return function()
  local status_ok, lspconfig = pcall(require, "lspconfig")
  local servers = require("core.lsp.servers")

  if not status_ok then
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

  local signs = {
    { name = "DiagnosticSignError", text = "✖" },
    { name = "DiagnosticSignWarn", text = "▲" },
    { name = "DiagnosticSignHint", text = "" },
    { name = "DiagnosticSignInfo", text = "✱" },
  }

  for _, sign in ipairs(signs) do
    vim.fn.sign_define(
      sign.name,
      { texthl = sign.name, text = sign.text, numhl = "" }
    )
  end

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  require("cmp_nvim_lsp").update_capabilities(capabilities)

  for server, config in pairs(servers) do
    lspconfig[server].setup(
      vim.tbl_deep_extend("force", { capabilities = capabilities }, config)
    )
  end
end
