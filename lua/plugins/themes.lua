-- Extra colorschemes. The default (tokyonight-night) is set via LazyVim's
-- `colorscheme` option in lua/plugins/init.lua.
--
--   <leader>uc  -> live colorscheme picker (defined in config/keymaps.lua)

return {
  -- Tokyonight: clean modern dark; "night" is the darkest variant.
  { "folke/tokyonight.nvim", lazy = false, priority = 1000,
    opts = { style = "night" } },

  -- Kanagawa: warm, muted, inspired by Hokusai's Great Wave. "dragon" = darker.
  { "rebelot/kanagawa.nvim", lazy = true,
    opts = { theme = "dragon" } },

  -- Rosé Pine: low-contrast, soothing. "main" is the dark variant.
  { "rose-pine/neovim", name = "rose-pine", lazy = true,
    opts = { variant = "main" } },

  -- Oxocarbon: IBM Carbon-inspired, high-contrast dark. Pure dark, very crisp.
  { "nyoom-engineering/oxocarbon.nvim", lazy = true },

  -- Gruvbox: the classic retro warm palette.
  { "ellisonleao/gruvbox.nvim", lazy = true,
    opts = { contrast = "hard" } },
}
