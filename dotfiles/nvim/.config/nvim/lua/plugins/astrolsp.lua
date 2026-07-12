-- AstroLSP allows you to customize the features in AstroNvim's LSP configuration engine
-- Configuration documentation can be found with `:h astrolsp`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

local function open_workflow_function_definition()
  if vim.bo.filetype ~= "php" then return false end

  local function_name = vim.fn.expand "<cword>"
  local composer_file = vim.fs.find("composer.json", { path = vim.api.nvim_buf_get_name(0), upward = true })[1]

  if not composer_file then return false end

  for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
    local imported_function = line:match "^%s*use%s+function%s+Workflow\\V2\\([%w_]+)%s*;"

    if imported_function == function_name then
      vim.system(
        { "composer", "show", "durable-workflow/workflow", "--path" },
        { text = true, cwd = vim.fs.dirname(composer_file) },
        function(package_result)
          local package_path = package_result.code == 0
              and package_result.stdout
              and vim.trim(package_result.stdout):match "%s(.+)$"
            or nil
          local functions_file = package_path and package_path .. "/src/V2/functions.php" or nil

          vim.schedule(function()
            if not functions_file or not vim.uv.fs_stat(functions_file) then
              vim.lsp.buf.definition()

              return
            end

            vim.cmd.edit(vim.fn.fnameescape(functions_file))

            if vim.fn.search("\\<function\\s\\+" .. function_name .. "\\>") == 0 then
              vim.notify("Workflow V2 function not found: " .. function_name, vim.log.levels.WARN)
            end
          end)
        end
      )

      return true
    end
  end

  return false
end

---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    -- Configuration table of features provided by AstroLSP
    features = {
      codelens = true, -- enable/disable codelens refresh on start
      inlay_hints = false, -- enable/disable inlay hints on start
      semantic_tokens = true, -- enable/disable semantic token highlighting
    },
    -- customize lsp formatting options
    formatting = {
      -- control auto formatting on save
      format_on_save = {
        enabled = false, -- disable format on save globally
        allow_filetypes = { -- enable format on save for specified filetypes only
          -- "go",
        },
        ignore_filetypes = { -- disable format on save for specified filetypes
          -- "python",
        },
      },
      disabled = { -- disable formatting capabilities for the listed language servers
        -- disable lua_ls formatting capability if you want to use StyLua to format your lua code
        -- "lua_ls",
      },
      timeout_ms = 1000, -- default format timeout
      -- filter = function(client) -- fully override the default formatting function
      --   return true
      -- end
    },
    -- enable servers that you already have installed without mason
    servers = {
      -- "pyright"
    },
    -- customize language server configuration options passed to `lspconfig`
    ---@diagnostic disable: missing-fields
    config = {
      -- clangd = { capabilities = { offsetEncoding = "utf-8" } },
      basedpyright = {
        settings = {
          basedpyright = {
            analysis = {
              -- Only use basedpyright for type information, not diagnostics
              typeCheckingMode = "off",
              diagnosticMode = "openFilesOnly",
              useLibraryCodeForTypes = true,
              autoImportCompletions = true,
              diagnosticSeverityOverrides = {
                -- Disable all diagnostics
                reportGeneralTypeIssues = "none",
                reportOptionalSubscript = "none",
                reportOptionalMemberAccess = "none",
                reportOptionalCall = "none",
                reportOptionalIterable = "none",
                reportOptionalContextManager = "none",
                reportOptionalOperand = "none",
              },
            },
          },
        },
      },
      ruff = {
        capabilities = {
          hoverProvider = false, -- Disable hover to avoid conflicts with basedpyright
        },
        init_options = {
          settings = {
            -- Ruff server settings
            configuration = vim.fn.expand "~/.config/ruff/pyproject.toml",
            lineLength = 120,
            lint = {
              args = { "--ignore=E501,E402 --select I" }, -- Ignore line length and module import not at top
            },
            format = {
              args = {},
            },
            check = {
              args = { "--ignore=E501,E402 --select I" }, -- Ignore line length and module import not at top
            },
          },
        },
        on_attach = function(client, bufnr)
          -- Ensure ruff is used for formatting
          client.server_capabilities.documentFormattingProvider = true
        end,
      },
    },
    -- customize how language servers are attached (boolean false disables setup)
    handlers = {
      pyright = false, -- use basedpyright + ruff instead
      htmlls = false, -- disable HTML language server
      ts_ls = false, -- typescript pack uses vtsls; disable ts_ls to avoid conflicts
      marksman = false, -- disable markdown language server
      markdown_oxide = false, -- disable alternative markdown language server
    },
    -- Configure buffer local auto commands to add when attaching a language server
    autocmds = {
      -- first key is the `augroup` to add the auto commands to (:h augroup)
      lsp_codelens_refresh = {
        -- Optional condition to create/delete auto command group
        -- can either be a string of a client capability or a function of `fun(client, bufnr): boolean`
        -- condition will be resolved for each client on each execution and if it ever fails for all clients,
        -- the auto commands will be deleted for that buffer
        cond = "textDocument/codeLens",
        -- cond = function(client, bufnr) return client.name == "lua_ls" end,
        -- list of auto commands to set
        {
          -- events to trigger
          event = { "InsertLeave", "BufEnter" },
          -- the rest of the autocmd options (:h nvim_create_autocmd)
          desc = "Refresh codelens (buffer)",
          callback = function(args)
            if require("astrolsp").config.features.codelens then vim.lsp.codelens.refresh { bufnr = args.buf } end
          end,
        },
      },
    },
    -- mappings to be set up on attaching of a language server
    mappings = {
      n = {
        -- a `cond` key can provided as the string of a server capability to be required to attach, or a function with `client` and `bufnr` parameters from the `on_attach` that returns a boolean
        gd = {
          function()
            if not open_workflow_function_definition() then vim.lsp.buf.definition() end
          end,
          desc = "Show the definition of current symbol",
          cond = "textDocument/definition",
        },
        gD = {
          function() vim.lsp.buf.declaration() end,
          desc = "Declaration of current symbol",
          cond = "textDocument/declaration",
        },
        ["<Leader>uY"] = {
          function() require("astrolsp.toggles").buffer_semantic_tokens() end,
          desc = "Toggle LSP semantic highlight (buffer)",
          cond = function(client, bufnr)
            return client:supports_method("textDocument/semanticTokens/full", bufnr) and vim.lsp.semantic_tokens ~= nil
          end,
        },
      },
    },
    -- A custom `on_attach` function to be run after the default `on_attach` function
    -- takes two parameters `client` and `bufnr`  (`:h lspconfig-setup`)
    on_attach = function(client, bufnr)
      -- this would disable semanticTokensProvider for all clients
      -- client.server_capabilities.semanticTokensProvider = nil
    end,
  },
}
