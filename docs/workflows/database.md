# Database Workflow

## Database Explorer

```bash
# Open database explorer
<leader>Dd

# Connect to database
# Press Enter or 'o' to connect
# Press 'x' to toggle connection

# Disconnect all
<leader>Dx
```

## Query Development

```bash
nvim query.sql

# Use AI for SQL generation
<leader>ac  # "Find users who haven't logged in for 30 days"

# Execute query
BB  # Execute selection or entire file
```

### Example Query
```sql
SELECT u.id, u.email, u.last_login
FROM users u
WHERE u.last_login < NOW() - INTERVAL '30 days'
   OR u.last_login IS NULL;
```

## Schema Design

```bash
<leader>ac  # AI chat
"Design a database schema for an e-commerce platform"

# AI provides:
# - Table structure
# - Relationship mappings
# - Index suggestions
# - Normalization advice
```

### Create Migrations
```bash
nvim migrations/001_create_users.sql

# Execute migration
BB
```

## Query Optimization

### 1. Identify Slow Queries
```bash
# Use database monitoring tools
# Profile query performance
```

### 2. Optimize with AI
```bash
# Select slow query
<leader>ao  # AI optimization suggestions
```

### 3. Test Optimizations
```bash
# Compare execution plans
# Measure performance improvements
```

### 4. Document
```bash
# Add comments to optimized queries
# Update documentation
```
