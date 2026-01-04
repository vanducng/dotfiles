# 🔧 Troubleshooting Guide

Comprehensive troubleshooting guide for common issues in the development environment.

## 📋 Table of Contents
- [Quick Fixes](#quick-fixes)
- [Window Management](#window-management)
- [Terminal Issues](#terminal-issues)
- [Neovim Problems](#neovim-problems)
- [AI Tools](#ai-tools)
- [Database Connections](#database-connections)
- [Performance Issues](#performance-issues)
- [System Recovery](#system-recovery)

## ⚡ Quick Fixes

### Emergency Recovery Commands
```bash
# If window manager breaks
killall yabai skhd
brew services restart yabai
brew services restart skhd

# If terminal is broken
/Applications/Ghostty.app/Contents/MacOS/ghostty

# If tmux is unresponsive
tmux kill-server
tmux new-session

# If Neovim is stuck
:qa!  # Force quit all
pkill nvim  # From another terminal
```

### Service Restart Commands
```bash
# Restart all window management
skhd --restart-service
yabai --restart-service

# Restart individual services
brew services restart yabai
brew services restart skhd

# Check service status
brew services list | grep -E "(yabai|skhd)"
```

## 🪟 Window Management

### Yabai Issues

#### Windows Not Tiling
```bash
# Check if yabai is running
ps aux | grep yabai

# Verify yabai configuration
yabai --check-sa

# Restart yabai service
yabai --restart-service

# Check for configuration errors
tail -f /usr/local/var/log/yabai/yabai.out.log
tail -f /usr/local/var/log/yabai/yabai.err.log
```

#### Scripting Addition Not Working
```bash
# Reinstall scripting addition
sudo yabai --uninstall-sa
sudo yabai --install-sa

# Check System Integrity Protection status
csrutil status

# If SIP is enabled, disable specific protections:
# Boot into Recovery Mode (Cmd+R)
# Open Terminal and run:
# csrutil enable --without fs --without debug --without nvram
```

#### Spaces Not Working
```bash
# Check Mission Control settings
# System Preferences → Mission Control
# Ensure "Automatically rearrange Spaces" is disabled

# Reset spaces configuration
yabai -m space --destroy
yabai -m space --create

# Check space configuration
yabai -m query --spaces
```

### SKHD Issues

#### Shortcuts Not Working
```bash
# Check if skhd is running
ps aux | grep skhd

# Test skhd configuration
skhd --config-file ~/.config/skhd/skhdrc --verbose

# Monitor key events
skhd --observe

# Check for permission issues
# System Preferences → Security & Privacy → Privacy → Accessibility
# Ensure skhd has accessibility permissions
```

#### Application Not Opening
```bash
# Verify application path
ls "/Applications/AppName.app"

# Test opening manually
open "/Applications/AppName.app"

# Check for application conflicts
# Some apps may override global shortcuts
```

## 💻 Terminal Issues

### Tmux Problems

#### Sessions Not Persisting
```bash
# Check tmux server status
tmux list-sessions

# Kill and restart tmux server
tmux kill-server
tmux new-session

# Check tmux configuration
tmux source-file ~/.tmux.conf
```

#### Plugins Not Loading
```bash
# Reinstall TPM (Tmux Plugin Manager)
rm -rf ~/.tmux/plugins/tpm
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Install plugins
# Press prefix + I in tmux
```

#### Copy-Paste Not Working
```bash
# Install reattach-to-user-namespace (macOS)
brew install reattach-to-user-namespace

# Test clipboard functionality
echo "test" | pbcopy
pbpaste

# Check tmux clipboard configuration
tmux show-options -g set-clipboard
```

### Terminal Emulator Issues

#### Ghostty Not Starting
```bash
# Check Ghostty installation
ls /Applications/Ghostty.app

# Start from command line to see errors
/Applications/Ghostty.app/Contents/MacOS/ghostty

# Check configuration file
cat ~/.config/ghostty/config
```

#### Colors Not Working
```bash
# Check terminal color support
echo $TERM
echo $COLORTERM

# Test true color support
curl -s https://gist.githubusercontent.com/lifepillar/09a44b8cf0f9397465614e622979107f/raw/24-bit-color.sh | bash

# Verify terminal settings
infocmp $TERM
```

## 🚀 Neovim Problems

### Plugin Issues

#### Plugins Not Loading
```bash
# Check plugin status
:Lazy

# Reinstall all plugins
:Lazy clean
:Lazy sync

# Check for errors
:messages
:checkhealth lazy
```

#### LSP Not Working
```bash
# Check LSP status
:LspInfo

# Install language servers
:Mason

# Restart LSP
:LspRestart

# Check LSP logs
:LspLog
```

#### Treesitter Errors
```bash
# Update treesitter parsers
:TSUpdate

# Check treesitter status
:checkhealth nvim-treesitter

# Reinstall specific parser
:TSInstall python
```

### Configuration Issues

#### Startup Errors
```bash
# Start Neovim with verbose output
nvim --startuptime startup.log

# Check for configuration errors
:messages

# Test minimal configuration
nvim --clean
```

#### Key Bindings Not Working
```bash
# Check key mappings
:map
:nmap
:imap

# Test specific mapping
:verbose map <leader>ac
```

## 🤖 AI Tools

### CodeCompanion Issues

#### API Key Problems
```bash
# Check environment variable
echo $OPENAI_API_KEY

# Test API connectivity
curl -H "Authorization: Bearer $OPENAI_API_KEY" \
     https://api.openai.com/v1/models

# Set API key temporarily
:lua vim.env.OPENAI_API_KEY = "your-key-here"
```

#### Chat Not Responding
```bash
# Check network connectivity
ping api.openai.com

# Check rate limits
# Review OpenAI usage dashboard

# Restart CodeCompanion
:CodeCompanion reset
```

### GitHub Copilot Issues

#### Authentication Problems
```bash
# Check Copilot status
:Copilot status

# Re-authenticate
:Copilot auth

# Check Copilot logs
:Copilot log
```

#### Suggestions Not Appearing
```bash
# Enable Copilot
:Copilot enable

# Check if disabled for file type
:Copilot status

# Manually trigger suggestions
# Use Ctrl+] in insert mode
```

### NeoCodeium Issues

#### Setup Problems
```bash
# Check NeoCodeium status
:NeoCodeium status

# Re-authenticate
:NeoCodeium auth

# Check configuration
:lua print(vim.inspect(require("neocodeium").config))
```

## 🗄️ Database Connections

### Dbee Issues

#### Connection Failures
```bash
# Check dbee status
:Dbee

# Load connections manually
:DbeeLoadConnections

# Check connection file
cat ~/.cache/nvim/dbee/persistence.json
```

#### Snowflake MFA Problems
```bash
# Disable auto-connect
:lua require("config.dbee-helpers").disable_snowflake_autoconnect()

# Restore connections when needed
:DbeeRestoreSnowflake

# Manual connection
# Use dbee UI to connect manually
```

#### Query Execution Issues
```bash
# Check database connectivity
# Test connection outside of Neovim

# Verify SQL syntax
# Use database-specific tools to validate

# Check dbee logs
:messages
```

## ⚡ Performance Issues

### Slow Startup

#### Neovim Startup
```bash
# Profile startup time
nvim --startuptime startup.log
cat startup.log | sort -k2 -n

# Identify slow plugins
:Lazy profile

# Disable unnecessary plugins temporarily
```

#### System Performance
```bash
# Check system resources
top -o cpu
top -o mem

# Check for runaway processes
ps aux | grep -E "(yabai|skhd|nvim|tmux)"

# Monitor disk usage
df -h
du -sh ~/.local ~/.cache
```

### Memory Issues

#### High Memory Usage
```bash
# Check memory usage by process
ps aux | sort -k4 -nr | head -10

# Clear caches
rm -rf ~/.cache/nvim
rm -rf ~/.local/share/nvim

# Restart services
brew services restart yabai
brew services restart skhd
```

#### Swap Usage
```bash
# Check swap usage
sysctl vm.swapusage

# Clear inactive memory (if needed)
sudo purge
```

## 🔄 System Recovery

### Complete Reset

#### Window Manager Reset
```bash
# Stop all services
brew services stop yabai
brew services stop skhd

# Kill any remaining processes
killall yabai skhd

# Clear configuration caches
rm -rf ~/.cache/yabai
rm -rf ~/.cache/skhd

# Restart services
brew services start yabai
brew services start skhd
```

#### Neovim Reset
```bash
# Backup current configuration
mv ~/.config/nvim ~/.config/nvim.backup
mv ~/.local/share/nvim ~/.local/share/nvim.backup
mv ~/.cache/nvim ~/.cache/nvim.backup

# Reinstall configuration
cd ~/.dotfiles
make stow-install

# Start Neovim (plugins will reinstall)
nvim
```

#### Tmux Reset
```bash
# Kill all tmux sessions
tmux kill-server

# Clear tmux plugins
rm -rf ~/.tmux/plugins

# Reinstall TPM
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Start new session
tmux new-session
# Press prefix + I to install plugins
```

### Backup Recovery

#### Configuration Backup
```bash
# Create backup before major changes
tar -czf ~/dotfiles-backup-$(date +%Y%m%d).tar.gz ~/.dotfiles

# Restore from backup
tar -xzf ~/dotfiles-backup-YYYYMMDD.tar.gz -C ~/
```

#### Data Recovery
```bash
# Recover Neovim sessions
ls ~/.local/share/nvim/sessions/

# Recover tmux sessions (if using tmux-resurrect)
ls ~/.tmux/resurrect/

# Recover database connections
ls ~/.cache/nvim/dbee/
```

## 📊 Diagnostic Commands

### System Information
```bash
# macOS version
sw_vers

# Hardware information
system_profiler SPHardwareDataType

# Disk space
df -h

# Memory usage
vm_stat

# CPU usage
top -l 1 | grep "CPU usage"
```

### Service Status
```bash
# Check all brew services
brew services list

# Check specific services
brew services list | grep -E "(yabai|skhd)"

# Check process status
ps aux | grep -E "(yabai|skhd|nvim|tmux)"
```

### Log Files
```bash
# Yabai logs
tail -f /usr/local/var/log/yabai/yabai.out.log
tail -f /usr/local/var/log/yabai/yabai.err.log

# SKHD logs
tail -f /usr/local/var/log/skhd/skhd.out.log
tail -f /usr/local/var/log/skhd/skhd.err.log

# System logs
log show --predicate 'process == "yabai"' --last 1h
log show --predicate 'process == "skhd"' --last 1h
```

## 🆘 Getting Help

### Documentation Resources
- Check specific tool wiki pages
- Review configuration files in `dotfiles/`
- Check the main README for basic setup

### Community Support
- GitHub issues for specific tools
- Reddit communities (r/neovim, r/tmux)
- Discord servers for development tools

### Professional Support
- Consider professional support for critical issues
- Backup important work before major changes
- Document issues for future reference

---

## 📖 Related Documentation
- [Yabai Configuration](yabai.md)
- [SKHD Setup](skhd.md)
- [Neovim Guide](neovim/README.md)
- [Tmux Documentation](tmux.md)
- [AI Tools Setup](ai/)