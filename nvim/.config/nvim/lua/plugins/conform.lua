return {
  "stevearc/conform.nvim",
  opts = {},
  config = function()
    require("conform").setup {
      formatters_by_ft = {
        cpp = { "clang-format" },
        c = { "clang-format" },
        lua = { "stylua" },
        go = { "goimports", "gofmt" },
        python = {
          "ruff_fix",
          "ruff_format",
          "ruff_organize_imports",
        },
        rust = { "rustfmt", lsp_format = "fallback" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = {
          "prettierd",
          "prettier",
          stop_after_first = true,
        },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = {
          "prettierd",
          "prettier",
          stop_after_first = true,
        },
        vue = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd", "prettier", stop_after_first = true },
        astro = { "prettierd", "prettier", stop_after_first = true },
      },
      formatters = {
        ["clang-format"] = {
          command = "/opt/homebrew/opt/llvm/bin/clang-format",
        },
        prettierd = {
          env = {
            PRETTIERD_DEFAULT_CONFIG = vim.fn.expand(
              vim.fn.stdpath("config")
                .. "/lua/conf/envconfig/.prettierrc.json"
            ),
          },
        },
      },
    }
  end,
}
