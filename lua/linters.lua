-- https://github.com/mantoni/eslint_d.js?tab=readme-ov-file#neovim
-- unproven to work yet
vim.env.ESLINT_D_PPID = vim.fn.getpid()

-- https://github.com/mfussenegger/nvim-lint?tab=readme-ov-file#usage
require('lint').linters_by_ft = {
  elixir = {'credo'},
  javascript = {'eslint_d'},
  typescript = {'eslint_d'},
}

-- https://github.com/mfussenegger/nvim-lint?tab=readme-ov-file#usage
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function()

    -- try_lint without arguments runs the linters defined in `linters_by_ft`
    -- for the current filetype
    require("lint").try_lint()
  end,
})
