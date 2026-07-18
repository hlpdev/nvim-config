-- Keymaps are automatically loaded on VeryLazy (after plugin keys),
-- so mappings here win over LazyVim/plugin defaults.

local map = vim.keymap.set

-- LazyVim hangs sub-mappings off <leader>s (search pickers) and <leader>d
-- (profiler scratch), which turns our single-key <leader>s / <leader>d into
-- which-key prefixes that only fire after a timeout. Drop those sub-mappings
-- so our keys fire instantly. (Grep is still on <leader>/ and <leader>fg.)
-- This file loads on VeryLazy, after LazyVim's defaults, so they exist here.
for _, m in ipairs(vim.api.nvim_get_keymap("n")) do
  if m.lhs:match("^ s.") or m.lhs:match("^ d.") then
    pcall(vim.keymap.del, "n", m.lhs)
  end
end

-- File explorer: LazyVim's default <leader>e (snacks explorer) is kept as-is.

-- Find the currently open snacks explorer picker, if any.
local function get_explorer()
  local ok, Snacks = pcall(require, "snacks")
  if not ok then return nil, nil end
  return Snacks.picker.get({ source = "explorer" })[1], Snacks
end

-- LSP
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
map("n", "<leader>f", vim.lsp.buf.format, { desc = "Format file" })
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Expand diagnostic message" })

-- <leader>fg was live-grep in the old config; LazyVim rebinds it to
-- git-files. Restore live-grep (grep also lives on <leader>/).
map("n", "<leader>fg", function() require("snacks").picker.grep() end, { desc = "Live Grep" })

-- Live colorscheme picker
map("n", "<leader>uc", function()
  vim.ui.select(vim.fn.getcompletion("", "color"), {
    prompt = "Colorscheme",
  }, function(choice)
    if choice then vim.cmd.colorscheme(choice) end
  end)
end, { desc = "Pick colorscheme" })

-- Terminal
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
map("n", "<leader>t", function()
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
    -- Only tree or empty buffer → full terminal
    vim.cmd("tabnew | terminal")
  end
  vim.cmd("startinsert")
end, { desc = "Open terminal" })

-- Save & close current buffer, returning to the tree when it was the last file
map("n", "<leader>q", function()
  local buf = vim.api.nvim_get_current_buf()
  local bt = vim.bo[buf].buftype
  local ft = vim.bo[buf].filetype
  local name = vim.api.nvim_buf_get_name(buf)

  -- In the explorer window: just close the explorer (don't try to :bd it).
  if ft:find("^snacks_picker") then
    local explorer = get_explorer()
    if explorer then explorer:close() end
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

  -- Ensure the explorer is shown and focused so we land on it.
  if real <= 1 then
    local explorer, Snacks = get_explorer()
    if explorer then
      explorer:focus()
    elseif Snacks then
      pcall(Snacks.explorer.open or Snacks.explorer)
    end
  end
end, { desc = "Save & close buffer (return to explorer)" })
