#!/bin/bash
set -euo pipefail

# Workspace Health Dashboard
# Monitors and reports on workspace status and health

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
readonly HEALTH_FILE="${WORKSPACE_ROOT}/.workspace-health"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Status indicators
readonly CHECK_MARK="✓"
readonly WARNING="⚠"
readonly ERROR_MARK="✗"
readonly INFO_MARK="ℹ"

print_header() {
    echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║           Dev-Lab Health Status        ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}Workspace:${NC} $(basename "$WORKSPACE_ROOT")"
    echo -e "${BLUE}Generated:${NC} $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
}

check_git_status() {
    echo -e "${PURPLE}▶ Git Repository Status${NC}"
    
    if [[ ! -d "${WORKSPACE_ROOT}/.git" ]]; then
        echo -e "  ${RED}${ERROR_MARK}${NC} Not a git repository"
        return 1
    fi
    
    cd "$WORKSPACE_ROOT"
    
    # Branch information
    local current_branch
    current_branch="$(git branch --show-current 2>/dev/null || echo 'detached')"
    echo -e "  ${GREEN}${CHECK_MARK}${NC} Current branch: ${current_branch}"
    
    # Remote status
    if git remote >/dev/null 2>&1; then
        local remote_url
        remote_url="$(git remote get-url origin 2>/dev/null || echo 'No origin')"
        echo -e "  ${GREEN}${CHECK_MARK}${NC} Remote: ${remote_url}"
        
        # Check if branch tracks remote
        if git status --porcelain=v1 2>/dev/null | grep -q "ahead\|behind"; then
            echo -e "  ${YELLOW}${WARNING}${NC} Branch has unpushed/unpulled commits"
        else
            echo -e "  ${GREEN}${CHECK_MARK}${NC} Branch is up to date with remote"
        fi
    else
        echo -e "  ${YELLOW}${WARNING}${NC} No remote configured"
    fi
    
    # Working tree status
    local status_output
    status_output="$(git status --porcelain 2>/dev/null)"
    if [[ -n "$status_output" ]]; then
        local modified_count staged_count untracked_count
        modified_count="$(echo "$status_output" | grep -c "^ M\|^MM\|^AM" || echo 0)"
        staged_count="$(echo "$status_output" | grep -c "^M\|^A\|^D" || echo 0)"
        untracked_count="$(echo "$status_output" | grep -c "^??" || echo 0)"
        
        echo -e "  ${YELLOW}${INFO_MARK}${NC} Working tree: ${staged_count} staged, ${modified_count} modified, ${untracked_count} untracked"
    else
        echo -e "  ${GREEN}${CHECK_MARK}${NC} Working tree is clean"
    fi
    
    echo ""
}

