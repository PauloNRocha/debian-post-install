# Contexto do Projeto - Debian Post Install

## 🎯 Objetivo
Este projeto tem como objetivo simplificar a configuração inicial de sistemas Debian 10+ após a instalação, automatizando tarefas repetitivas e oferecendo suporte a drivers, firmwares e pacotes essenciais.

A ideia é fornecer uma ferramenta leve, prática e segura, que ajude usuários a deixarem o sistema pronto para uso no dia a dia sem complicações.

---

## 🛠 Escopo Atual
- Instalação de **drivers e firmwares** mais comuns (Intel, AMD, NVIDIA, Wi-Fi, placas de rede).
- Inclusão de **pacotes básicos** pós-instalação.
- Compatibilidade inicial focada no **Debian 12 Bookworm** (com possibilidade de expansão para futuras versões).

---

## 📚 Diferenciais
- Script simples e de fácil manutenção (shell script).
- Documentação em múltiplos idiomas, português e inglês.
- Estrutura do repositório pensada para crescer de forma organizada.
- Transparência: não automatiza nada crítico sem aviso ao usuário.

---

## 🚧 Possíveis Evoluções (Roadmap)
- [ ] Adicionar **opções de execução** (`--nvidia`, `--amd`, `--firmware`, `--full`).
- [ ] Detectar automaticamente o hardware antes de instalar pacotes.
- [ ] Adicionar **logs** em `/var/log/debian-post-install.log`.
- [ ] Incluir um menu interativo simples (ex: `whiptail`).
- [ ] Adicionar suporte a **codecs multimídia**.
- [ ] Oferecer instalação opcional de **Flatpak e Flathub**.
- [ ] Suporte a **CUDA (NVIDIA)** para ambientes de computação.
- [ ] Expansão para Debian Testing e futuras versões estáveis.

---

## 👥 Público-Alvo
- Usuários de Debian que querem acelerar a configuração inicial.
- Pessoas que acabaram de instalar o sistema e precisam de drivers/firmwares.
- Quem busca um sistema pronto para uso básico sem ter que caçar pacotes manualmente.

---

## 📂 Estrutura Proposta
```
debian-post-install/
├── 📄 README.md                    # Este arquivo
├── 📄 CONTEXT.md                   # Este arquivo de contexto para IA e contribuidores
├── 📄 LICENSE                      # Licença MIT
├── 🚀 install.sh                   # Script principal
├── 📂 scripts/
│   ├── 01-repositories.sh           # ✅ Configuração de repositórios
│   ├── 02-drivers.sh                # ✅ Drivers de hardware
│   ├── 03-multimedia.sh             # ✅ Codecs e multimídia
│   ├── 04-essential-apps.sh         # ✅ Aplicações essenciais
│   ├── 05-development.sh            # ✅ Ferramentas de desenvolvimento
│   ├── 06-flatpak.sh                # ✅ Suporte a Flatpak
├── 📂 configs/                     # Arquivos de configuração (se necessário)
└── 📂 docs/                        # Documentação adicional
    ├── Readme_EN.md                 # Readme em inglês
    ├── 01-repositories.md           # Configuração de repositórios
    ├── 01-repositories_EN.md        # Configuração de repositórios (inglês)
    ├── 02-drivers.md                # Drivers de hardware
    ├── 02-drivers_EN.md             # Drivers de hardware (inglês)
    ├── 03-multimedia.md             # Codecs e multimídia
    ├── 03-multimedia_EN.md          # Codecs e multimídia (inglês)
    ├── 04-essential-apps.md         # Aplicações essenciais
    ├── 04-essential-apps_EN.md      # Aplicações essenciais (inglês)
    ├── 05-development.md            # Ferramentas de desenvolvimento
    ├── 05-development_EN.md         # Ferramentas de desenvolvimento (inglês)
    ├── 06-flatpak.md                # Suporte a Flatpak
    ├── 06-flatpak_EN.md             # Suporte a Flatpak (inglês)

---

## 🧩 Inspirações
- Experiência prática com instalações reais de Debian em diferentes hardwares.

---

## 🔒 Filosofia do Projeto
- **Clareza**: tudo bem documentado, sem “mágica oculta”.  
- **Controle**: usuário decide o que instalar.  
- **Segurança**: nada invasivo sem confirmação.  
- **Flexibilidade**: fácil de adaptar e expandir.  
