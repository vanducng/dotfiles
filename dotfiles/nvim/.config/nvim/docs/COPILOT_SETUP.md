# GitHub Copilot + CodeCompanion Setup Guide

## Overview
This configuration uses:
- **GitHub Copilot** for real-time auto-completion (paid: $10/month)
- **CodeCompanion** with Gemini for chat and manual code transformations (pay-per-use)

## Initial Setup

### 1. Install GitHub Copilot
After installing the plugin, you need to authenticate:

```vim
:Copilot setup
```

This will:
1. Open a browser to authenticate with GitHub
2. Provide a device code to enter
3. Complete the authentication

### 2. Verify Setup
```vim
:Copilot status
```

## Key Mappings

### GitHub Copilot (Auto-completion)
- `<C-J>` - Accept suggestion (in insert mode)
- `<C-]>` - Next suggestion
- `<C-[>` - Previous suggestion
- `<leader>cp` - Open Copilot panel (see all suggestions)
- `<leader>cs` - Check Copilot status
- `<leader>ce` - Enable Copilot
- `<leader>cd` - Disable Copilot

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
- Start typing and Copilot will suggest completions
- Press `<C-J>` to accept
- Use `<C-]>` and `<C-[>` to cycle through alternatives

### 2. Understanding Code
- Select code in visual mode
- Press `<leader>ae` to get explanation from Gemini

### 3. Refactoring
- Select code to refactor
- Press `<leader>ar` for AI-powered refactoring

### 4. Complex Questions
- Press `<leader>ac` to open chat
- Ask complex questions about your codebase

## Cost Optimization

### GitHub Copilot
- Fixed $10/month for unlimited suggestions
- Can disable for specific filetypes to save resources

### CodeCompanion (Gemini)
- Only charges when you use chat or transformations
- Typical costs:
  - Chat conversation: ~$0.01-0.05
  - Code explanation: ~$0.001-0.01
  - Refactoring: ~$0.01-0.05

## Tips

1. **Use Copilot for speed**: Let it handle boilerplate and common patterns
2. **Use CodeCompanion for understanding**: Better for complex explanations
3. **Disable Copilot in sensitive files**: Use `:Copilot disable` for private code
4. **Model selection**: Use `:CodeCompanionModel` to switch Gemini models

## Troubleshooting

### Copilot Not Working
1. Check status: `:Copilot status`
2. Re-authenticate: `:Copilot setup`
3. Check Node.js: Copilot requires Node.js installed

### CodeCompanion Issues
1. Verify API key: `echo $GEMINI_API_KEY`
2. Check health: `:checkhealth codecompanion`
3. Try a different model: `:CodeCompanionModel gemini-2.0-flash`

## Privacy Notes
- Copilot sends code context to GitHub servers
- CodeCompanion sends selected code to Google (Gemini)
- Both can be disabled per-buffer or globally