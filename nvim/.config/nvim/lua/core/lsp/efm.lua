local eslint = {
  lintCommand = "eslint_d -f unix --stdin --stdin-filename ${INPUT}",
  lintSource = "eslint_d",
  lintStdin = true,
  lintIgnoreExitCode = true,
  lintFormats = { "%f(%l,%c): %tarning %m", "%f(%l,%c): %rror %m" },
  -- lintFormats = { '%f:%l:%c: %m' },
  formatCommand = "eslint_d --fix-to-stdout --stdin --stdin-filename=${INPUT}",
  formatStdin = true,
}

local prettier = {
  formatCommand = "./node_modules/.bin/prettier --stdin --stdin-filepath ${INPUT}",
  formatStdin = true,
}

local gprettier = {
  formatCommand = "prettier --stdin-filepath ${INPUT}",
  formatStdin = true,
}

local prettier_d_slim = {
  formatCommand = "prettier_d_slim --stdin --stdin-filepath ${INPUT}",
  formatStdin = true,
}

local languages = {
  css = { gprettier },
  html = { gprettier },
  javascript = { gprettier, eslint },
  javascriptreact = { gprettier, eslint },
  json = { gprettier },
  --lua             = { stylua },
  markdown = { gprettier },
  scss = { gprettier },
  sass = { gprettier },
  graphql = { gprettier },
  typescript = { gprettier, eslint },
  typescriptreact = { gprettier, eslint },
  yaml = { prettier },
}

-- https://github.com/mattn/efm-langserver
local util = require "lspconfig.util"

return {
  root_dir = util.root_pattern {
    "package.json",
    ".git/",
    ".",
  },
  flags = { debounce_text_changes = 150 },
  filetypes = vim.tbl_keys(languages),
  init_options = { documentFormatting = true, codeAction = true },
  settings = {
    languages = languages,
    rootMarkers = { "package.json", ".git/" },
  },
}
