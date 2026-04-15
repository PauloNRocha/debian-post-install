#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${ROOT_DIR}/lib/common.sh"

declare -a modules=()
declare -a development_args=()

usage() {
    cat <<'EOF'
Uso:
  ./install.sh
  ./install.sh --list
  sudo ./install.sh --repositories
  sudo ./install.sh --desktop
  sudo ./install.sh --development --with-vscode
  sudo ./install.sh --full --drivers --with-docker

Modulos:
  --repositories
  --drivers
  --multimedia
  --essential
  --development
  --flatpak

Perfis:
  --desktop
  --full

Opcoes auxiliares:
  --with-vscode
  --with-docker
  --list
  --help
EOF
}

list_modules() {
    echo "Módulos suportados:"
    echo "  1. repositories  -> scripts/01-repositories.sh"
    echo "  2. drivers       -> scripts/02-drivers.sh"
    echo "  3. multimedia    -> scripts/03-multimedia.sh"
    echo "  4. essential     -> scripts/04-essential-apps.sh"
    echo "  5. development   -> scripts/05-development.sh"
    echo "  6. flatpak       -> scripts/06-flatpak.sh"
}

add_module() {
    local module="$1"
    local existing
    for existing in "${modules[@]:-}"; do
        if [[ "${existing}" == "${module}" ]]; then
            return 0
        fi
    done
    modules+=("${module}")
}

ask_yes_no() {
    local prompt="$1"
    local default_answer="${2:-n}"
    local answer

    if [[ "${default_answer}" == "s" ]]; then
        read -rp "${prompt} [S/n]: " answer
        [[ -z "${answer}" || "${answer}" =~ ^[Ss]$ ]]
        return
    fi

    read -rp "${prompt} [s/N]: " answer
    [[ "${answer}" =~ ^[Ss]$ ]]
}

configure_development_options() {
    print_header "OPÇÕES DO MÓDULO DE DESENVOLVIMENTO"

    if ask_yes_no "Adicionar VS Code oficial?" "n"; then
        if ! array_contains "--with-vscode" "${development_args[@]:-}"; then
            development_args+=("--with-vscode")
        fi
    fi

    if ask_yes_no "Adicionar Docker oficial?" "n"; then
        if ! array_contains "--with-docker" "${development_args[@]:-}"; then
            development_args+=("--with-docker")
        fi
    fi
}

configure_full_profile() {
    add_module "01-repositories.sh"
    add_module "04-essential-apps.sh"
    add_module "03-multimedia.sh"
    add_module "05-development.sh"
    add_module "06-flatpak.sh"

    if ask_yes_no "Incluir drivers e firmware no perfil completo?" "n"; then
        add_module "02-drivers.sh"
    fi

    if ask_yes_no "Deseja configurar opções extras do módulo de desenvolvimento?" "n"; then
        configure_development_options
    fi
}

