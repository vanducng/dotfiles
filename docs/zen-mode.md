# 🧘 Zen Mode - Distraction-Free Coding

Zen mode provides a distraction-free coding environment by hiding UI elements and centering your code for better focus.

## 📋 Table of Contents
- [Overview](#overview)
- [Keybindings](#keybindings)
- [Features](#features)
- [Configuration](#configuration)
- [Tmux Integration](#tmux-integration)
- [Best Practices](#best-practices)

## 🎯 Overview

Zen mode is designed to help you focus on code by:
- Removing visual distractions (status bars, line numbers, etc.)
- Centering content for better readability
- Dimming background elements
- Integrating with tmux for session-wide focus

## ⌨️ Keybindings

| Shortcut | Action | Description |
|----------|--------|-------------|
| `<leader>z` | Standard Zen | Enter zen mode with 70% width, optimal for reading |
| `<leader>Z` | Full Screen Zen | Enter full-screen zen mode (100% width) |
| `<leader>zx` | Exit All Zen | Exit zen mode across all tmux panes in session |
| `<leader>tt` | Twilight | Toggle twilight mode (dim inactive code) |

## ✨ Features

### Standard Zen Mode (`<leader>z`)
- **Width**: 70% of editor width (minimum 150 columns)
- **Height**: Full height
- **Purpose**: Optimal for reading and writing code
- **UI Changes**:
  - Hides line numbers and relative numbers
  - Removes sign column
  - Disables cursor line/column highlighting
  - Hides fold column and whitespace characters

### Full Screen Zen Mode (`<leader>Z`)
- **Width**: 100% of editor width
- **Height**: 100% of editor height
- **Purpose**: Maximum screen real estate for complex code
- **UI Changes**: Same as standard zen mode but uses full width

### Session-Wide Exit (`<leader>zx`)
- Exits zen mode in current Neovim instance
- Sends exit commands to all tmux panes in the current session
- Useful when working across multiple panes/windows

### Twilight Mode (`<leader>tt`)
- Dims inactive code sections
- Highlights only the current context (20 lines around cursor)
- Uses treesitter for intelligent context detection
- Can be used independently or with zen mode

## 🔧 Configuration

### Width Calculation
Zen mode automatically calculates optimal width:
```lua
-- 70% of editor width, minimum 150 columns
local function zen_mode_width()
  local editor_width = vim.o.columns
  local target_width = math.floor(editor_width * 0.7)
  return math.max(150, target_width)
end
```

### Terminal Integration
Zen mode integrates with various terminals:
- **Kitty**: Increases font size by 1
- **Alacritty**: Sets font size to 19.5
- **Neovide**: Increases scale by 10%
- **Tmux**: Hides tmux status line

### Backdrop Settings
- **Backdrop**: 0.95 (slightly darken background)
- **Status Line**: Hidden in zen mode
- **Git Signs**: Disabled for cleaner appearance

## 🖥️ Tmux Integration

### Automatic Status Line Hiding
When entering zen mode, the tmux status line is automatically hidden for a cleaner experience.

### Session-Wide Exit
The `<leader>zx` command:
1. Exits zen mode in the current Neovim instance
2. Detects the current tmux session
3. Sends exit commands to all panes in the session
4. Provides feedback on the operation

### Implementation
```lua
-- Send to all panes in the session
vim.fn.system(
  string.format(
    "tmux list-panes -a -s -F '#{session_name}:#{window_index}.#{pane_index}' | grep '^%s:' | xargs -I {} tmux send-keys -t {} 'C-c' Escape ':lua require(\"zen-mode\").close()' Enter 2>/dev/null || true",
    tmux_session
  )
)
```

## 💡 Best Practices

### When to Use Standard Zen Mode
- Reading and understanding complex code
- Writing documentation or comments
- Code reviews and analysis
- Learning new codebases

### When to Use Full Screen Zen Mode
- Working with very wide code (long lines)
- Side-by-side comparisons
- Complex data structures or configurations
- Maximum focus sessions

### Combining with Other Tools
```bash
# Deep focus session
<leader>Z   # Full screen zen
<leader>tt  # Enable twilight
# Work in focused environment

# Exit when done
<leader>zx  # Exit across all panes
```

### Workflow Integration
1. **Start Focus Session**: Enter zen mode when beginning deep work
2. **Use Twilight**: Enable for additional context highlighting
3. **Session Management**: Use `<leader>zx` when switching contexts
4. **Terminal Integration**: Let zen mode handle terminal font adjustments

## 🔗 Related Features

- **Twilight**: Complements zen mode with code dimming
- **Tmux Integration**: Session-wide focus management
- **Terminal Support**: Automatic font size adjustments
- **Git Integration**: Temporarily hides git signs for cleaner view

## 📚 See Also

- [Neovim Configuration](neovim/README.md)
- [Tmux Guide](tmux.md)
- [AI Workflows](ai/workflows.md)
- [Quick Reference](quick-reference.md)