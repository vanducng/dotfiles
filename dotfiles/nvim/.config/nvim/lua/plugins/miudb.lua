---@type LazySpec
return {
  {
    dir = "/Users/vanducng/git/personal/worktrees/miu-db-golang/ui/miu-db.nvim",
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
        function()
          if vim.bo.filetype ~= "sql" then
            vim.notify("Not in a SQL buffer", vim.log.levels.WARN)
            return
          end
          vim.cmd "MiuDBQuery"
        end,
        desc = "Run SQL buffer with miudb",
      },
    },
  },
}
