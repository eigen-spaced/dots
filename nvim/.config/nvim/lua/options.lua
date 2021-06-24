local fn = vim.fn -- to call Vim functions e.g. fn.bufnr()

local o = vim.o
local bo = vim.bo
local wo = vim.wo
local cmd = vim.api.nvim_command

local executable = function(e)
    return fn.executable(e) > 0
end
local opts_info = vim.api.nvim_get_all_options_info()
local opt = setmetatable({}, {
    __newindex = function(_, key, value)
        vim.o[key] = value
        local scope = opts_info[key].scope
        if scope == 'win' then
            vim.wo[key] = value
        elseif scope == 'buf' then
            vim.bo[key] = value
        end
    end,
})
local function add(value, str, sep)
    sep = sep or ','
    str = str or ''
    value = type(value) == 'table' and table.concat(value, sep) or value
    return str ~= '' and table.concat({ value, str }, sep) or value
  end

cmd('set iskeyword+=-') -- treat dash separated words as a word text object"
cmd('set shortmess+=c') -- Don't pass messages to |ins-completion-menu|.
cmd('set inccommand=split') -- Make substitution work in realtime
-- o.hidden = O.hidden_files -- Required to keep multiple buffers open multiple buffers
vim.cmd('set scrolloff=8')
vim.cmd('set sidescrolloff=5')

wo.number = true
wo.relativenumber = true

o.title = true
TERMINAL = vim.fn.expand('$TERMINAL')
cmd('let &titleold="'..TERMINAL..'"')
o.titlestring="%<%F%=%l/%L - nvim"
wo.wrap = true -- Display long lines as just one line
cmd('set whichwrap+=<,>,[,],h,l') -- move to next line with theses keys
cmd('syntax on') -- syntax highlighting
o.pumheight = 10 -- Makes popup menu smaller

o.fileencoding = 'utf-8' -- The encoding written to file
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

vim.go.t_Co = "256" -- Support 256 colors
-- vim.o.conceallevel = 0 -- So that I can see `` in markdown files

opt.expandtab = true -- Use spaces instead of tabs
opt.shiftwidth = 2 -- Size of an indent
opt.smartindent = true -- Insert indents automatically
opt.tabstop = 2 -- Number of spaces tabs count for
opt.softtabstop = 2

-- vim.wo.cursorline = true -- Enable highlighting of the current line
-- vim.o.showmode = false -- We don't need to see things like -- INSERT -- anymore
o.backup = false -- This is recommended by coc
o.writebackup = false -- This is recommended by coc
o.updatetime = 300 -- Faster completion
o.timeoutlen = 500 -- By default timeoutlen is 1000 ms
o.clipboard = "unnamedplus" -- Copy paste between vim and everything else
