#!/usr/bin/env bash
# =============================================================================
# lazygit - Simple Terminal UI for Git Commands
# DR Custom Terminal
# =============================================================================
# lazygit is a simple terminal UI for git commands. It provides an intuitive
# way to stage, commit, push, pull, and manage branches without memorizing
# complex git commands.
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
MODULE_NAME="lazygit"
MODULE_VERSION="1.0.0"
MODULE_DEPS=("brew")

# =============================================================================
# ASCII Art Header
# =============================================================================
show_ascii_header() {
    echo -e "${CYAN}"
    cat << 'EOF'
  _                           _ _
 | | __ _ _____   _  __ _  (_) |_
 | |/ _` |_  / | | |/ _` | | | __|
 | | (_| |/ /| |_| | (_| | | | |_
 |_|\__,_/___|\__, |\__, | |_|\__|
              |___/ |___/

 Simple Terminal UI for Git
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

    # Check for git
    if ! command_exists git; then
        print_error "git is required but not found"
        has_errors=1
    fi

    return $has_errors
}

# =============================================================================
# Installation Status Check
# =============================================================================
is_installed() {
    command_exists lazygit
}

# =============================================================================
# Get Version
# =============================================================================
get_version() {
    if is_installed; then
        lazygit --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1
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
        echo -e "  ${ICON_BULLET} Location: ${DIM}$(which lazygit)${NC}"
        echo ""

        # Check for config
        local config_dir="${HOME}/.config/lazygit"
        if [[ -f "${config_dir}/config.yml" ]]; then
            print_success "Configuration file exists"
        fi

        # Check for alias
        local zshrc_path
        zshrc_path="$(get_zshrc_path)"
        if grep -q "alias lzg=.*lazygit" "$zshrc_path" 2>/dev/null; then
            print_success "lzg alias configured"
        fi
    else
        echo -e "  ${ICON_ERROR} ${RED}Not installed${NC}"
    fi

    echo ""
}

# =============================================================================
# Install lazygit
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
    print_step 2 2 "Installing lazygit..."
    if ! install_with_brew "lazygit" "lazygit"; then
        print_error "Failed to install lazygit"
        return 1
    fi

    return 0
}

# =============================================================================
# Configure lazygit
# =============================================================================
configure() {
    print_divider "Configuration"

    # Create config directory
    local config_dir="${HOME}/.config/lazygit"
    local config_file="${config_dir}/config.yml"

    mkdir -p "$config_dir"

    # Add lzg alias
    print_info "Adding 'lzg' alias for lazygit..."
    add_alias_zshrc "lzg" "lazygit" "lazygit: quick access"
    print_success "Alias 'lzg' added"

    # Create config file
    if confirm "Create lazygit configuration file?" "y"; then
        print_info "Creating configuration..."

        cat > "$config_file" << 'EOF'
# lazygit configuration
# https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md

gui:
  # Use mouse for navigation
  mouseEvents: true

  # Show random tip in the command log
  showRandomTip: true

  # Border style
  border: "rounded"

  # Show file icons (requires nerd font)
  nerdFontsVersion: "3"

  # Theme
  theme:
    activeBorderColor:
      - cyan
      - bold
    inactiveBorderColor:
      - white
    optionsTextColor:
      - blue
    selectedLineBgColor:
      - blue
    selectedRangeBgColor:
      - blue
    cherryPickedCommitBgColor:
      - cyan
    cherryPickedCommitFgColor:
      - blue

git:
  # Pull/Push behavior
  paging:
    colorArg: always
    pager: delta --dark --paging=never

  # Auto fetch (in seconds, 0 to disable)
  autoFetch: true
  autoRefresh: true

  # Commit settings
  commit:
    signOff: false

  # Enable parsing of emoji in commit messages
  parseEmoji: true

os:
  # Open URLs in browser
  openCommand: open {{filename}}

  # Edit files with default editor
  editPreset: ''

keybinding:
  universal:
    quit: 'q'
    quit-alt1: '<c-c>'
    return: '<esc>'
    quitWithoutChangingDirectory: 'Q'
    togglePanel: '<tab>'
    prevItem: '<up>'
    nextItem: '<down>'
    prevItem-alt: 'k'
    nextItem-alt: 'j'
    prevPage: ','
    nextPage: '.'
    scrollLeft: 'H'
    scrollRight: 'L'
    gotoTop: '<'
    gotoBottom: '>'
    prevBlock: '<left>'
    nextBlock: '<right>'
    prevBlock-alt: 'h'
    nextBlock-alt: 'l'
    nextMatch: 'n'
    prevMatch: 'N'
    optionMenu: 'x'
    optionMenu-alt1: '?'
    select: '<space>'
    goInto: '<enter>'
    confirm: '<enter>'
    remove: 'd'
    new: 'n'
    edit: 'e'
    openFile: 'o'
    scrollUpMain: '<pgup>'
    scrollDownMain: '<pgdown>'
    scrollUpMain-alt1: 'K'
    scrollDownMain-alt1: 'J'
    scrollUpMain-alt2: '<c-u>'
    scrollDownMain-alt2: '<c-d>'
    executeCustomCommand: ':'
    createRebaseOptionsMenu: 'm'
    pushFiles: 'P'
    pullFiles: 'p'
    refresh: 'R'
    createPatchOptionsMenu: '<c-p>'
    nextTab: ']'
    prevTab: '['
    nextScreenMode: '+'
    prevScreenMode: '_'
    undo: 'z'
    redo: '<c-z>'
    filteringMenu: '<c-s>'
    diffingMenu: 'W'
    diffingMenu-alt: '<c-e>'
    copyToClipboard: '<c-o>'
    submitEditorText: '<enter>'
    appendNewline: '<a-enter>'
    extrasMenu: '@'
    toggleWhitespaceInDiffView: '<c-w>'
EOF

        # Configure delta as pager if available
        if command_exists delta; then
            print_success "Delta detected, configured as pager"
        else
            # Remove delta pager config if delta not installed
            sed -i.bak 's/pager: delta --dark --paging=never/pager: less -R/g' "$config_file"
            rm -f "${config_file}.bak"
            print_info "Using less as pager (install delta for better diffs)"
        fi

        print_success "Configuration saved to: $config_file"
    fi

    # Show keybindings
    echo ""
    print_divider "Key Bindings"
    echo ""
    echo -e "  ${BOLD}Navigation:${NC}"
    echo -e "  ${CYAN}h/j/k/l${NC}     Navigate panels and items"
    echo -e "  ${CYAN}<tab>${NC}       Switch between panels"
    echo -e "  ${CYAN}?${NC}           Show all keybindings"
    echo ""
    echo -e "  ${BOLD}Common actions:${NC}"
    echo -e "  ${CYAN}space${NC}       Stage/unstage file"
    echo -e "  ${CYAN}a${NC}           Stage all files"
    echo -e "  ${CYAN}c${NC}           Commit staged changes"
    echo -e "  ${CYAN}P${NC}           Push to remote"
    echo -e "  ${CYAN}p${NC}           Pull from remote"
    echo ""
    echo -e "  ${BOLD}Branches:${NC}"
    echo -e "  ${CYAN}n${NC}           Create new branch"
    echo -e "  ${CYAN}space${NC}       Checkout branch"
    echo -e "  ${CYAN}M${NC}           Merge into current branch"
    echo -e "  ${CYAN}r${NC}           Rebase current branch"
    echo ""

    return 0
}

# =============================================================================
# Uninstall lazygit
# =============================================================================
uninstall() {
    print_divider "Uninstall lazygit"

    print_warning "This will remove lazygit from your system"

    if ! confirm "Are you sure you want to uninstall lazygit?" "n"; then
        print_info "Uninstallation cancelled"
        return 0
    fi

    # Remove via Homebrew
    if uninstall_brew "lazygit"; then
        # Clean up shell configuration
        print_info "Cleaning up shell configuration..."
        remove_from_zshrc "alias lzg=.*lazygit" "pattern"

        # Ask about config removal
        local config_dir="${HOME}/.config/lazygit"
        if [[ -d "$config_dir" ]]; then
            if confirm "Remove lazygit configuration?" "n"; then
                rm -rf "$config_dir"
                print_success "Configuration removed"
            else
                print_info "Configuration kept at: $config_dir"
            fi
        fi

        print_success "lazygit uninstalled"
    else
        print_error "Failed to uninstall lazygit"
        return 1
    fi

    return 0
}

# =============================================================================
# Show Help
# =============================================================================
show_help() {
    echo ""
    echo -e "${BOLD}lazygit Installer${NC}"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  install     Install lazygit (default)"
    echo "  status      Show current installation status"
    echo "  uninstall   Remove lazygit completely"
    echo "  help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0              # Install lazygit"
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
                print_info "lazygit is not installed"
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
        print_info "Run 'lzg' in any git repository to start lazygit"
        echo ""
    fi

    exit $exit_code
}

# Run main if executed directly
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"
