#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# =========================
# Cores para output
# =========================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# =========================
# Funções de impressão
# =========================
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error()   { echo -e "${RED}❌${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_info()    { echo -e "${BLUE}ℹ${NC} $1"; }
print_header()  { echo -e "\n${CYAN}${BOLD}=== $1 ===${NC}\n"; }
print_step()    { echo -e "${PURPLE}▶${NC} $1"; }

# =========================
# Spinner
# =========================
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while ps -p $pid > /dev/null 2>&1; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# =========================
# Comando com timeout e progresso
# =========================
run_with_progress() {
    local message="$1"
    local command="$2"
    local timeout_seconds="${3:-300}"

    print_step "$message"
    timeout "$timeout_seconds" bash -c "$command" > /tmp/script_output 2>&1 & 
    local cmd_pid=$!
    spinner $cmd_pid
    wait $cmd_pid
    local exit_code=$?

    if [ $exit_code -eq 0 ]; then
        print_success "Concluído"
        rm -f /tmp/script_output
        return 0
    elif [ $exit_code -eq 124 ]; then
        print_error "Timeout após ${timeout_seconds}s"
        return 1
    else
        print_error "Falhou (código: $exit_code)"
        [ -f /tmp/script_output ] && echo -e "${YELLOW}Últimas linhas do erro:${NC}" && tail -5 /tmp/script_output
        return 1
    fi
}

# =========================
# Banner inicial
# =========================
clear
echo -e "${CYAN}${BOLD}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                       DEBIAN POST-INSTALL                    ║"
echo "║                      Instalador de Flatpak                   ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# =========================
# Verificações Iniciais
# =========================
print_header "VERIFICAÇÃO DE PRÉ-REQUISITOS"

if [ "$EUID" -ne 0 ]; then
    print_error "Este script precisa ser executado como root."
    exit 1
fi
print_success "Executando como root"

# =========================
# Instalação
# =========================
print_header "INSTALAÇÃO E CONFIGURAÇÃO DO FLATPAK"

# Atualizar a lista de pacotes
run_with_progress "Atualizando a lista de pacotes (apt update)" "apt update" 120

# Instalar Flatpak e o plugin da loja de apps
FLATPAK_PACKAGES="flatpak gnome-software-plugin-flatpak"
run_with_progress "Instalando Flatpak e plugin" "apt install -y $FLATPAK_PACKAGES"

# Adicionar o repositório Flathub
print_step "Adicionando o repositório Flathub..."
if flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo; then
    print_success "Repositório Flathub adicionado com sucesso."
else
    print_error "Falha ao adicionar o repositório Flathub."
    exit 1
fi

# =========================
# Conclusão
# =========================
print_header "CONFIGURAÇÃO CONCLUÍDA"
echo -e "🎉 ${GREEN}${BOLD}Flatpak foi instalado e configurado!${NC}"
echo ""
echo -e "Você pode instalar aplicações Flatpak via linha de comando ou pela loja de aplicativos."
echo -e "${YELLOW}Uma reinicialização é recomendada para garantir a integração completa com a loja de aplicativos.${NC}"
echo ""
echo -e "Para reiniciar agora, execute: ${CYAN}sudo reboot${NC}"
echo ""
