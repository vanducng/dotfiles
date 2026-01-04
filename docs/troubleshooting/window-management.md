# Window Management Troubleshooting

## Yabai Issues

### Windows Not Tiling
```bash
# Check if yabai is running
ps aux | grep yabai

# Verify configuration
yabai --check-sa

# Restart service
yabai --restart-service

# Check logs
tail -f /usr/local/var/log/yabai/yabai.out.log
tail -f /usr/local/var/log/yabai/yabai.err.log
```

### Scripting Addition Not Working
```bash
# Reinstall scripting addition
sudo yabai --uninstall-sa
sudo yabai --install-sa

# Check SIP status
csrutil status

# If SIP enabled, boot into Recovery Mode (Cmd+R):
# csrutil enable --without fs --without debug --without nvram
```

### Spaces Not Working
```bash
# System Preferences → Mission Control
# Disable "Automatically rearrange Spaces"

# Reset spaces
yabai -m space --destroy
yabai -m space --create

# Check configuration
yabai -m query --spaces
```

## SKHD Issues

### Shortcuts Not Working
```bash
# Check if running
ps aux | grep skhd

# Test configuration
skhd --config-file ~/.config/skhd/skhdrc --verbose

# Monitor key events
skhd --observe

# Check permissions
# System Preferences → Security & Privacy → Privacy → Accessibility
```

### Application Not Opening
```bash
# Verify application path
ls "/Applications/AppName.app"

# Test opening manually
open "/Applications/AppName.app"
```
