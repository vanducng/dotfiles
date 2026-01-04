# Coding Workflow

## Feature Development Cycle

### 1. Planning Phase
```bash
<leader>ac  # Open AI chat

# Example:
"I need to implement user authentication.
What's the best approach for React + Node.js?"
```

### 2. Implementation Phase
```bash
nvim src/auth/login.js

# Real-time AI completion
# Accept with C-J in insert mode

# For complex logic:
<leader>aa  # AI actions menu
<leader>ae  # Explain code
<leader>af  # Fix issues
```

### 3. Testing Phase
```bash
nvim tests/auth.test.js

<leader>ac  # "Generate tests for this module"

C-x + m     # Split for test terminal
npm test
```

### 4. Review Phase
```bash
<leader>ar  # AI code review
<leader>ao  # Optimization suggestions

<leader>gg  # Lazygit - review before commit
```

## Code Navigation

```bash
# Quick file navigation
<leader>ff  # Find files
<leader>fw  # Find word in project
<leader>fb  # Browse buffers

# Code navigation
gd  # Go to definition
gr  # Find references
gi  # Go to implementation
K   # Show documentation

# Project switching
C-f     # From Neovim
C-x + t # From tmux
```

## Refactoring Workflow

### 1. Identify Opportunities
```bash
<leader>ar  # AI code review
```

### 2. Plan Refactoring
```bash
<leader>ac  # "How should I refactor this for maintainability?"
```

### 3. Execute Refactoring
```bash
<leader>cr  # Rename symbols
<leader>ca  # Code actions
<leader>af  # Apply AI fixes
```

### 4. Verify Changes
```bash
# Run tests
# Use AI to review refactored code
```
