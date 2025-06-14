
# 📚 Development Environment Wiki

Welcome to the comprehensive wiki for this modern macOS development environment. This wiki contains detailed guides, troubleshooting tips, and advanced configuration options for all components of the setup.

## 📖 Table of Contents

### 🚀 Getting Started
- [Installation Guide](installation.md) - Complete setup instructions
- [First Steps](first-steps.md) - What to do after installation
- [Quick Reference](quick-reference.md) - Essential commands and shortcuts

### 🛠️ Core Tools
- [Neovim](neovim/README.md) - Editor configuration and plugins
- [Tmux](tmux.md) - Terminal multiplexer setup and workflows
- [Zsh](zsh.md) - Shell configuration and customization
- [Atuin](atuin.md) - Intelligent shell history and sync
- [Yabai](yabai.md) - Window manager setup and rules
- [SKHD](skhd.md) - Hotkey daemon configuration

### 🤖 AI Tools
- [CodeCompanion](ai/codecompanion.md) - AI chat and inline assistance
- [GitHub Copilot](ai/copilot.md) - Primary AI code completion with ergonomic keybindings
- [AI Workflows](ai/workflows.md) - Best practices and tips

### 🗄️ Database Development
- [Database Setup](database/setup.md) - Database tools configuration
- [Snowflake Integration](database/snowflake.md) - Snowflake-specific setup
- [SQL Workflows](database/workflows.md) - Database development patterns

### 🎨 Customization
- [Themes](customization/themes.md) - Color schemes and appearance
- [Keybindings](customization/keybindings.md) - Custom shortcuts
- [Plugins](customization/plugins.md) - Adding new functionality
- [Scripts](customization/scripts.md) - Custom automation

### 🔧 Advanced Topics
- [Performance Tuning](advanced/performance.md) - Optimization tips
- [Backup & Sync](advanced/backup.md) - Configuration backup strategies
- [Multiple Machines](advanced/multi-machine.md) - Setup across devices
- [Troubleshooting](troubleshooting.md) - Common issues and solutions

### 📋 Reference
- [Cheat Sheets](reference/cheatsheets.md) - Quick command references
- [Configuration Files](reference/configs.md) - File structure overview
- [External Resources](reference/resources.md) - Useful links and documentation

### 🔄 Workflows
- [Development Workflows](workflows/development.md) - Daily development patterns
- [Project Management](workflows/projects.md) - Project organization
- [Data Engineering](workflows/data-engineering.md) - Data-specific workflows
- [Temporal](temporal.md) - Workflow orchestration

---

## 🆘 Quick Help

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
- Check the specific tool's wiki page
- Look in the troubleshooting section
- Review configuration files in `dotfiles/`
- Check the main README for basic setup

---

*Last updated: $(date)*
