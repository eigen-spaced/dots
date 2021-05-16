local U = require 'utils'

-- set <Space> as Leader
vim.g.mapleader = ' '

-- unmap any functionality to space
U.map('n', '<Space>', '<NOP>')

-- Toggle highlighting
U.map('n', '<Leader>h', ':set hlsearch!<CR>')

U.map('i', 'jk', '<Esc>')
U.map('i', 'kj', '<Esc>')

-- Better split navigation
U.map('n', '<C-h>', '<C-w>h')
U.map('n', '<C-j>', '<C-w>j')
U.map('n', '<C-k>', '<C-w>k')
U.map('n', '<C-l>', '<C-w>l')

U.map('n', '<Leader>o', 'o<Esc>k', { silent = false })
U.map('n', '<Leader>O', 'O<Esc>j', { silent = false })

-- Better indenting
U.map('v', '<', '<gv')
U.map('v', '>', '>gv')

-- Buffer management
U.map('n', '<Tab>', ':bnext<CR>')
U.map('n', '<S-Tab>', ':bprev<CR>')

U.map('n', '<Leader>bk', ':bw<CR>')

-- Exit terminal using easier keybindings
U.map('t', 'jk', '<C-\\><C-n>')

-- Source lua.init
U.map('n', '<leader>si', ':luafile ~/.config/nvim/init.lua<CR>', { silent = true })
-- Source current lua file
U.map('n', '<leader>so', ':luafile %<CR>', { noremap = false })

-- Nvim tree
U.map('n', '<leader>e', ':NvimTreeToggle<CR>')

-- Auto closing brackets
U.map('i', '(;', '(<CR>);<C-c>O')
U.map('i', '{;', '{<CR>};<C-c>O')
U.map('i', '{;', '{<CR>};<C-c>O')
U.map('i', '[;', '[<CR>];<C-c>O')
U.map('i', '[;', '[<CR>];<C-c>O')


U.map('i', '{<CR>', '{<CR>}<C-c>O')
U.map('i', '(<CR>', '(<CR>)<C-c>O')

-- Line bubbling
U.map('n', '<Leader>j', ':move+1<CR>==')
U.map('n', '<Leader>k', ':move-2<CR>==')

U.map('x', 'K', ':move \'<-2<CR>gv-gv')
U.map('x', 'J', ':move \'>+1<CR>gv-gv')

