# 🏠 Duc's Digital Workspace

A comprehensive, AI-enhanced development environment for macOS featuring tiling window management, advanced terminal workflows, and integrated AI coding assistance.

![macOS](https://img.shields.io/badge/macOS-000000?style=for-the-badge&logo=apple&logoColor=white)
![Neovim](https://img.shields.io/badge/NeoVim-%2357A143.svg?&style=for-the-badge&logo=neovim&logoColor=white)
![Tmux](https://img.shields.io/badge/tmux-1BB91F?style=for-the-badge&logo=tmux&logoColor=white)
![Zsh](https://img.shields.io/badge/Zsh-F15A24?style=for-the-badge&logo=gnu-bash&logoColor=white)

## ✨ Features

### 🤖 AI-Enhanced Development
- **CodeCompanion** - AI chat and inline assistance
- **GitHub Copilot** - Primary AI code completion with ergonomic keybindings
- **Database AI** - AI-powered SQL assistance
- **Unified AI System** - Streamlined AI completion with conflict prevention

### 🪟 Window Management
- **Yabai** - Tiling window manager with BSP layout
- **SKHD** - Hotkey daemon for seamless app switching
- **Sketchybar** - Custom status bar with system info

### 💻 Terminal & Shell
- **Zsh** with Oh My Zsh and Powerlevel10k
- **Tmux** with custom keybindings and session management
- **Ghostty/Kitty** - Modern terminal emulators
- **Starship** - Cross-shell prompt

### 🛠️ Development Tools
- **Neovim** - AstroNvim v5 with LSP, treesitter, and AI
- **Database Tools** - Advanced SQL development with Snowflake support
- **Version Management** - Mise for runtime versions
- **Shell History** - Atuin for intelligent command history and sync
- **Environment Management** - Direnv for automatic environment loading
- **File Management** - Yazi with custom plugins

## 🚀 Quick Start

### Prerequisites
```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install GNU Stow
brew install stow
```

### Installation
```bash
# Clone the repository
git clone https://github.com/vanducng/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Install macOS dependencies
./scripts/macos-deps.sh

# Install dotfiles using GNU Stow
make stow-install
```

### Post-Installation
```bash
# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install Powerlevel10k theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Configure Powerlevel10k
p10k configure
```

## 📁 Repository Structure

```
dotfiles/
├── atuin/         # Intelligent shell history and sync
├── bin/           # Custom scripts and utilities
├── claude/        # Claude AI configuration
├── direnv/        # Environment variable management
├── ghostty/       # Ghostty terminal config
├── hammerspoon/   # macOS automation
├── karabiner/     # Keyboard customization
├── kitty/         # Kitty terminal config
├── lazygit/       # Git TUI configuration
├── mise/          # Runtime version manager
├── nvim/          # Neovim configuration (AstroNvim)
├── nvim-vscode/   # VSCode Neovim integration
├── sketchybar/    # Status bar configuration
├── skhd/          # Hotkey daemon config
├── starship/      # Shell prompt config
├── task/          # Task runner config
├── tmux/          # Terminal multiplexer config
├── vrapperrc/     # Vim keybindings for Eclipse
├── vscode/        # VSCode settings
├── yabai/         # Window manager config
├── yazi/          # File manager config
├── zathura/       # PDF viewer config
└── zsh/           # Shell configuration
```

## ⌨️ Key Bindings

### Global Shortcuts (SKHD)
| Shortcut | Action |
|----------|--------|
| `meh + a` | Open Ghostty |
| `meh + s` | Open Arc Browser |
| `meh + d` | Open DBeaver |
| `meh + w` | Open Windsurf IDE |
| `meh + x` | Open VSCode |
| `meh + v` | Open Cursor |
| `meh + u` | Open Claude |

### Window Management (Yabai + SKHD)
| Shortcut | Action |
|----------|--------|
| `ctrl + shift + hjkl` | Focus window |
| `cmd + shift + hjkl` | Move window |
| `hyper + hjkl` | Resize window |
| `hyper + f` | Toggle fullscreen |
| `hyper + e` | Balance windows |

### Tmux (Prefix: `C-x`)
| Shortcut | Action |
|----------|--------|
| `C-x + m` | Split horizontal |
| `C-x + v` | Split vertical |
| `C-x + hjkl` | Navigate panes |
| `C-x + t` | Project sessionizer |
| `C-x + r` | Reload config |

### Neovim
| Shortcut | Action |
|----------|--------|
| `<leader>ac` | Open AI Chat |
| `<leader>aa` | AI Actions |
| `<leader>Dd` | Database Explorer |
| `<C-f>` | Project Sessionizer |
| `-` | File Manager (Oil) |

### AI Completion (GitHub Copilot)
| Shortcut | Action |
|----------|--------|
| `<Tab>` | Accept suggestion or normal tab |
| `<C-;>` | Accept full suggestion |
| `<C-'>` | Accept word |
| `<C-]>` | Accept line |
| `<C-[>` | Previous suggestion |
| `<C-\>` | Next suggestion |
| `<C-BS>` | Dismiss suggestion |

## 🔧 Configuration Highlights

### Neovim Features
- **AstroNvim v5** - Modern Neovim distribution
- **AI Integration** - Multiple AI assistants for coding
- **Database Tools** - Advanced SQL development with MFA support
- **LSP Support** - Language servers for multiple languages
- **Custom Dashboard** - Branded startup screen

### Tmux Workflow
- **Project Sessionizer** - Quick project switching with FZF
- **Vim Navigation** - Consistent keybindings across tools
- **Session Persistence** - Automatic session management
- **Status Integration** - Catppuccin theme with system info

### Window Management
- **BSP Layout** - Binary space partitioning for optimal screen usage
- **Smart Gaps** - 5px gaps with toggle functionality
- **App Rules** - Specific behavior for different applications
- **Mouse Integration** - Fn + mouse for window manipulation

## 🛠️ Customization

### Adding New Applications
1. Add configuration to appropriate `dotfiles/` subdirectory
2. Update `STOW_FOLDERS` in `Makefile`
3. Run `make stow-install`

### Modifying Shortcuts
- **Global shortcuts**: Edit `dotfiles/skhd/.config/skhd/skhdrc`
- **Window management**: Edit `dotfiles/yabai/.config/yabai/yabairc`
- **Tmux bindings**: Edit `dotfiles/tmux/.tmux.conf`

### AI Configuration
See documentation in `dotfiles/nvim/.config/nvim/docs/`:
- `CODECOMPANION_USAGE.md` - AI chat and assistance
- `COPILOT_SETUP.md` - GitHub Copilot configuration
- `NEOCODEIUM_SETUP.md` - Alternative AI completion
- `DBEE_SNOWFLAKE_SETUP.md` - Database AI tools

## 📋 Available Commands

```bash
# Dotfiles management
make stow-install    # Install all dotfiles
make stow-clean      # Remove all symlinks

# System maintenance
./scripts/macos-deps.sh      # Install dependencies
./scripts/yabai-upgrade.sh   # Upgrade window manager

# Alias management (Atuin)
make export-aliases  # Export current aliases to file
make import-aliases  # Import aliases from file
make backup-aliases  # Export and commit aliases to git

# Tmux utilities
~/.local/bin/tmux-sessionizer    # Project switcher
~/.local/bin/tmux-windowizer     # Window manager
```

## 🔍 Troubleshooting

### Common Issues

**Yabai not working after macOS update:**
```bash
./scripts/yabai-upgrade.sh
```

**Tmux plugins not loading:**
```bash
# Install TPM
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# Press prefix + I in tmux to install plugins
```

**Neovim plugins not working:**
```bash
# Open Neovim and run
:Lazy sync
:Mason
```

**AI tools not responding:**
- Check API keys in respective configuration files
- Verify network connectivity
- See individual setup guides in `docs/` folder

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📚 References & Inspiration

- [GNU Stow Guide](https://dr563105.github.io/blog/manage-dotfiles-with-gnu-stow/)
- [AstroNvim Documentation](https://docs.astronvim.com/)
- [Yabai Wiki](https://github.com/koekeishiya/yabai/wiki)
- [Tmux Guide](https://github.com/tmux/tmux/wiki)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

⭐ **Star this repo if you find it useful!**
