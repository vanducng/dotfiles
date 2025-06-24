---@type LazySpec
return {
  {
    "toppair/peek.nvim",
    enabled = false, -- Disabled by default, enable if you prefer this over markdown-preview.nvim
    event = { "VeryLazy" },
    build = "deno task --quiet build:fast",
    config = function()
      require("peek").setup({
        -- Configuration for peek.nvim
        
        -- Auto-load preview when entering markdown buffer
        auto_load = true,
        
        -- Close preview when buffer is deleted
        close_on_bdelete = true,
        
        -- Enable syntax highlighting in preview
        syntax = true,
        
        -- Theme for preview (dark or light)
        theme = "dark",
        
        -- Update preview on TextChanged event
        update_on_change = true,
        
        -- Preview application (webview or browser)
        app = "webview", -- or "browser" to use default browser
        
        -- File types to enable peek for
        filetype = { "markdown" },
        
        -- Throttle updates (ms) - useful for large files
        throttle_at = 200000, -- 200KB
        throttle_time = 1000, -- 1 second
      })
      
      -- Auto-start peek for markdown files
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          -- Optional: Auto-start preview (uncomment to enable)
          -- vim.cmd("PeekOpen")
          
          -- Set buffer options for markdown files
          vim.opt_local.wrap = true
          vim.opt_local.linebreak = true
          vim.opt_local.spell = true
          vim.opt_local.conceallevel = 2
        end,
        desc = "Configure buffer options for Markdown files",
      })
    end,
    keys = {
      { "<leader>po", "<cmd>PeekOpen<cr>", desc = "Open Peek Preview" },
      { "<leader>pc", "<cmd>PeekClose<cr>", desc = "Close Peek Preview" },
    },
  },
}