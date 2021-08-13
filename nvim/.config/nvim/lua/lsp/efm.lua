local eslint = {
  lintCommand = 'eslint_d -f vscode --stdin --stdin-filename ${INPUT}',
  lintSource = 'eslint_d',
  lintStdin = true,
  lintIgnoreExitCode = true,
  lintFormats = { '%f(%l,%c): %tarning %m', '%f(%l,%c): %rror %m' },
  -- lintFormats = { '%f:%l:%c: %m' },
  formatCommand = 'eslint_d --fix-to-stdout --stdin --stdin-filename=${INPUT}',
  formatStdin = true,
}

local prettier = {
  formatCommand = "./node_modules/.bin/prettier --stdin --stdin-filepath ${INPUT}",
  formatStdin = true
}

local gprettier = {
  formatCommand = 'prettier --stdin-filepath ${INPUT}',
  formatStdin = true,
}

local prettier_d_slim = {
  formatCommand = 'prettier_d_slim --config-precedence prefer-file --stdin --stdin-filepath ${INPUT}',
  formatStdin = true,
}

local languages = {
  css                = { prettier_d_slim },
  html               = { prettier_d_slim },
  javascript         = { prettier_d_slim, eslint },
  javascriptreact    = { prettier_d_slim, eslint },
  json               = { prettier_d_slim },
  --lua             = { stylua },
  markdown           = { prettier_d_slim },
  scss               = { prettier_d_slim },
  sass               = { prettier_d_slim },
  graphql               = { prettier_d_slim },
  typescript         = { prettier_d_slim, eslint },
  typescriptreact    = { prettier_d_slim, eslint },
  yaml               = { prettier_d_slim },
}

-- https://github.com/mattn/efm-langserver
local util = require 'lspconfig.util'
local on_attach = require 'lsp.on_attach'

return  {
  root_dir = util.root_pattern({
        'package.json',
        '.git/',
        '.'
  }),
  -- flags = { debounce_text_changes = 150 },
  on_attach = on_attach,
  filetypes = vim.tbl_keys(languages),
  init_options = { documentFormatting = true, codeAction = true },
  settings = {
    languages = languages,
    rootMarkers = {'package.json', '.git/'}
  },
}
