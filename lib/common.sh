#!/usr/bin/env bash

if [[ -n "${DEBIAN_POST_INSTALL_COMMON_LOADED:-}" ]]; then
    return 0
fi
DEBIAN_POST_INSTALL_COMMON_LOADED=1

PROJECT_ROOT="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_BASE_DIR="/var/log/debian-post-install"
TMP_BASE_DIR="/tmp/debian-post-install"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

print_success() { echo -e "${GREEN}[ok]${NC} $1"; }
print_error()   { echo -e "${RED}[erro]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[aviso]${NC} $1"; }
print_info()    { echo -e "${BLUE}[info]${NC} $1"; }
print_header()  { echo -e "\n${CYAN}${BOLD}== $1 ==${NC}\n"; }
print_step()    { echo -e "${BLUE}-->${NC} $1"; }

show_banner() {
    local title="$1"
    echo -e "${CYAN}${BOLD}"
    echo "============================================================"
    echo " Debian Post-Install"
    echo " ${title}"
    echo "============================================================"
    echo -e "${NC}"
}

common_init() {
    MODULE_NAME="$1"
    RUN_TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
    mkdir -p "${LOG_BASE_DIR}" "${TMP_BASE_DIR}"
    MODULE_TMP_DIR="$(mktemp -d "${TMP_BASE_DIR}/${MODULE_NAME}.XXXXXX")"
    MODULE_LOG="${LOG_BASE_DIR}/${RUN_TIMESTAMP}-${MODULE_NAME}.log"
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

run_cmd() {
    local message="$1"
    shift

    local output_file="${MODULE_TMP_DIR}/last-command.log"
    print_step "${message}"

    if "$@" >"${output_file}" 2>&1; then
        cat "${output_file}" >> "${MODULE_LOG}"
        print_success "${message}"
        return 0
    fi

    local exit_code=$?
    cat "${output_file}" >> "${MODULE_LOG}"
    print_error "${message}"
    if [[ -s "${output_file}" ]]; then
        echo -e "${YELLOW}Ultimas linhas:${NC}"
        tail -n 20 "${output_file}"
    fi
    return "${exit_code}"
}

require_root() {
    if [[ "${EUID}" -ne 0 ]]; then
        die "Este script precisa ser executado como root."
    fi
}

require_debian_13() {
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
    virt_type="$(get_virtualization_type)"
    if [[ -n "${virt_type}" && "${virt_type}" != "none" ]]; then
        die "Este modulo foi desenhado para bare metal. Ambiente detectado: ${virt_type}."
    fi
}

mark_apt_sources_changed() {
    APT_UPDATED="false"
}

ensure_apt_updated() {
    if [[ "${APT_UPDATED:-false}" == "true" ]]; then
        return 0
    fi

    run_cmd "Atualizando indice de pacotes" apt-get update
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
