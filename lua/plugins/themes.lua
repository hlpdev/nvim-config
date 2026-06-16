-- Colorschemes. Several installed; switch live with the picker below.
-- Default is set at the bottom (DEFAULT_COLORSCHEME).
--
--   <leader>uc  -> live colorscheme picker (Telescope)
--
-- To change the default permanently, edit DEFAULT_COLORSCHEME.

local DEFAULT_COLORSCHEME = "tokyonight-night"

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

  -- Apply the default once everything is loaded, and add the live picker.
  {
    "folke/tokyonight.nvim", -- reuse an always-loaded spec to hang config on
    lazy = false,
    priority = 999,
    config = function()
      pcall(vim.cmd.colorscheme, DEFAULT_COLORSCHEME)

      -- Live picker: lists installed colorschemes, applies on <CR>.
      vim.keymap.set("n", "<leader>uc", function()
        local ok, builtin = pcall(require, "telescope.builtin")
        if ok then
          builtin.colorscheme({ enable_preview = true })
        else
          -- fallback if telescope isn't available
          vim.ui.select(vim.fn.getcompletion("", "color"), {
            prompt = "Colorscheme",
          }, function(choice)
            if choice then vim.cmd.colorscheme(choice) end
          end)
        end
      end, { desc = "Pick colorscheme" })
    end,
  },
}
