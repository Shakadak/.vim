-- https://www.notonlycode.org/neovim-lua-config/
-- https://neovim.io/doc/user/lua-guide.html

vim.cmd([[
set nocompatible              " be iMproved, required

call plug#begin()
" General
" Plug 'altercation/vim-colors-solarized'
Plug 'shaunsingh/solarized.nvim'

" Language Client
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Completion
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/nvim-cmp'

" Linters
Plug 'mfussenegger/nvim-lint'

" Haskell Language Server config down below [HLScdb]

" Rust
Plug 'rust-lang/rust.vim'

" Plug 'idris-hackers/idris-vim'

" Haskell
Plug 'neovimhaskell/haskell-vim'

" Elixir
"Plug 'elixir-editors/vim-elixir'

" Javascript
Plug 'pangloss/vim-javascript', { 'for': ['javascript', 'js', 'jsx', 'javascript.jsx']}
Plug 'mxw/vim-jsx', { 'for': ['javascript', 'js', 'jsx', 'javascript.jsx']}

" Reason
Plug 'reasonml-editor/vim-reason-plus'

" Purescript
Plug 'purescript-contrib/purescript-vim'

call plug#end()

"Put your custom Vim configuration here

"Better command completion
"set wildmenu
"set wildmode=list:longest

" Required for operations modifying multiple buffers like rename.
set hidden

"Show current line
"set cursorline

"syntax enable
"syntax on
"filetype on
set number
"set cursorline
"set cuc
"set mouse=a
set expandtab
set tabstop=4
set shiftwidth=4
"au BufWinEnter * let w:m2=matchadd('Tab', '\t', -1)
"au BufWinEnter * let w:m3=matchadd('Space', '\s\+$\| \+\ze\t', -1)
"set list listchars=tab:▸\ ,trail:·
"syn match LowVisibilityBraces display '[{}]'

"highlight Tab ctermbg=darkgreen
"highlight Space ctermbg=darkred
"hi LowVisibilityBraces ctermbg=darkgreen

"set term=screen-256color
"set t_ut=
"set t_Co=256
"set background=light
"let g:solarized_termcolors=256
"colorscheme solarized
set cursorline

let g:haddock_browser="/usr/bin/firefox"

set backspace=2


"let g:markdown_fenced_languages = ['css', 'elixir', 'ex=elixir', 'javascript', 'js=javascript', 'json=javascript', 'ruby', 'xml', 'html']

set termguicolors

]])

-- Color Scheme
require('solarized').set()

-- Deferred config
require('tree-sitter')
require('lsp')
require('terminal')
require('cmp-lsp')
require('linters')
