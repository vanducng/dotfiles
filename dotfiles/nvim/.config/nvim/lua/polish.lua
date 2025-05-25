vim.keymap.set("n", "<leader>yp", function()
  local relative_filepath = vim.fn.expand "%:."
  vim.fn.setreg("+", relative_filepath)
end, { noremap = true, silent = true, desc = "Copy relative file path to clipboard" })
vim.keymap.set("n", "<leader>yP", function()
  local absolute_filepath = vim.fn.expand "%:p"
  vim.fn.setreg("+", absolute_filepath)
end, { noremap = true, silent = true, desc = "Copy absolute file path to clipboard" })
