---@type LazySpec
return {
  {
    "github/copilot.vim",
    enabled = false, -- Temporarily disabled in favor of NeoCodeium
    event = "InsertEnter",
    config = function()
      -- Disable default Tab mapping to avoid conflicts with other plugins
      vim.g.copilot_no_tab_map = true
      
      -- Set up custom keymaps for Copilot
      vim.keymap.set('i', '<C-J>', 'copilot#Accept("\\<CR>")', {
        expr = true,
        replace_keycodes = false
      })
      
      -- Optional: Additional keymaps for navigation
      vim.keymap.set('i', '<C-]>', '<Plug>(copilot-next)')
      vim.keymap.set('i', '<C-[>', '<Plug>(copilot-previous)')
      
      -- Optional: Disable Copilot for certain filetypes
      vim.g.copilot_filetypes = {
        ["*"] = true,
        ["xml"] = false,
        ["markdown"] = true,
        ["yaml"] = true,
        ["json"] = true,
        ["gitcommit"] = false,
        ["gitrebase"] = false,
        ["help"] = false,
        ["hgcommit"] = false,
        ["svn"] = false,
        ["cvs"] = false,
        ["."] = false,
      }
      
      -- Optional: Configure Copilot to work with specific Node.js version
      -- vim.g.copilot_node_command = "~/.nvm/versions/node/v18.17.0/bin/node"
      
      -- Optional: Set workspace folders
      -- vim.g.copilot_workspace_folders = { vim.fn.getcwd() }
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