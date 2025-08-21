# 🐧 Debian Post-Install

[![Debian](https://img.shields.io/badge/Debian-10%20|%2011%20|%2012%20|%2013-A81D33?style=for-the-badge&logo=debian&logoColor=white)](https://www.debian.org/)
[![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)](LICENSE)
[![Shell Script](https://img.shields.io/badge/Shell_Script-Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)

Script para automatizar a configuração pós-instalação do Debian, adicionando repositórios, instalando firmwares e drivers, instalando aplicações essenciais, com backup automático.

## 📋 Índice

- [Funcionalidades](#-funcionalidades)
- [Compatibilidade](#-compatibilidade)
- [Roadmap](#-roadmap)
- [Instalação](#-instalação)
- [Uso](#-uso)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [Como Funciona](#-como-funciona)
- [Requisitos](#-requisitos)
- [Contribuição](#-contribuição)
- [Problemas Conhecidos](#-problemas-conhecidos)
- [Recursos Úteis](#-recursos-úteis)
- [Licença](#-licença)
- [Autor](#-autor)

## ⚡ Funcionalidades

### 🔧 Disponível

- ✅ Configuração de repositórios `contrib` e `non-free`.
- ✅ Backup automático do `sources.list`.
- ✅ Interface colorida com indicadores de progresso.
- ✅ Detecção automática da versão do Debian.
- ✅ Validação de alterações aplicadas.

### 🚧 Em Desenvolvimento

- 🔄 Instalação automática de drivers gráficos e Wi-Fi.
- 🔄 Multimídia (codecs, players e ferramentas de áudio/vídeo).
- 🔄 Aplicações essenciais (Git, curl, vim, build-essential).
- 🔄 Desenvolvimento (VSCode, Node.js, Docker, IDEs).
- 🔄 Flatpak e aplicações Flatpak.

## 🖥️ Compatibilidade

| Versão | Codinome | Status | Testado |
|--------|----------|--------|---------|
| Debian 13 | Trixie | ✅ Suportado | ✅ |
| Debian 12 | Bookworm | ✅ Suportado | ✅ |
| Debian 11 | Bullseye | ✅ Suportado | ⏳ |
| Debian 10 | Buster | ✅ Suportado | ⏳ |

## 🛠️ Roadmap

| Feature                         | Status       | Observações                       |
| ------------------------------- | ------------ | --------------------------------- |
| Configuração de repositórios    | ✅ Completa   | Scripts testados e validados      |
| Backup automático               | ✅ Completo   | Inclui timestamp e restauração    |
| Drivers gráficos/Wi-Fi          | 🚧 Planejado | Suporte Intel/NVIDIA/AMD          |
| Multimídia e Codecs             | 🚧 Planejado | VLC, ffmpeg, codecs essenciais    |
| Aplicações essenciais           | 🚧 Planejado | Git, curl, vim, build-essential   |
| Ferramentas de desenvolvimento  | 🚧 Planejado | VSCode, Node.js, Docker, IDEs     |
| Flatpak e apps                  | 🚧 Planejado | Instalação e configuração padrão  |
| Modo silencioso (--quiet)       | 🚧 Planejado | Para automação em massa           |
| Forçar reconfiguração (--force) | 🚧 Planejado | Reaplica alterações já existentes |

## 🚀 Instalação

### Método 1: Clone Completo

```bash
git clone https://github.com/PauloNRocha/debian-post-install.git
cd debian-post-install
chmod +x scripts/*.sh
```

### Método 2: Download Direto

```bash
wget https://raw.githubusercontent.com/PauloNRocha/debian-post-install/main/scripts/01-repositories.sh
chmod +x 01-repositories.sh
```

### Método 3: Uma Linha

```bash
curl -fsSL https://raw.githubusercontent.com/PauloNRocha/debian-post-install/main/install.sh | bash
```

## 💻 Uso

### Script de Repositórios

```bash
sudo ./scripts/01-repositories.sh
```

### Script Completo (em breve)

```bash
sudo ./install.sh
```

### Opções em desenvolvimento

```bash
sudo ./install.sh --quiet      # Modo silencioso
sudo ./install.sh --force      # Reaplica alterações
./install.sh --help            # Ajuda
sudo ./install.sh --version    # Versão
```

## 📁 Estrutura do Projeto

```
debian-post-install/
├── 📄 README.md                 # Este arquivo
├── 📄 LICENSE                   # Licença MIT
├── 🚀 install.sh               # Script principal (em desenvolvimento)
├── 📂 scripts/
│   ├── 01-repositories.sh      # ✅ Configuração de repositórios
│   ├── 02-drivers.sh          # 🚧 Drivers de hardware
│   ├── 03-multimedia.sh       # 🚧 Codecs e multimídia
│   ├── 04-essential-apps.sh   # 🚧 Aplicações essenciais
│   ├── 05-development.sh      # 🚧 Ferramentas de desenvolvimento
│   ├── 06-flatpak.sh          # 🚧 Suporte a Flatpak
│   └── 07-scripts-futuros.sh    # 🚧 Novos scripts
├── 📂 configs/                # Arquivos de configuração
│   └── sources.list.template  # Template de repositórios
└── 📂 docs/                   # Documentação adicional
    ├── troubleshooting.md     # Solução de problemas
    └── Readme_EN.md          # Readme em inglês

## 🔧 Como Funciona

**Script de Repositórios**

1. Detecta a versão do Debian.
2. Verifica se contrib e non-free já estão presentes.
3. Cria backup automático do sources.list.
4. Aplica alterações apenas nas linhas deb.
5. Valida se os repositórios foram adicionados.
6. Executa apt update com feedback visual.

**Repositórios Configurados**
| Debian | Original                 | Resultado Final                           |
| ------ | ------------------------ | ----------------------------------------- |
| 10-11  | `main`                   | `main contrib non-free`                   |
| 12-13  | `main non-free-firmware` | `main contrib non-free non-free-firmware` |

## ⚠️ Requisitos

* Debian 10, 11, 12 ou 13
* Root ou sudo
* Conexão com a internet
* Terminal com suporte a cores UTF-8

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch (git checkout -b feature/NovaFuncionalidade)
3. Commit suas mudanças (git commit -m 'Adicionar nova funcionalidade')
4. Push para a branch (git push origin feature/NovaFuncionalidade)
5. Abra um Pull Request

**Diretrizes**

- Use Bash
- Teste em Debian 10-13
- Inclua cores e indicadores de progresso
- Documente todas as alterações

## 🐛 Problemas Conhecidos

* Ícones UTF-8 podem não aparecer em terminais antigos
* Timeout no apt update em conexões lentas

## 📚 Recursos Úteis

- [Documentação Debian](https://www.debian.org/doc/)
- [Debian Repository](https://wiki.debian.org/SourcesList)
- [Bash Scripting Guide](https://tldp.org/LDP/Bash-Beginners-Guide/html/)

## 📄 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## ✨ Autor

Desenvolvido por Paulo Rocha

---

**⭐ Se este projeto foi útil, considere dar uma estrela!**
