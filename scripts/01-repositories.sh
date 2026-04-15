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

validate_deb822_components() {
    local file_path="$1"

    awk '
        function has_token(haystack, needle, token_count, tokens, idx) {
            token_count = split(haystack, tokens, /[[:space:]]+/)
            for (idx = 1; idx <= token_count; idx++) {
                if (tokens[idx] == needle) {
                    return 1
                }
            }
            return 0
        }

        /^Components:/ {
            components = $0
            sub(/^Components:[[:space:]]*/, "", components)
            lines++
            if (!has_token(components, "main") ||
                !has_token(components, "contrib") ||
                !has_token(components, "non-free") ||
                !has_token(components, "non-free-firmware")) {
                bad = 1
            }
        }

        END {
            exit(lines == 0 || bad)
        }
    ' "${file_path}"
}

rewrite_classic_sources() {
    local source_file="$1"
    local target_file="$2"

    awk -v target="${TARGET_COMPONENTS}" '
        function rebuild(line, rest, type, options, uri, suite, prefix) {
            rest = line
            sub(/^[[:space:]]+/, "", rest)

            if (rest ~ /^deb-src([[:space:]]|$)/) {
                type = "deb-src"
                sub(/^deb-src[[:space:]]+/, "", rest)
            } else if (rest ~ /^deb([[:space:]]|$)/) {
                type = "deb"
                sub(/^deb[[:space:]]+/, "", rest)
            } else {
                return line
            }

            options = ""
            if (rest ~ /^\[[^]]+\][[:space:]]+/) {
                match(rest, /^\[[^]]+\]/)
                options = substr(rest, RSTART, RLENGTH)
                rest = substr(rest, RLENGTH + 1)
                sub(/^[[:space:]]+/, "", rest)
            }

            if (match(rest, /^[^[:space:]]+/) == 0) {
                return "__PARSE_ERROR__"
            }
            uri = substr(rest, RSTART, RLENGTH)
            rest = substr(rest, RLENGTH + 1)
            sub(/^[[:space:]]+/, "", rest)

            if (match(rest, /^[^[:space:]]+/) == 0) {
                return "__PARSE_ERROR__"
            }
            suite = substr(rest, RSTART, RLENGTH)

            prefix = type
            if (options != "") {
                prefix = prefix " " options
            }

            return prefix " " uri " " suite " " target
        }

        /^[[:space:]]*deb(-src)?([[:space:]]|$)/ {
            rebuilt = rebuild($0)
            if (rebuilt == "__PARSE_ERROR__") {
                parse_error = 1
                print $0
                next
            }
            print rebuilt
            changed = 1
            next
        }

        { print }

        END {
            if (parse_error || changed == 0) {
                exit 2
            }
        }
    ' "${source_file}" > "${target_file}"
}

validate_classic_sources() {
    local file_path="$1"

    awk '
        /^[[:space:]]*deb(-src)?([[:space:]]|$)/ {
            lines++
            if ($0 !~ /^[[:space:]]*deb(-src)?([[:space:]]+\[[^]]+\])?[[:space:]]+[^[:space:]]+[[:space:]]+[^[:space:]]+[[:space:]]+main contrib non-free non-free-firmware[[:space:]]*$/) {
                bad = 1
            }
        }

        END {
            exit(lines == 0 || bad)
        }
    ' "${file_path}"
}

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

    if ! validate_deb822_components "${temporary_source}"; then
        die "Validacao falhou ao preparar ${SOURCE_FILE}."
    fi
else
    rewrite_classic_sources "${SOURCE_FILE}" "${temporary_source}" || die "Falha ao preparar a nova configuracao do sources.list."

    if ! validate_classic_sources "${temporary_source}"; then
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
