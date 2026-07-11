#!/usr/bin/env bash
# =============================================================================
# zoxide - Smarter cd Command
# DR Custom Terminal
# =============================================================================
# zoxide is a smarter cd command that learns your habits. It keeps track of
# the directories you visit and allows you to jump to them using fuzzy matching.
# Type 'z foo' instead of 'cd /very/long/path/to/foo'.
# =============================================================================

set -euo pipefail

# Get script directory for sourcing core libs
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# Source core libraries
source "${PROJECT_ROOT}/core/colors.sh"
source "${PROJECT_ROOT}/core/ui.sh"
source "${PROJECT_ROOT}/core/validators.sh"
source "${PROJECT_ROOT}/core/installers.sh"
source "${PROJECT_ROOT}/core/shell-config.sh"

# =============================================================================
# Module Metadata
# =============================================================================
MODULE_NAME="zoxide"
MODULE_VERSION="1.0.0"
MODULE_DEPS=("brew")

# =============================================================================
# ASCII Art Header
# =============================================================================
show_ascii_header() {
    echo -e "${CYAN}"
    cat << 'EOF'
                   _     _
  _______  __  ___(_) __| | ___
 |_  / _ \ \ \/ / | |/ _` |/ _ \
  / / (_) | >  <| | (_| |  __/
 /___\___/ /_/\_\_|_\__,_|\___|

 Smarter cd Command
EOF
    echo -e "${NC}"
    echo ""
}

# =============================================================================
# Dependency Check
# =============================================================================
check_dependencies() {
    local has_errors=0

    for dep in "${MODULE_DEPS[@]}"; do
        if ! command_exists "$dep"; then
            print_error "Required dependency not found: $dep"
            has_errors=1
        fi
    done

    return $has_errors
}

# =============================================================================
# Installation Status Check
# =============================================================================
is_installed() {
    command_exists zoxide
}

# =============================================================================
# Get Version
# =============================================================================
get_version() {
    if is_installed; then
        zoxide --version 2>/dev/null | awk '{print $2}'
    else
        echo "Not installed"
    fi
}

# =============================================================================
# Show Current Status
# =============================================================================
show_status() {
    print_divider "Current Status"

    if is_installed; then
        local version
        version="$(get_version)"

        echo -e "  ${ICON_SUCCESS} ${GREEN}Installed${NC}"
        echo -e "  ${ICON_BULLET} Version: ${BOLD}${version}${NC}"
        echo -e "  ${ICON_BULLET} Location: ${DIM}$(which zoxide)${NC}"
        echo ""

        # Check for shell integration
        local zshrc_path
        zshrc_path="$(get_zshrc_path)"
        if grep -q "zoxide init" "$zshrc_path" 2>/dev/null; then
            print_success "Shell integration configured"

            # Show database stats if available
            local db_path="${HOME}/.local/share/zoxide/db.zo"
            if [[ -f "$db_path" ]]; then
                local entry_count
                entry_count=$(zoxide query -l 2>/dev/null | wc -l | tr -d ' ')
                echo -e "  ${ICON_BULLET} Tracked directories: ${BOLD}${entry_count}${NC}"
            fi
        else
            print_warning "Shell integration not configured"
        fi
    else
        echo -e "  ${ICON_ERROR} ${RED}Not installed${NC}"
    fi

    echo ""
}

# =============================================================================
# Install zoxide
# =============================================================================
install() {
    print_divider "Installation"

    # Check for internet connectivity
    print_step 1 2 "Checking internet connection..."
    if ! has_internet; then
        print_error "No internet connection detected"
        return 1
    fi
    print_success "Internet connection available"

    # Install via Homebrew
    print_step 2 2 "Installing zoxide..."
    if ! install_with_brew "zoxide" "zoxide"; then
        print_error "Failed to install zoxide"
        return 1
    fi

    return 0
}

# =============================================================================
# Configure zoxide
# =============================================================================
configure() {
    print_divider "Configuration"

    local zshrc_path
    zshrc_path="$(get_zshrc_path)"

    # Add shell initialization
    print_info "Adding zoxide shell integration..."

    # Check if already configured
    if grep -q "zoxide init" "$zshrc_path" 2>/dev/null; then
        print_info "zoxide already configured in .zshrc"
    else
        add_to_zshrc 'eval "$(zoxide init zsh)"' "zoxide initialization"
        print_success "Added zoxide initialization"
    fi

    # Ask about cd replacement
    echo ""
    print_info "zoxide can replace the 'cd' command entirely"
    echo -e "  ${ICON_BULLET} You'll use 'z' for smart navigation"
    echo -e "  ${ICON_BULLET} Or replace 'cd' to use zoxide automatically"
    echo ""

    if confirm "Replace 'cd' with zoxide? (recommended)" "y"; then
        # Remove existing init if present
        remove_from_zshrc 'eval "$(zoxide init zsh)"' "exact"
        # Add init with cd replacement
        add_to_zshrc 'eval "$(zoxide init zsh --cmd cd)"' "zoxide initialization (replaces cd)"
        print_success "cd now uses zoxide"
        print_info "Regular cd behavior is preserved, plus smart jumping"
    fi

    # Seed the database so "cd <trecho>" ja funciona sem visitar cada pasta.
    local seed_script="${PROJECT_ROOT}/scripts/seed-zoxide.sh"
    if [[ -f "$seed_script" ]]; then
        echo ""
        print_info "Posso pre-popular o banco do zoxide com suas pastas de projetos"
        echo -e "  ${DIM}Registra Projects, Desktop, Documents e Downloads e suas subpastas${NC}"
        echo ""
        if confirm "Pre-popular o historico do zoxide agora?" "y"; then
            if bash "$seed_script"; then
                print_success "Banco do zoxide pre-populado"
            else
                print_warning "Nao foi possivel pre-popular o banco do zoxide"
            fi
        fi
    fi

    # Interactive mode with fzf
    if command_exists fzf; then
        echo ""
        if confirm "Enable interactive mode with fzf? (zi command)"; then
            # This is already included with zoxide init
            print_info "Interactive mode is available via 'zi' command"
            print_success "Use 'zi' for fzf-powered directory selection"
        fi
    else
        echo ""
        print_info "Install fzf for interactive directory selection"
        echo -e "  ${DIM}Run: brew install fzf${NC}"
    fi

    # Show usage
    echo ""
    print_divider "Usage"
    echo ""
    echo -e "  ${BOLD}Basic commands:${NC}"
    echo ""
    echo -e "  ${CYAN}z foo${NC}             Jump to directory containing 'foo'"
    echo -e "  ${CYAN}z foo bar${NC}         Jump to directory matching 'foo' and 'bar'"
    echo -e "  ${CYAN}z ~/projects${NC}      Go to exact path (like regular cd)"
    echo -e "  ${CYAN}z -${NC}               Go to previous directory"
    echo -e "  ${CYAN}z ..${NC}              Go up one directory"
    echo ""
    echo -e "  ${BOLD}Interactive mode (requires fzf):${NC}"
    echo ""
    echo -e "  ${CYAN}zi${NC}                Interactive directory picker"
    echo -e "  ${CYAN}zi foo${NC}            Interactive picker pre-filtered by 'foo'"
    echo ""
    echo -e "  ${BOLD}Query commands:${NC}"
    echo ""
    echo -e "  ${CYAN}zoxide query -l${NC}   List all tracked directories"
    echo -e "  ${CYAN}zoxide add /path${NC}  Manually add a directory"
    echo -e "  ${CYAN}zoxide remove /path${NC} Remove a directory"
    echo ""
    echo -e "  ${BOLD}How it works:${NC}"
    echo -e "  zoxide learns directories you visit frequently."
    echo -e "  Higher frequency + recent visits = higher ranking."
    echo ""

    return 0
}

# =============================================================================
# Uninstall zoxide
# =============================================================================
uninstall() {
    print_divider "Uninstall zoxide"

    print_warning "This will remove zoxide from your system"

    if ! confirm "Are you sure you want to uninstall zoxide?" "n"; then
        print_info "Uninstallation cancelled"
        return 0
    fi

    # Remove via Homebrew
    if uninstall_brew "zoxide"; then
        # Clean up shell configuration
        print_info "Cleaning up shell configuration..."
        remove_from_zshrc "zoxide init" "pattern"

        # Ask about removing database
        local db_path="${HOME}/.local/share/zoxide"
        if [[ -d "$db_path" ]]; then
            if confirm "Remove zoxide database (tracked directories)?" "n"; then
                rm -rf "$db_path"
                print_success "Database removed"
            else
                print_info "Database kept at: $db_path"
            fi
        fi

        print_success "zoxide uninstalled"
    else
        print_error "Failed to uninstall zoxide"
        return 1
    fi

    return 0
}

# =============================================================================
# Show Help
# =============================================================================
show_help() {
    echo ""
    echo -e "${BOLD}zoxide Installer${NC}"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  install     Install zoxide (default)"
    echo "  status      Show current installation status"
    echo "  uninstall   Remove zoxide completely"
    echo "  help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0              # Install zoxide"
    echo "  $0 status       # Check installation status"
    echo ""
}

# =============================================================================
# Main Entry Point
# =============================================================================
main() {
    local command="${1:-install}"

    # Show header
    show_ascii_header
    print_header "$MODULE_NAME Installer"

    case "$command" in
        install)
            # Check dependencies first
            if ! check_dependencies; then
                print_error "Missing dependencies. Please install Homebrew first."
                exit 1
            fi

            # Check if already installed
            if is_installed; then
                show_status
                print_warning "$MODULE_NAME is already installed"

                if confirm "Reconfigure $MODULE_NAME?"; then
                    configure
                fi
                exit 0
            fi

            install && configure
            ;;
        status)
            show_status
            ;;
        uninstall)
            if ! is_installed; then
                print_info "zoxide is not installed"
                exit 0
            fi
            uninstall
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac

    local exit_code=$?

    if [[ $exit_code -eq 0 && "$command" != "help" && "$command" != "status" ]]; then
        echo ""
        print_success "$MODULE_NAME operation complete!"
        print_info "Restart your terminal or run 'source ~/.zshrc' to apply changes"
        echo ""
    fi

    exit $exit_code
}

# Run main if executed directly
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"
