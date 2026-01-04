# AI Workflows

Daily development patterns using AI tools.

## Morning Setup
```bash
C-x + t     # Open project sessionizer
nvim
:Copilot status
<leader>ac  # Test CodeCompanion
```

## Code Review Workflow
```bash
<leader>ar  # AI code review
<leader>ae  # AI explanation
<leader>af  # AI fixes
<leader>ao  # AI optimization
```

## Focus Mode
```bash
<leader>z   # Zen mode (70% width)
<leader>Z   # Full screen zen
<leader>tt  # Dim inactive code
<leader>zx  # Exit zen mode
```

## Code Development

### Planning Phase
```markdown
# In CodeCompanion:
"I need to implement user authentication for a React app.
What's the best approach considering security and UX?"
```

### Implementation Phase
```javascript
// Copilot keybindings:
// Tab: Accept suggestion
// Ctrl+;: Accept full suggestion
// Ctrl+': Accept word
// Ctrl+]: Accept line
```

### Refinement Phase
```bash
<leader>ar  # Review implementation
<leader>ao  # Optimize performance
<leader>af  # Fix potential issues
```

## Debugging Workflow

```bash
# 1. Error analysis
<leader>ac  # "Help me debug this error: [details]"

# 2. Code investigation
<leader>ae  # AI explanation
<leader>ar  # AI review

# 3. Apply fixes
<leader>af  # AI-generated fixes
```

## Database Development

### Query Development
```sql
-- Use AI completion for SQL
SELECT u.id, u.email, u.last_login
FROM users u
WHERE u.last_login < NOW() - INTERVAL '30 days';

-- BB to execute query in dbee
```

### Schema Design
```markdown
# In CodeCompanion:
"Design a database schema for an e-commerce platform.
What tables and relationships should I consider?"
```

## Documentation

```bash
# Code documentation
<leader>ae  # Generate docstrings

# README generation
<leader>ac  # "Generate README for this project"

# API documentation
<leader>ae  # Generate OpenAPI/Swagger docs
```
