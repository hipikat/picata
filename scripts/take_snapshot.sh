#!/bin/bash
set -e

TIMESTAMP=$(date +"%Y-%m-%d-%H%M%S")
SNAPSHOT_DIR="snapshots/$TIMESTAMP"
mkdir -p "$SNAPSHOT_DIR"

echo "Creating snapshot at $SNAPSHOT_DIR"

# Dump schema
pg_dump -U postgres -h localhost --schema-only your_db > "$SNAPSHOT_DIR/schema.sql"

# Dump migrations and essential tables
pg_dump -U postgres -h localhost --data-only --table=django_migrations your_db > "$SNAPSHOT_DIR/migrations.sql"

# Dump app data
python manage.py dumpdata --exclude auth --exclude sessions --indent 2 > "$SNAPSHOT_DIR/data.json"

echo "Snapshot created successfully."
