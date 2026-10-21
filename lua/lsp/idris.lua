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
      vim.keymap.set('n', '<LocalLeader>a', require('idris2.code_action').add_clause, {desc = "Add clause"})
      vim.keymap.set('n', '<LocalLeader>c', require('idris2.code_action').case_split, {desc = "Case split"})
      vim.keymap.set('n', '<LocalLeader>o', require('idris2.code_action').expr_search, {desc = "Expression search"})
      vim.keymap.set('n', '<LocalLeader>gd', require('idris2.code_action').generate_def, {desc = "Generate definition"})
    end,
  },
  code_action_post_hook = save_hook,
}

require('idris2').setup(opts)

do
  local changetracking = require("vim.lsp._changetracking")
  local original_send_did_save = changetracking._send_did_save

  changetracking._send_did_save = function(bufnr)
    bufnr = vim._resolve_bufnr(bufnr)

    local has_idris = #vim.lsp.get_clients({
      bufnr = bufnr,
      name = "idris2_lsp",
    }) > 0

    if not has_idris then
      return original_send_did_save(bufnr)
    end

    local uri = vim.uri_from_bufnr(bufnr)
    local full_text = nil

    for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
      local save_capability = vim.tbl_get(
        client.server_capabilities,
        "textDocumentSync",
        "save"
      )

      if save_capability then
        local included_text = nil

        if type(save_capability) == "table" and save_capability.includeText then
          full_text = full_text or vim.lsp._buf_get_full_text(bufnr)
          included_text = full_text
        end

        client:notify("textDocument/didSave", {
          textDocument = { uri = uri },
          text = included_text,
        })
      else
        changetracking.flush(client, bufnr)
      end
    end
  end
end

--[[
-- do
--   local orig_publish = vim.lsp.handlers["textDocument/publishDiagnostics"]
--
--   vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, params, ctx, config)
--     local client = vim.lsp.get_client_by_id(ctx.client_id)
--
--     if client and client.name == "idris2_lsp" then
--       local uri = params and params.uri or "?"
--       local diagnostics = params and params.diagnostics or {}
--
--       vim.notify(string.format(
--         "DIAG from client=%s root=%s uri=%s count=%d",
--         client.id,
--         client.config.root_dir,
--         uri,
--         #diagnostics
--       ), vim.log.levels.WARN)
--     end
--
--     return orig_publish(err, params, ctx, config)
--   end
-- end
--
-- vim.api.nvim_create_autocmd("LspNotify", {
--   group = vim.api.nvim_create_augroup("debug-idris-lsp-notify", { clear = true }),
--   callback = function(ev)
--     local client = vim.lsp.get_client_by_id(ev.data.client_id)
--     if not client or client.name ~= "idris2_lsp" then
--       return
--     end
--
--     local method = ev.data.method
--     if method == "textDocument/didSave"
--       or method == "textDocument/didChange"
--       or method == "textDocument/didOpen" then
--       vim.notify(string.format(
--         "NOTIFY to client=%s method=%s buf=%s file=%s root=%s",
--         client.id,
--         method,
--         ev.buf,
--         vim.api.nvim_buf_get_name(ev.buf),
--         client.config.root_dir
--       ), vim.log.levels.WARN)
--     end
--   end,
-- })
--
-- vim.api.nvim_create_autocmd("LspRequest", {
--   group = vim.api.nvim_create_augroup("debug-idris-lsp-request", { clear = true }),
--   callback = function(ev)
--     local client = vim.lsp.get_client_by_id(ev.data.client_id)
--     if not client or client.name ~= "idris2_lsp" then
--       return
--     end
--
--     local req = ev.data.request or {}
--     if req.type ~= "pending" then
--       return
--     end
--
--     local method = req.method
--     if method == "textDocument/semanticTokens/full"
--       or method == "textDocument/hover"
--       or method == "textDocument/documentSymbol"
--       or method == "textDocument/completion"
--       or method == "textDocument/definition" then
--       vim.notify(string.format(
--         "REQUEST to client=%s method=%s buf=%s file=%s root=%s",
--         client.id,
--         method,
--         ev.buf,
--         vim.api.nvim_buf_get_name(ev.buf),
--         client.config.root_dir
--       ), vim.log.levels.WARN)
--     end
--   end,
-- })
--]]
