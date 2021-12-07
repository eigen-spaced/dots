local cmd = vim.cmd

local M = {}

function M.config()
  cmd [[packadd nvim-treesitter-textobjects]]

  require('nvim-treesitter.configs').setup {
    ensure_installed = 'maintained', -- one of "all", "maintained" (parsers with maintainers), or a list of languages
    ignore_install = {
      'php',
      'kotlin',
      'scala',
      'elixir',
      'zig',
    },
    highlight = {
      enable = true, -- false will disable the whole extension
      use_languagetree = true,
    },
    indent = { enable = true },
    rainbows = { enable = true },
    context_commentstring = { enable = true },

    textobjects = { -- syntax-aware textobjects
      select = {
        enable = true,
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['aC'] = '@class.outer',
          ['iC'] = '@class.inner',
          ['ac'] = '@conditional.outer',
          ['ic'] = '@conditional.inner',
          ['ab'] = '@block.outer',
          ['ib'] = '@block.inner',
          ['al'] = '@loop.outer',
          ['il'] = '@loop.inner',
          ['is'] = '@statement.inner',
          ['as'] = '@statement.outer',
          ['am'] = '@call.outer',
          ['im'] = '@call.inner',
          ['ad'] = '@comment.outer',
          ['id'] = '@comment.inner',
          -- Or you can define your own textobjects like this
          ['iF'] = {
            python = '(function_definition) @function',
            cpp = '(function_definition) @function',
            c = '(function_definition) @function',
            java = '(method_declaration) @function',
          },
        },
      },
    },
  }
end

return M
