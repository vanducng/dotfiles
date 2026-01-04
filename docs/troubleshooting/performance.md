# Performance & System Recovery

## Slow Startup

### Neovim Startup
```bash
# Profile startup time
nvim --startuptime startup.log
cat startup.log | sort -k2 -n

# Identify slow plugins
:Lazy profile
```

### System Performance
```bash
# Check resources
top -o cpu
top -o mem

# Check processes
ps aux | grep -E "(yabai|skhd|nvim|tmux)"

# Disk usage
df -h
du -sh ~/.local ~/.cache
```

## Memory Issues

### High Memory Usage
```bash
# Check by process
ps aux | sort -k4 -nr | head -10

# Clear caches
rm -rf ~/.cache/nvim
rm -rf ~/.local/share/nvim

# Restart services
brew services restart yabai
brew services restart skhd
```

### Swap Usage
```bash
# Check swap
sysctl vm.swapusage

# Clear inactive memory
sudo purge
```

## System Recovery

### Window Manager Reset
```bash
# Stop all services
brew services stop yabai
brew services stop skhd
killall yabai skhd

# Clear caches
rm -rf ~/.cache/yabai
rm -rf ~/.cache/skhd

# Restart
brew services start yabai
brew services start skhd
```

### Neovim Reset
```bash
# Backup current config
mv ~/.config/nvim ~/.config/nvim.backup
mv ~/.local/share/nvim ~/.local/share/nvim.backup
mv ~/.cache/nvim ~/.cache/nvim.backup

# Reinstall
cd ~/.dotfiles
make stow-install
nvim  # Plugins reinstall automatically
```

### Tmux Reset
```bash
# Kill all sessions
tmux kill-server

# Clear plugins
rm -rf ~/.tmux/plugins

# Reinstall TPM
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Start new session, then prefix + I to install plugins
tmux new-session
```

## Diagnostic Commands

### System Information
```bash
sw_vers                              # macOS version
system_profiler SPHardwareDataType   # Hardware info
df -h                                # Disk space
vm_stat                              # Memory usage
top -l 1 | grep "CPU usage"          # CPU usage
```

### Service Status
```bash
brew services list
brew services list | grep -E "(yabai|skhd)"
ps aux | grep -E "(yabai|skhd|nvim|tmux)"
```

### Log Files
```bash
# Yabai logs
tail -f /usr/local/var/log/yabai/yabai.out.log
tail -f /usr/local/var/log/yabai/yabai.err.log

# System logs
log show --predicate 'process == "yabai"' --last 1h
```
