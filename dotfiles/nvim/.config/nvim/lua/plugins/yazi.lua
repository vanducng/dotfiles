return {
  "mikavilpas/yazi.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  event = "VeryLazy",
  keys = {
    {
      "<leader>yf",
      function()
        -- Set environment variables for better image support
        vim.env.TERM_PROGRAM = "ghostty"
        vim.env.GHOSTTY = "1"
        -- Set high DPI for PDF rendering
        vim.env.YAZI_PDF_OPTS = "-r 300"
        require("yazi").yazi()
      end,
      desc = "Open yazi at current file",
    },
    {
      "<leader>yw",
      function()
        -- Set environment variables for better image support
        vim.env.TERM_PROGRAM = "ghostty"
        vim.env.GHOSTTY = "1"
        -- Set high DPI for PDF rendering
        vim.env.YAZI_PDF_OPTS = "-r 300"
        require("yazi").yazi(nil, vim.fn.getcwd())
      end,
      desc = "Open yazi in working directory",
    },
  },
  ---@type YaziConfig
  opts = {
    -- Open yazi instead of netrw for directories
    open_for_directories = false, -- Keep oil as default

    -- Set environment for image support in tmux
    yazi_config_home = vim.fn.expand "~/.config/yazi",

    -- Size of the floating window
    floating_window_scaling_factor = 0.9,

    -- Transparency of the yazi floating window (0-100)
    yazi_floating_window_winblend = 0,

    -- Highlight settings
    highlight_hovered_buffers_in_same_directory = true,

    -- Keymaps while yazi is open
    keymaps = {
      show_help = "<f1>",
      open_file_in_vertical_split = "<c-v>",
      open_file_in_horizontal_split = "<c-x>",
      open_file_in_tab = "<c-t>",
      grep_in_directory = "<c-s>",
      replace_in_directory = "<c-g>",
      cycle_open_buffers = "<tab>",
      copy_relative_path_to_selected_files = "<c-y>",
      send_to_quickfix_list = "<c-q>",
      change_working_directory = "<c-\\>",
    },

    -- Events to enable/disable certain features
    enable_mouse_support = true,

    -- Log level
    log_level = vim.log.levels.OFF,

    -- Hooks
    hooks = {
      -- Run when yazi is opened
      yazi_opened = function()
        -- You can add custom logic here
      end,
      -- Run when yazi is closed
      yazi_closed_successfully = function(chosen_file)
        -- You can add custom logic here
      end,
    },
  },
}
