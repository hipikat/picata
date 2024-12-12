#!/bin/bash
#
# Take a snapshot of the database.
#
# A snapshot consists of:
# - A timestamped directory under snapshots/ containing:
#   - An SQL dump of the database schema in schema.sql
#   - An SQL dump of the migrations table in migrations.sql
#   - An SQL dump of the locale table in locale.sql
#   - A JSON dump of data to data.json, excluding auth and sessions models
#
set -euo pipefail

TIMESTAMP=$(date +"%Y-%m-%d-%H%M%S")
SNAPSHOT_DIR="snapshots/$TIMESTAMP"
mkdir -p "$SNAPSHOT_DIR"

echo "Creating snapshot at $SNAPSHOT_DIR"

if [[ -n "${DB_PASSWORD:-}" ]]; then
    export PGPASSWORD="$DB_PASSWORD"
fi

pg_dump -U wagtail -h localhost --schema-only hpkdb > "$SNAPSHOT_DIR/schema.sql"
pg_dump -U wagtail -h localhost --data-only \
  --table=django_content_type \
  --table=django_migrations \
  --table=auth_group \
  --table=auth_group_permissions \
  --table=auth_permission \
  hpkdb > "$SNAPSHOT_DIR/system.sql"
pg_dump -U wagtail -h localhost --data-only --table=wagtailcore_locale hpkdb > "$SNAPSHOT_DIR/locales.sql"
uv run python src/manage.py dumpdata --exclude auth --exclude sessions --indent 2 > "$SNAPSHOT_DIR/data.json"

echo "Snapshot created successfully."
