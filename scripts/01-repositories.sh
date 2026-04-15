#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"

common_init "01-repositories"
show_banner "Configurador de repositorios"

print_header "Validacao do ambiente"
require_root
require_debian_13

SOURCE_FILE="/etc/apt/sources.list.d/debian.sources"
TARGET_COMPONENTS="main contrib non-free non-free-firmware"

print_info "Debian 13 usa o formato deb822 como padrao."
print_info "Este modulo trabalha apenas com ${SOURCE_FILE}."

if [[ ! -f "${SOURCE_FILE}" ]]; then
    die "Arquivo ${SOURCE_FILE} nao encontrado. Converta suas fontes para deb822 e execute novamente."
fi

backup_path="$(backup_file "${SOURCE_FILE}")"
print_success "Backup salvo em ${backup_path}"

temporary_source="${MODULE_TMP_DIR}/debian.sources"

awk -v target="${TARGET_COMPONENTS}" '
    BEGIN { changed = 0 }
    /^Components:/ {
        print "Components: " target
        changed = 1
        next
    }
    { print }
    END {
        if (changed == 0) {
            exit 2
        }
    }
' "${SOURCE_FILE}" > "${temporary_source}" || die "Falha ao preparar a nova configuracao do debian.sources."

if cmp -s "${SOURCE_FILE}" "${temporary_source}"; then
    print_warning "Os componentes ja estavam configurados como: ${TARGET_COMPONENTS}"
else
    install -m 0644 "${temporary_source}" "${SOURCE_FILE}"
    print_success "Arquivo ${SOURCE_FILE} atualizado."
fi

if ! awk '
    /^Components:/ {
        if ($0 !~ /main/ || $0 !~ /contrib/ || $0 !~ /non-free/ || $0 !~ /non-free-firmware/) {
            bad = 1
        }
    }
    END { exit bad }
' "${SOURCE_FILE}"; then
    die "Validacao falhou. Revise ${SOURCE_FILE}."
fi

ensure_apt_updated

print_header "Concluido"
print_success "Repositorios Debian 13 ajustados para ${TARGET_COMPONENTS}."
print_info "Log salvo em ${MODULE_LOG}"
