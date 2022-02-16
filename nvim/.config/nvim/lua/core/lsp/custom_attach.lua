local cmd = vim.cmd -- execute vim commands

local nmap = require("core.utils").nmap

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local custom_attach = function(client, bufnr)
  local function buf_option(...)
    vim.api.nvim_buf_set_option(bufnr, ...)
  end

  --Enable completion triggered by <c-x><c-o>
  buf_option("omnifunc", "v:lua.vim.lsp.omnifunc")

  ----------- Mappings -----------
  nmap("K", "<cmd>lua vim.lsp.buf.hover()<CR>")

  nmap("<leader>gD", "<cmd>lua vim.lsp.buf.declaration()<CR>")

  nmap("<leader>gd", "<cmd>lua vim.lsp.buf.definition()<CR>")

  nmap("<leader>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>")

  nmap("<leader>gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")

  nmap("<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>")

  nmap("<leader>gh", "<cmd>lua vim.lsp.buf.signature_help()<CR>")

  -- RENAME
  nmap("<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>")

  nmap("[d", "vim.lsp.diagnostic.goto_prev()<CR>")
  nmap("]d", "vim.lsp.diagnostic.goto_next()<CR>")

  nmap("<leader>xx", "<cmd>Trouble<CR>")
  nmap("<leader>gr", "<cmd>Trouble lsp_references<CR>")
  nmap("<leader>wd", "<cmd>Trouble workspace_diagnostics<CR>")
  nmap("<leader>dd", "<cmd>Trouble document_diagnostics<CR>")

  cmd([[ command! Format execute 'lua vim.lsp.buf.formatting()' ]])

  -- cmd [[autocmd CursorHold,CursorHoldI <buffer> lua show_diagnostics()]]
  -- cmd [[autocmd CursorHoldI <buffer> silent! lua vim.lsp.buf.signature_help()]]

  -- Set autocommands conditional on server_capabilities
  if client.resolved_capabilities.document_formatting then
    cmd([[
          augroup Format
            autocmd! * <buffer>
            autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync(nil, 1000)
          augroup END
        ]])
  end

  if client.resolved_capabilities.document_highlight then
    cmd([[
          augroup lsp_document_highlight
            autocmd! * <buffer>
            autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
            autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
          augroup END
        ]])
  end
end

return custom_attach
