---[[

local log_date_format = '%F %H:%M:%S'
local function format_func(level, ...)
  -- if log_levels[level] < current_log_level then
  --   return nil
  -- end

  -- local info = debug.getinfo(2, 'Sl')
  local header = string.format(
    '[%s][%s] %s',
    level,
    os.date(log_date_format),
    debug.traceback()
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

---]]

-- vim.lsp.log.set_level(1)
vim.lsp.log.set_level(vim.log.levels.TRACE)
-- require('vim.lsp.log').set_format_func(format_func)
vim.lsp.log.set_format_func(format_func)

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
    -- local log = require('./debug')
    -- log:write('((vim.uri_to_fname(str)))', ((vim.uri_to_fname(str))))
    -- log:write('(f(vim.uri_to_fname(str)))', (f(vim.uri_to_fname(str))))
    -- log:write('vim.uri_from_fname(f(vim.uri_to_fname(str)))', vim.uri_from_fname(f(vim.uri_to_fname(str))))
    return vim.uri_from_fname(f(vim.uri_to_fname(str)))
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
  -- local log = require('./debug')

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

  -- log:write('initialize.workspaceFoldersW', new_params.workspaceFolders)

  return new_params
end

local function publishDiagnostics(params)
  local new_params = deepcopy(params)
  new_params.uri = onFileUri(params.uri, toUPath)
  return new_params
end

local function changeWorkspace(params)
  -- local log = require('./debug')
  -- log:write('changeWorkspace', params)
  local new_params = deepcopy(params)
  new_params.path = toUPath(params.path)
  return new_params
end

local function defaultTransform(context)
  local log = require('./debug')
  return function(_, method)
    return function (params)
      log:write(context, method, params)
    end
  end
end

local function onParams(f)
  return function (params)
    return f(deepcopy(params))
  end
end

local function textDocument_uri(f)
  return onParams(function (params)
    params.textDocument.uri = onFileUri(params.textDocument.uri, f)
    -- local log = require('./debug')
    -- log:write('uri.onParams', params)
    return params
  end)
end

local function identity(params)
  return params
end

-- Client ==> LSP
local request_transform = {
  ['initialize'] = initialize,
  ["shutdown"] = identity,
  ["textDocument/completion"] = textDocument_uri(toWPath),
  ["textDocument/hover"] = textDocument_uri(toWPath),
  ["textDocument/signatureHelp"] = textDocument_uri(toWPath),
  ["textDocument/willSaveWaitUntil"] = textDocument_uri(toWPath),
}
setmetatable(request_transform, {__index = defaultTransform('request_transform')})

-- Client ==> LSP
local notify_transform = {
  ["textDocument/didSave"] = textDocument_uri(toWPath),
  ["textDocument/didOpen"] = textDocument_uri(toWPath),
  ["textDocument/didChange"] = textDocument_uri(toWPath),
  ["textDocument/didClose"] = textDocument_uri(toWPath),
  ["initialized"] = identity,
}
setmetatable(notify_transform, {__index = defaultTransform('notify_transform')})

-- Client <== Server
local notification_transform = {
  ["textDocument/publishDiagnostics"] = publishDiagnostics,
  ["gdscript_client/changeWorkspace"] = changeWorkspace,
  ["gdscript/capabilities"] = identity,
}
setmetatable(notification_transform, {__index = defaultTransform('notification_transform')})

-- Client <== Server
local server_request_transform = {
}
setmetatable(server_request_transform, {__index = defaultTransform('server_request_transform')})

local port = os.getenv 'GDScript_Port' or '6005'
local cmd = vim.lsp.rpc.connect('127.0.0.1', tonumber(port))
local wrapper = function(dispatchers)
  -- log:write("dispatchers", dispatchers)

  local notification = function(method, params)
    -- local log = require('./debug')
    -- if select(1, method) ~= 'gdscript/capabilities' then
    --   log:write('peach notification', method, params)
    -- end
    local new_params = notification_transform[method](params)
    -- log:write('notification', method, new_params)
    dispatchers.notification(method, new_params)
  end

  local server_request = function(method, params)
    local new_params = server_request_transform[method](params)
    -- local log = require('./debug')
    -- log:write('server_request', method, new_params)
    dispatchers.server_request(method, new_params)
  end

  local new_dispatchers = deepcopy(dispatchers)
  new_dispatchers.notification = notification
  new_dispatchers.server_request = server_request

  -- vim.print(new_dispatchers)

  -- log:write("new_dispatchers", new_dispatchers)
  -- log2.debug('wrapper(dispatchers)', dispatchers)
  local public_client = cmd(new_dispatchers)
  -- local log = require('./debug')
  -- log:write("public_client", public_client)

  local request = function (method, params, callback, notify_reply_callback)
    -- TODO: consider wrapping `callback` and `notify_reply_callback`

    local new_params = request_transform[method](params)
    -- if method ~= "initialize" then
      -- log:write('request', method, new_params, callback, notify_reply_callback)
    -- end

    public_client.request(method, new_params, callback, notify_reply_callback)
  end

  local function notify(method, params)
    local new_params = notify_transform[method](params)
    -- log:write('notify', method, new_params)
    public_client.notify(method, new_params)
  end

  local new_public_client = deepcopy(public_client)
  new_public_client.notify = notify
  new_public_client.request = request

  return new_public_client
end

vim.lsp.config("gdscript", {
  cmd = wrapper,
})
vim.lsp.enable("gdscript")
