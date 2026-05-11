local M = {}

local api = vim.api
local buffer = require('jira-sync.buffer')

local subcommands = {
  sync = function(args)
    require('jira-sync').sync()
  end,
  open = function(args)
    require('jira-sync').open_ticket()
  end,
  info = function(args)
    require('jira-sync').info()
  end,
  test = function(args)
    require('jira-sync').test()
  end,
  projects = function(args)
    require('jira-sync').projects()
  end,
  debug = function(args)
    require('jira-sync').debug()
  end,
}

--- @param opts vim.api.keyset.create_user_command.command_args
function M.dispatch(opts)
  local cmd = opts.fargs[1]
  if not cmd or cmd == '' then
    buffer.notify('Usage: Jira {sync|open|info|test|projects|debug}', vim.log.levels.WARN)
    return
  end

  local action = subcommands[cmd]
  if not action then
    buffer.notify(('Unknown Jira subcommand: %s'):format(cmd), vim.log.levels.ERROR)
    return
  end

  action({ unpack(opts.fargs, 2) })
end

function M.complete(ArgLead, CmdLine, CursorPos)
  local split = vim.split(CmdLine, '%s+')
  if #split <= 2 then
    return vim.tbl_keys(subcommands)
  end
  return {}
end

return M
