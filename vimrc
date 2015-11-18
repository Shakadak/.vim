set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')
"
" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'scrooloose/syntastic'

Plugin 'rust-lang/rust.vim'

Plugin 'elixir-lang/vim-elixir'

Plugin 'idris-hackers/idris-vim'

Plugin 'lukerandall/haskellmode-vim'

Plugin 'neovimhaskell/haskell-vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
" Plugin 'tpope/vim-fugitive'
" plugin from http://vim-scripts.org/vim/scripts.html
" Plugin 'L9'
" Git plugin not hosted on GitHub
" Plugin 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
" Plugin 'file:///home/gmarik/path/to/plugin'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
" Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" Avoid a name conflict with L9
" Plugin 'user/L9', {'name': 'newL9'}

" " All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just
" :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

"Put your custom Vim configuration here

"Better command completion
"set wildmenu
"set wildmode=list:longest

"Show current line
"set cursorline

syntax enable
syntax on
filetype on
set number
set cursorline
set cuc
set mouse=a
set expandtab
set tabstop=4
set shiftwidth=4
au BufWinEnter * let w:m2=matchadd('Tab', '\t', -1)
au BufWinEnter * let w:m3=matchadd('Space', '\s\+$\| \+\ze\t', -1)
"set list listchars=tab:▸\ ,trail:·
syn match LowVisibilityBraces display '[{}]'

highlight Tab ctermbg=darkgreen
highlight Space ctermbg=darkred
hi LowVisibilityBraces ctermbg=darkgreen
set background=light

let g:haddock_browser="/usr/bin/firefox"

set backspace=2