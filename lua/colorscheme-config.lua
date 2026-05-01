-- Color Scheme
vim.pack.add({
  { src = 'https://github.com/shaunsingh/solarized.nvim.git', name = 'solarized' },
})
vim.pack.add({
  {src = 'https://github.com/nyoom-engineering/oxocarbon.nvim'},
})
vim.pack.add({
  {src = 'https://github.com/EdenEast/nightfox.nvim.git', name = 'nightfox'},
})

-- require('solarized').set()
-- vim.cmd('colorscheme oxocarbon')
vim.cmd("colorscheme nightfox")
