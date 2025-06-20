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

        -- navigate buffer tabs
        ["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

        -- mappings seen under group name "Buffer"
        ["<Leader>bd"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Close buffer from tabline",
        },

        -- tables with just a `desc` key will be registered with which-key if it's installed
        -- this is useful for naming menus
        -- ["<Leader>b"] = { desc = "Buffers" },
        ["<Leader>D"] = { desc = "󰆼 Database" },

        -- Telescope keymaps with zen mode preservation
        ["<Leader>ff"] = {
          function()
            vim.g.zen_telescope_was_active = vim.g.zen_mode_active == true
            require("telescope.builtin").find_files()
          end,
          desc = "Find files",
        },
        ["<Leader>fF"] = {
          function()
            vim.g.zen_telescope_was_active = vim.g.zen_mode_active == true
            require("telescope.builtin").find_files({ hidden = true, no_ignore = true })
          end,
          desc = "Find files (including hidden)",
        },
        ["<Leader>fw"] = {
          function()
            vim.g.zen_telescope_was_active = vim.g.zen_mode_active == true
            require("telescope.builtin").live_grep()
          end,
          desc = "Find words",
        },
        ["<Leader>fb"] = {
          function()
            vim.g.zen_telescope_was_active = vim.g.zen_mode_active == true
            require("telescope.builtin").buffers()
          end,
          desc = "Find buffers",
        },
        ["<Leader>fh"] = {
          function()
            vim.g.zen_telescope_was_active = vim.g.zen_mode_active == true
            require("telescope.builtin").help_tags()
          end,
          desc = "Find help",
        },
        ["<Leader>fo"] = {
          function()
            vim.g.zen_telescope_was_active = vim.g.zen_mode_active == true
            require("telescope.builtin").oldfiles()
          end,
          desc = "Find history",
        },
        ["<Leader>gc"] = {
          function()
            vim.g.zen_telescope_was_active = vim.g.zen_mode_active == true
            require("telescope.builtin").git_commits()
          end,
          desc = "Git commits",
        },
        ["<Leader>gt"] = {
          function()
            vim.g.zen_telescope_was_active = vim.g.zen_mode_active == true
            require("telescope.builtin").git_status()
          end,
          desc = "Git status",
        },

        -- setting a mapping to false will disable it
        -- ["<C-S>"] = false,
      },
    },
  },
}
