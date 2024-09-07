#!/usr/bin/env bash
#
# Updates any 'magic' variables (i.e. fixed strings) that couldn't be avoided with
# the use of environment variables (or whatever), such as in cloud-init config files.
#
set -euo pipefail
IFS=$'\n\t'

# Get the project directory
prj=$(dirname "$(dirname "$(readlink -f "$0")")")

# Check if .env exists in the project root
if [ ! -f "$prj/.env" ]; then
    echo ".env file not found!"
    exit 1
fi

# Determine whether we're on macOS or GNU/Linux
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed_inplace() { sed -i '' "$@"; }
else
    sed_inplace() { sed -i "$@"; }
fi

# Cycle through environment variables from .env
env_vars=$(grep -E '^[A-Za-z_][A-Za-z0-9_]*=.*' "$prj/.env")
for var in $env_vars; do
    key=$(echo "$var" | cut -d= -f1)
    value=$(echo "$var" | cut -d= -f2)

    # Update NODE_VERSION in cloud-init files
    if [ "$key" = "NODE_VERSION" ]; then
        echo "Checking NODE_VERSION in cloud-init files..."
        for file in "$prj/scripts/cloud-init"*.yml; do
            if grep -q "NODE_VERSION=\"$value\"" "$file"; then
                echo "* NODE_VERSION already up to date in $file"
            else
                echo "* Updating NODE_VERSION in $file to $value"
                sed_inplace "s/NODE_VERSION=\"[^\"]*\"/NODE_VERSION=\"$value\"/g" "$file"
            fi
        done
    fi
done

echo "Magic variables updated!"
