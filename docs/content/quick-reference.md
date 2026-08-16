---
title: "Quick Reference Guide"
---

Essential commands and shortcuts for daily development workflow.

## 🚀 Emergency Commands

```bash
# Window manager broke
killall yabai skhd && brew services restart yabai && brew services restart skhd

# Terminal broke
/Applications/Ghostty.app/Contents/MacOS/ghostty

# Herdr diagnostics
herdr status
tail -n 100 ~/.config/herdr/herdr-server.log

# Neovim stuck
:qa! # or pkill nvim
```

## ⌨️ Essential Shortcuts

### Global (SKHD)
| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `meh + a` | Ghostty | `meh + s` | Dia |
| `meh + f` | Kitty | `meh + g` | Cursor |
| `meh + t` | Discord | `meh + x` | ChatGPT |
| `meh + v` | Grok Bot | `meh + q` | Music |
| `ctrl+shift+hjkl` | Focus Window | `cmd+shift+h/l` | Move Window |
| `hyper + arrows` | Resize Window | `hyper + f` | Fullscreen |

### Herdr (Prefix: C-x)
| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `C-x + m` | Split Right | `C-x + v` | Split Down |
| `Ctrl-Alt-hjkl` | Navigate Panes | `C-x + Space` | Pick Recent Target |
| `C-x + Shift-Right` | Next Workspace | `Ctrl-Alt-1..9` | Switch Workspace |
| `C-x + Shift-Up/Down` | Previous/Next Agent | `C-x + Alt-1..9` | Focus Agent |
| `C-x + p` | Previous Tab | `C-x + a` | Last Pane |
| `C-x + f` | Agent Address Picker | `C-x + g` | Session Navigator |
| `C-x + c` | New Tab | `C-x + Shift-T` | Rename Tab |
| `Ctrl-1..9` | Switch Tab | `C-x + w` | Workspace Picker |
| `C-x + r` | Resize Mode | `C-x + R` | Reload Config |
| `C-x + ?` | Key Help | | |

### Tmux (Legacy, Prefix: C-x)
| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `C-x + t` | Project Sessionizer | `C-x + m` | Split Horizontal |
| `C-x + v` | Split Vertical | `C-x + hjkl` | Navigate Panes |
| `C-x + Space` | Last Window | `C-x + c` | New Window |
| `C-x + Tab` | Tmux Fingers | `C-x + a` | Zoom Pane |
| `C-x + r` | Reload Config | `C-x + i` | Show Pane Numbers |

### Neovim
| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `<C-f>` | Project Sessionizer | `-` | File Manager |
| `<leader>ac` | AI Chat | `<leader>aa` | AI Actions |
| `<leader>Dd` | Database Explorer | `<leader>ff` | Find Files |
| `<leader>jf` | Pretty-print JSON/JSONL | `<leader>jp` | Preview JSON/JSONL |
| `<leader>gg` | Lazygit | `gd` | Go to Definition |

### AI Completion (Copilot)
| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `<Tab>` | Accept/Tab | `<C-;>` | Accept Full |
| `<C-'>` | Accept Word | `<C-]>` | Accept Line |
| `<C-[>` | Previous | `<C-\>` | Next |

## 🔧 Common Commands

### Service Management
```bash
# Restart window manager
skhd --restart-service
yabai --restart-service

# Reload configurations
herdr server reload-config
source ~/.zshrc

# Legacy Tmux only
tmux source-file ~/.tmux.conf

# Update plugins
:Lazy sync  # Neovim
prefix + I  # Legacy Tmux
```

### Project Management
```bash
# Quick project switch
C-x + g  # Search Herdr workspaces, tabs, and panes
C-x + w  # Open the Herdr workspace picker
C-f      # From Neovim

# New project tab
C-x + c
C-x + Shift-T  # Rename the tab
```

### AI Tools
```bash
# CodeCompanion
<leader>ac  # Open chat
<leader>aa  # Actions menu
<leader>ar  # Code review

# Copilot (ergonomic keybindings)
:Copilot status
:Copilot enable
Tab     # Accept suggestion or normal tab
C-;     # Accept full suggestion
C-'     # Accept word
C-]     # Accept line

# Database AI
<leader>Dd  # Select miudb connection
<leader>Dl  # List miudb connections
<leader>Dq  # Run current SQL buffer
<leader>j   # Run current SQL buffer

# Focus & Zen Mode
<leader>z   # Zen mode (70% width)
<leader>Z   # Full screen zen mode
<leader>zx  # Exit zen mode across legacy Tmux panes
<leader>tt  # Toggle twilight
```

## 📁 Important Paths

```bash
# Configuration files
~/.config/nvim/          # Neovim config
~/.config/yabai/         # Yabai config
~/.config/skhd/          # SKHD config
~/.config/atuin/         # Atuin config
~/.config/herdr/         # Herdr config and local runtime state
~/.tmux.conf             # Legacy Tmux config
~/.zshrc                 # Zsh config

# Dotfiles
~/.dotfiles/dotfiles/    # All configurations

# Logs
/usr/local/var/log/yabai/
/usr/local/var/log/skhd/

# Cache & Data
~/.cache/nvim/
~/.local/share/nvim/
~/.local/share/atuin/    # Atuin history database
```

## 🔍 Diagnostic Commands

```bash
# Check service status
brew services list | grep -E "(yabai|skhd)"
ps aux | grep -E "(yabai|skhd|nvim|herdr)"

# Check health
:checkhealth  # Neovim
herdr status  # Herdr client and server
tmux info     # Legacy Tmux

# View logs
tail -f /usr/local/var/log/yabai/yabai.err.log
tail -f /usr/local/var/log/skhd/skhd.err.log
```

## 🛠️ Installation Commands

```bash
# Install prerequisites
brew install git stow mise

# Install dotfiles and managed tools
git clone https://github.com/vanducng/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./scripts/macos-deps.sh
make stow-install
mise install
mise exec -- herdr --version

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

# Reset legacy Tmux
tmux kill-server
rm -rf ~/.tmux/plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

## 🎯 Workflow Patterns

### Daily Startup
```bash
1. herdr             # Start or resume the workspace manager
2. C-x + g           # Select a workspace, tab, or pane
3. nvim              # Open editor
4. <leader>Dd        # Open database if needed
5. <leader>ac        # Start AI chat if needed
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
1. C-x + g          # Search Herdr sessions
2. Type project or agent name
3. Enter            # Focus the target
```

### Database Work
```bash
1. <leader>Dd       # Select miudb connection
2. Open a .sql file
3. Write SQL query
4. <leader>j        # Execute buffer
```

## 🔗 Quick Links

- [Full Documentation](/)
- [Troubleshooting](/troubleshooting/)
- [Neovim Guide](/neovim/)
- [AI Workflows](/ai/workflows/)
- [Herdr Guide](/herdr/)
- [Legacy Tmux Guide](/tmux/)
