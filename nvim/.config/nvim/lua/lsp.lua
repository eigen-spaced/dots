USER = vim.fn.expand('$USER')

local M = {}

function M.setup()
end

function M.config()
  local lspconfig = require 'lspconfig'
  local HOME = os.getenv 'HOME'
  local SYSTEM_NAME

  vim.cmd [[ packadd nvim-lspconfig ]]

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true

  -- EFM LANGUAGE SERVER
  -- 

  -- TYPESCRIPT
  -- https://github.com/theia-ide/typescript-language-server
	--[[
  lspconfig.tsserver.setup {
    on_attach = function(client)
      client.resolved_capabilities.document_formatting = false
      on_attach(client)
    end,
    capabilities = capabilities,
    flags = { debounce_text_changes = 500 },
    commands = {
      OrganizeImports = {
        function()
          local params = {
            command = '_typescript.organizeImports',
            arguments = { vim.api.nvim_buf_get_name(0) },
            title = '',
          }
          vim.lsp.buf.execute_command(params)
        end,
      },
    },
  }
	]]

  -- PYTHON
  lspconfig.pyright.setup{}

  -- HASKELL
  lspconfig.hls.setup{}

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
    cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"},
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
end

return M
