# ⚡ Quick Reference Guide

Essential commands and shortcuts for daily development workflow.

## 🚀 Emergency Commands

```bash
# Window manager broke
killall yabai skhd && brew services restart yabai && brew services restart skhd

# Terminal broke
/Applications/Ghostty.app/Contents/MacOS/ghostty

# Tmux unresponsive
tmux kill-server && tmux new-session

# Neovim stuck
:qa! # or pkill nvim
```

## ⌨️ Essential Shortcuts

### Global (SKHD)
| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `meh + a` | Ghostty | `meh + s` | Arc Browser |
| `meh + w` | Windsurf | `meh + x` | VSCode |
| `meh + d` | DBeaver | `meh + u` | Claude |
| `ctrl+shift+hjkl` | Focus Window | `cmd+shift+hjkl` | Move Window |
| `hyper + hjkl` | Resize Window | `hyper + f` | Fullscreen |

### Tmux (Prefix: C-x)
| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `C-x + t` | Project Sessionizer | `C-x + m` | Split Horizontal |
| `C-x + v` | Split Vertical | `C-x + hjkl` | Navigate Panes |
| `C-x + r` | Reload Config | `C-x + a` | Zoom Pane |

### Neovim
| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `<C-f>` | Project Sessionizer | `-` | File Manager |
| `<leader>ac` | AI Chat | `<leader>aa` | AI Actions |
| `<leader>Dd` | Database Explorer | `<leader>ff` | Find Files |
| `<leader>gg` | Lazygit | `gd` | Go to Definition |

## 🔧 Common Commands

### Service Management
```bash
# Restart window manager
skhd --restart-service
yabai --restart-service

# Reload configurations
tmux source-file ~/.tmux.conf
source ~/.zshrc

# Update plugins
:Lazy sync  # Neovim
prefix + I  # Tmux
```

### Project Management
```bash
# Quick project switch
C-x + t  # From tmux
C-f      # From Neovim

# New project session
tmux new-session -s project -c ~/path/to/project

# Attach to session
tmux attach-session -t project
```

### AI Tools
```bash
# CodeCompanion
<leader>ac  # Open chat
<leader>aa  # Actions menu
<leader>ar  # Code review

# Copilot
:Copilot status
:Copilot enable
C-J  # Accept suggestion (insert mode)

# Database AI
<leader>Dd  # Open dbee
BB  # Execute query (visual/normal mode)
```

## 📁 Important Paths

```bash
# Configuration files
~/.config/nvim/          # Neovim config
~/.config/yabai/         # Yabai config
~/.config/skhd/          # SKHD config
~/.tmux.conf             # Tmux config
~/.zshrc                 # Zsh config

# Dotfiles
~/.dotfiles/dotfiles/    # All configurations

# Logs
/usr/local/var/log/yabai/
/usr/local/var/log/skhd/

# Cache
~/.cache/nvim/
~/.local/share/nvim/
```

## 🔍 Diagnostic Commands

```bash
# Check service status
brew services list | grep -E "(yabai|skhd)"
ps aux | grep -E "(yabai|skhd|nvim|tmux)"

# Check health
:checkhealth  # Neovim
tmux info     # Tmux

# View logs
tail -f /usr/local/var/log/yabai/yabai.err.log
tail -f /usr/local/var/log/skhd/skhd.err.log
```

## 🛠️ Installation Commands

```bash
# Install dotfiles
git clone https://github.com/vanducng/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make stow-install

# Install dependencies
./scripts/macos-deps.sh

# Setup AI tools
:Copilot auth  # GitHub Copilot
export OPENAI_API_KEY="..."  # CodeCompanion
```

## 📊 Performance Monitoring

```bash
# System resources
top -o cpu
top -o mem
df -h

# Process monitoring
ps aux | sort -k4 -nr | head -10  # Memory usage
ps aux | sort -k3 -nr | head -10  # CPU usage

# Neovim performance
:Lazy profile
nvim --startuptime startup.log
```

## 🔄 Backup & Recovery

```bash
# Backup configurations
tar -czf ~/dotfiles-backup-$(date +%Y%m%d).tar.gz ~/.dotfiles

# Reset Neovim
rm -rf ~/.config/nvim ~/.local/share/nvim ~/.cache/nvim
make stow-install

# Reset tmux
tmux kill-server
rm -rf ~/.tmux/plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

## 🎯 Workflow Patterns

### Daily Startup
```bash
1. C-x + t          # Select main project
2. nvim             # Open editor
3. <leader>Dd       # Open database if needed
4. <leader>ac       # Start AI chat if needed
```

### Code Review
```bash
1. Select code
2. <leader>ar       # AI review
3. <leader>af       # Apply fixes
4. :w               # Save changes
```

### Project Switch
```bash
1. C-x + t          # Project sessionizer
2. Type project name
3. Enter            # Switch to project
```

### Database Work
```bash
1. <leader>Dd       # Open dbee
2. Connect to database
3. Write SQL query
4. BB               # Execute query
```

## 🔗 Quick Links

- [Full Documentation](README.md)
- [Troubleshooting](troubleshooting.md)
- [Neovim Guide](neovim/README.md)
- [AI Workflows](ai/workflows.md)
- [Tmux Guide](tmux.md)