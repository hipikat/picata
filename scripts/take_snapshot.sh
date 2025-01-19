#!/bin/bash
#
# Take a snapshot of the database and optionally archive it.
#
# Usage:
#   ./take_snapshot.sh [--no-archive|--just-archive]
#
# A snapshot is a directory (or tarball) consisting of:
# - An SQL dump of the database schema in schema.sql
# - An SQL dump of the migrations table in migrations.sql
# - An SQL dump of the locale table in locale.sql
# - A JSON dump of data to data.json, excluding auth and sessions models
# - TODO: A copy of the media/ directory excluding renditions
#

set -euo pipefail

# Flags
NO_ARCHIVE=false
JUST_ARCHIVE=false

for arg in "$@"; do
    case $arg in
        --no-archive) NO_ARCHIVE=true ;;
        --just-archive) JUST_ARCHIVE=true ;;
        *) echo "Unknown argument: $arg" && exit 1 ;;
    esac
done

if [[ "$NO_ARCHIVE" == true && "$JUST_ARCHIVE" == true ]]; then
    echo "Error: --no-archive and --just-archive are mutually exclusive."
    exit 1
fi

SNAPSHOT_DIR="snapshots/latest"
ARCHIVE_NAME="snapshots/$(date +"%Y-%m-%d-%H%M%S").tgz"

# Just archive the latest snapshot if requested
if [[ "$JUST_ARCHIVE" == true ]]; then
    if [[ -d "$SNAPSHOT_DIR" ]]; then
        echo "Archiving current snapshot to $ARCHIVE_NAME"
        tar -czf "$ARCHIVE_NAME" -C "$SNAPSHOT_DIR" .
        exit 0
    else
        echo "No snapshot found in $SNAPSHOT_DIR to archive!"
        exit 1
    fi
fi

# Prepare for a new snapshot
echo "Taking a snapshot..."
mkdir -p "$SNAPSHOT_DIR"

# Export DB_PASSWORD if set
if [[ -n "${DB_PASSWORD:-}" ]]; then
    export PGPASSWORD="$DB_PASSWORD"
fi

# Create core database snapshot data
pg_dump -U wagtail -h localhost --schema-only hpkdb > "$SNAPSHOT_DIR/schema.sql"
pg_dump -U wagtail -h localhost --data-only --table=wagtailcore_locale hpkdb > "$SNAPSHOT_DIR/locales.sql"
pg_dump -U wagtail -h localhost --data-only \
  --table=django_content_type \
  --table=django_migrations \
  --table=auth_group \
  --table=auth_group_permissions \
  --table=auth_permission \
  hpkdb > "$SNAPSHOT_DIR/system.sql"

# Make the trailing-whitespace pre-commit hook happy
sed -i '$ d' "$SNAPSHOT_DIR/schema.sql"
sed -i '$ d' "$SNAPSHOT_DIR/locales.sql"
sed -i '$ d' "$SNAPSHOT_DIR/system.sql"

# Create an encrypted dump of the auth_user table
if [[ -z "${SNAPSHOT_PASSWORD:-}" ]]; then
    echo "Error: Missing SNAPSHOT_PASSWORD environment variable."
    exit 1
fi
pg_dump -U wagtail -h localhost --data-only --table=auth_user hpkdb > "$SNAPSHOT_DIR/auth_user.sql"
gpg --batch --yes --passphrase "$SNAPSHOT_PASSWORD" \
    --symmetric --cipher-algo AES256 \
    --output "$SNAPSHOT_DIR/auth_user.sql.gpg" \
    "$SNAPSHOT_DIR/auth_user.sql"
rm "$SNAPSHOT_DIR/auth_user.sql"

# Dump the rest of Wagtail's table data from Django
uv run python src/manage.py dumpdata \
  --exclude auth \
  --exclude sessions \
  --exclude wagtailsearch.indexentry \
  --indent 2 > "$SNAPSHOT_DIR/data.json"

# Create a snapshot of the media directory, excluding renditions
MEDIA_DIR="media"
SNAPSHOT_MEDIA_DIR="$SNAPSHOT_DIR/media"
if [[ ! -d "$MEDIA_DIR" ]]; then
    echo "Media directory '$MEDIA_DIR' does not exist. Skipping media snapshot."
else
    echo "Saving media directory (excluding renditions) to snapshot..."
    mkdir -p "$SNAPSHOT_MEDIA_DIR"
    rsync -av --exclude 'images/' "$MEDIA_DIR/" "$SNAPSHOT_MEDIA_DIR/"
    echo "Media snapshot saved successfully."
fi

# Add TOML metadata
SNAPSHOT_METADATA="$SNAPSHOT_DIR/snapshot-data.toml"
echo "timestamp = '$(date +"%Y-%m-%d %H:%M:%S")'" > "$SNAPSHOT_METADATA"
echo "commit_hash = '$(git rev-parse HEAD 2>/dev/null || echo "unknown")'" >> "$SNAPSHOT_METADATA"
echo "last_migration = '$(uv run python src/manage.py showmigrations --plan | tail -n 1)'" >> "$SNAPSHOT_METADATA"
echo "hostname = '$(hostname)'" >> "$SNAPSHOT_METADATA"
echo "git_status = '''$(git status --short || echo "unknown")'''" >> "$SNAPSHOT_METADATA"

echo "Snapshot created in $SNAPSHOT_DIR."

# Skip archiving if requested
if [[ "$NO_ARCHIVE" == true ]]; then
    exit 0
fi

# Archive the snapshot
echo "Archiving snapshot to $ARCHIVE_NAME"
tar -czf "$ARCHIVE_NAME" -C "$SNAPSHOT_DIR" .
echo "Archive created: $ARCHIVE_NAME"
