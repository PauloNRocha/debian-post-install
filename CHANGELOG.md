# Changelog

## 2026-04-15

### Adicionado

- `CHANGELOG.md` para registrar a evolucao do projeto.
- `install.sh` para orquestrar os modulos.
- `lib/common.sh` com funcoes compartilhadas, logs e validacoes comuns.

### Alterado

- Escopo travado em Debian 13 (Trixie).
- `01-repositories.sh` refeito para trabalhar com `deb822`.
- `02-drivers.sh` refeito para bare metal, com deteccao de virtualizacao.
- `03-multimedia.sh`, `04-essential-apps.sh` e `06-flatpak.sh` movidos para a base comum.
- `05-development.sh` modernizado, com base segura via pacotes do Debian e opcoes explicitas para VS Code e Docker.
- README e arquivos de contexto atualizados para refletir apenas o que realmente existe.
- Layout dos scripts padronizado novamente para o estilo visual classico do projeto.
- `install.sh` alterado para menu interativo com selecao por numeros.
- Menu principal enriquecido com descricoes curtas por opcao.
- Todos os scripts revisados com `shellcheck`.
- `01-repositories.sh` e `02-drivers.sh` ajustados para aceitar Debian 13 com `deb822` e tambem com `sources.list` classico.
- `05-development.sh` corrigido para carregar `common.sh` antes do parser de argumentos.
- Fluxo `--with-docker` corrigido no `05-development.sh`, sem depender do bloco do VS Code.
- Dependencia legada `apt-transport-https` removida do fluxo do VS Code.
- README principal e README em ingles ajustados para refletir o menu interativo textual.
- `01-repositories.sh` endurecido para validar `Components:` por tokens exatos no `deb822`.
- `01-repositories.sh` ajustado para reescrever linhas `deb` e `deb-src` no layout classico.
- `install.sh` ganhou suporte a `--dry-run` e resumo final mais informativo.
- `01-repositories.sh`, `02-drivers.sh` e `05-development.sh` passaram a pedir confirmacao explicita em operacoes sensiveis.

### Removido

- Documentacao que prometia `install.sh`, `LICENSE`, `configs/` e guias que nao existiam.
- Declaracoes de suporte para Debian 10, 11 e 12.
- Fluxos legados baseados em `sources.list` tradicional como caminho principal do projeto.
