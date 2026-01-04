# AI Best Practices

## Effective Prompting

### Be Specific
```markdown
# Bad
"Fix this code"

# Good
"This React component re-renders too often.
How can I optimize it using useMemo and useCallback?"
```

### Provide Context
```markdown
# Bad
"How do I handle errors?"

# Good
"In this Express.js API endpoint, how should I handle
database connection errors and return appropriate HTTP status codes?"
```

### Iterate and Refine
```markdown
1. "What's the best way to implement caching?"
2. "For a Node.js API with Redis, what strategies work best?"
3. "Show me cache invalidation for user data updates"
```

## Code Quality

### Use AI for Reviews
```bash
<leader>ar  # Before committing
# Address suggestions before commit
```

### Validate AI Suggestions
- Don't blindly accept AI code
- Test thoroughly
- Understand the suggestions
- Adapt to your specific context

## Security Considerations

### Review AI-Generated Code
```bash
<leader>ar  # AI security review
# Check for:
# - Input validation
# - SQL injection prevention
# - Authentication checks
```

### Don't Share Sensitive Data
```markdown
# Bad: Paste actual API keys
# Good: Use placeholders like "API_KEY"
```

## Troubleshooting

### AI Not Responding
```bash
# Check API keys
echo $OPENAI_API_KEY
:Copilot status

# Test connectivity
curl -I https://api.openai.com
curl -I https://copilot-proxy.githubusercontent.com
```

### Rate Limiting
- Reduce request frequency
- Use different AI tools alternately
- Consider upgrading API plans

### Slow Responses
- Be more specific in prompts
- Reduce context size
- Use shorter code snippets

## Productivity Tips

### Keyboard Shortcuts Mastery
```bash
<leader>ac  # Quick AI chat
<leader>aa  # AI actions menu
<leader>ar  # Code review
<leader>af  # Quick fixes
```

### Context Switching
- **Copilot**: Real-time coding
- **CodeCompanion**: Complex problems
- **Database AI**: SQL queries

### Learning from AI
```bash
"Why did you suggest this approach?"
"What are the trade-offs?"
"Are there alternative approaches?"
```

### Daily AI Habits
1. Morning: Plan features with AI
2. Coding: Use completion tools
3. Review: AI code review
4. Evening: Document with AI help
