# Code Review & Debugging

## Self Review

```bash
# 1. Review changes before commit
<leader>gg  # Lazygit - review diff

# 2. AI-powered review
<leader>ar  # AI code review
<leader>af  # Apply suggestions

# 3. Check for issues
<leader>aa  # AI actions
# Security, performance, maintainability

# 4. Final verification
# Run tests, check linting
```

## Team Review Preparation

```bash
# 1. Clean up commit history
<leader>gg  # Squash/reorder if needed

# 2. Write descriptive messages
# Use conventional commit format

# 3. Prepare PR description
<leader>ac  # "Generate PR description for: [diff]"

# 4. Document complex changes
```

## Reviewing Others' Code

```bash
git checkout pr-branch

<leader>ff  # Navigate changed files
<leader>ae  # AI explanation

# Test changes locally
# Provide constructive feedback
<leader>ac  # "How to provide feedback on this?"
```

## Debugging Workflow

### Issue Investigation
```bash
# 1. Reproduce the issue

# 2. Analyze error
<leader>ac  # "Help debug: [error details]"

# 3. Investigate code
gd          # Go to definition
gr          # Find references
<leader>ae  # AI explanation
```

### Debugging Process
```bash
# 1. Add logging
# Use AI for debugging strategies

# 2. Use debugger
# Set breakpoints in DAP

# 3. Analyze data flow
# Trace variables

# 4. Test hypotheses
```

### Solution Implementation
```bash
# 1. Develop fix
<leader>af  # AI fixes

# 2. Test thoroughly
# Unit, integration, manual tests

# 3. Document solution
# Add explaining comments

# 4. Prevent regression
# Add tests
```

## Documentation Workflow

### Code Documentation
```bash
# Document as you code
<leader>ae  # Generate docstrings

# Generate API documentation
<leader>ac  # "Generate API docs for this endpoint"

# Keep README current
```

### Technical Writing
```bash
<leader>ac  # "Create outline for [topic]"

nvim docs/feature-guide.md

<leader>ar  # AI review of documentation
```
