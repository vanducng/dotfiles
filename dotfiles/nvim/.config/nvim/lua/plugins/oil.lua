return {
  "stevearc/oil.nvim",
  ---@module 'oil'
  ---@type oil.SetupOpts
  dependencies = { "echasnovski/mini.icons" },
  lazy = false,
  keys = {
    { "<C-b>", function() require("oil").select { vertical = true } end, desc = "Open buffer in vertical view" },
  },
  opts = {
    default_file_explorer = false, -- Let yazi handle directory navigation
    padding = true,
    view_options = {
      show_hidden = true,
    },
    keymaps = {
      ["yp"] = {
        desc = "Copy filepath to system clipboard",
        callback = function()
          require("oil.actions").copy_entry_path.callback()
          vim.fn.setreg("+", vim.fn.getreg(vim.v.register))
        end,
      },
    },
  },
}
