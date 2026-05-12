local M = {}

local parser = require('jira-sync.parser')
local api_client = require('jira-sync.api')
local buffer = require('jira-sync.buffer')

local DEFAULT_STATUS_ORDER = {
  'Nuevo',
  'Por Hacer',
  'En curso',
  'En Revision',
  'Finalizado',
}

--- Extract and validate config from the current buffer.
--- @return table|nil config { project_key, epic_key, base_url, email, token, lines, fm_end, project_key_source }
local function get_buffer_config()
  local bufname = vim.api.nvim_buf_get_name(0)
  local lines = buffer.get_buffer_lines()
  local frontmatter, fm_end = parser.parse_frontmatter(lines)

  if not frontmatter then
    buffer.notify(
      'No YAML frontmatter found. Add --- block with jira_base_url, jira_email, jira_api_token',
      vim.log.levels.ERROR
    )
    return nil
  end

  local project_key = parser.normalize_project_key(frontmatter.jira_project_key)
  local epic_key = parser.normalize_issue_key(frontmatter.jira_epic)
  local project_key_source = 'frontmatter'

  if not project_key and not epic_key then
    project_key = parser.project_key_from_filename(bufname)
    project_key_source = 'filename'
  end

  if not project_key and not epic_key then
    buffer.notify(
      'Cannot determine Jira project. Set jira_project_key, jira_epic in frontmatter, or use <PROJECT>.md filename',
      vim.log.levels.ERROR
    )
    return nil
  end

  local base_url = frontmatter.jira_base_url
  local email = frontmatter.jira_email
  local token = frontmatter.jira_api_token

  local status_map = nil
  if frontmatter.jira_status_map then
    local raw = frontmatter.jira_status_map
    raw = raw:match("^'(.*)'$") or raw
    raw = raw:match('^"(.*)"$') or raw
    local ok, decoded = pcall(vim.json.decode, raw)
    if ok and type(decoded) == 'table' then
      status_map = decoded
    end
  end

  if not base_url or base_url == '' then
    buffer.notify('jira_base_url missing in frontmatter', vim.log.levels.ERROR)
    return nil
  end
  if not email or email == '' then
    buffer.notify('jira_email missing in frontmatter', vim.log.levels.ERROR)
    return nil
  end
  if not token or token == '' then
    buffer.notify('jira_api_token missing in frontmatter (use ${ENV_VAR} to reference env vars)', vim.log.levels.ERROR)
    return nil
  end

  return {
    project_key = project_key,
    epic_key = epic_key,
    project_key_source = project_key_source,
    base_url = base_url,
    email = email,
    token = token,
    lines = lines,
    fm_end = fm_end,
    status_map = status_map,
  }
end

