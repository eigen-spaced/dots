local cmd = vim.cmd

require("core.utils")

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local custom_attach = function(client, bufnr)
  local function buf_option(...)
    vim.api.nvim_buf_set_option(bufnr, ...)
  end

  --Enable completion triggered by <c-x><c-o>
  buf_option("omnifunc", "v:lua.vim.lsp.omnifunc")

  local function map(mode, lhs, rhs)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr })
  end

  ----------- Mappings -----------
  map("n", "K", vim.lsp.buf.hover)
  map("n", "<leader>gD", vim.lsp.buf.declaration)
  map("n", "<leader>gd", vim.lsp.buf.definition)
  map("n", "<leader>D", vim.lsp.buf.type_definition)
  map("n", "<leader>gi", vim.lsp.buf.implementation)
  map("n", "<leader>ca", vim.lsp.buf.code_action)
  map("n", "<leader>gh", vim.lsp.buf.signature_help)

  -- RENAME
  map("n", "<leader>rn", vim.lsp.buf.rename)

  map("n", "[d", vim.lsp.diagnostic.goto_prev)
  map("n", "]d", vim.lsp.diagnostic.goto_next)

  map("n", "<leader>xx", "<cmd>Trouble<CR>")
  map("n", "<leader>gr", "<cmd>Trouble lsp_references<CR>")
  map("n", "<leader>wd", "<cmd>Trouble workspace_diagnostics<CR>")
  map("n", "<leader>dd", "<cmd>Trouble document_diagnostics<CR>")

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
