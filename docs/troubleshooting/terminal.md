# Terminal Troubleshooting

## Tmux Problems

### Sessions Not Persisting
```bash
# Check server status
tmux list-sessions

# Kill and restart
tmux kill-server
tmux new-session

# Reload configuration
tmux source-file ~/.tmux.conf
```

### Plugins Not Loading
```bash
# Reinstall TPM
rm -rf ~/.tmux/plugins/tpm
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Install plugins: prefix + I in tmux
```

### Copy-Paste Not Working
```bash
# Install reattach-to-user-namespace (macOS)
brew install reattach-to-user-namespace

# Test clipboard
echo "test" | pbcopy
pbpaste

# Check tmux clipboard config
tmux show-options -g set-clipboard
```

## Ghostty Issues

### Not Starting
```bash
# Check installation
ls /Applications/Ghostty.app

# Start with errors visible
/Applications/Ghostty.app/Contents/MacOS/ghostty

# Check config
cat ~/.config/ghostty/config
```

### Colors Not Working
```bash
# Check terminal support
echo $TERM
echo $COLORTERM

# Test true color
curl -s https://gist.githubusercontent.com/lifepillar/09a44b8cf0f9397465614e622979107f/raw/24-bit-color.sh | bash

# Verify settings
infocmp $TERM
```
