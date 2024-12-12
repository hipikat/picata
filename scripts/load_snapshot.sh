#!/bin/bash
#
# Drop the database, load the latest snapshot, and apply remaining migrations.
#
set -euo pipefail

SNAPSHOT_DIR=$(ls -td snapshots/* 2>/dev/null | head -1 || true)
if [[ -z "${SNAPSHOT_DIR}" ]]; then
    echo "No snapshots found!"
    exit 1
fi

echo "Restoring snapshot from $SNAPSHOT_DIR"

if [[ -n "${DB_PASSWORD:-}" ]]; then
    echo "Found a database password…"
    export PGPASSWORD="$DB_PASSWORD"
else
    echo "No database password found!"
fi

dropdb -U wagtail hpkdb || true
createdb -U wagtail hpkdb

psql -U wagtail -d hpkdb -f "$SNAPSHOT_DIR/schema.sql"
psql -U wagtail -d hpkdb -f "$SNAPSHOT_DIR/migrations.sql"
psql -U wagtail -d hpkdb -f "$SNAPSHOT_DIR/locales.sql"
uv run python src/manage.py loaddata "$SNAPSHOT_DIR/data.json"
uv run python src/manage.py migrate

echo "Snapshot restored successfully."
