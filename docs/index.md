---
title: Home
description: AI-enhanced macOS development environment documentation
---

# Duc's Digital Workspace

Welcome to the comprehensive documentation for this modern macOS development environment. Quick setup, configuration guides, and troubleshooting for all tools.

## Getting Started

- [Installation Guide](installation.md) - Complete setup from scratch
- [Quick Reference](quick-reference.md) - Essential commands and shortcuts
- [Troubleshooting](troubleshooting.md) - Common issues and solutions

## Core Tools Documentation

**Terminal & Multiplexing:**
- [Tmux Setup](tmux.md) - Terminal multiplexer configuration
- [Atuin](atuin.md) - Shell history and sync

**Window Management:**
- [SKHD Configuration](skhd.md) - Hotkey daemon setup

**Editors & IDE:**
- [Neovim Configuration](neovim/README.md) - AstroNvim v5 setup

**Development Workflows:**
- [Zen Mode](zen-mode.md) - Distraction-free coding with Tmux
- [AI Workflows](ai/workflows.md) - Best practices for AI-assisted coding

## Quick Help

### Common Commands

```bash
# Restart services
brew services restart yabai
brew services restart skhd

# Reload configurations
tmux source-file ~/.tmux.conf
source ~/.zshrc

# Update plugins
:Lazy sync  # In Neovim
prefix + I  # In Tmux
```

### Emergency Recovery

```bash
# If window manager breaks
killall yabai skhd
brew services restart yabai

# If terminal breaks
/Applications/Ghostty.app/Contents/MacOS/ghostty
```

## Documentation Structure

1. **Installation** - Setup procedures and requirements
2. **Quick Reference** - Shortcuts and common commands
3. **Tool-Specific Guides** - Detailed configuration docs
4. **Troubleshooting** - Debug and fix common issues
5. **Workflows** - AI integration and daily patterns

## File & Links

- [Codebase Summary](../docs/codebase-summary.md) - Project structure overview
- [Main README](../README.md) - Feature highlights and badges
- [Neovim Docs](../dotfiles/nvim/.config/nvim/docs/) - AI tools and plugins
