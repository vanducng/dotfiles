return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    -- Disable logging to prevent errors
    enable_diagnostics = false,
    enable_git_status = true,
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
    },
    -- Fix logging issues
    log_level = "error", -- Only log errors, not info
    log_to_file = false, -- Disable file logging
  },
}
