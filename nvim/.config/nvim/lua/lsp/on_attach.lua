local U = require 'utils'

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  local function nmap(key, cmd, opts)
    U.buf_map('n', key, cmd, opts)
  end

  local function lua_nmap(key, cmd, opts)
    nmap(key, '<cmd>lua  ' .. cmd .. '<CR>', opts)
  end

  local function imap(key, cmd, opts)
    U.buf_map('i', key, cmd, opts)
  end

  local function lua_imap(key, cmd, opts)
    imap(key, '<cmd>lua  ' .. cmd .. '<CR>', opts)
  end

  --Enable completion triggered by <c-x><c-o>
  buf_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
    lua_nmap('K', 'vim.lsp.buf.hover()')
    lua_nmap('<leader>gd', 'vim.lsp.buf.definition()')
    lua_nmap('<leader>gD', 'vim.lsp.buf.declaration()')
    lua_nmap('<leader>gi', 'vim.lsp.buf.implementation()')
    lua_nmap('<leader>gr', 'TroubleToggle lsp_references')
    lua_nmap('<leader>ca', 'vim.lsp.buf.code_action()')
    lua_nmap('<leader>gh', 'vim.lsp.buf.signature_help()')
    lua_nmap('<leader>rn', 'vim.lsp.buf.rename()')
    lua_nmap('[d', 'vim.lsp.diagnostic.goto_prev()')
    lua_nmap(']d', 'vim.lsp.diagnostic.goto_next()')

  -- https://github.com/martinsione/dotfiles/blob/master/src/.config/nvim/lua/modules/config/nvim-lspconfig
  -- Only client with format capabilities is efm
  --if client.name ~= 'efm' then
   --client.resolved_capabilities.document_formatting = false
  --end

  -- Set autocommands conditional on server_capabilities
  if client.resolved_capabilities.document_formatting then
    vim.cmd([[
      augroup Format
      au! * <buffer>
      au BufWritePre <buffer> lua vim.lsp.buf.formatting_sync(nil, 1000)
      augroup END
    ]])
  end

end

return on_attach
