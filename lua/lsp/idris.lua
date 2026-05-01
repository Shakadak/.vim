-- " Idris
vim.pack.add({
  { name = 'nui', src = 'https://github.com/MunifTanjim/nui.nvim' },
  { name = 'idris2', src = 'https://github.com/idris-community/idris2-nvim'},
})

-- vim.lsp.enable("idris2_lsp")
local function save_hook(action)
  vim.cmd('silent write')
end

local opts = {
  server = {
    on_attach = function(...)
      vim.keymap.set('n', '<LocalLeader>a', require('idris2.code_action').add_clause, {})
      vim.keymap.set('n', '<LocalLeader>c', require('idris2.code_action').case_split, {})
      vim.keymap.set('n', '<LocalLeader>o', require('idris2.code_action').expr_search, {})
      vim.keymap.set('n', '<LocalLeader>gd', require('idris2.code_action').generate_def, {})
    end,
  },
  code_action_post_hook = save_hook,
}

require('idris2').setup(opts)
