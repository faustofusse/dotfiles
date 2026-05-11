local M = {}

local parser = require('jira-sync.parser')
local api_client = require('jira-sync.api')
local buffer = require('jira-sync.buffer')

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
  }
end

--- Main sync function.
--- Reads current buffer, fetches tickets, merges, writes back.
function M.sync()
  local cfg = get_buffer_config()
  if not cfg then
    return
  end

  local scope = cfg.epic_key or cfg.project_key
  buffer.progress_begin(('Syncing %s tickets...'):format(scope))

  api_client.fetch_tickets(cfg.base_url, cfg.email, cfg.token, cfg.project_key, cfg.epic_key, function(tickets, err)
    if err then
      vim.schedule(function()
        buffer.progress_end('Sync failed')
        buffer.notify(err, vim.log.levels.ERROR)
      end)
      return
    end

    vim.schedule(function()
      buffer.progress_report(('Merging %d tickets...'):format(#tickets), 80)
      local merged = buffer.merge_tickets(cfg.lines, cfg.fm_end, tickets)
      buffer.set_buffer_lines(merged)
      buffer.progress_end(('Synced %d tickets'):format(#tickets))
      if #tickets == 0 then
        buffer.notify(
          ('Synced 0 tickets for %s. Check that the key is correct.'):format(scope),
          vim.log.levels.WARN
        )
      else
        buffer.notify(('Synced %d tickets for %s'):format(#tickets, scope), vim.log.levels.INFO)
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
        table.insert(msg, ('  Search: %s/rest/api/3/search/jql?jql="Epic Link"=%s'):format(base_url, epic_key))
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
