# 🚀 Neovim - AI-Enhanced Code Editor

A comprehensive Neovim setup based on AstroNvim v5 with extensive AI integration, database tools, and modern development features.

## 📋 Table of Contents
- [Overview](#overview)
- [Key Features](#key-features)
- [Installation & Setup](#installation--setup)
- [Key Bindings](#key-bindings)
- [AI Tools](#ai-tools)
- [Database Development](#database-development)
- [Plugin Management](#plugin-management)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)

## 🎯 Overview

This Neovim configuration is built on **AstroNvim v5**, providing a modern, feature-rich development environment with:

- **AI Integration**: Multiple AI assistants for coding help
- **Database Tools**: Advanced SQL development with Snowflake support
- **LSP Support**: Language servers for multiple programming languages
- **Modern UI**: Beautiful interface with treesitter syntax highlighting
- **Project Management**: Seamless integration with tmux sessionizer

### Base Framework
- **AstroNvim v5**: Modern Neovim distribution
- **Lazy.nvim**: Fast plugin manager
- **Mason**: LSP, formatter, and linter installer
- **Treesitter**: Advanced syntax highlighting

## ✨ Key Features

### 🤖 AI-Powered Development
- **CodeCompanion**: AI chat and inline assistance
- **GitHub Copilot**: Primary AI code completion with ergonomic keybindings
- **Database AI**: AI-powered SQL assistance
- **Streamlined AI System**: Simplified, conflict-free AI completion

### 🗄️ Database Development
- **nvim-dbee**: Advanced database explorer
- **Snowflake Integration**: MFA support and connection management
- **SQL Completion**: AI-powered SQL suggestions
- **Query Execution**: Run queries directly from editor

### 🛠️ Development Tools
- **LSP Integration**: Language servers for 20+ languages
- **Debugging**: DAP integration for multiple languages
- **Testing**: Integrated test runners
- **Git Integration**: Advanced git workflows
- **File Management**: Oil.nvim for file operations

### 🎨 UI & Experience
- **Custom Dashboard**: Branded startup screen
- **Catppuccin Theme**: Beautiful, consistent theming
- **Status Line**: Rich status information
- **Notifications**: Snacks.nvim for beautiful notifications

## 🚀 Installation & Setup

### Prerequisites
```bash
# Install Neovim (latest stable)
brew install neovim

# Install required dependencies
brew install ripgrep fd fzf git
```

### Configuration Installation
The configuration is automatically installed via the dotfiles setup:
```bash
# Via dotfiles installation
make stow-install

# Or manually symlink
ln -sf ~/.dotfiles/dotfiles/nvim/.config/nvim ~/.config/nvim
```

### First Launch
1. **Open Neovim**: `nvim`
2. **Plugin Installation**: Plugins install automatically
3. **LSP Setup**: Run `:Mason` to install language servers
4. **AI Setup**: Configure API keys (see AI Tools section)

### Post-Installation
```bash
# Install language servers
:Mason

# Update plugins
:Lazy sync

# Check health
:checkhealth
```

## ⌨️ Key Bindings

### Leader Keys
- **Leader**: `<Space>`
- **Local Leader**: `,`

### Essential Shortcuts
| Shortcut | Action | Description |
|----------|--------|-------------|
| `<C-f>` | Project Sessionizer | Open tmux project picker |
| `-` | File Manager | Open Oil.nvim file manager |
| `<leader>k` | Previous Buffer | Switch to last buffer |
| `<leader>K` | Next Tab | Go to next tab |

### AI Assistance
| Shortcut | Action | Description |
|----------|--------|-------------|
| `<leader>ac` | AI Chat | Open CodeCompanion chat |
| `<leader>aa` | AI Actions | Show AI action menu |
| `<leader>at` | Toggle Chat | Toggle AI chat window |
| `<leader>aC` | Add to Chat | Add selection to chat |
| `<leader>ae` | Explain Code | AI code explanation |
| `<leader>ar` | Review Code | AI code review |
| `<leader>af` | Fix Code | AI code fixes |
| `<leader>ao` | Optimize Code | AI optimization suggestions |

### AI Completion (GitHub Copilot)
| Shortcut | Action | Description |
|----------|--------|-------------|
| `<Tab>` | Accept/Tab | Accept suggestion or normal tab |
| `<C-;>` | Accept Full | Accept complete suggestion |
| `<C-y>` | Accept Alt | Accept suggestion (alternative) |
| `<C-'>` | Accept Word | Accept next word |
| `<C-]>` | Accept Line | Accept current line |
| `<C-[>` | Previous | Previous suggestion |
| `<C-\>` | Next | Next suggestion |
| `<C-BS>` | Dismiss | Dismiss current suggestion |

### Zen Mode & Focus
| Shortcut | Action | Description |
|----------|--------|-------------|
| `<leader>z` | Zen Mode | Enter distraction-free mode (70% width) |
| `<leader>Z` | Full Screen Zen | Enter full-screen zen mode (100% width) |
| `<leader>zx` | Exit All Zen | Exit zen mode across all tmux panes |
| `<leader>tt` | Twilight | Toggle twilight (dim inactive code) |

### Database Tools
| Shortcut | Action | Description |
|----------|--------|-------------|
| `<leader>Dd` | Database Explorer | Open dbee database explorer |
| `<leader>Dx` | Disconnect All | Disconnect all active database connections |
| `x` | Toggle Connection | Toggle connection in dbee drawer |
| `<leader>Dt` | Toggle Database | Toggle database window |
| `<leader>De` | Execute Query | Run SQL query |
| `<leader>Ds` | Save Connection | Save database connection |

### File Operations
| Shortcut | Action | Description |
|----------|--------|-------------|
| `<leader>ff` | Find Files | Telescope file finder |
| `<leader>fw` | Find Word | Search in files |
| `<leader>fb` | Find Buffers | Open buffer list |
| `<leader>fh` | Find Help | Search help tags |
| `<leader>fr` | Recent Files | Recently opened files |

### LSP & Code
| Shortcut | Action | Description |
|----------|--------|-------------|
| `gd` | Go to Definition | Jump to definition |
| `gr` | Go to References | Find references |
| `gi` | Go to Implementation | Jump to implementation |
| `K` | Hover Documentation | Show documentation |
| `<leader>ca` | Code Actions | Show code actions |
| `<leader>cr` | Rename Symbol | Rename symbol |
| `<leader>cf` | Format Code | Format current buffer |

### Git Integration
| Shortcut | Action | Description |
|----------|--------|-------------|
| `<leader>gg` | Lazygit | Open Lazygit TUI |
| `<leader>gb` | Git Blame | Show git blame |
| `<leader>gd` | Git Diff | Show git diff |
| `<leader>gs` | Git Status | Show git status |

## 🤖 AI Tools

### CodeCompanion
**Primary AI assistant for chat and inline help**

#### Setup
1. **API Key**: Set your OpenAI API key
   ```bash
   export OPENAI_API_KEY="your-api-key"
   ```
2. **Configuration**: See `dotfiles/nvim/.config/nvim/docs/CODECOMPANION_USAGE.md`

#### Features
- **Chat Interface**: Full conversation with AI
- **Inline Assistance**: AI suggestions in code
- **Code Actions**: Context-aware AI actions
- **Multiple Models**: Support for different AI models

### GitHub Copilot
**Primary AI code completion with ergonomic keybindings**

#### Setup
1. **Install**: Already configured in dotfiles
2. **Authenticate**: `:Copilot auth`
3. **Enable**: `:Copilot enable`

#### Ergonomic Keybindings
The keybindings are designed for comfortable typing flow:
- **Left hand**: Holds `Ctrl` key
- **Right hand**: Reaches for target keys
- **Tab**: Smart accept or normal tab behavior

#### Key Features
- **Smart Tab**: Accepts suggestions when available, normal tab otherwise
- **Multiple Accept Options**: Full suggestion, word, or line
- **Easy Navigation**: Previous/next suggestions with bracket keys
- **Quick Dismiss**: Ctrl+Backspace for natural dismiss motion

#### Usage Commands
- **Panel**: `<leader>cp` to open Copilot panel
- **Status**: `<leader>cs` to check status
- **Enable/Disable**: `<leader>ce` / `<leader>cd`

## 🗄️ Database Development

### nvim-dbee
**Advanced database explorer and query tool**

#### Features
- **Connection Management**: Save and manage database connections
- **Query Execution**: Run SQL queries directly from Neovim
- **Result Viewing**: Beautiful result display
- **Snowflake Support**: Special handling for Snowflake MFA

#### Setup
1. **Open Database Explorer**: `<leader>Dd`
2. **Add Connection**: Use the UI to add database connections
3. **Save Connections**: Connections are saved automatically

#### Snowflake Integration
- **MFA Support**: Handles Snowflake multi-factor authentication
- **Auto-disable**: Prevents auto-connection to avoid MFA prompts
- **Manual Connection**: Connect only when needed

#### Usage
```sql
-- Execute query with BB (visual mode or normal mode)
SELECT * FROM my_table LIMIT 10;

-- Use completion for table names and columns
-- AI assistance for complex queries
```

### Database AI
- **SQL Generation**: AI-powered SQL query generation
- **Query Optimization**: AI suggestions for query improvements
- **Schema Understanding**: AI help with database schema

## 🔌 Plugin Management

### Lazy.nvim
**Modern plugin manager with lazy loading**

#### Commands
```bash
:Lazy                 # Open plugin manager
:Lazy sync           # Update all plugins
:Lazy install        # Install missing plugins
:Lazy clean          # Remove unused plugins
:Lazy profile        # Profile startup time
```

#### Adding Plugins
1. **Create Plugin File**: Add to `dotfiles/nvim/.config/nvim/lua/plugins/`
2. **Plugin Specification**: Use Lazy.nvim format
3. **Reload**: Restart Neovim or `:Lazy reload`

### Mason
**LSP, formatter, and linter installer**

#### Commands
```bash
:Mason               # Open Mason UI
:MasonInstall <tool> # Install specific tool
:MasonUpdate         # Update all tools
:MasonLog            # View installation logs
```

#### Installed Tools
- **Language Servers**: lua_ls, pyright, tsserver, rust_analyzer, etc.
- **Formatters**: prettier, stylua, black, rustfmt, etc.
- **Linters**: eslint, flake8, shellcheck, etc.
- **Debuggers**: debugpy, node-debug2, etc.

## 🎨 Customization

### Adding Custom Keybindings
Edit `dotfiles/nvim/.config/nvim/lua/plugins/astrocore.lua`:
```lua
mappings = {
  n = {
    ["<leader>custom"] = { ":echo 'Custom command'<cr>", desc = "Custom action" },
  },
}
```

### Custom Plugins
Create new file in `dotfiles/nvim/.config/nvim/lua/plugins/`:
```lua
-- custom-plugin.lua
return {
  "author/plugin-name",
  config = function()
    require("plugin-name").setup({
      -- configuration
    })
  end,
}
```

### Theme Customization
Edit `dotfiles/nvim/.config/nvim/lua/plugins/theme.lua`:
```lua
-- Modify Catppuccin theme settings
opts = {
  flavour = "mocha", -- latte, frappe, macchiato, mocha
  -- custom colors and highlights
}
```

### LSP Configuration
Edit `dotfiles/nvim/.config/nvim/lua/plugins/astrolsp.lua`:
```lua
-- Add custom LSP settings
config = {
  servers = {
    "new_language_server",
  },
}
```

## 🔧 Troubleshooting

### Common Issues

#### Plugins Not Loading
```bash
# Check plugin status
:Lazy

# Reinstall plugins
:Lazy clean
:Lazy sync

# Check for errors
:messages
```

#### LSP Not Working
```bash
# Check LSP status
:LspInfo

# Install language server
:Mason

# Restart LSP
:LspRestart
```

#### AI Tools Not Responding
```bash
# Check API keys
:echo $OPENAI_API_KEY

# Check network connectivity
# Verify API key validity

# Check plugin status
:Lazy
```

#### Database Connection Issues
```bash
# Check dbee status
:DbeeLoadConnections

# Verify connection details
# Check network connectivity to database

# For Snowflake MFA issues
:DbeeRestoreSnowflake
```

### Performance Issues

#### Slow Startup
```bash
# Profile startup time
:Lazy profile

# Disable unnecessary plugins
# Optimize plugin loading
```

#### High Memory Usage
```bash
# Check memory usage
:lua print(vim.fn.system("ps aux | grep nvim"))

# Disable heavy plugins if needed
# Reduce treesitter parsers
```

### Configuration Debugging

#### Check Health
```bash
:checkhealth          # General health check
:checkhealth lazy     # Plugin manager health
:checkhealth lsp      # LSP health
:checkhealth treesitter # Treesitter health
```

#### View Configuration
```bash
:lua print(vim.inspect(require("lazy").plugins()))
:lua print(vim.inspect(vim.g))
:lua print(vim.inspect(vim.o))
```

## 📚 Advanced Features

### Custom Commands
```bash
# Database helpers
:DbeeCreateExample    # Create example connections
:DbeeLoadConnections  # Load connections manually
:DbeeRestoreSnowflake # Restore Snowflake connections

# AI commands
:CodeCompanion        # Open AI chat
:CodeCompanionActions # Show AI actions
```

### Automation
- **Auto-save**: Automatic file saving (configurable)
- **Session Management**: Integration with tmux sessions
- **Project Detection**: Automatic project-specific settings

### Integration
- **Tmux**: Seamless tmux integration with sessionizer
- **Git**: Advanced git workflows with Lazygit
- **Terminal**: Integrated terminal with toggleterm
- **File Manager**: Oil.nvim for file operations

---

## 📖 Related Documentation
- [AI Tools Setup](../ai/)
- [Database Configuration](../database/)
- [Tmux Integration](../tmux.md)
- [Troubleshooting Guide](../troubleshooting.md)
- [Plugin Configurations](../../dotfiles/nvim/.config/nvim/lua/plugins/)