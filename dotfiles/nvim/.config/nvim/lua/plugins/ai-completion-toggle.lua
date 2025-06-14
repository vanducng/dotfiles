---@type LazySpec
return {
  -- AI Completion Toggle Commands
  {
    "AstroNvim/astrocore",
    opts = {
      commands = {
        -- Toggle between Copilot and NeoCodeium
        ToggleAICompletion = {
          function(opts)
            local completion_type = opts.args
            
            if completion_type == "copilot" then
              -- Enable Copilot, disable NeoCodeium
              vim.cmd("Lazy disable neocodeium")
              vim.cmd("Lazy enable copilot.vim")
              vim.cmd("Lazy reload copilot.vim")
              vim.notify("🤖 Enabled GitHub Copilot (NeoCodeium disabled)", vim.log.levels.INFO)
              
            elseif completion_type == "neocodeium" then
              -- Enable NeoCodeium, disable Copilot
              vim.cmd("Lazy disable copilot.vim")
              vim.cmd("Lazy enable neocodeium")
              vim.cmd("Lazy reload neocodeium")
              vim.notify("🔮 Enabled NeoCodeium (Copilot disabled)", vim.log.levels.INFO)
              
            else
              vim.notify("Usage: :ToggleAICompletion [copilot|neocodeium]", vim.log.levels.ERROR)
            end
          end,
          nargs = 1,
          complete = function()
            return { "copilot", "neocodeium" }
          end,
          desc = "Toggle between Copilot and NeoCodeium",
        },
        
        -- Disable both AI completions
        DisableAICompletion = {
          function()
            vim.cmd("Lazy disable copilot.vim")
            vim.cmd("Lazy disable neocodeium")
            vim.notify("🚫 Both AI completions disabled", vim.log.levels.INFO)
          end,
          desc = "Disable both Copilot and NeoCodeium",
        },
      },
      
      -- Add keymaps for quick toggle
      mappings = {
        n = {
          ["<Leader>ai"] = { desc = "󰚩 AI Completion" },
          ["<Leader>aic"] = { "<cmd>ToggleAICompletion copilot<cr>", desc = "Enable Copilot" },
          ["<Leader>ain"] = { "<cmd>ToggleAICompletion neocodeium<cr>", desc = "Enable NeoCodeium" },
          ["<Leader>aid"] = { "<cmd>DisableAICompletion<cr>", desc = "Disable AI completion" },
        },
      },
    },
  },
}