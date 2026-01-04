# Codebase Summary

Duc's Digital Workspace: AI-enhanced macOS development environment with 22 dotfiles packages managed via GNU Stow.

## Structure Overview

### Core Packages (22 total)

**Editors & IDEs:**
- `nvim` - Neovim with AstroNvim v5 distribution
- `nvim-vscode` - VSCode Neovim integration
- `vscode` - VSCode settings and keybindings

**Terminal & Shell:**
- `zsh` - Primary shell configuration with Oh My Zsh
- `tmux` - Terminal multiplexer with custom plugins
- `ghostty` - Modern terminal emulator
- `kitty` - Alternative terminal emulator
- `atuin` - Intelligent shell history with sync
- `starship` - Cross-shell prompt configuration

**Window Management:**
- `yabai` - Tiling window manager (BSP layout)
- `skhd` - Hotkey daemon for app switching
- `karabiner` - Keyboard customization
- `hammerspoon` - macOS automation scripts

**File & Git Management:**
- `yazi` - File manager with custom plugins
- `lazygit` - Git TUI configuration
- `bin` - Custom scripts (tmux-sessionizer, git-worktree-manager, etc.)

**Development Tools:**
- `direnv` - Automatic environment loading
- `mise` - Runtime version management
- `task` - Task runner configuration
- `zathura` - PDF viewer configuration

**Other:**
- `claude` - Claude AI user configuration
- `vrapperrc` - Vim keybindings for Eclipse

### Scripts (13 scripts)

**Installation & Setup:**
- `scripts/macos-deps.sh` - Install macOS dependencies
- `scripts/ci/` - CI pipeline scripts (validate, check-dependencies, test-platforms)

**Neovim Management:**
- `scripts/nvim-install-parser.sh` - Install treesitter parsers
- `scripts/nvim-treesitter-arm64.sh` - ARM64 specific setup
- `scripts/refresh-nvim.sh` - Refresh Neovim plugins

**Maintenance:**
- `scripts/yabai-upgrade.sh` - Update window manager
- `scripts/export-atuin-aliases.sh` - Export shell aliases
- `scripts/import-atuin-aliases.sh` - Import shell aliases
- `scripts/appscript-notifications.scpt` - macOS notifications

### Configuration Files

- `Makefile` - Build automation (stow install/clean, alias management)
- `.stow-local-ignore` - GNU Stow ignore patterns
- `.repomixignore` - Repomix packing exclusions
- `.gitleaksignore` - Secrets scanning exclusions
- `.gitignore` - Git ignore patterns
- `zensical.toml` - Documentation site configuration
- `mise.toml` - Runtime version specifications
- `CLAUDE.md` - Claude AI project instructions

### Documentation

- `docs/` - Main documentation folder with guides for all tools
- `dotfiles/nvim/.config/nvim/docs/` - Neovim-specific AI documentation

## Key Features

### Window Management
- **Yabai** - Binary space partitioning with 5px gaps
- **SKHD** - Modal hotkey system with app shortcuts
- **App Rules** - Specific window behavior per application

### AI Integration
- **Supermaven** - Real-time code completion (Tab to accept)
- **CodeCompanion** - Gemini API chat and inline assistance
- **Database AI** - SQL-specific AI helpers via dbee
- **fzf-lua** - Fuzzy finder (replaced Telescope)
- **Oil.nvim** - File explorer (replaced Neo-tree)

### Terminal Workflows
- **Tmux** - Session management with custom plugins
- **Atuin** - Command history with cloud sync
- **Starship** - Modern shell prompt with themes
- **Ghostty** - Primary terminal with modern features

### Development Environment
- **AstroNvim** - Modern Neovim distribution
- **Language Servers** - LSP support for multiple languages
- **Database Tools** - Advanced SQL with Snowflake support
- **Version Management** - Mise for runtime versions

## Dependencies

**System:**
- macOS 12.0+
- Homebrew
- Git
- GNU Stow

**Installed via Scripts:**
- Neovim + plugins
- Tmux + TPM
- Terminal emulators (Ghostty, Kitty)
- Development tools (Node, Python, Rust)
- Window managers (Yabai, SKHD)

## File Statistics

- Total Files: 102
- Total Tokens: 126,785
- Configuration-heavy (minimal code)
- Well-documented with inline comments

## Maintenance

**Key Files for Updates:**
- `Makefile` - Installation procedures
- `README.md` - Public documentation
- `CLAUDE.md` - Development instructions
- `dotfiles/nvim/` - Editor configuration
- `dotfiles/zsh/.zshrc` - Shell setup

**Common Tasks:**
- Stow install/clean: `make stow-install/clean`
- Alias management: `make export/import-aliases`
- Service restart: `brew services restart yabai skhd`
- Plugin updates: `:Lazy sync` (Neovim), `prefix + I` (Tmux)

## Documentation Hierarchy

1. **Installation** - Setup from scratch
2. **Quick Reference** - Essential commands
3. **Tool Guides** - Detailed configuration (Tmux, SKHD, Atuin, etc.)
4. **Troubleshooting** - Common issues and fixes
5. **AI Workflows** - Best practices for AI tools
6. **Advanced** - Custom configurations and extensions
