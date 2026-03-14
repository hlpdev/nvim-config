local o = vim.opt
o.number = true
o.relativenumber = true
o.tabstop = 2
o.shiftwidth = 2
o.expandtab = true
o.smartindent = true
o.wrap = false
o.termguicolors = true
o.signcolumn = "yes"
o.updatetime = 250
o.scrolloff = 8
o.splitright = true
o.splitbelow = true

vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { desc = "Format file" })
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = '[E]xpand diagnostic message' })

vim.keymap.set("n", "<leader>q", function()
  if vim.bo.modifiable and vim.bo.buftype ~= 'terminal' then
    vim.cmd("w")
  end

  if vim.bo.buftype == 'terminal' then
    vim.cmd("bd!")
  else
    vim.cmd("bd")
  end
end)

vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("n", "<leader>t", ":vs | term<CR>", { desc = "Open terminal" })
