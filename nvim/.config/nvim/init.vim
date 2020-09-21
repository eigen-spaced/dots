syntax enable

" Filetype indentation rules
filetype plugin indent on

autocmd FileType html setlocal shiftwidth=2 softtabstop=2 expandtab
autocmd FileType css setlocal shiftwidth=2 softtabstop=2 expandtab
autocmd FileType javascript setlocal  shiftwidth=2 softtabstop=2 expandtab
autocmd FileType json setlocal shiftwidth=2 softtabstop=2 expandtab

set noerrorbells
set nu rnu
set tabstop=4 softtabstop=4
set shiftwidth=4
set smartindent
set autoindent
set splitbelow
set splitright
set wrap
set smartcase
set colorcolumn=81

set splitright
set splitbelow

set noswapfile
set laststatus=2
set scrolloff=8
set sidescrolloff=5
set title

let mapleader=" "

set nohlsearch " Turn off search highlighting

call plug#begin('~/.config/nvim/plugged/')
	Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
	Plug 'junegunn/fzf.vim'

	Plug 'preservim/nerdtree'
	Plug 'sheerun/vim-polyglot'

	" dracula theme for nvim
	Plug 'dracula/vim'

	if (has("termguicolors"))
		set termguicolors
	endif
	colorscheme dracula

	Plug 'pangloss/vim-javascript'
	Plug 'leafgarland/typescript-vim'
	Plug 'peitalin/vim-jsx-typescript'
	Plug 'neoclide/coc.nvim', {'branch': 'release'}
	Plug 'tpope/vim-surround'
" nvim root write and read privileges
	Plug 'lambdalisue/suda.vim'
call plug#end()

" SudaWrite (for sudo read and write)
let g:suda#prompt = 'Enter password beep boop: '

" NERDTree config
let g:NERDTreeShowHidden = 1
let g:NERDTreeMinimalUI = 1
let g:NERDTreeIgnore = []
let g:NERDTreeStatusline = ''
" Automaticaly close nvim if NERDTree is only thing left open
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") &&
			\ b:NERDTree.isTabTree()) | q | endif

" Toggle
nnoremap <silent> <leader>n :NERDTreeToggle<CR>

" fzf
nnoremap <silent> <C-p> :Files<CR>
nnoremap <silent> <C-g> :GFiles<CR>
nnoremap <silent> <C-o> :Buffers<CR>
" Pulls file search in full screen with the (!)
nnoremap <C-o> :Rg! 

" coc.nvim config
let g:coc_global_extensions = [
	\'coc-emmet',
	\'coc-css',
	\'coc-eslint',
	\'coc-html',
	\'coc-json',
	\'coc-prettier',
	\'coc-tsserver',
	\'coc-python',
	\'coc-java'
\]

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Give more space for displaying messages.
set cmdheight=1

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

noremap <silent><expr> <c-space> coc#refresh()

" gd - go to definition of word under cursor
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)

" gi - go to implementation
nmap <silent> gi <Plug>(coc-implementation)

" gr - find references
nmap <silent> gr <Plug>(coc-references)

" gh - get hint on whatever's under the cursor
nnoremap <silent> K :call <SID>show_documentation()<CR>
nnoremap <silent> gh :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if &filetype == 'vim'
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

nnoremap <silent> <leader>co  :<C-u>CocList outline<cr>
nnoremap <silent> <leader>cs  :<C-u>CocList -I symbols<cr>

" List errors
nnoremap <silent> <leader>cl  :<C-u>CocList locationlist<cr>

" list commands available in tsserver (and others)
nnoremap <silent> <leader>cc  :<C-u>CocList commands<cr>

" restart when tsserver gets wonky
nnoremap <silent> <leader>cR  :<C-u>CocRestart<CR>

" view all errors
nnoremap <silent> <leader>cl  :<C-u>CocList locationlist<CR>

" manage extensions
nnoremap <silent> <leader>cx  :<C-u>CocList extensions<cr>

" rename the current word in the cursor
nmap <leader>cr  <Plug>(coc-rename)
nmap <leader>cf  <Plug>(coc-format-selected)
vmap <leader>cf  <Plug>(coc-format-selected)

" run code actions
vmap <leader>ca  <Plug>(coc-codeaction-selected)
nmap <leader>ca  <Plug>(coc-codeaction-selected)

"pynvim path
let g:python3_host_prog = '/usr/bin/python3'

" Split navigation shortcut remapping
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

" Standard bindings
inoremap jk <Esc>
inoremap jj <Esc>:wq<CR>
inoremap kj <Esc>
inoremap kk <Esc>:w<CR>

" Auto closing brackets
inoremap (; (<CR>);<C-c>O
inoremap (, (<CR>),<C-c>O
inoremap {; {<CR>};<C-c>O
inoremap {, {<CR>},<C-c>O
inoremap [; [<CR>];<C-c>O
inoremap [, [<CR>],<C-c>O
inoremap {<Space><Space> {<CR>}<C-c>O

" Use blackhole registers by default
nnoremap d "_d
vnoremap d "_d
nnoremap D "_D
vnoremap D "_D
nnoremap c "_c
vnoremap c "_c
nnoremap C "_C
vnoremap C "_C
nnoremap x "_x
vnoremap x "_x
nnoremap X "_X
vnoremap X "_X

" USE clipboard with leader
nnoremap <leader>d d
vnoremap <leader>d d
nnoremap <leader>D D
vnoremap <leader>D D
nnoremap <leader>c c
vnoremap <leader>c c
nnoremap <leader>C C
vnoremap <leader>C C
nnoremap <leader>x x
vnoremap <leader>x x
nnoremap <leader>X X
vnoremap <leader>X X

" Quickly insert an empty new line without entering insert mode
nnoremap <Leader>o o<Esc>
nnoremap <Leader>O O<Esc>

" Line bubbling
nnoremap <Leader><Up>   :<C-u>silent! move-2<CR>==
nnoremap <Leader><Down> :<C-u>silent! move+<CR>==
xnoremap <Leader><Up>   :<C-u>silent! '<,'>move-2<CR>gv=gv
xnoremap <Leader><Down> :<C-u>silent! '<,'>move'>+<CR>gv=gv

