//! Picata's native command-line interface.
//!
//! Cargo normally looks for a binary at `src/main.rs`, relative to the
//! `Cargo.toml` that defines its *crate* (Rust package). Picata's `Cargo.toml`
//! remains at the repository root, and its `[[bin]]` table explicitly points
//! Cargo here instead: `path = "rust/main.rs"`. The `rust/` directory is our
//! chosen home for Rust source code, not a magic Cargo directory; it keeps the
//! Rust and Python source trees clearly separated.
//!
//! The program currently has one path through it:
//!
//! 1. Clap parses `picata new <name>` into ordinary Rust values.
//! 2. `main` asks the operating system for the current directory.
//! 3. `run` dispatches the parsed subcommand.
//! 4. `create_project` creates `<name>/picata.yaml`.
//! 5. Any recoverable failure becomes a `CliError`, is printed to stderr, and
//!    produces a non-zero process exit code.

// `use` brings names into this module's scope. Rust's standard library is
// available automatically, but its individual types and modules are normally
// referred to through paths such as `std::path::Path` or imported like this.
use std::fmt;
use std::fs::{self, File};
use std::path::{Component, Path, PathBuf};
use std::process::ExitCode;

// Clap is an external crate declared in `Cargo.toml`. Its `derive` feature
// supplies procedural macros which generate the argument parser at compile
// time from the structs, enums, and attributes below.
use clap::{Parser, Subcommand};

/// The complete command line after Clap has parsed it.
//
// `derive` asks macros to generate trait implementations for this type:
//
// - `Debug` lets Rust format it with `{:?}`, which is useful while debugging.
// - `Parser` generates `Cli::parse()` and `Cli::try_parse_from(...)`.
//
// Attributes beginning with `#[...]` attach metadata to the next item. This
// `command` attribute configures Clap rather than changing runtime state.
#[derive(Debug, Parser)]
#[command(
    name = "picata",
    version,
    about = "The command-line interface for Picata"
)]
struct Cli {
    // This field contains exactly one variant of the `Command` enum. Telling
    // Clap that it is a `subcommand` gives us the `picata new ...` shape.
    #[command(subcommand)]
    command: Command,
}

/// A command Picata knows how to execute.
//
// An `enum` is a closed set of possible variants. Unlike a stringly-typed
// command name, it lets the compiler require us to handle every command when
// we dispatch it later. Adding (say) `Doctor` here will make an incomplete
// `match` in `run` fail to compile.
#[derive(Debug, PartialEq, Subcommand)]
enum Command {
    /// Create a new Picata project.
    New {
        /// Name of the directory to create in the current directory.
        // A `String` owns its UTF-8 text. Clap constructs and owns this value,
        // so it can safely outlive the raw operating-system argument list.
        name: String,
    },
}

/// A user-facing failure that prevents a CLI command from completing.
//
// This is a *tuple struct* (sometimes called a newtype): it wraps a `String`
// while remaining a distinct type. That distinction stops an arbitrary string
// from being mistaken for a handled CLI error and leaves room for richer error
// variants later without changing every function signature today.
#[derive(Debug)]
struct CliError(String);

// `Display` controls the friendly `{error}` representation of `CliError`.
// Implementing it ourselves lets `main` print the contained message without
// exposing the tuple field or using the developer-oriented `Debug` format.
impl fmt::Display for CliError {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        // `&self` borrows the error immutably; formatting does not consume it.
        // `&mut formatter` is an exclusive mutable borrow supplied by Rust's
        // formatting machinery. `'_` asks the compiler to infer its lifetime.
        formatter.write_str(&self.0)
    }
}

