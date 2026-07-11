#!/usr/bin/env bash
# =============================================================================
# Oh My ZSH - ZSH Framework Installer
# DR Custom Terminal
# =============================================================================
# Installs Oh My ZSH, a delightful community-driven framework for managing
# your zsh configuration. Provides beautiful themes, smart plugins, and
# hundreds of helper functions to supercharge your terminal experience.
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
MODULE_NAME="Oh My ZSH"
MODULE_VERSION="1.0.0"
MODULE_DEPS=("git" "curl" "zsh")

# Oh My ZSH installation URL
readonly OMZ_INSTALL_URL="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
readonly OMZ_UNINSTALL_URL="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/uninstall.sh"

# Default configuration
readonly DEFAULT_THEME="robbyrussell"
# Curated, correctly-ordered plugin list. Built-in Oh My ZSH plugins plus the
# custom plugins installed by the modules under modules/plugins. ATENCAO:
# zsh-syntax-highlighting e zsh-history-substring-search devem ser os dois
# ultimos (nesta ordem), conforme a documentacao oficial.
readonly DEFAULT_PLUGINS="git git-auto-fetch fzf macos sudo extract copypath copyfile copybuffer dirhistory web-search colored-man-pages command-not-found zsh-completions zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search"

# =============================================================================
# ASCII Art Header
# =============================================================================
show_ascii_header() {
    echo -e "${CYAN}"
    cat << 'EOF'
   ____  __       __  ___         _____  _____ __  __
  / __ \/ /_     /  |/  /_  __   /__  / / ___// / / /
 / / / / __ \   / /|_/ / / / /     / /  \__ \/ /_/ /
/ /_/ / / / /  / /  / / /_/ /     / /_____/ / __  /
\____/_/ /_/  /_/  /_/\__, /     /____/____/_/ /_/
                     /____/
    A delightful community-driven framework for ZSH
EOF
    echo -e "${NC}"
    echo ""
}

# =============================================================================
# Dependency Check
# =============================================================================
check_dependencies() {
    local has_errors=0

    print_divider "Checking Dependencies"

    # Check for Homebrew (recommended for macOS)
    if is_macos && ! has_brew; then
        print_warning "Homebrew is not installed"
        print_info "It's recommended to install Homebrew first for managing ZSH plugins"
        print_info "Run: ${PROJECT_ROOT}/modules/base/homebrew.sh"
        # Not a hard requirement, just a recommendation
    fi

    # Check for ZSH
    if ! command_exists zsh; then
        print_error "ZSH is required but not installed"
        if is_macos; then
            print_info "ZSH should be pre-installed on macOS"
            print_info "If missing, install with: brew install zsh"
        else
            print_info "Install ZSH using your package manager"
        fi
        has_errors=1
    else
        local zsh_version
        zsh_version=$(zsh --version 2>/dev/null | awk '{print $2}')
        print_success "ZSH installed (version: ${zsh_version})"
    fi

    # Check for Git
    if ! command_exists git; then
        print_error "Git is required but not installed"
        print_info "Install Git first"
        has_errors=1
    else
        print_success "Git installed"
    fi

    # Check for curl
    if ! command_exists curl; then
        print_error "curl is required but not installed"
        has_errors=1
    else
        print_success "curl installed"
    fi

    echo ""
    return $has_errors
}

# =============================================================================
# Installation Status Check
# =============================================================================
is_installed() {
    local omz_dir
    omz_dir="$(get_omz_dir)"
    [[ -d "$omz_dir" && -f "${omz_dir}/oh-my-zsh.sh" ]]
}

# =============================================================================
# Get Oh My ZSH Version
# =============================================================================
get_omz_version() {
    local omz_dir
    omz_dir="$(get_omz_dir)"

    if [[ -d "${omz_dir}/.git" ]]; then
        # Get the latest tag or commit date
        local version
        version=$(git -C "$omz_dir" describe --tags --abbrev=0 2>/dev/null || \
                  git -C "$omz_dir" log -1 --format="%cd" --date=short 2>/dev/null || \
                  echo "unknown")
        echo "$version"
    else
        echo "Not installed"
    fi
}

