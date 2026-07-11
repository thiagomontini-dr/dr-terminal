#!/usr/bin/env bash
# =============================================================================
# Shell Aliases - Atalhos e funcoes de produtividade
# DR Custom Terminal
# =============================================================================
# Adiciona um conjunto curado de aliases e funcoes ao .zshrc para acelerar
# tarefas comuns: navegacao, listagem, sistema, manutencao do Homebrew, e
# funcoes auxiliares como clone (git clone + cd) e mkcd (mkdir + cd).
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
MODULE_NAME="Shell Aliases"
MODULE_VERSION="1.0.0"
MODULE_DEPS=("zsh")

# Markers used to manage the managed block inside .zshrc
readonly MARKER_START="# >>> dr-terminal aliases >>>"
readonly MARKER_END="# <<< dr-terminal aliases <<<"

# =============================================================================
# ASCII Art Header
# =============================================================================
show_ascii_header() {
    echo -e "${CYAN}"
    cat << 'EOF'
       _ _
  __ _| (_) __ _ ___  ___  ___
 / _` | | |/ _` / __|/ _ \/ __|
| (_| | | | (_| \__ \  __/\__ \
 \__,_|_|_|\__,_|___/\___||___/

 Atalhos e funcoes de produtividade
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
    local zshrc_path
    zshrc_path="$(get_zshrc_path)"
    [[ -f "$zshrc_path" ]] && grep -Fq "$MARKER_START" "$zshrc_path"
}

# =============================================================================
# Show Current Status
# =============================================================================
show_status() {
    print_divider "Current Status"

    if is_installed; then
        local zshrc_path
        zshrc_path="$(get_zshrc_path)"

        local entries
        entries=$(sed -n "/$MARKER_START/,/$MARKER_END/p" "$zshrc_path" \
            | grep -cE "^(alias |[a-zA-Z_]+\(\) *\{)" || true)

        echo -e "  ${ICON_SUCCESS} ${GREEN}Installed${NC}"
        echo -e "  ${ICON_BULLET} Entradas gerenciadas: ${BOLD}${entries}${NC}"
        echo -e "  ${ICON_BULLET} Localizacao: ${DIM}${zshrc_path}${NC}"
    else
        echo -e "  ${ICON_ERROR} ${RED}Not installed${NC}"
    fi

    echo ""
}

# =============================================================================
# Write Managed Block
# =============================================================================
write_managed_block() {
    local zshrc_path="$1"

    cat >> "$zshrc_path" << EOF

${MARKER_START}
# Navegacao
alias ..='cd ..'
alias ...='cd ../..'

# Sistema
alias l='ls -lah'
alias reload='source ~/.zshrc'
alias c='clear'
alias h='history'
alias now='date +"%Y-%m-%d %H:%M:%S"'
alias week='date +%V'

# Manutencao
alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'
alias brewup='brew update && brew upgrade && brew cleanup'

# Ajuda: abre o guia de plugins do Zsh no editor
alias zshhelp='\${EDITOR:-cursor} "${PROJECT_ROOT}/docs/ZSH-PLUGINS.md"'

# configclaude: faz backup datado do settings.json e abre no editor
configclaude() {
    local file="\$HOME/.claude/settings.json"
    if [[ ! -f "\$file" ]]; then
        echo "configclaude: \$file nao existe" >&2
        return 1
    fi
    cp "\$file" "\${file}.bkp_\$(date +%Y%m%d_%H%M%S)" && \${EDITOR:-cursor} "\$file"
}

# git clone + cd para a pasta clonada
clone() {
    if [[ -z "\${1:-}" ]]; then
        echo "Uso: clone <repo-url> [destino]" >&2
        return 1
    fi
    local target="\${2:-\$(basename "\$1" .git)}"
    git clone "\$1" "\$target" && cd "\$target"
}

# mkdir + cd
mkcd() { mkdir -p "\$1" && cd "\$1"; }
${MARKER_END}
EOF
}

# =============================================================================
# Remove Managed Block
# =============================================================================
remove_managed_block() {
    local zshrc_path="$1"
    local temp_file
    temp_file="$(mktemp)"

    awk -v start="$MARKER_START" -v end="$MARKER_END" '
        $0 == start { skip = 1; next }
        $0 == end   { skip = 0; next }
        !skip       { print }
    ' "$zshrc_path" > "$temp_file"

    # Drop trailing blank lines that may remain after removal
    awk 'NF { blank=0 } !NF { blank++ } blank<2' "$temp_file" > "${temp_file}.cleaned"
    mv "${temp_file}.cleaned" "$zshrc_path"
    rm -f "$temp_file"
}

# =============================================================================
# Install Aliases
# =============================================================================
install() {
    print_divider "Installation"

    local zshrc_path
    zshrc_path="$(get_zshrc_path)"

    if [[ ! -f "$zshrc_path" ]]; then
        touch "$zshrc_path"
    fi

    if is_installed; then
        print_info "Aliases ja estao instalados (bloco gerenciado encontrado)"
        if confirm "Reaplicar bloco para garantir conteudo atualizado?" "y"; then
            backup_zshrc >/dev/null
            remove_managed_block "$zshrc_path"
            write_managed_block "$zshrc_path"
            print_success "Bloco de aliases reaplicado"
        fi
        return 0
    fi

    backup_zshrc >/dev/null
    write_managed_block "$zshrc_path"
    print_success "Aliases adicionados ao .zshrc"

    return 0
}

# =============================================================================
# Configure (post-install info)
# =============================================================================
configure() {
    print_divider "Aliases incluidos"
    echo ""
    echo -e "  ${BOLD}Navegacao${NC}"
    echo -e "    ${CYAN}..${NC}          cd .."
    echo -e "    ${CYAN}...${NC}         cd ../.."
    echo ""
    echo -e "  ${BOLD}Sistema${NC}"
    echo -e "    ${CYAN}l${NC}           ls -lah"
    echo -e "    ${CYAN}reload${NC}      source ~/.zshrc"
    echo -e "    ${CYAN}c${NC}           clear"
    echo -e "    ${CYAN}h${NC}           history"
    echo -e "    ${CYAN}now${NC}         data e hora atual"
    echo -e "    ${CYAN}week${NC}        numero da semana ISO"
    echo ""
    echo -e "  ${BOLD}Manutencao${NC}"
    echo -e "    ${CYAN}flushdns${NC}    limpa cache DNS do macOS"
    echo -e "    ${CYAN}brewup${NC}      brew update + upgrade + cleanup"
    echo ""
    echo -e "  ${BOLD}Ajuda e config${NC}"
    echo -e "    ${CYAN}zshhelp${NC}     abre o guia de plugins do Zsh"
    echo -e "    ${CYAN}configclaude${NC}  backup datado do settings.json + abre no editor"
    echo ""
    echo -e "  ${BOLD}Funcoes${NC}"
    echo -e "    ${CYAN}clone <url>${NC}        git clone + cd para a pasta clonada"
    echo -e "    ${CYAN}mkcd <pasta>${NC}       mkdir -p + cd"
    echo ""

    return 0
}

# =============================================================================
# Uninstall Aliases
# =============================================================================
uninstall() {
    print_divider "Uninstall Shell Aliases"

    if ! is_installed; then
        print_info "Nenhum bloco gerenciado encontrado no .zshrc"
        return 0
    fi

    if ! confirm "Remover o bloco de aliases do .zshrc?" "n"; then
        print_info "Uninstallation cancelled"
        return 0
    fi

    local zshrc_path
    zshrc_path="$(get_zshrc_path)"

    backup_zshrc >/dev/null
    remove_managed_block "$zshrc_path"
    print_success "Bloco de aliases removido"

    return 0
}

# =============================================================================
# Show Help
# =============================================================================
show_help() {
    echo ""
    echo -e "${BOLD}Shell Aliases Installer${NC}"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  install     Adiciona o bloco de aliases ao .zshrc (default)"
    echo "  status      Mostra status do bloco gerenciado"
    echo "  uninstall   Remove o bloco gerenciado do .zshrc"
    echo "  help        Mostra esta ajuda"
    echo ""
    echo "Examples:"
    echo "  $0              # Instala os aliases"
    echo "  $0 status       # Verifica o status"
    echo "  $0 uninstall    # Remove o bloco"
    echo ""
}

# =============================================================================
# Main Entry Point
# =============================================================================
main() {
    local command="${1:-install}"

    show_ascii_header
    print_header "$MODULE_NAME Installer"

    case "$command" in
        install)
            if ! check_dependencies; then
                print_error "Dependencias ausentes"
                exit 1
            fi
            install && configure
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
        print_info "Rode 'source ~/.zshrc' ou abra um novo terminal para aplicar"
        echo ""
    fi

    exit $exit_code
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"
