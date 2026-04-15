#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"

common_init "03-multimedia"
show_banner "Instalador de multimidia"

print_header "Validacao do ambiente"
require_root
require_debian_13

declare -a multimedia_packages=(
    ffmpeg
    gstreamer1.0-libav
    gstreamer1.0-plugins-bad
    gstreamer1.0-plugins-base
    gstreamer1.0-plugins-good
    gstreamer1.0-plugins-ugly
    lame
    libavcodec-extra
    vlc
)

print_header "Pacotes selecionados"
printf ' - %s\n' "${multimedia_packages[@]}"

install_packages "${multimedia_packages[@]}"

print_header "Concluido"
print_success "Pacotes multimidia instalados."
print_info "Log salvo em ${MODULE_LOG}"
