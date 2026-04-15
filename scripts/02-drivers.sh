#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../lib/common.sh"

common_init "02-drivers"
show_banner "Instalador de Drivers e Firmwares"

print_header "VERIFICAÇÃO DE PRÉ-REQUISITOS"
require_root
require_debian_13
require_bare_metal

SOURCE_FILE="/etc/apt/sources.list.d/debian.sources"
CLASSIC_SOURCE_FILE="/etc/apt/sources.list"

if [[ -f "${SOURCE_FILE}" ]]; then
    if ! grep -Eq '^Components:.*contrib.*non-free.*non-free-firmware|^Components:.*contrib.*non-free-firmware.*non-free' "${SOURCE_FILE}"; then
        die "Repositorios non-free ainda nao estao ativos. Execute 01-repositories.sh antes deste modulo."
    fi
elif [[ -f "${CLASSIC_SOURCE_FILE}" ]]; then
    if ! grep -Eq '^deb .+ main contrib non-free non-free-firmware$' "${CLASSIC_SOURCE_FILE}"; then
        die "Repositorios non-free ainda nao estao ativos. Execute 01-repositories.sh antes deste modulo."
    fi
else
    die "Nenhum arquivo de fontes APT suportado foi encontrado. Execute 01-repositories.sh antes deste modulo."
fi

print_header "INSTALAÇÃO DE DRIVERS E FIRMWARES"
ensure_apt_updated
install_packages pciutils usbutils

PCI_OUTPUT="$(lspci -nn 2>/dev/null || true)"
USB_OUTPUT="$(lsusb 2>/dev/null || true)"
CPU_OUTPUT="$(lscpu 2>/dev/null || true)"
HARDWARE_OUTPUT="${PCI_OUTPUT}"$'\n'"${USB_OUTPUT}"$'\n'"${CPU_OUTPUT}"

declare -a packages=()
declare -a reasons=()

add_package() {
    local package="$1"
    local reason="$2"
    if ! array_contains "${package}" "${packages[@]:-}"; then
        packages+=("${package}")
        reasons+=("${package}: ${reason}")
    fi
}

if grep -qi 'NVIDIA' <<< "${PCI_OUTPUT}"; then
    add_package "nvidia-driver" "GPU NVIDIA detectada"
    add_package "firmware-misc-nonfree" "firmware complementar para GPUs NVIDIA"
fi

if grep -qiE 'VGA|3D controller|Display controller' <<< "${PCI_OUTPUT}" && grep -qiE 'AMD|ATI' <<< "${PCI_OUTPUT}"; then
    add_package "firmware-amd-graphics" "GPU AMD/ATI detectada"
    add_package "mesa-vulkan-drivers" "suporte Vulkan para GPU AMD/ATI"
fi

if grep -qiE 'VGA|3D controller|Display controller' <<< "${PCI_OUTPUT}" && grep -qi 'Intel' <<< "${PCI_OUTPUT}"; then
    add_package "firmware-intel-graphics" "GPU Intel detectada"
fi

if grep -qi 'GenuineIntel' <<< "${CPU_OUTPUT}" || grep -qi 'Intel' /proc/cpuinfo 2>/dev/null; then
    add_package "intel-microcode" "CPU Intel detectada"
fi

if grep -qi 'AuthenticAMD' <<< "${CPU_OUTPUT}" || grep -qi 'AMD' /proc/cpuinfo 2>/dev/null; then
    add_package "amd64-microcode" "CPU AMD detectada"
fi

if grep -qiE 'Intel.*Wireless|Wireless.*Intel|Wi-Fi 6|Wi-Fi 7|Centrino' <<< "${HARDWARE_OUTPUT}"; then
    add_package "firmware-iwlwifi" "controladora sem fio Intel detectada"
fi

if grep -qiE 'Realtek.*Wireless|Realtek.*RTL|RTL8|RTL9|802\.11.*Realtek' <<< "${HARDWARE_OUTPUT}"; then
    add_package "firmware-realtek" "controladora Realtek detectada"
fi

if grep -qiE 'Broadcom|BCM43|BCM44|BCM435|BCM436|Cypress' <<< "${HARDWARE_OUTPUT}"; then
    add_package "firmware-brcm80211" "controladora Broadcom/Cypress detectada"
fi

if grep -qiE 'Atheros|Qualcomm' <<< "${HARDWARE_OUTPUT}"; then
    add_package "firmware-atheros" "controladora Qualcomm Atheros detectada"
fi

if [[ "${#packages[@]}" -eq 0 ]]; then
    print_warning "Nenhum hardware suportado foi detectado automaticamente."
    print_info "Revise o log em ${MODULE_LOG} se quiser validar a deteccao."
    exit 0
fi

print_header "PACOTES SELECIONADOS"
printf ' - %s\n' "${reasons[@]}"

install_packages "${packages[@]}"

print_header "Concluido"
print_success "Drivers e firmware instalados."
print_warning "Reinicie o sistema para carregar microcode e firmware cedo no boot."
print_info "Log salvo em ${MODULE_LOG}"
