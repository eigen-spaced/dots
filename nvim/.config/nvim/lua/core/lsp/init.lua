return function()
  local status_ok, lspconfig = pcall(require, "lspconfig")
  local servers = require "core.lsp.servers"

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

  vim.fn.sign_define("LspDiagnosticsSignError", {
    text = "✖",
    numhl = "LspDiagnosticsDefaultError",
    })
  vim.fn.sign_define("LspDiagnosticsSignWarning", {
    text = "▲",
    numhl = "LspDiagnosticsDefaultWarning",
    })
  vim.fn.sign_define("LspDiagnosticsSignInformation", {
    text = "●",
    numhl = "LspDiagnosticsDefaultInformation",
    })
  vim.fn.sign_define("LspDiagnosticsSignHint", {
    text = "✱",
    numhl = "LspDiagnosticsDefaultHint",
    })

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  -- compe config
  require("cmp_nvim_lsp").update_capabilities(capabilities)

  require("modules.null_ls").config()

  for server, config in pairs(servers) do
    lspconfig[server].setup(
      vim.tbl_deep_extend("force", { capabilities = capabilities }, config)
    )
  end
end
