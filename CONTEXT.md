# Contexto do Projeto - Debian Post-Install

## Objetivo

Recuperar e manter um conjunto pequeno de scripts para pos-instalacao do Debian 13, com foco em:

- desktop;
- workstation;
- ambiente de desenvolvimento;
- configuracao previsivel e auditavel.

O projeto nao tenta mais ser um "instalador universal". Cada modulo precisa ter um escopo claro, uma justificativa tecnica e um comportamento seguro para automacao.

## Escopo atual

- Debian 13 apenas.
- APT com prioridade para `deb822`, mas com compatibilidade tambem para `sources.list` classico em Debian 13.
- Scripts modulares com logs persistentes.
- Base comum em `lib/common.sh`.
- Instalador principal em `install.sh`.

## Filosofia

- Clareza: nada de passos escondidos ou promessas infladas no README.
- Estabilidade: preferir pacotes do Debian sempre que isso fizer sentido.
- Seguranca: repositorios de terceiros so entram por opt-in explicito.
- Honestidade operacional: nao executar rotina de drivers em container, nao vender "suporte" onde ele nao existe.

## Diretrizes de manutencao

- Nao reintroduzir suporte a Debian antigo sem necessidade real.
- Nao usar `curl | bash` como fluxo padrao de instalacao.
- Nao adicionar repositorios externos sem documentar risco, origem e motivacao.
- Nao afirmar compatibilidade sem testar o caminho principal.
- Nao duplicar boilerplate entre scripts quando a base comum puder resolver.

## Modulos

- `01-repositories.sh`
  - Ajuste de `debian.sources`.
- `02-drivers.sh`
  - Bare metal apenas.
- `03-multimedia.sh`
  - Codecs e players.
- `04-essential-apps.sh`
  - Pacotes de uso geral.
- `05-development.sh`
  - Base de desenvolvimento + opcoes externas explicitas.
- `06-flatpak.sh`
  - Flatpak + Flathub + integracao opcional com loja grafica.

## Melhorias futuras possiveis

- Suite de testes em VM Debian 13.
- `shellcheck` no CI.
- Perfis de instalacao por tipo de maquina.
- Modo `--yes` controlado e bem documentado.
- Relatorio final consolidado apos `install.sh`.
