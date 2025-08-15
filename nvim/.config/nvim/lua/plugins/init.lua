return {
  { "nvim-lua/plenary.nvim" },

  { "nvim-tree/nvim-web-devicons" },

  {
    "mason-org/mason.nvim",
    providers = {
      "mason.providers.registry-api",
      "mason.providers.client",
    },
    build = ":MasonUpdate", -- :MasonUpdate updates registry contents
  },

  { "mason-org/mason-lspconfig.nvim" },

  {
    "stevearc/conform.nvim",
    opts = {},
    config = function()
      require("conform").setup {
        formatters_by_ft = {
          lua = { "stylua" },
          -- Conform will run multiple formatters sequentially
          -- python = { "isort", "black" },
          rust = { "rustfmt", lsp_format = "fallback" },
          -- Conform will run the first available formatter
          javascript = { "prettierd", "prettier", stop_after_first = true },
          javascriptreact = {
            "prettierd",
            "prettier",
            stop_after_first = true,
          },
          typescript = { "prettierd", "prettier", stop_after_first = true },
          typescriptreact = {
            "prettierd",
            "prettier",
            stop_after_first = true,
          },
          vue = { "prettierd", "prettier", stop_after_first = true },
          json = { "prettierd", "prettier", stop_after_first = true },
          astro = { "prettierd", "prettier", stop_after_first = true },
        },
        formatters = {
          prettierd = {
            env = {
              PRETTIERD_DEFAULT_CONFIG = vim.fn.expand(
                vim.fn.stdpath("config")
                  .. "/lua/conf/envconfig/.prettierrc.json"
              ),
            },
          },
        },
      }
    end,
  },

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

  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {},
    config = function()
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

  {
    "folke/trouble.nvim",
    cmd = "Trouble",
  },

  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
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
        files = {
          cmd = "rg --files --hidden --glob '!.git/' --glob '!node_modules/'",
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
    -- event = "VeryLazy",
    config = function()
      require("nvim-autopairs").setup {}

      local autopairs = require("nvim-autopairs")
      local cond = require("nvim-autopairs.conds")
      local Rule = require("nvim-autopairs.rule")

      -- remove add single quote on filetype scheme or lisp
      autopairs.get_rules("`")[1].not_filetypes = { "clojure", "lisp" }
      autopairs.get_rules("'")[1].not_filetypes = { "clojure", "lisp" }
      -- autopairs.get_rules("(")[1].not_filetypes = { "clojure", "lisp" }

      autopairs.add_rules {
        -- Rule to insert only '() without adding duplicate quotes
        Rule("'", ")", { "clojure", "lisp" })
          :with_pair(cond.not_after_text("("))
          :with_move(cond.none())
          :with_cr(cond.none())
          :use_key("("), -- Trigger on typing '('
      }
    end,
  },

  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
  },

  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      explorer = { enabled = true },
      indent = { enabled = true },
      input = { enabled = true },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      scope = { enabled = false },
      bigfile = {
        enabled = true,
        notify = false,
        size = 100 * 1024, -- 100 KB
        line_length = 1000,
        setup = function(ctx)
          vim.schedule(function()
            Snacks.util.wo(0, {
              foldenable = false,
              statuscolumn = "",
              conceallevel = 0,
            })
            if vim.api.nvim_buf_is_valid(ctx.buf) then
              vim.bo[ctx.buf].syntax = ctx.ft
            end
          end)
        end,
      },
    },
    keys = {
      {
        "<leader>bk",
        function()
          Snacks.bufdelete()
        end,
        desc = "Delete Buffer",
      },
    },
  },

  {
    "saghen/blink.cmp",
    -- optional: provides snippets for the snippet source
    dependencies = { "rafamadriz/friendly-snippets" },
    version = "1.*",

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        -- ["tab"] = { "select_next" },
        -- ["<s-tab>"] = { "select_prev" },
        ["<CR>"] = { "select_and_accept", "fallback" },
        ["<c-e>"] = { "hide", "show", "fallback" },
        ["<c-n>"] = { "select_next", "show", "fallback" },
        ["<c-p>"] = { "select_prev", "show", "fallback" },
        ["<c-j>"] = { "select_next", "fallback" },
        ["<c-k>"] = { "select_prev", "fallback" },
      },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 500 },
      },

      -- Default list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, due to `opts_extend`
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },

      -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
      -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
      -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
      --
      -- See the fuzzy documentation for more information
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
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
    "folke/ts-comments.nvim",
    opts = {},
    event = "VeryLazy",
    enabled = vim.fn.has("nvim-0.10.0") == 1,
  },

  -- {
  --   "rmagatti/auto-session",
  --   config = function()
  --     require("auto-session").setup {
  --       log_level = "info",
  --       auto_session_suppress_dirs = {
  --         "~/",
  --         "~/Projects",
  --         "~/Documents/projects",
  --       },
  --     }
  --   end,
  -- },

  {
    "Olical/conjure",
    ft = { "clojure", "fennel", "python" }, -- etc
    lazy = true,
    init = function()
      -- This is VERY helpful when reporting an issue with the project
      -- vim.g["conjure#debug"] = true
    end,
  },

  {
    "julienvincent/nvim-paredit",
    config = function()
      require("nvim-paredit").setup()
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
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup {}
    end,
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
    end,
  },

  {
    "TimUntersberger/neogit",
    event = "BufRead",
    setup = function()
      require("modules.neogit-nvim").setup()
    end,
    config = function()
      require("modules.neogit-nvim").config()
    end,
  },

  {
    "lervag/vimtex",
    lazy = false, -- we don't want to lazy load VimTeX
    -- tag = "v2.15", -- uncomment to pin to a specific release
    init = function()
      -- VimTeX configuration goes here, e.g.
      vim.g.vimtex_view_method = "zathura"
    end,
  },

  {
    "ggandor/leap.nvim",
    config = function()
      require("leap").add_default_mappings()
    end,
  },

  { "rafcamlet/nvim-luapad", cmd = "Luapad" },
}
