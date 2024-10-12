local M = {}

function M.config()
  local icons = require("core.icons")

  vim.lsp.handlers["textDocument/publishDiagnostics"] =
    vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
      virtual_text = {
        prefix = "▎", -- Could be '●', '▎', 'x'
      },
      update_in_insert = true,
    })

  local diagnostic_data = {
    { icon = icons.diagnostics.ERROR, fullname = "Error", shortname = "Error" },
    { icon = icons.diagnostics.WARN, fullname = "Warning", shortname = "Warn" },
    { icon = icons.diagnostics.HINT, fullname = "Hint", shortname = "Hint" },
    {
      icon = icons.diagnostics.INFO,
      fullname = "Information",
      shortname = "Info",
    },
  }

  for _, diagnostic in ipairs(diagnostic_data) do
    vim.fn.sign_define("DiagnosticSign" .. diagnostic.shortname, {
      text = diagnostic.icon,
      texthl = "Diagnostic" .. diagnostic.shortname,
      linehl = "",
      numhl = "",
    })

    vim.fn.sign_define("LspDiagnosticsSign" .. diagnostic.fullname, {
      text = diagnostic.icon,
      texthl = "LspDiagnosticsSign" .. diagnostic.fullname,
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
      local keymap_opts = { buffer = args.buf, silent = true, noremap = true }
      local with_desc = function(opts, desc)
        return vim.tbl_extend("force", opts, { desc = desc })
      end

      vim.keymap.set(
        "n",
        "gD",
        vim.lsp.buf.declaration,
        with_desc(keymap_opts, "LSP declaration")
      )
      vim.keymap.set(
        "n",
        "<leader>gd",
        vim.lsp.buf.definition,
        with_desc(keymap_opts, "LSP definition")
      )
      vim.keymap.set(
        "n",
        "K",
        vim.lsp.buf.hover,
        with_desc(keymap_opts, "LSP hover")
      )
      vim.keymap.set(
        "n",
        "gi",
        vim.lsp.buf.implementation,
        with_desc(keymap_opts, "LSP implementation")
      )
      vim.keymap.set("n", "<C-s>", vim.lsp.buf.signature_help, keymap_opts)
      vim.keymap.set("i", "<C-s>", vim.lsp.buf.signature_help, keymap_opts)

      vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition)
      vim.keymap.set(
        "n",
        "<leader>rn",
        vim.lsp.buf.rename,
        with_desc(keymap_opts, "LSP rename")
      )

      -- vim.keymap.set("n", "<leader>lt", vim.lsp.buf.document_symbol)
      vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)

      local troubleHelper = function(mode)
        require("trouble").open { mode = mode }
      end

      vim.keymap.set("n", "<leader>xx", "<cmd>Trouble<CR>")
      vim.keymap.set("n", "<leader>gr", function()
        troubleHelper("lsp_references")
      end, with_desc(keymap_opts, "Trouble LSP references"))

      vim.keymap.set("n", "<leader>dd", function()
        require("trouble").toggle { mode = "diagnostics", focus = true }
      end, with_desc(keymap_opts, "Trouble LSP references"))

      vim.keymap.set("n", "<leader>li", function()
        troubleHelper("lsp_incoming_calls")
      end, with_desc(keymap_opts, "Trouble LSP incoming calls"))
      vim.keymap.set("n", "<leader>lo", function()
        troubleHelper("lsp_outgoing_calls")
      end, with_desc(keymap_opts, "Trouble LSP outgoing calls"))
      vim.opt.shortmess:append("c")
    end,
  })

  vim.api.nvim_create_autocmd("LspAttach", {
    group = au,
    desc = "LSP highlight",
    callback = function(args)
      local bufnr = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)

      if client and client.server_capabilities.documentHighlightProvider then
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
      if client and client.server_capabilities.documentFormattingProvider then
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
    end,
  })

  local mason_status_ok, mason = pcall(require, "mason")
  local mason_lspconfig_status_ok, mason_lspconfig =
    pcall(require, "mason-lspconfig")
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
      "volar",
      "gopls",
    },
  }

  local capabilities = require("cmp_nvim_lsp").default_capabilities()
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
              missing_parameters = false, -- missing fields :)
            },
            format = { enable = false },
          },
        },
      }
    end,
    ["volar"] = function()
      lspconfig.volar.setup {
        capabilities = capabilities,
        filetypes = {
          "typescript",
          "javascript",
          "javascriptreact",
          "typescriptreact",
          "vue",
        },
      }
    end,
  }

  -- https://www.npbee.me/posts/deno-and-typescript-in-a-monorepo-neovim-lsp
  ---Specialized root pattern that allows for an exclusion
  ---@param opt { root: string[], exclude: string[] }
  ---@return fun(file_name: string): string | nil
  local function root_pattern_exclude(opt)
    local lsputil = require("lspconfig.util")

    return function(fname)
      local excluded_root = lsputil.root_pattern(opt.exclude)(fname)
      local included_root = lsputil.root_pattern(opt.root)(fname)

      if excluded_root then
        return nil
      else
        return included_root
      end
    end
  end

  require("typescript-tools").setup {
    filetypes = {
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
      "vue",
    },
    settings = {
      capabilities = capabilities,
      root_dir = root_pattern_exclude {
        root = { "package.json" },
        exclude = { "deno.json", "deno.jsonc" },
      },
      separate_diagnostic_server = true,
      tsserver_max_memory = "auto",
      single_file_support = false,
      tsserver_plugins = {
        "@vue/typescript-plugin",
      },
    },
  }
end

return M
