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

  -- Prevent race conditions and conflicts between volar and tsserver
  vim.api.nvim_create_autocmd("LspAttach", {
    group = au,
    desc = "prevent tsserver and volar competing",
    callback = function(args)
      if not (args.data and args.data.client_id) then
        return
      end
      local active_clients = vim.lsp.get_clients()
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      -- prevent tsserver and volar competing
      -- if client.name == "volar" or require("lspconfig").util.root_pattern("nuxt.config.ts")(vim.fn.getcwd()) then
      -- OR
      if client and client.name == "volar" then
        for _, client_ in pairs(active_clients) do
          -- stop tsserver if volar is already active
          if client_.name == "tsserver" then
            client_.stop()
          end
        end
      elseif client and client.name == "tsserver" then
        for _, client_ in pairs(active_clients) do
          -- prevent tsserver from starting if volar is already active
          if client_.name == "volar" then
            client.stop()
          end
        end
      end
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
            require("conform").format {
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
      "astro",
    },
  }

  local capabilities = require("cmp_nvim_lsp").default_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true

  mason_lspconfig.setup_handlers {
    function(server_name)
      -- Otherwise the following `setup()` would override our config.
      if server_name ~= "jsonls" then
        lspconfig[server_name].setup {
          capabilities = capabilities,
        }
      end
    end,

    ["html"] = function()
      lspconfig.html.setup {
        capabilities = capabilities,
        -- disable any autoformatting html brings for .njk files
        on_attach = function(client, bufnr)
          if
            vim.bo[bufnr].filetype == "html" and vim.fn.expand("%:e") == "njk"
          then
            client.server_capabilities.documentFormattingProvider = false
          end
        end,
      }
    end,

    ["cssls"] = function()
      lspconfig.cssls.setup {
        capabilities = capabilities,
        on_attach = function(client, bufnr)
          -- Disable formatting capability of `cssls`
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end,
        settings = {
          css = {
            lint = {
              unknownAtRules = "ignore", -- Prevent errors on @apply, @tailwind, etc.
            },
          },
        },
      }
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
          "vue",
        },
      }
    end,
  }

  -- https://www.npbee.me/posts/deno-and-typescript-in-a-monorepo-neovim-lsp if
  -- I ever have to setup deno with TS
end

return M