interactive_menu() {
    local choice

    while true; do
        show_banner "Instalador Principal"
        print_header "MENU PRINCIPAL"
        echo " [ 1 ] Configurar repositórios"
        echo "       Ajusta o debian.sources para habilitar contrib, non-free e non-free-firmware."
        echo " [ 2 ] Instalar drivers e firmware"
        echo "       Detecta hardware em bare metal e instala firmware grafico, Wi-Fi e microcode."
        echo " [ 3 ] Instalar multimídia"
        echo "       Instala codecs, VLC, FFmpeg e plugins GStreamer."
        echo " [ 4 ] Instalar aplicações essenciais"
        echo "       Instala a base utilitaria do sistema, como git, curl, jq, vim e htop."
        echo " [ 5 ] Instalar ferramentas de desenvolvimento"
        echo "       Instala toolchain do Debian e pode adicionar VS Code e Docker opcionalmente."
        echo " [ 6 ] Instalar Flatpak"
        echo "       Instala Flatpak, adiciona Flathub e integra com a loja grafica quando existir."
        echo " [ 7 ] Perfil desktop"
        echo "       Executa repositórios, essenciais, multimídia e Flatpak."
        echo " [ 8 ] Perfil completo"
        echo "       Executa o perfil mais amplo e permite incluir drivers e extras de desenvolvimento."
        echo " [ 9 ] Listar módulos suportados"
        echo "       Exibe o mapeamento entre opcoes e scripts."
        echo " [ 0 ] Sair"
        echo
        read -rp "Sua escolha: " choice

        modules=()
        development_args=()

        case "${choice}" in
            1)
                add_module "01-repositories.sh"
                return 0
                ;;
            2)
                add_module "02-drivers.sh"
                return 0
                ;;
            3)
                add_module "03-multimedia.sh"
                return 0
                ;;
            4)
                add_module "04-essential-apps.sh"
                return 0
                ;;
            5)
                add_module "05-development.sh"
                configure_development_options
                return 0
                ;;
            6)
                add_module "06-flatpak.sh"
                return 0
                ;;
            7)
                add_module "01-repositories.sh"
                add_module "04-essential-apps.sh"
                add_module "03-multimedia.sh"
                add_module "06-flatpak.sh"
                return 0
                ;;
            8)
                configure_full_profile
                return 0
                ;;
            9)
                print_header "MÓDULOS SUPORTADOS"
                list_modules
                echo
                read -rp "Pressione Enter para voltar ao menu..."
                ;;
            0)
                echo "Saindo."
                exit 0
                ;;
            *)
                print_error "Opção inválida."
                sleep 1
                ;;
        esac
    done
}

run_module() {
    local module="$1"
    shift
    local script_path="${ROOT_DIR}/scripts/${module}"

    print_header "EXECUTANDO ${module}"
    bash "${script_path}" "$@"
}

parse_args() {
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --repositories)
                add_module "01-repositories.sh"
                ;;
            --drivers)
                add_module "02-drivers.sh"
                ;;
            --multimedia)
                add_module "03-multimedia.sh"
                ;;
            --essential)
                add_module "04-essential-apps.sh"
                ;;
            --development)
                add_module "05-development.sh"
                ;;
            --flatpak)
                add_module "06-flatpak.sh"
                ;;
            --desktop)
                add_module "01-repositories.sh"
                add_module "04-essential-apps.sh"
                add_module "03-multimedia.sh"
                add_module "06-flatpak.sh"
                ;;
            --full)
                add_module "01-repositories.sh"
                add_module "04-essential-apps.sh"
                add_module "03-multimedia.sh"
                add_module "05-development.sh"
                add_module "06-flatpak.sh"
                ;;
            --with-vscode)
                add_module "05-development.sh"
                development_args+=("--with-vscode")
                ;;
            --with-docker)
                add_module "05-development.sh"
                development_args+=("--with-docker")
                ;;
            --list)
                list_modules
                exit 0
                ;;
            --help|-h)
                usage
                exit 0
                ;;
            *)
                print_error "Opção inválida: $1"
                usage
                exit 1
                ;;
        esac
        shift
    done
}

if [[ "$#" -eq 0 ]]; then
    interactive_menu
else
    parse_args "$@"
fi

if [[ "${#modules[@]}" -eq 0 ]]; then
    usage
    exit 1
fi

common_init "install"
show_banner "Instalador Principal"
print_header "RESUMO DA EXECUÇÃO"
require_root
require_debian_13

echo "Módulos selecionados:"
printf ' - %s\n' "${modules[@]}"
if [[ "${#development_args[@]}" -gt 0 ]]; then
    echo "Opções extras do módulo de desenvolvimento:"
    printf ' - %s\n' "${development_args[@]}"
fi
echo

for module in "${modules[@]}"; do
    if [[ "${module}" == "05-development.sh" ]]; then
        run_module "${module}" "${development_args[@]}"
    else
        run_module "${module}"
    fi
done

print_header "EXECUÇÃO CONCLUÍDA"
print_success "Todos os módulos selecionados foram processados."
