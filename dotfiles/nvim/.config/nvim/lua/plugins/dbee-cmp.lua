return {
  {
    "vanducng/cmp-dbee", -- Use remote repository with blink.cmp support
    dependencies = { 
      "vanducng/nvim-dbee",
      "saghen/blink.cmp",
    },
    event = { "BufRead *.sql", "BufNewFile *.sql" }, -- Load on SQL files
    ft = "sql",
    enabled = true, -- Enable with new blink.cmp compatibility
    config = function()
      -- Setup cmp-dbee with performance optimizations and optional debug logging
      local ok, cmp_dbee = pcall(require, "cmp-dbee")
      if ok and cmp_dbee then
        cmp_dbee.setup({
          -- Performance optimizations
          cache = {
            structure_expiry_s = 60,  -- Cache DB structure for 1 minute
            column_expiry_s = 300,    -- Cache columns for 5 minutes
            preload_common_tables = true,
          },
          completion = {
            debounce_delay_ms = 150,  -- Debounce completion requests
            max_items = 100,
          },
          -- Enable debug logging for troubleshooting (set to false for production)
          debug = {
            enabled = false,  -- Set to true to enable debug logging
            performance_monitoring = false,  -- Set to true to monitor performance
            log_slow_queries = true,  -- Log operations > 100ms
            slow_query_threshold_ms = 100,
            log_context_detection = false,  -- Set to true to debug context detection
            log_cache_hits = false,  -- Set to true to debug caching
          },
        })
        vim.notify("cmp-dbee configured successfully with performance optimizations", vim.log.levels.INFO)
      else
        vim.notify("cmp-dbee module not found - plugin may not be installed correctly", vim.log.levels.WARN)
      end
    end,
  },
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      -- Check if cmp-dbee with blink.cmp support is available
      local cmp_dbee_available = pcall(require, "cmp-dbee")
      
      -- Ensure sources table exists
      opts.sources = opts.sources or {}
      opts.sources.default = opts.sources.default or { "lsp", "path", "snippets", "buffer" }
      opts.sources.per_filetype = opts.sources.per_filetype or {}
      opts.sources.providers = opts.sources.providers or {}
      
      if cmp_dbee_available then
        vim.notify("cmp-dbee with blink.cmp support loaded successfully", vim.log.levels.INFO)
        
        -- Add dbee to SQL filetype sources
        opts.sources.per_filetype.sql = { "lsp", "path", "snippets", "buffer", "dbee" }
        
        -- Configure dbee provider for blink.cmp
        opts.sources.providers.dbee = {
          name = "dbee",
          module = "cmp-dbee",
          enabled = true,
          async = true,
          timeout_ms = 1000,
        }
      else
        vim.notify("cmp-dbee not available, using default SQL completion", vim.log.levels.WARN)
        -- Fallback: just use default sources for SQL
        opts.sources.per_filetype.sql = { "lsp", "path", "snippets", "buffer" }
      end
      
      return opts
    end,
  },
}
