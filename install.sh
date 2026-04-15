#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
    cat <<'EOF'
Uso:
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
  --desktop    repositories + essential + multimedia + flatpak
  --full       repositories + essential + multimedia + development + flatpak

Flags auxiliares:
  --with-vscode  ativa VS Code dentro do modulo development
  --with-docker  ativa Docker dentro do modulo development
  --list         mostra os modulos suportados
  --help         mostra esta ajuda
EOF
}

list_modules() {
    cat <<'EOF'
Modulos suportados:
  repositories  -> scripts/01-repositories.sh
  drivers       -> scripts/02-drivers.sh
  multimedia    -> scripts/03-multimedia.sh
  essential     -> scripts/04-essential-apps.sh
  development   -> scripts/05-development.sh
  flatpak       -> scripts/06-flatpak.sh
EOF
}

declare -a modules=()
declare -a development_args=()

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

run_module() {
    local module="$1"
    shift
    local script_path="${ROOT_DIR}/scripts/${module}"

    echo
    echo ">>> Executando ${module}"
    bash "${script_path}" "$@"
}

if [[ "$#" -eq 0 ]]; then
    usage
    exit 1
fi

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
            echo "Opcao invalida: $1" >&2
            usage
            exit 1
            ;;
    esac
    shift
done

if [[ "${#modules[@]}" -eq 0 ]]; then
    usage
    exit 1
fi

for module in "${modules[@]}"; do
    if [[ "${module}" == "05-development.sh" ]]; then
        run_module "${module}" "${development_args[@]}"
    else
        run_module "${module}"
    fi
done

echo
echo "Execucao concluida."
