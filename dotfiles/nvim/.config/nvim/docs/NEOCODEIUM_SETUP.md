# NeoCodeium + CodeCompanion Setup Guide

## Overview
This configuration uses:
- **NeoCodeium** (Windsurf) for real-time auto-completion (FREE)
- **CodeCompanion** with Gemini for chat and manual code transformations (pay-per-use)

### Supported Languages
NeoCodeium is configured to work with all major programming languages including:
- **SQL** (sql, mysql, postgresql, plsql) - Perfect for database work
- **Web** (javascript, typescript, html, css, react)
- **Systems** (go, rust, c, cpp, java)
- **Scripting** (python, lua, bash, zsh)
- **Config** (yaml, json, toml, markdown)

> **Note**: GitHub Copilot is temporarily disabled but can be re-enabled by setting `enabled = true` in `copilot.lua`

## Initial Setup

### 1. Install NeoCodeium
After installing the plugin, you need to authenticate:

```vim
:NeoCodeium auth
```

This will:
1. Open a browser to authenticate with Windsurf/Codeium
2. Provide a token to paste back into Neovim
3. Complete the authentication

### 2. Verify Setup
```vim
:NeoCodeium status
```

## Key Mappings

### NeoCodeium (Auto-completion)
- `<C-j>` - Accept full suggestion (in insert mode)
- `<C-f>` - Accept word only
- `<C-l>` - Accept current line only
- `<C-c>` - Clear current suggestion
- `<C-i>` - Cycle through suggestions
- `<leader>nc` - Toggle NeoCodeium
- `<leader>ns` - Check NeoCodeium status
- `<leader>ne` - Enable NeoCodeium
- `<leader>nd` - Disable NeoCodeium
- `<leader>na` - Authenticate NeoCodeium

### CodeCompanion (Chat & Transformations)
- `<leader>ac` - Open AI chat
- `<leader>aa` - Show actions menu
- `<leader>ae` - Explain code
- `<leader>af` - Fix code
- `<leader>ar` - Refactor code
- `<leader>aT` - Generate tests
- `<leader>ad` - Document code

## Usage Patterns

### 1. Writing New Code
- Start typing and NeoCodeium will suggest completions
- Press `<C-j>` to accept full suggestion
- Press `<C-f>` to accept just the next word
- Press `<C-l>` to accept just the current line
- Use `<C-i>` to cycle through alternative suggestions

### 2. Understanding Code
- Select code in visual mode
- Press `<leader>ae` to get explanation from Gemini

### 3. Refactoring
- Select code to refactor
- Press `<leader>ar` for AI-powered refactoring

### 4. Complex Questions
- Press `<leader>ac` to open chat
- Ask complex questions about your codebase

### 5. SQL Development
- NeoCodeium provides excellent SQL completions for:
  - Table and column names (when context is available)
  - SQL keywords and functions
  - Common query patterns
  - Database-specific syntax (MySQL, PostgreSQL, etc.)
- Works great with your DBEE setup for database development
- Supports both .sql files and SQL blocks in other languages

## Cost Optimization

### NeoCodeium (Windsurf)
- **Completely FREE** for unlimited suggestions
- No monthly subscription required
- Can still disable for specific filetypes for performance

### CodeCompanion (Gemini)
- Only charges when you use chat or transformations
- Typical costs:
  - Chat conversation: ~$0.01-0.05
  - Code explanation: ~$0.001-0.01
  - Refactoring: ~$0.01-0.05

## Tips

1. **Use NeoCodeium for speed**: Let it handle boilerplate and common patterns
2. **Use CodeCompanion for understanding**: Better for complex explanations
3. **Disable NeoCodeium in sensitive files**: Use `:NeoCodeium disable` for private code
4. **Model selection**: Use `:CodeCompanionModel` to switch Gemini models
5. **Performance**: Enable debounce in config to reduce API calls

## Troubleshooting

### NeoCodeium Not Working
1. Check status: `:NeoCodeium status`
2. Re-authenticate: `:NeoCodeium auth`
3. Check Neovim version: Requires Neovim >= 0.10.0
4. Toggle: `:NeoCodeium toggle`
5. Check if disabled in current buffer: `:NeoCodeium enable`

### CodeCompanion Issues
1. Verify API key: `echo $GEMINI_API_KEY`
2. Check health: `:checkhealth codecompanion`
3. Try a different model: `:CodeCompanionModel gemini-2.0-flash`

## Privacy Notes
- NeoCodeium sends code context to Windsurf/Codeium servers
- CodeCompanion sends selected code to Google (Gemini)
- Both can be disabled per-buffer or globally
- Review Windsurf Privacy Policy before use

## Switching Back to Copilot
To re-enable GitHub Copilot:
1. Set `enabled = true` in `lua/plugins/copilot.lua`
2. Set `enabled = false` in `lua/plugins/neocodeium.lua`
3. Restart Neovim

## Advanced Configuration

### Performance Tuning
```lua
-- In neocodeium setup
{
  debounce = true,        -- Reduce API calls
  single_line = true,     -- Collapse multi-line suggestions
  show_label = false,     -- Hide labels for cleaner UI
}
```

### Disable for Specific Files
```lua
-- Disable in git commit messages, sensitive files, etc.
filetypes = {
  gitcommit = false,
  [".env"] = false,
  ["secrets.yaml"] = false,
}
```

### Enterprise Setup
If using Windsurf Enterprise:
```lua
{
  api_url = "https://codeium.company.com",
  portal_url = "https://codeium.company.com",
}
```