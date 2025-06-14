# 🖥️ Tmux - Terminal Multiplexer

Tmux is the backbone of the terminal workflow, providing session management, window splitting, and seamless project switching.

## 📋 Table of Contents
- [Overview](#overview)
- [Key Bindings](#key-bindings)
- [Session Management](#session-management)
- [Project Sessionizer](#project-sessionizer)
- [Plugins](#plugins)
- [Configuration](#configuration)
- [Workflows](#workflows)
- [Troubleshooting](#troubleshooting)

## 🎯 Overview

### Custom Prefix
- **Prefix Key**: `C-x` (instead of default `C-b`)
- **Reason**: Avoids conflicts with shell shortcuts and easier to reach

### Key Features
- **Project Sessionizer**: Quick project switching with FZF
- **Vim Navigation**: Consistent hjkl movement across panes
- **Catppuccin Theme**: Beautiful, consistent theming
- **Session Persistence**: Automatic session management
- **Copy-Paste Integration**: Seamless macOS clipboard integration

## ⌨️ Key Bindings

### Session Management
| Shortcut | Action | Description |
|----------|--------|-------------|
| `C-x + t` | Project Sessionizer | Open FZF project picker |
| `C-x + E` | Wiki Session | Quick access to wiki |
| `C-x + X` | CNB Project | Switch to CNB project |
| `C-x + S` | NADR Project | Switch to NADR project |
| `C-x + D` | Mountain Project | Switch to Mountain project |
| `C-x + R` | CREPES Project | Switch to CREPES project |
| `C-x + G` | Infra Project | Switch to infra project |

### Window & Pane Management
| Shortcut | Action | Description |
|----------|--------|-------------|
| `C-x + m` | Split Horizontal | Create horizontal split |
| `C-x + v` | Split Vertical | Create vertical split |
| `C-x + c` | New Window | Create new window in current directory |
| `C-x + h/j/k/l` | Navigate Panes | Vim-style pane navigation |
| `C-x + H/J/K/L` | Resize Panes | Resize panes in direction |
| `C-x + a` | Toggle Zoom | Zoom current pane |
| `C-x + A` | Next Pane Zoom | Switch to next pane and zoom |

### Copy Mode
| Shortcut | Action | Description |
|----------|--------|-------------|
| `C-x + [` | Enter Copy Mode | Start text selection |
| `v` | Begin Selection | Start selecting text (in copy mode) |
| `y` | Copy Selection | Copy selected text |
| `C-x + ]` | Paste | Paste copied text |

### Plugin Management
| Shortcut | Action | Description |
|----------|--------|-------------|
| `C-x + I` | Install Plugins | Install new plugins |
| `C-x + U` | Update Plugins | Update existing plugins |
| `C-x + alt + u` | Uninstall Plugins | Remove unused plugins |

## 🎯 Session Management

### Creating Sessions
```bash
# Create new session
tmux new-session -s session_name

# Create session in specific directory
tmux new-session -s project -c ~/projects/my-project

# Create detached session
tmux new-session -d -s background_task
```

### Attaching/Detaching
```bash
# List sessions
tmux list-sessions
tmux ls

# Attach to session
tmux attach-session -t session_name
tmux a -t session_name

# Detach from session
C-x + d
```

### Session Navigation
```bash
# Switch between sessions
C-x + s    # Show session list
C-x + (    # Previous session
C-x + )    # Next session
```

## 🚀 Project Sessionizer

The project sessionizer is a powerful FZF-based tool for quick project switching.

### How It Works
1. **Trigger**: Press `C-x + t` or `C-f` (in Neovim)
2. **Search**: FZF searches predefined project directories
3. **Select**: Choose project with fuzzy search
4. **Switch**: Automatically creates/switches to project session

### Search Paths
```bash
~/personal
~/projects
~/work/cnb
~/work/cormac
~/work/mountain
~/work/timo
```

### Usage Examples
```bash
# From anywhere, press C-x + t
# Type partial project name: "wiki"
# Press Enter to switch to wiki session

# Or use directly from command line
~/.local/bin/tmux-sessionizer ~/projects/my-project
```

### Customization
Edit `~/.local/bin/tmux-sessionizer` to add new search paths:
```bash
search_paths=(
    ~/personal
    ~/projects
    ~/work/your-company
    ~/custom/path
)
```

## 🔌 Plugins

### Plugin Manager: TPM
- **Repository**: https://github.com/tmux-plugins/tpm
- **Installation**: Automatic via dotfiles setup

### Installed Plugins

#### Core Plugins
- **tmux-sensible**: Sensible default settings
- **tmux-fzf**: FZF integration for tmux

#### Theme & UI
- **catppuccin-tmux**: Beautiful Catppuccin theme
- **Custom status modules**: Directory, meetings, date/time

#### Navigation & Productivity
- **tmux-easymotion**: Vim-like easymotion for tmux
  - **Trigger**: `Space` key
  - **Hints**: `asdghklqwertyuiopzxcvbnmfj`

### Plugin Management

#### Installing New Plugins
1. Add plugin to `~/.tmux.conf`:
   ```bash
   set -g @plugin 'author/plugin-name'
   ```
2. Press `C-x + I` to install
3. Restart tmux or source config: `C-x + r`

#### Updating Plugins
```bash
# Update all plugins
C-x + U

# Or manually
cd ~/.tmux/plugins/tpm
git pull
```

#### Removing Plugins
1. Remove/comment plugin line in config
2. Press `C-x + alt + u` to uninstall
3. Or manually delete from `~/.tmux/plugins/`

## ⚙️ Configuration

### Key Configuration Files
- **Main Config**: `dotfiles/tmux/.tmux.conf`
- **Scripts**: `dotfiles/tmux/.config/tmux/scripts/`

### Important Settings

#### Terminal & Colors
```bash
set-option -g default-terminal "screen-256color"
set -ga terminal-overrides ",*:Tc"  # True color support
set -g allow-passthrough on         # Image preview support
```

#### Mouse & Navigation
```bash
set -g mouse on                     # Enable mouse support
setw -g mode-keys vi               # Vim keybindings
set -g base-index 1                # Start windows at 1
set -g renumber-windows on         # Renumber windows automatically
```

#### Performance
```bash
set-option -sg escape-time 5       # Faster escape for Neovim
set -g history-limit 10000         # Increase history
set-option -g focus-events on      # Enable focus events
```

### Theme Configuration
```bash
# Catppuccin theme settings
set -g @catppuccin_window_left_separator ""
set -g @catppuccin_window_right_separator " "
set -g @catppuccin_status_modules_right "directory meetings date_time"
set -g @catppuccin_status_modules_left "session"
set -g @catppuccin_date_time_text "%H:%M"
```

## 🔄 Workflows

### Daily Development Workflow
1. **Start Day**: `C-x + t` → Select main project
2. **Code**: Use panes for editor, terminal, tests
3. **Switch Projects**: `C-x + t` → Quick project switching
4. **End Day**: Sessions persist automatically

### Multi-Project Workflow
```bash
# Session 1: Main development
tmux new-session -d -s main -c ~/projects/main-project

# Session 2: Documentation
tmux new-session -d -s docs -c ~/projects/documentation

# Session 3: Monitoring/logs
tmux new-session -d -s monitoring

# Switch between them with C-x + s
```

### Pair Programming Setup
```bash
# Create shared session
tmux new-session -d -s pair-session

# Both users attach to same session
tmux attach-session -t pair-session
```

## 🔧 Troubleshooting

### Common Issues

#### Tmux Not Starting
```bash
# Check tmux version
tmux -V

# Kill all tmux sessions
tmux kill-server

# Start fresh
tmux new-session
```

#### Plugins Not Loading
```bash
# Reinstall TPM
rm -rf ~/.tmux/plugins/tpm
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Reload config and install
tmux source-file ~/.tmux.conf
# Press C-x + I
```

#### Colors Not Working
```bash
# Check terminal color support
echo $TERM
echo $COLORTERM

# Test true color
curl -s https://gist.githubusercontent.com/lifepillar/09a44b8cf0f9397465614e622979107f/raw/24-bit-color.sh | bash
```

#### Copy-Paste Issues
```bash
# Install reattach-to-user-namespace (macOS)
brew install reattach-to-user-namespace

# Verify pbcopy/pbpaste work
echo "test" | pbcopy
pbpaste
```

### Performance Issues
```bash
# Check session count
tmux list-sessions

# Kill unused sessions
tmux kill-session -t unused_session

# Reduce history limit if needed
set -g history-limit 5000
```

### Configuration Debugging
```bash
# Reload configuration
tmux source-file ~/.tmux.conf

# Check configuration errors
tmux show-messages

# Verify key bindings
tmux list-keys
```

## 📚 Advanced Tips

### Custom Scripts
Create custom scripts in `~/.config/tmux/scripts/`:
```bash
#!/bin/bash
# Example: Auto-layout for development
tmux split-window -h -p 30
tmux split-window -v -p 50
tmux select-pane -t 0
```

### Session Templates
```bash
# Create session template script
#!/bin/bash
SESSION_NAME="dev-template"
tmux new-session -d -s $SESSION_NAME -c ~/projects

# Window 1: Editor
tmux rename-window "editor"
tmux send-keys "nvim" C-m

# Window 2: Terminal
tmux new-window -n "terminal" -c ~/projects

# Window 3: Server
tmux new-window -n "server" -c ~/projects
tmux send-keys "npm run dev" C-m

# Attach to session
tmux attach-session -t $SESSION_NAME
```

### Integration with Other Tools
```bash
# Open tmux from Neovim
:terminal tmux new-session -d -s nested

# Use with SSH
ssh user@server -t tmux attach-session -t remote-dev
```

---

## 📖 Related Documentation
- [Project Sessionizer Script](../dotfiles/bin/.local/bin/tmux-sessionizer)
- [Tmux Configuration](../dotfiles/tmux/.tmux.conf)
- [Neovim Integration](neovim/README.md)
- [Terminal Setup](terminal.md)
