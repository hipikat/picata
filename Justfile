#!/usr/bin/env just --justfile

set dotenv-load := true
set positional-arguments := true

# Constants/Preferences

user := "${DEVELOPER}"

# Get the project name from 'name' in '[project]' in 'pyproject.toml'

project_name := `awk '/^\[project\]/ { proj = 1 } proj && /^name = / { gsub(/"/, "", $3); print $3; exit }' pyproject.toml`

# Print system info and available `just` recipes
_default:
    @echo "This is an {{ arch() }} machine with {{ num_cpus() }} cpu(s), on {{ os() }}."
    @echo "Running: {{ just_executable() }}"
    @echo "   with: {{ justfile() }}"
    @echo "     in: {{ invocation_directory_native() }}"
    @echo ""
    @just --list

### Infrastructure

tofu_root := "infra/"
tofu_env_cmds := "plan apply destroy"
tofu_dotenv_vars := "TLD DB_NAME DB_USER"

# Generate an HCL-compattible file from the .env file at infra/dot_env.tfvars
[group('infra')]
_dotenv-for-tofu:
    #!/usr/bin/env bash
    whitelist="{{ tofu_dotenv_vars }}"
    {
      echo "# This file was generated by the '_dotenv-for-tofu' recipe in the Justfile."
      echo "# Do not edit this file manually; changes will be overwritten.\n"
      grep -v '^#' .env | grep -v '^[[:space:]]*$' | awk -F= -v whitelist="$whitelist" '{
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", $1);
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2);
        if ((" " whitelist " ") ~ (" " $1 " ")) {
          print tolower($1) " = \"" $2 "\""
        }
      }'
    } > infra/dot_env.tfvars

