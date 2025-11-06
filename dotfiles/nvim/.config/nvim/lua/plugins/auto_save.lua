local excluded_filetypes = {
  -- this one is especially useful if you use neovim as a commit message editor
  "gitcommit",
  -- most of these are usually set to non-modifiable, which prevents autosaving
  -- by default, but it doesn't hurt to be extra safe.
  "NvimTree",
  "Outline",
  "fzf",
  "alpha",
  "dashboard",
  "lazygit",
  "neo-tree",
  "oil",
  "prompt",
  "toggleterm",
  "dbee", -- Exclude dbee popup windows
}

local excluded_filenames = {
  "do-not-autosave-me.lua",
  "persistent.json",
}

local function save_condition(buf)
  if
    vim.tbl_contains(excluded_filetypes, vim.fn.getbufvar(buf, "&filetype"))
    or vim.tbl_contains(excluded_filenames, vim.fn.expand "%:t")
  then
    return false
  end
  return true
end

return {
  {
    "okuuva/auto-save.nvim",
    cmd = "ASToggle",
    event = { "InsertLeave", "TextChanged" },
    opts = {
      enabled = true,
      -- Updated configuration based on latest plugin version
      trigger_events = {
        immediate_save = { "BufLeave", "FocusLost" },
        defer_save = { "InsertLeave", "TextChanged" },
        cancel_deferred_save = { "InsertEnter" },
      },
      condition = save_condition,
      write_all_buffers = false,
      noautocmd = false,
      lockmarks = false,
      debounce_delay = 1000,
      debug = false,
    },
    config = function(_, opts)
      -- Disable confirm for overwriting files
      vim.o.confirm = false
      -- Set write behavior to not prompt
      vim.o.writeany = true

      require("auto-save").setup(opts)
    end,
  },
}
