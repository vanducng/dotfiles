---@type LazySpec
local candidates = {
  vim.fn.expand "~/git/personal/miu-db/ui/miu-db.nvim",
  vim.fn.expand "~/work/git/personal/miu-db/ui/miu-db.nvim",
}

local dir
for _, candidate in ipairs(candidates) do
  if vim.fn.isdirectory(candidate) == 1 then
    dir = candidate
    break
  end
end

if not dir then
  return {}
end

return {
  {
    dir = dir,
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
