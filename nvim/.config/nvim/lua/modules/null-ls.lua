local M = {}

function M.config()
  local custom_attach = require "core.lsp.custom_attach"
  local nls = require('null-ls')

  nls.setup{
    sources = {
      -- NOTE:
        -- 1. both needs to be enabled to so prettier can apply eslint fixes
        -- 2. prettierd should come first to prevent occassional race condition
      nls.builtins.formatting.prettierd,
      nls.builtins.formatting.eslint_d,

      nls.builtins.formatting.stylua.with {
        condition = function(utils)
          return utils.root_has_file 'stylua.toml'
        end,
      },

      nls.builtins.formatting.stylua.gofmt,

      nls.builtins.diagnostics.eslint_d
      -- nls.builtins.diagnostics.shellcheck,
      -- nls.builtins.code_actions.refactoring,
    },
    debug = true,
    on_attach = function(client, bufnr)
      custom_attach(client, bufnr)
    end,
  }
end

return M
