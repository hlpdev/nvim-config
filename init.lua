require("config.lazy")

-- On startup with no file args, open the snacks explorer as a left sidebar
-- (next to the LazyVim dashboard). Lives here (not config/autocmds.lua)
-- because LazyVim loads autocmds on VeryLazy, after VimEnter has fired.
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- only when nvim was launched with no file/dir arguments and no piped input
    if vim.fn.argc() ~= 0 or vim.g.std_in then return end

    vim.schedule(function()
      local ok, Snacks = pcall(require, "snacks")
      if not ok then return end
      -- don't open a second one if something already opened it
      if #Snacks.picker.get({ source = "explorer" }) == 0 then
        pcall(Snacks.explorer.open or Snacks.explorer)
      end
    end)
  end,
})

-- mark stdin so the autocmd above can skip when input is piped in
vim.api.nvim_create_autocmd("StdinReadPre", {
  callback = function() vim.g.std_in = true end,
})
