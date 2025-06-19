-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/vue_ls.lua

return {
  cmd = { "vue-language-server", "--stdio" },
  filetypes = { "vue" },
  root_markers = { "package.json" },
  -- https://github.com/vuejs/language-tools/blob/v2/packages/language-server/lib/types.ts
  init_options = {
    typescript = {
      tsdk = "",
    },
  },
}
