local M = {}

function M.config()
  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics,
    {
      virtual_text = {
        prefix = "▎", -- Could be '●', '▎', 'x'
      },
      update_in_insert = true,
    }
  )

  local diagnostic_signs = { " ", " ", " ", " " }

  local diagnostic_severity_fullnames = {
    "Error",
    "Warning",
    "Hint",
    "Information",
  }
  local diagnostic_severity_shortnames = { "Error", "Warn", "Hint", "Info" }

  -- define diagnostic icons/highlights for signcolumn and other stuff
  for index, icon in ipairs(diagnostic_signs) do
    local fullname = diagnostic_severity_fullnames[index]
    local shortname = diagnostic_severity_shortnames[index]

    vim.fn.sign_define("DiagnosticSign" .. shortname, {
      text = icon,
      texthl = "Diagnostic" .. shortname,
      linehl = "",
      numhl = "",
    })

    vim.fn.sign_define("LspDiagnosticsSign" .. fullname, {
      text = icon,
      texthl = "LspDiagnosticsSign" .. fullname,
      linehl = "",
      numhl = "",
    })
  end

  local au = vim.api.nvim_create_augroup("LspAttach", { clear = true })

  -- vim.api.nvim_create_autocmd('LspAttach', {
  --   group = au,
  --   desc = 'LSP options',
  --   callback = function(args)
  --     local client = vim.lsp.get_client_by_id(args.data.client_id)
  --     require('lsp-status').on_attach(client)
  --
  --     local bufnr = args.buf
  --     vim.api.nvim_buf_set_option(
  --       bufnr,
  --       'formatexpr',lsp
  --       'v:lua.vim.lsp.formatexpr'
  --     )
  --     vim.api.nvim_buf_set_option(
  --       bufnr,
  --       'tagfunc',
  --       'v:lua.vim.lsp.tagfunc'
  --     )
  --   end,
  -- })

  vim.api.nvim_create_autocmd("LspAttach", {
    group = au,
    desc = "LSP keymaps",
    callback = function(args)
      local bufnr = args.buf
      local function map(mode, lhs, rhs)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr })
      end

      map("n", "gD", vim.lsp.buf.declaration)
      map("n", "<leader>gd", vim.lsp.buf.definition)
      map("n", "K", vim.lsp.buf.hover)
      map("n", "gi", vim.lsp.buf.implementation)
      map("n", "<C-s>", vim.lsp.buf.signature_help)
      map("i", "<C-s>", vim.lsp.buf.signature_help)
      map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder)
      map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder)
      map("n", "<leader>wl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      end)
      map("n", "<leader>D", vim.lsp.buf.type_definition)
      map("n", "<leader>rn", vim.lsp.buf.rename)
      -- map('n', '<leader>rn', function()
      --   require('conf.nui_lsp').lsp_rename()
      -- end)
      map("n", "gr", function()
        require("trouble").open { mode = "lsp_references" }
      end)
      map("n", "gR", vim.lsp.buf.references)
      map("n", "<leader>li", vim.lsp.buf.incoming_calls)
      map("n", "<leader>lo", vim.lsp.buf.outgoing_calls)
      map("n", "<leader>lt", vim.lsp.buf.document_symbol)
      map("n", "<leader>d", function()
        vim.diagnostic.open_float {
          {
            scope = "line",
            border = "single",
            focusable = false,
            severity_sort = true,
          },
        }
      end)
      map("n", "[d", function()
        vim.diagnostic.goto_prev { enable_popup = false }
      end)
      map("n", "]d", function()
        vim.diagnostic.goto_next { enable_popup = false }
      end)
      map("n", "[e", function()
        vim.diagnostic.goto_prev {
          enable_popup = false,
          severity = { min = vim.diagnostic.severity.WARN },
        }
      end)
      map("n", "]e", function()
        vim.diagnostic.goto_next {
          enable_popup = false,
          severity = { min = vim.diagnostic.severity.WARN },
        }
      end)
      map("n", "<leader>q", vim.diagnostic.setloclist)
      map("n", "<leader>ls", vim.lsp.buf.document_symbol)
      map("n", "<leader>lS", vim.lsp.buf.workspace_symbol)

      map("n", "<leader>xx", "<cmd>Trouble<CR>")
      map("n", "<leader>gr", "<cmd>Trouble lsp_references<CR>")
      map("n", "<leader>wd", "<cmd>Trouble workspace_diagnostics<CR>")
      map("n", "<leader>dd", "<cmd>Trouble document_diagnostics<CR>")
      vim.opt.shortmess:append("c")
    end,
  })

  vim.api.nvim_create_autocmd("LspAttach", {
    group = au,
    desc = "LSP highlight",
    callback = function(args)
      local bufnr = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)

      if client.server_capabilities.documentHighlightProvider then
        local augroup_lsp_highlight = "lsp_highlight"

        vim.api.nvim_create_augroup(augroup_lsp_highlight, { clear = false })
        vim.api.nvim_create_autocmd("CursorHold", {
          group = augroup_lsp_highlight,
          buffer = bufnr,
          callback = vim.lsp.buf.document_highlight,
        })
        vim.api.nvim_create_autocmd("CursorMoved", {
          group = augroup_lsp_highlight,
          buffer = bufnr,
          callback = vim.lsp.buf.clear_references,
        })
      end
    end,
  })

  vim.api.nvim_create_autocmd("LspAttach", {
    group = au,
    desc = "LSP format",
    callback = function(args)
      local bufnr = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client.server_capabilities.documentFormattingProvider then
        local augroup_lsp_format = "lsp_format"
        vim.api.nvim_create_augroup(augroup_lsp_format, { clear = false })
        vim.api.nvim_create_autocmd("BufWritePre", {
          group = augroup_lsp_format,
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.format {
              -- async = true,
              filter = function(server)
                local disabled_servers = {
                  "lua_ls",
                  "eslint",
                  "tsserver",
                }
                return not vim.tbl_contains(disabled_servers, server.name)
              end,
            }
          end,
        })
      end

      -- FIXME
      -- if client.server_capabilities.documentRangeFormattingProvider then
      --     map('n', '<leader>f', vim.lsp.buf.range_formatting)
      -- end
    end,
  })

  local mason_status_ok, mason = pcall(require, "mason")
  local mason_lspconfig_status_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
  local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")

  if not mason_status_ok then
    return
  end

  if not mason_lspconfig_status_ok then
    return
  end

  if not lspconfig_status_ok then
    return
  end

  require("neodev").setup()

  -- JSON
  -- vscode-json-language-server
  lspconfig.jsonls.setup = {
    flags = { debounce_text_changes = 150 },
    filetypes = { "json", "jsonc" },
    settings = {
      json = {
        schemas = {
          {
            fileMatch = { "package.json" },
            url = "https://json.schemastore.org/package.json",
          },
          {
            fileMatch = { "tsconfig*.json" },
            url = "https://json.schemastore.org/tsconfig.json",
          },
          {
            fileMatch = {
              ".prettierrc",
              ".prettierrc.json",
              "prettier.config.json",
            },
            url = "https://json.schemastore.org/prettierrc.json",
          },
          {
            fileMatch = { ".eslintrc", ".eslintrc.json" },
            url = "https://json.schemastore.org/eslintrc.json",
          },
          {
            fileMatch = {
              ".stylelintrc",
              ".stylelintrc.json",
              "stylelint.config.json",
            },
            url = "http://json.schemastore.org/stylelintrc.json",
          },
        },
      },
    },
  }

  mason.setup()
  mason_lspconfig.setup {
    ensure_installed = {
      "lua_ls",
      "rust_analyzer",
      "cssls",
      "html",
      "svelte",
      "pyright",
      "tailwindcss",
      "vimls",
      "bashls",
      "tsserver",
      "volar",
      "gopls",
    },
  }

  -- local capabilities = vim.lsp.protocol.make_client_capabilities()
  -- require("cmp_nvim_lsp").default_capabilities(capabilities)

  local capabilities = require("cmp_nvim_lsp").default_capabilities(
    vim.lsp.protocol.make_client_capabilities()
  )
  capabilities.textDocument.completion.completionItem.snippetSupport = true

  require("rust-tools").setup {
    -- rust-tools options
    tools = {
      autoSetHints = true,
      inlay_hints = {
        show_parameter_hints = true,
        parameter_hints_prefix = "<- ",
        other_hints_prefix = "=> ",
      },
    },
    -- all the opts to send to nvim-lspconfig
    -- these override the defaults set by rust-tools.nvim
    --
    -- REFERENCE:
    -- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
    -- https://rust-analyzer.github.io/manual.html#configuration
    -- https://rust-analyzer.github.io/manual.html#features
    --
    -- NOTE: The configuration format is `rust-analyzer.<section>.<property>`.
    --       <section> should be an object.
    --       <property> should be a primitive.
    server = {
      -- on_attach = function(client, bufnr)
      --   require("shared/lsp")(client, bufnr)
      --   require("illuminate").on_attach(client)
      --
      --   local bufopts = {
      --     noremap = true,
      --     silent = true,
      --     buffer = bufnr,
      --   }
      --   vim.keymap.set("n", "<leader><leader>rr", "<Cmd>RustRunnables<CR>", bufopts)
      --   vim.keymap.set("n", "K", "<Cmd>RustHoverActions<CR>", bufopts)
      -- end,
      ["rust-analyzer"] = {
        assist = {
          importEnforceGranularity = true,
          importPrefix = "create",
        },
        cargo = { allFeatures = true },
        checkOnSave = {
          -- default: `cargo check`
          command = "clippy",
          allFeatures = true,
        },
      },
      inlayHints = {
        -- NOT SURE THIS IS VALID/WORKS 😬
        lifetimeElisionHints = {
          enable = true,
          useParameterNames = true,
        },
      },
    },
  }

  mason_lspconfig.setup_handlers {
    function(server_name)
      -- Otherwise the following `setup()` would override our config.
      if server_name ~= "jsonls" then
        lspconfig[server_name].setup {
          capabilities = capabilities,
        }
      end
    end,

    ["lua_ls"] = function()
      lspconfig.lua_ls.setup {
        capabilities = capabilities,
        flags = { debounce_text_changes = 150 },
        settings = {
          Lua = {
            completion = {
              callSnippet = "Replace",
            },
            workspace = {
              checkThirdParty = false,
            },
            telemetry = { enable = false },
            diagnostics = {
              -- unusedLocalExclude = { "_*" },
              globals = { "vim", "use", "require" },
            },
            format = { enable = false },
          },
        },
      }
    end,

    ["tsserver"] = function()
      lspconfig.tsserver.setup {
        capabilities = capabilities,

        on_attach = function(client, _)
          client.server_capabilities.document_formatting = false
          client.server_capabilities.document_range_formatting = false
          local ts_utils = require("nvim-lsp-ts-utils")

          -- defaults
          ts_utils.setup {
            -- eslint
            eslint_enable_code_actions = true,
            eslint_enable_disable_comments = true,
            eslint_bin = "eslint_d",
            eslint_config_fallback = nil,
            eslint_enable_diagnostics = true,

            -- formatting
            enable_formatting = true,
            formatter = "prettierd",
            formatter_config_fallback = nil,

            -- parentheses completion
            complete_parens = false,
            signature_help_in_parens = false,

            -- update imports on file move
            update_imports_on_move = true,
            require_confirmation_on_move = false,
            watch_dir = nil,
          }

          -- required to fix code action ranges
          ts_utils.setup_client(client)
        end,
      }
    end,
  }
end

return M