/// Create a project directory containing an empty `picata.yaml`.
//
// `root` and `name` are borrowed (`&`) rather than owned: this function only
// needs to inspect them. `Path` is the borrowed filesystem-path type, analogous
// to how `str` is borrowed text. `PathBuf` is its owned counterpart, analogous
// to `String`, and is returned because the new path must survive this call.
//
// `Result<Success, Failure>` makes failure explicit in the type system. The
// caller must either handle `CliError` or deliberately propagate it.
fn create_project(root: &Path, name: &str) -> Result<PathBuf, CliError> {
    // This does not touch the filesystem. It only views the borrowed string as
    // a platform-aware path so we can validate its components.
    let project_name = Path::new(name);
    let mut components = project_name.components();

    // We deliberately accept one normal filename component and nothing else.
    // This rejects empty input, `.`, `..`, absolute paths, and nested paths.
    //
    // `matches!` is a standard macro for testing a value against a pattern.
    // Calling `next()` advances the mutable iterator, so the second call tells
    // us whether an unwanted second component exists.
    if !matches!(components.next(), Some(Component::Normal(_))) || components.next().is_some() {
        // `return` exits immediately. `Err(...)` is the failure variant of
        // `Result`; `format!` creates an owned String with `name` interpolated.
        return Err(CliError(format!(
            "project name must be a single directory name: {name}"
        )));
    }

    // `join` creates a new `PathBuf`; it neither mutates `root` nor creates the
    // directory. Keeping path construction separate from I/O is easy to test.
    let project_directory = root.join(project_name);

    // `create_dir` creates exactly one directory and fails if it already
    // exists. That is intentional: `picata new` must never merge into or
    // overwrite a directory the user already owns.
    //
    // The standard I/O error is useful but lacks Picata context. `map_err`
    // transforms only the failure side of the Result into our `CliError`. The
    // trailing `?` returns that error from this function immediately; on
    // success it unwraps `()` and execution continues.
    fs::create_dir(&project_directory).map_err(|error| {
        // `|error| { ... }` is a closure: a small anonymous function passed to
        // `map_err`. `display()` provides a human-readable path formatter.
        CliError(format!(
            "could not create {}: {error}",
            project_directory.display()
        ))
    })?;

    let config_path = project_directory.join("picata.yaml");

    // `File::create` creates a new empty file (or truncates an existing one).
    // The parent directory was created by us immediately above, so it should
    // contain nothing; no user file is at risk of truncation here.
    if let Err(error) = File::create(&config_path) {
        // If file creation fails, make a best-effort attempt to roll back the
        // empty directory. `let _ =` explicitly discards the cleanup Result:
        // the original file error is more useful than a secondary cleanup
        // error, and we have no sensible recovery beyond reporting failure.
        let _ = fs::remove_dir(&project_directory);

        return Err(CliError(format!(
            "could not create {}: {error}",
            config_path.display()
        )));
    }

    // `Ok(...)` is Result's success variant. Returning the owned PathBuf lets
    // the caller report exactly what was created.
    Ok(project_directory)
}

/// Dispatch one parsed command.
fn run(command: Command, root: &Path) -> Result<(), CliError> {
    // `match` is exhaustive pattern matching. It also *moves* the owned
    // `command` into the chosen arm. Destructuring `Command::New { name }`
    // moves its owned String into the local variable `name`.
    match command {
        Command::New { name } => {
            // Borrow `name` as `&str` for the duration of this call. `?`
            // propagates a CliError to `main` without printing it here; keeping
            // presentation at the program boundary prevents duplicate errors.
            let project_directory = create_project(root, &name)?;

            // Macros use `!` in Rust. `println!` writes a formatted line to
            // stdout, which is appropriate for a successful command result.
            println!("Created Picata project at {}", project_directory.display());
        }
    }

    // `()` is Rust's unit value: this function succeeded but has no meaningful
    // data to return. It is similar in role to Python's `None`.
    Ok(())
}

