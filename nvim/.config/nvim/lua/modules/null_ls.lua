local M = {}

function M.config()
  local status_ok, nls = pcall(require, "null-ls")

  if not status_ok then
    return
  end

  local formatting = nls.builtins.formatting
  local diagnostics = nls.builtins.diagnostics
  local code_actions = nls.builtins.code_actions

  local custom_attach = require("core.lsp.custom_attach")
  local nmap = require("core.utils").nmap

  local has_eslint_config = function(utils)
    return utils.root_has_file {
      ".eslintrc",
      ".eslintrc.json",
      ".eslintrc.js",
      ".eslintrc.cjs",
      ".eslintrc.yaml",
      ".eslintrc.yml",
    }
  end

  local sources = {
    -- both needs to be enabled to so prettier can apply eslint fixes
    -- prettierd should come first to prevent occassional race condition
    formatting.prettierd.with {
      extra_args = { "--no-semi", "--single-quote", "--jsx-single-quote" },
    },
    diagnostics.eslint_d.with {
      condition = has_eslint_config,
      filetypes = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "vue",
        "svelte",
      },
    },
    formatting.eslint_d.with {
      condition = has_eslint_config,
    },

    -- formatting.stylua.with {
    --   condition = function(utils)
    --     return utils.root_has_file { "stylua.toml", ".stylua.toml" }
    --   end,
    -- },

    formatting.stylua,
    formatting.stylua.gofmt,
    formatting.black,

    diagnostics.eslint_d,

    code_actions.gitsigns,
    -- nls.builtins.code_actions.refactoring,
  }

  nls.setup {
    on_attach = function(_, bufnr)
      custom_attach(_, bufnr)
    end,
    sources = sources,
    debug = false,
    diagnostics_format = "[#{c}] #{m} (#{s})",
  }
end

return M
