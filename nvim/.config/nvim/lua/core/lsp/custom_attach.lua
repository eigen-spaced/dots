local cmd = vim.cmd -- execute vim commands

require("core.utils")

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local custom_attach = function(client, bufnr)
  local function buf_option(...)
    vim.api.nvim_buf_set_option(bufnr, ...)
  end

  --Enable completion triggered by <c-x><c-o>
  buf_option("omnifunc", "v:lua.vim.lsp.omnifunc")

  ----------- Mappings -----------
  nmap("K", "<cmd>lua vim.lsp.buf.hover()<CR>", nil, bufnr)

  nmap("<leader>gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", nil, bufnr)

  nmap("<leader>gd", "<cmd>lua vim.lsp.buf.definition()<CR>", nil, bufnr)

  nmap("<leader>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", nil, bufnr)

  nmap("<leader>gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", nil, bufnr)

  nmap("<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", nil, bufnr)

  nmap("<leader>gh", "<cmd>lua vim.lsp.buf.signature_help()<CR>", nil, bufnr)

  -- RENAME
  nmap("<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", nil, bufnr)

  nmap("[d", "vim.lsp.diagnostic.goto_prev()<CR>", nil, bufnr)
  nmap("]d", "vim.lsp.diagnostic.goto_next()<CR>", nil, bufnr)

  nmap("<leader>xx", "<cmd>Trouble<CR>", nil, bufnr)
  nmap("<leader>gr", "<cmd>Trouble lsp_references<CR>", nil, bufnr)
  nmap("<leader>wd", "<cmd>Trouble workspace_diagnostics<CR>", nil, bufnr)
  nmap("<leader>dd", "<cmd>Trouble document_diagnostics<CR>", nil, bufnr)

  cmd([[ command! Format execute 'lua vim.lsp.buf.formatting()' ]])

  -- cmd([[autocmd CursorHold,CursorHoldI <buffer> lua show_diagnostics()]])
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
