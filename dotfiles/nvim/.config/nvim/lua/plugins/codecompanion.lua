---@type LazySpec
return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    cmd = {
      "CodeCompanion",
      "CodeCompanionChat",
      "CodeCompanionActions",
    },
    keys = {
      -- Chat commands
      { "<leader>ac", "<cmd>CodeCompanionChat<cr>", desc = "Open CodeCompanion Chat" },
      { "<leader>at", "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle CodeCompanion Chat" },
      { "<leader>aC", "<cmd>CodeCompanionChat Add<cr>", desc = "Add to CodeCompanion Chat" },
      
      -- Actions (inline assistance)
      { "<leader>aa", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "CodeCompanion Actions" },
      
      -- Quick actions for common tasks
      { "<leader>ae", "<cmd>CodeCompanion explain<cr>", mode = { "n", "v" }, desc = "Explain Code" },
      { "<leader>af", "<cmd>CodeCompanion fix<cr>", mode = { "n", "v" }, desc = "Fix Code" },
      { "<leader>ar", "<cmd>CodeCompanion refactor<cr>", mode = { "n", "v" }, desc = "Refactor Code" },
      { "<leader>aT", "<cmd>CodeCompanion tests<cr>", mode = { "n", "v" }, desc = "Generate Tests" },
      { "<leader>ad", "<cmd>CodeCompanion doc<cr>", mode = { "n", "v" }, desc = "Document Code" },
      { "<leader>agc", "<cmd>CodeCompanion commit<cr>", mode = "n", desc = "Generate Commit Message" },
      
      -- Visual mode specific
      { "<leader>av", ":<C-u>'<,'>CodeCompanion<cr>", mode = "v", desc = "Send selection to CodeCompanion" },
    },
    opts = {
      -- Adapter configuration - use the default Gemini adapter
      adapters = {
        gemini = function()
          return require("codecompanion.adapters").extend("gemini", {
            env = {
              api_key = function()
                local key = os.getenv("GEMINI_API_KEY")
                if not key or key == "" then
                  vim.notify("GEMINI_API_KEY environment variable not set", vim.log.levels.ERROR)
                end
                return key
              end,
            },
            schema = {
              model = {
                default = vim.g.codecompanion_gemini_model or "gemini-2.5-flash-preview-05-20",
                -- Available models:
                -- "gemini-2.5-pro-preview-06-05"
                -- "gemini-2.5-pro-preview-05-06"
                -- "gemini-2.5-flash-preview-05-20"
                -- "gemini-2.0-flash"
                -- "gemini-2.0-flash-lite"
                -- "gemini-1.5-pro"
                -- "gemini-1.5-flash"
              },
            },
          })
        end,
      },
      
      -- Strategies configuration
      strategies = {
        chat = {
          adapter = "gemini",
          keymaps = {
            -- Chat specific keymaps (in chat buffer)
            options = {
              modes = { n = "?" },
            },
            completion = {
              modes = { i = "<C-_>" },
            },
            send = {
              modes = { n = "<CR>", i = "<C-s>" },
            },
            regenerate = {
              modes = { n = "gr" },
            },
            close = {
              modes = { n = "<C-c>", i = "<C-c>" },
            },
            stop = {
              modes = { n = "q" },
            },
            clear = {
              modes = { n = "gx" },
            },
            change_adapter = {
              modes = { n = "ga" },
            },
          },
        },
        inline = {
          adapter = "gemini",
        },
        cmd = {
          adapter = "gemini",
        },
      },
      
      -- Display configuration
      display = {
        action_palette = {
          width = 95,
          height = 10,
          prompt = "Select an action: ",
          provider = "default", -- Options: "default", "telescope"
        },
        chat = {
          window = {
            layout = "vertical", -- Options: "vertical", "horizontal", "float"
            width = 0.45, -- 45% of screen width
            height = 0.65, -- 65% of screen height
            relative = "editor",
            border = "rounded",
            position = "right", -- Options: "left", "right", "top", "bottom", "center"
          },
          intro_message = "Welcome to CodeCompanion! I'm using Gemini to help you with your code. How can I assist you today?",
          show_settings = false, -- Hide settings in chat window header
        },
      },
      
      -- Logging configuration
      log_level = "INFO", -- Options: "TRACE", "DEBUG", "INFO", "WARN", "ERROR"
      
      -- Default prompts configuration
      default_prompts = {
        -- You can customize these prompts as needed
        ["explain"] = {
          strategy = "chat",
          description = "Explain the selected code",
          opts = {
            index = 1,
            is_default = true,
            is_slash_cmd = false,
            short_name = "explain",
          },
          prompts = {
            {
              role = "system",
              content = [[You are a senior software engineer. When explaining code:
1. Start with a high-level overview
2. Break down the logic step by step
3. Highlight any important patterns or idioms
4. Point out potential issues or improvements
5. Use clear, concise language]],
            },
            {
              role = "user",
              content = function(context)
                return "Please explain this code:\n\n```" .. context.filetype .. "\n" .. context.selection .. "\n```"
              end,
            },
          },
        },
        ["commit"] = {
          strategy = "inline",
          description = "Generate commit message from git diff",
          opts = {
            index = 2,
            is_default = true,
            is_slash_cmd = false,
            short_name = "commit",
          },
          prompts = {
            {
              role = "system",
              content = [[You are an expert at writing clear, concise git commit messages. Follow these guidelines:
1. Use conventional commit format: type(scope): description
2. Types: feat, fix, docs, style, refactor, test, chore, perf, ci, build
3. Keep the first line under 50 characters
4. Use imperative mood (e.g., "add", "fix", "update")
5. Don't end with a period
6. If needed, add a longer description after a blank line
7. Focus on WHY the change was made, not just WHAT changed]],
            },
            {
              role = "user",
              content = function()
                -- Get git diff for staged changes
                local handle = io.popen("git diff --cached 2>/dev/null")
                if not handle then
                  return "Error: Unable to execute git command. Make sure you're in a git repository."
                end
                local staged_diff = handle:read("*a") or ""
                local success = handle:close()
                
                -- If no staged changes, get working directory changes
                if staged_diff == "" then
                  handle = io.popen("git diff 2>/dev/null")
                  if not handle then
                    return "Error: Unable to execute git command."
                  end
                  staged_diff = handle:read("*a") or ""
                  handle:close()
                end
                
                if not success then
                  return "Error: Git command failed. Make sure you're in a git repository."
                end
                
                if staged_diff == "" then
                  return "No git changes found. Please stage some changes first with 'git add' or make some changes to your files."
                end
                
                return "Based on the following git diff, generate an appropriate commit message:\n\n```diff\n" .. staged_diff .. "\n```"
              end,
            },
          },
        },
      },
      
      -- Enable inline completions
      enable_inline_completion = true,
      
      -- Use Treesitter for better code understanding
      use_treesitter = true,
    },
    config = function(_, opts)
      require("codecompanion").setup(opts)
      
      -- Optional: Set up autocommands for CodeCompanion
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "codecompanion",
        callback = function()
          vim.opt_local.wrap = true
          vim.opt_local.linebreak = true
          vim.opt_local.spell = false
        end,
      })
      
      -- Create a command to quickly switch between Gemini models
      vim.api.nvim_create_user_command("CodeCompanionModel", function(opts)
        local model = opts.args
        local valid_models = {
          "gemini-2.5-pro-preview-06-05",
          "gemini-2.5-pro-preview-05-06",
          "gemini-2.5-flash-preview-05-20",
          "gemini-2.0-flash",
          "gemini-2.0-flash-lite",
          "gemini-1.5-pro",
          "gemini-1.5-flash",
        }
        
        if vim.tbl_contains(valid_models, model) then
          -- For dynamic model switching, we need to update the adapter
          vim.notify("CodeCompanion: Model switching to " .. model .. ". Please restart the chat for the change to take effect.", vim.log.levels.INFO)
          -- Store the selected model in a global variable that can be used when creating new chats
          vim.g.codecompanion_gemini_model = model
        else
          vim.notify("Invalid model. Valid models: " .. table.concat(valid_models, ", "), vim.log.levels.ERROR)
        end
      end, {
        nargs = 1,
        complete = function()
          return {
            "gemini-2.5-pro-preview-06-05",
            "gemini-2.5-pro-preview-05-06",
            "gemini-2.5-flash-preview-05-20",
            "gemini-2.0-flash",
            "gemini-2.0-flash-lite",
            "gemini-1.5-pro",
            "gemini-1.5-flash",
          }
        end,
        desc = "Switch CodeCompanion Gemini model",
      })
    end,
  },
}