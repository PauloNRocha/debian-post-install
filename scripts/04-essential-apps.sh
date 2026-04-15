#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../lib/common.sh"

common_init "04-essential-apps"
show_banner "Instalador de Aplicações Essenciais"

print_header "VERIFICAÇÃO DE PRÉ-REQUISITOS"
require_root
require_debian_13

declare -a essential_packages=(
    bash-completion
    build-essential
    ca-certificates
    curl
    git
    htop
    jq
    tree
    unzip
    vim
    wget
    zip
)

print_header "INSTALAÇÃO DE APLICAÇÕES ESSENCIAIS"
print_info "Pacotes a serem instalados:"
printf ' - %s\n' "${essential_packages[@]}"

install_packages "${essential_packages[@]}"

print_header "Concluido"
print_success "Pacotes essenciais instalados."
print_info "Log salvo em ${MODULE_LOG}"
