local uv = vim.uv or vim.loop
local mason_root = vim.fn.stdpath "data" .. "/mason"
local mason_ts = mason_root .. "/bin/tree-sitter"
if uv.fs_stat(mason_ts) then
  local out = vim.fn.system { mason_ts, "--version" }
  if vim.v.shell_error ~= 0 and tostring(out):find("GLIBC", 1, true) then
    vim.notify("Removing mason tree-sitter-cli (incompatible glibc)", vim.log.levels.WARN)
    vim.fn.delete(mason_ts)
    vim.fn.delete(mason_root .. "/packages/tree-sitter-cli", "rf")
  end
end

require("lazy").setup({
  {
    "AstroNvim/AstroNvim",
    version = "^6", -- Remove version tracking to elect for nightly AstroNvim
    import = "astronvim.plugins",
    opts = { -- AstroNvim options must be set here with the `import` key
      mapleader = " ", -- This ensures the leader key must be configured before Lazy is set up
      maplocalleader = ",", -- This ensures the localleader key must be configured before Lazy is set up
      icons_enabled = true, -- Set to false to disable icons (if no Nerd Font is available)
      pin_plugins = nil, -- Default will pin plugins when tracking `version` of AstroNvim, set to true/false to override
      update_notifications = true, -- Enable/disable notification about running `:Lazy update` twice to update pinned plugins
    },
  },
  { import = "community" },
  { import = "plugins" },
} --[[@as LazySpec]], {
  -- Configure any other `lazy.nvim` configuration options here
  install = { colorscheme = { "astrotheme", "habamax" } },
  ui = { backdrop = 100 },
  performance = {
    rtp = {
      -- disable some rtp plugins, add more to your liking
      disabled_plugins = {
        "gzip",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "zipPlugin",
      },
    },
  },
} --[[@as LazyConfig]])
