#!/bin/bash
#
# sonarqube-manager.sh - SonarQube Container Management Script
#
# Description: Management script for SonarQube Docker container in dev-lab
# Author: Mauricio Pasten (@mrp4sten)
# Version: 1.0.0
# Created: $(date 2025-10-01)
# License: MIT
#
# Usage: ./sonarqube-manager.sh [start|stop|status|logs|restart|cleanup]
#
# Environment Variables:
#   - SONARQUBE_PORT: Default 9000
#   - SONARQUBE_VERSION: Default 'community'
#

set -euo pipefail

# Configuration
readonly SCRIPT_NAME="$(basename "$0")"
readonly SONARQUBE_PORT="${SONARQUBE_PORT:-9000}"
readonly SONARQUBE_VERSION="${SONARQUBE_VERSION:-community}"
readonly COMPOSE_FILE="../docker-compose.yml"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Validation functions
check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed or not in PATH"
        exit 3
    fi
}

check_docker_compose() {
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose is not installed or not in PATH"
        exit 3
    fi
}

validate_environment() {
    check_docker
    check_docker_compose
    
    if [[ ! -f "$COMPOSE_FILE" ]]; then
        log_error "Docker compose file not found: $COMPOSE_FILE"
        exit 1
    fi
}

# Main functions
start_sonarqube() {
    log_info "Starting SonarQube with Docker Compose..."
    docker-compose -f "$COMPOSE_FILE" up -d
    
    log_info "Waiting for SonarQube to start (this may take 2-3 minutes)..."
    sleep 30
    
    log_success "SonarQube started successfully!"
    log_info "Access at: http://localhost:${SONARQUBE_PORT}"
    log_info "Default credentials: admin/admin"
}

stop_sonarqube() {
    log_info "Stopping SonarQube..."
    docker-compose -f "$COMPOSE_FILE" down
    log_success "SonarQube stopped"
}

status_sonarqube() {
    log_info "SonarQube Status:"
    if docker-compose -f "$COMPOSE_FILE" ps | grep -q "Up"; then
        log_success "RUNNING - http://localhost:${SONARQUBE_PORT}"
        docker-compose -f "$COMPOSE_FILE" ps
    else
        log_warning "STOPPED"
    fi
}

show_logs() {
    log_info "Showing SonarQube logs (Ctrl+C to exit)..."
    docker-compose -f "$COMPOSE_FILE" logs -f
}

restart_sonarqube() {
    log_info "Restarting SonarQube..."
    docker-compose -f "$COMPOSE_FILE" restart
    log_success "SonarQube restarted"
}

cleanup_sonarqube() {
    log_warning "This will remove ALL SonarQube data including projects and analysis history!"
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Cleaning up SonarQube (including volumes)..."
        docker-compose -f "$COMPOSE_FILE" down -v
        log_success "All SonarQube data removed"
    else
        log_info "Cleanup cancelled"
    fi
}

show_usage() {
    cat << EOF
Usage: $SCRIPT_NAME [COMMAND]

SonarQube Container Management Script

Commands:
    start       Start SonarQube container
    stop        Stop SonarQube container  
    status      Check container status
    logs        View container logs (follow mode)
    restart     Restart SonarQube container
    cleanup     Remove container and all data (DESTRUCTIVE)

Examples:
    $SCRIPT_NAME start    # Start SonarQube
    $SCRIPT_NAME status   # Check status
    $SCRIPT_NAME logs     # View logs in real-time

Environment Variables:
    SONARQUBE_PORT      SonarQube port (default: 9000)
    SONARQUBE_VERSION   SonarQube version (default: community)

Exit Codes:
    0 - Success
    1 - General error
    2 - Invalid arguments
    3 - Docker not available
EOF
}

# Main execution
main() {
    validate_environment
    
    local command="${1:-}"
    
    case "$command" in
        start)
            start_sonarqube
            ;;
        stop)
            stop_sonarqube
            ;;
        status)
            status_sonarqube
            ;;
        logs)
            show_logs
            ;;
        restart)
            restart_sonarqube
            ;;
        cleanup)
            cleanup_sonarqube
            ;;
        -h|--help|help)
            show_usage
            ;;
        "")
            log_error "No command specified"
            show_usage
            exit 2
            ;;
        *)
            log_error "Invalid command: $command"
            show_usage
            exit 2
            ;;
    esac
}

main "$@"