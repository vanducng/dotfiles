# 🕰️ Atuin - Intelligent Shell History

Atuin replaces your existing shell history with a SQLite database, and records additional context for your commands. It provides intelligent search, synchronization across machines, and powerful alias management.

## 📋 Table of Contents
- [Overview](#overview)
- [Key Features](#key-features)
- [Installation & Setup](#installation--setup)
- [Usage](#usage)
- [Alias Management](#alias-management)
- [Search & Navigation](#search--navigation)
- [Synchronization](#synchronization)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)

## 🎯 Overview

Atuin enhances your shell experience by:
- **Recording rich context** for every command (directory, exit code, duration, etc.)
- **Providing intelligent search** with fuzzy finding and filtering
- **Synchronizing history** across all your machines
- **Managing aliases** centrally with dotfiles integration
- **Offering statistics** and insights about your command usage

### Why Atuin?
- **Better than Ctrl+R**: Fuzzy search with context
- **Cross-machine sync**: Access history from any device
- **Rich metadata**: Know when, where, and how commands ran
- **Privacy-focused**: End-to-end encryption for sync
- **Alias management**: Centralized alias storage and sync

## ✨ Key Features

### 🔍 Intelligent Search
- **Fuzzy search**: Find commands even with typos
- **Context filtering**: Filter by directory, exit code, or time
- **Interactive UI**: Beautiful TUI for browsing history
- **Quick access**: Instant search with Ctrl+R

### 🔄 Cross-Machine Sync
- **Encrypted sync**: End-to-end encryption for privacy
- **Automatic backup**: Never lose command history
- **Multi-device**: Access from any machine
- **Conflict resolution**: Smart merging of histories

### 📝 Alias Management
- **Centralized storage**: All aliases in one place
- **Version control**: Track alias changes over time
- **Sync across machines**: Same aliases everywhere
- **Backup & restore**: Easy alias management

### 📊 Statistics & Insights
- **Command frequency**: See your most-used commands
- **Time tracking**: Know how long commands take
- **Success rates**: Track command failure rates
- **Usage patterns**: Understand your workflow

## 🚀 Installation & Setup

### Prerequisites
```bash
# Atuin is already included in dotfiles
# Installation happens automatically via stow-install
```

### Initial Setup
```bash
# 1. Install dotfiles (includes Atuin config)
make stow-install

# 2. Import existing shell history
atuin import auto

# 3. Set up sync account (optional)
atuin register -u <username> -e <email>
atuin login -u <username>

# 4. Start using Atuin
# Restart your shell or source ~/.zshrc
```

### Verification
```bash
# Check Atuin status
atuin status

# Test search functionality
atuin search git

# Verify configuration
atuin config list
```

## 💻 Usage

### Basic Commands
```bash
# Search history interactively
atuin search
# Or use Ctrl+R (replaces default shell search)

# Search for specific command
atuin search git commit

# Show recent history
atuin history list

# Get statistics
atuin stats
```

### Search Modes
```bash
# Fuzzy search (default)
atuin search git com  # Finds "git commit"

# Exact search
atuin search --exact "git commit -m"

# Filter by directory
atuin search --cwd /path/to/project git

# Filter by exit code
atuin search --exit 0  # Only successful commands
atuin search --exit 1  # Only failed commands
```

### Interactive Search (Ctrl+R)
- **Up/Down**: Navigate through results
- **Enter**: Execute selected command
- **Tab**: Edit command before executing
- **Ctrl+C**: Cancel search
- **Ctrl+D**: Delete selected entry

## 📝 Alias Management

### Current Aliases
The dotfiles include 38+ pre-configured aliases for common development tasks:

```bash
# Git aliases
g='git'
gs='git status'
gc='git checkout'
gp='git pull'
gP='git push'

# Development tools
v='nvim'
lg='lazygit'
d='docker'
dc='docker-compose'

# And many more...
```

### Managing Aliases

#### View Aliases
```bash
# List all aliases
atuin dotfiles alias list

# Search for specific alias
atuin dotfiles alias list | grep git
```

#### Add/Modify Aliases
```bash
# Add new alias
atuin dotfiles alias set myalias "my command"

# Update existing alias
atuin dotfiles alias set g "git --no-pager"

# Delete alias
atuin dotfiles alias delete myalias
```

#### Backup & Restore
```bash
# Export current aliases to file
make export-aliases

# Import aliases from file
make import-aliases

# Backup aliases to git
make backup-aliases
```

### Alias File Structure
```bash
# Location: dotfiles/atuin/.config/atuin/aliases.sh
#!/bin/bash
# Atuin Aliases - Generated on [date]
# Use 'atuin dotfiles alias set <n> <command>' to restore
# You can also execute this file directly: ./aliases.sh

atuin dotfiles alias set 'g' 'git'
atuin dotfiles alias set 'v' 'nvim'
# ... more aliases
```

## 🔍 Search & Navigation

### Search Syntax
```bash
# Basic search
atuin search term

# Multiple terms (AND)
atuin search git commit

# Exclude terms
atuin search git -commit

# Wildcard search
atuin search "git *"
```

### Filtering Options
```bash
# Filter by directory
atuin search --cwd ~/projects git

# Filter by date
atuin search --after "2024-01-01" deploy
atuin search --before "2024-12-31" backup

# Filter by duration
atuin search --duration 5s..  # Commands taking >5 seconds

# Filter by exit code
atuin search --exit 0 deploy  # Only successful deploys
```

### Advanced Search
```bash
# Search in specific session
atuin search --session-id <id> command

# Search by hostname
atuin search --host myserver deploy

# Combine filters
atuin search --cwd ~/work --exit 0 --after "2024-01-01" deploy
```

## 🔄 Synchronization

### Setup Sync
```bash
# Register new account
atuin register -u username -e email@example.com

# Login to existing account
atuin login -u username

# Verify sync status
atuin status
```

### Sync Operations
```bash
# Manual sync
atuin sync

# Force sync (resolve conflicts)
atuin sync --force

# Check sync status
atuin status
```

### Privacy & Security
- **End-to-end encryption**: History encrypted before upload
- **Local key**: Encryption key stored locally only
- **No plaintext**: Server never sees unencrypted commands
- **Open source**: Audit the code yourself

### Self-Hosting (Optional)
```bash
# Use custom sync server
atuin config set sync_address https://your-server.com

# Disable sync entirely
atuin config set auto_sync false
```

## ⚙️ Configuration

### Configuration File
- **Location**: `dotfiles/atuin/.config/atuin/config.toml`
- **Auto-loaded**: Via dotfiles stow installation

### Key Settings
```toml
# Search configuration
search_mode = "fuzzy"  # or "exact"
filter_mode = "global"  # or "session", "directory"

# Sync settings
auto_sync = true
sync_frequency = "1h"

# UI preferences
show_preview = true
max_preview_height = 4
show_help = true

# Privacy settings
secrets_filter = true  # Filter out potential secrets
```

### Customization
```bash
# Change search mode
atuin config set search_mode exact

# Disable auto-sync
atuin config set auto_sync false

# Change key bindings
atuin config set keymap_mode vim  # or emacs

# View all settings
atuin config list
```

### Shell Integration
```bash
# The dotfiles automatically configure:
# - Ctrl+R replacement
# - Up arrow enhancement
# - Command recording
# - Alias loading

# Manual integration (if needed)
echo 'eval "$(atuin init zsh)"' >> ~/.zshrc
```

## 🔧 Troubleshooting

### Common Issues

#### History Not Recording
```bash
# Check if atuin is properly initialized
echo $ATUIN_SESSION

# Verify shell integration
atuin status

# Restart shell
exec zsh
```

#### Search Not Working
```bash
# Check database
atuin doctor

# Rebuild search index
atuin search --rebuild-index

# Check for corrupted database
sqlite3 ~/.local/share/atuin/history.db "PRAGMA integrity_check;"
```

#### Sync Issues
```bash
# Check network connectivity
atuin status

# Re-authenticate
atuin logout
atuin login -u username

# Force sync
atuin sync --force
```

#### Aliases Not Loading
```bash
# Check alias configuration
atuin dotfiles alias list

# Reload aliases
source ~/.zshrc

# Import from backup
make import-aliases
```

### Performance Issues

#### Slow Search
```bash
# Check database size
du -h ~/.local/share/atuin/history.db

# Optimize database
atuin search --rebuild-index

# Limit history size
atuin config set max_history_length 100000
```

#### High Memory Usage
```bash
# Check atuin processes
ps aux | grep atuin

# Restart atuin daemon
atuin daemon stop
atuin daemon start
```

### Database Maintenance

#### Backup History
```bash
# Export history
atuin export > history-backup.json

# Backup database file
cp ~/.local/share/atuin/history.db ~/atuin-backup.db
```

#### Clean Up History
```bash
# Remove old entries (older than 1 year)
atuin history prune --days 365

# Remove entries from specific directory
atuin history delete --cwd /tmp

# Remove failed commands
atuin history delete --exit-code 1
```

## 📊 Statistics & Analytics

### Usage Statistics
```bash
# Overall stats
atuin stats

# Top commands
atuin stats --count 20

# Commands by directory
atuin stats --cwd ~/projects

# Time-based stats
atuin stats --after "2024-01-01"
```

### Insights
```bash
# Most used commands
atuin search --limit 0 | head -20

# Failed commands
atuin search --exit 1

# Long-running commands
atuin search --duration 10s..

# Commands by frequency
atuin stats | sort -nr
```

## 🔗 Integration

### Tmux Integration
- Works seamlessly with tmux sessions
- Each tmux pane has separate history context
- Session-aware search and filtering

### Neovim Integration
- Terminal commands within Neovim are recorded
- Search available in Neovim terminal mode
- Consistent experience across all shells

### Git Integration
- Git commands are tracked with repository context
- Easy to find commands by project
- Track deployment and release commands

---

## 📖 Related Documentation
- [Atuin Configuration](../dotfiles/atuin/.config/atuin/config.toml)
- [Alias Management Scripts](../scripts/export-atuin-aliases.sh)
- [Shell Configuration](zsh.md)
- [Development Workflows](workflows/development.md)
- [Quick Reference](quick-reference.md)