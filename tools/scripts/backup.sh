#!/bin/bash
set -euo pipefail

# Workspace Backup Script
# Creates backups of projects and scratch directories

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
readonly BACKUP_DIR="${HOME}/dev-lab-backups"
readonly TIMESTAMP="$(date '+%Y%m%d-%H%M%S')"

# Colors
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

log() {
    local level="$1"
    shift
    local message="$*"
    
    case "$level" in
        "INFO")  echo -e "${GREEN}[INFO]${NC} $message" ;;
        "WARN")  echo -e "${YELLOW}[WARN]${NC} $message" ;;
        "ERROR") echo -e "${RED}[ERROR]${NC} $message" ;;
        "DEBUG") echo -e "${BLUE}[DEBUG]${NC} $message" ;;
    esac
}

create_backup() {
    local backup_name="dev-lab-backup-${TIMESTAMP}"
    local backup_path="${BACKUP_DIR}/${backup_name}"
    
    log "INFO" "Creating backup: $backup_name"
    
    # Create backup directory
    mkdir -p "$backup_path"
    
    # Backup projects directory
    if [[ -d "${WORKSPACE_ROOT}/projects" ]]; then
        log "INFO" "Backing up projects..."
        cp -r "${WORKSPACE_ROOT}/projects" "${backup_path}/"
    fi
    
    # Backup scratch directory  
    if [[ -d "${WORKSPACE_ROOT}/scratch" ]]; then
        log "INFO" "Backing up scratch..."
        cp -r "${WORKSPACE_ROOT}/scratch" "${backup_path}/"
    fi
    
    # Backup workspace config
    if [[ -f "${WORKSPACE_ROOT}/.workspace-config" ]]; then
        cp "${WORKSPACE_ROOT}/.workspace-config" "${backup_path}/"
    fi
    
    # Create backup manifest
    cat > "${backup_path}/backup-manifest.txt" << EOF
Backup created: $(date)
Workspace: ${WORKSPACE_ROOT}
Backup size: $(du -sh "$backup_path" | cut -f1)
Contents:
$(ls -la "$backup_path")
EOF
    
    log "INFO" "Backup completed: $backup_path"
    log "INFO" "Backup size: $(du -sh "$backup_path" | cut -f1)"
}

cleanup_old_backups() {
    local keep_days="${1:-7}"
    
    if [[ ! -d "$BACKUP_DIR" ]]; then
        return
    fi
    
    log "INFO" "Cleaning up backups older than $keep_days days..."
    
    find "$BACKUP_DIR" -name "dev-lab-backup-*" -type d -mtime +"$keep_days" -exec rm -rf {} \; 2>/dev/null || true
    
    log "INFO" "Cleanup completed"
}

list_backups() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        log "WARN" "No backup directory found"
        return
    fi
    
    echo "Available backups:"
    find "$BACKUP_DIR" -name "dev-lab-backup-*" -type d -printf "%f %TY-%Tm-%Td %TH:%TM\n" 2>/dev/null | sort -r || log "INFO" "No backups found"
}

restore_backup() {
    local backup_name="$1"
    local backup_path="${BACKUP_DIR}/${backup_name}"
    
    if [[ ! -d "$backup_path" ]]; then
        log "ERROR" "Backup not found: $backup_name"
        exit 1
    fi
    
    log "WARN" "This will overwrite current projects and scratch directories!"
    read -p "Are you sure? (yes/no): " -r
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        log "INFO" "Restore cancelled"
        exit 0
    fi
    
    log "INFO" "Restoring from: $backup_name"
    
    # Backup current state first
    if [[ -d "${WORKSPACE_ROOT}/projects" ]] || [[ -d "${WORKSPACE_ROOT}/scratch" ]]; then
        local current_backup="current-backup-${TIMESTAMP}"
        log "INFO" "Creating backup of current state: $current_backup"
        create_backup >/dev/null 2>&1
    fi
    
    # Restore projects
    if [[ -d "${backup_path}/projects" ]]; then
        rm -rf "${WORKSPACE_ROOT}/projects" 2>/dev/null || true
        cp -r "${backup_path}/projects" "${WORKSPACE_ROOT}/"
        log "INFO" "Restored projects directory"
    fi
    
    # Restore scratch
    if [[ -d "${backup_path}/scratch" ]]; then
        rm -rf "${WORKSPACE_ROOT}/scratch" 2>/dev/null || true
        cp -r "${backup_path}/scratch" "${WORKSPACE_ROOT}/"
        log "INFO" "Restored scratch directory"
    fi
    
    # Restore config
    if [[ -f "${backup_path}/.workspace-config" ]]; then
        cp "${backup_path}/.workspace-config" "${WORKSPACE_ROOT}/"
        log "INFO" "Restored workspace config"
    fi
    
    log "INFO" "Restore completed successfully"
}

show_help() {
    cat << EOF
Dev-Lab Workspace Backup Tool

USAGE:
    $0 [COMMAND] [OPTIONS]

COMMANDS:
    create              Create a new backup (default)
    list                List available backups
    restore <name>      Restore from backup
    cleanup [days]      Remove backups older than N days (default: 7)

OPTIONS:
    --help              Show this help message

DESCRIPTION:
    Creates backups of the projects/ and scratch/ directories.
    Backups are stored in: ${BACKUP_DIR}

EXAMPLES:
    $0                                  Create backup
    $0 create                          Create backup
    $0 list                            List backups
    $0 restore dev-lab-backup-20240101 Restore specific backup
    $0 cleanup 14                      Remove backups older than 14 days

EOF
}

main() {
    local command="create"
    
    if [[ $# -gt 0 ]]; then
        case "$1" in
            create)
                command="create"
                shift
                ;;
            list)
                command="list"
                shift
                ;;
            restore)
                command="restore"
                shift
                if [[ $# -eq 0 ]]; then
                    log "ERROR" "Backup name required for restore"
                    exit 1
                fi
                ;;
            cleanup)
                command="cleanup"
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                log "ERROR" "Unknown command: $1"
                show_help
                exit 1
                ;;
        esac
    fi
    
    case "$command" in
        create)
            create_backup
            ;;
        list)
            list_backups
            ;;
        restore)
            restore_backup "$1"
            ;;
        cleanup)
            cleanup_old_backups "${1:-7}"
            ;;
    esac
}

main "$@"