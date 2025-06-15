-- Find what's actually calling Snowflake during typing
print("=== Find Snowflake Caller ===")

-- Patch the database connection function to track calls
local database = require("cmp-dbee.database")
local original_get_current = database.get_current_connection

-- Track all calls to get_current_connection
database.get_current_connection = function()
  local info = debug.getinfo(2, "Sl")
  local caller = info.source .. ":" .. info.currentline
  
  local conn = original_get_current()
  if conn and conn.type == "snowflake" then
    print("🔍 get_current_connection called from:", caller)
  end
  
  return conn
end

-- Patch get_db_structure to see if it's being called
local original_get_db_structure = database.get_db_structure
database.get_db_structure = function(callback)
  local info = debug.getinfo(2, "Sl")
  local caller = info.source .. ":" .. info.currentline
  print("🔥 get_db_structure called from:", caller)
  
  return original_get_db_structure(callback)
end

-- Patch get_models to see if it's being called
local original_get_models = database.get_models
database.get_models = function(schema, callback)
  local info = debug.getinfo(2, "Sl") 
  local caller = info.source .. ":" .. info.currentline
  print("🔥 get_models called from:", caller, "for schema:", schema)
  
  return original_get_models(schema, callback)
end

-- Patch get_column_completion to see if it's being called
local original_get_column_completion = database.get_column_completion
database.get_column_completion = function(schema, model, callback)
  local info = debug.getinfo(2, "Sl")
  local caller = info.source .. ":" .. info.currentline
  print("🔥 get_column_completion called from:", caller, "for", schema .. "." .. model)
  
  return original_get_column_completion(schema, model, callback)
end

-- Also patch the core dbee functions to see if they're being called
local core_ok, core = pcall(require, "dbee.api.core")
if core_ok then
  local original_get_structure = core.connection_get_structure
  if original_get_structure then
    core.connection_get_structure = function(connection_id)
      local info = debug.getinfo(2, "Sl")
      local caller = info.source .. ":" .. info.currentline
      print("🔥 CORE connection_get_structure called from:", caller, "for connection:", connection_id)
      
      return original_get_structure(connection_id)
    end
  end
  
  local original_get_columns = core.connection_get_columns
  if original_get_columns then
    core.connection_get_columns = function(connection_id, opts)
      local info = debug.getinfo(2, "Sl")
      local caller = info.source .. ":" .. info.currentline
      print("🔥 CORE connection_get_columns called from:", caller, "for:", vim.inspect(opts))
      
      return original_get_columns(connection_id, opts)
    end
  end
end

print("✅ Patches applied. Now type in a SQL file to see what calls Snowflake.")
print("   Look for 🔥 lines to see what's making database queries.")

-- Test with current connection
local current = database.get_current_connection()
if current then
  print("Current connection type:", current.type)
else
  print("No current connection")
end