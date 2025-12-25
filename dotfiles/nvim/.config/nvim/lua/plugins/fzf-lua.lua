return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = function()
    local actions = require "fzf-lua.actions"

    return {
      -- Use fzf-native profile for better performance
      "default-title",

      -- Global options
      winopts = {
        height = 0.85,
        width = 0.85,
        row = 0.5,
        col = 0.5,
        border = "rounded",
        preview = {
          default = "bat", -- Use bat for syntax highlighting
          border = "rounded",
          wrap = "nowrap",
          hidden = "nohidden",
          vertical = "down:45%",
          horizontal = "right:60%",
          layout = "flex", -- Auto-switch between horizontal/vertical
          flip_columns = 120, -- Switch to horizontal when width > 120
          title = true,
          title_pos = "center",
          scrollbar = "float",
          scrolloff = "-2",
          delay = 50, -- Delay preview to reduce lag
          winopts = {
            number = false,
            relativenumber = false,
            cursorline = true,
            cursorlineopt = "both",
            cursorcolumn = false,
            signcolumn = "no",
            foldcolumn = "0",
          },
        },
      },

      -- Key bindings inside fzf window
      keymap = {
        builtin = {
          ["<F1>"] = "toggle-help",
          ["<F2>"] = "toggle-fullscreen",
          ["<F3>"] = "toggle-preview-wrap",
          ["<F4>"] = "toggle-preview",
          ["<F5>"] = "toggle-preview-ccw",
          ["<F6>"] = "toggle-preview-cw",
          ["<C-d>"] = "preview-page-down",
          ["<C-u>"] = "preview-page-up",
          ["<C-f>"] = "preview-down",
          ["<C-b>"] = "preview-up",
        },
        fzf = {
          ["ctrl-q"] = "select-all+accept", -- Send all to quickfix
          ["ctrl-u"] = "unix-line-discard",
          ["ctrl-a"] = "beginning-of-line",
          ["ctrl-e"] = "end-of-line",
          ["alt-a"] = "toggle-all",
        },
      },

      -- Custom actions
      actions = {
        files = {
          ["default"] = actions.file_edit_or_qf,
          ["ctrl-s"] = actions.file_split,
          ["ctrl-v"] = actions.file_vsplit,
          ["ctrl-t"] = actions.file_tabedit,
          ["ctrl-q"] = actions.file_sel_to_qf,
          ["alt-q"] = actions.file_sel_to_ll,
        },
        buffers = {
          ["default"] = actions.buf_edit,
          ["ctrl-s"] = actions.buf_split,
          ["ctrl-v"] = actions.buf_vsplit,
          ["ctrl-t"] = actions.buf_tabedit,
          ["ctrl-x"] = actions.buf_del,
        },
      },

      -- fzf native options
      fzf_opts = {
        ["--ansi"] = "",
        ["--info"] = "inline",
        ["--height"] = "100%",
        ["--layout"] = "reverse",
        ["--border"] = "none",
        ["--highlight-line"] = "", -- Highlight current line (fzf >=0.53)
        ["--prompt"] = "❯ ",
        ["--pointer"] = "▶",
        ["--marker"] = "✓",
      },

      -- File picker options
      files = {
        prompt = "Files❯ ",
        multiprocess = true,
        git_icons = true,
        file_icons = true,
        color_icons = true,
        find_opts = [[-type f -not -path '*/\.git/*' -printf '%P\n']],
        fd_opts = [[--color=never --type f --hidden --follow --exclude .git --exclude node_modules]],
        actions = {
          ["ctrl-g"] = actions.toggle_ignore,
        },
      },

      -- Grep options
      grep = {
        prompt = "Rg❯ ",
        input_prompt = "Grep For❯ ",
        multiprocess = true,
        git_icons = true,
        file_icons = true,
        color_icons = true,
        grep_opts = "--binary-files=without-match --line-number --recursive --color=auto --perl-regexp -e",
        rg_opts = [[--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e]],
        actions = {
          ["ctrl-g"] = { actions.grep_lgrep },
        },
      },

      -- LSP options
      lsp = {
        prompt_postfix = "❯ ",
        cwd_only = false, -- Search in all buffers, not just cwd
        async_or_timeout = 5000,
        file_icons = true,
        git_icons = false,
        lsp_icons = true,
        severity_only = nil, -- Show all severities
        symbols = {
          async_or_timeout = true,
          symbol_style = 3, -- 1: icon+kind, 2: icon, 3: kind
          symbol_hl_prefix = "CmpItemKind",
          symbol_fmt = function(s, opts)
            return "[" .. s .. "]"
          end,
        },
        code_actions = {
          prompt = "Code Actions❯ ",
          async_or_timeout = 5000,
          previewer = "codeaction_native",
        },
      },

      -- Git options
      git = {
        status = {
          prompt = "GitStatus❯ ",
          preview_pager = "delta --width=$FZF_PREVIEW_COLUMNS",
          actions = {
            ["right"] = { actions.git_unstage, actions.resume },
            ["left"] = { actions.git_stage, actions.resume },
          },
        },
        commits = {
          prompt = "Commits❯ ",
          preview_pager = "delta --width=$FZF_PREVIEW_COLUMNS",
          actions = {
            ["default"] = actions.git_checkout,
          },
        },
        bcommits = {
          prompt = "Buffer Commits❯ ",
          preview_pager = "delta --width=$FZF_PREVIEW_COLUMNS",
        },
        branches = {
          prompt = "Branches❯ ",
          actions = {
            ["default"] = actions.git_switch,
          },
        },
      },

      -- Buffers
      buffers = {
        prompt = "Buffers❯ ",
        file_icons = true,
        color_icons = true,
        sort_lastused = true,
        actions = {
          ["ctrl-x"] = { actions.buf_del, actions.resume },
        },
      },

      -- Quickfix/Location list
      quickfix = {
        file_icons = true,
        git_icons = true,
      },
    }
  end,
}
