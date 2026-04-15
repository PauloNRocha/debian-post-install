#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../lib/common.sh"

common_init "01-repositories"
show_banner "Configurador de Repositórios"

if [[ "${EUID}" -ne 0 ]]; then
    print_error "Este script precisa ser executado como root."
    exit 1
fi

require_debian_13

TARGET_COMPONENTS="main contrib non-free non-free-firmware"
DEB822_SOURCE_FILE="/etc/apt/sources.list.d/debian.sources"
CLASSIC_SOURCE_FILE="/etc/apt/sources.list"

print_info "Este modulo suporta Debian 13 com deb822 ou sources.list classico."

if [[ -f "${DEB822_SOURCE_FILE}" ]]; then
    SOURCE_LAYOUT="deb822"
    SOURCE_FILE="${DEB822_SOURCE_FILE}"
    print_info "Layout detectado: deb822 (${SOURCE_FILE})"
elif [[ -f "${CLASSIC_SOURCE_FILE}" ]]; then
    SOURCE_LAYOUT="classic"
    SOURCE_FILE="${CLASSIC_SOURCE_FILE}"
    print_info "Layout detectado: sources.list classico (${SOURCE_FILE})"
else
    die "Nenhum arquivo de fontes APT suportado foi encontrado."
fi

backup_path="$(backup_file "${SOURCE_FILE}")"
print_success "Backup salvo em ${backup_path}"

print_header "CONFIGURAÇÃO DE REPOSITÓRIOS"

temporary_source="${MODULE_TMP_DIR}/apt-sources.updated"

if [[ "${SOURCE_LAYOUT}" == "deb822" ]]; then
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

    if ! awk '
        /^Components:/ {
            if ($0 !~ /main/ || $0 !~ /contrib/ || $0 !~ /non-free/ || $0 !~ /non-free-firmware/) {
                bad = 1
            }
        }
        END { exit bad }
    ' "${temporary_source}"; then
        die "Validacao falhou ao preparar ${SOURCE_FILE}."
    fi
else
    awk '
        /^deb([[:space:]]|$)/ {
            line=$0
            split(line, fields, /[[:space:]]+/)
            prefix=""
            for (i = 1; i <= 3 && i <= length(fields); i++) {
                prefix = prefix fields[i]
                if (i < 3) {
                    prefix = prefix " "
                }
            }
            print prefix " main contrib non-free non-free-firmware"
            next
        }
        { print }
    ' "${SOURCE_FILE}" > "${temporary_source}" || die "Falha ao preparar a nova configuracao do sources.list."

    if ! grep -Eq '^deb .+ main contrib non-free non-free-firmware$' "${temporary_source}"; then
        die "Validacao falhou ao preparar ${SOURCE_FILE}."
    fi
fi

if cmp -s "${SOURCE_FILE}" "${temporary_source}"; then
    print_warning "Os componentes ja estavam configurados como: ${TARGET_COMPONENTS}"
else
    install -m 0644 "${temporary_source}" "${SOURCE_FILE}"
    print_success "Arquivo ${SOURCE_FILE} atualizado."
fi

ensure_apt_updated

print_header "Concluido"
print_success "Repositorios Debian 13 ajustados para ${TARGET_COMPONENTS}."
print_info "Log salvo em ${MODULE_LOG}"
