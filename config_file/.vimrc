"NAME:Li Wang
"Mail:wangli.ahau@gmail.com

" An example for a vimrc file.
"
" Maintainer:        Bram Moolenaar <Bram@vim.org>
" Last change:        2008 Dec 17
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"              for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"            for OpenVMS:  sys$login:.vimrc

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

"this line is added by wangli
"set tabstop=4 "表示一个tab显示空格的长度默认 8
"set shiftwidth=4 "换行后缩进为4
set number "显示行号
set formatoptions=tcrqn
set autoindent
set smartindent
set cindent

"Tag list(ctas)
let Tlist_Exit_OnlyWindow=1
let Tlist_Show_One_File=1
"let Tlist_Auto_Open = 1



set ruler " 打开状态栏标尺
"set cursorline " 突出显示当前行
"set magic " 设置魔术
"set guioptions-=T " 隐藏工具栏
"set guioptions-=m " 隐藏菜单栏

if has("vms")
  set nobackup        " do not keep a backup file, use versions instead
else
  set backup        " keep a backup file
endif
set history=50        " keep 50 lines of command line history
set ruler        " show the cursor position all the time
set showcmd        " display incomplete commands
set incsearch        " do incremental searching

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

else

  set autoindent        " always set autoindenting on

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
                  \ | wincmd p | diffthis
endif

let g:winManagerWindowLayout='FileExplorer|TagList' 
nmap wm :WMToggle<cr>

set cscopequickfix=s-,c-,d-,i-,t-,e-
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" cscope setting
" """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has("cscope")
    set csprg=/usr/bin/cscope
    set csto=0
    set cst
    set csverb
    set cspc=3
    "add any database in current dir
    if filereadable("cscope.out")
        cs add cscope.out
    "else search cscope.out elsewhere
    else
       let cscope_file=findfile("cscope.out", ".;")
       let cscope_pre=matchstr(cscope_file, ".*/")
       if !empty(cscope_file) && filereadable(cscope_file)
           exe "cs add" cscope_file cscope_pre
       endif      
     endif
endif

"if has("cscope")
"          set csprg=/usr/bin/cscope
"          set csto=1
"          set cst
"          set nocsverb
"add any database in current directory
"if filereadable("cscope.out")
" cs add cscope.out
"endif
"        set csverb
"endif
                
nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
nmap <C-\>i :cs find i <C-R>=expand("<cfile>")<CR>$<CR>
nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>

"if &filetype == 'c'
set makeprg=gcc\ -o\ %<\ %
"elseif &filetype =='java'
        "set makeprg=javac\ %<\ %
"endif

" Only do this part when compiled with support for autocommands.
" 智能补全
if has("autocmd") 
 autocmd Filetype java setlocal omnifunc=javacomplete#Complete 
 autocmd FileType python set omnifunc=pythoncomplete#Complete  
 autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS  
 autocmd FileType html set omnifunc=htmlcomplete#CompleteTags  
 autocmd FileType css set omnifunc=csscomplete#CompleteCSS  
 autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags  
 autocmd FileType php set omnifunc=phpcomplete#CompletePHP  
 autocmd FileType c set omnifunc=ccomplete#Complete  
endif

set rtp+=/Library/Python/2.7/site-packages/powerline/bindings/vim

" These lines setup the environment to show graphics and colors correctly.
set nocompatible
set t_Co=256

let g:minBufExplForceSyntaxEnable = 1
python from powerline.vim import setup as powerline_setup
python powerline_setup()
python del powerline_setup

if ! has('gui_running')
	set ttimeoutlen=10
	augroup FastEscape
		autocmd!
		au InsertEnter * set timeoutlen=0
		au InsertLeave * set timeoutlen=1000
	augroup END
endif

set laststatus=2 " Always display the statusline in all windows
set guifont=Inconsolata\ for\ Powerline:h14
set noshowmode " Hide the default mode text (e.g. -- INSERT -- below the statusline)
