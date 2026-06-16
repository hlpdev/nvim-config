local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git", "clone", "--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", lazypath,
	})
end

vim.opt.rtp:prepend(lazypath)

require("options")
require("lazy").setup("plugins")

-- On startup with no file args, open the file explorer as a left sidebar
-- (and remove the empty [No Name] buffer so the tree isn't sitting next
-- to a blank window).
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- only when nvim was launched with no file/dir arguments and no piped input
    if vim.fn.argc() ~= 0 or vim.g.std_in then return end

    vim.schedule(function()
      -- neo-tree may still be loading; bail quietly if its command isn't ready
      if vim.fn.exists(":Neotree") == 0 then return end

      -- open the tree on the left and focus it
      pcall(vim.cmd, "Neotree show left")
      pcall(vim.cmd, "Neotree focus")

      -- close every OTHER window (the blank [No Name] sitting to the right),
      -- so only the tree remains on first launch
      local tree_win = vim.api.nvim_get_current_win()
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if win ~= tree_win and vim.api.nvim_win_is_valid(win) then
          pcall(vim.api.nvim_win_close, win, false)
        end
      end

      -- wipe any now-orphaned empty [No Name] buffers
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf)
          and vim.api.nvim_buf_get_name(buf) == ""
          and vim.bo[buf].buftype == ""
          and not vim.bo[buf].modified
          and vim.fn.bufwinid(buf) == -1
        then
          pcall(vim.api.nvim_buf_delete, buf, { force = true })
        end
      end
    end)
  end,
})

-- mark stdin so the autocmd above can skip when input is piped in
vim.api.nvim_create_autocmd("StdinReadPre", {
  callback = function() vim.g.std_in = true end,
})
