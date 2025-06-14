# Dotfiles Central Management

Guide for using dotfiles as the central management system for your development workflow.

## Overview

This dotfiles repository serves as the central hub for managing your entire development environment across multiple machines. It uses GNU Stow for symlink management and provides a comprehensive, reproducible setup.

## Key Commands

### Installation & Management
```bash
# Install all dotfiles configurations
make stow-install

# Remove all symlinks (clean uninstall)
make stow-clean

# Install system dependencies
./scripts/macos-deps.sh
```

### Alias Management (Atuin Integration)
```bash
# Export current aliases to version control
make export-aliases

# Import aliases from backup
make import-aliases

# Backup aliases to git
make backup-aliases
```

## Repository Structure

The dotfiles are organized by application in the `dotfiles/` directory:

```
dotfiles/
├── atuin/         # Intelligent shell history and sync
├── bin/           # Custom scripts and utilities
├── claude/        # Claude AI configuration
├── direnv/        # Environment variable management
├── ghostty/       # Ghostty terminal config
├── nvim/          # Neovim configuration (AstroNvim)
├── tmux/          # Terminal multiplexer config
├── yabai/         # Window manager config
├── skhd/          # Hotkey daemon config
├── zsh/           # Shell configuration
└── ...            # Additional tool configurations
```

## Adding New Tools

### 1. Create Configuration Directory
```bash
# Create new tool directory
mkdir -p dotfiles/newtool/.config/newtool

# Add configuration files
cp ~/.config/newtool/config.toml dotfiles/newtool/.config/newtool/
```

### 2. Update Makefile
```bash
# Edit Makefile to include new tool
vim Makefile

# Add to STOW_FOLDERS line
STOW_FOLDERS=... newtool
```

### 3. Install New Configuration
```bash
# Install the new dotfiles
make stow-install
```

## Workflow Best Practices

### Daily Workflow
1. **Morning Setup**: `make stow-install` ensures all configs are current
2. **Development**: Use configured tools with consistent settings
3. **End of Day**: Commit any configuration changes

### Configuration Changes
1. **Edit configs** in the dotfiles directory (not in home directory)
2. **Test changes** by running `make stow-install`
3. **Commit changes** to version control
4. **Push to remote** for backup and sync

### Multi-Machine Sync
1. **Clone repository** on new machine
2. **Run installation** with `make stow-install`
3. **Install dependencies** with `./scripts/macos-deps.sh`
4. **Sync aliases** with `make import-aliases`

## Key Features

### Centralized Management
- **Single source of truth** for all development tool configurations
- **Version controlled** changes with git history
- **Consistent environment** across all machines
- **Easy backup and restore** capabilities

### Tool Integration
- **AI Tools**: CodeCompanion, GitHub Copilot with ergonomic keybindings
- **Window Management**: Yabai + SKHD for tiling workflow
- **Terminal**: Tmux + Ghostty/Kitty with project sessionizer
- **Editor**: Neovim with AstroNvim and extensive plugin ecosystem
- **Shell**: Zsh with Atuin for intelligent history and alias management

### Automation
- **Makefile targets** for common operations
- **Scripts** for system setup and maintenance
- **Stow integration** for clean symlink management
- **Alias backup** system with Atuin integration

## Troubleshooting

### Common Issues
```bash
# If symlinks are broken
make stow-clean
make stow-install

# If new tool not working
# Check if added to STOW_FOLDERS in Makefile

# If aliases missing
make import-aliases

# If dependencies missing
./scripts/macos-deps.sh
```

### Verification
```bash
# Check symlink status
ls -la ~/.config/nvim  # Should point to dotfiles

# Verify tool configurations
nvim --version
tmux -V
yabai --version
```

## Maintenance

### Regular Tasks
- **Weekly**: Update plugins and tools
- **Monthly**: Review and clean up unused configurations
- **Quarterly**: Update system dependencies

### Backup Strategy
- **Git repository**: Primary backup and version control
- **Alias export**: `make backup-aliases` before major changes
- **Documentation**: Keep wiki updated with changes

## Integration Points

### With Development Workflow
- **Project Sessionizer**: Quick project switching with tmux
- **AI Assistance**: Integrated AI tools for coding
- **Database Tools**: Configured database development environment
- **Version Control**: Git integration with Lazygit

### With System Tools
- **Window Management**: Seamless app switching and layout
- **Shell Enhancement**: Intelligent history and command completion
- **Terminal Multiplexing**: Session management and persistence
- **File Management**: Integrated file operations with Oil.nvim

This dotfiles system provides a comprehensive, maintainable approach to development environment management that scales across multiple machines and evolves with your workflow needs.