# =============================================================================
# Show Current Status
# =============================================================================
show_status() {
    print_divider "Current Status"

    local omz_dir
    omz_dir="$(get_omz_dir)"

    echo -e "  ${ICON_BULLET} Installation path: ${DIM}${omz_dir}${NC}"
    echo ""

    if is_installed; then
        local version
        version="$(get_omz_version)"

        echo -e "  ${ICON_SUCCESS} ${GREEN}Installed${NC}"
        echo -e "  ${ICON_BULLET} Version/Date: ${BOLD}${version}${NC}"
        echo ""

        # Show current theme
        local zshrc_path
        zshrc_path="$(get_zshrc_path)"
        if [[ -f "$zshrc_path" ]]; then
            local current_theme
            current_theme=$(grep "^ZSH_THEME=" "$zshrc_path" 2>/dev/null | cut -d'"' -f2) || true
            if [[ -n "$current_theme" ]]; then
                echo -e "  ${ICON_BULLET} Current theme: ${BOLD}${current_theme}${NC}"
            fi

            # Show enabled plugins
            local plugins
            plugins=$(list_plugins_omz) || true
            if [[ -n "$plugins" ]]; then
                echo -e "  ${ICON_BULLET} Enabled plugins: ${DIM}${plugins}${NC}"
            fi
        fi

        # Check custom directory
        local custom_dir
        custom_dir="$(get_omz_custom_dir)"
        if [[ -d "$custom_dir" ]]; then
            local custom_plugins
            local custom_themes
            custom_plugins=$(find "${custom_dir}/plugins" -maxdepth 1 -type d 2>/dev/null | wc -l)
            custom_themes=$(find "${custom_dir}/themes" -name "*.zsh-theme" 2>/dev/null | wc -l)
            custom_plugins=$((custom_plugins - 1))  # Subtract the directory itself

            if [[ $custom_plugins -gt 0 || $custom_themes -gt 0 ]]; then
                echo ""
                echo -e "  ${ICON_BULLET} Custom plugins: ${BOLD}${custom_plugins}${NC}"
                echo -e "  ${ICON_BULLET} Custom themes: ${BOLD}${custom_themes}${NC}"
            fi
        fi

        # Check if ZSH is default shell
        echo ""
        if is_zsh_default_shell; then
            print_success "ZSH is the default shell"
        else
            print_warning "ZSH is not the default shell"
            print_info "Set it with: chsh -s \$(which zsh)"
        fi
    else
        echo -e "  ${ICON_ERROR} ${RED}Not installed${NC}"
    fi

    echo ""
}

# =============================================================================
# Backup Existing Configuration
# =============================================================================
backup_existing_config() {
    print_divider "Backing Up Configuration"

    local zshrc_path
    zshrc_path="$(get_zshrc_path)"

    # Backup .zshrc if it exists
    if [[ -f "$zshrc_path" ]]; then
        print_info "Found existing .zshrc"
        local backup_file
        backup_file=$(backup_zshrc)
        if [[ -n "$backup_file" ]]; then
            print_success "Backup saved to: $backup_file"
        fi
    else
        print_info "No existing .zshrc found"
    fi

    # Backup other zsh files
    local zsh_files=(".zshenv" ".zprofile" ".zlogin" ".zlogout")
    local backup_dir="$HOME/.config/zsh-backups"

    for file in "${zsh_files[@]}"; do
        local file_path="$HOME/$file"
        if [[ -f "$file_path" ]]; then
            local timestamp
            timestamp="$(date +%Y%m%d_%H%M%S)"
            mkdir -p "$backup_dir"
            cp "$file_path" "${backup_dir}/${file#.}_${timestamp}.bak"
            print_info "Backed up $file"
        fi
    done

    return 0
}

# =============================================================================
# Install Oh My ZSH
# =============================================================================
install() {
    print_divider "Installation"

    # Check for internet connectivity
    print_step 1 6 "Checking internet connection..."
    if ! has_internet; then
        print_error "No internet connection detected"
        print_info "Please connect to the internet and try again"
        return 1
    fi
    print_success "Internet connection available"

    # Verify Oh My ZSH URL is accessible
    print_step 2 6 "Verifying Oh My ZSH servers..."
    if ! url_accessible "https://raw.githubusercontent.com"; then
        print_error "Cannot reach GitHub"
        print_info "Please check your network connection"
        return 1
    fi
    print_success "Oh My ZSH servers reachable"

    # Backup existing configuration
    print_step 3 6 "Backing up existing configuration..."
    backup_existing_config

    # Install Oh My ZSH
    print_step 4 6 "Installing Oh My ZSH..."
    echo ""
    print_info "Running official installation script..."
    print_info "Installation path: $(get_omz_dir)"
    echo ""

    # Run the installation script with environment variables:
    # - RUNZSH=no: Prevent auto-switching to zsh after install
    # - KEEP_ZSHRC=no: Allow creating fresh .zshrc from template
    # - CHSH=no: Don't change default shell automatically
    local install_env="RUNZSH=no KEEP_ZSHRC=no CHSH=no"

    if ! env $install_env sh -c "$(curl -fsSL ${OMZ_INSTALL_URL})" "" --unattended; then
        print_error "Oh My ZSH installation failed"
        return 1
    fi

    echo ""
    print_success "Oh My ZSH installed successfully"

    # Configure shell
    print_step 5 6 "Configuring Oh My ZSH..."
    configure_omz

    # Verify installation
    print_step 6 6 "Verifying installation..."
    if is_installed; then
        print_success "Oh My ZSH is ready to use"
    else
        print_error "Installation verification failed"
        return 1
    fi

    return 0
}

