---
title: "Installation Guide"
---

Complete step-by-step installation guide for the development environment.

## 📋 Prerequisites

### System Requirements
- **macOS**: 12.0 (Monterey) or later (Homebrew + Ghostty/Kitty)
- **Linux**: Ubuntu 22.04+ (user-space bootstrap; sudo optional)
- **Git**: Version control system
- **Terminal**: Ghostty or Kitty on macOS; Kitty (user-space) on Linux

### Hardware Requirements
- **RAM**: 8GB minimum, 16GB recommended
- **Storage**: 10GB free space for tools and configurations
- **CPU**: Intel, Apple Silicon, or x86_64 Linux

## Linux (Ubuntu 22.04+)

This path does **not** use Homebrew, Nix, or sudo. It installs CLIs into `~/.local` and `mise`, then stows portable configs.

Failures already baked in: `aqua:tmux/tmux` is not in the aqua registry (use mise `tmux`); `git-delta` is not a mise tool name (use `aqua:dandavison/delta`); do not auto-stow `grok` over a live Grok TUI `~/.grok/` tree.

```bash
git clone https://github.com/vanducng/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make bootstrap-linux
```

Add this to `~/.bashrc` (do not replace the distro file):

```bash
# ~/.config/shell/linux.sh is stowed by the shell-linux package
[[ -f ~/.config/shell/linux.sh ]] && source ~/.config/shell/linux.sh
```

Copy the git identity template (not committed as `~/.gitconfig`):

```bash
cp ~/.config/git/gitconfig.linux.example ~/.gitconfig
# default email: me@vanducng.dev
# ~/work/cnb (or ~/src/careernowbrands) → duc@careernowbrands.com
# ~/work/crashchat                     → me@vanducng.dev
# ~/work/ab-spectrum                   → duc@yds.services
# ~/work/bhcoe                         → duc@careernowbrands.com
```

Optional (needs sudo): `mosh`, `zathura`, `taskwarrior`, and `chsh -s` to zsh. Grok config: `make stow-grok` is opt-in after backing up `~/.grok/auth.json`.

Desktop (Sway = i3 on Wayland, Ghostty, same skhd/Karabiner keys): `make linux-desktop`. Details in [Linux desktop](/linux-desktop). Homelab (disks, never-sleep, ssh, clones): `make linux-homelab` then `sudo -E ./scripts/linux-homelab-root.sh` — [Linux homelab](/linux-homelab).

Then continue from [Step 5](#-step-5-install-dotfiles) if you only needed the Linux extras above — `make bootstrap-linux` already ran `stow-install`.

## 🛠️ Step 1: Install Homebrew (macOS)

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add Homebrew to PATH (Apple Silicon)
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# Add Homebrew to PATH (Intel)
echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/usr/local/bin/brew shellenv)"

# Verify installation
brew --version
```

## 📦 Step 2: Install Core Dependencies

```bash
# Install essential tools
brew install git stow mise

# Install development tools
brew install neovim fzf ripgrep fd

# Install window management
brew install yabai skhd

# Install terminal emulators
brew install --cask ghostty kitty

# Verify installations
git --version
stow --version
nvim --version
```

## 🏠 Step 3: Clone Dotfiles Repository

```bash
# Clone the repository
git clone https://github.com/vanducng/dotfiles.git ~/.dotfiles

# Navigate to dotfiles directory
cd ~/.dotfiles

# Verify repository structure
ls -la
```

## 🔧 Step 4: Install System Dependencies

```bash
# Run the macOS dependencies script
./scripts/macos-deps.sh

# This installs:
# - Development tools (Node.js, Python, Rust)
# - Applications (browsers, editors, communication tools)
# - Utilities (file managers, system tools)
```

## 🔗 Step 5: Install Dotfiles

```bash
# Install all dotfiles using GNU Stow
make stow-install

# This creates symlinks for:
# - Shell configuration (zsh)
# - Agent workspace manager (Herdr)
# - Legacy terminal multiplexer config (tmux)
# - Editor configuration (neovim)
# - Window manager (yabai, skhd)
# - Application configs (kitty, ghostty, etc.)

# Install the managed CLI versions, including Herdr
mise install

# Verify Herdr
mise exec -- herdr --version
```

New Zsh sessions activate mise automatically. Run `mise exec -- herdr` to start Herdr immediately in the current shell.

## 🐚 Step 6: Shell Setup

### Install Oh My Zsh
```bash
# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install Powerlevel10k theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Install zsh plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

### Configure Shell
```bash
# Restart terminal or source configuration
source ~/.zshrc

# Configure Powerlevel10k (if prompted)
p10k configure

# Verify shell setup
echo $SHELL
which zsh
```

## 🪟 Step 7: Window Manager Setup

### Configure Yabai
```bash
# Start yabai service
brew services start yabai

# Install scripting addition (requires password)
sudo yabai --install-sa

# Verify yabai is running
yabai --check-sa
```

### Configure SKHD
```bash
# Start skhd service
brew services start skhd

# Grant accessibility permissions
# System Preferences → Security & Privacy → Privacy → Accessibility
# Add and enable: /usr/local/bin/skhd (or /opt/homebrew/bin/skhd)

# Verify skhd is running
ps aux | grep skhd
```

### System Preferences
```bash
# Disable Mission Control shortcuts that conflict
# System Preferences → Keyboard → Shortcuts → Mission Control
# Disable or change conflicting shortcuts

# Configure Spaces
# System Preferences → Mission Control
# Uncheck "Automatically rearrange Spaces based on most recent use"
```

