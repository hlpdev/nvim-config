-- Overrides on top of LazyVim's defaults.
-- LazyVim already ships the picker, lualine, treesitter, LSP, completion,
-- gitsigns, which-key, bufferline, indent guides, autopairs, comments, etc.

return {

  -- Default colorscheme (the extra themes live in themes.lua)
  { "LazyVim/LazyVim", opts = { colorscheme = "tokyonight-night" } },

  -- Extra treesitter parsers on top of LazyVim's defaults
  { "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "cpp", "cmake" } } },

  -- Extra language servers (clangd comes from the lang.clangd extra)
  { "neovim/nvim-lspconfig",
    opts = {
      servers = {
        luau_lsp = {},
      },
    } },

  -- Drop persistence.nvim's <leader>q* session keys so the custom <leader>q
  -- "save & close buffer" mapping fires without a which-key timeout.
  { "folke/persistence.nvim",
    keys = function() return {} end },

}
