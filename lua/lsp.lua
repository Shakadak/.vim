-- Set up lspconfig.
-- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..
local capabilities = require('cmp_nvim_lsp').default_capabilities()

vim.lsp.config("elixirls", {
  -- cmd = { "/home/nathanael/.local/bin/elixirls/language_server.sh" }
  cmd = { "elixir-ls" },
  capabilities = capabilities,
  settings = {
    elixirLS = {
      incrementalDialyzer = true,
    }
  },
})

-- Haskell Language Server config [HLScdb]
vim.lsp.enable('hls')
vim.lsp.enable("elixirls")
vim.lsp.enable("erlangls")
vim.lsp.enable("purescriptls")
vim.lsp.enable("ts_ls")
vim.lsp.enable("cssls")
vim.lsp.enable("jsonls")

-- Idris2 config
require('lsp/idris')

vim.keymap.set('n', 'gD', vim.lsp.buf.implementation, {silent = true})
vim.keymap.set('n', '<c-k>', vim.lsp.buf.signature_help, {silent = true})
vim.keymap.set('n', '1gD', vim.lsp.buf.type_definition, {silent = true})
-- vim.keymap.set('n', 'gr', vim.lsp.buf.refrences, {silent = true})
vim.keymap.set('n', 'g0', vim.lsp.buf.document_symbol, {silent = true})
vim.keymap.set('n', 'gW', vim.lsp.buf.workspace_symbol, {silent = true})
vim.keymap.set('n', 'gd', vim.lsp.buf.declaration, {silent = true})

vim.keymap.set('n', '<c-]>', vim.lsp.buf.definition, { silent = true, })
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { silent = true, })

vim.keymap.set('n', '<leader>ep', vim.diagnostic.goto_prev, { silent = true, })
vim.keymap.set('n', '<leader>en', vim.diagnostic.goto_next, { silent = true, })
vim.keymap.set('n', '<leader>eo', vim.diagnostic.open_float, { silent = true, })

vim.diagnostic.config({
    virtual_text = true,
    -- virtual_text = {current_line = true},
    -- virtual_lines = {
    --    current_line = true,
    --},
})
