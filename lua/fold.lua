-- Start with folds open
-- vim.o.foldenable = true
-- vim.o.foldlevel = 99
-- vim.o.foldlevelstart = 99

local function has_ts_parser(buf)
  local ft = vim.bo[buf].filetype
  local lang = vim.treesitter.language.get_lang(ft) or ft
  return pcall(vim.treesitter.get_parser, buf, lang)
end

local function set_folding(buf)
  -- foldmethod/foldexpr are window options; tie them to the buffer shown in that window
  if has_ts_parser(buf) then
    vim.wo.foldmethod = "expr"
    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
  else
    -- fallback for filetypes without TS
    vim.wo.foldmethod = "indent" -- or "syntax"
    -- this is a reset, the previous buffer could have a TS parser
    vim.wo.foldexpr = ""
  end
end

vim.api.nvim_create_autocmd({ "BufWinEnter", "FileType" }, {
  callback = function(args)
    set_folding(args.buf)
  end,
})
