--- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/biome.lua

local util = require("lspconfig.util")

return {
  cmd = { "biome", "lsp-proxy" },
  filetypes = {
    "astro",
    "css",
    "graphql",
    "html",
    "javascript",
    "javascriptreact",
    "json",
    "jsonc",
    "svelte",
    "typescript",
    "typescript.tsx",
    "typescriptreact",
    "vue",
  },
  workspace_required = true,

  root_dir = function(bufnr, on_dir)
    local global_biome_config =
      vim.fn.expand(vim.fn.stdpath("config") .. "/lua/conf/envconfig") -- fallback config
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local root_files = { "biome.json", "biome.jsonc" }
    root_files = util.insert_package_json(root_files, "biome", fname)

    local found = vim.fs.find(root_files, { path = fname, upward = true })[1]
    local root_dir

    if found then
      root_dir = vim.fs.dirname(found)
    else
      root_dir = global_biome_config
    end

    on_dir(root_dir)
  end,
}
