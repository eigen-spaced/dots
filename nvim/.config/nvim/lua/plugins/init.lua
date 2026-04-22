return {
  { "nvim-lua/plenary.nvim" },

  {
    "nvim-mini/mini.nvim",
    version = false,
    config = function()
      require("mini.comment").setup()
      require("mini.surround").setup()
      require("mini.icons").setup()
      require("mini.misc").setup()

      local combine_groups = function(groups)
        local parts = vim.tbl_map(function(s)
          if type(s) == "string" then
            return s
          end
          if type(s) ~= "table" then
            return ""
          end

          local string_arr = vim.tbl_filter(function(x)
            return type(x) == "string" and x ~= ""
          end, s.strings or {})
          local str = table.concat(string_arr, " ")

          -- Use previous highlight group
          if s.hl == nil then
            return " " .. str .. " "
          end

          -- Allow using this highlight group later
          if str:len() == 0 then
            return "%#" .. s.hl .. "#"
          end

          return string.format("%%#%s#%s", s.hl, str)
        end, groups)

        return table.concat(parts, "")
      end

      local function hex(n)
        return n and string.format("#%06x", n) or "NONE"
      end
      local function bg_of(name)
        return hex(vim.api.nvim_get_hl(0, { name = name, link = false }).bg)
      end

      local function define_caps()
        local sl_bg = bg_of("StatusLine")
        local sections = {
          "MiniStatuslineModeNormal",
          "MiniStatuslineModeInsert",
          "MiniStatuslineModeVisual",
          "MiniStatuslineModeReplace",
          "MiniStatuslineModeCommand",
          "MiniStatuslineModeOther",
          "MiniStatuslineDevinfo",
          "MiniStatuslineFileinfo",
          "MiniStatuslineFilename",
        }
        for _, s in ipairs(sections) do
          vim.api.nvim_set_hl(0, s .. "Cap", { fg = bg_of(s), bg = sl_bg })
        end
      end

      define_caps()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = define_caps })

      require("mini.statusline").setup {
        content = {
          -- Content for active window
          active = function()
            local mode, mode_hl =
              MiniStatusline.section_mode { trunc_width = 120 }
            local git = MiniStatusline.section_git { trunc_width = 40 }
            local diff = MiniStatusline.section_diff { trunc_width = 75 }
            local diagnostics =
              MiniStatusline.section_diagnostics { trunc_width = 75 }
            local lsp = MiniStatusline.section_lsp { trunc_width = 75 }
            local filename =
              MiniStatusline.section_filename { trunc_width = 140 }
            local fileinfo =
              MiniStatusline.section_fileinfo { trunc_width = 120 }
            local location =
              MiniStatusline.section_location { trunc_width = 75 }
            local search =
              MiniStatusline.section_searchcount { trunc_width = 75 }

            local L = ""
            local R = ""

            local tab = {
              { hl = mode_hl .. "Cap", strings = { L } },
              { hl = mode_hl, strings = { mode } },
              { hl = mode_hl .. "Cap", strings = { R } },
              "%<",
            }

            if table.concat({ git, diff, diagnostics, lsp }):len() > 0 then
              table.insert(
                tab,
                { hl = "MiniStatuslineDevinfoCap", strings = { L } }
              )
              table.insert(tab, {
                hl = "MiniStatuslineDevinfo",
                strings = { git, diff, diagnostics, lsp },
              })
              table.insert(
                tab,
                { hl = "MiniStatuslineDevinfoCap", strings = { R } }
              )
              table.insert(tab, "%<")
            end

            table.insert(
              tab,
              { hl = "MiniStatuslineFilenameCap", strings = { L } }
            )
            table.insert(tab, {
              hl = "MiniStatuslineFilename",
              strings = { " ", filename, " " },
            })
            table.insert(
              tab,
              { hl = "MiniStatuslineFilenameCap", strings = { R } }
            )

            table.insert(tab, "%=")

            if fileinfo:len() > 0 then
              table.insert(
                tab,
                { hl = "MiniStatuslineFileinfoCap", strings = { L } }
              )
              table.insert(
                tab,
                { hl = "MiniStatuslineFileinfo", strings = { fileinfo } }
              )
              table.insert(
                tab,
                { hl = "MiniStatuslineFileinfoCap", strings = { R } }
              )
            end

            table.insert(tab, { hl = mode_hl .. "Cap", strings = { L } })
            table.insert(tab, {
              hl = mode_hl,
              strings = { search, location },
            })
            table.insert(tab, { hl = mode_hl .. "Cap", strings = { R } })

            return combine_groups(tab)
          end,
          -- Content for inactive window(s)
          inactive = nil,
        },
        use_icons = vim.g.have_nerd_font,
        set_vim_settings = true,
      }
    end,
  },

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
          cpp = { "clang-format" },
          c = { "clang-format" },
          lua = { "stylua" },
          go = { "goimports", "gofmt" },
          python = {
            "ruff_fix",
            "ruff_format",
            "ruff_organize_imports",
          },
          rust = { "rustfmt", lsp_format = "fallback" },
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
          ["clang-format"] = {
            command = "/opt/homebrew/opt/llvm/bin/clang-format",
          },
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
    opts = {
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
    },
    keys = {
      -- vim.keymap.set("n", "-", require("oil").open, { desc = "Open parent directory" })
      {
        "-",
        function()
          require("oil").toggle_float()
        end,
        mode = { "n", "x" },
        desc = "Open folder under current folder",
      },
    },
  },

  -- TREESITTER ECOSYSTEM
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")
      ts.install {
        "c",
        "lua",
        "vim",
        "vimdoc",
        "go",
        "gomod",
        "gowork",
        "gotmpl",
        "python",
        "javascript",
        "typescript",
        "html",
      }

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup(
          "TreesitterHighlight",
          { clear = true }
        ),
        callback = function(args)
          local bufnr = args.buf
          local ft = vim.bo[bufnr].filetype

          local ignore_ft = {
            "fzf",
            "TelescopePrompt",
            "qf",
            "netrw",
            "lazy",
            "mason",
            "notify",
          }
          if vim.tbl_contains(ignore_ft, ft) then
            return
          end

          local lang = vim.treesitter.language.get_lang(ft) or ft

          -- We pass the function, then the arguments: pcall(fn, arg1, arg2)
          local ok, err = pcall(vim.treesitter.start, bufnr, lang)
        end,
      })
    end,
  },

  {
    "davidmh/mdx.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },

  {
    "windwp/nvim-ts-autotag",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    lazy = true, -- Don't load automatically
    event = "VeryLazy", -- Load after everything else
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
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      heading = {
        enabled = false,
      },
    },
  },

  {
    "HiPhish/rainbow-delimiters.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      after = "nvim-treesitter",
    },
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("core.lsp").config()
    end,
  },

  {
    "mrcjkb/rustaceanvim",
    version = "^6",
    lazy = false,
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
    dependencies = { "nvim-mini/mini.icons" },
    ---@module "fzf-lua"
    ---@type fzf-lua.Config
    opts = {
      files = {
        winopts = {
          width = 0.5,
          height = 0.5,
        },
        previewer = false,
        cmd = "rg --files --hidden --glob '!.git/' --glob '!node_modules/'",
      },
    },
    keys = {
      {
        "<c-p>",
        function()
          require("fzf-lua").files()
        end,
        mode = { "n", "x" },
      },
      {
        "<c-g>",
        function()
          require("fzf-lua").grep()
        end,
        mode = { "n", "x" },
      },

      {
        "<c-/>",
        function()
          require("fzf-lua").live_grep()
        end,
        mode = { "n", "x" },
      },

      {
        "<c-b>",
        function()
          require("fzf-lua").buffers()
        end,
        mode = { "n", "x" },
      },
    },
  },

  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LspAttach",
    priority = 1000,
    config = function()
      require("tiny-inline-diagnostic").setup()
      vim.diagnostic.config { virtual_text = false } -- Disable Neovim's default virtual text diagnostics
    end,
  },

  {
    "gbprod/yanky.nvim",
    dependencies = {
      { "kkharji/sqlite.lua", "folke/snacks.nvim" },
    },
    opts = {
      ring = { storage = "sqlite" },
    },
    keys = {
      {
        "<c-'>",
        function()
          Snacks.picker.yanky()
        end,
        mode = { "n", "x" },
        desc = "Open Yank History",
      },
      { "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank text" },
      {
        "p",
        "<Plug>(YankyPutAfter)",
        mode = { "n", "x" },
        desc = "Put yanked text after cursor",
      },
      {
        "P",
        "<Plug>(YankyPutBefore)",
        mode = { "n", "x" },
        desc = "Put yanked text before cursor",
      },
      {
        "gp",
        "<Plug>(YankyGPutAfter)",
        mode = { "n", "x" },
        desc = "Put yanked text after selection",
      },
      {
        "gP",
        "<Plug>(YankyGPutBefore)",
        mode = { "n", "x" },
        desc = "Put yanked text before selection",
      },
      {
        "<leader>p",
        "<Plug>(YankyPreviousEntry)",
        desc = "Select previous entry through yank history",
      },
      {
        "<leader>n",
        "<Plug>(YankyNextEntry)",
        desc = "Select next entry through yank history",
      },
      {
        "]p",
        "<Plug>(YankyPutIndentAfterLinewise)",
        desc = "Put indented after cursor (linewise)",
      },
      {
        "[p",
        "<Plug>(YankyPutIndentBeforeLinewise)",
        desc = "Put indented before cursor (linewise)",
      },
      {
        "]P",
        "<Plug>(YankyPutIndentAfterLinewise)",
        desc = "Put indented after cursor (linewise)",
      },
      {
        "[P",
        "<Plug>(YankyPutIndentBeforeLinewise)",
        desc = "Put indented before cursor (linewise)",
      },
      {
        ">p",
        "<Plug>(YankyPutIndentAfterShiftRight)",
        desc = "Put and indent right",
      },
      {
        "<p",
        "<Plug>(YankyPutIndentAfterShiftLeft)",
        desc = "Put and indent left",
      },
      {
        ">P",
        "<Plug>(YankyPutIndentBeforeShiftRight)",
        desc = "Put before and indent right",
      },
      {
        "<P",
        "<Plug>(YankyPutIndentBeforeShiftLeft)",
        desc = "Put before and indent left",
      },
      {
        "=p",
        "<Plug>(YankyPutAfterFilter)",
        desc = "Put after applying a filter",
      },
      {
        "=P",
        "<Plug>(YankyPutBeforeFilter)",
        desc = "Put before applying a filter",
      },
    },
  },

  {
    "hat0uma/csvview.nvim",
    ---@module "csvview"
    ---@type CsvView.Options
    opts = {
      parser = { comments = { "#", "//" } },
      keymaps = {
        -- Text objects for selecting fields
        textobject_field_inner = { "if", mode = { "o", "x" } },
        textobject_field_outer = { "af", mode = { "o", "x" } },
        -- Excel-like navigation:
        -- Use <Tab> and <S-Tab> to move horizontally between fields.
        -- Use <Enter> and <S-Enter> to move vertically between rows and place the cursor at the end of the field.
        -- Note: In terminals, you may need to enable CSI-u mode to use <S-Tab> and <S-Enter>.
        jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
        jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
        jump_next_row = { "<Enter>", mode = { "n", "v" } },
        jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
      },
    },
    cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
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
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
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
      -- notifier = { enabled = true },
      zen = { enabled = true },
      quickfile = { enabled = true },
      scope = { enabled = false },
      picker = { enabled = true },
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
      {
        "<leader>z",
        function()
          Snacks.zen()
        end,
        desc = "Toggle Zen Mode",
      },
      {
        "<leader>Z",
        function()
          Snacks.zen.zoom()
        end,
        desc = "Toggle Zoom",
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

      sources = {
        default = { "lazydev", "lsp", "path", "snippets", "buffer" },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            -- make lazydev completions top priority (see `:h blink.cmp`)
            score_offset = 100,
          },
        },
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

    "obsidian-nvim/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    event = {
      "BufReadPre " .. vim.fn.expand("~") .. "/notes/*.md",
      "BufNewFile " .. vim.fn.expand("~") .. "/notes/*.md",
    },
    ---@module 'obsidian'
    ---@type obsidian.config
    opts = {
      workspaces = {
        {
          name = "main",
          path = "~/notes",
        },
      },
      completion = {
        nvim_cmp = false,
        min_chars = 0,
      },
      picker = {
        name = "fzf-lua",
      },
      note_id_func = function(title)
        if title ~= nil then
          return title
        else
          local suffix = ""
          for _ = 1, 4 do
            suffix = suffix .. string.char(math.random(65, 90))
          end
          return suffix
        end
      end,
      frontmatter = {
        func = function(note)
          local out = { collection = "Uncategorised", tags = note.tags }
          if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
            for k, v in pairs(note.metadata) do
              out[k] = v
            end
          end
          return out
        end,
        sort = { "tags", "collections" },
      },
    },
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

  { "rafcamlet/nvim-luapad", cmd = "Luapad" },
}
