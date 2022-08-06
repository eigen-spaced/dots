local cmd, fn, api = vim.cmd, vim.fn, vim.api
local utils = require("core.utils")

require("core.options")
require("core.keymap")

-- Bootstrap packer
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

if fn.empty(fn.glob(install_path)) > 0 then
  vim.notify("Bootstrapping packer.nvim", { title = "Packer" })
  _G.packer_bootstrap = fn.system {
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  }
end

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
      branch = "v2.x",
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
      key = { "<c-p>" },
      module_pattern = "telescope.*",
      setup = function()
        require("modules.telescope-nvim").setup()
      end,
      config = function()
        require("modules.telescope-nvim").config()
      end,
      requires = {
        {
          "nvim-telescope/telescope-fzf-native.nvim",
          run = "make",
          after = "telescope.nvim",
          config = function()
            require("telescope").load_extension("fzf")
          end,
        },
      },
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

    -- AUTO-COMPLETION
    use {
      "hrsh7th/nvim-cmp",
      module = "cmp",
      event = "InsertEnter",
      config = function()
        require("modules.cmp")
      end,
      requires = {
        { "hrsh7th/cmp-nvim-lsp" }, --, after = "nvim-lspconfig" },
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
        if vim.wo.colorcolumn == "" then
          vim.opt.colorcolumn = "99999" --  workaround for cursorline causing artifacts
        end
        require("indent_blankline").setup {
          show_first_indent_level = false,
          show_current_context = true,
          show_current_context_start = true,
          buftype_exclude = { "terminal", "readonly", "nofile" },
          filetype_exclude = { "help", "packer", "neo-tree", "gitcommit" },
          use_treesitter = true,
        }
      end,
      disable = true,
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

    use {
      "NTBBloodbath/rest.nvim",
      setup = function()
        nmap("<leader>r", "<Plug>RestNvim")
        nmap("<leader>rp", "<Plug>RestNvimPreview")
        nmap("<leader>rl", "<Plug>RestNvimLast")
      end,
    }

    use { "mrjones2014/smart-splits.nvim" }

    use { "tpope/vim-eunuch" }

    use {
      "tpope/vim-surround",
      event = "BufReadPost",
    }

    -- THEMES
    use {
      "daschw/leaf.nvim",
      config = function()
        require("modules.colorscheme").leaf_config()
      end,
    }

    use {
      "navarasu/onedark.nvim",
      config = function()
        require("onedark").setup {
          style = "darker",
          code_style = {
            comments = "italic",
            keywords = "bold",
            functions = "none",
          },
        }
        require("onedark").load()
      end,
    }

    use {
      "rebelot/kanagawa.nvim",
      config = function()
        require("kanagawa").setup {
          dimInactive = true,
          globalStatus = true,
        }
      end,
    }

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
            block = "<leader>cb",
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

    use {
      "folke/which-key.nvim",
      config = function()
        require("modules.whichkey-nvim")
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

-- vim.cmd("au VimEnter * colorscheme kanagawa")
-- vim.cmd("colorscheme kanagawa")

-- prevent auto commenting of new lines
local auto_comment_group = api.nvim_create_augroup("DisableAutoComment", { clear = true })
api.nvim_create_autocmd(
  "BufEnter",
  { command = "set fo-=c fo-=r fo-=o", group = auto_comment_group, pattern = "*" }
)

-- Don't screw up folds when inserting text that might affect them, until
-- leaving insert mode. Foldmethod is local to the window. Protect against
-- screwing up folding when switching between windows.
cmd([[
    augroup folds
      autocmd InsertEnter * if !exists('w:last_fdm') | let w:last_fdm=&foldmethod | setlocal foldmethod=manual | endif
      autocmd InsertLeave,WinLeave * if exists('w:last_fdm') | let &l:foldmethod=w:last_fdm | unlet w:last_fdm | endif
    augroup END
  ]])

vim.api.nvim_create_augroup("bufcheck", { clear = true })

-- reload config file on change
api.nvim_create_autocmd("BufWritePost", {
  group = "bufcheck",
  pattern = vim.env.MYVIMRC,
  command = "silent source %",
})

-- highlight yanked text briefly
api.nvim_create_autocmd("TextYankPost", {
  group = "bufcheck",
  callback = function()
    vim.highlight.on_yank { higroup = "Search", timeout = 250, on_visual = true }
  end,
  pattern = "*",
})

-- Enable spell checking for certain file types
api.nvim_create_autocmd(
  { "BufRead", "BufNewFile" },
  { pattern = { "*.txt", "*.md", "*.tex" }, command = "setlocal spell" }
)

api.nvim_create_autocmd("VimResized", { command = "wincmd =" })
