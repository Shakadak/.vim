-- https://www.notonlycode.org/neovim-lua-config/
-- https://neovim.io/doc/user/lua-guide.html

-- vim.pack.add({
--   -- Install "plug" and use default branch (usually `main` or `master`)
--   -- Specify plugin's name (here the plugin will be called "plug"
--   -- instead of "vim-plug")
--   { src = 'https://github.com/junegunn/vim-plug.git', name = 'plug' }
-- }, {
--   load = true
-- })

-- disable modelines
vim.o.modeline = false

-- hints


vim.pack.add({
  { src = 'https://github.com/neovim/nvim-lspconfig.git' },
})


vim.pack.add({
  { src = 'https://github.com/hrsh7th/cmp-nvim-lsp.git', name = 'cmp_nvim_lsp' },
  { src = 'https://github.com/hrsh7th/nvim-cmp.git', name = 'cmp' },
})

vim.pack.add({
  { src = 'https://github.com/mfussenegger/nvim-lint.git', name = 'lint' },
})




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


-- Deferred config
require('tree-sitter')
require('lsp')
require('terminal')
require('cmp-lsp')
require('linters')
require('fold')
require('colorscheme-config')
require('which-key-config')
