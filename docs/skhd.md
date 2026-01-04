# ⌨️ SKHD - Simple Hotkey Daemon

SKHD provides global hotkeys for seamless application launching and window management integration with Yabai.

## 📋 Table of Contents
- [Overview](#overview)
- [Application Shortcuts](#application-shortcuts)
- [Window Management](#window-management)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)

## 🎯 Overview

SKHD (Simple Hotkey Daemon) is a lightweight hotkey daemon for macOS that enables global keyboard shortcuts. It's tightly integrated with Yabai for window management and provides quick access to frequently used applications.

### Key Features
- **Global Hotkeys**: System-wide keyboard shortcuts
- **Application Launching**: Quick access to development tools
- **Window Management**: Integration with Yabai tiling
- **Modifier Keys**: Uses `meh` (ctrl+alt+cmd) and `hyper` (ctrl+alt+cmd+shift)

## 🚀 Application Shortcuts

All application shortcuts use the `meh` key (ctrl+alt+cmd) for consistency and to avoid conflicts.

### Development Tools
| Shortcut | Application | Description |
|----------|-------------|-------------|
| `meh + a` | Ghostty | Primary terminal emulator |
| `meh + w` | Windsurf | AI-powered IDE |
| `meh + x` | VSCode | Microsoft Visual Studio Code |
| `meh + v` | Cursor | AI-powered code editor |
| `meh + d` | DBeaver | Database management tool |

### Browsers & Communication
| Shortcut | Application | Description |
|----------|-------------|-------------|
| `meh + s` | Arc | Primary web browser |
| `meh + m` | Firefox | Secondary browser |
| `meh + j` | Zen Browser | Alternative browser |
| `meh + k` | Slack | Team communication |
| `meh + r` | Zalo | Messaging app |
| `meh + g` | Discord | Community chat |
| `meh + z` | Zoom | Video conferencing |
| `meh + t` | Microsoft Teams | Enterprise communication |

### Productivity & AI Tools
| Shortcut | Application | Description |
|----------|-------------|-------------|
| `meh + o` | Obsidian | Note-taking and knowledge management |
| `meh + u` | Claude | AI assistant |
| `meh + l` | Perplexity | AI search engine |
| `meh + b` | Linear | Project management |
| `meh + i` | Structured | Task and time management |
| `meh + e` | LibreOffice | Office suite |

## 🪟 Window Management

SKHD integrates with Yabai for powerful window management capabilities.

### Window Focus
| Shortcut | Action | Description |
|----------|--------|-------------|
| `ctrl + shift + h` | Focus West | Move focus to left window |
| `ctrl + shift + j` | Focus South | Move focus to bottom window |
| `ctrl + shift + k` | Focus North | Move focus to top window |
| `ctrl + shift + l` | Focus East | Move focus to right window |

### Window Movement
| Shortcut | Action | Description |
|----------|--------|-------------|
| `cmd + shift + h` | Warp West | Move window to the left |
| `cmd + shift + j` | Warp South | Move window down |
| `cmd + shift + k` | Warp North | Move window up |
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
| `hyper + x` | Send to Recent | Move window to recent space |
| `cmd + ctrl + 1-4` | Move & Follow | Move window and follow to space |

### Layout Controls
| Shortcut | Action | Description |
|----------|--------|-------------|
| `hyper + e` | Balance Windows | Equalize window sizes |
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
meh = ctrl + alt + cmd          # Primary modifier for apps
hyper = ctrl + alt + cmd + shift # Secondary modifier for window management
```

### Adding New Shortcuts

#### Application Shortcuts
```bash
# Template for new application
meh - [key] : open "/Applications/AppName.app"

# Example: Add new app
meh - n : open "/Applications/Notion.app"
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
- [SKHD Configuration](../dotfiles/skhd/.config/skhd/skhdrc)
- [Yabai Window Management](yabai.md)
- [Application Setup](applications.md)
- [Troubleshooting Guide](troubleshooting.md)