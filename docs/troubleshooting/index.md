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

<div class="dt-card-grid" markdown>
<div class="dt-card" markdown>

### [Window Management](window-management.md)

Yabai tiling issues, SKHD shortcut conflicts, and spaces configuration.

</div>
<div class="dt-card" markdown>

### [Terminal](terminal.md)

Tmux session problems, Ghostty issues, and color/rendering fixes.

</div>
<div class="dt-card" markdown>

### [Neovim](neovim.md)

Plugin failures, LSP errors, and Neovim config troubleshooting.

</div>
<div class="dt-card" markdown>

### [AI Tools](ai-tools.md)

CodeCompanion, Supermaven, and miudb database AI issues.

</div>
<div class="dt-card" markdown>

### [Performance](performance.md)

Slow startup, high memory usage, and system recovery steps.

</div>
</div>
