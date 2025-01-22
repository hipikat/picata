#!/bin/bash
#
# Drop the database, load the latest or specified snapshot, and apply remaining migrations.
#
set -euo pipefail

# Parse arguments
SNAPSHOT_ARG="${1:-latest}"

# Resolve the snapshot directory
if [[ "$SNAPSHOT_ARG" == "latest" ]]; then
    if [[ -d "snapshots/latest" ]]; then
        SNAPSHOT_DIR="snapshots/latest"
        echo "Using the latest snapshot at $SNAPSHOT_DIR"
    else
        echo "No latest snapshot found!"
        exit 1
    fi
else
    MATCHING_ARCHIVES=$(ls snapshots/*"$SNAPSHOT_ARG"*.tar.gz 2>/dev/null || true)
    MATCH_COUNT=$(echo "$MATCHING_ARCHIVES" | wc -l)
    if [[ "$MATCH_COUNT" -eq 0 ]]; then
        echo "No matching snapshots found for '$SNAPSHOT_ARG'."
        exit 1
    elif [[ "$MATCH_COUNT" -gt 1 ]]; then
        echo "Multiple matches found for '$SNAPSHOT_ARG':"
        echo "$MATCHING_ARCHIVES"
        echo "Please provide a more specific date string."
        exit 1
    fi
    ARCHIVE_PATH="$MATCHING_ARCHIVES"
    SNAPSHOT_DIR=$(mktemp -d)
    echo "Extracting snapshot from $ARCHIVE_PATH to $SNAPSHOT_DIR"
    tar -xzf "$ARCHIVE_PATH" -C "$SNAPSHOT_DIR"
fi

# Verify required snapshot files
for REQUIRED_FILE in schema.sql system.sql locales.sql data.json; do
    if [[ ! -f "$SNAPSHOT_DIR/$REQUIRED_FILE" ]]; then
        echo "Error: $REQUIRED_FILE is missing in the snapshot directory."
        exit 1
    fi
done

# Restore the media directory
if [[ -d "$SNAPSHOT_DIR/media" ]]; then
    echo "Restoring media files..."
    rsync -av "$SNAPSHOT_DIR/media/" media/
else
    echo "Warning: No media directory found in the snapshot. Skipping media restore."
fi

# Database restoration
if [[ -n "${DB_PASSWORD:-}" ]]; then
    echo "Found a database password…"
    export PGPASSWORD="$DB_PASSWORD"
else
    echo "No database password found!"
fi

echo "Dropping and recreating the database..."
dropdb -U wagtail hpkdb || true
createdb -U wagtail hpkdb

echo "Restoring database schema and data..."
psql -U wagtail -d hpkdb -f "$SNAPSHOT_DIR/schema.sql"
psql -U wagtail -d hpkdb -f "$SNAPSHOT_DIR/locales.sql"
psql -U wagtail -d hpkdb -f "$SNAPSHOT_DIR/system.sql"

echo "Decrypting and restoring auth_user data..."
AUTH_USER_DUMP="$SNAPSHOT_DIR/auth_user.sql.gpg"
if [[ -f "$AUTH_USER_DUMP" ]]; then
    if [[ -z "${SNAPSHOT_PASSWORD:-}" ]]; then
        echo "Error: Missing SNAPSHOT_PASSWORD for decrypting auth_user dump."
        exit 1
    fi
    gpg --batch --yes --passphrase "$SNAPSHOT_PASSWORD" \
        --output "$SNAPSHOT_DIR/auth_user.sql" \
        "$AUTH_USER_DUMP"
    psql -U wagtail -d hpkdb -f "$SNAPSHOT_DIR/auth_user.sql"
    rm "$SNAPSHOT_DIR/auth_user.sql"  # Clean up plaintext after use
else
    echo "No encrypted auth_user dump found. Skipping auth_user restore."
fi

echo "Restoring Wagtail data..."
mkdir -p logs
uv run python src/manage.py loaddata "$SNAPSHOT_DIR/data.json"

echo "Running migrations..."
uv run python src/manage.py migrate

echo "Rebuilding search index..."
uv run python src/manage.py update_index

echo "Snapshot restored successfully."

# Cleanup temporary directory if created
if [[ -n "${ARCHIVE_PATH:-}" ]]; then
    echo "Cleaning up extracted snapshot..."
    rm -rf "$SNAPSHOT_DIR"
fi
