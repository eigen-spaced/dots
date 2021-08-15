local U = {}

-- mappings
function U.map(mode, key, cmd, opts)
    local options = { noremap = true, silent = true }
    if opts then
        options = vim.tbl_extend('force', options, opts)
    end
    vim.api.nvim_set_keymap(mode, key, cmd, options)
end

function U.nmap(key, cmd, opts)
  U.map('n', key, cmd, opts)
end


function U.imap(key, cmd, opts)
  U.map('i', key, cmd, opts)
end

function U.vmap(key, cmd, opts)
  U.map('v', key, cmd, opts)
end

function U.buf_map(mode, key, cmd, opts)
    local options = { noremap = true, silent = true }
    if opts then
        options = vim.tbl_extend('force', options, opts)
    end
    vim.api.nvim_buf_set_keymap(0, mode, key, cmd, options)
end

function U.is_buffer_empty()
    -- Check whether the current buffer is empty
    return vim.fn.empty(vim.fn.expand '%:t') == 1
end

function U.has_width_gt(cols)
    -- Check if the windows width is greater than a given number of columns
    return vim.fn.winwidth(0) / 2 > cols
end

return U
