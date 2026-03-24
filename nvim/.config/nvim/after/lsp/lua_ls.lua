return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = {
    ".emmyrc.json",
    ".luarc.json",
    ".luarc.jsonc",
    ".luacheckrc",
    ".stylua.toml",
    "stylua.toml",
    "selene.toml",
    "selene.yml",
    ".git",
  },
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT", -- Best practice for Neovim/Luvit
      },
      codeLens = { enable = true },
      diagnostics = {
        -- 'vim' is omitted here because lazydev.nvim handles it better
        globals = { "use" },
        disable = { "missing-parameters", "missing-fields" },
      },
      workspace = {
        -- Prevents the "Do you want to configure your work environment as..." popups
        checkThirdParty = false,
        -- Tells the server where to look for library files
        library = {
          vim.env.VIMRUNTIME,
        },
      },
      telemetry = { enable = false },
    },
  },
  single_file_support = true,
}
