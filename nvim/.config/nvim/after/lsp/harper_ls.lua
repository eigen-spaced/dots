-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/harper_ls.lua

return {
  cmd = { "harper-ls", "--stdio" },
  filetypes = { "markdown", "text", "gitcommit" },
  settings = {
    ["harper-ls"] = {
      linters = {
        SentenceCapitalization = false,
        LongSentences = false,
      },
      markdown = { IgnoreLinkTitle = false },
      isolateEnglish = false,
      dialect = "British",
    },
  },
}
