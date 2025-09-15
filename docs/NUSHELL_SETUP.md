# 🐚 Nushell Configuration Guide

Nushell is configured as the primary shell with Ghostty terminal integration, featuring a PowerLevel10k-inspired lean theme and modern shell capabilities.

## 🚀 Quick Start

### Prerequisites
- Nushell installed via Homebrew (`brew install nushell`)
- Starship prompt (`brew install starship`)
- Nerd Font installed for proper icons

### Initial Setup
1. Nushell is automatically set as default in Ghostty
2. Configuration is managed through GNU Stow
3. Starship provides P10K-inspired lean theme

## 📁 Configuration Structure

```
nushell/.config/nushell/
├── config.nu              # Main configuration
├── env.nu                 # Environment variables & PATH
├── modules/
│   ├── aliases.nu         # Command shortcuts
│   ├── functions.nu       # Essential functions
│   └── tools.nu          # Tool integrations
├── scripts/
│   ├── nvim-integration.nu # Neovim helpers
│   └── starship-theme.nu  # Theme switcher
├── starship-lean.toml     # P10K-inspired lean theme
└── starship-full.toml     # Full theme option
```

## ⚡ Key Features

### Modern Shell Capabilities
- **Structured Data**: Built-in JSON, CSV, TOML processing
- **Fuzzy Completion**: Smart command completion
- **Vi-mode Editing**: Vim-style command line editing
- **Type System**: Strong typing with error checking

### Tool Integration
- **Atuin**: Intelligent command history with sync
- **Zoxide**: Smart directory navigation
- **Direnv**: Automatic environment loading
- **Yazi**: File manager with directory change

### Prompt Themes
- **Lean Theme**: P10K-inspired single-line prompt
- **Full Theme**: Comprehensive information display
- **Easy Switching**: Commands to toggle between themes

## 🎨 Starship Themes

### Lean Theme (Default)
```
~/project on main [!2?1] ❯
```
- Minimal single-line format
- Directory + Git branch + Status + Arrow
- Time and duration on right side
- Clean, fast, distraction-free

### Full Theme
```
~/project on main [!2?1] 🐍3.11 ☁️aws-prod
❯
```
- Multi-line with more context
- Language versions, cloud context
- All original Starship modules

### Theme Commands
```nushell
starship-lean      # Switch to lean theme
starship-full      # Switch to full theme
starship-info      # Show current theme
```

## 🛠️ Available Functions

### File & Directory Operations
```nushell
yy [args]                    # Yazi file manager with cd
nvim-select                  # Select and edit file with Neovim
nvim-config [type]           # Quick edit config files
edit-config                  # Edit Nushell config
edit-env                     # Edit Nushell environment
```

### Git & GitHub Integration
```nushell
ghcs <command>               # GitHub Copilot suggest
ghce <command>               # GitHub Copilot explain
```

### System Utilities
```nushell
sysinfo                      # System information
weather [city]               # Weather report
note <title> <content>       # Quick note taking
backup <file>                # Quick file backup
```

## 📝 Configuration Examples

### Adding Custom Functions
```nushell
# In ~/.config/nushell/modules/functions.nu
export def my-function [param: string] {
    print $"Hello ($param)!"
}
```

### Environment Variables
```nushell
# In ~/.config/nushell/env.nu
$env.MY_VAR = "value"
path add "/my/custom/path"
```

### Custom Aliases
```nushell
# In ~/.config/nushell/modules/aliases.nu
export alias ll = ls -la
export alias g = git
```

## 🔧 Keybindings

### Vi-mode Navigation
- `jk` - Escape to normal mode (in insert mode)
- `Ctrl+L` - Clear screen
- `Ctrl+G` - Tmux sessionizer

### Prompt Indicators
- `:` - Vi insert mode
- `〉` - Vi normal mode
- `:::` - Multi-line continuation

## 🚀 Advanced Features

### Structured Data Processing
```nushell
# JSON processing
curl https://api.github.com/users/octocat | from json | get name

# CSV analysis
open data.csv | where age > 25 | get name

# Directory analysis
ls | where size > 1MB | sort-by modified -r
```

### Parallel Processing
```nushell
# Process multiple files in parallel
ls *.txt | each { |file|
    open $file.name | lines | length
} | math sum
```

### Custom Commands with Parameters
```nushell
def deploy [env: string, --dry-run] {
    if $dry_run {
        print $"Would deploy to ($env)"
    } else {
        print $"Deploying to ($env)"
    }
}
```

## 🔄 Migration from Zsh

### Key Differences
- **Syntax**: Different from POSIX shells
- **Data Types**: Structured data instead of text streams
- **Commands**: Built-in alternatives to Unix tools
- **Functions**: Different parameter syntax

### Common Migrations
```bash
# Zsh
find . -name "*.txt" | xargs grep "pattern"

# Nushell
ls **/*.txt | each { |file| open $file.name } | str join | str contains "pattern"
```

### Learning Resources
- **Interactive Help**: `help commands`
- **Command Info**: `help <command>`
- **Examples**: `<command> --help`
- **Book**: [Nushell Book](https://www.nushell.sh/book/)

## 🐛 Troubleshooting

### Common Issues

**Config not loading:**
```nushell
# Check config path
$nu.config-path

# Test config syntax
source ~/.config/nushell/config.nu
```

**Functions not available:**
```nushell
# Reload config (restart shell)
# Or check function definition
which my-function
```

**Theme not updating:**
```nushell
# Check Starship config
starship-info

# Manually switch themes
starship-lean
```

**Atuin deprecation warning:**
- This is a known issue with Atuin's Nushell integration
- Warning is harmless and doesn't affect functionality
- Will be resolved in future Atuin updates

## 📚 Resources

- [Nushell Official Book](https://www.nushell.sh/book/)
- [Starship Configuration](https://starship.rs/config/)
- [Catppuccin Color Schemes](https://catppuccin.com/)
- [Nerd Fonts](https://nerdfonts.com/)

## 🔄 Backup Strategy

Your Zsh configuration remains intact and can be accessed:
1. Change Ghostty config to use `/bin/zsh`
2. Or run `zsh` from within Nushell
3. All original aliases and functions preserved

This allows safe experimentation with Nushell while maintaining fallback options.