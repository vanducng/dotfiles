return {
  "stevearc/oil.nvim",
  ---@module 'oil'
  ---@type oil.SetupOpts
  dependencies = { "echasnovski/mini.icons" },
  lazy = false,
  config = function()
    require("oil").setup {
      padding = true,
      keymaps = {
        ["yp"] = {
          desc = "Copy filepath to system clipboard",
          callback = function()
            require("oil.actions").copy_entry_path.callback()
            vim.fn.setreg("+", vim.fn.getreg(vim.v.register))
          end,
        },
      },
    }
  end,
  keys = {
    { "<C-b>", function() require("oil").select { vertical = true } end, desc = "Open buffer in vertical view" },
    { "<leader>e", "<cmd>Oil<cr>", desc = "Open file explorer (Oil)" }, -- Replaces neo-tree <leader>e
    { "-", "<cmd>Oil<cr>", desc = "Open parent directory (Oil)" }, -- Quick access
  },
  opts = {
    default_file_explorer = true,
    view_options = {
      show_hidden = true,
    },
  },
}
