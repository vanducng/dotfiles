---@type LazySpec
return {
  "Maxteabag/sqlit.nvim",
  opts = { keymap = false },
  keys = {
    {
      "<leader>D",
      function()
        local sqlit = require "sqlit"
        local cmd = "sqlit --theme " .. (sqlit.config.theme or "textual-ansi")
        vim.cmd "tabnew"
        vim.fn.termopen(cmd, {
          on_exit = function()
            vim.schedule(function()
              pcall(vim.cmd, "tabclose")
            end)
          end,
        })
        vim.cmd "startinsert"
      end,
      desc = "Database (sqlit)",
    },
  },
}
