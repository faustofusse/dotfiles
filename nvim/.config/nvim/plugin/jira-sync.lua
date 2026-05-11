-- plugin/jira-sync.lua
-- Entry point: registers the :Jira command (with :jira abbreviation)

vim.api.nvim_create_user_command('Jira', function(opts)
  require('jira-sync.commands').dispatch(opts)
end, {
  nargs = '*',
  desc = 'Jira ticket management',
  complete = function(ArgLead, CmdLine, CursorPos)
    return require('jira-sync.commands').complete(ArgLead, CmdLine, CursorPos)
  end,
})

-- Allow typing :jira (lowercase) by expanding to :Jira when it's the whole command line
vim.cmd([[cabbrev <expr> jira getcmdtype() == ':' && getcmdline() ==# 'jira' ? 'Jira' : 'jira']])
