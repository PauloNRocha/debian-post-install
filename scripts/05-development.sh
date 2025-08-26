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
echo "║                    DEBIAN POST-INSTALL                       ║"
echo "║           Instalador de Ferramentas de Desenvolvimento       ║"
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
print_header "INSTALAÇÃO DE FERRAMENTAS DE DESENVOLVIMENTO"

# Dependências para adicionar repositórios
run_with_progress "Instalando dependências (curl, gpg)" "apt update && apt install -y curl gpg"

# --- Node.js (via NodeSource) ---
print_info "Configurando Node.js..."
if ! command -v node >/dev/null 2>&1; then
    run_with_progress "Adicionando repositório NodeSource" "curl -fsSL https://deb.nodesource.com/setup_20.x | bash -"
    run_with_progress "Instalando Node.js" "apt install -y nodejs"
else
    print_warning "Node.js já está instalado"
fi

# --- Visual Studio Code ---
print_info "Configurando Visual Studio Code..."
if ! command -v code >/dev/null 2>&1; then
    run_with_progress "Adicionando chave GPG da Microsoft" "curl -sSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /usr/share/keyrings/packages.microsoft.gpg"
    run_with_progress "Adicionando repositório VSCode" 'echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    run_with_progress "Instalando VSCode" "apt update && apt install -y code"
else
    print_warning "Visual Studio Code já está instalado"
fi

# --- Docker ---
print_info "Configurando Docker..."
if ! command -v docker >/dev/null 2>&1; then
    run_with_progress "Adicionando chave GPG do Docker" "install -m 0755 -d /etc/apt/keyrings && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && chmod a+r /etc/apt/keyrings/docker.gpg"
    run_with_progress "Adicionando repositório Docker" 'echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list'
    run_with_progress "Instalando Docker Engine" "apt update && apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"
    print_step "Adicionando usuário atual ao grupo docker (necessário logout/login)"
    # Adiciona o usuário que invocou sudo, ou o usuário logado
    REAL_USER=${SUDO_USER:-$(logname)}
    usermod -aG docker "$REAL_USER"
    print_success "Usuário $REAL_USER adicionado ao grupo docker."
else
    print_warning "Docker já está instalado"
fi

# =========================
# Conclusão
# =========================
print_header "CONFIGURAÇÃO CONCLUÍDA"
echo -e "🎉 ${GREEN}${BOLD}Ferramentas de desenvolvimento instaladas!${NC}"
echo ""
echo -e "${YELLOW}Para que as permissões do Docker funcionem, você precisa fazer logout e login novamente.${NC}"
echo ""