--- Main sync function.
--- Reads current buffer, fetches tickets, pushes local status changes, merges, writes back.
function M.sync()
  local cfg = get_buffer_config()
  if not cfg then
    return
  end

  local local_brackets = buffer.extract_local_brackets(cfg.lines, cfg.fm_end)
  local last_brackets = vim.b.jira_sync_brackets
  local reverse_map = buffer.build_reverse_status_map(cfg.status_map)

  local scope = cfg.epic_key or cfg.project_key
  buffer.progress_begin(('Syncing %s tickets...'):format(scope))

  local function finalize(tickets, failure_msgs)
    vim.schedule(function()
      buffer.progress_report(('Merging %d tickets...'):format(#tickets), 80)
      local merged = buffer.merge_tickets(cfg.lines, cfg.fm_end, tickets)
      buffer.set_buffer_lines(merged)
      vim.b.jira_sync_brackets = buffer.extract_local_brackets(merged, cfg.fm_end)
      buffer.progress_end(('Synced %d tickets'):format(#tickets))
      local msg = ('Synced %d tickets for %s'):format(#tickets, scope)
      if #tickets == 0 then
        msg = ('Synced 0 tickets for %s. Check that the key is correct.'):format(scope)
        buffer.notify(msg, vim.log.levels.WARN)
      elseif failure_msgs and #failure_msgs > 0 then
        buffer.notify(msg .. '\n' .. table.concat(failure_msgs, '\n'), vim.log.levels.WARN)
      else
        buffer.notify(msg, vim.log.levels.INFO)
      end
    end)
  end

  api_client.fetch_tickets(cfg.base_url, cfg.email, cfg.token, cfg.project_key, cfg.epic_key, function(tickets, err)
    if err then
      vim.schedule(function()
        buffer.progress_end('Sync failed')
        buffer.notify(err, vim.log.levels.ERROR)
      end)
      return
    end

    local ticket_map = {}
    for _, t in ipairs(tickets) do
      ticket_map[t.key] = t
    end

    local updates = {}
    if last_brackets then
      for key, local_bracket in pairs(local_brackets) do
        local last_bracket = last_brackets[key]
        if last_bracket and local_bracket ~= last_bracket then
          local desired_status = reverse_map[local_bracket]
          local ticket = ticket_map[key]
          if desired_status and ticket and desired_status ~= ticket.status then
            table.insert(updates, { key = key, status = desired_status })
          end
        end
      end
    end

    if #updates == 0 then
      finalize(tickets, nil)
      return
    end

    buffer.progress_report(('Pushing %d status updates...'):format(#updates), 40)

    local completed = 0
    local failures = {}

    local function check_done()
      completed = completed + 1
      if completed == #updates then
        finalize(tickets, failures)
      end
    end

    local samples = {}
    for _, t in ipairs(tickets) do
      table.insert(samples, { key = t.key, status = t.status })
    end

    local function process_updates(graph)
      for _, update in ipairs(updates) do
        local ticket = ticket_map[update.key]
        local current_status = ticket and ticket.status or 'Unknown'

        local function on_transition_done(ok, err_msg, actual_status)
          if ok then
            if ticket_map[update.key] then
              ticket_map[update.key].status = update.status
            end
          else
            if actual_status and ticket_map[update.key] then
              ticket_map[update.key].status = actual_status
            end
            table.insert(failures, ('%s: %s'):format(update.key, err_msg))
          end
          check_done()
        end

        local function fallback_chain(err_msg)
          api_client.transition_chain(
            cfg.base_url, cfg.email, cfg.token,
            update.key, update.status, current_status, DEFAULT_STATUS_ORDER,
            function(ok2, err2, actual2)
              if ok2 then
                on_transition_done(true, nil)
              else
                on_transition_done(false, err2 or err_msg, actual2)
              end
            end
          )
        end

        if graph and graph[current_status] and graph[current_status][update.status] then
          -- Direct transition available in graph
          api_client.transition_issue(
            cfg.base_url, cfg.email, cfg.token,
            update.key, graph[current_status][update.status],
            function(ok, err)
              if ok then
                on_transition_done(true, nil)
              else
                on_transition_done(false, err)
              end
            end
          )
        elseif graph then
          local path = api_client.find_path_bfs(graph, current_status, update.status)
          if path and #path > 0 then
            api_client.execute_graph_path(
              cfg.base_url, cfg.email, cfg.token,
              update.key, graph, path, current_status,
              function(ok, err_msg, actual_status)
                if ok then
                  on_transition_done(true, nil)
                else
                  fallback_chain(err_msg)
                end
              end
            )
          else
            fallback_chain(('No path from "%s" to "%s" in global graph'):format(current_status, update.status))
          end
        else
          fallback_chain('No transition graph available')
        end
      end
    end

    api_client.build_transition_graph(cfg.base_url, cfg.email, cfg.token, samples, function(graph, graph_err)
      if graph_err then
        process_updates(nil)
      else
        process_updates(graph)
      end
    end)
  end)
end

--- Open the Jira ticket under cursor in the default browser.
function M.open_ticket()
  local cfg = get_buffer_config()
  if not cfg then
    return
  end

  local cursor_line = vim.api.nvim_get_current_line()
  local key = cursor_line:match('([A-Z0-9]+%-%d+)')

  if not key then
    buffer.notify('No ticket key found on current line', vim.log.levels.WARN)
    return
  end

  local url = ('%s/browse/%s'):format(cfg.base_url, key)
  vim.ui.open(url)
end

--- Show parsed config and project key for the current buffer.
function M.info()
  local bufname = vim.api.nvim_buf_get_name(0)
  local lines = buffer.get_buffer_lines()
  local frontmatter, fm_end = parser.parse_frontmatter(lines)

  local raw_project = frontmatter and frontmatter.jira_project_key
  local project_key = parser.normalize_project_key(raw_project)
  local raw_epic = frontmatter and frontmatter.jira_epic
  local epic_key = parser.normalize_issue_key(raw_epic)
  local project_key_source = 'frontmatter'

  if not project_key and not epic_key then
    project_key = parser.project_key_from_filename(bufname)
    project_key_source = 'filename'
  end

  local msg = {}
  table.insert(msg, 'Jira Sync Info')
  table.insert(msg, '==============')
  table.insert(msg, ('Filename:    %s'):format(vim.fn.fnamemodify(bufname, ':t')))

  if epic_key then
    table.insert(msg, ('Epic:        %s'):format(epic_key))
    table.insert(msg, ('Project key: %s (derived from epic)'):format(
      parser.normalize_project_key(epic_key) or '<not detected>'
    ))
  else
    table.insert(msg, ('Project key: %s (from %s)'):format(
      project_key or '<not detected>',
      project_key_source
    ))
  end

  if frontmatter then
    table.insert(msg, ('Frontmatter: found (ends at line %d)'):format(fm_end))
    local base_url = frontmatter.jira_base_url or '<missing>'
    table.insert(msg, ('Base URL:    %s'):format(base_url))
    table.insert(msg, ('Email:       %s'):format(frontmatter.jira_email or '<missing>'))
    local token = frontmatter.jira_api_token
    if token and token ~= '' then
      local masked = #token > 8 and (token:sub(1, 4) .. '...' .. token:sub(-4)) or '<set>'
      table.insert(msg, ('API Token:   %s'):format(masked))
    else
      table.insert(msg, 'API Token:   <missing>')
    end
    if base_url:match('^https?://') then
      table.insert(msg, '')
      table.insert(msg, 'URLs that will be called:')
      if epic_key then
        table.insert(msg, ('  Search: %s/rest/api/3/search/jql?jql=parent=%s'):format(base_url, epic_key))
      elseif project_key then
        table.insert(msg, ('  Project check: %s/rest/api/3/project/%s'):format(base_url, project_key))
        table.insert(msg, ('  Search:        %s/rest/api/3/search/jql?jql=project=%s'):format(base_url, project_key))
      end
    end
  else
    table.insert(msg, 'Frontmatter: <not found>')
  end

  buffer.notify(table.concat(msg, '\n'), vim.log.levels.INFO)
end

--- Test connectivity to Jira and verify the project exists.
function M.test()
  local cfg = get_buffer_config()
  if not cfg then
    return
  end

  -- Derive project key from epic if needed
  local test_key = cfg.project_key or parser.normalize_project_key(cfg.epic_key)

  buffer.progress_begin('Testing Jira connection...')

  api_client.test_project(cfg.base_url, cfg.email, cfg.token, test_key, function(result, err)
    if err then
      vim.schedule(function()
        buffer.progress_end('Connection test failed')
        buffer.notify(err, vim.log.levels.ERROR)
      end)
      return
    end

    vim.schedule(function()
      buffer.progress_end('Connection test passed')
      local msg = {}
      table.insert(msg, 'Jira connection OK')
      table.insert(msg, ('Project:     %s'):format(result.name or test_key))
      table.insert(msg, ('Project key: %s'):format(result.key or '?'))
      table.insert(msg, ('Issue types: %s'):format(
        result.issueTypes and table.concat(
          vim.iter(result.issueTypes):map(function(it) return it.name end):totable(),
          ', '
        ) or 'N/A'
      ))
      buffer.notify(table.concat(msg, '\n'), vim.log.levels.INFO)
    end)
  end)
end

--- List all accessible Jira projects for this API key.
function M.projects()
  local lines = buffer.get_buffer_lines()
  local frontmatter, _ = parser.parse_frontmatter(lines)

  if not frontmatter then
    buffer.notify(
      'No YAML frontmatter found. Add --- block with jira_base_url, jira_email, jira_api_token',
      vim.log.levels.ERROR
    )
    return
  end

  local base_url = frontmatter.jira_base_url
  local email = frontmatter.jira_email
  local token = frontmatter.jira_api_token

  if not base_url or base_url == '' then
    buffer.notify('jira_base_url missing in frontmatter', vim.log.levels.ERROR)
    return
  end
  if not email or email == '' then
    buffer.notify('jira_email missing in frontmatter', vim.log.levels.ERROR)
    return
  end
  if not token or token == '' then
    buffer.notify('jira_api_token missing in frontmatter', vim.log.levels.ERROR)
    return
  end

  buffer.progress_begin('Fetching accessible projects...')

  api_client.list_projects(base_url, email, token, function(projects, err)
    if err then
      vim.schedule(function()
        buffer.progress_end('Failed to fetch projects')
        buffer.notify(err, vim.log.levels.ERROR)
      end)
      return
    end

    vim.schedule(function()
      buffer.progress_end(('Found %d projects'):format(#projects))
      if #projects == 0 then
        buffer.notify('No projects found for this API key.', vim.log.levels.WARN)
        return
      end

      local msg = {}
      table.insert(msg, ('Accessible Jira Projects (%d):'):format(#projects))
      table.insert(msg, '===========================')
      for _, p in ipairs(projects) do
        table.insert(msg, ('  %s — %s'):format(p.key or '?', p.name or 'Unnamed'))
      end
      buffer.notify(table.concat(msg, '\n'), vim.log.levels.INFO)
    end)
  end)
end

--- Show the exact curl command to test Jira authentication manually.
function M.debug()
  local lines = buffer.get_buffer_lines()
  local frontmatter, _ = parser.parse_frontmatter(lines)

  if not frontmatter then
    buffer.notify(
      'No YAML frontmatter found. Add --- block with jira_base_url, jira_email, jira_api_token',
      vim.log.levels.ERROR
    )
    return
  end

  local base_url = frontmatter.jira_base_url or '<missing>'
  local email = frontmatter.jira_email or '<missing>'
  local token = frontmatter.jira_api_token or '<missing>'

  local msg = {}
  table.insert(msg, 'Debug: Test these commands in your terminal')
  table.insert(msg, '============================================')
  table.insert(msg, '')
  table.insert(msg, '1. Test connection (list projects):')
  table.insert(msg, ('curl -s -u "%s:<API_TOKEN>" "%s/rest/api/3/project" | jq'):format(email, base_url))
  table.insert(msg, '')
  table.insert(msg, '2. Test a specific project:')
  local project_key = frontmatter.jira_project_key or '<set jira_project_key in frontmatter>'
  table.insert(msg, ('curl -s -u "%s:<API_TOKEN>" "%s/rest/api/3/project/%s" | jq'):format(email, base_url, project_key))
  table.insert(msg, '')
  table.insert(msg, '3. Test search:')
  table.insert(msg, ('curl -s -u "%s:<API_TOKEN>" "%s/rest/api/3/search/jql?jql=project=%s&maxResults=1" | jq'):format(email, base_url, project_key))
  table.insert(msg, '')
  table.insert(msg, 'Note: Replace <API_TOKEN> with your actual token or use the env var')

  buffer.notify(table.concat(msg, '\n'), vim.log.levels.INFO)
end

return M
