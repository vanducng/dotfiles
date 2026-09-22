---
title: "SKHD - Simple Hotkey Daemon"
---

SKHD provides global hotkeys for seamless application launching and window management integration with Yabai.


## 🎯 Overview

SKHD (Simple Hotkey Daemon) is a lightweight hotkey daemon for macOS that enables global keyboard shortcuts. It's tightly integrated with Yabai for window management and provides quick access to frequently used applications.

### Key Features
- **Global Hotkeys**: System-wide keyboard shortcuts
- **Application Launching**: Quick access to development tools
- **Window Management**: Integration with Yabai tiling
- **Modifier Keys**: Uses `meh` (ctrl+alt+shift) and `hyper` (ctrl+alt+cmd+shift)

## 🚀 Application Shortcuts

All application shortcuts use the `meh` key (ctrl+alt+shift) for consistency and to avoid conflicts.

### Space map

17 spaces. Display 1 holds 1-8, display 2 holds 9-17.

| Space | Display | App |
|-------|---------|-----|
| 1 | 1 | Ghostty |
| 2 | 1 | LibreOffice |
| 3 | 1 | Dia (stack) |
| 4 | 1 | Chrome, Vivaldi |
| 5 | 1 | Cursor |
| 6 | 1 | Preview, Foxit, ego lite |
| 7 | 1 | Alter |
| 8 | 1 | Obsidian |
| 9 | 2 | Slack |
| 10 | 2 | Telegram |
| 11 | 2 | Zalo |
| 12 | 2 | Discord, WhatsApp (stack) |
| 13 | 2 | Arc |
| 14 | 2 | Cliq |
| 15 | 2 | kitty |
| 16 | 2 | ChatGPT, Claude, Codex, Grok (stack) |
| 17 | 2 | spare |

### Development Tools
| Shortcut | Application | Description |
|----------|-------------|-------------|
| `meh + a` | Ghostty | Focus the primary terminal and move the pointer to it |
| `meh + f` | Sysmon overlay | Last tmux window, centered (first start: btop / disk / vault) |
| `cmd + shift + opt + v` | Sysmon left of Dia | Hub on the left quarter of Dia's space. Press again to focus it |
| `cmd + shift + opt + g` | Sysmon right of Dia | Hub on the right quarter of Dia's space. Press again to focus it |
| `cmd + shift + opt + r` | Sysmon left of Ego | Hub on the left quarter of Ego's space. Press again to focus it |
| `cmd + shift + opt + t` | Sysmon right of Ego | Hub on the right quarter of Ego's space. Press again to focus it |
| `meh + x` | ChatGPT | AI assistant on display 2, space 16 |
| `meh + g` | Cursor | AI-powered code editor on space 5 |
| `meh + h` | Alter | Chat hub on space 7 |

### Browsers & Communication
| Shortcut | Application | Description |
|----------|-------------|-------------|
| `meh + s` | Dia | Primary web browser on space 3 |
| `meh + e` | Ego | Lightweight browser on display 1, space 6 |
| `meh + d` | Arc | Browser on space 13 |
| `meh + z` | Zen Browser | Alternative browser |
| `meh + c` | Vivaldi | Browser on display 1, space 4 |
| `meh + k` | Slack | Team communication on space 9 |
| `meh + r` | Telegram | Messaging app on space 10 |
| `meh + u` | Zalo | Messaging app on space 11 |
| `meh + t` | Discord | Community chat on space 12 |
| `meh + y` | WhatsApp | Messaging app on space 12 |
| `meh + j` | Cliq | Team communication on space 14 |

### Productivity & AI Tools
| Shortcut | Application | Description |
|----------|-------------|-------------|
| `meh + 1` | 1Password | Password manager |
| `meh + v` | Grok Bot | Grok desktop app on space 16 |
| `meh + l` | Perplexity | AI search engine |
| `meh + i` | Structured | Task and time management |
| `meh + w` | LibreOffice | Office suite on space 2 |
| `meh + p` | Foxit PDF Reader | PDF reader on space 6 |
| `meh + o` | Preview | macOS preview app on space 6 |
| `meh + n` | Obsidian | Notes on space 8 |
| `meh + m` | superwhisper | Voice input |
| `meh + q` | Apple Music | Music player |
| `meh + b` | Borumi | Productivity app |

## 🪟 Window Management

SKHD integrates with Yabai for powerful window management capabilities.

### Window Focus
| Shortcut | Action | Description |
|----------|--------|-------------|
| `ctrl + shift + h` | Focus West | Move focus to left window |
| `ctrl + shift + j` | Focus South | Move focus to bottom window |
| `ctrl + shift + k` | Focus North | Move focus to top window |
| `ctrl + shift + l` | Focus East | Move focus to right window |
| `ctrl + shift + tab` | Focus Stack | Toggle the visible window in a stacked space |

### Window Movement
| Shortcut | Action | Description |
|----------|--------|-------------|
| `cmd + shift + h` | Warp West | Move window to the left |
| `cmd + shift + l` | Warp East | Move window to the right |

### Window Resizing
| Shortcut | Action | Description |
|----------|--------|-------------|
| `hyper + left` | Resize Left | Decrease width from left |
| `hyper + down` | Resize Down | Increase height downward |
| `hyper + up` | Resize Up | Decrease height upward |
| `hyper + right` | Resize Right | Increase width to right |

