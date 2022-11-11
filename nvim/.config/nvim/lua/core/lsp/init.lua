local M = {}

function M.setup()
  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics,
    {
      virtual_text = {
        prefix = "▎", -- Could be '●', '▎', 'x'
      },
      update_in_insert = true,
    }
  )

  local diagnostic_signs = { " ", " ", " ", " " }

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
  --       'formatexpr',
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
        vim.api.nvim_create_autocmd("BufWritePost", {
          group = augroup_lsp_format,
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.format {
              async = true,
              filter = function(server)
                local disabled_servers = {
                  "sumneko_lua",
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
end

function M.config()
  local lsp_status_ok, lspconfig = pcall(require, "lspconfig")
  local wk_status_ok, wk = pcall(require, "which-key")

  if not lsp_status_ok then
    return
  end

  vim.cmd([[packadd nvim-lspconfig]])
  local servers = require("core.lsp.servers")

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  require("cmp_nvim_lsp").default_capabilities(capabilities)

  for server, config in pairs(servers) do
    require("lspconfig")[server].setup(
      vim.tbl_deep_extend("force", { capabilities = capabilities }, config)
    )
  end

  local sources = require("modules.null-ls-nvim").setup()

  require("null-ls").setup {
    sources = sources,
    debug = false,
    -- Fallback to .bashrc as a project root to enable LSP on loose files
    root_dir = function(fname)
      return lspconfig.util.root_pattern("tsconfig.json", "pyproject.toml", "stylua.toml")(fname)
        or lspconfig.util.root_pattern(".eslintrc.js", ".git")(fname)
        or lspconfig.util.root_pattern("package.json", ".git/", ".zshrc")(fname)
    end,
  }

  if not wk_status_ok then
    return
  end

  wk.register {
    g = {
      name = "+goto",
      D = "lsp declaration",
      d = "lsp definition",
      i = "lsp implementation",
      h = "lsp signature help",
    },
    ca = "code action",
    rn = "lsp rename",
  }
end

return M
