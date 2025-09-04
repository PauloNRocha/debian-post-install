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
    local timeout_seconds="${3:-300}" # Aumentado para instalações maiores

    print_step "$message"
    timeout "$timeout_seconds" bash -c "$command" > /tmp/script_output 2>&1 &    local cmd_pid=$!
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
echo "║                    DEBIAN POST-INSTALL                       ║"
echo "║              Instalador de Multimídia e Codecs               ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# =========================
# Verificações Iniciais
# =========================
print_header "VERIFICAÇÃO DE PRÉ-REQUISITOS"

# 1. Verificar se é root
print_step "Verificando privilégios de root..."
if [ "$EUID" -ne 0 ]; then
    print_error "Este script precisa ser executado como root."
    echo -e "${YELLOW}Use: sudo ./03-multimedia.sh${NC}"
    exit 1
fi
print_success "Executando como root"

# =========================
# Instalação
# =========================
print_header "INSTALAÇÃO DE PACOTES DE MULTIMÍDIA"

# Atualizar a lista de pacotes
run_with_progress "Atualizando a lista de pacotes (apt update)" "apt update" 120

# Lista de pacotes de multimídia
MULTIMEDIA_PACKAGES="vlc ffmpeg gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav lame libavcodec-extra"

print_info "Pacotes a serem instalados: ${CYAN}${MULTIMEDIA_PACKAGES}${NC}"

if ! run_with_progress "Instalando pacotes de multimídia" "apt install -y $MULTIMEDIA_PACKAGES"; then
    print_error "A instalação de pacotes de multimídia falhou."
    print_warning "Verifique os erros acima e tente instalar os pacotes manualmente."
    exit 1
fi

# =========================
# Conclusão
# =========================
print_header "CONFIGURAÇÃO CONCLUÍDA"
echo -e "🎉 ${GREEN}${BOLD}Pacotes de multimídia e codecs foram instalados!${NC}"
echo ""
echo -e "Players como o VLC e codecs do sistema já estão prontos para uso."
echo ""