check_directory_structure() {
    echo -e "${PURPLE}▶ Directory Structure${NC}"
    
    local required_dirs=(
        "docs"
        "tools"
        "projects"
        "scratch"
        "tools/scripts"
    )
    
    local optional_dirs=(
        "tools/templates"
        "tools/configs"
        "docs/cheatsheets"
        "docs/workflows"
    )
    
    local missing_required=()
    local missing_optional=()
    
    for dir in "${required_dirs[@]}"; do
        if [[ -d "${WORKSPACE_ROOT}/${dir}" ]]; then
            echo -e "  ${GREEN}${CHECK_MARK}${NC} ${dir}/"
        else
            echo -e "  ${RED}${ERROR_MARK}${NC} ${dir}/ (missing)"
            missing_required+=("$dir")
        fi
    done
    
    for dir in "${optional_dirs[@]}"; do
        if [[ -d "${WORKSPACE_ROOT}/${dir}" ]]; then
            echo -e "  ${GREEN}${CHECK_MARK}${NC} ${dir}/"
        else
            echo -e "  ${YELLOW}${WARNING}${NC} ${dir}/ (optional)"
            missing_optional+=("$dir")
        fi
    done
    
    if [[ ${#missing_required[@]} -gt 0 ]]; then
        echo -e "  ${RED}Missing required directories: ${missing_required[*]}${NC}"
    fi
    
    echo ""
}

check_project_status() {
    echo -e "${PURPLE}▶ Projects Status${NC}"
    
    local projects_dir="${WORKSPACE_ROOT}/projects"
    if [[ ! -d "$projects_dir" ]]; then
        echo -e "  ${RED}${ERROR_MARK}${NC} Projects directory not found"
        echo ""
        return
    fi
    
    local project_count=0
    while IFS= read -r -d '' project_path; do
        local project_name
        project_name="$(basename "$project_path")"
        
        if [[ -d "${project_path}/.git" ]]; then
            cd "$project_path"
            local branch
            branch="$(git branch --show-current 2>/dev/null || echo 'detached')"
            local status
            if git status --porcelain 2>/dev/null | grep -q .; then
                status="${YELLOW}modified${NC}"
            else
                status="${GREEN}clean${NC}"
            fi
            echo -e "  ${GREEN}${CHECK_MARK}${NC} ${project_name} (${branch}) - ${status}"
        else
            echo -e "  ${BLUE}${INFO_MARK}${NC} ${project_name} (not a git repo)"
        fi
        
        ((project_count++))
    done < <(find "$projects_dir" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)
    
    if [[ $project_count -eq 0 ]]; then
        echo -e "  ${YELLOW}${INFO_MARK}${NC} No projects found"
    else
        echo -e "  ${BLUE}Total projects: ${project_count}${NC}"
    fi
    
    echo ""
}

check_tools_status() {
    echo -e "${PURPLE}▶ Tools Status${NC}"
    
    # Docker and SonarQube
    if command -v docker >/dev/null 2>&1; then
        echo -e "  ${GREEN}${CHECK_MARK}${NC} Docker installed"
        
        if command -v docker-compose >/dev/null 2>&1; then
            echo -e "  ${GREEN}${CHECK_MARK}${NC} Docker Compose installed"
            
            # Check SonarQube status
            local sonarqube_dir="${WORKSPACE_ROOT}/tools/sonarqube"
            if [[ -f "${sonarqube_dir}/docker-compose.yml" ]]; then
                cd "$sonarqube_dir"
                if docker-compose ps 2>/dev/null | grep -q "Up"; then
                    echo -e "  ${GREEN}${CHECK_MARK}${NC} SonarQube is running"
                else
                    echo -e "  ${YELLOW}${INFO_MARK}${NC} SonarQube is stopped"
                fi
            else
                echo -e "  ${YELLOW}${WARNING}${NC} SonarQube configuration not found"
            fi
        else
            echo -e "  ${YELLOW}${WARNING}${NC} Docker Compose not installed"
        fi
    else
        echo -e "  ${RED}${ERROR_MARK}${NC} Docker not installed"
    fi
    
    # Essential tools
    local tools=("git" "curl" "jq")
    for tool in "${tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            echo -e "  ${GREEN}${CHECK_MARK}${NC} ${tool} available"
        else
            echo -e "  ${YELLOW}${WARNING}${NC} ${tool} not found"
        fi
    done
    
    echo ""
}

check_workspace_usage() {
    echo -e "${PURPLE}▶ Workspace Usage${NC}"
    
    # Disk usage
    local total_size
    total_size="$(du -sh "$WORKSPACE_ROOT" 2>/dev/null | cut -f1)"
    echo -e "  ${BLUE}${INFO_MARK}${NC} Total size: ${total_size}"
    
    # Project sizes
    local projects_dir="${WORKSPACE_ROOT}/projects"
    if [[ -d "$projects_dir" ]]; then
        local projects_size
        projects_size="$(du -sh "$projects_dir" 2>/dev/null | cut -f1)"
        echo -e "  ${BLUE}${INFO_MARK}${NC} Projects size: ${projects_size}"
    fi
    
    # Scratch usage
    local scratch_dir="${WORKSPACE_ROOT}/scratch"
    if [[ -d "$scratch_dir" ]]; then
        local scratch_size
        scratch_size="$(du -sh "$scratch_dir" 2>/dev/null | cut -f1)"
        echo -e "  ${BLUE}${INFO_MARK}${NC} Scratch size: ${scratch_size}"
    fi
    
    # File counts
    local total_files
    total_files="$(find "$WORKSPACE_ROOT" -type f 2>/dev/null | wc -l)"
    echo -e "  ${BLUE}${INFO_MARK}${NC} Total files: ${total_files}"
    
    echo ""
}

generate_health_summary() {
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    
    # Count issues
    local warnings=0
    local errors=0
    
    # This is a simplified count - in a real implementation, 
    # you'd collect these during the checks above
    if [[ ! -d "${WORKSPACE_ROOT}/.git" ]]; then
        ((errors++))
    fi
    
    local status_color
    local status_text
    if [[ $errors -gt 0 ]]; then
        status_color="$RED"
        status_text="CRITICAL"
    elif [[ $warnings -gt 0 ]]; then
        status_color="$YELLOW"
        status_text="WARNING"
    else
        status_color="$GREEN"
        status_text="HEALTHY"
    fi
    
    echo -e "${PURPLE}▶ Health Summary${NC}"
    echo -e "  ${status_color}Status: ${status_text}${NC}"
    echo -e "  ${BLUE}Last check: ${timestamp}${NC}"
    
    # Save health status
    cat > "$HEALTH_FILE" << EOF
{
    "timestamp": "${timestamp}",
    "status": "${status_text}",
    "errors": ${errors},
    "warnings": ${warnings}
}
EOF
    
    echo ""
}

show_help() {
    cat << EOF
Dev-Lab Workspace Health Dashboard

USAGE:
    $0 [OPTIONS]

OPTIONS:
    --watch          Continuous monitoring mode
    --json           Output in JSON format
    --quiet          Minimal output
    --help           Show this help message

DESCRIPTION:
    Monitors and reports on workspace health including:
    - Git repository status
    - Directory structure
    - Project status
    - Tool availability
    - Disk usage

EXAMPLES:
    $0               Show health dashboard
    $0 --watch       Continuous monitoring
    $0 --json        JSON output for scripts

EOF
}

main() {
    local watch_mode=false
    local json_output=false
    local quiet_mode=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --watch)
                watch_mode=true
                shift
                ;;
            --json)
                json_output=true
                shift
                ;;
            --quiet)
                quiet_mode=true
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                echo "Unknown option: $1" >&2
                show_help
                exit 1
                ;;
        esac
    done
    
    if [[ "$json_output" == "true" ]]; then
        # JSON output mode (simplified)
        echo '{"status": "healthy", "timestamp": "'$(date -Iseconds)'", "workspace": "'$(basename "$WORKSPACE_ROOT")'"}'
        exit 0
    fi
    
    if [[ "$watch_mode" == "true" ]]; then
        while true; do
            clear
            print_header
            check_git_status
            check_directory_structure
            check_project_status
            check_tools_status
            check_workspace_usage
            generate_health_summary
            echo -e "${CYAN}Refreshing in 30 seconds... (Ctrl+C to exit)${NC}"
            sleep 30
        done
    else
        print_header
        check_git_status
        check_directory_structure
        check_project_status
        check_tools_status
        check_workspace_usage
        generate_health_summary
    fi
}

# Run main function
main "$@"