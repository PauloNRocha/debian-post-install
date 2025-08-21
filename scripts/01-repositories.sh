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
    local timeout_seconds="${3:-30}"

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
echo "║              Configurador de Repositórios                    ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# =========================
# Detectar versão do Debian
# =========================
print_step "Detectando versão do sistema..."
if [ -f /etc/os-release ]; then
    . /etc/os-release > /dev/null 2>&1
    DEBIAN_VERSION=$VERSION_ID
    print_success "Detectado Debian $DEBIAN_VERSION"
else
    print_error "Não foi possível detectar a versão do Debian"
    exit 1
fi

# =========================
# Definir componentes por versão
# =========================
declare -A COMPONENTS_PATTERN
declare -A COMPONENTS_REPLACEMENT

COMPONENTS_PATTERN=(
    ["10"]="main"
    ["11"]="main"
    ["12"]="main non-free-firmware"
    ["13"]="main non-free-firmware"
)
COMPONENTS_REPLACEMENT=(
    ["10"]="main contrib non-free"
    ["11"]="main contrib non-free"
    ["12"]="main contrib non-free non-free-firmware"
    ["13"]="main contrib non-free non-free-firmware"
)

if [[ -z "${COMPONENTS_PATTERN[$DEBIAN_VERSION]:-}" ]]; then
    print_error "Versão não suportada: $DEBIAN_VERSION"
    echo -e "Versões suportadas: ${GREEN}Debian 10, 11, 12, 13${NC}"
    exit 1
fi

print_info "Sistema: Debian $DEBIAN_VERSION"

# =========================
# Configuração de repositórios
# =========================
print_header "CONFIGURAÇÃO DE REPOSITÓRIOS"

# Verificar se sources.list existe
print_step "Verificando arquivo sources.list..."
[ -f /etc/apt/sources.list ] || { print_error "/etc/apt/sources.list não encontrado!"; exit 1; }
print_success "Arquivo encontrado"

# Verificar se contrib/non-free já existem
NEEDS_UPDATE=false

if ! grep -qE "contrib(\s|$)" /etc/apt/sources.list; then
    print_info "Repositório 'contrib' precisa ser adicionado"
    NEEDS_UPDATE=true
else
    print_warning "'contrib' já configurado"
fi

if ! grep -qE "non-free(\s|$)" /etc/apt/sources.list; then
    print_info "Repositório 'non-free' precisa ser adicionado"
    NEEDS_UPDATE=true
else
    print_warning "'non-free' já configurado"
fi

if [ "$NEEDS_UPDATE" = false ]; then
    print_success "Todos os repositórios já configurados"
    exit 0
fi

# Backup
BACKUP_FILE="/etc/apt/sources.list.backup.$(date +%Y%m%d_%H%M%S)"
print_step "Criando backup de segurança..."
cp /etc/apt/sources.list "$BACKUP_FILE" && print_success "Backup: $BACKUP_FILE"

# Aplicar modificação apenas em linhas ativas
print_step "Configurando repositórios contrib e non-free..."
sed -i "/^deb / s/${COMPONENTS_PATTERN[$DEBIAN_VERSION]}/${COMPONENTS_REPLACEMENT[$DEBIAN_VERSION]}/g" /etc/apt/sources.list
print_success "Repositórios configurados"

# Validar configuração
print_step "Validando configuração..."
if grep -qE "contrib.*non-free" /etc/apt/sources.list; then
    print_success "Configuração validada com sucesso"
else
    print_error "Erro na validação da configuração"
    echo -e "Verifique manualmente: ${YELLOW}/etc/apt/sources.list${NC}"
    exit 1
fi

# =========================
# Atualizar pacotes
# =========================
print_header "ATUALIZANDO SISTEMA"
if ! run_with_progress "Atualizando lista de pacotes" "apt update" 60; then
    print_warning "Erro ao atualizar - continuando..."
    echo -e "${YELLOW}Execute manualmente: ${CYAN}apt update${NC}"
else
    print_success "Lista de pacotes atualizada!"
fi

# =========================
# Conclusão
# =========================
print_header "CONFIGURAÇÃO CONCLUÍDA"
echo -e "🎉 ${GREEN}${BOLD}Repositórios contrib e non-free configurados!${NC}"
echo -e "${YELLOW}Backup salvo em: ${NC}$BACKUP_FILE"
echo ""
