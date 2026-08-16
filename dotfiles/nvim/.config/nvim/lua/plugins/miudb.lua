---@type LazySpec
return {
  {
    dir = "/Users/vanducng/git/personal/miu-db/ui/miu-db.nvim",
    name = "miu-db.nvim",
    ft = { "sql" },
    cmd = {
      "MiuDBConnections",
      "MiuDBQuery",
      "MiuDBSelectConnection",
    },
    keys = {
      {
        "<leader>Dd",
        "<cmd>MiuDBSelectConnection<cr>",
        desc = "Select miudb connection",
      },
      {
        "<leader>Dl",
        "<cmd>MiuDBConnections<cr>",
        desc = "List miudb connections",
      },
      {
        "<leader>Dq",
        "<cmd>MiuDBQuery<cr>",
        desc = "Run SQL buffer with miudb",
      },
      {
        "<leader>j",
        "<cmd>MiuDBQuery<cr>",
        desc = "Run SQL buffer with miudb",
        ft = "sql",
      },
    },
  },
}
