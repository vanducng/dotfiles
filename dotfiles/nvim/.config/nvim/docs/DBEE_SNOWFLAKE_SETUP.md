# nvim-dbee Multi-Database Setup Guide

This guide explains how to set up and use nvim-dbee with multiple database connections (Snowflake, PostgreSQL, MySQL) in your Neovim configuration.

## Prerequisites

1. **Database Access**: You need access to your database(s) with appropriate credentials
2. **Database Drivers**: Install database drivers (handled automatically by dbee)

## Installation

The nvim-dbee plugin is already configured in your AstroNvim setup via `lua/plugins/dbee.lua`.

## Secure Connection Management

### Method 1: DBEE UI (Recommended)

1. **Open DBEE**: Press `<leader>Dd`
2. **Add Connection**: In the drawer, press `a` to add a new connection
3. **Fill Details**: Enter your database credentials securely
4. **Save**: Connections are automatically saved to `persistence.json`

### Method 2: Edit Connections File

#### Quick Setup:
```vim
:DbeeConnections
```
This command will:
- Open your connections file for editing
- Create an example file if none exists

#### Manual Setup:
Edit `~/.cache/nvim/dbee/persistence.json`:

```json
[
  {
    "id": "snowflake_prod",
    "name": "Snowflake Production",
    "type": "snowflake", 
    "url": "snowflake://username:password@account.region.snowflakecomputing.com/database/schema?warehouse=COMPUTE_WH&role=ROLE_NAME"
  },
  {
    "id": "postgres_dev",
    "name": "PostgreSQL Development",
    "type": "postgres",
    "url": "postgres://username:password@localhost:5432/mydb?sslmode=require"
  },
  {
    "id": "mysql_local",
    "name": "MySQL Local",
    "type": "mysql", 
    "url": "username:password@tcp(localhost:3306)/mydb"
  }
]
```

### Method 3: Environment Variables (Optional)

Add to your shell profile (`.zshrc`, `.bashrc`, etc.):

```bash
export DBEE_CONNECTIONS='[
  {
    "id": "snowflake_prod",
    "name": "Snowflake Production",
    "type": "snowflake",
    "url": "snowflake://username:password@account.region.snowflakecomputing.com/database/schema?warehouse=COMPUTE_WH&role=ROLE_NAME"
  }
]'
```

## Available Commands

| Command | Description |
|---------|-------------|
| `:DbeeConnections` | Edit connections file (creates example if none exists) |
| `:DbeeExampleConnections` | Create example connections file |

## Database URL Formats

### Snowflake URL Format

```
snowflake://username:password@account.region.snowflakecomputing.com/database/schema?warehouse=WAREHOUSE_NAME&role=ROLE_NAME
```

**Parameters:**
- `username`: Your Snowflake username
- `password`: Your Snowflake password  
- `account`: Your Snowflake account identifier
- `region`: Your Snowflake region (if applicable)
- `database`: Default database to connect to
- `schema`: Default schema to use
- `warehouse`: Warehouse to use for compute
- `role`: Role to assume for the session

### PostgreSQL URL Format

```
postgres://username:password@host:port/database?sslmode=require
```

**Parameters:**
- `username`: Your PostgreSQL username
- `password`: Your PostgreSQL password
- `host`: Database server hostname/IP
- `port`: Database port (default: 5432)
- `database`: Database name
- `sslmode`: SSL connection mode (disable, require, prefer)

### MySQL URL Format

```
username:password@tcp(host:port)/database
```

**Parameters:**
- `username`: Your MySQL username
- `password`: Your MySQL password
- `host`: Database server hostname/IP
- `port`: Database port (default: 3306)
- `database`: Database name

## Key Mappings

| Key | Mode | Action |
|-----|------|--------|
| `<leader>D` | Normal | Database menu (WhichKey) |
| `<leader>Dd` | Normal | Open Database Explorer (DBEE) |
| `<leader>Dt` | Normal | Toggle Database Explorer |
| `<leader>Dx` | Normal | Disconnect all active database connections |
| `<leader>j` | Normal | Execute SQL statement (semicolon-delimited) ⭐ **NEW** |
| `<leader>J` | Normal | Select SQL statement (semicolon-delimited) ⭐ **NEW** |

### Within DBEE Interface:
- **Query execution**: 
  - `BB` (execute selection in visual mode, or entire file in normal mode)
  - `BS` (execute SQL statement at cursor - built into DBEE) ⭐ **NEW**
  - `<leader>j` (execute SQL statement at cursor - custom keymap) ⭐ **NEW**
