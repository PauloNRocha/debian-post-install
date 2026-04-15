#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../lib/common.sh"

common_init "06-flatpak"
show_banner "Instalador de Flatpak"

print_header "VERIFICAÇÃO DE PRÉ-REQUISITOS"
require_root
require_debian_13

declare -a flatpak_packages=(flatpak)

if dpkg-query -W -f='${Status}' gnome-software 2>/dev/null | grep -q "ok installed"; then
    flatpak_packages+=(gnome-software-plugin-flatpak)
    print_info "GNOME Software detectado. Plugin Flatpak sera instalado."
elif dpkg-query -W -f='${Status}' plasma-discover 2>/dev/null | grep -q "ok installed"; then
    flatpak_packages+=(plasma-discover-backend-flatpak)
    print_info "Plasma Discover detectado. Backend Flatpak sera instalado."
else
    print_warning "Nenhuma loja grafica suportada foi detectada. Apenas o Flatpak base sera instalado."
fi

print_header "INSTALAÇÃO E CONFIGURAÇÃO DO FLATPAK"
print_info "Pacotes a serem instalados:"
printf ' - %s\n' "${flatpak_packages[@]}"

install_packages "${flatpak_packages[@]}"
run_cmd "Adicionando repositorio Flathub" flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

print_header "Concluido"
print_success "Flatpak configurado."
print_warning "Reinicie a sessao grafica para integrar a loja de aplicativos, se aplicavel."
print_info "Log salvo em ${MODULE_LOG}"
