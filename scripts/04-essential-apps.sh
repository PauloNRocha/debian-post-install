#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"

common_init "04-essential-apps"
show_banner "Instalador de aplicacoes essenciais"

print_header "Validacao do ambiente"
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

print_header "Pacotes selecionados"
printf ' - %s\n' "${essential_packages[@]}"

install_packages "${essential_packages[@]}"

print_header "Concluido"
print_success "Pacotes essenciais instalados."
print_info "Log salvo em ${MODULE_LOG}"