# =============================================================================
# Configure Oh My ZSH
# =============================================================================
configure_omz() {
    local zshrc_path
    zshrc_path="$(get_zshrc_path)"
    local omz_dir
    omz_dir="$(get_omz_dir)"

    # Ensure .zshrc exists (Oh My ZSH should create it)
    if [[ ! -f "$zshrc_path" ]]; then
        print_warning ".zshrc not found, creating from template..."
        if [[ -f "${omz_dir}/templates/zshrc.zsh-template" ]]; then
            cp "${omz_dir}/templates/zshrc.zsh-template" "$zshrc_path"
        else
            # Create minimal .zshrc
            # NOTE: The quoted heredoc (<< 'ZSHRC') intentionally prevents variable
            # expansion during file creation. Variables like $HOME and $ZSH will be
            # written literally and expanded at runtime when the shell sources the file.
            cat > "$zshrc_path" << 'ZSHRC'
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="robbyrussell"

# Which plugins would you like to load?
plugins=(git)

source $ZSH/oh-my-zsh.sh
ZSHRC
        fi
    fi

    # Ensure export ZSH= is set
    if ! grep -q "^export ZSH=" "$zshrc_path"; then
        print_info "Adding ZSH export path"
        add_to_zshrc "export ZSH=\"\$HOME/.oh-my-zsh\"" "Path to your oh-my-zsh installation" "top"
    fi

    # Ensure ZSH_THEME is set
    if ! grep -q "^ZSH_THEME=" "$zshrc_path"; then
        print_info "Setting default theme: ${DEFAULT_THEME}"
        echo "" >> "$zshrc_path"
        echo "# Oh My ZSH Theme" >> "$zshrc_path"
        echo "ZSH_THEME=\"${DEFAULT_THEME}\"" >> "$zshrc_path"
    fi

    # Ensure plugins line exists and carries the curated default list.
    if ! grep -q "^plugins=(" "$zshrc_path"; then
        print_info "Configuring default plugins"
        echo "" >> "$zshrc_path"
        echo "# Oh My ZSH Plugins" >> "$zshrc_path"
        echo "plugins=(${DEFAULT_PLUGINS})" >> "$zshrc_path"
    elif grep -qE "^plugins=\(git\)[[:space:]]*$" "$zshrc_path"; then
        # Fresh install created the template default plugins=(git). Replace it
        # with the curated list without touching a user-customized array.
        print_info "Applying curated default plugins"
        local temp_file
        temp_file="$(mktemp)"
        sed "s/^plugins=(git)[[:space:]]*$/plugins=(${DEFAULT_PLUGINS})/" "$zshrc_path" > "$temp_file"
        mv "$temp_file" "$zshrc_path"
    fi

    # Ensure source $ZSH/oh-my-zsh.sh exists
    if ! grep -q 'source.*oh-my-zsh\.sh' "$zshrc_path"; then
        print_info "Adding Oh My ZSH source"
        add_to_zshrc 'source $ZSH/oh-my-zsh.sh' "Load Oh My ZSH" "after:^plugins="
    fi

    # Create custom directories if they don't exist
    local custom_dir
    custom_dir="$(get_omz_custom_dir)"
    mkdir -p "${custom_dir}/plugins"
    mkdir -p "${custom_dir}/themes"
    print_success "Custom directories created"

    return 0
}

