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

### Removido

- Documentacao que prometia `install.sh`, `LICENSE`, `configs/` e guias que nao existiam.
- Declaracoes de suporte para Debian 10, 11 e 12.
- Fluxos legados baseados em `sources.list` tradicional como caminho principal do projeto.
