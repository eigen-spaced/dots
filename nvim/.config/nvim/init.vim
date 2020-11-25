syntax enable

set encoding=UTF-8

" Filetype indentation rules
filetype plugin indent on

autocmd FileType java setlocal shiftwidth=4 softtabstop=4 expandtab
autocmd FileType python setlocal shiftwidth=4 softtabstop=4 expandtab

set tabstop=2 softtabstop=2
set shiftwidth=2
set smartindent
set autoindent

set smartcase
set splitright
set splitbelow
set noswapfile

" ## Search ##
set ignorecase
set smartcase

" ## User interface ##
set laststatus=2
set ruler
set nu rnu
set noerrorbells
set title
set colorcolumn=81

" ## Text rendering ##
set linebreak
set wrap
set scrolloff=8
set sidescrolloff=5
" Disable auto-commenting to the next line
set formatoptions-=cro

set nohlsearch " Turn off search highlighting

let mapleader=" "

set tabline=%!MyTabLine()  " custom tab pages line
function! MyTabLine()
  let s = ''
  " loop through each tab page
  for i in range(tabpagenr('$'))
    if i + 1 == tabpagenr()
      let s .= '%#TabLineSel#'
    else
      let s .= '%#TabLine#'
    endif
    if i + 1 == tabpagenr()
      let s .= '%#TabLineSel#' " WildMenu
    else
      let s .= '%#Title#'
    endif
    " set the tab page number (for mouse clicks)
    let s .= '%' . (i + 1) . 'T '
    " set page number string
    let s .= i + 1 . ''
    " get buffer names and statuses
    let n = ''  " temp str for buf names
    let m = 0   " &modified counter
    let buflist = tabpagebuflist(i + 1)
    " loop through each buffer in a tab
    for b in buflist
      if getbufvar(b, "&buftype") == 'help'
        " let n .= '[H]' . fnamemodify(bufname(b), ':t:s/.txt$//')
      elseif getbufvar(b, "&buftype") == 'quickfix'
        " let n .= '[Q]'
      elseif getbufvar(b, "&modifiable")
        let n .= fnamemodify(bufname(b), ':t') . ', ' " pathshorten(bufname(b))
      endif
      if getbufvar(b, "&modified")
        let m += 1
      endif
    endfor
    " let n .= fnamemodify(bufname(buflist[tabpagewinnr(i + 1) - 1]), ':t')
    let n = substitute(n, ', $', '', '')
    " add modified label
    if m > 0
      let s .= '+'
      " let s .= '[' . m . '+]'
    endif
    if i + 1 == tabpagenr()
      let s .= ' %#TabLineSel#'
    else
      let s .= ' %#TabLine#'
    endif
    " add buffer names
    if n == ''
      let s.= '[New]'
    else
      let s .= n
    endif
    " switch to no underlining and add final space
    let s .= ' '
  endfor
  let s .= '%#TabLineFill#%T'
  " right-aligned close button
  " if tabpagenr('$') > 1
  "   let s .= '%=%#TabLineFill#%999Xclose'
  " endif
  return s
endfunction

" ## netrw config ##
" display in tree structure
let g:netrw_liststyle = 3

" Remove annoying banner
let g:netrw_banner = 0

" sort is affecting only: directories on the top, files below
let g:netrw_sort_sequence = '[\/]$,*'

" Use right side of project window
let g:netrw_altv = 1

" Open file, but keep focus in Explorer
autocmd filetype netrw nmap <c-a> <cr>:wincmd W<cr>


call plug#begin('~/.config/nvim/plugged/')
	Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
	Plug 'junegunn/fzf.vim'

	Plug 'vimwiki/vimwiki'
	Plug 'junegunn/goyo.vim'

	Plug 'tpope/vim-eunuch'
	Plug 'tpope/vim-surround'

	Plug 'dracula/vim'
	Plug 'sainnhe/sonokai'
	Plug 'rakr/vim-one'

	Plug 'sheerun/vim-polyglot'
	Plug 'pangloss/vim-javascript'
	Plug 'leafgarland/typescript-vim'
	Plug 'peitalin/vim-jsx-typescript'
	Plug 'neoclide/coc.nvim', {'branch': 'release'}
	Plug 'jparise/vim-graphql'

	Plug 'neovimhaskell/haskell-vim'

" nvim root write and read privileges
	Plug 'lambdalisue/suda.vim'
call plug#end()

" SudaWrite (for sudo read and write)
let g:suda#prompt = 'Enter password beep boop: '


if (has("termguicolors"))
	set termguicolors
endif

" set background=dark
" let g:one_allow_italics=1
" colorscheme one

let g:sonokai_style = 'andromeda'
let g:sonokai_enable_italic = 1 

colorscheme sonokai

" ## haskell vim ##
let g:haskell_classic_highlighting = 1		" Enable to classical highlighting
let g:haskell_enable_quantification = 1   " Enable highlighting of `forall`
let g:haskell_enable_recursivedo = 1      " Enable highlighting of `mdo` and `rec`
let g:haskell_enable_arrowsyntax = 1      " Enable highlighting of `proc`
let g:haskell_enable_pattern_synonyms = 1 " Enable highlighting of `pattern`
let g:haskell_enable_typeroles = 1        " Enable highlighting of type roles
let g:haskell_enable_static_pointers = 1  " Enable highlighting of `static`
let g:haskell_backpack = 1                " Enable highlighting of backpack keywords
let g:haskell_indent_case = 2							" Enable indenting (or switch to hident?)

" ## fzf ##
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
	\'coc-java',
	\'coc-explorer'
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

" Explorer
nmap <leader>e :CocCommand explorer<CR>
nmap <leader>f :CocCommand explorer --preset floating<CR>
autocmd BufEnter * if (winnr("$") == 1 && &filetype == 'coc-explorer') | q | endif

"pynvim path
let g:python3_host_prog = '/usr/bin/python3'

" Split navigation shortcut remapping
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

" Standard bindings
inoremap jk <Esc>
inoremap kk <Esc>:w<CR>

nmap <Tab> :tabnext<CR>
nmap <S-Tab> :tabprev<CR>

" Auto closing brackets
inoremap (; (<CR>);<C-c>O
inoremap (, (<CR>),<C-c>O
inoremap {; {<CR>};<C-c>O
inoremap {, {<CR>},<C-c>O
inoremap [; [<CR>];<C-c>O
inoremap [, [<CR>],<C-c>O
inoremap {<CR> {<CR>}<C-c>O

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

" Better indenting
vnoremap < <gv
vnoremap > >gv

" Split line under cursor into two seperate lines
nmap <NL> i<CR><ESC>
