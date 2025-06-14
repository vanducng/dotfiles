---@type LazySpec
return {
  {
    "github/copilot.vim",
    enabled = true,
    event = "InsertEnter",
    config = function()
      -- Disable default Tab mapping to avoid conflicts
      vim.g.copilot_no_tab_map = true
      
      -- Ergonomic keymaps: left hand on Ctrl, right hand on target keys
      -- Tab: Accept suggestion or normal tab behavior
      vim.keymap.set("i", "<Tab>", function()
        local copilot_suggestion = vim.fn["copilot#GetDisplayedSuggestion"]()
        if copilot_suggestion.text ~= "" then
          return vim.fn["copilot#Accept"]("")
        else
          -- Insert actual tab character
          local keys = vim.api.nvim_replace_termcodes("<Tab>", true, false, true)
          vim.api.nvim_feedkeys(keys, "n", false)
        end
      end, { desc = "Accept Copilot suggestion or normal Tab" })
      
      -- Ctrl + ; (semicolon) - Accept full suggestion (easy right hand reach)
      vim.keymap.set("i", "<C-;>", 'copilot#Accept("\\<CR>")', { 
        expr = true, 
        replace_keycodes = false,
        desc = "Accept Copilot suggestion" 
      })
      
      -- Ctrl + l - Accept line (revised keymap)
      vim.keymap.set("i", "<C-l>", '<Plug>(copilot-accept-line)', { desc = "Accept Copilot line" })
      
      -- Ctrl + i - Next suggestion (as requested)
      vim.keymap.set("i", "<C-i>", '<Plug>(copilot-next)', { desc = "Next Copilot suggestion" })
      
      -- Ctrl + u - Previous suggestion (avoids conflicts)
      vim.keymap.set("i", "<C-u>", '<Plug>(copilot-previous)', { desc = "Previous Copilot suggestion" })
      
      -- Ctrl + x - Dismiss suggestion (easy reach, commonly used for dismiss)
      vim.keymap.set("i", "<C-x>", '<Plug>(copilot-dismiss)', { desc = "Dismiss Copilot suggestion" })
      
      -- Alternative keymaps for terminals that don't support all combinations
      vim.keymap.set("i", "<C-y>", 'copilot#Accept("\\<CR>")', { 
        expr = true, 
        replace_keycodes = false,
        desc = "Accept Copilot suggestion (alternative)" 
      })
      
      -- Configure filetypes
      vim.g.copilot_filetypes = {
        ["*"] = true,
        ["markdown"] = true,
        ["yaml"] = true,
        ["json"] = true,
        ["gitcommit"] = false,
        ["gitrebase"] = false,
        ["help"] = false,
        ["."] = false,
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