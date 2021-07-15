local cmd = vim.cmd -- execute vim commands
local fn = vim.fn -- call vim functions
local opt = vim.opt

local execute = vim.api.nvim_command

local U = require 'utils'

-- Bootstrap packer
local install_path = fn.stdpath 'data' ..'/site/pack/packer/start/packer.nvim'

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

  use 'neovim/nvim-lspconfig'

  use {
    'karb94/neoscroll.nvim',
    config = function() require'neoscroll'.setup() end
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


require 'lsp'

vim.g.mapleader = ' '

-- kommentary defaults
vim.g.kommentary_create_default_mappings = false

U.map("n", "<leader>c", "<Plug>kommentary_motion_default")
U.map("n", "<leader>cc", "<Plug>kommentary_line_default")
U.map("v", "<leader>c", "<Plug>kommentary_visual_default")


-----------------------------------------------------------------------------//
-- Indentation {{{1
-----------------------------------------------------------------------------//
opt.expandtab = true -- Use spaces instead of tabs
opt.shiftwidth = 2 -- Size of an indent
opt.tabstop = 2 -- Number of spaces tabs count for
opt.softtabstop = 2
opt.smartindent = true -- Insert indents automatically
opt.shiftround = true -- Round indent
opt.joinspaces = false -- No double spaces with join after a dot

-----------------------------------------------------------------------------//
-- Display {{{1
-----------------------------------------------------------------------------//
opt.number = true -- Print line number
opt.relativenumber = true -- Relative line numbers
opt.numberwidth = 2
opt.signcolumn = 'yes:1' -- 'auto:1-2'

opt.wrap = true
opt.linebreak = true -- wrap, but on words, not randomly
-- opt.textwidth = 80
opt.synmaxcol = 1024 -- don't syntax highlight long lines
vim.g.vimsyn_embed = 'lPr' -- allow embedded syntax highlighting for lua, python, ruby
opt.showmode = false
opt.lazyredraw = true
opt.emoji = false -- turn off as they are treated as double width characters
opt.list = true -- show invisible characters

opt.listchars = {
    eol = ' ',
    tab = '→ ',
    extends = '…',
    precedes = '…',
    trail = '·',
}
opt.shortmess:append 'I' -- disable :intro startup screen

-----------------------------------------------------------------------------//
-- Title {{{1
-----------------------------------------------------------------------------//
opt.titlestring = '❐ %t'
opt.titleold = '%{fnamemodify(getcwd(), ":t")}'
opt.title = true
opt.titlelen = 70

-----------------------------------------------------------------------------//
-- Folds {{{1
-----------------------------------------------------------------------------//
opt.foldtext = 'folds#render()'
opt.foldopen:append { 'search' }
opt.foldlevelstart = 10
opt.foldmethod = 'syntax'
-- opt.foldmethod = 'expr'
-- opt.foldexpr='nvim_treesitter#foldexpr()'

-----------------------------------------------------------------------------//
-- Backup {{{1
-----------------------------------------------------------------------------//
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.undofile = true -- Save undo history
opt.confirm = true -- prompt to save before destructive actions

-----------------------------------------------------------------------------//
-- Search {{{1
-----------------------------------------------------------------------------//
opt.ignorecase = true -- Ignore case
opt.smartcase = true -- Don't ignore case with capitals
opt.wrapscan = true -- Search wraps at end of file
opt.scrolloff = 5 -- Lines of context
opt.sidescrolloff = 8 -- Columns of context
opt.showmatch = true

-- Use faster grep alternatives if possible
if executable 'rg' then
    opt.grepprg =
        [[rg --hidden --glob "!.git" --no-heading --smart-case --vimgrep --follow $*]]
    opt.grepformat:prepend { '%f:%l:%c:%m' }
end

-----------------------------------------------------------------------------//
-- window splitting and buffers {{{1
-----------------------------------------------------------------------------//
opt.hidden = true -- Enable modified buffers in background
opt.splitbelow = true -- Put new windows below current
opt.splitright = true -- Put new windows right of current
opt.fillchars = {
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
opt.mouse = 'a'

-----------------------------------------------------------------------------//
-- Netrw {{{1
-----------------------------------------------------------------------------//
-- do not display info on the top of window
vim.g.netrw_banner = 0

-----------------------------------------------------------------------------//
-- Colorscheme {{{1
-----------------------------------------------------------------------------//
opt.termguicolors = true

-----------------------------------------------------------------------------//
-- Keymaps {{{1
-----------------------------------------------------------------------------//
-- unmap any functionality tied to space
U.map('n', '<Space>', '<NOP>')

-- Toggle highlighting
-- U.map('n', '<Leader>h', '<cmd>set hlsearch!<CR>')

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
U.map('n', '<Leader>j', ':move+1<CR>==')
U.map('n', '<Leader>k', ':move-2<CR>==')

U.map('x', 'K', '<cmd>move \'<-2<CR>gv-gv')
U.map('x', 'J', '<cmd>move \'>+1<CR>gv-gv')

-- Sensible defaults
-- from https://github.com/disrupted/dotfiles/blob/master/.config/nvim/init.lua
U.map('', 'Q', '') -- disable Q for ex mode
-- U.map('n', 'x', '"_x') --delete char without yank
-- U.map('x', 'x', '"_x') -- delete visual selection without yank

-----------------------------------------------------------------------------//
-- }}}1
-----------------------------------------------------------------------------//