# Run an OpenTofu command; uses applicabletfvar files, gets raw output
[group('infra')]
[no-exit-message]
tofu *args='': _dotenv-for-tofu
    #!/usr/bin/env bash
    args=({{ args }})
    cd {{ tofu_root }}
    if [[ " {{ tofu_env_cmds }} " =~ " ${args[0]} " ]]; then
      args=("${args[0]} -var-file=dot_env.tfvars -var-file=settings.tfvars -var-file=secrets.tfvars" "${args[@]:1}")
      tofu_env=$(just tofu workspace show)
      if [ -f "envs/$tofu_env.tfvars" ]; then
        args=("${args[0]}" "-var-file=envs/$tofu_env.tfvars" "${args[@]:1}")
      fi
      public_ip=$(curl -s http://checkip.amazonaws.com)
      if [ -z "$public_ip" ]; then
        echo "error: Could not fetch public IP." >&2
        exit 1
      fi
      args=("${args[0]}" "-var=internal_ips=${public_ip}" "${args[@]:1}")
    elif [[ "${args[0]}" == "output" && ${#args[@]} -gt 1 ]]; then
      args=("${args[0]} -raw" "${args[@]:1}")
    fi
    tofu ${args[@]}

# Run an OpenTofu command against a specific workspace
[group('infra')]
tofu-in workspace='' *args='':
    #!/usr/bin/env bash
    old_workspace=$(just tofu workspace show)
    cd {{ tofu_root }}
    [ "{{ workspace }}" != "$old_workspace" ] && tofu workspace select {{ workspace }} > /dev/null
    just -q tofu {{ args }}
    [ "{{ workspace }}" != "$old_workspace" ] && tofu workspace select $old_workspace > /dev/null

# Run tofu in infra/managed_volume, in a workspace named for the volume
[group('infra')]
[no-exit-message]
tofu-volume *args='': _dotenv-for-tofu
    #!/usr/bin/env bash
    args=({{ args }})
    cd {{ tofu_root }}managed_volume/
    if [[ " {{ tofu_env_cmds }} " =~ " ${args[0]} " ]]; then
      args=("${args[0]} -var-file=../dot_env.tfvars -var-file=../settings.tfvars -var-file=../secrets.tfvars" "${args[@]:1}")
      volume_name=$(just tofu-volume workspace show)
      if [ -f "$volume_name.tfvars" ]; then
        args=("${args[0]}" "-var-file=$volume_name.tfvars" "${args[@]:1}")
      else
        echo "error: In $(pwd); no $volume_name.tfvars file found." >&2
      fi
    elif [[ "${args[0]}" == "output" && ${#args[@]} -gt 1 ]]; then
      args=("${args[0]} -raw" "${args[@]:1}")
    fi
    tofu ${args[@]}

# List DigitalOcean volumes
[group('infra')]
volume-list:
    doctl compute volume list --format 'Name,ID,Region,Size,DropletIDs,Tags'

# List DigitalOcean Volume snapshots
[group('infra')]
volume-snapshot-list:
    doctl compute snapshot list --resource volume --format 'Name,ID,ResourceId,CreatedAt,Size,MinDiskSize,Tags'

# Attach a named volume to specified server
[group('infra')]
[no-exit-message]
volume-attach volume_name droplet_name:
    #!/usr/bin/env bash
    volume_id=$(doctl compute volume list --format Name,ID --no-header | grep -w "^{{ volume_name }}" | awk '{print $2}')
    if [ -z "$volume_id" ]; then
      echo "error: Volume '{{ volume_name }}' not found." >&2
      exit 1
    fi
    droplet_id=$(doctl compute droplet list --format Name,ID --no-header | grep -w "^{{ droplet_name }}" | awk '{print $2}')
    if [ -z "$droplet_id" ]; then
      echo "error: Droplet '{{ droplet_name }}' not found." >&2
      exit 1
    fi
    echo "Attaching volume '{{ volume_name }}' (ID: $volume_id) to droplet '{{ droplet_name }}' (ID: $droplet_id)..."
    doctl compute volume-action attach "$volume_id" "$droplet_id" --wait

# Detach a named volume from any server it's attached to
[group('infra')]
[no-exit-message]
volume-detach volume_name:
    #!/usr/bin/env bash
    volume_id=$(doctl compute volume list --format Name,ID --no-header | grep -w "^{{ volume_name }}" | awk '{print $2}')
    if [ -z "$volume_id" ]; then
      echo "error: Volume '{{ volume_name }}' not found." >&2
      exit 1
    fi
    current_droplet_id=$(doctl compute volume get "$volume_id" --format DropletIDs --no-header | jq -r '.[0]')
    if [ "$current_droplet_id" = "null" ]; then
      echo "Volume '{{ volume_name }}' is already detached."
    else
      echo "Detaching volume '{{ volume_name }}' (ID: $volume_id) from droplet ID $current_droplet_id..."
      doctl compute volume-action detach $volume_id $current_droplet_id --wait
    fi

# Mount a volume attached to a container to a specific path
[group('infra')]
volume-mount volume_name mount_point:
    #!/usr/bin/env bash
    just ssh "\
      mkdir -p {{ mount_point }};\
      sudo mount -o discard,defaults,noatime /dev/disk/by-id/scsi-0DO_Volume_{{ volume_name }} {{ mount_point }};\
      echo '/dev/disk/by-id/scsi-0DO_Volume_{{ volume_name }} {{ mount_point }} ext4 defaults,nofail,discard 0 0' | sudo tee -a /etc/fstab;\
      echo 'Volume {{ volume_name }} mounted at {{ mount_point }}.'\
    "

# Make a snapshot image of a volume
[group('infra')]
[no-exit-message]
volume-snapshot volume_name snapshot_name="":
    #!/usr/bin/env bash
    volume_name="{{ volume_name }}"
    volume_id=$(doctl compute volume list --format Name,ID --no-header | grep -w "^$volume_name\b" | awk '{print $2}')
    snapshot_name=${snapshot_name:-$volume_name}
    doctl compute volume snapshot $volume_id --snapshot-name $snapshot_name

### Python/Django

# Run a Python command
[group('python')]
py *args='':
    uv run python {{ args }}

# Run a Django management command
[group('python')]
dj *args='':
    uv run python src/manage.py {{ args }}

# Run Python code in the Django shell
[group('python')]
dj-shell *command='':
    uv run python src/manage.py shell -c "{{ command }}"

# Create superuser with a non-interactive password setting
[group('python')]
dj-createsuperuser user email password:
    #!/usr/bin/env bash
    just dj createsuperuser --noinput --username="{{ user }}" --email="{{ email }}"
    just dj-shell "
    from django.contrib.auth import get_user_model
    User = get_user_model()
    user = User.objects.get(username='{{ user }}')
    user.set_password('{{ password }}')
    user.save()
    print('Superuser password set successfully.')"

### Database

# Initialize the database and user, with a password if provided
[group('database')]
db-init db_password='':
    #!/usr/bin/env bash
    psql_cmd=$([[ "$(uname)" == "Darwin" ]] && echo "psql" || echo "sudo -u postgres psql")
    createdb_cmd=$([[ "$(uname)" == "Darwin" ]] && echo "createdb" || echo "sudo -u postgres createdb")
    role_exists=$($psql_cmd -tAc "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER';")
    if [[ "$role_exists" == "1" ]]; then
      echo "Role $DB_USER exists."
      if [[ -n "{{ db_password }}" ]]; then
        echo "Updating password for role $DB_USER..."
        $psql_cmd -c "ALTER ROLE $DB_USER WITH PASSWORD '{{ db_password }}';"
      else
        echo "Unsetting password for role $DB_USER..."
        $psql_cmd -c "ALTER ROLE $DB_USER WITH PASSWORD NULL;"
      fi
    else
      if [[ -n "{{ db_password }}" ]]; then
        echo "Creating role $DB_USER with password..."
        $psql_cmd -c "CREATE ROLE $DB_USER WITH LOGIN PASSWORD '{{ db_password }}';"
      else
        echo "Creating role $DB_USER without a password..."
        $psql_cmd -c "CREATE ROLE $DB_USER WITH LOGIN;"
      fi
    fi
    echo "Granting CREATEDB privilege to $DB_USER..."
    $psql_cmd -c "ALTER ROLE $DB_USER CREATEDB;"
    echo "Checking for database $DB_NAME..."
    db_exists=$($psql_cmd -tA -c "SELECT 1 FROM pg_database WHERE datname='$DB_NAME';")
    if [[ "$db_exists" == "1" ]]; then
      echo "Database $DB_NAME already exists. Skipping creation."
    else
      echo "Creating database $DB_NAME owned by $DB_USER..."
      $createdb_cmd -O $DB_USER $DB_NAME
    fi

# Drop the application database and associated user, if they exist
[group('database')]
db-destroy:
    #!/usr/bin/env bash
    prefix=$([[ "$(uname)" == "Darwin" ]] && echo "" || echo "sudo -u postgres")
    if $prefix psql -tAc "SELECT 1 FROM pg_database WHERE datname='$DB_NAME';" | grep -q 1; then
      echo "Database $DB_NAME found. Dropping it..."
      $prefix psql -c "DROP DATABASE $DB_NAME;"
    else
      echo "Database $DB_NAME does not exist. Skipping drop."
    fi
    if $prefix psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER';" | grep -q 1; then
      echo "Role $DB_USER found. Dropping it..."
      $prefix psql -c "DROP ROLE $DB_USER;"
    else
      echo "Role $DB_USER does not exist. Skipping drop."
    fi

### Linting

# Rewrite all OpenTofu config files into the canonical format
[group('lint')]
lint-tofu:
    @find infra/ -type f \( -name '*.tf' -o -name '*.tfvars' -o -name '*.tftest.hcl' \) -exec tofu fmt {} +

# Run Ruff linting and fix any auto-fixable issues
[group('lint')]
lint-ruff:
    @ruff check . --fix

# Run 'just --fmt', and overwrite the Justfile. (Unstable!)
[group('lint')]
lint-just:
    @just --fmt --unstable

# Run all linting commands across the project
[group('lint')]
lint:
    just lint-tofu
    just lint-ruff
    just lint-just

### Docker

# List the target images defined in the Dockerfile
[group('docker')]
_list-docker-targets:
    #!/usr/bin/env bash
    echo "Available targets:"
    grep -E '^FROM ' Dockerfile | awk '{target=$4; sub(/^hpk-/, "", target); print target}'

# Build a Docker image for hpk-(target), tagged with 'latest'
[group('docker')]
docker-build target='' tag='latest':
    #!/usr/bin/env bash
    [ -z "{{ target }}" ] && just _list-docker-targets && exit
    cmd="docker build --target hpk-{{ target }} -t hpk-{{ target }}:{{ tag }} ."
    echo $cmd && $cmd

# Run a transient Docker container built from a hpk-(target) image
[group('docker')]
docker-run target='' *command='bash':
    #!/usr/bin/env bash
    [ -z "{{ target }}" ] && just _list-docker-targets && exit
    cmd='docker run --rm -it hpk-{{ target }} {{ command }}'
    echo $cmd && $cmd

# Remove named volumes attached to the Docker Compose cluster
[group('docker')]
compose-clean:
    docker compose down -v

# Bring up the Docker Compose dev environment with existing images
[group('docker')]
compose:
    docker compose up

# Bring up the Docker Compose dev environment; build where needed
[group('docker')]
compose-build:
    docker compose up --build

# Bring up the Docker Compose dev environment; refresh volumes & build
[group('docker')]
compose-fresh:
    @just compose-clean
    @just compose-build

# Make and run Django migrations in the Docker Compose environment
[group('docker')]
compose-migrate:
    docker compose exec app-dev just migrate

### Workflow

# Run django-extensions' `runserver_plus` development server
[group('workflow')]
_develop-local:
    @just dj runserver_plus

# Run a dev server with Docker Compose
[group('workflow')]
_develop-docker:
    # should just require `docker-compose` up
    @just compose

# # Run a dev server in the cloud
# [group('workflow')]
# _develop-cloud:
#   # run `tofu apply` against the dev environment?

# Run a development server
[group('workflow')]
develop target='local':
    @just _develop-{{ target }}

# Sync the project's Python environment. (Runs `uv sync`.)
[group('workflow')]
init-python *args='':
    uv sync {{ args }}

# Sync the Python environment, allowing package upgrades.
[group('workflow')]
update-python *args='':
    just init-python --upgrade {{ args }}

# Install the project's Node environment. (Runs `npm update`.)
[group('workflow')]
init-node *args='':
    npm update {{ args }}

# Update Node packages to the latest, respecting semver constraints.
[group('workflow')]
update-node *args='':
    npm update --save {{ args }}

# Initialise the project's Python & Node environments.
[group('workflow')]
init:
    just init-python
    just init-node

# Update the Python & Node environments, and associated lock files.
[group('workflow')]
update:
    just update-python
    just update-node

# Make and run Django migrations
[group('workflow')]
migrate:
    just dj makemigrations
    just dj migrate

# Run an ssh command against the current workspace (or just ssh in)
[group('workflow')]
[no-exit-message]
ssh *args='':
    #!/usr/bin/env bash
    workspace=$(just -q tofu workspace show)
    just ssh-in $workspace "{{ args }}"

# Run ssh against the server for the specified environment
[group('workflow')]
[no-exit-message]
ssh-in env *args='':
    #!/usr/bin/env bash
    # args=({{ args }})
    server_ip=$(just -q tofu-in {{ env }} output server_ip 2> /dev/null)
    if [ $(echo "$server_ip" | wc -l) -ne 1 ]; then
      echo "error: Could not determine server IP for {{ env }} environment." >&2
      exit 1
    fi
    ssh {{ user }}@$server_ip "{{ args }}"

# Copy files from the current workspace's server to local
[group('workflow')]
[no-exit-message]
scp-get source target='':
    #!/usr/bin/env bash
    workspace=$(just -q tofu workspace show)
    just scp-get-in "$workspace" "{{ source }}" "${target:-.}"

# Copy files from a specific workspace's server to local
[group('workflow')]
[no-exit-message]
scp-get-in env source target='':
    #!/usr/bin/env bash
    server_ip=$(just -q tofu-in "$env" output server_ip 2> /dev/null)
    if [ $(echo "$server_ip" | wc -l) -ne 1 ]; then
      echo "error: Could not determine server IP for $env environment." >&2
      exit 1
    fi
    scp "{{ user }}@${server_ip}:{{ source }}" "${target:-.}"

# Copy files from local to the current workspace's server
[group('workflow')]
[no-exit-message]
scp-put source target:
    #!/usr/bin/env bash
    workspace=$(just -q tofu workspace show)
    just scp-put-in "$workspace" "{{ source }}" "{{ target }}"

# Copy files from local to a specific workspace's server
[group('workflow')]
[no-exit-message]
scp-put-in env source target:
    #!/usr/bin/env bash
    server_ip=$(just -q tofu-in "$env" output server_ip 2> /dev/null)
    if [ $(echo "$server_ip" | wc -l) -ne 1 ]; then
      echo "error: Could not determine server IP for $env environment." >&2
      exit 1
    fi
    scp "{{ source }}" "{{ user }}@${server_ip}:{{ target }}"

# Build and collect JS & CSS, and watch for changes in source
[group('workflow')]
watch:
    npm run watch:build

# Set the INTERNAL_IPS on the server to your current public IP
[group('workflow')]
[no-exit-message]
set-internal env='':
    #!/usr/bin/env bash
    env=${env:-$(just -q tofu workspace show)}
    public_ip=$(curl -s http://checkip.amazonaws.com)
    if [ -z "$public_ip" ]; then
      echo "error: Could not fetch public IP." >&2
      exit 1
    fi
    echo "Setting INTERNAL_IPS=\"$public_ip\" on $env..."
    just ssh-in $env "\
      sudo sed -i '/^INTERNAL_IPS=/d' /etc/environment && \
      echo '\"INTERNAL_IPS=\\\"$public_ip\\\"\"' | sudo tee -a /etc/environment >/dev/null && \
      sudo systemctl restart gunicorn-hpk\
    "
