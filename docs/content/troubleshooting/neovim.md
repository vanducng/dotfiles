---
title: "Neovim Troubleshooting"
---

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

### `GLIBC_2.39 not found` on Linux

Mason's `tree-sitter-cli` GitHub linux-x64 binary is linked against GLIBC 2.39 (Ubuntu 24.04). Ubuntu 22.04 ships GLIBC 2.35, so `:TSInstall` fails with:

```
tree-sitter: /lib/x86_64-linux-gnu/libc.so.6: version `GLIBC_2.39' not found
```

`make linux-deps` compiles `tree-sitter-cli` with cargo against the host libc and removes the broken Mason copy. nvim also drops a non-runnable Mason binary on startup.

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
