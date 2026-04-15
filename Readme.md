# Debian Post-Install

[In English](docs/Readme_EN.md)

Projeto para automatizar uma pos-instalacao enxuta e previsivel do Debian 13 (Trixie), com foco em desktop e workstation. O repositorio nao tenta mais cobrir Debian 10, 11 ou 12, e tambem nao promete um instalador "magico": cada modulo faz uma tarefa especifica, com escopo claro, log em disco e mensagens objetivas.

## Escopo atual

- Debian 13 apenas.
- Suporte a `deb822` e tambem ao `sources.list` classico quando ele ainda for o layout ativo.
- Execucao modular por script individual ou via `install.sh`.
- Logs persistentes em `/var/log/debian-post-install/`.

## Modulos disponiveis

- `01-repositories.sh`
  - Habilita `contrib`, `non-free` e `non-free-firmware` no layout APT ativo.
  - No layout classico, ajusta linhas `deb` e `deb-src`.
- `02-drivers.sh`
  - Detecta hardware e instala drivers e firmware para bare metal.
  - Nao deve ser usado em container.
- `03-multimedia.sh`
  - Instala codecs e ferramentas multimidia comuns.
- `04-essential-apps.sh`
  - Instala pacotes basicos de uso geral.
- `05-development.sh`
  - Instala base de desenvolvimento a partir dos repositorios do Debian.
  - Pode habilitar opcionalmente VS Code e Docker com flags explicitas.
- `06-flatpak.sh`
  - Instala Flatpak e adiciona Flathub.
  - Detecta integracao GNOME ou KDE quando fizer sentido.

## O que mudou nesta recuperacao

- O projeto foi limitado a Debian 13 para reduzir ramificacoes e suporte legado.
- O fluxo de repositorios foi modernizado para `deb822`, que e o caminho recomendado no Trixie.
- Foi criado um `install.sh` real para orquestrar os modulos.
- Os scripts passaram a compartilhar uma base comum em `lib/common.sh`.
- O README agora descreve apenas arquivos e fluxos que realmente existem.
- Foi criado um `CHANGELOG.md` para registrar a evolucao do projeto.

## Instalacao

```bash
git clone https://github.com/PauloNRocha/debian-post-install.git
cd debian-post-install
chmod 755 install.sh scripts/*.sh lib/common.sh
```

## Uso rapido

Executar apenas o ajuste de repositorios:

```bash
sudo ./scripts/01-repositories.sh
```

Preparar uma estacao de trabalho desktop sem Docker e sem drivers:

```bash
sudo ./install.sh --desktop
```

Adicionar a base de desenvolvimento usando apenas pacotes do Debian:

```bash
sudo ./install.sh --development
```

Adicionar VS Code ao modulo de desenvolvimento:

```bash
sudo ./install.sh --development --with-vscode
```

Adicionar Docker ao modulo de desenvolvimento:

```bash
sudo ./install.sh --development --with-docker
```

Executar tudo, incluindo drivers:

```bash
sudo ./install.sh --full --drivers
```

Listar os modulos suportados:

```bash
./install.sh --list
```

## Opcoes do install.sh

- `--repositories`
- `--drivers`
- `--multimedia`
- `--essential`
- `--development`
- `--flatpak`
- `--desktop`
  - Executa `repositories`, `essential`, `multimedia` e `flatpak`.
- `--full`
  - Executa `repositories`, `essential`, `multimedia`, `development` e `flatpak`.
- `--with-vscode`
  - Habilita o repositorio oficial do VS Code dentro do modulo de desenvolvimento.
- `--with-docker`
  - Habilita o repositorio oficial do Docker dentro do modulo de desenvolvimento.
- `--list`
- `--help`

## Estrutura do projeto

```text
debian-post-install/
|-- CHANGELOG.md
|-- CONTEXT.md
|-- CONTEXT_EN.md
|-- Readme.md
|-- docs/
|   `-- Readme_EN.md
|-- install.sh
|-- lib/
|   `-- common.sh
`-- scripts/
    |-- 01-repositories.sh
    |-- 02-drivers.sh
    |-- 03-multimedia.sh
    |-- 04-essential-apps.sh
    |-- 05-development.sh
    `-- 06-flatpak.sh
```

## Decisoes tecnicas

### Repositorios APT

O projeto prefere `/etc/apt/sources.list.d/debian.sources`, mas aceita tambem `/etc/apt/sources.list` quando o sistema Debian 13 ainda estiver nesse layout. Antes da pesquisa, a ideia era continuar editando apenas `sources.list` com `sed`. Depois da pesquisa nas referencias do Debian, o fluxo foi refeito para priorizar `deb822`, sem quebrar Debian 13 instalado com o formato classico. No formato classico, o modulo agora atualiza tanto `deb` quanto `deb-src`, e no `deb822` a validacao de `Components:` passou a usar tokens exatos.

### Desenvolvimento

Antes da pesquisa, o modulo de desenvolvimento seguia a ideia antiga de instalar Node.js via script remoto do NodeSource. Depois da pesquisa, a base padrao foi movida para os pacotes do proprio Debian 13, e os componentes de terceiros ficaram opcionais e explicitamente separados.

### Docker

O modulo de Docker segue o repositorio oficial do fornecedor. Isso foi mantido, mas com duas travas:

- instalacao somente quando a flag `--with-docker` e usada;
- aviso explicito sobre impacto em firewall, porque o proprio Docker documenta limitacoes com `nftables`.

## Limitacoes atuais

- `02-drivers.sh` foi pensado para bare metal. Em container e recusado.
- O menu interativo atual e textual. Ainda nao existe interface grafica dedicada.
- Ainda nao existe suite automatica de testes.

## Referencias tecnicas

- Debian Wiki - SourcesList: https://wiki.debian.org/SourcesList
- Debian manpage - `sources.list(5)`: https://manpages.debian.org/testing/apt/sources.list.5.en.html
- Docker - Install Docker Engine on Debian: https://docs.docker.com/engine/install/debian/
- Visual Studio Code on Linux: https://code.visualstudio.com/docs/setup/linux
- Flatpak Debian setup: https://flatpak.org/setup/Debian

## Changelog

Veja `CHANGELOG.md`.
