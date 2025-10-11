---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  build = function()
    -- Force ARM64 architecture for treesitter compilation
    vim.fn.system("arch -arm64 " .. vim.fn.stdpath("data") .. "/lazy/nvim-treesitter/scripts/install.sh")
  end,
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
    },
    auto_install = true,
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
