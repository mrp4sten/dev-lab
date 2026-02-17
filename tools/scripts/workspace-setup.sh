#!/bin/bash
set -euo pipefail

# Workspace Setup Script
# Initializes and configures the dev-lab environment

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
readonly LOG_FILE="${WORKSPACE_ROOT}/.setup.log"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    
    case "$level" in
        "INFO")  echo -e "${GREEN}[INFO]${NC} $message" | tee -a "$LOG_FILE" ;;
        "WARN")  echo -e "${YELLOW}[WARN]${NC} $message" | tee -a "$LOG_FILE" ;;
        "ERROR") echo -e "${RED}[ERROR]${NC} $message" | tee -a "$LOG_FILE" ;;
        "DEBUG") echo -e "${BLUE}[DEBUG]${NC} $message" | tee -a "$LOG_FILE" ;;
    esac
}

check_requirements() {
    log "INFO" "Checking system requirements..."
    
    local missing_tools=()
    
    # Check essential tools
    command -v git >/dev/null 2>&1 || missing_tools+=("git")
    command -v docker >/dev/null 2>&1 || missing_tools+=("docker")
    command -v docker-compose >/dev/null 2>&1 || missing_tools+=("docker-compose")
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log "ERROR" "Missing required tools: ${missing_tools[*]}"
        log "INFO" "Please install missing tools and run setup again"
        exit 1
    fi
    
    log "INFO" "All required tools found"
}

setup_git_hooks() {
    log "INFO" "Setting up git hooks..."
    
    local hooks_dir="${WORKSPACE_ROOT}/.git/hooks"
    
    # Pre-commit hook for conventional commits
    cat > "${hooks_dir}/commit-msg" << 'EOF'
#!/bin/bash
# Check commit message format
commit_regex='^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .{1,50}'

if ! grep -qE "$commit_regex" "$1"; then
    echo "Invalid commit message format!"
    echo "Format: type(scope): description"
    echo "Types: feat, fix, docs, style, refactor, test, chore"
    echo "Example: feat(api): add user authentication"
    exit 1
fi
EOF
    
    chmod +x "${hooks_dir}/commit-msg"
    log "INFO" "Git hooks configured"
}

setup_directory_structure() {
    log "INFO" "Ensuring directory structure..."
    
    local dirs=(
        "projects"
        "scratch/playground"
        "scratch/pocs" 
        "scratch/temp"
        "docs/cheatsheets"
        "docs/workflows"
        "tools/scripts"
        "tools/templates"
        "tools/configs"
    )
    
    for dir in "${dirs[@]}"; do
        mkdir -p "${WORKSPACE_ROOT}/${dir}"
        log "DEBUG" "Created/verified: $dir"
    done
}

setup_environment_files() {
    log "INFO" "Setting up environment files..."
    
    # Create workspace config if it doesn't exist
    local config_file="${WORKSPACE_ROOT}/.workspace-config"
    if [[ ! -f "$config_file" ]]; then
        cat > "$config_file" << 'EOF'
# Dev-Lab Workspace Configuration
WORKSPACE_NAME="dev-lab"
DEFAULT_EDITOR="code"
DEFAULT_SHELL="bash"
SONARQUBE_ENABLED="true"
AUTO_BACKUP="false"
BACKUP_INTERVAL="7d"
EOF
        log "INFO" "Created workspace configuration"
    fi
    
    # Ensure proper .gitignore
    local gitignore="${WORKSPACE_ROOT}/.gitignore"
    if ! grep -q "^\.workspace-config$" "$gitignore" 2>/dev/null; then
        echo ".workspace-config" >> "$gitignore"
        echo ".setup.log" >> "$gitignore"
        echo ".workspace-health" >> "$gitignore"
        log "INFO" "Updated .gitignore with workspace files"
    fi
}

validate_setup() {
    log "INFO" "Validating setup..."
    
    local validation_passed=true
    
    # Check directory structure
    local required_dirs=("projects" "scratch" "docs" "tools")
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "${WORKSPACE_ROOT}/${dir}" ]]; then
            log "ERROR" "Missing directory: $dir"
            validation_passed=false
        fi
    done
    
    # Check git repository
    if [[ ! -d "${WORKSPACE_ROOT}/.git" ]]; then
        log "ERROR" "Not a git repository"
        validation_passed=false
    fi
    
    # Check essential files
    local required_files=("README.md" "AGENTS.md")
    for file in "${required_files[@]}"; do
        if [[ ! -f "${WORKSPACE_ROOT}/${file}" ]]; then
            log "ERROR" "Missing file: $file"
            validation_passed=false
        fi
    done
    
    if [[ "$validation_passed" == "true" ]]; then
        log "INFO" "Validation passed"
        return 0
    else
        log "ERROR" "Validation failed"
        return 1
    fi
}

show_help() {
    cat << EOF
Dev-Lab Workspace Setup

USAGE:
    $0 [OPTIONS]

OPTIONS:
    --check-only      Only check requirements and validate
    --force           Force setup even if already configured
    --help           Show this help message

DESCRIPTION:
    Initializes and configures the dev-lab workspace environment.
    Sets up directory structure, git hooks, and essential configuration.

EXAMPLES:
    $0                Setup the workspace
    $0 --check-only   Validate current setup
    $0 --force        Force reconfiguration

EOF
}

main() {
    local check_only=false
    local force_setup=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --check-only)
                check_only=true
                shift
                ;;
            --force)
                force_setup=true
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                log "ERROR" "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    log "INFO" "Starting workspace setup..."
    log "INFO" "Workspace root: $WORKSPACE_ROOT"
    
    # Always check requirements
    check_requirements
    
    if [[ "$check_only" == "true" ]]; then
        validate_setup
        exit $?
    fi
    
    # Check if already setup (unless forced)
    if [[ -f "${WORKSPACE_ROOT}/.workspace-config" && "$force_setup" == "false" ]]; then
        log "INFO" "Workspace already configured (use --force to reconfigure)"
        validate_setup
        exit $?
    fi
    
    # Run setup steps
    setup_directory_structure
    setup_git_hooks
    setup_environment_files
    
    # Validate the setup
    if validate_setup; then
        log "INFO" "Workspace setup completed successfully!"
        log "INFO" "Run './tools/scripts/workspace-health.sh' to check workspace status"
    else
        log "ERROR" "Setup completed with errors"
        exit 1
    fi
}

# Run main function
main "$@"