---@type LazySpec
return {
  "vanducng/nvim-dbee",
  branch = "main",
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  build = function() require("dbee").install "go" end,
  config = function()
    -- Setup dbee immediately to avoid command issues
    require("dbee").setup {
      -- Don't set a default connection
      default_connection = nil,

      sources = {
        -- Load connections from environment variable (optional)
        require("dbee.sources").EnvSource:new "DBEE_CONNECTIONS",
        -- Load connections from persistent file (primary method)
        require("dbee.sources").FileSource:new(vim.fn.expand "~/.dbee/persistent.json"),
      },

      editor = {
        mappings = {
          -- Default DBEE mappings
          { key = "BB", mode = "v", action = "run_selection" },
          { key = "BB", mode = "n", action = "run_file" },
        },
      },
    }

    -- Note: cmp-dbee is configured separately in dbee-cmp.lua
    -- Removed duplicate setup to avoid conflicts with disabled databases

    -- For backward compatibility, set the global function
    _G.setup_dbee = function()
      -- Already set up, do nothing
    end
    _G.dbee_setup_done = true

    -- Load database helpers (lazy-loaded, no hardcoded credentials)
    local helpers_ok, _ = pcall(require, "config.dbee-helpers")
    if not helpers_ok then
      -- Helpers file doesn't exist, that's okay
    end
  end,
  cmd = {
    "Dbee",
    "DbeeToggle",
    "DbeeExecuteQuery",
  },
  keys = {
    {
      "<leader>D",
      desc = "󰆼 Database",
    },
    {
      "<leader>Dd",
      function()
        -- Open Dbee (setup is done automatically)
        require("dbee").open()
      end,
      desc = "Open Database Explorer",
    },
    {
      "<leader>Dt",
      function()
        require("dbee").toggle()
      end,
      desc = "Toggle Database Explorer",
    },
    {
      "<leader>j",
      function()
        -- Check if we're in a DBEE editor buffer or SQL file
        local filetype = vim.bo.filetype
        local bufname = vim.api.nvim_buf_get_name(0)

        -- Check if we're in a SQL context (DBEE editor or SQL file)
        if filetype == "sql" or string.find(bufname, "dbee/editor") or string.find(bufname, "dbee/notes") then
          -- Enhanced error handling for SQL execution
          local api = require "dbee.api"
          local core = require "dbee.api.core"
          local utils = require "dbee.utils"
          
          -- Check connection first
          local current_conn = core.get_current_connection()
          if not current_conn then
            vim.notify("❌ No database connection selected", vim.log.levels.ERROR)
            return
          end
          
          -- Get the SQL statement to validate before execution
          local bufnr = vim.api.nvim_get_current_buf()
          local cursor_pos = vim.api.nvim_win_get_cursor(0)
          local row = cursor_pos[1] - 1
          
          local query = utils.get_sql_statement_at_cursor(bufnr, row)
          if not query or query == "" then
            vim.notify("❌ No SQL statement found at cursor", vim.log.levels.WARN)
            return
          end
          
          -- Pre-validate common issues for Snowflake (silent)
          if current_conn.type == "snowflake" then
            -- Check for potential schema issues
            local schema_table_pattern = "([%w_]+)%.([%w_]+)"
            local schema, table = query:match(schema_table_pattern)
            -- Note: Schema case-sensitivity check removed for less noise
          end
          
          -- Execute SQL statement
          api.ui.editor_do_action "run_statement"
        else
          vim.notify("Not in a SQL buffer", vim.log.levels.WARN)
        end
      end,
      desc = "Execute SQL statement (semicolon-delimited)",
    },
    {
      "<leader>J",
      function()
        -- Check if we're in a DBEE editor buffer or SQL file
        local filetype = vim.bo.filetype
        local bufname = vim.api.nvim_buf_get_name(0)

        -- Check if we're in a SQL context
        if filetype == "sql" or string.find(bufname, "dbee/editor") or string.find(bufname, "dbee/notes") then
          -- Use DBEE's new select_statement action
          local api = require "dbee.api"
          local ok, err = pcall(function() api.ui.editor_do_action "select_statement" end)

          if not ok then 
            vim.notify("❌ Failed to select SQL statement: " .. tostring(err), vim.log.levels.ERROR)
          end
          -- No success notification for selection
        else
          vim.notify("Not in a SQL buffer", vim.log.levels.WARN)
        end
      end,
      desc = "Select SQL statement (semicolon-delimited)",
    },
  },
}
