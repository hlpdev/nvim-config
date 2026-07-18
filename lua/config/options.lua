-- Options are automatically loaded before lazy.nvim startup.
-- LazyVim defaults: https://www.lazyvim.org/configuration/general#options
local o = vim.opt

-- always sync with the system clipboard (LazyVim skips this over SSH)
o.clipboard = "unnamedplus"

-- 4-space indentation (LazyVim defaults to 2)
o.tabstop = 4
o.shiftwidth = 4
o.expandtab = true

o.scrolloff = 8
o.updatetime = 250
o.wrap = false
