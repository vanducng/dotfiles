---@type LazySpec
return {
  "nvimtools/none-ls.nvim",
  opts = function(_, opts)
    -- opts variable is the default configuration table for the setup function call
    local null_ls = require "null-ls"

    -- Check supported formatters and linters
    -- https://github.com/nvimtools/none-ls.nvim/tree/main/lua/null-ls/builtins/formatting
    -- https://github.com/nvimtools/none-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics

    -- Only insert new sources, do not replace the existing ones
    -- (If you wish to replace, use `opts.sources = {}` instead of the `list_insert_unique` function)
    opts.sources = require("astrocore").list_insert_unique(opts.sources, {
      -- Set a formatter
      -- null_ls.builtins.formatting.stylua,
      null_ls.builtins.formatting.prettier.with({
        filetypes = { "markdown", "yaml", "json", "html", "css", "javascript", "typescript" },
      }),
      -- Note: Ruff formatting is now handled by the ruff LSP server
      -- If you still want to use ruff via null-ls, use:
      -- null_ls.builtins.formatting.ruff_format,
    })
  end,
}
