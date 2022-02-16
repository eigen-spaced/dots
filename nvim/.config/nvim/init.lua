local cmd = vim.cmd
local exec = vim.api.nvim_exec
local fn = vim.fn
local execute = vim.api.nvim_command

local map = require("core.utils").map
local nmap = require("core.utils").nmap
local vmap = require("core.utils").vmap
local imap = require("core.utils").imap

require("core.options")

-- Bootstrap packer
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

if fn.empty(fn.glob(install_path)) > 0 then
  fn.execute(
    "!git clone https://github.com/wbthomason/packer.nvim " .. install_path
  )
  execute("packadd packer.nvim")
end

cmd([[
    augroup Packer
      autocmd!
      autocmd BufWritePost init.lua PackerCompile
    augroup end
  ]])

local packer = require("packer")
local use = packer.use

packer.startup(function()
  use { "wbthomason/packer.nvim", opt = true }

  use { "nvim-lua/plenary.nvim" }

  use { "kyazdani42/nvim-web-devicons" }

  use {
    "nvim-neo-tree/neo-tree.nvim",
    cmd = {
      "NeoTreeFloat",
      "NeoTreeFloatToggle",
      "NeoTreeReveal",
      "NeoTreeRevealToggle",
    },
    branch = "v1.x",
    requires = {
      "MunifTanjim/nui.nvim",
    },
    setup = function()
      require("modules.neo-tree-nvim").setup()
    end,
    config = function()
      require("modules.neo-tree-nvim").config()
    end,
  }

  use {
    "nvim-treesitter/nvim-treesitter",
    requires = {
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
        after = "nvim-treesitter",
      },
      {
        "nvim-treesitter/playground",
        cmd = "TSPlaygroundToggle",
      },
    },
    run = ":TSUpdate",
    config = function()
      require("modules.treesitter").config()
    end,
  }

  use {
    "nvim-telescope/telescope.nvim",
    module = "telescope",
    cmd = "Telescope",
    setup = function()
      require("modules.telescope-nvim").setup()
    end,
    config = function()
      require("modules.telescope-nvim").config()
    end,
  }

  use {
    "neovim/nvim-lspconfig",
    config = require("core.lsp"),
  }

  use { "williamboman/nvim-lsp-installer" }

  use {
    "jose-elias-alvarez/null-ls.nvim",
    config = function()
      require("modules.null_ls").config()
    end,
  }

  use { "jose-elias-alvarez/nvim-lsp-ts-utils" }

  use {
    "folke/trouble.nvim",
    cmd = "Trouble",
    config = function()
      require("modules.trouble").config()
    end,
    requires = { "kyazdani42/nvim-web-devicons" },
  }

  use {
    "windwp/nvim-ts-autotag",
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  }

  use {
    "nanozuki/tabby.nvim",
    requires = "kyazdani42/nvim-web-devicons",
    config = function()
      require("tabby").setup()
    end,
  }

  use {
    "AckslD/nvim-neoclip.lua",
    module = "neoclip",
    event = { "TextYankPost" },
    setup = function()
      require("modules.neoclip").setup()
    end,
    config = function()
      require("modules.neoclip").config()
    end,
  }

  use {
    "windwp/nvim-autopairs",
    event = { "InsertEnter" },
    config = function()
      require("modules.autopairs").config()
    end,
  }

  use {
    "L3MON4D3/LuaSnip",
    after = "nvim-cmp",
    config = function()
      --   require 'conf.snippets'
      require("luasnip/loaders/from_vscode").lazy_load()
    end,
    wants = "rafamadriz/friendly-snippets",
  }

  use {
    "rafamadriz/friendly-snippets",
    event = "InsertCharPre",
  }

  use {
    "simrat39/symbols-outline.nvim",
    event = "VimEnter",
    setup = function()
      require("modules.symbols-outline").setup()
    end,
    config = function()
      require("modules.symbols-outline").config()
    end,
  }

  use {
    "hrsh7th/nvim-cmp",
    config = function()
      require("core.cmp").config()
    end,
    requires = {
      { "hrsh7th/cmp-nvim-lsp" },
      { "saadparwaiz1/cmp_luasnip", after = "nvim-cmp" },
      { "hrsh7th/cmp-buffer", after = "nvim-cmp" },
      { "hrsh7th/cmp-path", after = "nvim-cmp" },
      { "f3fora/cmp-spell", after = "nvim-cmp" },
    },
  }

  use { "michaelb/sniprun", run = "bash ./install.sh" }

  use {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("modules.gitsigns").config()
    end,
  }

  use {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require("indent_blankline").setup {
        show_current_context = true,
        buftype_exclude = { "terminal", "readonly", "nofile" },
        filetype_exclude = { "help", "packer", "neo-tree" },
      }
    end,
  }

  use { "tpope/vim-eunuch" }

  use {
    "tpope/vim-surround",
    event = "BufReadPost",
  }

  use {
    "projekt0n/github-nvim-theme",
    --[[ config = function()
      require("github-theme").setup({
        theme_style = "dark"
      })
    end ]]
  }

  use("folke/tokyonight.nvim")
  use("rebelot/kanagawa.nvim")

  use {
    "TimUntersberger/neogit",
    module = "neogit",
    setup = function()
      require("modules.neogit").setup()
    end,
    config = function()
      require("modules.neogit").config()
    end,
  }

  use {
    "numToStr/Comment.nvim",
    event = "BufReadPost",
    config = function()
      require("Comment").setup {
        toggler = {
          ---line-comment keymap
          line = "<leader>cc",
          ---block-comment keymap
          block = "<leader>bc",
        },

        opleader = {
          ---line-comment keymap
          line = "<leader>c",
          ---block-comment keymap
          block = "<leader>b",
        },
      }
    end,
  }

  use { "famiu/bufdelete.nvim", cmd = { "Bdelete", "Bwipeout" } }

  use { "ellisonleao/glow.nvim", cmd = "Glow" }
