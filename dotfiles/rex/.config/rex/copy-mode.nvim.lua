vim.opt.clipboard = "unnamedplus"
vim.bo.modifiable = false
vim.keymap.set("n", "q", "<cmd>qa!<cr>")
vim.keymap.set("n", "<C-c>", "<cmd>qa!<cr>")

local note = vim.env.REX_COPY_NOTE or ""
if note ~= "" then vim.opt.winbar = note end
