return function()
  local lspconfig = require 'lspconfig'
  local servers = require 'core.lsp.servers'
  local custom_attach = require 'core.lsp.custom_attach'

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  -- compe config
  require('cmp_nvim_lsp').update_capabilities(capabilities)

  --------------------- custom config servers ---------------------
  -- null-ls
  require('core.lsp.null-ls').config()
  lspconfig['null-ls'].setup {
    on_attach = custom_attach,
    -- Fallback to .bashrc as a project root to enable LSP on loose files
    root_dir = function(fname)
      return lspconfig.util.root_pattern(
        'tsconfig.json',
        'pyproject.toml'
      )(fname) or lspconfig.util.root_pattern(
          '.eslintrc.js',
          '.git'
        )(fname) or lspconfig.util.root_pattern(
          'package.json',
          '.git/',
          '.zshrc'
        )(fname)
    end,
  }

  -- efm langserver
  --[[ local efm = require 'core.lsp.efm'
  lspconfig[efm].setup {
    on_attach = custom_attach,
    capabilities = capabilities
  } ]]

  for server, config in pairs(servers) do
    lspconfig[server].setup(vim.tbl_deep_extend(
      "force",
      { capabilities = capabilities },
      config))
  end
end
