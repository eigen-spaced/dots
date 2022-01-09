return function()
  local lspconfig = require 'lspconfig'
  local servers = require 'core.lsp.servers'

  vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics,
    {
      virtual_text = {
        prefix = '▎', -- Could be '●', '▎', 'x'
      },
    }
  )

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  -- compe config
  require('cmp_nvim_lsp').update_capabilities(capabilities)

  --------------------- custom config servers ---------------------
  require('modules.null-ls').config()

  --[[ local efm = require 'core.lsp.efm'
  lspconfig[efm].setup {
    on_attach = custom_attach,
    capabilities = capabilities
  } ]]

  for server, config in pairs(servers) do
    lspconfig[server].setup(
      vim.tbl_deep_extend('force', { capabilities = capabilities }, config)
    )
  end
end
