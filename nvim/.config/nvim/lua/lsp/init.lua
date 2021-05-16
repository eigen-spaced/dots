USER = vim.fn.expand('$USER')

-- PYTHON
require('lspconfig').pyright.setup{
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true
      }
    }
  }
}

-- LUA
local HOME = os.getenv 'HOME'
local SYSTEM_NAME

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
        globals = {'vim'}
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = {
          [vim.fn.expand('$VIMRUNTIME/lua')] = true,
          [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true
        }
      }
    }
  }
}
