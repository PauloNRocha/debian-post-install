#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../lib/common.sh"

WITH_VSCODE="false"
WITH_DOCKER="false"

usage() {
    cat <<'EOF'
Uso:
  sudo ./scripts/05-development.sh
  sudo ./scripts/05-development.sh --with-vscode
  sudo ./scripts/05-development.sh --with-docker
  sudo ./scripts/05-development.sh --with-vscode --with-docker
EOF
}

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --with-vscode)
            WITH_VSCODE="true"
            ;;
        --with-docker)
            WITH_DOCKER="true"
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            die "Opcao invalida: $1"
            ;;
    esac
    shift
done

common_init "05-development"
show_banner "Instalador de Ferramentas de Desenvolvimento"

print_header "VERIFICAÇÃO DE PRÉ-REQUISITOS"
require_root
require_debian_13

DEBIAN_CODENAME="${VERSION_CODENAME:-trixie}"

print_info "Base padrao do modulo: pacotes do proprio Debian 13."
print_info "VS Code e Docker entram apenas por opt-in explicito."

declare -a development_packages=(
    build-essential
    curl
    git
    jq
    nodejs
    npm
    pipx
    python3-pip
    python3-venv
    shellcheck
    vim
    wget
)

print_header "Pacotes base selecionados"
printf ' - %s\n' "${development_packages[@]}"

install_packages "${development_packages[@]}"

if [[ "${WITH_VSCODE}" == "true" ]]; then
    print_header "VISUAL STUDIO CODE"
    if ! confirm_action "Adicionar o repositório oficial do VS Code e instalar o pacote?"; then
        die "Operação cancelada pelo usuário."
    fi

    install_packages gpg wget

    tmp_key="${MODULE_TMP_DIR}/microsoft.gpg"
    run_cmd "Baixando chave do VS Code" bash -lc "wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > '${tmp_key}'"
    install -D -o root -g root -m 0644 "${tmp_key}" /usr/share/keyrings/microsoft.gpg

    cat > /etc/apt/sources.list.d/vscode.sources <<'EOF'
Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64 arm64 armhf
Signed-By: /usr/share/keyrings/microsoft.gpg
EOF

    mark_apt_sources_changed
    install_packages code
fi

if [[ "${WITH_DOCKER}" == "true" ]]; then
    print_header "DOCKER"
    if [[ -n "$(get_virtualization_type)" ]]; then
        die "Docker nao e instalado automaticamente em container por este modulo."
    fi

    print_warning "O Docker altera o comportamento de rede e exige atencao especial com firewall."
    print_warning "A documentacao oficial recomenda revisar o impacto em iptables/DOCKER-USER antes de expor portas."
    if ! confirm_action "Adicionar o repositório oficial do Docker e instalar o Docker Engine?"; then
        die "Operação cancelada pelo usuário."
    fi

    install_packages ca-certificates curl
    run_cmd "Removendo pacotes Docker conflitantes" bash -lc "apt-get remove -y docker.io docker-compose docker-doc podman-docker containerd runc || true"
    install -m 0755 -d /etc/apt/keyrings
    run_cmd "Baixando chave oficial do Docker" curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc

    cat > /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: ${DEBIAN_CODENAME}
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

    mark_apt_sources_changed
    install_packages docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    if [[ -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
        run_cmd "Adicionando ${SUDO_USER} ao grupo docker" usermod -aG docker "${SUDO_USER}"
        print_warning "O usuario ${SUDO_USER} precisa encerrar a sessao e entrar novamente para usar o grupo docker."
    else
        print_warning "Nenhum usuario nao-root foi identificado via sudo. Adicione manualmente quem deve usar Docker."
    fi
fi

print_header "Concluido"
print_success "Modulo de desenvolvimento concluido."
print_info "Log salvo em ${MODULE_LOG}"
