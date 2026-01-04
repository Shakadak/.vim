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

-- npm install --global typescript-language-server
vim.lsp.config("ts_ls", {
  capabilities = capabilities,
  on_attach = function (client, bufnr)
    vim.lsp.completion.enable(true, client.id, bufnr, {
      autotrigger = true,
      convert = function (item)
        return { abbr = item.label:gsub('%b()', '') }
      end
    })
  end
})
vim.lsp.enable("ts_ls")
-- npm install --global vscode-langservers-extracted
vim.lsp.enable("cssls")
-- npm install --global vscode-langservers-extracted
vim.lsp.enable("jsonls")

require("lsp/lua")

require("lsp/gdscript")

-- Idris2 config
require('lsp/idris')

vim.keymap.set('n', 'gD', vim.lsp.buf.implementation, {silent = true})
vim.keymap.set('n', '<c-k>', vim.lsp.buf.signature_help, {silent = true})
vim.keymap.set('n', '1gD', vim.lsp.buf.type_definition, {silent = true})
-- vim.keymap.set('n', 'gr', vim.lsp.buf.references, {silent = true})
vim.keymap.set('n', 'g0', vim.lsp.buf.document_symbol, {silent = true})
vim.keymap.set('n', 'gW', vim.lsp.buf.workspace_symbol, {silent = true})
vim.keymap.set('n', 'gd', vim.lsp.buf.declaration, {silent = true})

vim.keymap.set('n', '<c-]>', vim.lsp.buf.definition, { silent = true, })
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { silent = true, })

vim.diagnostic.config({
    virtual_text = true,
    -- virtual_text = {current_line = true},
    -- virtual_lines = {
    --    current_line = true,
    --},
})