- **SQL statement selection**:
  - `SS` (select SQL statement at cursor - built into DBEE) ⭐ **NEW**
  - `<leader>J` (select SQL statement at cursor - custom keymap) ⭐ **NEW**
  - `is` and `as` (text objects for inner/around SQL statement) ⭐ **NEW**
- **Navigation**: `<Tab>` to switch between panels
- **Connection**: `<Enter>` or `o` to connect to selected database
- **Disconnect**: `x` to toggle connection for selected database
- **New editor**: `e` to create new SQL editor
- **Close**: `q` to quit windows
- **Refresh**: `r` to refresh connections/structure
- **Cancel query**: `<C-c>` (in result window to cancel running query)

## Usage

1. **Open DBEE**: Press `<leader>Dd` to open the DBEE interface
2. **Connect to Snowflake**: Select your Snowflake connection from the drawer
3. **Write Queries**: Create or open a `.sql` file
4. **Execute Queries**: 
   - `BB` to execute entire file or selected text
   - `<leader>j` or `BS` to execute SQL statement at cursor (automatically detects statement boundaries using semicolons) ⭐ **RECOMMENDED**
   - `<leader>J` or `SS` to select SQL statement at cursor (useful for reviewing before execution)

## SQL Text Objects ⭐ **NEW**

DBEE now includes custom text objects for SQL statements:

- **`is`** - Inner SQL statement (content without semicolon)
- **`as`** - Around SQL statement (content including semicolon)

### Usage Examples:
```vim
vis    " Select inner SQL statement
das    " Delete around SQL statement  
cis    " Change inner SQL statement
yas    " Yank around SQL statement
```

These work with any SQL file and automatically detect statement boundaries using semicolons, respecting:
- String literals (`'...'` and `"..."`)
- Line comments (`-- comment`)
- Block comments (`/* comment */`)

## Common Database Queries

The configuration includes helper queries for common database operations:

### Snowflake Queries

```sql
-- Show current context
SELECT 
  CURRENT_WAREHOUSE() AS warehouse,
  CURRENT_DATABASE() AS database,
  CURRENT_SCHEMA() AS schema,
  CURRENT_ROLE() AS role,
  CURRENT_USER() AS user;

-- List databases
SHOW DATABASES;

-- List schemas
SHOW SCHEMAS;

-- List tables
SHOW TABLES;

-- Describe table
DESC TABLE your_table_name;
```

### PostgreSQL Queries

```sql
-- Show current context
SELECT 
  current_database() AS database,
  current_schema() AS schema,
  current_user AS user,
  session_user AS session_user;

-- List databases
SELECT datname AS database_name FROM pg_database WHERE datistemplate = false;

-- List schemas
SELECT schema_name FROM information_schema.schemata;

-- List tables
SELECT table_name FROM information_schema.tables WHERE table_schema = current_schema();

-- Describe table
\d your_table_name
```

### MySQL Queries

```sql
-- Show current context
SELECT 
  DATABASE() AS database_name,
  USER() AS user,
  CONNECTION_ID() AS connection_id;

-- List databases
SHOW DATABASES;

-- List tables
SHOW TABLES;

-- Describe table
DESCRIBE your_table_name;
```

## Security Considerations

1. **Environment Variables**: Use environment variables instead of hardcoding credentials
2. **SSH Keys**: Consider using key-based authentication if supported
3. **Connection Encryption**: Snowflake connections are encrypted by default
4. **Credential Files**: Ensure connection files have appropriate permissions (600)

## Troubleshooting

### Connection Issues
- Verify your Snowflake account details
- Check network connectivity to Snowflake
- Ensure your role has appropriate permissions
- Verify warehouse is available and running

### Driver Issues
- Run `:Dbee install` to reinstall the dbee binary
- Check that Go is installed on your system
- Restart Neovim after installation

### Query Execution Issues
- Verify you're connected to the correct database/schema
- Check that your role has SELECT permissions
- Ensure the warehouse is running (not suspended)

## Advanced Configuration

You can customize the dbee configuration further by modifying `lua/plugins/dbee.lua`:

```lua
-- Example: Custom result page size
result = {
  page_size = 500,  -- Increase from default 100
},

-- Example: Custom drawer mappings
drawer = {
  mappings = {
    { key = "r", mode = "n", action = "refresh" },
    { key = "c", mode = "n", action = "connect" },
  },
},
```

## Environment Setup Script

You can use this helper function in your Neovim config:

```lua
-- Add to your init.lua or a custom config file
vim.api.nvim_create_user_command("DbeeSetupSnowflake", function()
  require("plugins.dbee-snowflake").create_connection_file()
end, { desc = "Setup example Snowflake connections" })
```

This creates the command `:DbeeSetupSnowflake` to generate example connection files.