# Debian Post-Install

[Em portugues](../Readme.md)

This repository provides a Debian 13 post-install toolkit focused on desktop and workstation use. The project was recovered and narrowed on purpose: Debian 13 only, `deb822` only, and explicit module boundaries.

## Available modules

- `01-repositories.sh`
  - Enables `contrib`, `non-free`, and `non-free-firmware` in `debian.sources`.
- `02-drivers.sh`
  - Hardware detection and firmware installation for bare metal only.
- `03-multimedia.sh`
  - Multimedia tools and codecs.
- `04-essential-apps.sh`
  - General-purpose baseline packages.
- `05-development.sh`
  - Development baseline from Debian repositories, with optional VS Code and Docker support.
- `06-flatpak.sh`
  - Flatpak, Flathub, and optional desktop-store integration.

## Quick start

```bash
git clone https://github.com/PauloNRocha/debian-post-install.git
cd debian-post-install
chmod 755 install.sh scripts/*.sh lib/common.sh
```

Desktop workstation baseline:

```bash
sudo ./install.sh --desktop
```

Development baseline:

```bash
sudo ./install.sh --development
```

Development baseline with VS Code:

```bash
sudo ./install.sh --development --with-vscode
```

Development baseline with Docker:

```bash
sudo ./install.sh --development --with-docker
```

Full run including drivers:

```bash
sudo ./install.sh --full --drivers
```

## Notes

- Driver installation is intended for bare metal and is blocked in containers.
- Docker setup is opt-in because it changes networking behavior and adds an external repository.
- The project now uses `CHANGELOG.md` to record relevant changes.

## Technical references

- Debian Wiki - SourcesList: https://wiki.debian.org/SourcesList
- `sources.list(5)` manpage: https://manpages.debian.org/testing/apt/sources.list.5.en.html
- Docker on Debian: https://docs.docker.com/engine/install/debian/
- VS Code on Linux: https://code.visualstudio.com/docs/setup/linux
- Flatpak Debian setup: https://flatpak.org/setup/Debian
