#!/usr/bin/env just --justfile

set dotenv-load
set positional-arguments

# Constants/Preferences
user := 'ada'

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
  args="{{args}}"
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
py args='':
  @uv run python {{args}}

# Run a Django management command
[group('python')]
dj args='':
  @uv run python src/manage.py {{args}}


### Workflow

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

# Run a development server bareback
[group('workflow')]
_develop-local:
  @just python runserver_plus

# # Run a dev server with Docker Compose
# [group('workflow')]
# _develop-docker:
#   # should just require `docker-compose` up

# # Run a dev server in the cloud
# [group('workflow')]
# _develop-local:
#   # run `tofu apply` against the dev environment?


# TODO: Defer to _develop-docker or _develop-cloud based on an env var?
# Run a development server
[group('workflow')]
develop target='local':
  @just _develop-{{target}}