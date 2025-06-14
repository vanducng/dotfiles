# OpenCode.md - Dotfiles Repository Guide

## Commands
- `make stow-install` - Install dotfiles using GNU stow
- `make stow-clean` - Remove dotfiles symlinks
- `./scripts/macos-deps.sh` - Install macOS dependencies
- `./scripts/yabai-upgrade.sh` - Upgrade yabai window manager

## Code Style Guidelines
- **Shell Scripts**: Use shebang (`#!/bin/zsh` or `#!/bin/bash`) at the beginning
- **Functions**: Define with `function name() {` syntax in shell scripts
- **Variables**: Use uppercase for constants (e.g., `STOW_FOLDERS`, `YABAI_CERT`)
- **Indentation**: Use tabs in Makefiles, spaces (2-4) in shell scripts
- **Comments**: Prefix with `#` for shell scripts, explain complex operations
- **Error Handling**: Check command success with conditionals (`if`, `grep -q`)
- **Path Handling**: Use `$HOME` instead of `~` in scripts for better compatibility
- **Command Substitution**: Prefer `$()` over backticks
- **Quoting**: Always quote variables that might contain spaces

## Repository Structure
- `dotfiles/` - Configuration files organized by application
- `scripts/` - Utility scripts for system setup and maintenance
- `wiki/` - Documentation and reference materials