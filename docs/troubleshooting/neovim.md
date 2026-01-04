# Neovim Troubleshooting

## Plugin Issues

### Plugins Not Loading
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

### LSP Not Working
```bash
# Check LSP status
:LspInfo

# Install language servers
:Mason

# Restart LSP
:LspRestart

# Check logs
:LspLog
```

### Treesitter Errors
```bash
# Update parsers
:TSUpdate

# Check status
:checkhealth nvim-treesitter

# Reinstall specific parser
:TSInstall python
```

## Configuration Issues

### Startup Errors
```bash
# Verbose output
nvim --startuptime startup.log

# Check errors
:messages

# Test minimal config
nvim --clean
```

### Key Bindings Not Working
```bash
# Check mappings
:map
:nmap
:imap

# Test specific mapping
:verbose map <leader>ac
```
