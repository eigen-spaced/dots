return function()
  local lsp_status_ok, lspconfig = pcall(require, "lspconfig")
  local wk_status_ok, wk = pcall(require, "which-key")

  local servers = require("core.lsp.servers")

  if not lsp_status_ok then
    return
  end

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

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  require("cmp_nvim_lsp").update_capabilities(capabilities)

  for server, config in pairs(servers) do
    lspconfig[server].setup(
      vim.tbl_deep_extend("force", { capabilities = capabilities }, config)
    )
  end

  wk.register {
    ["<leader>"] = {
      g = {
        name = "+goto",
        D = "lsp declaration",
        d = "lsp definition",
        i = "lsp implementation",
        h = "lsp signature help",
      },
      ca = "code action",
      rn = "lsp rename",
    },
  }
end
