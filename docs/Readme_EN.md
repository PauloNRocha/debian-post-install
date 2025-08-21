# 🐧 Debian Post-Install (English)

[![Debian](https://img.shields.io/badge/Debian-10%20|%2011%20|%2012%20|%2013-A81D33?style=for-the-badge&logo=debian&logoColor=white)](https://www.debian.org/)
[![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)](LICENSE)
[![Shell Script](https://img.shields.io/badge/Shell_Script-Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)

A script to automate Debian's post-installation setup, adding repositories, installing firmware and drivers, and setting up essential applications, with automatic backups.

## 📋 Table of Contents

- [Features](#features)
- [Compatibility](#compatibility)
- [Roadmap](#roadmap)
- [Installation](#installation)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [How It Works](#how-it-works)
- [Requirements](#requirements)
- [Contributing](#contributing)
- [Known Issues](#known-issues)
- [Useful Resources](#useful-resources)
- [License](#license)
- [Author](#author)

## ⚡ Features

### 🔧 Available

- ✅ `contrib` and `non-free` repository setup.
- ✅ Automatic backup of `sources.list`.
- ✅ Colorful interface with progress indicators.
- ✅ Automatic detection of the Debian version.
- ✅ Validation of applied changes.

### 🚧 In Development

- 🔄 Automatic installation of graphics and Wi-Fi drivers.
- 🔄 Multimedia (codecs, players, and audio/video tools).
- 🔄 Essential applications (Git, curl, vim, build-essential).
- 🔄 Development tools (VSCode, Node.js, Docker, IDEs).
- 🔄 Flatpak and Flatpak applications.

## 🖥️ Compatibility

| Version   | Codename | Status      | Tested |
| --------- | -------- | ----------- | ------ |
| Debian 13 | Trixie   | ✅ Supported | ✅      |
| Debian 12 | Bookworm | ✅ Supported | ✅      |
| Debian 11 | Bullseye | ✅ Supported | ⏳      |
| Debian 10 | Buster   | ✅ Supported | ⏳      |

## 🛠️ Roadmap

| Feature                         | Status      | Notes                             |
| ------------------------------- | ----------- | --------------------------------- |
| Repository Configuration        | ✅ Complete | Scripts tested and validated      |
| Automatic Backup                | ✅ Complete | Includes timestamp and restore    |
| Graphics/Wi-Fi Drivers          | 🚧 Planned  | Intel/NVIDIA/AMD support          |
| Multimedia & Codecs             | 🚧 Planned  | VLC, ffmpeg, essential codecs     |
| Essential Applications          | 🚧 Planned  | Git, curl, vim, build-essential   |
| Development Tools               | 🚧 Planned  | VSCode, Node.js, Docker, IDEs     |
| Flatpak & Apps                  | 🚧 Planned  | Default installation and setup    |
| Silent Mode (`--quiet`)         | 🚧 Planned  | For mass automation               |
| Force Reconfiguration (`--force`) | 🚧 Planned  | Re-applies existing changes       |

## 🚀 Installation

### Method 1: Full Clone

```bash
git clone https://github.com/PauloNRocha/debian-post-install.git
cd debian-post-install
chmod +x scripts/*.sh
```

### Method 2: Direct Download

```bash
wget https://raw.githubusercontent.com/PauloNRocha/debian-post-install/main/scripts/01-repositories.sh
chmod +x 01-repositories.sh
```

### Method 3: One-Liner

```bash
curl -fsSL https://raw.githubusercontent.com/PauloNRocha/debian-post-install/main/install.sh | bash
```

## 💻 Usage

### Repositories Script

```bash
sudo ./scripts/01-repositories.sh
```

### Full Script (coming soon)

```bash
sudo ./install.sh
```

### Options in development

```bash
sudo ./install.sh --quiet      # Silent mode
sudo ./install.sh --force      # Re-apply changes
./install.sh --help            # Help
sudo ./install.sh --version    # Version
```

## 📁 Project Structure

```
debian-post-install/
├── 📄 README.md                 # This file
├── 📄 README.en.md              # English Readme
├── 📄 LICENSE                   # MIT License
├── 🚀 install.sh               # Main script (in development)
├── 📂 scripts/
│   ├── 01-repositories.sh      # ✅ Repository setup
│   ├── 02-drivers.sh          # 🚧 Hardware drivers
│   ├── 03-multimedia.sh       # 🚧 Codecs and multimedia
│   ├── 04-essential-apps.sh   # 🚧 Essential applications
│   ├── 05-development.sh      # 🚧 Development tools
│   ├── 06-flatpak.sh          # 🚧 Flatpak support
│   └── 07-future-scripts.sh   # 🚧 New scripts
├── 📂 configs/                # Configuration files
│   └── sources.list.template  # Repository template
└── 📂 docs/                   # Additional documentation
    └── troubleshooting.md     # Troubleshooting guide
```

## 🔧 How It Works

**Repositories Script**

1. Detects the Debian version.
2. Checks if `contrib` and `non-free` are already present.
3. Creates an automatic backup of `sources.list`.
4. Applies changes only to `deb` lines.
5. Validates that the repositories were added.
6. Runs `apt update` with visual feedback.

**Configured Repositories**
| Debian | Original                 | Final Result                              |
| ------ | ------------------------ | ----------------------------------------- |
| 10-11  | `main`                   | `main contrib non-free`                   |
| 12-13  | `main non-free-firmware` | `main contrib non-free non-free-firmware` |

## ⚠️ Requirements

* Debian 10, 11, 12, or 13
* Root or sudo access
* Internet connection
* A terminal with UTF-8 color support

## 🤝 Contributing

1. Fork the project
2. Create a branch (`git checkout -b feature/NewFeature`)
3. Commit your changes (`git commit -m 'Add a new feature'`)
4. Push to the branch (`git push origin feature/NewFeature`)
5. Open a Pull Request

**Guidelines**

- Use Bash
- Test on Debian 10-13
- Include colors and progress indicators
- Document all changes

## 🐛 Known Issues

* UTF-8 icons may not appear correctly in older terminals
* `apt update` may time out on slow connections

## 📚 Useful Resources

- [Debian Documentation](https://www.debian.org/doc/)
- [Debian Repository](https://wiki.debian.org/SourcesList)
- [Bash Scripting Guide](https://tldp.org/LDP/Bash-Beginners-Guide/html/)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ✨ Author

Developed by Paulo Rocha

---

**⭐ If this project was helpful, please consider giving it a star!**
