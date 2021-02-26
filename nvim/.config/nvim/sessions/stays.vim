let SessionLoad = 1
let s:so_save = &so | let s:siso_save = &siso | set so=0 siso=0
let v:this_session=expand("<sfile>:p")
silent only
cd ~/Documents/web-dev/windbnb
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
set shortmess=aoO
badd +29 src/components/Navbar/Navbar.js
badd +29 src/components/context/GlobalState.js
badd +4 src/components/Navbar/NavbarModal/LocationList/LocationList.js
badd +11 src/components/context/AppReducer/AppReducer.js
badd +4 src/components/Navbar/NavbarModal/GuestCount/GuestCountToggle/GuestCountToggle.js
badd +16 src/components/App/App.js
badd +12 src/components/StaysList/StaysList.js
badd +1 src/components/StaysList/StaysListItem/StaysListItem.js
badd +8 src/index.js
badd +36 src/components/Navbar/NavbarModal/GuestCount/GuestCount.js
badd +1 src/context/GlobalState.js
badd +6 src/context/AppReducer/AppReducer.js
badd +41 src/components/Navbar/NavbarModal/NavbarModal.js
badd +26 src/components/App/globalStyles.js
argglobal
%argdel
$argadd src/components/Navbar/Navbar.js
set stal=2
edit src/components/Navbar/Navbar.js
set splitbelow splitright
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
argglobal
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 28 - ((16 * winheight(0) + 13) / 27)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
28
normal! 0
if exists(':tcd') == 2 | tcd ~/Documents/web-dev/windbnb/src/components/Navbar/NavbarModal/GuestCount/GuestCountToggle | endif
tabedit ~/Documents/web-dev/windbnb/src/components/Navbar/NavbarModal/NavbarModal.js
set splitbelow splitright
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
argglobal
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 32 - ((9 * winheight(0) + 13) / 27)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
32
normal! 0
if exists(':tcd') == 2 | tcd ~/Documents/web-dev/windbnb/src/components/Navbar/NavbarModal/GuestCount/GuestCountToggle | endif
tabedit ~/Documents/web-dev/windbnb/src/components/StaysList/StaysListItem/StaysListItem.js
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd w
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe 'vert 1resize ' . ((&columns * 66 + 67) / 134)
exe 'vert 2resize ' . ((&columns * 67 + 67) / 134)
argglobal
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 1 - ((0 * winheight(0) + 13) / 27)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
1
normal! 03|
wincmd w
argglobal
if bufexists("~/Documents/web-dev/windbnb/src/components/StaysList/StaysList.js") | buffer ~/Documents/web-dev/windbnb/src/components/StaysList/StaysList.js | else | edit ~/Documents/web-dev/windbnb/src/components/StaysList/StaysList.js | endif
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 13 - ((12 * winheight(0) + 13) / 27)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
13
normal! 012|
wincmd w
exe 'vert 1resize ' . ((&columns * 66 + 67) / 134)
exe 'vert 2resize ' . ((&columns * 67 + 67) / 134)
if exists(':tcd') == 2 | tcd ~/Documents/web-dev/windbnb/src/components/Navbar/NavbarModal/GuestCount/GuestCountToggle | endif
tabedit ~/Documents/web-dev/windbnb/src/context/GlobalState.js
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd w
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe 'vert 1resize ' . ((&columns * 66 + 67) / 134)
exe 'vert 2resize ' . ((&columns * 67 + 67) / 134)
argglobal
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 101 - ((14 * winheight(0) + 13) / 27)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
101
normal! 043|
wincmd w
argglobal
if bufexists("~/Documents/web-dev/windbnb/src/context/AppReducer/AppReducer.js") | buffer ~/Documents/web-dev/windbnb/src/context/AppReducer/AppReducer.js | else | edit ~/Documents/web-dev/windbnb/src/context/AppReducer/AppReducer.js | endif
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 6 - ((5 * winheight(0) + 13) / 27)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
6
normal! 015|
wincmd w
exe 'vert 1resize ' . ((&columns * 66 + 67) / 134)
exe 'vert 2resize ' . ((&columns * 67 + 67) / 134)
if exists(':tcd') == 2 | tcd ~/Documents/web-dev/windbnb/src/components/Navbar/NavbarModal/GuestCount/GuestCountToggle | endif
tabnext 2
set stal=1
if exists('s:wipebuf') && getbufvar(s:wipebuf, '&buftype') isnot# 'terminal'
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20 winminheight=1 winminwidth=1 shortmess=filnxtToOFc
let s:sx = expand("<sfile>:p:r")."x.vim"
if file_readable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &so = s:so_save | let &siso = s:siso_save
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
