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
    local timeout_seconds="${3:-180}" # Aumentado para instalações

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
echo "║                    DEBIAN POST-INSTALL                       ║"
echo "║              Instalador de Drivers e Firmwares               ║"
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
    echo -e "${YELLOW}Use: sudo ./02-drivers.sh${NC}"
    exit 1
fi
print_success "Executando como root"

# 2. Verificar repositórios non-free
print_step "Verificando se os repositórios 'contrib' e 'non-free' estão habilitados..."
if ! grep -qE "contrib|non-free" /etc/apt/sources.list; then
    print_error "Repositórios 'contrib' e 'non-free' não encontrados."
    print_warning "Execute o script 01-repositories.sh primeiro."
    exit 1
fi
print_success "Repositórios necessários estão presentes"

# =========================
# Instalação
# =========================
print_header "INSTALAÇÃO DE DRIVERS E FIRMWARES"

# Atualizar a lista de pacotes
run_with_progress "Atualizando a lista de pacotes (apt update)" "apt update" 120

# Detectar hardware de vídeo
print_step "Detectando hardware de vídeo..."
VIDEO_HARDWARE=$(lspci | grep -i 'VGA compatible controller')
PACKAGES_TO_INSTALL=""

if echo "$VIDEO_HARDWARE" | grep -iq "NVIDIA"; then
    print_success "Placa de vídeo NVIDIA detectada"
    PACKAGES_TO_INSTALL+="nvidia-driver firmware-misc-nonfree "
elif echo "$VIDEO_HARDWARE" | grep -iq "AMD"; then
    print_success "Placa de vídeo AMD/ATI detectada"
    PACKAGES_TO_INSTALL+="firmware-amd-graphics libgl1-mesa-dri libglx-mesa0 mesa-vulkan-drivers xserver-xorg-video-all "
elif echo "$VIDEO_HARDWARE" | grep -iq "Intel"; then
    print_success "Placa de vídeo Intel detectada"
    PACKAGES_TO_INSTALL+="firmware-misc-nonfree intel-microcode "
else
    print_warning "Nenhum hardware de vídeo específico (NVIDIA/AMD/Intel) detectado."
fi

# Adicionar firmwares comuns (Wi-Fi, Bluetooth, etc.)
print_step "Adicionando pacotes de firmware comuns..."
PACKAGES_TO_INSTALL+="firmware-linux-nonfree firmware-iwlwifi firmware-realtek"
print_success "Pacotes de firmware adicionados à lista de instalação"

# Instalar os pacotes
if [ -n "$PACKAGES_TO_INSTALL" ]; then
    print_info "Pacotes a serem instalados: ${CYAN}${PACKAGES_TO_INSTALL}${NC}"
    if ! run_with_progress "Instalando drivers e firmwares" "apt install -y $PACKAGES_TO_INSTALL"; then
        print_error "A instalação de pacotes falhou."
        print_warning "Verifique os erros acima e tente instalar os pacotes manualmente."
        exit 1
    fi
else
    print_warning "Nenhum pacote de driver específico foi selecionado para instalação."
fi

# =========================
# Conclusão
# =========================
print_header "CONFIGURAÇÃO CONCLUÍDA"
echo -e "🎉 ${GREEN}${BOLD}Drivers e firmwares foram instalados!${NC}"
echo -e "${YELLOW}É altamente recomendável reiniciar o sistema para que todas as alterações entrem em vigor.${NC}"
echo ""
echo -e "Para reiniciar agora, execute: ${CYAN}sudo reboot${NC}"
echo ""
