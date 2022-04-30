local fn = vim.fn
local set = vim.opt
local cmd = vim.cmd

local executable = function(e)
  return fn.executable(e) > 0
end

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
set.signcolumn = "yes:1" -- 'auto:1-2'
set.colorcolumn = "100"
set.cmdheight = 2 -- Set command line height to two lines

set.wrap = true
set.linebreak = true -- wrap, but on words, not randomly
-- set.textwidth = 80
set.synmaxcol = 1024 -- don't syntax highlight long lines
vim.g.vimsyn_embed = "lPr" -- allow embedded syntax highlighting for lua, python, ruby
set.showmode = false
set.lazyredraw = true
set.emoji = false -- turn off as they are treated as double width characters
set.list = true -- show invisible characters

--- This is used to handle markdown code blocks where the language might
--- be set to a value that isn't equivalent to a vim filetype
vim.g.markdown_fenced_languages = {
  "js=javascript",
  "ts=typescript",
  "shell=sh",
  "bash=sh",
  "console=sh",
}

set.listchars = {
  eol = " ",
  tab = "→ ",
  extends = "…",
  precedes = "…",
  trail = "·",
}
-- set.shortmess:append "I" -- disable :intro startup screen

-----------------------------------------------------------------------------//
-- Title {{{1
-----------------------------------------------------------------------------//
set.titlestring = "❐ %t"
set.titleold = '%{fnamemodify(getcwd(), ":t")}'
set.title = true
set.titlelen = 70

-----------------------------------------------------------------------------//
-- Folds {{{1
-----------------------------------------------------------------------------//
-- set.foldexpr = "nvim_treesitter#foldexpr()"
-- set.foldtext =
--   [[substitute(getline(v:foldstart),'\\t',repeat('\ ',&tabstop),'g').'...'.trim(getline(v:foldend)) ]]
-- -- set.foldopen:append { "search" }
-- -- set.foldlevelstart = 10
-- set.foldmethod = "expr"
-- -- set.fillchars = "fold:\\"
-- set.foldnestmax = 3
-- set.foldminlines = 1

-----------------------------------------------------------------------------//
-- Backup {{{1
-----------------------------------------------------------------------------//
set.swapfile = false
set.backup = false
set.writebackup = false
set.undofile = true -- Save undo history
set.confirm = true -- prompt to save before destructive actions
-- set.updatetime = 1000 -- cursor update and swapfile write time. Do not set to 0

-----------------------------------------------------------------------------//
-- Search {{{1
-----------------------------------------------------------------------------//
set.ignorecase = true -- Ignore case
set.smartcase = true -- Don't ignore case with capitals
set.wrapscan = true -- Search wraps at end of file
set.scrolloff = 5 -- Lines of context
set.sidescrolloff = 8 -- Columns of context
set.showmatch = true
set.inccommand = "nosplit"
cmd("set nohlsearch")

-- Use faster grep alternatives if possible
if executable("rg") then
  set.grepprg = [[rg --hidden --glob "!.git" --no-heading --smart-case --vimgrep --follow $*]]
  set.grepformat:prepend { "%f:%l:%c:%m" }
end

-----------------------------------------------------------------------------//
-- window splitting and buffers {{{1
-----------------------------------------------------------------------------//
set.hidden = true -- Enable modified buffers in background
set.splitbelow = true -- Put new windows below current
set.splitright = true -- Put new windows right of current
set.fillchars = {
  vert = "│",
  fold = " ",
  diff = "-", -- alternatives: ⣿ ░
  msgsep = "‾",
  foldopen = "▾",
  foldsep = "│",
  foldclose = "▸",
}

set.laststatus = 3

-- resize splits when Vim is resized
cmd("au VimResized * wincmd =")
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal"

-----------------------------------------------------------------------------//
-- Terminal {{{1
-----------------------------------------------------------------------------//
-- Open a terminal pane on the right using :Term
-- cmd [[command Term :botright vsplit term://$SHELL]]

-- Terminal visual tweaks
-- Enter insert mode when switching to terminal
-- Close terminal buffer on process exit
cmd([[
      autocmd TermOpen * setlocal listchars= nonumber norelativenumber nocursorline
      autocmd TermOpen * startinsert
      autocmd BufEnter,BufWinEnter,WinEnter term://* startinsert
      autocmd BufLeave term://* stopinsert
      autocmd TermClose term://* call nvim_input('<CR>')
      autocmd TermClose * call feedkeys("i")
    ]])

-----------------------------------------------------------------------------//
-- Mouse {{{1
-----------------------------------------------------------------------------//
set.mouse = "a"

-----------------------------------------------------------------------------//
-- Netrw {{{1
-----------------------------------------------------------------------------//
-- do not display info on the top of window
vim.g.netrw_banner = 0

-----------------------------------------------------------------------------//
-- Colorscheme {{{1
-----------------------------------------------------------------------------//
set.termguicolors = true

-- tokyonight config
vim.g.tokyonight_style = "night"
cmd("colorscheme kanagawa")
-- remove those awkward borders from between splits. Looking for a fix in the future
vim.api.nvim_set_hl(0, "WinSeparator", { bg = "None" })

-----------------------------------------------------------------------------//
-- }}}1
-----------------------------------------------------------------------------//
