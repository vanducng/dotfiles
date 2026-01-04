# 🚀 Installation Guide

Complete step-by-step installation guide for the development environment.

## 📋 Prerequisites

### System Requirements
- **macOS**: 12.0 (Monterey) or later
- **Homebrew**: Package manager for macOS
- **Git**: Version control system
- **Terminal**: Terminal emulator (Ghostty, Kitty, or built-in Terminal)

### Hardware Requirements
- **RAM**: 8GB minimum, 16GB recommended
- **Storage**: 10GB free space for tools and configurations
- **CPU**: Intel or Apple Silicon Mac

## 🛠️ Step 1: Install Homebrew

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
brew install git stow

# Install development tools
brew install neovim tmux fzf ripgrep fd

# Install window management
brew install yabai skhd

# Install terminal emulators
brew install --cask ghostty kitty

# Verify installations
git --version
stow --version
nvim --version
tmux -V
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
# - Terminal multiplexer (tmux)
# - Editor configuration (neovim)
# - Window manager (yabai, skhd)
# - Application configs (kitty, ghostty, etc.)
```

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

### Configure Tmux
```bash
# Install Tmux Plugin Manager (TPM)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Start tmux
tmux new-session

# Install plugins (in tmux)
# Press: Ctrl-x + I (capital I)

# Verify tmux configuration
tmux source-file ~/.tmux.conf
```

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

# Test tmux
tmux new-session -s test
# Press: Ctrl-x + t (should open project sessionizer)

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
ps aux | grep -E "(yabai|skhd|tmux)"

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

### Add Personal Projects
```bash
# Edit tmux sessionizer paths
nvim ~/.local/bin/tmux-sessionizer

# Add your project directories
search_paths=(
    ~/personal
    ~/projects
    ~/work/your-company
)
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

# Tmux plugins
tmux kill-server
rm -rf ~/.tmux/plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
tmux new-session
# Press: Ctrl-x + I
```

### Getting Help
- Check the [Troubleshooting Guide](troubleshooting.md)
- Review individual tool documentation
- Check GitHub issues for specific problems

## 🎉 Next Steps

### Learn the Workflow
1. Read the [Quick Reference](quick-reference.md)
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
- [Quick Reference](quick-reference.md)
- [Troubleshooting Guide](troubleshooting.md)
- [Neovim Setup](neovim/README.md)
- [AI Tools Configuration](ai/)
- [Daily Workflows](workflows/)