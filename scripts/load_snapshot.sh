#!/bin/bash
set -e

SNAPSHOT_DIR=$(ls -td snapshots/* | head -1)

if [ -z "$SNAPSHOT_DIR" ]; then
    echo "No snapshots found!"
    exit 1
fi

echo "Restoring snapshot from $SNAPSHOT_DIR"

# Drop and recreate database
dropdb -U postgres your_db || true
createdb -U postgres your_db

# Restore schema and essential tables
psql -U postgres -d your_db -f "$SNAPSHOT_DIR/schema.sql"
psql -U postgres -d your_db -f "$SNAPSHOT_DIR/migrations.sql"

# Restore app data
python manage.py loaddata "$SNAPSHOT_DIR/data.json"

# Apply migrations
python manage.py migrate

echo "Snapshot restored successfully."