## 💻 Step 8: Terminal Setup

### Configure Herdr
```bash
# Validate the managed config
mise exec -- herdr config check

# Start or resume the workspace manager
mise exec -- herdr
```

The [Tmux guide](/tmux/) remains available for legacy remote and compatibility workflows.

### Configure Terminal Emulator
```bash
# For Ghostty (recommended)
# Configuration is already linked via dotfiles

# For Kitty (alternative)
# Configuration is already linked via dotfiles

# Test terminal features
echo $TERM
echo $COLORTERM
```

## 🚀 Step 9: Neovim Setup

### Initial Launch
```bash
# Start Neovim
nvim

# Plugins will install automatically
# Wait for installation to complete

# Check health
:checkhealth

# Exit Neovim
:qa
```

### Install Language Servers
```bash
# Open Neovim
nvim

# Open Mason (LSP installer)
:Mason

# Install language servers for your languages:
# - lua_ls (Lua)
# - pyright (Python)
# - tsserver (TypeScript/JavaScript)
# - rust_analyzer (Rust)
# - etc.

# Verify LSP installation
:LspInfo
```

## 🤖 Step 10: AI Tools Setup

### GitHub Copilot
```bash
# Open Neovim
nvim

# Authenticate with GitHub
:Copilot auth

# Follow the authentication flow
# Verify status
:Copilot status
```

### CodeCompanion (OpenAI)
```bash
# Set OpenAI API key
export OPENAI_API_KEY="your-api-key-here"

# Add to shell configuration
echo 'export OPENAI_API_KEY="your-api-key-here"' >> ~/.zshrc

# Test CodeCompanion
nvim
# Press: <leader>ac
```

:::caution
Adding `OPENAI_API_KEY` to `~/.zshrc` stores the key in plaintext. Prefer a secrets manager or an ignored env file, and never commit `~/.zshrc` with a real key.
:::

### NeoCodeium (Free Alternative)
```bash
# Open Neovim
nvim

# Authenticate with Codeium
:NeoCodeium auth

# Follow the authentication flow
# Verify status
:NeoCodeium status
```

## 🗄️ Step 11: Database Tools (Optional)

### Install Database Clients
```bash
# DBeaver (GUI client)
brew install --cask dbeaver-community

# Command line tools
brew install postgresql mysql sqlite
```

### Configure Database Tools
```bash
# Open Neovim
nvim

# Open database explorer
# Press: <leader>Dd

# Add database connections through the UI
# Connections are saved automatically
```

## ✅ Step 12: Verification

### Test Core Functionality
```bash
# Test window manager
# Press: meh + a (should open Ghostty)
# Press: ctrl + shift + h (should focus left window)

# Test Herdr
herdr status
# Press: Ctrl-x + ? (should open active key help)

# Test Neovim
nvim
# Press: <leader>ff (should open file finder)
# Press: <leader>ac (should open AI chat)
```

### Check Services
```bash
# Verify all services are running
brew services list | grep -E "(yabai|skhd)"

# Check process status
ps aux | grep -E "(yabai|skhd|herdr)"

# Test key bindings
skhd --observe  # Press some keys to test
```

## 🔧 Post-Installation Configuration

### Customize Settings
```bash
# Edit configurations as needed
nvim ~/.dotfiles/dotfiles/yabai/.config/yabai/yabairc
nvim ~/.dotfiles/dotfiles/skhd/.config/skhd/skhdrc
nvim ~/.dotfiles/dotfiles/nvim/.config/nvim/lua/plugins/user.lua

# Apply changes
make stow-install
skhd --restart-service
yabai --restart-service
```

### Open a Project Workspace
```bash
cd ~/projects/your-project
herdr

# Inside Herdr, use C-x g to search workspaces, tabs, and panes
```

## 🆘 Troubleshooting Installation

### Common Issues

#### Permission Denied
```bash
# Fix file permissions
chmod +x ~/.local/bin/*
chmod +x ~/.dotfiles/scripts/*

# Grant accessibility permissions
# System Preferences → Security & Privacy → Privacy → Accessibility
```

#### Services Not Starting
```bash
# Check Homebrew services
brew services list

# Restart services
brew services restart yabai
brew services restart skhd

# Check logs
tail -f /usr/local/var/log/yabai/yabai.err.log
```

#### Plugins Not Installing
```bash
# Neovim plugins
nvim
:Lazy clean
:Lazy sync

# Herdr config and runtime
mise exec -- herdr config check
herdr status
tail -n 100 ~/.config/herdr/herdr-server.log
```

### Getting Help
- Check the [Troubleshooting Guide](/troubleshooting/)
- Review individual tool documentation
- Check GitHub issues for specific problems

## 🎉 Next Steps

### Learn the Workflow
1. Read the [Quick Reference](/quick-reference/)
2. Practice key bindings
3. Explore AI tools
4. Customize to your needs

### Advanced Setup
1. Configure additional languages
2. Add custom scripts
3. Set up project templates
4. Integrate with your workflow

### Stay Updated
```bash
# Update dotfiles
cd ~/.dotfiles
git pull origin main
make stow-install

# Update plugins
nvim
:Lazy sync

# Update system packages
brew update && brew upgrade
```

---

## 📖 Related Documentation
- [Quick Reference](/quick-reference/)
- [Troubleshooting Guide](/troubleshooting/)
- [Neovim Setup](/neovim/)
- [AI Tools Configuration](/ai/)
- [Daily Workflows](/workflows/)
