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
tofu_env_cmds := "plan apply destroy"
db_name := "hpkio_db"

# Run an OpenTofu command; uses applicable tfvar files, gets raw output
[group('infra')]
[no-exit-message]
tofu *args='':
  #!/usr/bin/env bash
  args=({{args}})
  cd {{tofu_root}}
  if [[ " {{tofu_env_cmds}} " =~ " ${args[0]} " ]]; then
    args=("${args[0]} -var-file=secrets.tfvars" "${args[@]:1}")
    tofu_env=$(just tofu workspace show)
    if [ -f "envs/$tofu_env.tfvars" ]; then
      args=("${args[0]}" "-var-file=envs/$tofu_env.tfvars" "${args[@]:1}")
    fi
  elif [[ "${args[0]}" == "output" && ${#args[@]} -gt 1 ]]; then
    args=("${args[0]} -raw" "${args[@]:1}")
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

# Perform tofu commands in the 'vscode_volume' OpenTofu configuration
[group('infra')]
[no-exit-message]
vscode-volume *args='':
  #!/usr/bin/env bash
  args=({{args}})
  cd {{tofu_root}}vscode_volume/
  if [[ " {{tofu_env_cmds}} " =~ " ${args[0]} " ]]; then
    args=("${args[0]} -var-file=../secrets.tfvars" "${args[@]:1}")
  elif [[ "${args[0]}" == "output" && ${#args[@]} -gt 1 ]]; then
    args=("${args[0]} -raw" "${args[@]:1}")
  fi
  tofu ${args[@]}

# Mount the vscode-data volume on the server for the current workspace
[group('infra')]
vscode-mount:
  #!/usr/bin/env bash
  volume_id=$(just -q vscode-volume output vscode_volume_id)
  droplet_id=$(just -q tofu output droplet_id)
  doctl compute volume-action attach $volume_id $droplet_id --wait

# Detach the vscode-data volume from any server it's attached to
[group('infra')]
vscode-unmount:
  #!/usr/bin/env bash
  volume_id=$(just -q vscode-volume output vscode_volume_id)
  attached_droplet_id=$(doctl compute volume get $volume_id --format DropletIDs --no-header | jq -r '.[0]')
  # TODO: remove the mount from the fstab file first
  doctl compute volume-action detach $volume_id $attached_droplet_id --wait


### Python/Django

# Run a Python command
[group('python')]
py *args='':
  uv run python {{args}}

# Run a Django management command
[group('python')]
dj *args='':
  uv run python src/manage.py {{args}}


### Linting

# Rewrite all OpenTofu config files into the canonical format
[group('lint')]
lint-tofu:
  @find infra/ -type f \( -name '*.tf' -o -name '*.tfvars' -o -name '*.tftest.hcl' \) -exec tofu fmt {} +

# Run all lint commands across the project
[group('lint')]
lint:
  just lint-tofu


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

# Run an ssh command against the current workspace (or just ssh in)
[group('workflow')]
ssh *args='':
  #!/usr/bin/env bash
  workspace=$(just -q tofu workspace show)
  just ssh-in $workspace {{args}}

# Run ssh against the server for the specified environment
[group('workflow')]
ssh-in env *args='':
  #!/usr/bin/env bash
  args=({{args}})
  server_ip=$(just -q tofu-in {{env}} output server_ip 2> /dev/null)
  if [ $(echo "$server_ip" | wc -l) -ne 1 ]; then
    echo "error: Could not determine server IP for {{env}} environment." >&2
    exit 1
  fi
  # if [[ ${#args[@]} -gt 0 ]]; then
  #   echo "Running command on {{env}} server at $server_ip..."
  # else
  #   echo "Connecting to {{env}} server at $server_ip..."
  # fi
  ssh {{user}}@$server_ip "${args[@]}"

# Update 'magic' strings in the project from values in .env
[group('workflow')]
update-magic:
  @scripts/update_magic.sh

# Build and collect JS & CSS, and watch for changes in source
[group('workflow')]
watch:
  npm run watch:build