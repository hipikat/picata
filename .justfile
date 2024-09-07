#!/usr/bin/env just --justfile

set dotenv-load
set positional-arguments

# Constants/Preferences
user := "${DEVELOPER}"

# Get the project name from 'name' in '[project]' in 'pyproject.toml'
project_name := `awk '/^\[project\]/ { proj = 1 } proj && /^name = / { gsub(/"/, "", $3); print $3; exit }' pyproject.toml`

# Print system info and available `just` recipes
_default:
  @echo "This is an {{arch()}} machine with {{num_cpus()}} cpu(s), on {{os()}}."
  @echo "Running: {{just_executable()}}"
  @echo "   with: {{justfile()}}"
  @echo "     in: {{invocation_directory_native()}}"
  @echo ""
  @just --list


### Infrastructure

tofu_root := "infra/"
tofu_vars := "-var-file=secrets.tfvars"
tofu_env_cmds := "plan apply destroy"
db_name := "hpkio_db"

# Run an OpenTofu command, using applicable tfvar files
[group('infra')]
tofu *args='':
  #!/usr/bin/env bash
  args=({{args}})
  cd {{tofu_root}}
  if [[ " {{tofu_env_cmds}} " =~ " ${args[0]} " ]]; then
    args=("${args[0]} {{tofu_vars}}" "${args[@]:1}")
    tofu_env=$(just tofu workspace show)
    if [ -f "envs/$tofu_env.tfvars" ]; then
      args=("${args[0]}" "-var-file=envs/$tofu_env.tfvars" "${args[@]:1}")
    fi
  fi
  tofu ${args[@]}

# Run an OpenTofu command against a specific workspace
[group('infra')]
tofu-in workspace='' *args='':
  #!/usr/bin/env bash
  old_workspace=$(just tofu workspace show)
  cd {{tofu_root}}
  [ "{{workspace}}" != "$old_workspace" ] && tofu workspace select {{workspace}} > /dev/null
  just -q tofu {{args}}
  [ "{{workspace}}" != "$old_workspace" ] && tofu workspace select $old_workspace > /dev/null

# Get a raw OpenTofu output, or list all if none are specified
[group('infra')]
tofu-output key='' workspace='':
  #!/usr/bin/env bash
  [ -n "{{workspace}}" ] && cmd="tofu-in {{workspace}}" || cmd="tofu"
  [ -n "{{key}}" ] && key="-raw {{key}}" || key=""
  just $cmd output $key


### Python/Django

# Run a Python command
[group('python')]
py *args='':
  @uv run python {{args}}

# Run a Django management command
[group('python')]
dj *args='':
  @uv run python src/manage.py {{args}}


### Linting
# Rewrite all OpenTofu config files into the canonical format
[group('lint')]
lint-tofu:
  @find infra/ -type f \( -name '*.tf' -o -name '*.tfvars' -o -name '*.tftest.hcl' \) -exec tofu fmt {} +


### Workflow

# Run django-extensions' `runserver_plus` development server
[group('workflow')]
_develop-local:
  @just dj runserver_plus

# # Run a dev server with Docker Compose
# [group('workflow')]
# _develop-docker:
#   # should just require `docker-compose` up

# # Run a dev server in the cloud
# [group('workflow')]
# _develop-local:
#   # run `tofu apply` against the dev environment?

# Run a development server
[group('workflow')]
develop target='local':
  @just _develop-{{target}}

# Make and run Django migrations
[group('workflow')]
migrate:
  just dj makemigrations
  just dj migrate

# Run all lint commands across the project
[group('workflow')]
lint:
  just lint-tofu

# SSH into the server for `env` environment
[group('workflow')]
ssh env="dev":
  #!/usr/bin/env bash
  server_ip=$(just -q tofu-output server_ip dev 2> /dev/null)
  if [ $(echo "$server_ip" | wc -l) -ne 1 ]; then
    echo "error: Could not determine server IP for {{env}} environment." >&2
    exit 1
  fi
  echo "Connecting to {{env}} server at $server_ip..."
  ssh {{user}}@$server_ip

# Update 'magic' strings in the project from values in .env
[group('workflow')]
update-magic:
  @scripts/update_magic.sh