# =============================================================================
# Post-Installation Configuration
# =============================================================================
configure() {
    print_divider "Post-Installation Configuration"

    if ! is_installed; then
        print_error "Oh My ZSH is not installed"
        return 1
    fi

    # Theme selection
    echo ""
    echo -e "${BOLD}Popular themes:${NC}"
    echo ""
    echo -e "  ${CYAN}robbyrussell${NC}  - Clean and informative (default)"
    echo -e "  ${CYAN}agnoster${NC}      - Powerline-style, requires Nerd Font"
    echo -e "  ${CYAN}af-magic${NC}      - Clean with git status"
    echo -e "  ${CYAN}bira${NC}          - Two-line prompt with git info"
    echo -e "  ${CYAN}candy${NC}         - Colorful and fun"
    echo -e "  ${CYAN}refined${NC}       - Minimal and elegant"
    echo ""

    if confirm "Change the default theme?" "n"; then
        local theme
        read -r -p "$(echo -e "${YELLOW}?${NC} Enter theme name: ")" theme
        if [[ -n "$theme" ]]; then
            set_omz_theme "$theme"
        fi
    fi

    # Plugin recommendations
    echo ""
    print_divider "Recommended Plugins"
    echo ""
    echo -e "  ${BOLD}Built-in plugins:${NC}"
    echo -e "  ${CYAN}git${NC}              - Git aliases and functions"
    echo -e "  ${CYAN}docker${NC}           - Docker command completion"
    echo -e "  ${CYAN}npm${NC}              - npm aliases and completion"
    echo -e "  ${CYAN}node${NC}             - Node.js helpers"
    echo -e "  ${CYAN}brew${NC}             - Homebrew aliases (macOS)"
    echo -e "  ${CYAN}macos${NC}            - macOS helpers (macOS)"
    echo -e "  ${CYAN}colored-man-pages${NC} - Syntax highlighting for man pages"
    echo ""
    echo -e "  ${BOLD}Popular third-party plugins:${NC}"
    echo -e "  ${CYAN}zsh-autosuggestions${NC}      - Fish-like autosuggestions"
    echo -e "  ${CYAN}zsh-syntax-highlighting${NC}  - Syntax highlighting"
    echo -e "  ${CYAN}zsh-completions${NC}          - Additional completions"
    echo ""

    # Offer to install popular third-party plugins
    if confirm "Install zsh-autosuggestions plugin?" "y"; then
        install_omz_plugin "zsh-users/zsh-autosuggestions" "zsh-autosuggestions"
    fi

    if confirm "Install zsh-syntax-highlighting plugin?" "y"; then
        install_omz_plugin "zsh-users/zsh-syntax-highlighting" "zsh-syntax-highlighting"
    fi

    # Set ZSH as default shell
    echo ""
    if ! is_zsh_default_shell; then
        if confirm "Set ZSH as your default shell?" "y"; then
            local zsh_path
            zsh_path="$(which zsh)"
            print_info "Changing default shell to: $zsh_path"
            print_info "You may be prompted for your password"

            if chsh -s "$zsh_path"; then
                print_success "ZSH is now your default shell"
            else
                print_warning "Failed to change default shell"
                print_info "You can do it manually with: chsh -s $(which zsh)"
            fi
        fi
    else
        print_success "ZSH is already your default shell"
    fi

    # Show next steps
    echo ""
    print_divider "Getting Started"
    echo ""
    echo -e "  ${BOLD}Customize your configuration:${NC}"
    echo -e "  ${DIM}Edit ~/.zshrc to modify theme, plugins, and settings${NC}"
    echo ""
    echo -e "  ${BOLD}Common Oh My ZSH commands:${NC}"
    echo ""
    echo -e "  ${CYAN}omz update${NC}        Update Oh My ZSH"
    echo -e "  ${CYAN}omz changelog${NC}     Show recent changes"
    echo -e "  ${CYAN}omz reload${NC}        Reload configuration"
    echo -e "  ${CYAN}omz theme list${NC}    List available themes"
    echo -e "  ${CYAN}omz plugin list${NC}   List available plugins"
    echo ""
    echo -e "  ${BOLD}Useful aliases (from git plugin):${NC}"
    echo ""
    echo -e "  ${CYAN}gst${NC}   git status"
    echo -e "  ${CYAN}gco${NC}   git checkout"
    echo -e "  ${CYAN}gp${NC}    git push"
    echo -e "  ${CYAN}gl${NC}    git pull"
    echo -e "  ${CYAN}glog${NC}  git log --oneline --decorate --graph"
    echo ""

    return 0
}

