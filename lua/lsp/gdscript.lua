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

local wsl_path = {}

function wsl_path.win_to_wsl(path)
  path = path:gsub("\\", "/")

  local drive, rest = path:match("^(%a):/(.*)$")
  drive = drive:lower()
  return "/mnt/" .. drive .. "/" .. rest
end

function wsl_path.wsl_to_win(path)
  local drive, rest = path:match("^/mnt/(%a)/(.*)$")
  drive = drive:upper()
  rest = rest:gsub("/", "\\")
  return drive .. ":\\" .. rest
end

local function onFileUri(f, maybe_str)
  local function run(str)
    local prefix = "file://"
    local prefix_len = string.len(prefix)
    if string.sub(str, 1, prefix_len) == prefix then
      return vim.uri_from_fname(f(vim.uri_to_fname(str)))
    end
    return str
  end

  if maybe_str == nil then
    return run
  else
    return run(maybe_str)
  end
end

local function toWPath(path)
  -- local wslpath_result = vim.trim(vim.system({'wslpath', '-w', path}, { text = true }):wait().stdout)
  -- local custom_result = wsl_path.wsl_to_win(path)
  -- if wslpath_result ~= custom_result then
  --   require("./debug"):write(string.format("toWPath divergence: %s <=> %s", wslpath_result, custom_result))
  -- end
  -- return wslpath_result
  return wsl_path.wsl_to_win(path)
end

local function toUPath(path)
  -- local wslpath_result = vim.trim(vim.system({'wslpath', '-u', path}, { text = true }):wait().stdout)
  -- local custom_result = wsl_path.win_to_wsl(path)
  -- if wslpath_result ~= custom_result then
  --   require("./debug"):write(string.format("toUPath divergence: %s <=> %s", wslpath_result, custom_result))
  -- end
  -- return wslpath_result
  return wsl_path.win_to_wsl(path)
end

local function initialize(params)
  -- local log = require('./debug')
  -- log:write('dbg.initialize', params)
  params.rootPath = toWPath(params.rootPath)
  params.rootUri = onFileUri(toWPath, params.rootUri)

  params.workspaceFolders = map(params.workspaceFolders, function (folder)
    folder.name = toWPath(folder.name)
    folder.uri = onFileUri(toWPath, folder.uri)
    return folder
  end)

  return params
end

local function publishDiagnostics(params)
  local new_params = deepcopy(params)
  new_params.uri = onFileUri(toUPath, params.uri)
  return new_params
end

local function changeWorkspace(params)
  -- local log = require('./debug')
  -- log:write('changeWorkspace', params)
  local new_params = deepcopy(params)
  new_params.path = toUPath(params.path)
  return new_params
end

local function onParams(f)
  return function (params)
    return f(deepcopy(params))
  end
end

local function onKey(key, f)
  return function (params)
    params[key] = f(params[key])
    return params
  end
end

--[[
local function dbg(method, f)
  return function (params)
    local new_params = f(params)
    local log = require('./debug')
    log:write(method, new_params)
    return new_params
  end
end
--]]

local function textDocument_uri(f)
  return onParams(onKey("textDocument", onKey("uri", onFileUri(f))))
end

local function identity(params)
  return params
end

local function defaultTransform(context)
  local log = require('./debug')
  return function(_, method)
    return function (params)
      log:write(context, method, params)
      return params
    end
  end
end

-- Client ==> LSP
local request_transform = {
  ["completionItem/resolve"] = onParams(onKey("data", textDocument_uri(toWPath))),
  ["shutdown"] = identity,
  ["textDocument/completion"] = textDocument_uri(toWPath),
  ["textDocument/definition"] = textDocument_uri(toWPath),
  ["textDocument/hover"] = textDocument_uri(toWPath),
  ["textDocument/signatureHelp"] = textDocument_uri(toWPath),
  ["textDocument/willSaveWaitUntil"] = textDocument_uri(toWPath),
  ['initialize'] = onParams(initialize),
}
setmetatable(request_transform, {__index = defaultTransform('request_transform')})

-- Client ==> LSP
local notify_transform = {
  ["initialized"] = identity,
  ["textDocument/didChange"] = textDocument_uri(toWPath),
  ["textDocument/didClose"] = textDocument_uri(toWPath),
  ["textDocument/didOpen"] = textDocument_uri(toWPath),
  ["textDocument/didSave"] = textDocument_uri(toWPath),
}
setmetatable(notify_transform, {__index = defaultTransform('notify_transform')})

-- Client <== Server
local notification_transform = {
  ["gdscript/capabilities"] = identity,
  ["gdscript_client/changeWorkspace"] = changeWorkspace,
  ["textDocument/publishDiagnostics"] = publishDiagnostics,
}
setmetatable(notification_transform, {__index = defaultTransform('notification_transform')})

-- Client <== Server
local server_request_transform = {
}
setmetatable(server_request_transform, {__index = defaultTransform('server_request_transform')})

local function onResult(f)
  return function (error, result)
    if error ~= nil then
      local log = require('./debug')
      log:write("onResult.error", error)
    end
    return error, f(result)
  end
end

local function onResults(f)
  return function (error, results)
    if error ~= nil then
      local log = require('./debug')
      log:write("onResults.error", error)
    end
    return error, map(results, f)
  end
end

local function biIdentity(error, result)
  if error ~= nil then
    local log = require('./debug')
    log:write("biIdentity.error", error)
  end
  return error, result
end

--[[
local function dbg2(method, f)
  return function (error, result)
    local new_error, new_params = f(error, result)
    local log = require('./debug')
    log:write(method, new_error, new_params)
    return new_error, new_params
  end
end
--]]

local function defaultCallbackTransform(context)
  local log = require('./debug')
  return function(_, method)
    return function (error, result)
      log:write(context, method, error, result)
      return error, result
    end
  end
end

-- Client <== Server
local request_callback_transform = {
  ["completionItem/resolve"] = onResult(onKey("data", textDocument_uri(toUPath))),
  ["initialize"] = biIdentity,
  ["textDocument/completion"] = onResults(onKey("data", textDocument_uri(toUPath))),
  ["textDocument/definition"] = onResults(onKey("uri", onFileUri(toUPath))),
  ["textDocument/hover"] = biIdentity,
  ["textDocument/signatureHelp"] = biIdentity,
  ["textDocument/willSaveWaitUntil"] = biIdentity,
}
setmetatable(request_callback_transform, {__index = defaultCallbackTransform('request_callback_transform')})

local port = os.getenv 'GDScript_Port' or '6005'
local cmd = vim.lsp.rpc.connect('127.0.0.1', tonumber(port))
local wrapper = function(dispatchers)
  -- log:write("dispatchers", dispatchers)

  local notification = function(method, params)
    local new_params = notification_transform[method](params)
    -- local log = require('./debug')
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

  local function request(method, params, callback, notify_reply_callback)
    -- TODO: consider wrapping `callback` and `notify_reply_callback`

    local new_params = request_transform[method](params)
    -- if method ~= "initialize" then
      -- log:write('request', method, new_params, callback, notify_reply_callback)
    -- end

    local function new_callback(error, result)
      local new_error, new_result = request_callback_transform[method](error, result)
      return callback(new_error, new_result)
    end

    public_client.request(method, new_params, new_callback, notify_reply_callback)
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
