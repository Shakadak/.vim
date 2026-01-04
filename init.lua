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

" Idris
" Plug 'neovim/nvim-lspconfig'
Plug 'MunifTanjim/nui.nvim'
Plug 'idris-community/idris2-nvim'


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
]])

-- Required for operations modifying multiple buffers like rename.
-- https://neovim.io/doc/user/options.html#'hidden'
vim.o.hidden = true

vim.o.number = true
vim.o.cursorline = true
-- vim.opt.cursorcolumn = true
-- vim.api.nvim_create_autocmd({"WinLeave"}, {
--   callback = function() vim.opt.cursorcolumn = false end
-- })
-- vim.api.nvim_create_autocmd({"WinEnter"}, {
--   callback = function() vim.opt.cursorcolumn = true end
-- })

vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.shiftwidth = 0

vim.o.completeopt = 'fuzzy,menuone,noinsert'

-- https://neovim.io/doc/user/options.html#'termguicolors'
-- vim.opt.termguicolors = true

-- Color Scheme
require('solarized').set()

-- Deferred config
require('tree-sitter')
require('lsp')
require('terminal')
require('cmp-lsp')
require('linters')
