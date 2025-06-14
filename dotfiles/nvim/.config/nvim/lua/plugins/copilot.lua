---@type LazySpec
return {
  {
    "github/copilot.vim",
    enabled = true, -- Enabled (use :ToggleAICompletion neocodeium to switch)
    event = "InsertEnter",
    config = function()
      -- Validation: Check if NeoCodeium is enabled
      local neocodeium_enabled = false
      for _, plugin in pairs(require("lazy").plugins()) do
        if plugin.name == "neocodeium" and not plugin._.disabled then
          neocodeium_enabled = true
          break
        end
      end
      
      if neocodeium_enabled then
        vim.notify("⚠️  Both Copilot and NeoCodeium are enabled. Please disable one to avoid conflicts.", vim.log.levels.WARN)
      end
      
      -- Disable default Tab mapping to avoid conflicts
      vim.g.copilot_no_tab_map = true
      
      -- Set up unified keymaps (same as NeoCodeium for consistency)
      -- <Tab>: Accept suggestion or normal tab
      -- <C-j>: Accept full suggestion  
      -- <C-f>: Accept word
      -- <C-l>: Accept line
      -- <C-c>: Clear suggestion
      -- <C-i>: Cycle suggestions
      vim.keymap.set("i", "<Tab>", function()
        local copilot_suggestion = vim.fn["copilot#GetDisplayedSuggestion"]()
        if copilot_suggestion.text ~= "" then
          return vim.fn["copilot#Accept"]("")
        else
          -- Insert actual tab character or trigger completion
          local keys = vim.api.nvim_replace_termcodes("<Tab>", true, false, true)
          vim.api.nvim_feedkeys(keys, "n", false)
        end
      end, { desc = "Accept Copilot suggestion or normal Tab" })
      
      vim.keymap.set("i", "<C-j>", function()
        return vim.fn["copilot#Accept"]("")
      end, { desc = "Accept Copilot full suggestion" })
      
      vim.keymap.set("i", "<C-f>", function()
        return vim.fn["copilot#AcceptWord"]("")
      end, { desc = "Accept Copilot word" })
      
      vim.keymap.set("i", "<C-l>", function()
        return vim.fn["copilot#AcceptLine"]("")
      end, { desc = "Accept Copilot current line" })

      -- Clear suggestions
      vim.keymap.set("i", "<C-c>", function()
        vim.fn["copilot#Dismiss"]()
      end, { desc = "Clear Copilot suggestion" })

      -- Cycle through suggestions
      vim.keymap.set("i", "<C-i>", function()
        vim.fn["copilot#Next"]()
      end, { desc = "Next Copilot suggestion" })
      
      -- Disable Copilot for certain filetypes (same as NeoCodeium)
      vim.g.copilot_filetypes = {
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
      }
    end,
    cmd = "Copilot",
    keys = {
      { "<leader>cp", "<cmd>Copilot panel<cr>", desc = "Open Copilot panel" },
      { "<leader>cs", "<cmd>Copilot status<cr>", desc = "Copilot status" },
      { "<leader>ce", "<cmd>Copilot enable<cr>", desc = "Enable Copilot" },
      { "<leader>cd", "<cmd>Copilot disable<cr>", desc = "Disable Copilot" },
    },
  },
}