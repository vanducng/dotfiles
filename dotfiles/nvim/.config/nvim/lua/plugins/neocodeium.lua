---@type LazySpec
return {
  {
    "monkoose/neocodeium",
    event = "VeryLazy",
    config = function()
      -- Validation: Check if Copilot is enabled
      local copilot_enabled = false
      for _, plugin in pairs(require("lazy").plugins()) do
        if plugin.name == "copilot.vim" and not plugin._.disabled then
          copilot_enabled = true
          break
        end
      end
      
      if copilot_enabled then
        vim.notify("⚠️  Both NeoCodeium and Copilot are enabled. Please disable one to avoid conflicts.", vim.log.levels.WARN)
      end

      local neocodeium = require "neocodeium"

      neocodeium.setup {
        -- Basic configuration with minimal options to avoid errors
        enabled = true,
        manual = false,
        show_label = true,
        debounce = true,

        -- Filetype configuration - explicitly enable SQL and coding languages
        filetypes = {
          -- Disable for non-coding contexts
          help = false,
          gitcommit = false,
          gitrebase = false,
          hgcommit = false,
          svn = false,
          cvs = false,
          ["."] = false,

          -- Explicitly enable for coding languages
          sql = true,
          mysql = true,
          postgresql = true,
          plsql = true,
          lua = true,
          python = true,
          javascript = true,
          typescript = true,
          javascriptreact = true,
          typescriptreact = true,
          go = true,
          rust = true,
          java = true,
          cpp = true,
          c = true,
          php = true,
          ruby = true,
          yaml = true,
          json = true,
          toml = true,
          markdown = true,
          sh = true,
          bash = true,
          zsh = true,
          vim = true,
        },
      }

      -- Set up unified keymaps (same as Copilot for consistency)
      -- <Tab>: Accept suggestion or normal tab
      -- <C-j>: Accept full suggestion  
      -- <C-f>: Accept word
      -- <C-l>: Accept line
      -- <C-c>: Clear suggestion
      -- <C-i>: Cycle suggestions
      vim.keymap.set("i", "<Tab>", function()
        if neocodeium.visible() then
          neocodeium.accept()
        else
          -- Insert actual tab character or trigger completion
          local keys = vim.api.nvim_replace_termcodes("<Tab>", true, false, true)
          vim.api.nvim_feedkeys(keys, "n", false)
        end
      end, { desc = "Accept NeoCodeium suggestion or normal Tab" })
      
      vim.keymap.set("i", "<C-j>", function() neocodeium.accept() end, { desc = "Accept NeoCodeium full suggestion" })
      vim.keymap.set("i", "<C-f>", function() neocodeium.accept_word() end, { desc = "Accept NeoCodeium word" })
      vim.keymap.set("i", "<C-l>", function() neocodeium.accept_line() end, { desc = "Accept NeoCodeium current line" })

      -- Optional: Clear suggestions
      vim.keymap.set("i", "<C-c>", function() neocodeium.clear() end, { desc = "Clear NeoCodeium suggestion" })

      -- Optional: Cycle through suggestions (if multiple available)
      vim.keymap.set("i", "<C-i>", function() neocodeium.cycle_or_complete() end, { desc = "Cycle NeoCodeium suggestions" })
    end,

    -- Commands for managing NeoCodeium
    cmd = {
      "NeoCodeium",
    },

    -- Key mappings that work outside of insert mode
    keys = {
      -- { "<leader>nc", "<cmd>NeoCodeium toggle<cr>", desc = "Toggle NeoCodeium" },
      -- { "<leader>ns", "<cmd>NeoCodeium status<cr>", desc = "NeoCodeium status" },
      -- { "<leader>ne", "<cmd>NeoCodeium enable<cr>", desc = "Enable NeoCodeium" },
      -- { "<leader>nd", "<cmd>NeoCodeium disable<cr>", desc = "Disable NeoCodeium" },
      -- { "<leader>na", "<cmd>NeoCodeium auth<cr>", desc = "Authenticate NeoCodeium" },
    },
  },
}
