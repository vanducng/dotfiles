# Nushell Vi Mode Reference

## Default Vi Mode Commands (Built-in)

### Navigation
- `h` - Move cursor left
- `l` - Move cursor right
- `w` - Move to next word
- `b` - Move to previous word
- `e` - Move to end of word
- `0` - Move to beginning of line
- `$` - Move to end of line

### Editing
- `i` - Enter insert mode at cursor
- `a` - Enter insert mode after cursor
- `A` - Enter insert mode at end of line
- `I` - Enter insert mode at beginning of line
- `o` - Open new line below and enter insert mode
- `O` - Open new line above and enter insert mode

### Text Objects (Basic)
- `x` - Delete character under cursor
- `dd` - Delete entire line
- `dw` - Delete word
- `d$` - Delete to end of line
- `cc` - Change entire line
- `cw` - Change word
- `c$` - Change to end of line

### Mode Switching
- `Esc` - Return to normal mode from insert mode
- `v` - Enter visual mode (basic selection)

### Other
- `u` - Undo
- `r` - Replace character under cursor
- `/` - Search forward
- `?` - Search backward
- `n` - Next search result
- `N` - Previous search result

## Cursor Configuration
- **Insert mode**: Line cursor (vertical bar)
- **Normal mode**: Block cursor (solid rectangle)
- **Visual mode**: Block cursor

## Note
Nushell's vi mode is more limited than full vim, but covers the essential navigation and editing commands. Complex text objects like `diw` (delete inner word) are not fully supported in the same way as vim.