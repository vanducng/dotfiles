---@type LazySpec
return {
  "vanducng/nvim-dbee",
  branch = "main",
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  build = function() require("dbee").install "go" end,
  config = function()
    -- Defer the setup to prevent auto-connection on startup
    _G.dbee_setup_done = false

    _G.setup_dbee = function()
      if _G.dbee_setup_done then return end

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

      -- Setup cmp-dbee for auto completion (if available)
      local cmp_dbee_ok, cmp_dbee = pcall(require, "cmp-dbee")
      if cmp_dbee_ok then
        cmp_dbee.setup()
      end

      _G.dbee_setup_done = true
    end

    -- Load database helpers (lazy-loaded, no hardcoded credentials)
    require "config.dbee-helpers"
  end,
  cmd = {
    "Dbee",
    "DbeeToggle",
    "DbeeExecuteQuery",
  },
  init = function()
    -- Wrap the original commands to ensure setup is called first
    local function wrap_dbee_command(cmd_name)
      local original_cmd = vim.fn.exists(":" .. cmd_name) == 2
      if not original_cmd then
        vim.api.nvim_create_user_command(cmd_name, function(opts)
          _G.setup_dbee()
          vim.cmd(cmd_name .. " " .. opts.args)
        end, { nargs = "*" })
      end
    end

    -- Wrap the commands
    vim.api.nvim_create_autocmd("CmdlineEnter", {
      once = true,
      callback = function()
        wrap_dbee_command "Dbee"
        wrap_dbee_command "DbeeToggle"
        wrap_dbee_command "DbeeExecuteQuery"
      end,
    })
  end,
  keys = {
    {
      "<leader>D",
      desc = "󰆼 Database",
    },
    {
      "<leader>Dd",
      function()
        -- Setup dbee if not already done
        _G.setup_dbee()
        -- Open Dbee
        require("dbee").open()
      end,
      desc = "Open Database Explorer",
    },
    {
      "<leader>Dt",
      function()
        -- Setup dbee if not already done
        _G.setup_dbee()
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
          local api = require "dbee.api"
          local ok, err = pcall(function() api.ui.editor_do_action "run_statement" end)

          if not ok then vim.notify("Failed to execute SQL statement: " .. tostring(err), vim.log.levels.ERROR) end
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

          if not ok then vim.notify("Failed to select SQL statement: " .. tostring(err), vim.log.levels.ERROR) end
        else
          vim.notify("Not in a SQL buffer", vim.log.levels.WARN)
        end
      end,
      desc = "Select SQL statement (semicolon-delimited)",
    },
  },
}
