local cmd = vim.cmd -- execute vim commands
local fn = vim.fn -- call vim functions
local set = vim.opt

local execute = vim.api.nvim_command

local U = require 'utils'

-- Bootstrap packer
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path})
  execute 'packadd packer.nvim'
end

local packer = require 'packer'
local use = packer.use

packer.startup(function ()
  use { 'wbthomason/packer.nvim', opt = true }

 use {
    'kyazdani42/nvim-tree.lua',
    opt = true,
    cmd = { 'NvimTreeOpen', 'NvimTreeToggle' },
    setup = require('nv-tree').setup,
    config = require('nv-tree').config,
    requires = { 'kyazdani42/nvim-web-devicons', opt = true },
  }

  use {
    'hrsh7th/nvim-compe',
    event = { 'InsertEnter' },
    config = require('nv-compe').config,
    -- after = 'LuaSnip',
  }

  use {
    'neovim/nvim-lspconfig',
    -- opt = true,
    event = { 'BufRead' },
    config = require('lsp').config,
  }

  use {
    'ray-x/navigator.lua',
    event = { 'BufRead', 'BufWrite' },
    config = require('nv-navigator').config,
    requires = {'ray-x/guihua.lua', run = 'cd lua/fzy && make'}
  }

  use {
    'karb94/neoscroll.nvim',
    config = function() require'neoscroll'.setup() end
  }

  use {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = require('nv-gitsigns').config,
    requires = { 'nvim-lua/plenary.nvim' }
  }

  use 'tpope/vim-eunuch'
  use 'tpope/vim-surround'
  use 'tpope/vim-fugitive'

  use {
    'shaunsingh/moonlight.nvim',
    config = require('colorscheme').config
  }

  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    config = require('tree-sitter').config
  }

  use {
    'nvim-telescope/telescope.nvim',
    event = { 'VimEnter' },
    setup = require('nv-telescope').setup,
    config = require('nv-telescope').config,
    requires = { {'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'} },
  }

  use 'b3nj5m1n/kommentary'

  use {
    'famiu/bufdelete.nvim',
    cmd = { 'Bdelete', 'Bwipeout' },
  }
end)

local executable = function(e)
    return fn.executable(e) > 0
end


vim.g.mapleader = ' '

-- kommentary defaults
vim.g.kommentary_create_default_mappings = false

U.map("n", "<leader>c", "<Plug>kommentary_motion_default")
U.map("n", "<leader>cc", "<Plug>kommentary_line_default")
U.map("v", "<leader>c", "<Plug>kommentary_visual_default")


