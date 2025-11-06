-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics = { virtual_text = true, virtual_lines = false }, -- diagnostic settings on startup
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },

    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
      update_in_insert = false, -- Don't update diagnostics while typing
    },

    -- Auto commands can be configured here
    autocmds = {
      -- Disable diagnostics in insert mode for better performance
      disable_diagnostics_in_insert = {
        {
          event = "InsertEnter",
          desc = "Disable diagnostics in insert mode",
          callback = function() vim.diagnostic.disable(0) end,
        },
        {
          event = "InsertLeave",
          desc = "Enable diagnostics when leaving insert mode",
          callback = function() vim.diagnostic.enable(0) end,
        },
      },
    },
    -- passed to `vim.filetype.add`
    filetypes = {
      -- see `:h vim.filetype.add` for usage
      extension = {
        foo = "fooscript",
      },
      filename = {
        [".foorc"] = "fooscript",
      },
      pattern = {
        [".*/etc/foo/.*"] = "fooscript",
      },
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = true, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        signcolumn = "yes", -- sets vim.opt.signcolumn to yes
        wrap = false, -- sets vim.opt.wrap
        ignorecase = true, -- case insensitive search
        smartcase = true, -- case sensitive if uppercase letter in search
        -- hlsearch = true, -- highlight search results
        -- incsearch = true, -- incremental search
        -- shortmess = vim.opt.shortmess - "S", -- show search count (e.g., [1/100])
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        -- second key is the lefthand side of the map
        ["<C-f>"] = { ":silent !tmux neww ~/.local/bin/tmux-sessionizer<cr>", desc = "Run tmux sessionizer" },
        ["-"] = { "<cmd>Oil<cr>", desc = "Open parent directory" },
        ["<Leader>k"] = { ":b#<cr>", desc = "Go to previous open buffer" },
        ["<Leader>K"] = { ":tabn<cr>", desc = "Go to previous tab" },
        ["<C-d>"] = { "<C-d>zz", desc = "Jump down and center" },
        ["<C-u>"] = { "<C-u>zz", desc = "Jump down and center" },
        ["<Leader>rf"] = {
          function()
            local current_file = vim.fn.expand "%:p"
            if current_file == "" then
              vim.notify("No file in current buffer", vim.log.levels.WARN)
              return
            end
            if vim.bo.filetype ~= "python" then
              vim.notify("Ruff can only be used on Python files", vim.log.levels.WARN)
              return
            end

            -- Run ruff with comprehensive rules:
            -- --fix: Automatically fix issues that can be auto-corrected
            -- --select I,W291,W292,W293,Q000: Select specific rules:
            --   I: Import sorting (isort rules)
            --   W291: Trailing whitespace
            --   W292: No newline at end of file
            --   W293: Blank line contains whitespace
            --   Q000: Double quote preference
            vim.cmd("!" .. "ruff check --fix --select I,W291,W292,W293,Q000 " .. vim.fn.shellescape(current_file))
          end,
          desc = "Ruff fix: imports, trailing spaces, EOF newlines",
        },

        -- tables with just a `desc` key will be registered with which-key if it's installed
        -- this is useful for naming menus
        ["<Leader>D"] = { desc = "󰆼 Database" },

        -- Open project root in Oil
        ["<Leader>e"] = {
          function()
            -- Find project root by looking for .git directory
            local function find_git_root()
              local current_file = vim.api.nvim_buf_get_name(0)
              local current_dir
              if current_file == "" then
                current_dir = vim.fn.getcwd()
              else
                current_dir = vim.fn.fnamemodify(current_file, ":h")
              end

              while current_dir ~= "/" do
                if vim.fn.isdirectory(current_dir .. "/.git") == 1 then
                  return current_dir
                end
                current_dir = vim.fn.fnamemodify(current_dir, ":h")
              end
              return vim.fn.getcwd() -- fallback to current working directory
            end

            local root = find_git_root()
            require("oil").open(root)
          end,
          desc = "Open project root in Oil",
        },

        -- Open current directory in Oil
        ["<Leader>."] = {
          function()
            local current_file = vim.api.nvim_buf_get_name(0)
            if current_file == "" then
              require("oil").open(vim.fn.getcwd())
            else
              require("oil").open(vim.fn.fnamemodify(current_file, ":h"))
            end
          end,
          desc = "Open current directory in Oil",
        },

        -- fzf-lua keymaps with zen mode preservation
        ["<Leader>ff"] = {
          function()
            vim.g.zen_fzf_was_active = vim.g.zen_mode_active == true
            require("fzf-lua").files()
          end,
          desc = "Find files",
        },
        ["<Leader>fF"] = {
          function()
            vim.g.zen_fzf_was_active = vim.g.zen_mode_active == true
            require("fzf-lua").files { cmd = "fd --hidden --no-ignore" }
          end,
          desc = "Find files (including hidden)",
        },
        ["<Leader>fw"] = {
          function()
            vim.g.zen_fzf_was_active = vim.g.zen_mode_active == true
            require("fzf-lua").live_grep()
          end,
          desc = "Find words",
        },
        ["<Leader>fb"] = {
          function()
            vim.g.zen_fzf_was_active = vim.g.zen_mode_active == true
            require("fzf-lua").buffers()
          end,
          desc = "Find buffers",
        },
        ["<Leader>fh"] = {
          function()
            vim.g.zen_fzf_was_active = vim.g.zen_mode_active == true
            require("fzf-lua").helptags()
          end,
          desc = "Find help",
        },
        ["<Leader>fo"] = {
          function()
            vim.g.zen_fzf_was_active = vim.g.zen_mode_active == true
            require("fzf-lua").oldfiles()
          end,
          desc = "Find history",
        },
        ["<Leader>gc"] = {
          function()
            vim.g.zen_fzf_was_active = vim.g.zen_mode_active == true
            require("fzf-lua").git_commits()
          end,
          desc = "Git commits",
        },
        ["<Leader>gt"] = {
          function()
            vim.g.zen_fzf_was_active = vim.g.zen_mode_active == true
            require("fzf-lua").git_status()
          end,
          desc = "Git status",
        },
        ["<Leader>gC"] = {
          function()
            vim.g.zen_fzf_was_active = vim.g.zen_mode_active == true
            require("fzf-lua").git_bcommits()
          end,
          desc = "Git commits (current file)",
        },

        -- setting a mapping to false will disable it
        -- ["<C-S>"] = false,
      },
    },
  },
}
