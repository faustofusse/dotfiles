local M = {}

local api = vim.api

--- @param msg string
--- @param level string 'begin'|'report'|'end'
--- @param percent integer 0-100
local function notify_progress(msg, level, percent)
  local progress = {
    kind = 'progress',
    source = 'jira-sync',
    title = 'Jira Sync',
    status = level == 'end' and 'success' or 'running',
    percent = percent or (level == 'begin' and 0 or (level == 'end' and 100 or 50)),
  }
  vim.schedule(function()
    api.nvim_echo({ { msg } }, level ~= 'report', progress)
  end)
end

function M.progress_begin(msg)
  notify_progress(msg, 'begin', 0)
end

function M.progress_report(msg, percent)
  notify_progress(msg, 'report', percent)
end

function M.progress_end(msg)
  notify_progress(msg, 'end', 100)
end

--- Send a message to :messages, bypassing vim.notify (and thus fidget).
--- Safe to call from async/fast-event callbacks.
--- @param msg string
--- @param level? integer vim.log.levels value
function M.notify(msg, level)
  vim.schedule(function()
    local hl
    if level == vim.log.levels.ERROR then
      hl = 'ErrorMsg'
    elseif level == vim.log.levels.WARN then
      hl = 'WarningMsg'
    end
    api.nvim_echo({ { msg, hl } }, true, {})
  end)
end

--- Read all lines from the current buffer.
--- @return string[]
function M.get_buffer_lines()
  local bufnr = api.nvim_get_current_buf()
  local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
  return lines
end

--- Write lines to the current buffer, replacing content after frontmatter.
--- @param lines string[] all lines including frontmatter
function M.set_buffer_lines(lines)
  local bufnr = api.nvim_get_current_buf()
  api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
end

--- Map Jira status names to markdown checkbox bracket content.
--- @param status string raw Jira status name
--- @return string bracket content (single char or status)
function M.format_status(status)
  local map = {
    ['Nuevo'] = ' ',
    ['Por Hacer'] = 'p',
    ['Finalizado'] = 'x',
    ['En curso'] = '~',
    ['En Revision'] = 'r',
    ['Cancelado'] = 'c',
  }
  return map[status] or status
end

--- Merge fetched tickets with existing buffer lines.
--- Preserves notes (text after summary) for existing tickets.
--- Appends new tickets at the end.
--- @param existing_lines string[]
--- @param frontmatter_end integer 0-indexed line where frontmatter ends
--- @param tickets jira_sync.Ticket[]
--- @return string[] merged_lines
function M.merge_tickets(existing_lines, frontmatter_end, tickets)
  local merged = {}

  -- Copy everything up to and including frontmatter
  for i = 1, frontmatter_end do
    table.insert(merged, existing_lines[i])
  end

  -- Build lookup: ticket key -> ticket data from Jira
  local tickets_by_key = {}
  for _, ticket in ipairs(tickets) do
    tickets_by_key[ticket.key] = ticket
  end

  local line_pattern = '^%s*%-%s*%[([^%]]*)%]%s*([A-Z0-9]+%-%d+):%s*(.*)$'
  local used_keys = {}

  -- Iterate existing lines after frontmatter, replacing/updating ticket lines in-place
  for i = frontmatter_end + 1, #existing_lines do
    local line = existing_lines[i]
    local _, key, rest = line:match(line_pattern)

    if key and tickets_by_key[key] then
      -- This ticket exists in Jira: update status, preserve rest (summary + notes)
      used_keys[key] = true
      local bracket = M.format_status(tickets_by_key[key].status)
      table.insert(merged, ('- [%s] %s: %s'):format(bracket, key, rest))
    else
      -- Non-ticket line or ticket no longer in Jira: preserve as-is
      table.insert(merged, line)
    end
  end

  -- Append any new tickets that weren't in the original file
  for _, ticket in ipairs(tickets) do
    if not used_keys[ticket.key] then
      local bracket = M.format_status(ticket.status)
      table.insert(merged, ('- [%s] %s: %s'):format(bracket, ticket.key, ticket.summary))
    end
  end

  return merged
end

--- Extract current checkbox brackets for each ticket key in the buffer.
--- @param lines string[]
--- @param frontmatter_end integer
--- @return table<string, string> key -> bracket
function M.extract_local_brackets(lines, frontmatter_end)
  local brackets = {}
  local pattern = '^%s*%-%s*%[([^%]]*)%]%s*([A-Z0-9]+%-%d+):%s*(.*)$'
  for i = frontmatter_end + 1, #lines do
    local bracket, key = lines[i]:match(pattern)
    if key then
      brackets[key] = bracket
    end
  end
  return brackets
end

--- Build a reverse map from bracket character to Jira status name.
--- Uses built-in defaults and optional user-provided overrides.
--- @param custom_map table<string, string>|nil bracket -> status
--- @return table<string, string>
function M.build_reverse_status_map(custom_map)
  local reverse = {}
  local forward = {
    ['Nuevo'] = ' ',
    ['Por Hacer'] = 'p',
    ['Finalizado'] = 'x',
    ['En curso'] = '~',
    ['En Revision'] = 'r',
    ['Cancelado'] = 'c',
  }
  for status, bracket in pairs(forward) do
    reverse[bracket] = status
  end
  if custom_map then
    for bracket, status in pairs(custom_map) do
      reverse[bracket] = status
    end
  end
  return reverse
end

return M
