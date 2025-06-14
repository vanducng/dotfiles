-- Database helper functions for nvim-dbee
-- This file provides helper functions and query templates for multiple database types
-- No hardcoded credentials - all connections managed via DBEE UI or persistence.json

local M = {}

-- Database-specific SQL helpers
M.database_queries = {
  -- Snowflake-specific queries
  snowflake = {
    -- Show current warehouse, database, schema
    current_context = [[
SELECT 
  CURRENT_WAREHOUSE() AS warehouse,
  CURRENT_DATABASE() AS database,
  CURRENT_SCHEMA() AS schema,
  CURRENT_ROLE() AS role,
  CURRENT_USER() AS user;
]],
    -- List all databases
    list_databases = "SHOW DATABASES;",
    -- List all schemas in current database
    list_schemas = "SHOW SCHEMAS;",
    -- List all tables in current schema
    list_tables = "SHOW TABLES;",
    -- List all warehouses
    list_warehouses = "SHOW WAREHOUSES;",
    -- Describe table structure
    describe_table = "DESC TABLE {table_name};",
    -- Show table information
    table_info = "SHOW TABLES LIKE '{table_pattern}';",
    -- Query information schema
    columns_info = [[
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = '{table_name}'
ORDER BY ordinal_position;
]],
  },

  -- PostgreSQL-specific queries
  postgres = {
    -- Show current database and user
    current_context = [[
SELECT 
  current_database() AS database,
  current_schema() AS schema,
  current_user AS user,
  session_user AS session_user;
]],
    -- List all databases
    list_databases = "SELECT datname AS database_name FROM pg_database WHERE datistemplate = false;",
    -- List all schemas
    list_schemas = "SELECT schema_name FROM information_schema.schemata;",
    -- List all tables
    list_tables = "SELECT table_name FROM information_schema.tables WHERE table_schema = current_schema();",
    -- Describe table structure
    describe_table = "\\d {table_name}",
    -- Query information schema
    columns_info = [[
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = '{table_name}'
ORDER BY ordinal_position;
]],
  },

  -- MySQL-specific queries
  mysql = {
    -- Show current database and user
    current_context = [[
SELECT 
  DATABASE() AS database_name,
  USER() AS user,
  CONNECTION_ID() AS connection_id;
]],
    -- List all databases
    list_databases = "SHOW DATABASES;",
    -- List all tables
    list_tables = "SHOW TABLES;",
    -- Describe table structure
    describe_table = "DESCRIBE {table_name};",
    -- Query information schema
    columns_info = [[
SELECT 
  COLUMN_NAME,
  DATA_TYPE,
  IS_NULLABLE,
  COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = '{table_name}'
ORDER BY ORDINAL_POSITION;
]],
  },
}

-- Get queries for a specific database type
function M.get_queries_for_type(db_type) return M.database_queries[db_type] or {} end

-- Get all supported database types
function M.get_supported_types() return vim.tbl_keys(M.database_queries) end

-- Create example connections file (without credentials)
function M.create_example_connections()
  local cache_dir = vim.fn.stdpath "cache" .. "/dbee"
  vim.fn.mkdir(cache_dir, "p")

  local connections_file = cache_dir .. "/persistence.json.example"
  local example_connections = {
    {
      id = "snowflake_example",
      name = "Snowflake Example",
      type = "snowflake",
      url = "snowflake://USERNAME:PASSWORD@ACCOUNT.REGION.snowflakecomputing.com/DATABASE/SCHEMA?warehouse=WAREHOUSE&role=ROLE",
    },
    {
      id = "postgres_example",
      name = "PostgreSQL Example",
      type = "postgres",
      url = "postgres://USERNAME:PASSWORD@HOST:5432/DATABASE?sslmode=require",
    },
    {
      id = "mysql_example",
      name = "MySQL Example",
      type = "mysql",
      url = "USERNAME:PASSWORD@tcp(HOST:3306)/DATABASE",
    },
  }

  local file = io.open(connections_file, "w")
  if file then
    file:write(vim.json.encode(example_connections))
    file:close()
    vim.notify("Created example connections file at: " .. connections_file, vim.log.levels.INFO)
    vim.notify("Edit this file with your actual credentials and rename to persistence.json", vim.log.levels.INFO)
  else
    vim.notify("Failed to create example connections file", vim.log.levels.ERROR)
  end
