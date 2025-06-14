return {
  {
    "MattiasMTS/cmp-dbee",
    branch = "ms/v2",
    dependencies = { "vanducng/nvim-dbee" },
    ft = "sql",
    enabled = false, -- Disable for now due to compatibility issues
    opts = {},
  },
  {
    "saghen/blink.cmp",
    opts = {
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        per_filetype = {
          sql = { "buffer" }, -- Only use buffer completion for SQL for now
        },
      },
    },
  },
}
