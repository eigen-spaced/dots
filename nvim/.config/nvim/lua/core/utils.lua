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

function U._echo_multiline(msg)
  for _, s in ipairs(vim.fn.split(msg, '\n')) do
    vim.cmd('echom \'' .. s:gsub('\'', '\'\'') .. '\'')
  end
end

function U.info(msg)
  vim.cmd 'echohl Directory'
  U._echo_multiline(msg)
  vim.cmd 'echohl None'
end

function U.warn(msg)
  vim.cmd 'echohl WarningU.g'
  U._echo_multiline(msg)
  vim.cmd 'echohl None'
end

function U.err(msg)
  vim.cmd 'echohl ErrorU.g'
  U._echo_multiline(msg)
  vim.cmd 'echohl None'
end

-- sudo write and execute within neovim
-- directly stolen from https://github.com/ibhagwan/nvim-lua/blob/main/lua/utils.lua#L307
U.sudo_exec = function(cmd, print_output)
  local password = vim.fn.inputsecret 'Password: '
  if not password or #password == 0 then
    U.warn 'Invalid password, sudo aborted'
    return false
  end
  local out = vim.fn.system(string.format('sudo -p \'\' -S %s', cmd), password)
  if vim.v.shell_error ~= 0 then
    print '\r\n'
    U.err(out)
    return false
  end
  if print_output then
    print('\r\n', out)
  end
  return true
end

U.sudo_write = function(tmpfile, filepath)
  if not tmpfile then
    tmpfile = vim.fn.tempname()
  end
  if not filepath then
    filepath = vim.fn.expand '%'
  end
  if not filepath or #filepath == 0 then
    U.err 'E32: No file name'
    return
  end
  -- `bs=1048576` is equivalent to `bs=1U. for GNU dd or `bs=1m` for BSD dd
  -- Both `bs=1U. and `bs=1m` are non-POSIX
  local cmd = string.format(
    'dd if=%s of=%s bs=1048576',
    vim.fn.shellescape(tmpfile),
    vim.fn.shellescape(filepath)
  )
  -- no need to check error as this fails the entire function
  vim.api.nvim_exec(string.format('write! %s', tmpfile), true)
  if U.sudo_exec(cmd) then
    U.info(string.format('\r\n"%s" written', filepath))
    vim.cmd 'e!'
  end
  vim.fn.delete(tmpfile)
end

return U
