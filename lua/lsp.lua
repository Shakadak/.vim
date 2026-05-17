-- Set up lspconfig.
-- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..
-- local capabilities = require('cmp_nvim_lsp').default_capabilities()

vim.lsp.config("elixirls", {
  -- cmd = { "/home/nathanael/.local/bin/elixirls/language_server.sh" }
  cmd = { "elixir-ls" },
  -- capabilities = capabilities,
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
vim.lsp.enable("rust_analyzer")

-- npm install --global purescript-language-server
local MiniCompletion = require('mini.completion')
vim.lsp.config("purescriptls", {
  root_dir = function (bufnr, on_dir)
    on_dir(vim.fs.root(bufnr, {".git", "output"}))
  end,
  on_attach = function (client, bufnr)
    vim.b[bufnr].minicompletion_config = {
      lsp_completion = {
        process_items = function(items, base)
          -- print('process_items ' .. vim.inspect(items))
          -- Some LSP servers send null for string fields; Neovim decodes
          -- JSON null as vim.NIL (userdata), which breaks string matching.
          for _, item in ipairs(items) do
            for k, v in pairs(item) do
              if v == vim.NIL then item[k] = nil end
            end
          end
          return MiniCompletion.default_process_items(items, base)
        end,
      },
    }
  end
})
vim.lsp.enable("purescriptls")

-- npm install --global typescript-language-server
vim.lsp.config("ts_ls", {
  -- capabilities = capabilities,
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

-- see keymaps at:
-- - https://neovim.io/doc/user/lsp.html#_defaults
-- - https://neovim.io/doc/user/diagnostic.html#_defaults
-- CTRL-S now -- vim.keymap.set('n', '<c-k>', vim.lsp.buf.signature_help, {silent = true})
vim.keymap.set('n', 'gW', vim.lsp.buf.workspace_symbol, {silent = true})
vim.keymap.set('n', 'gd', vim.lsp.buf.declaration, {silent = true})

vim.diagnostic.config({
    virtual_text = true,
    -- virtual_text = {current_line = true},
    -- virtual_lines = {
    --    current_line = true,
    --},
})
