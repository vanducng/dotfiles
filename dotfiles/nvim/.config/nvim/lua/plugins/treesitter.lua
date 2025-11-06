---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  opts = {
    ensure_installed = {
      "lua",
      "vim",
      "python",
      "yaml",
      "json",
      "markdown",
      "markdown_inline",
      "bash",
      "sql",
      "typescript",
      "tsx",
      "javascript",
      "jsdoc",
      "c",
      "query",
      "vimdoc",
      "luap",
      "html",
      "css",
      "jsonc",
    },
    ignore_install = { "csv", "gitignore", "dockerfile", "hcl", "requirements", "scss", "styled" }, -- Prevent x86_64 parsers
    auto_install = false, -- Disable auto-install to prevent x86_64 compilation
    highlight = {
      enable = true,
      disable = function(lang, buf)
        -- Disable for CSV files
        if lang == "csv" then
          return true
        end
        -- Disable for large files
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
          return true
        end
        return false
      end,
    },
  },
}