### Space Management
| Shortcut | Action | Description |
|----------|--------|-------------|
| `hyper + 1-9` | Send to Space | Move window to specific space |
| `hyper + tab` | Send to Recent | Move window to recent space |
| `cmd + ctrl + 1-4` | Move & Follow | Move window and follow to space |
| `cmd + ctrl + ←/→` | Move to Display | Move window to previous/next display and follow |

### Layout Controls
| Shortcut | Action | Description |
|----------|--------|-------------|
| `hyper + e` | Balance Windows | Equalize window sizes |
| `hyper + w` | Wide Split | Left or top side of the focused split takes 80% |
| `hyper + f` | Toggle Fullscreen | Zoom fullscreen |
| `shift + alt + f` | Native Fullscreen | macOS native fullscreen |
| `shift + alt + space` | Toggle Float | Float/unfloat window |
| `alt + r` | Rotate Clockwise | Rotate layout 270° |
| `shift + alt + r` | Rotate Counter | Rotate layout 90° |

### Gap Controls
| Shortcut | Action | Description |
|----------|--------|-------------|
| `hyper + i` | Toggle Gaps | Enable/disable gaps and padding |
| `hyper + o` | Toggle Padding | Toggle padding only |

## ⚙️ Configuration

### Configuration File
- **Location**: `dotfiles/skhd/.config/skhd/skhdrc`
- **Reload**: `skhd --restart-service`

### Key Modifier Definitions
```bash
# Modifier key definitions
meh = ctrl + alt + shift          # Primary modifier for apps
hyper = ctrl + alt + cmd + shift  # Secondary modifier for window management
```

### Adding New Shortcuts

#### Application Shortcuts
```bash
# Template for new application
meh - [key] : open "/Applications/AppName.app"

# Example: Add new app
meh - q : open "/Applications/Notion.app"
```

#### Window Management Shortcuts
```bash
# Template for window actions
[modifier] - [key] : yabai -m window --[action] [parameters]

# Example: New resize shortcut
hyper - 0 : yabai -m space --balance
```

### Service Management
```bash
# Start SKHD service
brew services start skhd

# Stop SKHD service
brew services stop skhd

# Restart SKHD service
brew services restart skhd
skhd --restart-service

# Check service status
brew services list | grep skhd
```

## 🔧 Troubleshooting

### Common Issues

#### Shortcuts Not Working
```bash
# Check if SKHD is running
ps aux | grep skhd

# Restart SKHD service
skhd --restart-service

# Check for configuration errors
skhd --verbose
```

#### Permission Issues
```bash
# SKHD needs accessibility permissions
# Go to: System Preferences → Security & Privacy → Privacy → Accessibility
# Add and enable: /usr/local/bin/skhd
```

#### Application Not Opening
```bash
# Verify application path
ls "/Applications/AppName.app"

# Check if application exists
mdfind "kMDItemDisplayName == 'AppName'"

# Test opening manually
open "/Applications/AppName.app"
```

#### Conflicts with Other Apps
```bash
# Check for conflicting shortcuts
# Some apps may override global shortcuts

# Use different modifier combinations
# Consider using hyper instead of meh for some shortcuts
```

### Configuration Debugging

#### Test Configuration
```bash
# Check configuration syntax
skhd --config-file ~/.config/skhd/skhdrc --verbose

# Monitor key events
skhd --observe

# Reload configuration
skhd --reload
```

#### Key Code Discovery
```bash
# Find key codes for special keys
skhd --observe
# Press the key you want to map
# Note the key code displayed
```

### Performance Optimization

#### Reduce Latency
```bash
# Minimize delay in shortcuts
# Avoid complex shell commands in shortcuts
# Use direct application paths instead of scripts when possible
```

#### Memory Usage
```bash
# Monitor SKHD memory usage
ps aux | grep skhd

# SKHD should use minimal memory
# If high usage, check for configuration loops
```

## 📚 Advanced Configuration

### Conditional Shortcuts
```bash
# Different shortcuts based on active application
# Example: Different behavior in terminal vs browser
```

### Mode-Based Shortcuts
```bash
# Create different modes for different workflows
# Example: Development mode vs presentation mode
```

### Integration with Scripts
```bash
# Call custom scripts from shortcuts
meh - p : ~/.local/bin/project-setup.sh

# Pass parameters to scripts
meh - shift - p : ~/.local/bin/project-setup.sh --template react
```

### Dynamic Application Detection
```bash
# Open different apps based on context
# Example: Open appropriate terminal based on current project
```

## 🔗 Integration

### Yabai Integration
- Window management shortcuts directly control Yabai
- Seamless tiling and space management
- Consistent modifier keys across both tools

### Tmux Integration
- Application shortcuts work from within tmux sessions
- Terminal applications respect tmux session context

### Neovim Integration
- Shortcuts work while Neovim is focused
- No conflicts with Neovim's key mappings

---

## 📖 Related Documentation
- [SKHD Configuration](https://github.com/vanducng/dotfiles/blob/main/dotfiles/skhd/.config/skhd/skhdrc)
- [Window Management](/troubleshooting/window-management/)
- [Troubleshooting Guide](/troubleshooting/)
