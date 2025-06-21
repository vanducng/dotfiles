---@type LazySpec
return {
  {
    "supermaven-inc/supermaven-nvim",
    enabled = true,
    event = "InsertEnter",
    config = function()
      require("supermaven-nvim").setup {
        keymaps = {
          accept_suggestion = "<C-l>",
          clear_suggestion = "<C-x>",
          accept_word = "<C-w>",
        },
        ignore_filetypes = {
          gitcommit = true,
          gitrebase = true,
          help = true,
        },
        color = {
          suggestion_color = "#808080",
          cterm = 244,
        },
        log_level = "info",
        disable_inline_completion = false,
        disable_keymaps = false,
      }

      -- Additional keymaps to match copilot functionality
      vim.keymap.set("i", "<C-y>", function()
        local suggestion = require "supermaven-nvim.completion_preview"
        if suggestion.has_suggestion() then suggestion.on_accept_suggestion() end
      end, { desc = "Accept Supermaven suggestion (alternative)" })

      vim.keymap.set(
        "i",
        "<C-]>",
        function() require("supermaven-nvim.completion_preview").on_accept_suggestion() end,
        { desc = "Accept Supermaven suggestion" }
      )

      vim.keymap.set("i", "<C-p>", function()
        -- Supermaven doesn't have previous suggestion, so we'll clear current one
        require("supermaven-nvim.completion_preview").on_dispose_inlay()
      end, { desc = "Clear Supermaven suggestion" })
    end,
    cmd = { "SupermavenStart", "SupermavenStop", "SupermavenRestart", "SupermavenToggle" },
    keys = {
      { "<leader>cp", "<cmd>SupermavenToggle<cr>", desc = "Toggle Supermaven" },
      { "<leader>cs", "<cmd>SupermavenShowLog<cr>", desc = "Supermaven status" },
      { "<leader>ce", "<cmd>SupermavenStart<cr>", desc = "Enable Supermaven" },
      { "<leader>cd", "<cmd>SupermavenStop<cr>", desc = "Disable Supermaven" },
    },
  },
}
