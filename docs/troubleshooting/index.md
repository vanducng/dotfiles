# Troubleshooting Guide

Quick fixes and recovery commands for common issues.

## Quick Fixes

### Emergency Recovery
```bash
# Window manager breaks
killall yabai skhd
brew services restart yabai
brew services restart skhd

# Terminal broken
/Applications/Ghostty.app/Contents/MacOS/ghostty

# Tmux unresponsive
tmux kill-server
tmux new-session

# Neovim stuck
:qa!  # Force quit all
pkill nvim  # From another terminal
```

### Service Restart
```bash
# Restart all window management
skhd --restart-service
yabai --restart-service

# Check status
brew services list | grep -E "(yabai|skhd)"
```

## Troubleshooting by Category

- **[Window Management](window-management.md)** - Yabai tiling, SKHD shortcuts, spaces
- **[Terminal](terminal.md)** - Tmux sessions, Ghostty, colors
- **[Neovim](neovim.md)** - Plugins, LSP, config errors
- **[AI Tools](ai-tools.md)** - CodeCompanion, Copilot, database AI
- **[Performance](performance.md)** - Slow startup, memory, system recovery