end)

-----------------------------------------------------------------------------//
-- Keymaps {{{1
-----------------------------------------------------------------------------//

-- Remap space as leader key
nmap("<Space>", "<NOP>")

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Toggle highlighting
nmap("<leader>hs", "<cmd>set hlsearch!<CR>")

imap("jk", "<Esc>")
imap("kj", "<Esc>")

-- Better split navigation
nmap("<C-h>", "<C-w>h")
nmap("<C-j>", "<C-w>j")
nmap("<C-k>", "<C-w>k")
nmap("<C-l>", "<C-w>l")

nmap("<Leader>o", "o<Esc>k")
nmap("<Leader>O", "O<Esc>j")

-- Better indenting
vmap("<", "<gv")
vmap(">", ">gv")

-- Buffer management
nmap("<Tab>", "<cmd>bnext<CR>")
nmap("<S-Tab>", "<cmd>bprev<CR>")

nmap("<Leader>bk", "<cmd>Bdelete<CR>")

-- Exit terminal using easier keybindings
-- U.map('t', 'jk', '<C-\\><C-n>')

-- Source lua.init
nmap("<leader>si", "<cmd>luafile ~/.config/nvim/init.lua<CR>")
-- Source current lua file
nmap("<leader>so", "<cmd>source %<CR>")

-- Line bubbling
map("x", "J", ":m '>+1<CR>gv-gv")
map("x", "K", ":m '<-2<CR>gv-gv")
imap("<C-j>", "<cmd>move .+1<CR><esc>==a")
imap("<C-k>", "<cmd>move .-2<CR><esc>==a")
nmap("<leader>j", "<cmd>move .+1<CR>==")
nmap("<leader>k", "<cmd>move .-2<CR>==")

-- Close readonly buffers with q
nmap("gq", "&readonly ? ':close!<CR>' : 'q'", {
  expr = true,
  noremap = true,
})

-- Remap for dealing with word wraps
nmap(
  "j",
  "v:count == 0 ? 'gj' : 'j'",
  { expr = true, noremap = true, silent = true }
)
nmap(
  "k",
  "v:count == 0 ? 'gk' : 'k'",
  { expr = true, noremap = true, silent = true }
)

map("", "Q", "") -- disable Q for ex mode
map("", "q:", "") -- disable Q for ex mode
-- U.map('n', 'x', '"_x') --delete char without yank
-- U.map('x', 'x', '"_x') -- delete visual selection without yank

imap(",", ",<C-g>u")
imap(".", ".<C-g>u")
imap("!", "!<C-g>u")
imap("(", "(<C-g>u")

map(
  "c",
  "w!!",
  "<esc>:lua require 'core.utils'.sudo_write()<CR>",
  { silent = true }
)

-----------------------------------------------------------------------------//
-- }}}1
-----------------------------------------------------------------------------//

-- prevent auto commenting of new lines
exec([[au BufEnter * set fo-=c fo-=r fo-=o]], false)

-- git commit window
exec(
  [[au BufNewFile,BufRead COMMIT_EDITMSG set spell nonumber wrap linebreak]],
  false
)
exec([[au BufEnter,BufWinEnter,WinEnter COMMIT_EDITMSG startinsert]], false)

exec([[au filetype gitcommit let b:EditorConfig_disable=1]], false)
