# CodeCompanion.nvim Usage Guide

## Overview
CodeCompanion.nvim is an AI-powered coding assistant for Neovim that integrates with Google Gemini models.

## Prerequisites
- Ensure your `GEMINI_API_KEY` is set in `~/.envrc`
- The plugin will automatically use this API key

## Available Gemini Models
- `gemini-2.5-pro-preview-06-05` - Most capable, slower
- `gemini-2.5-pro-preview-05-06` - Previous pro version
- `gemini-2.5-flash-preview-05-20` - **Default**, balanced speed/quality
- `gemini-2.0-flash` - Fast, good for quick tasks
- `gemini-2.0-flash-lite` - Fastest, basic tasks
- `gemini-1.5-pro` - Older pro model
- `gemini-1.5-flash` - Older fast model

## Key Mappings

### Chat Commands
- `<leader>ac` - Open CodeCompanion chat window
- `<leader>at` - Toggle chat window
- `<leader>aC` - Add current context to chat

### Inline Actions
- `<leader>aa` - Show available actions menu (works in normal and visual mode)
- `<leader>ae` - Explain selected code
- `<leader>af` - Fix code issues
- `<leader>ar` - Refactor code
- `<leader>aT` - Generate tests
- `<leader>ad` - Document code
- `<leader>agc` - Generate commit message from git diff
- `<leader>av` - Send visual selection to CodeCompanion

### Chat Buffer Keymaps
When inside a chat buffer:
- `<CR>` or `<C-s>` - Send message
- `gr` - Regenerate last response
- `<C-c>` - Close chat
- `q` - Stop current request
- `gx` - Clear chat history
- `ga` - Change adapter/model
- `?` - Show options

## Usage Examples

### 1. Basic Chat
```vim
" Open chat with <leader>ac
" Type your question and press Enter to send
```

### 2. Explain Code
```vim
" Select code in visual mode
" Press <leader>ae to get explanation
```

### 3. Quick Fixes
```vim
" Place cursor on problematic code
" Press <leader>af to get AI-suggested fixes
```

### 4. Generate Tests
```vim
" Select a function in visual mode
" Press <leader>aT to generate unit tests
```

### 5. Generate Commit Messages
```vim
" Make your changes and stage them with git add
" Then press <leader>agc to generate a commit message
" The AI will analyze your git diff and suggest an appropriate message
```

### 6. Switch Models
```vim
:CodeCompanionModel gemini-2.0-flash
" Switches to a faster model for quick tasks

:CodeCompanionModel gemini-2.5-pro-preview-06-05
" Switches to the most capable model for complex tasks
```

## Tips

1. **Model Selection**:
   - Use flash models for quick tasks and explanations
   - Use pro models for complex refactoring or code generation

2. **Visual Mode**:
   - Always select code in visual mode for context-aware operations
   - The AI will only see what you select

3. **Chat Context**:
   - The chat maintains context throughout the conversation
   - Use `gx` to clear and start fresh

4. **Performance**:
   - The plugin runs asynchronously, so it won't block your editor
   - You can continue editing while waiting for responses

## Troubleshooting

1. **Check Health**:
   ```vim
   :checkhealth codecompanion
   ```

2. **Verify API Key**:
   ```bash
   echo $GEMINI_API_KEY
   ```

3. **Check Logs**:
   - Logs are available if you set `log_level = "DEBUG"` in the config

4. **Common Issues**:
   - If chat doesn't open, ensure you've sourced your `.envrc` file
   - API rate limits may cause delays with pro models

## Integration with Other Tools
- Works alongside `claude-code.nvim` without conflicts
- Independent from the disabled `llm.nvim` plugin
- Uses standard Neovim splits and buffers