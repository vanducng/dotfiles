---@type LazySpec
return {
  "vanducng/nvim-dbee",
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  build = function()
    require("dbee").install("go")
  end,
  config = function()
    require("dbee").setup({
      sources = {
        -- Load connections from environment variable (optional)
        require("dbee.sources").EnvSource:new("DBEE_CONNECTIONS"),
        -- Load connections from persistent file (primary method)
        require("dbee.sources").FileSource:new(vim.fn.stdpath("cache") .. "/dbee/persistence.json"),
      },
      editor = {
        mappings = {
          -- Default DBEE mappings
          { key = "BB", mode = "v", action = "run_selection" },
          { key = "BB", mode = "n", action = "run_file" },
        },
      },
    })
    
    -- Load database helpers (lazy-loaded, no hardcoded credentials)
    require("config.dbee-helpers")
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
      "<cmd>Dbee<cr>",
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
          -- Use DBEE's new run_statement action
          local api = require("dbee.api")
          local ok, err = pcall(function()
            api.ui.editor_do_action("run_statement")
          end)
          
          if not ok then
            vim.notify("Failed to execute SQL statement: " .. tostring(err), vim.log.levels.ERROR)
          end
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
          local api = require("dbee.api")
          local ok, err = pcall(function()
            api.ui.editor_do_action("select_statement")
          end)
          
          if not ok then
            vim.notify("Failed to select SQL statement: " .. tostring(err), vim.log.levels.ERROR)
          end
        else
          vim.notify("Not in a SQL buffer", vim.log.levels.WARN)
        end
      end,
      desc = "Select SQL statement (semicolon-delimited)",
    },
  },
}