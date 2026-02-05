#!/bin/bash
# Backup PostgreSQL database to a file
# Usage: ./backup-db.sh [output_dir]

set -e

OUTPUT_DIR="${1:-./backups}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${OUTPUT_DIR}/tayzhang_backup_${TIMESTAMP}.sql"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Get database credentials from environment or use defaults
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-tayzhang}"
DB_USER="${DB_USER:-postgres}"

echo "Starting backup of database: $DB_NAME"

# Run pg_dump inside the postgres container
docker compose exec -T postgres pg_dump -U "$DB_USER" "$DB_NAME" > "$BACKUP_FILE"

# Compress the backup
gzip "$BACKUP_FILE"

echo "Backup completed: ${BACKUP_FILE}.gz"

# Optional: Upload to OSS (uncomment and configure as needed)
# ossutil cp "${BACKUP_FILE}.gz" oss://your-bucket/backups/

# Clean up old backups (keep last 7 days)
find "$OUTPUT_DIR" -name "tayzhang_backup_*.sql.gz" -mtime +7 -delete

echo "Backup process finished"
