return {

  -- Colorschemes are defined in lua/plugins/themes.lua

  -- File tree is now defined in lua/plugins/asset-preview.lua
  -- (split out so the asset-viewer <cr> mapping lives with the neo-tree spec)

  -- Fuzzy finder
  { "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>",  desc = "Live Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>",    desc = "Buffers" },
    }},

  -- Status line
  { "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = true },

  -- Syntax highlighting
  { "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup {
        ensure_installed = { "c", "cpp", "lua", "cmake" },
        highlight = { enable = true },
        indent = { enable = true },
      }
    end },

  -- LSP + Mason (auto-installs language servers)
  { "williamboman/mason.nvim", config = true },
  { "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      require("mason-lspconfig").setup {
        ensure_installed = { "clangd" },  -- The C/C++ LSP
        automatic_installation = true,
      }
      vim.lsp.config("clangd", {})
      vim.lsp.enable("clangd")
      vim.lsp.config("luau_lsp", {})
      vim.lsp.enable("luau_lsp")
    end },

  -- Autocompletion
  { "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup {
        snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
          ["<Tab>"]     = cmp.mapping.select_next_item(),
          ["<S-Tab>"]   = cmp.mapping.select_prev_item(),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        },
      }
    end },

  -- Auto-pairs (brackets, quotes)
  { "windwp/nvim-autopairs", event = "InsertEnter", config = true },

  -- Git signs in gutter
  { "lewis6991/gitsigns.nvim", config = true },

  -- Which-key (shows keybind hints)
  { "folke/which-key.nvim", event = "VeryLazy", config = true },

  -- Comment toggling  gcc / gc
  { "numToStr/Comment.nvim", config = true },

  -- Indentation guides
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", config = true },

  -- Bufferline (tabs at the top)
  { "akinsho/bufferline.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = true 
  },

  -- lsp signature
  { "ray-x/lsp_signature.nvim",
    event = "InsertEnter",
    opts = {
      hint_enable = false,
      handler_opts = { border = "rounded" },
      select_signature_key = "<A-n>",
    },
  },

}