-----------------------------------------------------------------------------//
-- Indentation {{{1
-----------------------------------------------------------------------------//
set.expandtab = true -- Use spaces instead of tabs
set.shiftwidth = 2 -- Size of an indent
set.tabstop = 2 -- Number of spaces tabs count for
set.softtabstop = 2
set.smartindent = true -- Insert indents automatically
set.shiftround = true -- Round indent
set.joinspaces = false -- No double spaces with join after a dot

-----------------------------------------------------------------------------//
-- Display {{{1
-----------------------------------------------------------------------------//
set.number = true -- Display line number
set.relativenumber = true -- Relative line numbers
set.numberwidth = 2
set.signcolumn = 'yes:1' -- 'auto:1-2'

set.wrap = true
set.linebreak = true -- wrap, but on words, not randomly
-- set.textwidth = 80
set.synmaxcol = 1024 -- don't syntax highlight long lines
vim.g.vimsyn_embed = 'lPr' -- allow embedded syntax highlighting for lua, python, ruby
set.showmode = false
set.lazyredraw = true
set.emoji = false -- turn off as they are treated as double width characters
set.list = true -- show invisible characters

set.listchars = {
    eol = ' ',
    tab = '→ ',
    extends = '…',
    precedes = '…',
    trail = '·',
}
set.shortmess:append 'I' -- disable :intro startup screen

-----------------------------------------------------------------------------//
-- Title {{{1
-----------------------------------------------------------------------------//
set.titlestring = '❐ %t'
set.titleold = '%{fnamemodify(getcwd(), ":t")}'
set.title = true
set.titlelen = 70

-----------------------------------------------------------------------------//
-- Folds {{{1
-----------------------------------------------------------------------------//
set.foldtext = 'folds#render()'
set.foldopen:append { 'search' }
set.foldlevelstart = 10
set.foldmethod = 'syntax'
-- set.foldmethod = 'expr'
-- set.foldexpr='nvim_treesitter#foldexpr()'

-----------------------------------------------------------------------------//
-- Backup {{{1
-----------------------------------------------------------------------------//
set.swapfile = false
set.backup = false
set.writebackup = false
set.undofile = true -- Save undo history
set.confirm = true -- prompt to save before destructive actions

-----------------------------------------------------------------------------//
-- Search {{{1
-----------------------------------------------------------------------------//
set.ignorecase = true -- Ignore case
set.smartcase = true -- Don't ignore case with capitals
set.wrapscan = true -- Search wraps at end of file
set.scrolloff = 5 -- Lines of context
set.sidescrolloff = 8 -- Columns of context
set.showmatch = true

-- Use faster grep alternatives if possible
if executable 'rg' then
    set.grepprg =
        [[rg --hidden --glob "!.git" --no-heading --smart-case --vimgrep --follow $*]]
    set.grepformat:prepend { '%f:%l:%c:%m' }
end

-----------------------------------------------------------------------------//
-- window splitting and buffers {{{1
-----------------------------------------------------------------------------//
set.hidden = true -- Enable modified buffers in background
set.splitbelow = true -- Put new windows below current
set.splitright = true -- Put new windows right of current
set.fillchars = {
    vert = '│',
    fold = ' ',
    diff = '-', -- alternatives: ⣿ ░
    msgsep = '‾',
    foldopen = '▾',
    foldsep = '│',
    foldclose = '▸',
}

-----------------------------------------------------------------------------//
-- Terminal {{{1
-----------------------------------------------------------------------------//
-- Open a terminal pane on the right using :Term
-- cmd [[command Term :botright vsplit term://$SHELL]]

-- Terminal visual tweaks
-- Enter insert mode when switching to terminal
-- Close terminal buffer on process exit
cmd [[
    autocmd TermOpen * setlocal listchars= nonumber norelativenumber nocursorline
    autocmd TermOpen * startinsert
    autocmd BufEnter,BufWinEnter,WinEnter term://* startinsert
    autocmd BufLeave term://* stopinsert
    autocmd TermClose term://* call nvim_input('<CR>')
    autocmd TermClose * call feedkeys("i")
]]


-----------------------------------------------------------------------------//
-- Mouse {{{1
-----------------------------------------------------------------------------//
set.mouse = 'a'

-----------------------------------------------------------------------------//
-- Netrw {{{1
-----------------------------------------------------------------------------//
-- do not display info on the top of window
vim.g.netrw_banner = 0

-----------------------------------------------------------------------------//
-- Colorscheme {{{1
-----------------------------------------------------------------------------//
set.termguicolors = true

-----------------------------------------------------------------------------//
-- Keymaps {{{1
-----------------------------------------------------------------------------//
-- unmap any functionality tied to space
U.map('n', '<Space>', '<NOP>')

-- Toggle highlighting
U.map('n', '<leader><leader>h', '<cmd>set hlsearch!<CR>')

U.map('i', 'jk', '<Esc>')
U.map('i', 'kj', '<Esc>')

-- Better split navigation
U.map('n', '<C-h>', '<C-w>h')
U.map('n', '<C-j>', '<C-w>j')
U.map('n', '<C-k>', '<C-w>k')
U.map('n', '<C-l>', '<C-w>l')

U.map('n', '<Leader>o', 'o<Esc>k')
U.map('n', '<Leader>O', 'O<Esc>j')

-- Better indenting
U.map('v', '<', '<gv')
U.map('v', '>', '>gv')

-- Buffer management
U.map('n', '<Tab>', '<cmd>bnext<CR>')
U.map('n', '<S-Tab>', '<cmd>bprev<CR>')

U.map('n', '<Leader>bk', '<cmd>Bdelete<CR>',{ silent = true })

-- Exit terminal using easier keybindings
U.map('t', 'jk', '<C-\\><C-n>')

-- Source lua.init
U.map('n', '<leader>si', '<cmd>luafile ~/.config/nvim/init.lua<CR>', { silent = true })
-- Source current lua file
U.map('n', '<leader>so', '<cmd>luafile %<CR>', { noremap = false })

-- Auto closing brackets
U.map('i', '(;', '(<CR>);<C-c>O')
U.map('i', '{;', '{<CR>};<C-c>O')
U.map('i', '{;', '{<CR>};<C-c>O')
U.map('i', '[;', '[<CR>];<C-c>O')
U.map('i', '[;', '[<CR>];<C-c>O')

U.map('i', '{<Space>', '{<Space><Space>}<C-c>hi')
U.map('i', '[<Space>', '[<Space><Space>]<C-c>hi')

U.map('i', '{<CR>', '{<CR>}<C-c>O')
U.map('i', '(<CR>', '(<CR>)<C-c>O')

-- Line bubbling
U.map('v', 'J', '<cmd>move \'>+1<CR>gv=gv', { noremap = true })
U.map('v', 'K', '<cmd>move \'<-2<CR>gv=gv', { noremap = true })
U.map('i', '<C-j>', '<cmd>move .+1<CR><esc>==a', { noremap = true })
U.map('i', '<C-k>', '<cmd>move .-2<CR><esc>==a', { noremap = true })
U.map('n', '<leader>j', '<cmd>move .+1<CR>==', { noremap = true })
U.map('n', '<leader>k', '<cmd>move .-2<CR>==', { noremap = true })

-- Close readonly buffers with q
U.map('n', 'q', '&readonly ? \':close!<CR>\' : \'q\'', { expr = true, noremap = true })

-- Sensible defaults
-- from https://github.com/disrupted/dotfiles/blob/master/.config/nvim/init.lua
U.map('', 'Q', '') -- disable Q for ex mode
U.map('', 'q:', '') -- disable Q for ex mode
-- U.map('n', 'x', '"_x') --delete char without yank
-- U.map('x', 'x', '"_x') -- delete visual selection without yank
--
U.map('n', 'Y', 'y$', { noremap = true })

U.map('i', ',', ',<C-g>u', { noremap = true })
U.map('i', '.', '.<C-g>u', { noremap = true })
U.map('i', '!', '!<C-g>u', { noremap = true })
U.map('i', '(', '(<C-g>u', { noremap = true })
-----------------------------------------------------------------------------//
-- }}}1
-----------------------------------------------------------------------------//
