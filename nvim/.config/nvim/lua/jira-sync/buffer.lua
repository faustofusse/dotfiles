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

--- Open a split buffer to prompt for transition field values.
--- Fugitive-commit-style: user edits, then saves (:w) or presses <Enter> to submit.
--- @param issue_key string
--- @param target_status string
--- @param transition table { id, to, required_fields = { {key, name}, ... } }
--- @param on_submit fun(values: table|nil)
---   values: { [field_key] = value_string } or nil if cancelled
--- @param prefills table<string, string>|nil field_key -> prefill value
function M.prompt_transition_fields(issue_key, target_status, transition, on_submit, prefills)
  vim.schedule(function()
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.bo[bufnr].buftype = 'acwrite'
  vim.bo[bufnr].bufhidden = 'wipe'
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].filetype = 'jira-transition'

  local lines = {
    '# Transition: ' .. issue_key .. ' → ' .. target_status,
    '#',
    '# Required fields:',
  }
  for _, f in ipairs(transition.required_fields) do
    local type_hint = ''
    if f.schema then
      if f.schema.type == 'user' then
        type_hint = ' (user/accountId)'
      elseif f.schema.type == 'doc' or f.schema.type == 'any' then
        type_hint = ' (rich text)'
      elseif f.schema.type == 'string' then
        type_hint = ' (text)'
      end
    end
    table.insert(lines, '#   - ' .. f.name .. type_hint)
  end
  table.insert(lines, '#')
  table.insert(lines, '# Fill in values below each field name.')
  table.insert(lines, '# Press <Enter> to submit, q to cancel.')
  table.insert(lines, '# Lines starting with # are ignored.')
  table.insert(lines, '')

  for _, f in ipairs(transition.required_fields) do
    local type_hint = ''
    if f.schema then
      if f.schema.type == 'user' then
        type_hint = ' [user/accountId]'
      elseif f.schema.type == 'doc' or f.schema.type == 'any' then
        type_hint = ' [rich text]'
      elseif f.schema.type == 'string' then
        type_hint = ' [text]'
      end
    end
    table.insert(lines, f.name .. type_hint .. ':')
    local prefill = prefills and prefills[f.key] or ''
    table.insert(lines, prefill)
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

  vim.cmd('belowright split')
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, bufnr)

  -- Position cursor on first editable line (first field value line after headers)
  local cursor_line
  if #transition.required_fields == 0 then
    -- No fields to edit; put cursor on last comment line
    cursor_line = #lines
  else
    cursor_line = #lines - (#transition.required_fields * 2) + 2
  end
  vim.api.nvim_win_set_cursor(win, { math.min(cursor_line, #lines), 0 })

  local submitted = false

  local function parse_and_submit()
    if submitted then
      return
    end

    local buf_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local values = {}
    local current_field_name = nil
    local current_lines = {}

    for _, line in ipairs(buf_lines) do
      if not line:match('^%s*#') then
        local field_header = line:match('^(.-):%s*$')
        if field_header then
          if current_field_name then
            for _, f in ipairs(transition.required_fields) do
              if f.name == current_field_name then
                values[f.key] = table.concat(current_lines, '\n'):match('^%s*(.-)%s*$') or ''
                break
              end
            end
          end
          -- Strip type hint like [rich text] from header to match field name
          current_field_name = (field_header:match('^(.-)%s*%[.*%]$') or field_header):match('^%s*(.-)%s*$')
          current_lines = {}
        elseif current_field_name then
          table.insert(current_lines, line)
        end
      end
    end

    if current_field_name then
      for _, f in ipairs(transition.required_fields) do
        if f.name == current_field_name then
          values[f.key] = table.concat(current_lines, '\n'):match('^%s*(.-)%s*$') or ''
          break
        end
      end
    end

    for _, f in ipairs(transition.required_fields) do
      if not values[f.key] or values[f.key] == '' then
        M.notify('Field "' .. f.name .. '" is required', vim.log.levels.WARN)
        return
      end
    end

    submitted = true
    vim.schedule(function()
      pcall(vim.api.nvim_win_close, win, true)
      on_submit(values)
    end)
  end

  local function cancel()
    if submitted then
      return
    end
    submitted = true
    pcall(vim.api.nvim_win_close, win, true)
    on_submit(nil)
  end

  vim.api.nvim_create_autocmd('BufWriteCmd', {
    buffer = bufnr,
    callback = parse_and_submit,
  })

  vim.keymap.set('n', '<CR>', parse_and_submit, { buffer = bufnr, silent = true, nowait = true })
  vim.keymap.set('n', 'q', cancel, { buffer = bufnr, silent = true, nowait = true })
  end)
end

return M
