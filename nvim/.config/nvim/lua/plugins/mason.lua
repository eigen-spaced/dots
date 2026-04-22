return {
  {
    "mason-org/mason.nvim",
    providers = {
      "mason.providers.registry-api",
      "mason.providers.client",
    },
    build = ":MasonUpdate", -- :MasonUpdate updates registry contents
  },

  { "mason-org/mason-lspconfig.nvim" },
}