end

-- Check if connections file exists
function M.has_connections()
  local connections_file = vim.fn.stdpath "cache" .. "/dbee/persistence.json"
  return vim.fn.filereadable(connections_file) == 1
end

-- Open connections file for editing
function M.edit_connections()
  local connections_file = vim.fn.stdpath "cache" .. "/dbee/persistence.json"
  if not M.has_connections() then
    M.create_example_connections()
    vim.notify("No connections file found. Created example file first.", vim.log.levels.WARN)
    connections_file = connections_file .. ".example"
  end
  vim.cmd("edit " .. connections_file)
end

-- User commands for managing connections
vim.api.nvim_create_user_command(
  "DbeeConnections",
  function() M.edit_connections() end,
  { desc = "Edit DBEE connections file" }
)

vim.api.nvim_create_user_command(
  "DbeeExampleConnections",
  function() M.create_example_connections() end,
  { desc = "Create example DBEE connections file" }
)

vim.api.nvim_create_user_command(
  "DbeeLoadConnections",
  function() 
    if _G.setup_dbee then
      _G.setup_dbee()
      vim.notify("Dbee setup completed with connections loaded", vim.log.levels.INFO)
    else
      vim.notify("Dbee setup not available", vim.log.levels.ERROR)
    end
  end,
  { desc = "Manually setup DBEE with connections" }
)

-- Workaround for Snowflake MFA connections
-- Remove Snowflake connections from persistence file on startup to prevent auto-connect
function M.disable_snowflake_autoconnect()
  local connections_file = vim.fn.stdpath("cache") .. "/dbee/persistence.json"
  if vim.fn.filereadable(connections_file) == 1 then
    local file = io.open(connections_file, "r")
    if file then
      local content = file:read("*all")
      file:close()
      
      local ok, connections = pcall(vim.json.decode, content)
      if ok and type(connections) == "table" then
        -- Create a backup of original connections
        local backup_file = connections_file .. ".backup"
        local backup = io.open(backup_file, "w")
        if backup then
          backup:write(content)
          backup:close()
        end
        
        -- Filter out Snowflake connections
        local filtered = {}
        for _, conn in ipairs(connections) do
          if conn.type ~= "snowflake" then
            table.insert(filtered, conn)
          end
        end
        
        -- Write back filtered connections
        if #filtered < #connections then
          local new_file = io.open(connections_file, "w")
          if new_file then
            new_file:write(vim.json.encode(filtered))
            new_file:close()
            vim.notify("Temporarily removed Snowflake connections to prevent auto-connect. Backup saved to " .. backup_file, vim.log.levels.INFO)
          end
        end
      end
    end
  end
end

-- Function to restore Snowflake connections when needed
function M.restore_snowflake_connections()
  local connections_file = vim.fn.stdpath("cache") .. "/dbee/persistence.json"
  local backup_file = connections_file .. ".backup"
  
  if vim.fn.filereadable(backup_file) == 1 then
    local backup = io.open(backup_file, "r")
    if backup then
      local content = backup:read("*all")
      backup:close()
      
      local file = io.open(connections_file, "w")
      if file then
        file:write(content)
        file:close()
        vim.notify("Snowflake connections restored from backup", vim.log.levels.INFO)
      end
    end
  else
    vim.notify("No backup file found", vim.log.levels.WARN)
  end
end

-- User command to restore Snowflake connections
vim.api.nvim_create_user_command(
  "DbeeRestoreSnowflake",
  function() M.restore_snowflake_connections() end,
  { desc = "Restore Snowflake connections from backup" }
)

-- Optional: Call this on startup to prevent auto-connect
-- Uncomment the line below if you want to automatically disable Snowflake connections on startup
-- M.disable_snowflake_autoconnect()

return M
