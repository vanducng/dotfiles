return {
  "romgrk/barbar.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons", -- patched fonts support
    "lewis6991/gitsigns.nvim", -- display git status
  },
  init = function() vim.g.barbar_auto_setup = false end,
  config = function()
    local barbar = require "barbar"

    barbar.setup {
      clickable = true, -- Enables/disables clickable tabs
      tabpages = false, -- Enable/disables current/total tabpages indicator (top right corner)
      insert_at_end = true,
      icons = {
        button = "",
        buffer_index = true,
        filetype = { enabled = true },
        visible = { modified = { buffer_number = false } },
        gitsigns = {
          added = { enabled = true, icon = "+" },
          changed = { enabled = true, icon = "~" },
          deleted = { enabled = true, icon = "-" },
        },
      },
    }

    -- key maps

    local map = vim.api.nvim_set_keymap
    local opts = { noremap = true, silent = true }

    -- Move to previous/next
    map("n", "<A-,>", "<Cmd>BufferPrevious<CR>", opts)
    map("n", "<A-.>", "<Cmd>BufferNext<CR>", opts)
    -- Re-order to previous/next
    map("n", "<A-n>", "<Cmd>BufferMovePrevious<CR>", opts)
    map("n", "<A-m>", "<Cmd>BufferMoveNext<CR>", opts)
    -- Goto buffer in position...
    map("n", "<A-y>", "<Cmd>BufferGoto 1<CR>", opts)
    map("n", "<A-u>", "<Cmd>BufferGoto 2<CR>", opts)
    map("n", "<A-i>", "<Cmd>BufferGoto 3<CR>", opts)
    map("n", "<A-o>", "<Cmd>BufferGoto 4<CR>", opts)
    map("n", "<A-h>", "<Cmd>BufferGoto 5<CR>", opts)
    map("n", "<A-j>", "<Cmd>BufferGoto 6<CR>", opts)
    map("n", "<A-k>", "<Cmd>BufferGoto 7<CR>", opts)
    map("n", "<A-l>", "<Cmd>BufferGoto 8<CR>", opts)
    map("n", "<A-;>", "<Cmd>BufferLast<CR>", opts)
    -- Pin/unpin buffer
    map("n", "<A-p>", "<Cmd>BufferPin<CR>", opts)
    -- Close buffer
    map("n", "<A-c>", "<Cmd>BufferClose<CR>", opts)
    map("n", "<A-b>", "<Cmd>BufferCloseAllButCurrent<CR>", opts)
  end,
}
