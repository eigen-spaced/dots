local eslint = {
    lintCommand = 'eslint_d -f unix --stdin --stdin-filename ${INPUT}',
    lintSource = 'eslint_d',
    lintIgnoreExitCode = true,
    lintStdin = true,
    lintFormats = { '%f:%l:%c: %m' },
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

local prettier_d = {
    formatCommand = 'prettier_d_slim --config-precedence prefer-file --stdin --stdin-filepath ${INPUT}',
    formatStdin = true,
}

local format_config = {
    css                = { prettier },
    html               = { prettier },
    javascript         = { prettier, eslint },
    javascriptreact    = { prettier, eslint },
    json               = { prettier },
     --lua             = { stylua },
    markdown           = { prettier },
    scss               = { prettier },
    typescript         = { prettier, eslint },
    typescriptreact    = { prettier, eslint },
    yaml               = { gprettier },
}

-- https://github.com/mattn/efm-langserver
local HOME = os.getenv 'HOME'
local util = require 'lspconfig.util'
-- local efm_config = HOME .. '/.config/efm-langserver/config.yaml'
-- local efm_log = '/tmp/efm.log'

local efm_root_markers = {'package.json', '.git/', '.zshrc'}

return  {
  -- cmd = { 'efm-langserver', '-c', efm_config, '-logfile', efm_log },
  root_dir = util.root_pattern(efm_root_markers),
  -- flags = { debounce_text_changes = 150 },
  filetypes = vim.tbl_keys(format_config),
  init_options = { documentFormatting = true, codeAction = true },
  settings = {
    languages = format_config,
    rootMarkers = efm_root_markers
  },
}

