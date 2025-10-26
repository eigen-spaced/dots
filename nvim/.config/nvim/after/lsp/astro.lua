--- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/astro.lua

return {
  cmd = { "astro-ls", "--stdio" },
  filetypes = { "astro" },
  root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
  init_options = {
    typescript = {},
  },
}
