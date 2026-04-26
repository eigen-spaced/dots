-- Simple plugin specs with no (or trivial) custom config live here.
-- Anything with a non-trivial `config` / `opts` has its own file in this directory.

return {
  { "nvim-lua/plenary.nvim" },

  {
    "davidmh/mdx.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },

  {
    "HiPhish/rainbow-delimiters.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      after = "nvim-treesitter",
    },
  },

  {
    "mrcjkb/rustaceanvim",
    version = "^6",
    lazy = false,
  },

  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {
      keys = {
        ["<esc>"] = "close",
      },
    },
  },

  {
    "folke/ts-comments.nvim",
    opts = {},
    event = "VeryLazy",
    enabled = vim.fn.has("nvim-0.10.0") == 1,
  },

  { "tpope/vim-eunuch" },

  { "rafcamlet/nvim-luapad", cmd = "Luapad" },

  {
    "lervag/vimtex",
    lazy = false,
    init = function()
      vim.g.vimtex_view_method = "zathura"
    end,
  },
}
