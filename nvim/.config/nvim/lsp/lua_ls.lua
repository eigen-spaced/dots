-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/lua_ls.lua

return {
  cmd = {
    "lua-language-server",
  },
  root_markers = {
    ".git",
    ".luacheckrc",
    ".luarc.json",
    ".luarc.jsonc",
    ".stylua.toml",
    "selene.toml",
    "selene.yml",
    "stylua.toml",
  },
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim", "use", "require" },
        disable = { "missing-parameters", "missing-fields" },
      },
      telemetry = { enable = false },
    },
  },

  single_file_support = true,
  log_level = vim.lsp.protocol.MessageType.Warning,
}
