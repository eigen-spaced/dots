local cmd = vim.cmd -- execute vim commands

local U = require 'utils'
local nmap = U.nmap
local imap = U.imap

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  --Enable completion triggered by <c-x><c-o>
  buf_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
    nmap('K', '<cmd>lua vim.lsp.buf.hover()<CR>')
    nmap('<leader>gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
    nmap('<leader>gD', '<cmd>lua vim.lsp.buf.declaration()<CR>')
    nmap('<leader>gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
    nmap('<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>')
    nmap('<leader>gh', '<cmd>lua vim.lsp.buf.signature_help()<CR>')
    nmap('<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>')
    nmap('[d', 'vim.lsp.diagnostic.goto_prev()<CR>')
    nmap(']d', 'vim.lsp.diagnostic.goto_next()<CR>')

    nmap('<leader>gr', '<cmd>Trouble lsp_references<CR>')
    nmap('<leader>wd', '<cmd>Trouble lsp_workspace_diagnostics<CR>')
    nmap('<leader>dd', '<cmd>Trouble lsp_document_diagnostics<CR>')

  -- https://github.com/martinsione/dotfiles/blob/master/src/.config/nvim/lua/modules/config/nvim-lspconfig
  -- Only client with format capabilities is efm
  if client.name ~= 'efm' then
   client.resolved_capabilities.document_formatting = false
  end

  --[[
  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
      virtual_text = false,
      underline = true,
      signs = true,
    }
  )
  vim.cmd [[autocmd CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics()]]
  -- vim.cmd [[autocmd CursorHoldI * silent! lua vim.lsp.buf.signature_help()]]

  -- Set autocommands conditional on server_capabilities
  if client.resolved_capabilities.document_formatting then
    cmd [[
        augroup Format
        au! * <buffer>
        au BufWritePre <buffer> lua vim.lsp.buf.formatting_sync(nil, 1000)
        augroup END
    ]]
  end

end

return on_attach
