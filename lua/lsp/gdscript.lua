--[[

local log_date_format = '%F %H:%M:%S'
local function format_func(level, ...)
  -- if log_levels[level] < current_log_level then
  --   return nil
  -- end

  local info = debug.getinfo(2, 'Sl')
  local header = string.format(
    '[%s][%s] %s:%s',
    level,
    os.date(log_date_format),
    info.short_src,
    info.currentline
  )
  local parts = { header }
  local argc = select('#', ...)
  for i = 1, argc do
    local arg = select(i, ...)
    table.insert(parts, arg == nil and 'nil' or vim.inspect(arg))
    -- table.insert(parts, arg == nil and 'nil' or vim.inspect(arg, { newline = ' ', indent = '' }))
  end
  return table.concat(parts, '\t') .. '\n'
end

--]]

-- vim.lsp.log.set_level(1)
-- vim.lsp.log.set_level(vim.log.levels.DEBUG)
-- require('vim.lsp.log').set_format_func(format_func)
-- vim.lsp.log.set_format_func(format_func)

-- local log2 = require('vim.lsp.log')

-- http://lua-users.org/wiki/CopyTable
local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

local function map(tbl, f)
    local t = {}
    for k, v in pairs(tbl) do
        t[k] = f(v)
    end
    return t
end

local function onFileUri(str, f)
  local prefix = "file://"
  local prefix_len = string.len(prefix)
  if string.sub(str, 1, prefix_len) == prefix then
    return prefix .. f(string.sub(str, prefix_len + 1))
  end
  return str
end

local function toWPath(path)
  return vim.trim(vim.system({'wslpath', '-w', path}, { text = true }):wait().stdout)
end

local function toUPath(path)
  return vim.trim(vim.system({'wslpath', '-u', path}, { text = true }):wait().stdout)
end

local function initialize(params)
  local log = require('./debug')

  -- TODO: handle file URIs `rootUri`, `workspaceFolders.uri`
  -- TODO: maybe file URIs should be left as is

  local new_params = deepcopy(params)

  new_params.rootPath = toWPath(params.rootPath)
  new_params.rootUri = onFileUri(params.rootUri, toWPath)

  new_params.workspaceFolders = map(params.workspaceFolders, function (folder)
    local new_folder = deepcopy(folder)
    new_folder.name = toWPath(folder.name)
    new_folder.uri = onFileUri(folder.uri, toWPath)
    return new_folder
  end)

  log:write('initialize.workspaceFoldersW', new_params.workspaceFolders)

  return new_params
end

local function willSaveWaitUntil(params)
  local new_params = deepcopy(params)

  new_params.textDocument.uri = onFileUri(params.textDocument.uri, toWPath)

  return new_params
end

local request_transform = {
  ['initialize'] = initialize,
  ["textDocument/willSaveWaitUntil"] = willSaveWaitUntil,
}
setmetatable(request_transform, {__index = function () return function (x)
  return x
end end})

local port = os.getenv 'GDScript_Port' or '6005'
local cmd = vim.lsp.rpc.connect('127.0.0.1', tonumber(port))
local wrapper = function(dispatchers)
  -- log:write("dispatchers", dispatchers)

  local notification = function(...)
    local log = require('./debug')
    if select(1, ...) ~= 'gdscript/capabilities' then
      log:write('peach notification', ...)
    end
    dispatchers.notification(...)
  end

  local server_request = function(...)
    local log = require('./debug')
    log:write('peach server_request')
    -- log:write('banana', a, b, c, d)
    -- log2.debug('split', a, b, c, d)
    dispatchers.server_request(...)
  end

  local new_dispatchers = {
    notification = notification,
    on_error = dispatchers.on_error,
    on_exit = dispatchers.on_exit,
    server_request = server_request
  }

  -- vim.print(new_dispatchers)

  -- log:write("new_dispatchers", new_dispatchers)
  -- log2.debug('wrapper(dispatchers)', dispatchers)
  local public_client = cmd(new_dispatchers)
  local log = require('./debug')
  -- log:write("public_client", public_client)

  local request = function (method, params, callback, notify_reply_callback)
    -- TODO: consider wrapping `callback` and `notify_reply_callback`

    local new_params = request_transform[method](params)
    -- if method ~= "initialize" then
      log:write('request', method, new_params, callback, notify_reply_callback)
    -- end

    public_client.request(method, new_params, callback, notify_reply_callback)
  end

  local new_public_client = {
    is_closing = public_client.is_closing,
    notify = public_client.notify,
    request = request,
    terminate = public_client.terminate,
  }
  return new_public_client
end

vim.lsp.config("gdscript", {
  cmd = wrapper,
})
vim.lsp.enable("gdscript")
