---@type LazySpec
return {
  -- use mason-tool-installer for automatically installing Mason packages
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    -- overrides `require("mason-tool-installer").setup(...)`
    opts = {
      -- Make sure to use the names found in `:Mason`
      -- skip tree-sitter-cli: mason's linux-x64 binary needs GLIBC 2.39
      ensure_installed = {
        -- install language servers
        "lua-language-server",
        "ruff",
        "basedpyright",
        "phpactor",

        -- install formatters
        "stylua",
        "prettier", -- markdown, yaml, json, html, css formatter

        -- install debuggers
        "debugpy",
      },
    },
  },
}
