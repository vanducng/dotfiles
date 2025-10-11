return {
  "nvim-neo-tree/neo-tree.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    -- Disable logging before setup to prevent errors
    vim.g.neo_tree_remove_legacy_commands = 1

    require("neo-tree").setup({
      enable_diagnostics = false,
      enable_git_status = true,

      -- Completely disable logging
      enable_normal_mode_for_inputs = false,
      enable_cursor_hijack = false,

      filesystem = {
        filtered_items = {
          visible = false,
          hide_dotfiles = true,
          hide_gitignored = true,
          hide_by_name = {
            ".DS_Store",
            "thumbs.db",
            "node_modules",
            "__pycache__",
          },
        },
        follow_current_file = {
          enabled = false,
        },
        use_libuv_file_watcher = false,
      },

      -- Window settings
      window = {
        mappings = {
          ["<space>"] = "none",
        },
      },
    })
  end,
}
