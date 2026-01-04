---
title: Home
description: Comprehensive AI-enhanced development environment for macOS
---

# Duc's Digital Workspace

Welcome to the comprehensive documentation for this modern macOS development environment. This wiki contains detailed guides, troubleshooting tips, and configuration options for all components.

## Getting Started

- [Installation Guide](installation.md) - Complete setup instructions
- [Quick Reference](quick-reference.md) - Essential commands and shortcuts

## Core Tools

- [Neovim](neovim/README.md) - Editor configuration and plugins
- [Zen Mode](zen-mode.md) - Distraction-free coding environment
- [Tmux](tmux.md) - Terminal multiplexer setup and workflows
- [Atuin](atuin.md) - Intelligent shell history and sync
- [SKHD](skhd.md) - Hotkey daemon configuration

## AI Tools

- [AI Workflows](ai/workflows.md) - Best practices and tips for AI-assisted development

## Workflows

- [Development Workflows](workflows/development.md) - Daily development patterns
- [Temporal](temporal.md) - Workflow orchestration

## Quick Help

### Common Commands

```bash
# Restart window manager
skhd --restart-service
yabai --restart-service

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
brew services restart skhd

# If terminal is broken
/Applications/Ghostty.app/Contents/MacOS/ghostty
```

### Getting Help

- Check the [Troubleshooting Guide](troubleshooting.md)
- Review configuration files in `dotfiles/`
- Check the main README for basic setup
