#!/usr/bin/env bash

if [[ -n "${DEBIAN_POST_INSTALL_COMMON_LOADED:-}" ]]; then
    return 0
fi
DEBIAN_POST_INSTALL_COMMON_LOADED=1

LOG_BASE_DIR="/var/log/debian-post-install"
TMP_BASE_DIR="/tmp/debian-post-install"
DRY_RUN="${DEBIAN_POST_INSTALL_DRY_RUN:-false}"
ASSUME_YES="${DEBIAN_POST_INSTALL_ASSUME_YES:-false}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error()   { echo -e "${RED}❌${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_info()    { echo -e "${BLUE}ℹ${NC} $1"; }
print_header()  { echo -e "\n${CYAN}${BOLD}=== $1 ===${NC}\n"; }
print_step()    { echo -e "${PURPLE}▶${NC} $1"; }

center_text() {
    local width="$1"
    local text="$2"
    local text_length="${#text}"
    local left_padding=$(((width - text_length) / 2))
    local right_padding=$((width - text_length - left_padding))

    printf '%*s%s%*s' "${left_padding}" '' "${text}" "${right_padding}" ''
}

show_banner() {
    local title="$1"
    clear
    echo -e "${CYAN}${BOLD}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    printf "║%s║\n" "$(center_text 62 "DEBIAN POST-INSTALL")"
    printf "║%s║\n" "$(center_text 62 "${title}")"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

common_init() {
    MODULE_NAME="$1"
    RUN_TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
    mkdir -p "${TMP_BASE_DIR}"
    mkdir -p "${LOG_BASE_DIR}" 2>/dev/null || true
    if [[ -d "${LOG_BASE_DIR}" && -w "${LOG_BASE_DIR}" ]]; then
        EFFECTIVE_LOG_BASE_DIR="${LOG_BASE_DIR}"
    else
        EFFECTIVE_LOG_BASE_DIR="${TMP_BASE_DIR}/logs"
        mkdir -p "${EFFECTIVE_LOG_BASE_DIR}"
    fi
    MODULE_TMP_DIR="$(mktemp -d "${TMP_BASE_DIR}/${MODULE_NAME}.XXXXXX")"
    MODULE_LOG="${EFFECTIVE_LOG_BASE_DIR}/${RUN_TIMESTAMP}-${MODULE_NAME}.log"
    touch "${MODULE_LOG}"
    trap common_cleanup EXIT
}

common_cleanup() {
    if [[ -n "${MODULE_TMP_DIR:-}" && -d "${MODULE_TMP_DIR}" ]]; then
        rm -rf "${MODULE_TMP_DIR}"
    fi
}

die() {
    print_error "$1"
    exit 1
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

bool_is_true() {
    [[ "${1:-false}" == "true" ]]
}

is_interactive_tty() {
    [[ -t 0 && -t 1 ]]
}

format_command() {
    local formatted=""
    local arg

    for arg in "$@"; do
        if [[ -n "${formatted}" ]]; then
            formatted+=" "
        fi
        printf -v arg '%q' "${arg}"
        formatted+="${arg}"
    done

    printf '%s\n' "${formatted}"
}

confirm_action() {
    local prompt="$1"
    local answer

    if bool_is_true "${DRY_RUN}"; then
        print_warning "Dry-run ativo: confirmação ignorada para '${prompt}'."
        return 0
    fi

    if bool_is_true "${ASSUME_YES}"; then
        return 0
    fi

    if ! is_interactive_tty; then
        die "Ação sensível requer confirmação interativa: ${prompt}"
    fi

    read -rp "${prompt} [s/N]: " answer
    [[ "${answer}" =~ ^[Ss]$ ]]
}

spinner() {
    local pid="$1"
    local delay=0.1
    local spinstr=$'|/-\\'

    while ps -p "${pid}" >/dev/null 2>&1; do
        local temp=${spinstr#?}
        printf " [%c]  " "${spinstr}"
        spinstr=${temp}${spinstr%"${temp}"}
        sleep "${delay}"
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

run_cmd() {
    local message="$1"
    shift
    local timeout_seconds="${RUN_CMD_TIMEOUT:-600}"
    local command_text

    command_text="$(format_command "$@")"

    local output_file="${MODULE_TMP_DIR}/last-command.log"
    print_step "${message}"

    if bool_is_true "${DRY_RUN}"; then
        echo "[dry-run] ${message}" >> "${MODULE_LOG}"
        echo "[dry-run] ${command_text}" >> "${MODULE_LOG}"
        print_info "[dry-run] ${command_text}"
        print_success "Simulado"
        return 0
    fi

    timeout "${timeout_seconds}" "$@" >"${output_file}" 2>&1 &
    local cmd_pid=$!
    spinner "${cmd_pid}"
    wait "${cmd_pid}"
    local exit_code=$?

    cat "${output_file}" >> "${MODULE_LOG}"

    if [[ "${exit_code}" -eq 0 ]]; then
        print_success "Concluído"
        return 0
    fi

    if [[ "${exit_code}" -eq 124 ]]; then
        print_error "Timeout ao executar: ${message}"
        return 1
    fi

    print_error "Falhou (código: ${exit_code})"
    if [[ -s "${output_file}" ]]; then
        echo -e "${YELLOW}Últimas linhas do erro:${NC}"
        tail -n 20 "${output_file}"
    fi
    return "${exit_code}"
}

require_root() {
    print_step "Verificando privilégios de root..."
    if [[ "${EUID}" -ne 0 ]]; then
        if bool_is_true "${DRY_RUN}"; then
            print_warning "Dry-run sem root: verificacao de privilégio relaxada para simulacao."
            return 0
        fi
        die "Este script precisa ser executado como root."
    fi
    print_success "Executando como root"
}

require_debian_13() {
    print_step "Detectando versão do sistema..."
    if [[ ! -f /etc/os-release ]]; then
        die "Nao foi possivel identificar o sistema operacional."
    fi

    # shellcheck disable=SC1091
    . /etc/os-release

    if [[ "${ID:-}" != "debian" ]]; then
        die "Projeto suportado apenas em Debian 13."
    fi

    if [[ "${VERSION_ID:-}" != "13" ]]; then
        die "Projeto suportado apenas em Debian 13 (Trixie)."
    fi

    print_success "Detectado Debian ${VERSION_ID}"
    print_info "Sistema: Debian ${VERSION_ID}"
}

get_virtualization_type() {
    if command_exists systemd-detect-virt; then
        systemd-detect-virt 2>/dev/null || true
        return 0
    fi

    if grep -sqE '(/lxc/|/lxd/)' /proc/1/cgroup 2>/dev/null; then
        echo "lxc"
        return 0
    fi

    tr '\0' '\n' </proc/1/environ 2>/dev/null | grep -E '^container=' | cut -d= -f2 || true
}

require_bare_metal() {
    local virt_type
    print_step "Verificando se o ambiente é bare metal..."
    virt_type="$(get_virtualization_type)"
    if [[ -n "${virt_type}" && "${virt_type}" != "none" ]]; then
        die "Este modulo foi desenhado para bare metal. Ambiente detectado: ${virt_type}."
    fi
    print_success "Ambiente bare metal confirmado"
}

mark_apt_sources_changed() {
    APT_UPDATED="false"
}

ensure_apt_updated() {
    if [[ "${APT_UPDATED:-false}" == "true" ]]; then
        return 0
    fi

    run_cmd "Atualizando lista de pacotes (apt update)" apt-get update
    APT_UPDATED="true"
}

install_packages() {
    if [[ "$#" -eq 0 ]]; then
        return 0
    fi

    ensure_apt_updated
    run_cmd "Instalando pacotes: $*" apt-get install -y --no-install-recommends "$@"
}

backup_file() {
    local source_file="$1"
    local backup_file="${source_file}.${RUN_TIMESTAMP}.bak"

    if bool_is_true "${DRY_RUN}"; then
        echo "[dry-run] backup ${source_file} -> ${backup_file}" >> "${MODULE_LOG}"
        printf '%s\n' "${backup_file}"
        return 0
    fi

    cp -a "${source_file}" "${backup_file}"
    printf '%s\n' "${backup_file}"
}

array_contains() {
    local needle="$1"
    shift
    local item
    for item in "$@"; do
        if [[ "${item}" == "${needle}" ]]; then
            return 0
        fi
    done
    return 1
}
