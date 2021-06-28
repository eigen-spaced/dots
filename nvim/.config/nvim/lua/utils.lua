local U = {}

function U.map(mode, key, result, opts)
  -- Convienent Key mapping function
  opts = opts or {}

  vim.api.nvim_set_keymap(mode, key, result, opts)
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
