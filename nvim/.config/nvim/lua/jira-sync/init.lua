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

    local failures = {}
    local samples = {}
    for _, t in ipairs(tickets) do
      table.insert(samples, { key = t.key, status = t.status })
    end

    -- Helper: convert plain text to Atlassian Document Format
    local function to_adf(text)
      return {
        type = 'doc',
        version = 1,
        content = {
          {
            type = 'paragraph',
            content = {
              { type = 'text', text = text or '' },
            },
          },
        },
      }
    end

    -- Helper: transform user-provided values based on field schemas
    local function transform_fields(values, schemas, my_account_id)
      local result = {}
      for key, val in pairs(values) do
        local schema = schemas and schemas[key]
        if schema then
          if schema.type == 'user' or key == 'assignee' then
            -- Assignee expects { accountId = '...' }
            if val == my_account_id then
              result[key] = { accountId = my_account_id }
            elseif val:match('@') then
              -- User typed an email; try to use it as-is (Jira may resolve it)
              result[key] = { name = val }
            else
              result[key] = { accountId = val }
            end
          elseif key == 'summary' then
            -- Summary is always plain string
            result[key] = val
          elseif key == 'description' or key == 'comment' then
            -- Standard rich-text fields always need ADF in API v3
            result[key] = to_adf(val)
          elseif schema.type == 'doc' or schema.type == 'any' then
            result[key] = to_adf(val)
          elseif schema.type == 'string' and schema.custom then
            -- Custom string field: textarea needs ADF, textfield is plain
            local custom_type = schema.custom or ''
            if custom_type:match('textfield') and not custom_type:match('textarea') then
              result[key] = val
            else
              -- textarea, wikitext, or unknown custom string → ADF
              result[key] = to_adf(val)
            end
          elseif schema.type == 'string' then
            -- System string field without custom info: description-like fields need ADF
            -- Only summary is known to be plain; everything else string → ADF on retry
            result[key] = to_adf(val)
          else
            result[key] = val
          end
        else
          -- No schema info (inferred from error): try ADF for text, plain for others
          if type(val) == 'string' and val:match('^%d+$') then
            -- Looks like an ID
            result[key] = val
          else
            result[key] = to_adf(val)
          end
        end
      end
      return result
    end

    api_client.get_myself(cfg.base_url, cfg.email, cfg.token, function(myself, myself_err)
      local my_account_id = myself and myself.accountId

      local function process_updates(graph)
        local update_index = 1

        local function process_next()
          if update_index > #updates then
            finalize(tickets, failures)
            return
          end

          local update = updates[update_index]
          local ticket = ticket_map[update.key]
          local current_status = ticket and ticket.status or 'Unknown'

          local function on_done(ok, err_msg, actual_status)
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
            update_index = update_index + 1
            process_next()
          end

          -- Query specific issue transitions first
          api_client.get_transitions(cfg.base_url, cfg.email, cfg.token, update.key, function(transitions, err)
            if err then
              on_done(false, err)
              return
            end

            -- Try direct transition
            local direct = nil
            for _, t in ipairs(transitions) do
              if t.to and t.to.name == update.status then
                direct = t
                break
              end
            end

            if direct then
              local meta_schemas = {}

              local function try_direct(raw_values)
                local fields = raw_values and transform_fields(raw_values, meta_schemas, my_account_id) or nil
                api_client.transition_issue(cfg.base_url, cfg.email, cfg.token, update.key, direct.id, function(ok, err2, err_data)
                  if ok then
                    on_done(true)
                    return
                  end

                  if raw_values then
                    -- Already retried with user-provided fields; fail permanently
                    on_done(false, err2)
                    return
                  end

                  -- First failure — try to discover required fields and prompt
                  local function prompt_and_retry(transition_fields)
                    if not transition_fields or #transition_fields == 0 then
                      on_done(false, err2)
                      return
                    end
                    -- Build schema lookup for the prompt result
                    for _, f in ipairs(transition_fields) do
                      if f.schema and next(f.schema) then
                        meta_schemas[f.key] = f.schema
                      end
                    end
                    local prompt_transition = vim.deepcopy(direct)
                    prompt_transition.required_fields = transition_fields

                    -- Pre-fill user/assignee fields with current user's accountId
                    local prefills = {}
                    if my_account_id then
                      for _, f in ipairs(transition_fields) do
                        local schema = f.schema or {}
                        if schema.type == 'user' or f.key == 'assignee' then
                          prefills[f.key] = my_account_id
                        end
                      end
                    end

                    buffer.prompt_transition_fields(update.key, update.status, prompt_transition, function(values)
                      if values then
                        try_direct(values)
                      else
                        on_done(false, 'User cancelled')
                      end
                    end, prefills)
                  end

                  -- Always query transition meta for proper schemas,
                  -- then merge with inferred field names from error response.
                  api_client.get_transition_meta(cfg.base_url, cfg.email, cfg.token, update.key, direct.id, function(meta_fields, meta_err)
                    local merged_fields = {}

                    if meta_fields and #meta_fields > 0 then
                      for _, mf in ipairs(meta_fields) do
                        table.insert(merged_fields, mf)
                      end
                    end

                    -- Merge inferred field names (from error) for any fields meta missed
                    if err_data and err_data.errors and next(err_data.errors) then
                      local meta_keys = {}
                      for _, mf in ipairs(merged_fields) do
                        meta_keys[mf.key] = true
                      end
                      for field_key, msg in pairs(err_data.errors) do
                        if not meta_keys[field_key] then
                          table.insert(merged_fields, {
                            key = field_key,
                            name = msg,
                            schema = {},
                          })
                        end
                      end
                    end

                    if #merged_fields == 0 then
                      on_done(false, err2)
                      return
                    end

                    prompt_and_retry(merged_fields)
                  end)
                end, fields)
              end

              if #direct.required_fields > 0 then
                local prefills = {}
                if my_account_id then
                  for _, f in ipairs(direct.required_fields) do
                    local schema = f.schema or {}
                    if schema.type == 'user' or f.key == 'assignee' then
                      prefills[f.key] = my_account_id
                    end
                  end
                end
                buffer.prompt_transition_fields(update.key, update.status, direct, function(values)
                  if values then
                    try_direct(values)
                  else
                    on_done(false, 'User cancelled')
                  end
                end, prefills)
                return
              end

              try_direct(nil)
              return
            end

            -- Try graph path
            if graph then
              local path = api_client.find_path_bfs(graph, current_status, update.status)
              if path and #path > 0 then
                api_client.execute_graph_path(
                  cfg.base_url, cfg.email, cfg.token,
                  update.key, graph, path, current_status,
                  function(ok, err_msg, actual)
                    if ok then
                      on_done(true)
                    else
                      api_client.transition_chain(
                        cfg.base_url, cfg.email, cfg.token,
                        update.key, update.status, actual or current_status, DEFAULT_STATUS_ORDER,
                        function(ok2, err2, actual2)
                          if ok2 then on_done(true) else on_done(false, err2 or err_msg, actual2) end
                        end
                      )
                    end
                  end
                )
                return
              end
            end

            -- Fallback to chain
            api_client.transition_chain(
              cfg.base_url, cfg.email, cfg.token,
              update.key, update.status, current_status, DEFAULT_STATUS_ORDER,
              function(ok2, err2, actual2)
                if ok2 then on_done(true) else on_done(false, err2, actual2) end
              end
            )
          end)
        end

        process_next()
      end

      api_client.build_transition_graph(cfg.base_url, cfg.email, cfg.token, samples, function(graph, graph_err)
        if graph_err then
          process_updates(nil)
        else
          process_updates(graph)
        end
      end)
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
