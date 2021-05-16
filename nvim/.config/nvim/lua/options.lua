local o = vim.o
local bo = vim.bo
local wo = vim.wo
local cmd = vim.api.nvim_command

cmd('set iskeyword+=-') -- treat dash separated words as a word text object"
cmd('set shortmess+=c') -- Don't pass messages to |ins-completion-menu|.
cmd('set inccommand=split') -- Make substitution work in realtime
-- o.hidden = O.hidden_files -- Required to keep multiple buffers open multiple buffers
vim.cmd('set scrolloff=8')
vim.cmd('set sidescrolloff=5')

wo.number = true -- set numbered lines
o.title = true
TERMINAL = vim.fn.expand('$TERMINAL')
cmd('let &titleold="'..TERMINAL..'"')
o.titlestring="%<%F%=%l/%L - nvim"
wo.wrap = true -- Display long lines as just one line
cmd('set whichwrap+=<,>,[,],h,l') -- move to next line with theses keys
cmd('syntax on') -- syntax highlighting
o.pumheight = 10 -- Makes popup menu smaller

o.fileencoding = "utf-8" -- The encoding written to file
o.cmdheight = 2 -- More space for displaying messages

-- To fix a neovim bug affecting indent-blankline
-- Related: https://github.com/lukas-reineke/indent-blankline.nvim/issues/59
wo.colorcolumn = "99999"

o.mouse = "a" -- Enable your mouse

o.splitbelow = true
o.splitright = true

-- Search options
o.hlsearch = true
o.ignorecase = true
o.smartcase = true

o.t_Co = "256" -- Support 256 colors
-- vim.o.conceallevel = 0 -- So that I can see `` in markdown files

bo.expandtab = true
bo.tabstop = 2
bo.softtabstop = 2 -- Change the number of space characters inserted for indentation
bo.shiftwidth = 2
bo.smartindent = true -- Makes indenting smart

wo.relativenumber = true -- set relative number
-- vim.wo.cursorline = true -- Enable highlighting of the current line
-- vim.o.showmode = false -- We don't need to see things like -- INSERT -- anymore
o.backup = false -- This is recommended by coc
o.writebackup = false -- This is recommended by coc
o.updatetime = 300 -- Faster completion
o.timeoutlen = 500 -- By default timeoutlen is 1000 ms
o.clipboard = "unnamedplus" -- Copy paste between vim and everything else
