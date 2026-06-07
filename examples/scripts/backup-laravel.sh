#!/bin/bash
# Laravel Backup Script
# Part of OpenOps Toolkit

set -e

# Configuration
APP_NAME="${1:-laravel-app}"
BACKUP_DIR="/var/backups/${APP_NAME}"
RETENTION_DAYS=7
DATE=$(date +%Y%m%d_%H%M%S)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Logging
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1"
    exit 1
}

# Create backup directory
create_backup_dir() {
    mkdir -p "${BACKUP_DIR}"
    log "Backup directory created: ${BACKUP_DIR}"
}

# Backup application files
backup_files() {
    log "Backing up application files..."
    
    local app_dir="/var/www/${APP_NAME}"
    local file_backup="${BACKUP_DIR}/${APP_NAME}_files_${DATE}.tar.gz"
    
    if [ -d "$app_dir" ]; then
        tar -czf "$file_backup" -C /var/www "${APP_NAME}" \
            --exclude='storage/logs/*' \
            --exclude='storage/framework/cache/*' \
            --exclude='storage/framework/sessions/*' \
            --exclude='storage/framework/views/*' \
            --exclude='vendor' \
            --exclude='node_modules'
        
        log "Files backup created: ${file_backup}"
    else
        error "Application directory not found: ${app_dir}"
    fi
}

# Backup database
backup_database() {
    log "Backing up database..."
    
    local db_backup="${BACKUP_DIR}/${APP_NAME}_db_${DATE}.sql.gz"
    local env_file="/var/www/${APP_NAME}/.env"
    
    if [ -f "$env_file" ]; then
        # Extract database credentials from .env
        local db_name=$(grep DB_DATABASE "$env_file" | cut -d '=' -f2 | tr -d '"' | tr -d "'")
        local db_user=$(grep DB_USERNAME "$env_file" | cut -d '=' -f2 | tr -d '"' | tr -d "'")
        local db_pass=$(grep DB_PASSWORD "$env_file" | cut -d '=' -f2 | tr -d '"' | tr -d "'")
        
        if [ -n "$db_name" ] && [ -n "$db_user" ]; then
            mysqldump -u "$db_user" -p"$db_pass" "$db_name" | gzip > "$db_backup"
            log "Database backup created: ${db_backup}"
        else
            warn "Database credentials not found in .env"
        fi
    else
        warn ".env file not found"
    fi
}

# Backup storage
backup_storage() {
    log "Backing up storage..."
    
    local storage_backup="${BACKUP_DIR}/${APP_NAME}_storage_${DATE}.tar.gz"
    local storage_dir="/var/www/${APP_NAME}/storage/app"
    
    if [ -d "$storage_dir" ]; then
        tar -czf "$storage_backup" -C "/var/www/${APP_NAME}/storage" "app"
        log "Storage backup created: ${storage_backup}"
    else
        warn "Storage directory not found"
    fi
}

# Clean old backups
cleanup_old_backups() {
    log "Cleaning up old backups..."
    
    find "$BACKUP_DIR" -name "*.tar.gz" -mtime +$RETENTION_DAYS -delete
    find "$BACKUP_DIR" -name "*.sql.gz" -mtime +$RETENTION_DAYS -delete
    
    log "Old backups cleaned up (retention: ${RETENTION_DAYS} days)"
}

# Verify backups
verify_backups() {
    log "Verifying backups..."
    
    local file_count=$(find "$BACKUP_DIR" -name "*_${DATE}.*" | wc -l)
    
    if [ $file_count -gt 0 ]; then
        log "Backup verification successful: ${file_count} files created"
    else
        error "Backup verification failed: no files created"
    fi
}

# Main function
main() {
    log "Starting backup for ${APP_NAME}"
    
    create_backup_dir
    backup_files
    backup_database
    backup_storage
    cleanup_old_backups
    verify_backups
    
    log "Backup completed successfully"
    log "Backup location: ${BACKUP_DIR}"
}

# Run main function
main