local nls_status_ok, nls = pcall(require, "null-ls")

if not nls_status_ok then
  return
end

local formatting = nls.builtins.formatting
local diagnostics = nls.builtins.diagnostics
local h = require("null-ls.helpers")
-- local code_actions = nls.builtins.code_actions

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

local blackd = {
  name = "blackd",
  method = nls.methods.FORMATTING,
  filetypes = { "python" },
  generator = h.formatter_factory {
    command = "blackd-client",
    to_stdin = true,
  },
}

local sources = {
  -- both needs to be enabled to so prettier can apply eslint fixes
  -- prettierd should come first to prevent occassional race condition
  -- formatting.prettierd.with {
  --   args = { "--no-semi", "--single-quote", "--jsx-single-quote" },
  -- },
  -- formatting.prettierd,

  require("none-ls.diagnostics.eslint_d").with {
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

  -- formatting.stylua.with {
  --   condition = function(utils)
  --     return utils.root_has_file 'stylua.toml'
  --       or utils.root_has_file '.stylua.toml'
  --   end,
  -- },

  formatting.stylua,
  formatting.gofmt,
  formatting.black,
  -- formatting.prettier,

  formatting.prettierd.with {
    env = {
      PRETTIERD_DEFAULT_CONFIG = vim.fn.expand(
        vim.fn.stdpath("config") .. "/lua/conf/prettier-config/.prettierrc.json"
      ),
    },
    -- extra_args = { "--no-semi", "--jsx-single-quote", "--print-width=80", "--use-tabs=2" },
  },

  -- code_actions.gitsigns,
  -- nls.builtins.code_actions.refactoring,
}

require("null-ls").setup {
  debug = true,
  sources = sources,
}
