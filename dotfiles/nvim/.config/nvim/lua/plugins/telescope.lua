return {
  "nvim-telescope/telescope.nvim",
  -- Ensure telescope loads early if needed
  priority = 100,
  -- Dependencies to ensure they load first
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = function(_, opts)
    local actions = require "telescope.actions"

    -- Initialize opts if it's nil
    opts = opts or {}
    opts.defaults = opts.defaults or {}
    opts.pickers = opts.pickers or {}

    -- Merge defaults mappings
    opts.defaults.mappings = vim.tbl_deep_extend("force", opts.defaults.mappings or {}, {
      n = {
        ["dd"] = actions.delete_buffer,
        ["<C-d>"] = actions.delete_buffer,
      },
      i = {
        ["<C-d>"] = actions.delete_buffer,
      },
    })

    -- Configure buffer-specific picker settings
    opts.pickers.buffers = vim.tbl_deep_extend("force", opts.pickers.buffers or {}, {
      mappings = {
        n = {
          ["dd"] = actions.delete_buffer,
          ["<C-d>"] = actions.delete_buffer,
        },
        i = {
          ["<C-d>"] = actions.delete_buffer,
        },
      },
    })

    return opts
  end,
  -- Remove the config function - lazy.nvim will handle setup automatically
}
