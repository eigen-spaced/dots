local cmd = vim.cmd
local exec = vim.api.nvim_exec
local fn = vim.fn

require("core.options")
local utils = require("core.utils")

-- Bootstrap packer
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system {
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  }
end

cmd([[
    augroup Packer
      autocmd!
      autocmd BufWritePost init.lua PackerCompile
    augroup end
  ]])

cmd([[ packadd packer.nvim ]])
local packer = require("packer")
local use = packer.use

packer.startup {
  function()
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

    -- TREESITTER ECOSYSTEM
    use {
      "nvim-treesitter/nvim-treesitter",
      event = "BufRead",
      cmd = {
        "TSInstall",
        "TSInstallInfo",
        "TSInstallSync",
        "TSUninstall",
        "TSUpdate",
        "TSUpdateSync",
        "TSDisableAll",
        "TSEnableAll",
      },
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
      "windwp/nvim-ts-autotag",
      after = "nvim-treesitter",
      config = function()
        require("modules.autotag")
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

    -- LSP
    use {
      "neovim/nvim-lspconfig",
      config = require("core.lsp"),
    }

    use { "williamboman/nvim-lsp-installer" }

    use {
      "jose-elias-alvarez/null-ls.nvim",
      config = function()
        require("modules.null-ls-nvim")
      end,
      after = "nvim-lspconfig",
    }

    use {
      "jose-elias-alvarez/nvim-lsp-ts-utils",
      ft = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
      },
    }

    use {
      "folke/trouble.nvim",
      cmd = "Trouble",
      config = function()
        require("modules.trouble").config()
      end,
      requires = { "kyazdani42/nvim-web-devicons" },
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
        require("modules.neoclip-nvim").setup()
      end,
      config = function()
        require("modules.neoclip-nvim").config()
      end,
    }

    use {
      "windwp/nvim-autopairs",
      event = "InsertEnter",
      config = function()
        require("modules.autopairs")
      end,
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
      event = "InsertEnter",
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

    use {

      "L3MON4D3/LuaSnip",
      event = "InsertEnter",
      module = "luasnip",
      config = function()
        --   require 'conf.snippets'
        require("luasnip/loaders/from_vscode").lazy_load()
      end,

      requires = { "rafamadriz/friendly-snippets" },
    }

    use { "michaelb/sniprun", run = "bash ./install.sh" }

    use {
      "lewis6991/gitsigns.nvim",
      event = { "BufReadPre", "BufNewFile" },
      config = function()
        require("modules.gitsigns-nvim")
      end,
    }

    use {
      "sindrets/diffview.nvim",
      config = function()
        require("modules.diffview")
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

    use {
      "rmagatti/auto-session",
      config = function()
        require("auto-session").setup {
          log_level = "info",
          auto_session_suppress_dirs = { "~/", "~/Projects" },
        }
      end,
    }

    use { "tpope/vim-eunuch" }

    use {
      "tpope/vim-surround",
      event = "BufReadPost",
    }

    -- THEMES
    use {
      "projekt0n/github-nvim-theme",
      -- config = function()
      --   require("github-theme").setup {
      --     theme_style = "dark_default",
      --   }
      -- end,
      disable = true,
    }

    use { "folke/tokyonight.nvim" }
    use { "rebelot/kanagawa.nvim" }

    use {
      "feline-nvim/feline.nvim",
      config = function()
        require("modules.feline-nvim")
      end,
    }

    use {
      "TimUntersberger/neogit",
      -- module = "neogit",
      cond = utils.is_git_directory,
      event = "BufRead",
      setup = function()
        require("modules.neogit-nvim").setup()
      end,
      config = function()
        require("modules.neogit-nvim").config()
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

    use { "nathom/filetype.nvim" }

    use { "rafcamlet/nvim-luapad", cmd = "Luapad" }

    use { "famiu/bufdelete.nvim", cmd = { "Bdelete", "Bwipeout" } }

    use { "ellisonleao/glow.nvim", cmd = "Glow" }

    if packer_bootstrap then
      require("packer").sync()
    end
  end,
  config = {
    display = {
      open_fn = function()
        return require("packer.util").float { border = "single" }
      end,
    },
  },
}

-----------------------------------------------------------------------------//
-- Keymaps {
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

-- Better resizing
nmap("<M-Left>", "5<C-W><")
nmap("<M-Right>", "5<C-W>>")
nmap("<M-Down>", "5<C-W>-")
nmap("<M-Up>", "5<C-W>+")

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

-- Line bubbling
xmap("J", ":m '>+1<CR>gv-gv")
xmap("K", ":m '<-2<CR>gv-gv")
imap("<C-j>", "<cmd>move .+1<CR><esc>==a")
imap("<C-k>", "<cmd>move .-2<CR><esc>==a")
nmap("<leader>j", "<cmd>move .+1<CR>==")
nmap("<leader>k", "<cmd>move .-2<CR>==")

-- Close readonly buffers with q
nmap("gq", "&readonly ? ':close!<CR>' : 'q'", { expr = true, noremap = true })

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

vim.api.nvim_set_keymap("", "Q", "", { noremap = true, silent = true }) -- disable Q for ex mode
vim.api.nvim_set_keymap("", "q:", "", { noremap = true, silent = true }) -- disable Q for ex mode
-- U.map('n', 'x', '"_x') --delete char without yank
-- U.map('x', 'x', '"_x') -- delete visual selection without yank

imap(",", ",<C-g>u")
imap(".", ".<C-g>u")
imap("!", "!<C-g>u")
imap("(", "(<C-g>u")

cmap("w!!", "<esc>:lua require'core.utils'.sudo_write()<CR>", {
  silent = true,
})

nmap("<leader>so", "<cmd>lua require'core.utils'.source_filetype()<CR>")

-----------------------------------------------------------------------------//
-- }
-----------------------------------------------------------------------------//

-- prevent auto commenting of new lines
cmd([[au BufEnter * set fo-=c fo-=r fo-=o]])

-- Don't screw up folds when inserting text that might affect them, until
-- leaving insert mode. Foldmethod is local to the window. Protect against
-- screwing up folding when switching between windows.
cmd([[
    augroup folds
      autocmd InsertEnter * if !exists('w:last_fdm') | let w:last_fdm=&foldmethod | setlocal foldmethod=manual | endif
      autocmd InsertLeave,WinLeave * if exists('w:last_fdm') | let &l:foldmethod=w:last_fdm | unlet w:last_fdm | endif
    augroup END
  ]])

-- highlight yanked text briefly
cmd(
  [[autocmd TextYankPost * silent! lua vim.highlight.on_yank { higroup="Search", timeout=250, on_visual=true }]]
)
-- git commit window
exec(
  [[au BufNewFile,BufRead COMMIT_EDITMSG set spell nonumber wrap linebreak]],
  false
)
exec([[au BufEnter,BufWinEnter,WinEnter COMMIT_EDITMSG startinsert]], false)

exec([[au filetype gitcommit let b:EditorConfig_disable=1]], false)
