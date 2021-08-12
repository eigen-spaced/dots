return function()
  local lspconfig = require 'lspconfig'
  local on_attach = require 'lsp.on_attach'

  USER = vim.fn.expand('$USER')
  local HOME = os.getenv 'HOME'
  local SYSTEM_NAME

  -- vim.cmd [[packadd nvim-lspconfig]]

  -- LUA
  if vim.fn.has 'mac' == 1 then
    SYSTEM_NAME = 'macOS'
  elseif vim.fn.has 'unix' == 1 then
    SYSTEM_NAME = 'Linux'
  end

  local sumneko_root_path = HOME .. '/dev/lua-language-server'
  local sumneko_binary = sumneko_root_path
    .. '/bin/'
    .. SYSTEM_NAME
    .. '/lua-language-server'

  require'lspconfig'.sumneko_lua.setup {
    cmd = { sumneko_binary, "-E", sumneko_root_path .. "/main.lua" },
    on_attach = on_attach,
    settings = {
      Lua = {
        runtime = {
          -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
          version = 'LuaJIT',
          -- Setup your lua path
          path = vim.split(package.path, ';')
        },
        diagnostics = {
          -- Get the language server to recognize the `vim` global
          globals = { 'vim' }
        },
        workspace = {
          -- Make the server aware of Neovim runtime files
          library = {
            [vim.fn.expand('$VIMRUNTIME/lua')] = true,
            [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true
          }
        },
        telemetry = { enable = false },
      }
    }
  }

  local servers = {}

  servers.bashls = {
    on_attach = function(client)
      on_attach(client)
    end
  }

  servers.vimls = {
    on_attach = function(client)
      on_attach(client)
    end,
  }

-- TYPESCRIPT
  -- https://github.com/theia-ide/typescript-language-server
  servers.tsserver = {
    on_attach = function(client)
      on_attach(client)
    end,
    filetypes = {
      "javascript",
      "javascriptreact",
      "javascript.jsx",
      "typescript",
      "typescriptreact",
      "typescript.tsx"
    },
  }

  -- CSS
  servers.cssls = {
    on_attach = function(client)
      on_attach(client)
    end,
  }

  -- HTML
  servers.html = {
    on_attach = function(client)
      on_attach(client)
    end,
  }

  -- PYTHON
  servers.pyright = {
    on_attach = function(client)
      on_attach(client)
    end,
  }

  -- HASKELL
  servers.hls = {
    on_attach = function(client)
      on_attach(client)
    end,
  }

  local efm = require 'lsp.efm'
  servers.efm = efm

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = { 'documentation', 'detail', 'additionalTextEdits' },
  }

  for server, config in pairs(servers) do
    lspconfig[server].setup(vim.tbl_deep_extend("force", { capabilities = capabilities }, config))
  end

end
