require('nvim-treesitter.configs').setup {
  ensure_installed = {
    "css",
    "eex",
    "elixir",
    "erlang",
    "gdscript",
    "haskell",
    "heex",
    "html",
    "idris",
    "javascript",
    "json",
    "lua",
    "markdown",
    "nix",
    "tsx",
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
  ---[[
  indent = {
    enable = true
  },
  --]]
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

-- Disable folding at startup.
-- https://neovim.io/doc/user/options.html#'foldenable'
vim.opt.foldenable = false
-- https://neovim.io/doc/user/options.html#'foldexpr'
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldmethod = "expr"

-- Highlight @foo.bar as "Identifier" only in Lua files
vim.api.nvim_set_hl(0, "@variable.elixir", { ctermfg = "NONE"})
vim.api.nvim_set_hl(0, "@symbol", { link = "Constant"})
