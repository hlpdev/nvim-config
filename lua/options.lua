local o = vim.opt
o.number = true
o.relativenumber = true
o.tabstop = 4
o.shiftwidth = 4
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
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })

vim.keymap.set("n", "<leader>q", function()
  local buf = vim.api.nvim_get_current_buf()
  local bt = vim.bo[buf].buftype
  local ft = vim.bo[buf].filetype
  local name = vim.api.nvim_buf_get_name(buf)

  -- In the neo-tree window: just close the tree (don't try to :bd it).
  if ft == "neo-tree" then
    pcall(vim.cmd, "Neotree close")
    return
  end

  -- Terminal: force-kill it.
  if bt == "terminal" then
    pcall(vim.cmd, "bd!")
    return
  end

  -- Blank, unmodified [No Name] scratch buffer: nothing worth saving.
  -- If it's the only window, leave it; otherwise close the window.
  if name == "" and bt == "" and not vim.bo[buf].modified then
    if #vim.api.nvim_tabpage_list_wins(0) > 1 then
      pcall(vim.cmd, "close")
    end
    return
  end

  -- Real, modifiable file: save it first.
  if vim.bo[buf].modifiable and bt == "" then
    pcall(vim.cmd, "w")
  end

  -- Count real file buffers (listed, named). If this is the last one,
  -- delete it but keep nvim open on the tree rather than quitting/blanking.
  local real = 0
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(b)
      and vim.bo[b].buflisted
      and vim.api.nvim_buf_get_name(b) ~= ""
      and vim.bo[b].buftype == ""
    then
      real = real + 1
    end
  end

  -- Remember the window the file is in, then delete the buffer.
  local file_win = vim.api.nvim_get_current_win()
  pcall(vim.cmd, "bd")

  -- After bd, that window (if it still exists) is showing a blank scratch
  -- buffer. If there's more than one window, close that window so we don't
  -- leave a blank panel next to the tree. Guard so we never close the
  -- last remaining window.
  if vim.api.nvim_win_is_valid(file_win)
    and #vim.api.nvim_tabpage_list_wins(0) > 1
  then
    local b = vim.api.nvim_win_get_buf(file_win)
    local is_blank = vim.api.nvim_buf_get_name(b) == ""
      and vim.bo[b].buftype == ""
      and not vim.bo[b].modified
    if is_blank then
      pcall(vim.api.nvim_win_close, file_win, false)
    end
  end

  -- Ensure the tree is shown and focused so we land on the explorer.
  if real <= 1 and vim.fn.exists(":Neotree") == 1 then
    pcall(vim.cmd, "Neotree show left")
    pcall(vim.cmd, "Neotree focus")
  end
end, { desc = "Save & close buffer (return to tree)" })

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

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.c", "*.cpp", "*.h", "*.hpp" },
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})
