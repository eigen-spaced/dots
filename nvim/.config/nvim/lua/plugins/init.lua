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
    version = "^9",
    lazy = false,
    init = function()
      vim.g.rustaceanvim = {
        server = {
          cmd = { "rust-analyzer", "--log-file", "/tmp/ra.log" },
          default_settings = {
            ["rust-analyzer"] = {
              check = {
                command = "check",
              },
              cachePriming = {
                enable = true,
                numThreads = 4, -- Adjust to your CPU core count
              },
              checkOnSave = true,
              cargo = {
                allTargets = false,
              },
              files = {
                watcher = "server",
              },
            },
          },
        },
      }
    end,
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
