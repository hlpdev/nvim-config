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
o.clipboard = "unnamedplus"

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
--vim.keymap.set("n", "<leader>t", ":vs | term<CR>", { desc = "Open terminal" })
vim.keymap.set("n", "<leader>t", function()
  -- Check if there is any real file open (non-empty name and normal buftype)
  local real_file_open = false
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    local buftype = vim.bo[buf].buftype
    local name = vim.api.nvim_buf_get_name(buf)

    if buftype == "" and name ~= "" then
      real_file_open = true
      break
    end
  end

  if real_file_open then
    -- Editing a real file → split terminal
    vim.cmd("vsplit | terminal")
  else
    -- Only netrw or empty buffer → full terminal
    vim.cmd("tabnew | terminal")
  end
  vim.cmd("startinsert")
end)

