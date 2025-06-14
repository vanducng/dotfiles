---@type LazySpec
return {
  {
    "github/copilot.vim",
    enabled = true,
    event = "InsertEnter",
    config = function()
      vim.g.copilot_no_tab_map = true
      
      vim.keymap.set("i", "<C-;>", 'copilot#Accept("\\<CR>")', { 
        expr = true, 
        replace_keycodes = false,
        desc = "Accept Copilot suggestion" 
      })
      
      vim.keymap.set("i", "<C-l>", '<Plug>(copilot-accept-line)', { desc = "Accept Copilot line" })
      vim.keymap.set("i", "<C-]>", '<Plug>(copilot-next)', { desc = "Next Copilot suggestion" })
      vim.keymap.set("i", "<C-p>", '<Plug>(copilot-previous)', { desc = "Previous Copilot suggestion" })
      vim.keymap.set("i", "<C-x>", '<Plug>(copilot-dismiss)', { desc = "Dismiss Copilot suggestion" })
      
      vim.keymap.set("i", "<C-y>", 'copilot#Accept("\\<CR>")', { 
        expr = true, 
        replace_keycodes = false,
        desc = "Accept Copilot suggestion (alternative)" 
      })
      
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