/// Parse arguments, run the selected command, and choose the process exit code.
fn main() -> ExitCode {
    // Clap reads the real process arguments here. Invalid syntax and requests
    // such as `--help` or `--version` are handled by Clap before it returns.
    let cli = Cli::parse();

    // Asking for the current directory can fail (for example, if the directory
    // was removed after the process started), so the standard library returns
    // a Result. `match` makes both possibilities explicit.
    let root = match std::env::current_dir() {
        Ok(root) => root,
        Err(error) => {
            // Errors belong on stderr. Returning `FAILURE` maps to a portable
            // non-zero status instead of baking in an OS-specific integer.
            eprintln!("error: could not determine the current directory: {error}");
            return ExitCode::FAILURE;
        }
    };

    // `main` is the outer boundary that turns our domain-level Result into
    // terminal output and an operating-system process status.
    match run(cli.command, &root) {
        Ok(()) => ExitCode::SUCCESS,
        Err(error) => {
            eprintln!("error: {error}");
            ExitCode::FAILURE
        }
    }
}

// `cfg(test)` tells the compiler to include this module only in test builds.
// Shipping the release binary therefore carries none of this test-only code.
#[cfg(test)]
mod tests {
    use std::time::{SystemTime, UNIX_EPOCH};

    // A child module has its own scope. Importing `super::*` makes the private
    // items from the parent module available to these white-box unit tests.
    use super::*;

    /// Create a sufficiently unique directory for one test invocation.
    //
    // We use only the standard library for this tiny suite rather than adding a
    // development dependency. A production-sized suite would likely use the
    // `tempfile` crate so cleanup also happens automatically after panics.
    fn temporary_directory(test_name: &str) -> PathBuf {
        let nonce = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            // `expect` unwraps a Result or panics with this explanation. That is
            // appropriate in setup code: a broken test fixture should fail the
            // test immediately rather than become a user-facing CliError.
            .expect("system clock should be later than the Unix epoch")
            .as_nanos();

        let path = std::env::temp_dir().join(format!(
            "picata-cli-{test_name}-{}-{nonce}",
            std::process::id()
        ));

        fs::create_dir(&path).expect("temporary directory should be created");
        path
    }

    // Each `#[test]` function becomes an independently reported test case under
    // `cargo test`.
    #[test]
    fn parses_new_command() {
        // `try_parse_from` is the non-exiting parser useful in tests. Unlike
        // `Cli::parse`, it accepts an explicit argument sequence. The first
        // element conventionally represents the executable name.
        let cli = Cli::try_parse_from(["picata", "new", "foo"]).unwrap();

        // `assert_eq!` requires `Command: PartialEq`, which is why that trait is
        // among the enum's derived implementations near the top of this file.
        assert_eq!(
            cli.command,
            Command::New {
                name: "foo".to_owned()
            }
        );
    }

    #[test]
    fn new_creates_an_empty_config_file() {
        let root = temporary_directory("new");

        let project_directory = create_project(&root, "foo").expect("project should be created");
        let config_path = project_directory.join("picata.yaml");

        // Check both parts of the contract: the path is a regular file, and its
        // length is exactly zero bytes.
        assert!(config_path.is_file());
        assert_eq!(fs::metadata(config_path).unwrap().len(), 0);

        // Cleanup is explicit because our standard-library helper has no Drop
        // guard. `unwrap` makes an unexpected cleanup failure visible in tests.
        fs::remove_dir_all(root).unwrap();
    }

    #[test]
    fn new_refuses_to_replace_an_existing_directory() {
        let root = temporary_directory("existing");
        fs::create_dir(root.join("foo")).unwrap();

        // `expect_err` is the mirror of `expect`: success would panic because
        // this scenario is specifically required to fail.
        let error = create_project(&root, "foo").expect_err("existing project should be refused");

        assert!(error.to_string().contains("could not create"));
        fs::remove_dir_all(root).unwrap();
    }

    #[test]
    fn new_rejects_a_path_instead_of_a_name() {
        let root = temporary_directory("path");

        let error = create_project(&root, "foo/bar").expect_err("paths should be refused");

        // Here the precise wording is part of the tested user experience.
        assert_eq!(
            error.to_string(),
            "project name must be a single directory name: foo/bar"
        );
        fs::remove_dir_all(root).unwrap();
    }
}
