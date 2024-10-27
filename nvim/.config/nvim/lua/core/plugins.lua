local utils = require("core.utils")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  }
end

vim.opt.rtp:prepend(lazypath)

local lazy_ok, lazy = pcall(require, "lazy")

if lazy_ok then
  lazy.setup {
    { "nvim-lua/plenary.nvim" },

    { "kyazdani42/nvim-web-devicons" },

    {
      "williamboman/mason.nvim",
      build = ":MasonUpdate", -- :MasonUpdate updates registry contents
    },

    { "williamboman/mason-lspconfig.nvim" },

    {
      "stevearc/oil.nvim",
      config = function()
        require("oil").setup {
          delete_to_trash = false,
          keymaps = {
            ["<C-s>"] = "actions.select_split",
            ["<C-v>"] = "actions.select_vsplit",
            ["<Esc>"] = "actions.close",
          },
          float = {
            -- Padding around the floating window
            max_width = 80,
            border = "single",
            win_options = {
              winblend = 10,
            },
          },
        }
        -- vim.keymap.set("n", "-", require("oil").open, { desc = "Open parent directory" })
        vim.keymap.set("n", "-", require("oil").toggle_float)
      end,
    },

    {
      "nvim-neo-tree/neo-tree.nvim",
      cmd = {
        "NeoTreeFloat",
        "NeoTreeFloatToggle",
        "NeoTreeReveal",
        "NeoTreeRevealToggle",
      },
      branch = "v2.x",
      dependencies = {
        "MunifTanjim/nui.nvim",
      },
      setup = function()
        require("modules.neo-tree").setup()
      end,
      config = function()
        require("modules.neo-tree").config()
      end,
    },

    -- TREESITTER ECOSYSTEM
    {
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
      dependencies = {
        {
          "nvim-treesitter/nvim-treesitter-textobjects",
        },
        {
          "nvim-treesitter/playground",
          cmd = "TSPlaygroundToggle",
        },
      },
      build = ":TSUpdate",
      config = function()
        require("modules.treesitter").config()
      end,
    },

    {
      "HiPhish/rainbow-delimiters.nvim",
      dependencies = {
        "nvim-treesitter/nvim-treesitter",
      },
    },

    {
      "simrat39/symbols-outline.nvim",
      event = "VimEnter",
      setup = function()
        require("modules.symbols-outline").setup()
      end,
      config = function()
        require("modules.symbols-outline").config()
      end,
    },

    -- { "mistweaverco/kulala.nvim", opts = {} },

    {
      "windwp/nvim-ts-autotag",
      config = function()
        require("nvim-ts-autotag").setup {
          filetypes = {
            "html",
            "javascript",
            "javascriptreact",
            "svelte",
            "typescript",
            "typescriptreact",
            "vue",
          },
          skip_tags = {
            "area",
            "base",
            "br",
            "col",
            "command",
            "embed",
            "hr",
            "img",
            "slot",
            "input",
            "keygen",
            "link",
            "meta",
            "menuitem",
            "param",
            "source",
            "track",
            "wbr",
          },
        }
      end,
    },

    {
      "nvim-telescope/telescope.nvim",
      cmd = "Telescope",
      key = { "<c-p>" },
      setup = function()
        require("modules.telescope-nvim").setup()
      end,
      config = function()
        require("modules.telescope-nvim").config()
      end,
    },

    -- LSP
    {
      "neovim/nvim-lspconfig",
      config = function()
        require("core.lsp").config()
      end,
    },

    -- {
    --   "hinell/lsp-timeout.nvim",
    --   dependencies = { "neovim/nvim-lspconfig" },
    -- },

    {
      "nvimtools/none-ls.nvim",
      dependencies = {
        "nvim-lspconfig",
        "nvimtools/none-ls-extras.nvim",
      },
      config = function()
        require("modules.none-ls")
      end,
    },

    {
      "pmizio/typescript-tools.nvim",
      dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
      opts = {},
      config = function()
        local capabilities = require("cmp_nvim_lsp").default_capabilities()
        require("typescript-tools").setup {
          on_attach = function(client)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end,
          filetypes = {
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
            "vue",
          },
          settings = {
            capabilities = capabilities,
            separate_diagnostic_server = true,
            tsserver_max_memory = "auto",
            single_file_support = false,
            tsserver_plugins = {
              "@vue/typescript-plugin",
            },
          },
        }
      end,
    },

    { "simrat39/rust-tools.nvim" },

    {
      "folke/trouble.nvim",
      cmd = "Trouble",
    },

    {
      "ibhagwan/fzf-lua",
      config = function()
        vim.keymap.set(
          { "n", "v" },
          "<c-p>",
          "<cmd>lua require('fzf-lua').files()<CR>",
          { silent = true }
        )
        vim.keymap.set(
          { "n", "v" },
          "<leader>fw",
          "<cmd>lua require('fzf-lua').grep()<CR>",
          { silent = true }
        )
        vim.keymap.set(
          { "n", "v" },
          "<c-b>",
          "<cmd>lua require('fzf-lua').buffers()<CR>",
          { silent = true }
        )
        require("fzf-lua").setup {
          winpots = {
            preview = {
              hidden = "hidden",
            },
          },
        }
      end,
    },

    {
      "AckslD/nvim-neoclip.lua",
      event = { "TextYankPost" },
      config = function()
        require("modules.neoclip-nvim").config()
      end,
    },

    {
      "windwp/nvim-autopairs",
      event = "InsertEnter",
      config = function()
        local npairs = require("nvim-autopairs")
        npairs.setup()

        local cond = require("nvim-autopairs.conds")
        local Rule = require("nvim-autopairs.rule")

        -- uses the default behaviour and adds +,-,/,* to no_after for clojure and lisp
        npairs.add_rules {
          Rule("(", ")", { "clojure", "lisp" }):with_pair(
            cond.not_after_regex([=[[%w%%%'%[%"%.%`%$%+%-%/%*]]=])
          ),
        }

        -- turn off the original rule for clojure and lisp
        npairs.get_rule("(")[1].not_filetypes = { "clojure", "lisp" }
      end,
    },

    { "folke/neodev.nvim" },

    -- AUTO-COMPLETION
    {
      "hrsh7th/nvim-cmp",
      event = "InsertEnter",
      config = function()
        require("modules.cmp")
      end,
      dependencies = {
        { "hrsh7th/cmp-nvim-lsp" }, --, after = "nvim-lspconfig" },
        { "saadparwaiz1/cmp_luasnip" },
        { "hrsh7th/cmp-buffer" },
        { "hrsh7th/cmp-path" },
        { "f3fora/cmp-spell" },
      },
    },

    {
      "L3MON4D3/LuaSnip",
      event = "InsertEnter",
      config = function()
        --   require 'conf.snippets'
        require("luasnip/loaders/from_vscode").lazy_load()
      end,

      dependencies = { "rafamadriz/friendly-snippets" },
    },

    {
      "lewis6991/gitsigns.nvim",
      config = function()
        require("modules.gitsigns-nvim")
      end,
    },

    {
      "sindrets/diffview.nvim",
      config = function()
        require("modules.diffview")
      end,
    },

    {
      "lukas-reineke/indent-blankline.nvim",
      main = "ibl",
      config = function()
        require("ibl").setup {
          -- exclude = { "terminal", "readonly", "nofile" },
          -- show_first_indent_level = false,
          -- show_current_context = true,
          -- show_current_context_start = false,
          -- filetype_exclude = { "help", "gitcommit" },
          -- use_treesitter = true,
        }
      end,
    },

    {
      "rmagatti/auto-session",
      config = function()
        require("auto-session").setup {
          log_level = "info",
          auto_session_suppress_dirs = {
            "~/",
            "~/Projects",
            "~/Documents/projects",
          },
        }
      end,
    },

    {
      "Olical/conjure",
      ft = { "clojure", "fennel", "python" }, -- etc
      lazy = true,
      init = function()
        -- This is VERY helpful when reporting an issue with the project
        vim.g["conjure#debug"] = true
      end,
    },

    {
      "mrjones2014/smart-splits.nvim",
      config = function()
        local keymap = vim.keymap
        local smart_splits = require("smart-splits")

        keymap.set("n", "<M-Left>", smart_splits.resize_left)
        keymap.set("n", "<M-Down>", smart_splits.resize_down)
        keymap.set("n", "<M-Up>", smart_splits.resize_up)
        keymap.set("n", "<M-Right>", smart_splits.resize_right)
        -- moving between splits
        keymap.set("n", "<C-h>", smart_splits.move_cursor_left)
        keymap.set("n", "<C-j>", smart_splits.move_cursor_down)
        keymap.set("n", "<C-k>", smart_splits.move_cursor_up)
        keymap.set("n", "<C-l>", smart_splits.move_cursor_right)
        -- swapping buffers
        keymap.set("n", "<leader><leader>h", smart_splits.swap_buf_left)
        keymap.set("n", "<leader><leader>j", smart_splits.swap_buf_down)
        keymap.set("n", "<leader><leader>k", smart_splits.swap_buf_up)
        keymap.set("n", "<leader><leader>l", smart_splits.swap_buf_right)
      end,
    },

    { "tpope/vim-eunuch" },

    {
      "tpope/vim-surround",
      event = "BufReadPost",
    },

    -- THEMES
    {
      "EdenEast/nightfox.nvim",
      config = function()
        require("nightfox").setup {
          options = {
            dim_inactive = true,
            styles = {
              functions = "bold",
              keywords = "italic",
            },
          },
        }
      end,
    },

    {
      "rebelot/kanagawa.nvim",
      config = function()
        require("kanagawa").setup {
          dimInactive = true,
        }
        vim.cmd("colorscheme kanagawa")
        -- Since colors are being loaded from kanagawa, we'll put this here
      end,
    },

    {
      "TimUntersberger/neogit",
      cond = utils.is_git_directory,
      event = "BufRead",
      setup = function()
        require("modules.neogit-nvim").setup()
      end,
      config = function()
        require("modules.neogit-nvim").config()
      end,
    },

    {
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
    },

    {
      "Pocco81/true-zen.nvim",
      config = function()
        require("modules.true-zen").config()
      end,
    },

    {
      "ggandor/leap.nvim",
      config = function()
        require("leap").add_default_mappings()
      end,
    },

    { "rafcamlet/nvim-luapad", cmd = "Luapad" },

    { "famiu/bufdelete.nvim", cmd = { "Bdelete", "Bwipeout" } },

    { "ellisonleao/glow.nvim", cmd = "Glow" },
  }
else
  vim.notify("Lazy.nvim failed to load.")
end
