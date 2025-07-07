require('nvim-treesitter.configs').setup {
    ensure_installed = {
        "eex",
        "elixir",
        "erlang",
        "lua",
        "markdown",
        "haskell",
        "javascript",
        "typescript",
    },
  ---[[
  highlight = {
    enable = true,
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    -- additional_vim_regex_highlighting = { 'elixir' },
  },
  --]]
  indent = {
    enable = true
  },
  incremental_selection = {
      enable = true,
      keymaps = {
          init_selection = "<CR>",
          node_incremental = "<CR>",
          scope_incremental = "<Tab>",
          node_decremental = "<S-Tab>",
      },
  },
}

vim.cmd([[
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
set nofoldenable                     " Disable folding at startup.
]])

-- Highlight @foo.bar as "Identifier" only in Lua files
vim.api.nvim_set_hl(0, "@variable.elixir", { ctermfg = "NONE"})
vim.api.nvim_set_hl(0, "@symbol", { link = "Constant"})
