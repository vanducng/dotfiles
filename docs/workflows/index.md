# Development Workflows

Daily development patterns using the integrated environment.

## Daily Routine

### Morning Setup
```bash
# Open terminal (Ghostty starts automatically)

# Navigate to project
C-x + t  # Open tmux sessionizer

# Open editor
nvim

# Check status
:checkhealth
<leader>ac    # Test AI tools
<leader>Dd    # Check database (if needed)
```

### Project Layout
```bash
C-x + m  # Split horizontal
C-x + v  # Split vertical

# Example layout:
# ┌─────────────┬─────────────┐
# │   Neovim    │   Browser   │
# ├─────────────┼─────────────┤
# │  Terminal   │   Logs      │
# └─────────────┴─────────────┘
```

### End of Day
```bash
<leader>gg  # Lazygit - stage, commit, push
<leader>ac  # AI help for documentation
# Sessions persist automatically
```

## Project Setup

### New Project
```bash
mkdir ~/projects/new-project
cd ~/projects/new-project
git init
git remote add origin <url>

C-x + t  # Create tmux session
nvim
<leader>ac  # Ask AI for project structure
```

### Environment Config
```bash
nvim .env.example
nvim .env.local
nvim .gitignore
nvim README.md
```

## Documentation

- **[Coding](coding.md)** - Feature development, refactoring
- **[Database](database.md)** - Schema design, queries
- **[Review & Debug](review.md)** - Code review, debugging, documentation