# =============================================================================
# Update Oh My ZSH
# =============================================================================
update() {
    print_divider "Updating Oh My ZSH"

    if ! is_installed; then
        print_error "Oh My ZSH is not installed"
        return 1
    fi

    local omz_dir
    omz_dir="$(get_omz_dir)"

    print_info "Updating Oh My ZSH..."

    # Use the built-in upgrade script if available
    if [[ -f "${omz_dir}/tools/upgrade.sh" ]]; then
        if env ZSH="$omz_dir" sh "${omz_dir}/tools/upgrade.sh"; then
            print_success "Oh My ZSH updated successfully"
        else
            print_warning "Update had some issues"
        fi
    else
        # Fall back to git pull
        print_info "Using git to update..."
        if git -C "$omz_dir" pull --rebase --stat; then
            print_success "Oh My ZSH updated successfully"
        else
            print_error "Failed to update Oh My ZSH"
            return 1
        fi
    fi

    # Update custom plugins
    local custom_dir
    custom_dir="$(get_omz_custom_dir)"

    if [[ -d "${custom_dir}/plugins" ]]; then
        local plugin_dirs
        plugin_dirs=$(find "${custom_dir}/plugins" -maxdepth 1 -type d -name "*" ! -name "plugins" 2>/dev/null)

        if [[ -n "$plugin_dirs" ]]; then
            echo ""
            print_info "Updating custom plugins..."

            while IFS= read -r plugin_dir; do
                if [[ -d "${plugin_dir}/.git" ]]; then
                    local plugin_name
                    plugin_name=$(basename "$plugin_dir")
                    if git -C "$plugin_dir" pull --rebase --quiet 2>/dev/null; then
                        print_success "Updated: $plugin_name"
                    else
                        print_warning "Could not update: $plugin_name"
                    fi
                fi
            done <<< "$plugin_dirs"
        fi
    fi

    return 0
}

# =============================================================================
# Uninstall Oh My ZSH
# =============================================================================
uninstall() {
    print_divider "Uninstall Oh My ZSH"

    if ! is_installed; then
        print_info "Oh My ZSH is not installed"
        return 0
    fi

    print_warning "This will remove Oh My ZSH and restore your original .zshrc backup"
    echo ""

    if ! confirm "Are you sure you want to uninstall Oh My ZSH?" "n"; then
        print_info "Uninstallation cancelled"
        return 0
    fi

    local omz_dir
    omz_dir="$(get_omz_dir)"

    # Run the official uninstall script if available
    if [[ -f "${omz_dir}/tools/uninstall.sh" ]]; then
        print_info "Running uninstall script..."
        env ZSH="$omz_dir" sh "${omz_dir}/tools/uninstall.sh" --unattended
    else
        # Manual uninstall
        print_info "Removing Oh My ZSH directory..."

        # Backup current .zshrc before removal
        local zshrc_path
        zshrc_path="$(get_zshrc_path)"
        if [[ -f "$zshrc_path" ]]; then
            backup_zshrc
        fi

        # Remove Oh My ZSH directory
        rm -rf "$omz_dir"

        # Check for pre-Oh My ZSH backup
        local pre_omz_backup="$HOME/.zshrc.pre-oh-my-zsh"
        if [[ -f "$pre_omz_backup" ]]; then
            print_info "Restoring pre-Oh My ZSH configuration..."
            mv "$pre_omz_backup" "$zshrc_path"
            print_success "Original .zshrc restored"
        fi
    fi

    if [[ ! -d "$omz_dir" ]]; then
        print_success "Oh My ZSH uninstalled successfully"
    else
        print_error "Failed to uninstall Oh My ZSH"
        return 1
    fi

    return 0
}

# =============================================================================
# Show Help
# =============================================================================
show_help() {
    echo ""
    echo -e "${BOLD}Oh My ZSH Installer${NC}"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  install     Install Oh My ZSH (default)"
    echo "  update      Update Oh My ZSH and plugins"
    echo "  status      Show current installation status"
    echo "  uninstall   Remove Oh My ZSH completely"
    echo "  help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0              # Install Oh My ZSH"
    echo "  $0 status       # Check installation status"
    echo "  $0 update       # Update Oh My ZSH"
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
                print_error "Missing dependencies. Please install them first."
                exit 1
            fi

            # Check if already installed
            if is_installed; then
                show_status
                print_warning "$MODULE_NAME is already installed"

                if ! confirm "Reinstall $MODULE_NAME?"; then
                    print_info "Skipping $MODULE_NAME installation"

                    # Offer to run configuration anyway
                    if confirm "Run post-installation configuration?" "y"; then
                        configure
                    fi
                    exit 0
                fi

                # Uninstall first, then install fresh
                uninstall && install && configure
            else
                install && configure
            fi
            ;;
        update)
            if ! is_installed; then
                print_error "Oh My ZSH is not installed"
                print_info "Run: $0 install"
                exit 1
            fi
            update
            ;;
        status)
            show_status
            ;;
        uninstall)
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
        echo ""
        if [[ "$command" == "install" ]]; then
            print_info "Start a new terminal session or run: source ~/.zshrc"
        fi
        echo ""
    fi

    exit $exit_code
}

# Run main if executed directly
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"
