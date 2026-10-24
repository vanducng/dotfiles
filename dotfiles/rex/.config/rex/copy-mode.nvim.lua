-- Neovim init for Rex copy mode (C-x [), loaded with nvim -u. It holds only what
-- reading, searching and yanking need: the full config takes ~300ms to start.
vim.opt.clipboard = "unnamedplus"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
-- Blank instead of ~ below short text, and no status line naming the temp file.
vim.opt.fillchars = { eob = " " }
vim.opt.laststatus = 0
vim.opt.shortmess:append("F")
vim.keymap.set("n", "q", "<cmd>qa!<cr>")

local note = vim.env.REX_COPY_NOTE or ""
if note ~= "" then vim.opt.winbar = note end
