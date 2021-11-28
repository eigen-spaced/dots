local null_ls = require('null-ls')

local M = {}

function M.config()
  null_ls.config({
    sources = {
      null_ls.builtins.formatting.stylua.with {
        condition = function(utils)
          return utils.root_has_file 'stylua.toml'
        end,
      },

      null_ls.builtins.formatting.eslint_d,

      null_ls.builtins.formatting.prettierd.with {
        filetypes = {
          'vue',
          'svelte',
          'css',
          'scss',
          'less',
          'html',
          'yaml',
          'graphql',
        },
      },
      -- null_ls.builtins.diagnostics.shellcheck,
      -- null_ls.builtins.code_actions.refactoring,
    },
  })
end

return M
