return {
  {
    dir = "/Users/vanducng/dotfiles/dev/cmp-dbee", -- Use local dev version with fixes
    name = "cmp-dbee",
    dependencies = { 
      "vanducng/nvim-dbee",
      "saghen/blink.cmp",
    },
    event = { "BufRead *.sql", "BufNewFile *.sql" }, -- Load on SQL files
    ft = "sql",
    enabled = true, -- Re-enabled with compatibility fixes
    config = function()
      -- Setup cmp-dbee with performance optimizations and optional debug logging
      local ok, cmp_dbee = pcall(require, "cmp-dbee")
      if ok and cmp_dbee then
        cmp_dbee.setup({
          -- Performance optimizations
          cache = {
            structure_expiry_s = 60,  -- Cache DB structure for 1 minute
            column_expiry_s = 300,    -- Cache columns for 5 minutes
            preload_common_tables = false,  -- Disabled to improve initial connection performance
          },
          completion = {
            debounce_delay_ms = 300,  -- Increased debounce delay for better performance
            max_items = 100,
          },
          -- Disable completion for specific database types
          disabled_databases = { "snowflake" },
          -- Database-specific overrides (optional, for fine-grained control)
          database_overrides = {
            -- Example: Allow execution but disable completion for specific databases
            -- bigquery = {
            --   completion_enabled = false,
            --   execution_enabled = true,
            -- },
          },
          -- Enable debug logging for troubleshooting (set to false for production)
          debug = {
            enabled = true,  -- Set to true to enable debug logging
            log_disabled_connections = true,  -- Log when completion is disabled
            performance_monitoring = true,  -- Set to true to monitor performance
            log_slow_queries = true,  -- Log operations > 100ms
            slow_query_threshold_ms = 100,
            log_context_detection = true,  -- Set to true to debug context detection
            log_cache_hits = true,  -- Set to true to debug caching
          },
        })
        -- Notification disabled per user request
      else
        vim.notify("cmp-dbee module not found - plugin may not be installed correctly", vim.log.levels.WARN)
      end
    end,
  },
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      -- Ensure sources table exists
      opts.sources = opts.sources or {}
      opts.sources.default = opts.sources.default or { "lsp", "path", "snippets", "buffer" }
      opts.sources.per_filetype = opts.sources.per_filetype or {}
      opts.sources.providers = opts.sources.providers or {}
      
      -- Always configure dbee provider (will be available when needed)
      opts.sources.per_filetype.sql = { "lsp", "path", "snippets", "buffer", "dbee" }
      
      -- Configure dbee provider for blink.cmp
      opts.sources.providers.dbee = {
        name = "dbee",
        module = "cmp-dbee.blink-wrapper", -- Use wrapper that can disable itself
        enabled = true,
        async = true,
        timeout_ms = 1000,
      }
      
      return opts
    end,
    config = function(_, opts)
      -- Apply the configuration and verify it worked
      require("blink.cmp").setup(opts)
      
      -- Defer verification to ensure setup is complete
      vim.defer_fn(function()
        local blink_ok, blink = pcall(require, "blink.cmp")
        if blink_ok and blink.config then
          if blink.config.sources and blink.config.sources.providers and blink.config.sources.providers.dbee then
            -- Success notification disabled per user request
          else
            vim.notify("❌ cmp-dbee provider not found in blink.cmp config", vim.log.levels.WARN)
          end
        end
      end, 100)
    end,
  },
}
