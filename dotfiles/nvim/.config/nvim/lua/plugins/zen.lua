-- Calculate zen mode width: 70% of editor width, minimum 150 columns
local function zen_mode_width()
  local editor_width = vim.o.columns
  local target_width = math.floor(editor_width * 0.7)
  -- Ensure width is at least 150 columns
  return math.max(150, target_width)
end

-- Store zen mode state
local zen_mode_active = false

return {
  -- Not performant so only enable when needed
  {
    "folke/twilight.nvim",
    lazy = true,
    opts = {
      dimming = {
        inactive = true, -- when true, other windows will be fully dimmed (unless they contain the same buffer)
      },
      context = 20, -- amount of lines we will try to show around the current line
      treesitter = true, -- use treesitter when available for the filetype
    },
    keys = {
      {
        "<leader>tt",
        "<cmd>Twilight<cr>",
        desc = "Toggle twilight",
      },
    },
  },
  {
    "folke/zen-mode.nvim",
    cmd = { "ZenMode" },
    config = function()
      local zen_mode = require "zen-mode"

      -- Setup zen mode with options
      zen_mode.setup {
        window = {
          width = function() return zen_mode_width() end,
          height = 1.0, -- full height
          backdrop = 0.95, -- darken background
          options = {
            signcolumn = "no", -- disable signcolumn
            number = false, -- disable number column
            relativenumber = false, -- disable relative numbers
            cursorline = false, -- disable cursorline
            cursorcolumn = false, -- disable cursor column
            foldcolumn = "0", -- disable fold column
            list = false, -- disable whitespace characters
          },
        },
        plugins = {
          options = {
            enabled = true,
            ruler = false, -- disables the ruler text in the cmd line area
            showcmd = false, -- disables the command in the last line of the screen
            laststatus = 0, -- turn off the statusline in zen mode
          },
          twilight = { enabled = false }, -- disables to start Twilight when zen mode opens
          -- NOTE: Those options are disables by default, change to enabled = true to enable
          gitsigns = { enabled = false }, -- disables git signs
          tmux = { enabled = true }, -- disables the tmux statusline
          -- NOTE: Need to add to wezterm config https://github.com/folke/zen-mode.nvim#wezterm
          wezterm = {
            enabled = false,
            font = "+1", -- +1 font size or fixed size, e.g. 21
          },
          alacritty = {
            enabled = true,
            font = "19.5", -- set font size to 19.5
          },
          kitty = {
            enabled = true,
            font = "+1", -- increase font size by 1
          },
          neovide = {
            enabled = true,
            scale = 1.1, -- Increase scale by 10%
          },
        },
      }

      -- Track zen mode state
      vim.api.nvim_create_autocmd("User", {
        pattern = "ZenModeEnter",
        callback = function()
          zen_mode_active = true
          vim.g.zen_mode_active = true -- Global state for keymaps
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "ZenModeLeave",
        callback = function()
          zen_mode_active = false
          vim.g.zen_mode_active = false -- Global state for keymaps
        end,
      })

      -- Telescope integration: restore zen mode after telescope file selection
      vim.api.nvim_create_autocmd("BufEnter", {
        callback = function()
          -- Use vim.schedule for immediate execution on next tick
          vim.schedule(function()
            local buftype = vim.bo.buftype
            local filetype = vim.bo.filetype
            local bufname = vim.api.nvim_buf_get_name(0)

            -- Check if this is a normal file buffer (not telescope or special)
            local is_normal_buffer = buftype == ""
              and filetype ~= "TelescopePrompt"
              and filetype ~= "TelescopeResults"
              and not bufname:match "^term://"
              and bufname ~= ""

            -- Restore zen mode if it was active before telescope
            if vim.g.zen_telescope_was_active and is_normal_buffer and not zen_mode_active then
              zen_mode.toggle {
                window = {
                  width = zen_mode_width(),
                  height = 1.0,
                },
              }
              vim.g.zen_telescope_was_active = false
            end
          end)
        end,
      })
    end,
    keys = {
      -- add <leader>z to enter zen mode
      {
        "<leader>z",
        function()
          require("zen-mode").toggle {
            window = {
              width = zen_mode_width(),
              height = 1.0,
            },
          }
        end,
        desc = "Distraction Free Mode",
      },
      -- add <leader>Z to enter zen mode with max width, no padding
      {
        "<leader>Z",
        function()
          require("zen-mode").toggle {
            window = {
              width = 1.0, -- max width (100%)
              height = 1.0, -- max height (100%)
              options = {
                number = false,
                relativenumber = false,
                foldcolumn = "0",
                list = false,
                showbreak = "NONE",
                signcolumn = "no",
              },
            },
          }
        end,
        desc = "Zen Mode Full Screen",
      },
      -- add <leader>zx to exit zen mode across all windows in tmux session
      {
        "<leader>zx",
        function()
          -- Exit zen mode in current neovim instance
          require("zen-mode").close()

          -- Send lua command to close zen mode to all tmux panes
          local tmux_session = vim.fn.system("tmux display-message -p '#S'"):gsub("\n", "")
          if tmux_session and tmux_session ~= "" then
            -- Send to all panes in the session
            vim.fn.system(
              string.format(
                "tmux list-panes -a -s -F '#{session_name}:#{window_index}.#{pane_index}' | grep '^%s:' | xargs -I {} tmux send-keys -t {} 'C-c' Escape ':lua require(\"zen-mode\").close()' Enter 2>/dev/null || true",
                tmux_session
              )
            )
            vim.notify("Zen mode exit command sent to all tmux panes", vim.log.levels.INFO)
          end
        end,
        desc = "Exit Zen Mode (All Tmux Panes)",
      },
    },
  },
}
