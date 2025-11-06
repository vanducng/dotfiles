return {
  "mikavilpas/yazi.nvim",
  event = "VeryLazy",
  keys = {
    {
      "<leader>,",
      "<cmd>Yazi<cr>",
      desc = "Open yazi at current file",
    },
    {
      "<leader>cw",
      "<cmd>Yazi cwd<cr>",
      desc = "Open yazi in working directory",
    },
    {
      "<c-up>",
      "<cmd>Yazi toggle<cr>",
      desc = "Resume yazi session",
    },
  },
  opts = {
    -- Floating window configuration
    floating_window_scaling_factor = 0.9,
    yazi_floating_window_winblend = 0,
    yazi_floating_window_border = "rounded",

    -- Integration settings
    open_for_directories = false, -- Let Oil handle directory opening
    clipboard_register = "*", -- Use system clipboard
    highlight_hovered_buffers_in_same_directory = true, -- Visual feedback

    -- Keymaps inside yazi
    keymaps = {
      show_help = "<f1>",
      open_file_in_vertical_split = "<c-v>",
      open_file_in_horizontal_split = "<c-x>",
      open_file_in_tab = "<c-t>",
      grep_in_directory = "<c-s>", -- Requires fzf-lua
      replace_in_directory = "<c-g>", -- Requires grug-far (optional)
      cycle_open_buffers = "<tab>", -- Cycle through open buffers
      copy_relative_path_to_selected_files = "<c-y>",
      send_to_quickfix_list = "<c-q>", -- Send selected files to quickfix
    },

    -- Hooks for custom behavior
    hooks = {
      yazi_opened = function()
        -- Optional: notify when yazi opens
        -- vim.notify("Yazi opened", vim.log.levels.INFO)
      end,
      yazi_closed_successfully = function(chosen_file, config, state)
        -- Auto-save before opening file from yazi
        if vim.bo.modified then
          vim.cmd "write"
        end
      end,
      yazi_opened_multiple_files = function(chosen_files, config, state)
        -- Open multiple files in quickfix list
        vim.fn.setqflist({}, "r", {
          title = "Yazi",
          items = vim.tbl_map(function(file)
            return { filename = file, lnum = 1 }
          end, chosen_files),
        })
        vim.cmd "copen"
      end,
    },

    -- Performance
    log_level = vim.log.levels.OFF,

    -- Integration with your existing fzf-lua setup
    integrations = {
      grep_in_directory = function(directory)
        -- Use your configured fzf-lua for grepping
        require("fzf-lua").live_grep { cwd = directory }
      end,
      grep_in_selected_files = function(selected_files)
        -- Grep only in selected files
        require("fzf-lua").live_grep {
          cmd = "rg --column --line-number --no-heading --color=always --smart-case "
            .. table.concat(
              vim.tbl_map(function(file) return vim.fn.shellescape(file) end, selected_files),
              " "
            ),
        }
      end,
    },
  },
}
