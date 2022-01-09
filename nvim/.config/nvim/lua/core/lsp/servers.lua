local custom_attach = require "core.lsp.custom_attach"

local servers = {}
local HOME = os.getenv "HOME"
local SYSTEM_NAME

if vim.fn.has "mac" == 1 then
  SYSTEM_NAME = "macOS"
elseif vim.fn.has "unix" == 1 then
  SYSTEM_NAME = "Linux"
end

-- LUA
local sumneko_binary = HOME
  .. "/dev/lua-language-server"
  .. "/bin/"
  .. SYSTEM_NAME
  .. "/lua-language-server"

servers.sumneko_lua = {
  on_attach = custom_attach,
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = "LuaJIT",
        -- Setup your lua path
        path = vim.split(package.path, ";"),
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = { "vim" },
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = {
          [vim.fn.expand "$VIMRUNTIME/lua"] = true,
          [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
        },
      },
      telemetry = { enable = false },
    },
  },
}

servers.tsserver = {
  on_attach = function(client, bufnr)
    client.resolved_capabilities.document_formatting = false

    local ts_utils = require "nvim-lsp-ts-utils"

    -- defaults
    ts_utils.setup {
      debug = false,
      disable_commands = false,
      enable_import_on_completion = true,

      -- eslint
      eslint_enable_code_actions = true,
      eslint_enable_disable_comments = true,
      eslint_bin = "eslint_d",
      eslint_config_fallback = nil,
      eslint_enable_diagnostics = true,

      -- formatting
      enable_formatting = true,
      formatter = "prettierd",
      formatter_config_fallback = nil,

      -- parentheses completion
      complete_parens = false,
      signature_help_in_parens = false,

      -- update imports on file move
      update_imports_on_move = false,
      require_confirmation_on_move = false,
      watch_dir = nil,
    }

    -- required to fix code action ranges
    ts_utils.setup_client(client)

    custom_attach(client, bufnr)
  end,
}

servers.bashls = {
  on_attach = function(client, bufnr)
    custom_attach(client, bufnr)
  end,
}

servers.vimls = {
  on_attach = function(client, bufnr)
    custom_attach(client, bufnr)
  end,
}

servers.cssls = {
  on_attach = function(client, bufnr)
    client.resolved_capabilities.document_formatting = false
    custom_attach(client, bufnr)
  end,
}

-- HTML
servers.html = {
  -- cmd = { 'html languageserver', '--stdio' },
  on_attach = function(client, bufnr)
    client.resolved_capabilities.document_formatting = false
    custom_attach(client, bufnr)
  end,
}

-- PYTHON
servers.pyright = {
  on_attach = function(client, bufnr)
    custom_attach(client, bufnr)
  end,
}

-- GOPLS
servers.gopls = {
  on_attach = function(client, bufnr)
    custom_attach(client, bufnr)
  end,
  flags = { debounce_text_changes = 150 },
}

-- HASKELL
servers.hls = {
  on_attach = function(client, bufnr)
    client.resolved_capabilities.document_formatting = false
    custom_attach(client, bufnr)
  end,
}

return servers
