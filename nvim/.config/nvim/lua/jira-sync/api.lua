local M = {}

local api = vim.api

--- @class jira_sync.Ticket
--- @field key string
--- @field summary string
--- @field status string

--- Fetch all tickets for a project or epic from Jira using the enhanced search endpoint.
--- Uses vim.net.request (async) and accumulates paginated results.
--- @param base_url string e.g. "https://acme.atlassian.net"
--- @param email string
--- @param token string
--- @param project_key string|nil
--- @param epic_key string|nil e.g. "DPIT-1853"
--- @param on_done fun(tickets: jira_sync.Ticket[]|nil, err: string|nil)
function M.fetch_tickets(base_url, email, token, project_key, epic_key, on_done)
  local auth = vim.base64.encode(email .. ':' .. token)
  local headers = {
    Authorization = 'Basic ' .. auth,
    ['Content-Type'] = 'application/json',
    Accept = 'application/json',
  }

  local all_tickets = {}
  local max_results = 100
  local next_page_token = nil

  local function fetch_page()
    local jql
    if epic_key then
      jql = 'parent=' .. vim.uri_encode(epic_key)
    else
      jql = 'project=' .. vim.uri_encode(project_key)
    end

    local url = ('%s/rest/api/3/search/jql?jql=%s&fields=key,summary,status&maxResults=%d'):format(
      base_url, jql, max_results
    )

    if next_page_token then
      url = url .. '&nextPageToken=' .. vim.uri_encode(next_page_token)
    end

    vim.net.request(url, { headers = headers }, function(err, res)
      if err then
        on_done(nil, 'HTTP error: ' .. err)
        return
      end

      local ok, data = pcall(vim.json.decode, res.body)
      if not ok then
        on_done(nil, 'JSON parse error: ' .. tostring(data))
        return
      end

      if data.errorMessages then
        on_done(nil, 'Jira error: ' .. table.concat(data.errorMessages, '; '))
        return
      end

      for _, issue in ipairs(data.issues or {}) do
        table.insert(all_tickets, {
          key = issue.key,
          summary = issue.fields and issue.fields.summary or '',
          status = issue.fields and issue.fields.status and issue.fields.status.name or 'Unknown',
        })
      end

      if data.isLast == false and data.nextPageToken then
        next_page_token = data.nextPageToken
        fetch_page()
      else
        on_done(all_tickets, nil)
      end
    end)
  end

  fetch_page()
end

--- Test connectivity by fetching project details.
--- @param base_url string
--- @param email string
--- @param token string
--- @param project_key string
--- @param on_done fun(result: table|nil, err: string|nil)
function M.test_project(base_url, email, token, project_key, on_done)
  local auth = vim.base64.encode(email .. ':' .. token)
  local headers = {
    Authorization = 'Basic ' .. auth,
    ['Content-Type'] = 'application/json',
    Accept = 'application/json',
  }

  local url = ('%s/rest/api/3/project/%s'):format(base_url, vim.uri_encode(project_key))

  vim.net.request(url, { headers = headers }, function(err, res)
    if err then
      on_done(nil, 'HTTP error: ' .. err)
      return
    end

    local ok, data = pcall(vim.json.decode, res.body)
    if not ok then
      on_done(nil, 'JSON parse error: ' .. tostring(data))
      return
    end

    if data.errorMessages then
      on_done(nil, 'Jira error: ' .. table.concat(data.errorMessages, '; '))
      return
    end

    on_done(data, nil)
  end)
end

--- List all projects accessible with this API key.
--- @param base_url string
--- @param email string
--- @param token string
--- @param on_done fun(projects: table[]|nil, err: string|nil)
function M.list_projects(base_url, email, token, on_done)
  local auth = vim.base64.encode(email .. ':' .. token)
  local headers = {
    Authorization = 'Basic ' .. auth,
    ['Content-Type'] = 'application/json',
    Accept = 'application/json',
  }

  local url = base_url .. '/rest/api/3/project'

  vim.net.request(url, { headers = headers }, function(err, res)
    if err then
      on_done(nil, 'HTTP error: ' .. err)
      return
    end

    local ok, data = pcall(vim.json.decode, res.body)
    if not ok then
      on_done(nil, 'JSON parse error: ' .. tostring(data))
      return
    end

    if data.errorMessages then
      on_done(nil, 'Jira error: ' .. table.concat(data.errorMessages, '; '))
      return
    end

    on_done(data, nil)
  end)
end

--- Get available transitions for an issue.
--- @param base_url string
--- @param email string
--- @param token string
--- @param issue_key string
--- @param on_done fun(transitions: table[]|nil, err: string|nil)
function M.get_transitions(base_url, email, token, issue_key, on_done)
  local auth = vim.base64.encode(email .. ':' .. token)
  local headers = {
    Authorization = 'Basic ' .. auth,
    ['Content-Type'] = 'application/json',
    Accept = 'application/json',
  }

  local url = ('%s/rest/api/3/issue/%s/transitions?expand=transitions.fields'):format(base_url, vim.uri_encode(issue_key))

  vim.net.request(url, { headers = headers }, function(err, res)
    if err then
      on_done(nil, err)
      return
    end

    local ok, data = pcall(vim.json.decode, res.body)
    if not ok then
      on_done(nil, 'JSON parse error: ' .. tostring(data))
      return
    end

    if data.errorMessages then
      on_done(nil, 'Jira error: ' .. table.concat(data.errorMessages, '; '))
      return
    end

    local transitions = {}
    for _, t in ipairs(data.transitions or {}) do
      local required_fields = {}
      if t.fields then
        for field_key, field_meta in pairs(t.fields) do
          if field_meta.required then
            table.insert(required_fields, {
              key = field_key,
              name = field_meta.name or field_key,
            })
          end
        end
      end
      table.insert(transitions, {
        id = t.id,
        name = t.name,
        to = t.to,
        required_fields = required_fields,
      })
    end
    on_done(transitions, nil)
  end)
end

--- Execute a transition on an issue.
--- Uses vim.system directly (not vim.net.request) so we can read the response body on 400/500 errors.
--- @param base_url string
--- @param email string
--- @param token string
--- @param issue_key string
--- @param transition_id string
--- @param on_done fun(ok: boolean, err: string|nil)
function M.transition_issue(base_url, email, token, issue_key, transition_id, on_done)
  local auth = vim.base64.encode(email .. ':' .. token)
  local url = ('%s/rest/api/3/issue/%s/transitions'):format(base_url, vim.uri_encode(issue_key))
  local body = vim.json.encode({ transition = { id = transition_id } })

  local args = {
    'curl', '-s', '-S', '-w', '\nHTTP_CODE:%{http_code}\n',
    '-X', 'POST',
    '-H', 'Authorization: Basic ' .. auth,
    '-H', 'Content-Type: application/json',
    '-d', body,
    url,
  }

  vim.system(args, {}, function(res)
    if res.code ~= 0 then
      on_done(false, res.stderr ~= '' and res.stderr or ('curl exit %d'):format(res.code))
      return
    end

    local stdout = res.stdout or ''
    local status_code = stdout:match('HTTP_CODE:(%d%d%d)')
    local body_text = stdout:gsub('\nHTTP_CODE:%d%d%d\n$', '')

    if status_code and status_code:match('^2') then
      on_done(true, nil)
      return
    end

    -- Try to parse Jira's structured error response
    local ok, data = pcall(vim.json.decode, body_text)
    if ok then
      if data.errorMessages and #data.errorMessages > 0 then
        on_done(false, table.concat(data.errorMessages, '; '))
        return
      end
      if data.errors then
        local msgs = {}
        for k, v in pairs(data.errors) do
          table.insert(msgs, v)
        end
        if #msgs > 0 then
          on_done(false, table.concat(msgs, '; '))
          return
        end
      end
    end

    on_done(false, ('HTTP %s'):format(status_code or 'unknown'))
  end)
end

--- Update an issue's status by finding and executing the appropriate transition.
--- @param base_url string
--- @param email string
--- @param token string
--- @param issue_key string
--- @param desired_status string
--- @param on_done fun(ok: boolean, err: string|nil)
function M.update_status(base_url, email, token, issue_key, desired_status, on_done)
  M.get_transitions(base_url, email, token, issue_key, function(transitions, err)
    if err then
      on_done(false, 'Failed to get transitions: ' .. err)
      return
    end

    local chosen = nil
    for _, t in ipairs(transitions) do
      if t.to and t.to.name == desired_status then
        chosen = t
        break
      end
    end

    if not chosen then
      local available = {}
      for _, t in ipairs(transitions) do
        table.insert(available, (t.to and t.to.name or t.name or '?'))
      end
      on_done(false, ('No transition to "%s" found for %s. Available: %s'):format(
        desired_status, issue_key, table.concat(available, ', ')
      ))
      return
    end

    if #chosen.required_fields > 0 then
      local names = {}
      for _, f in ipairs(chosen.required_fields) do
        table.insert(names, f.name)
      end
      on_done(false, ('Transition to "%s" requires fields: %s'):format(
        desired_status, table.concat(names, ', ')
      ))
      return
    end

    M.transition_issue(base_url, email, token, issue_key, chosen.id, on_done)
  end)
end

--- Transition an issue to a desired status, automatically chaining through intermediates.
--- Uses status_order to pick the best intermediate step when a direct transition is unavailable.
--- Tracks visited statuses to avoid infinite loops.
--- @param base_url string
--- @param email string
--- @param token string
--- @param issue_key string
--- @param desired_status string
--- @param current_status string
--- @param status_order string[]|nil ordered statuses to guide path selection
--- @param on_done fun(ok: boolean, err: string|nil, actual_status: string|nil)
---   On success: (true, nil, desired_status)
---   On failure after partial progress: (false, err, actual_status_reached)
---   On failure at start: (false, err, current_status)
--- @param depth integer|nil internal recursion depth
--- @param visited table<string, boolean>|nil statuses already visited in this chain
function M.transition_chain(base_url, email, token, issue_key, desired_status, current_status, status_order, on_done, depth, visited)
  depth = (depth or 0) + 1
  if depth > 10 then
    on_done(false, ('Transition chain too deep for %s'):format(issue_key), current_status)
    return
  end

  visited = visited or {}
  if visited[current_status] then
    on_done(false, ('Transition loop detected for %s at status "%s"'):format(issue_key, current_status), current_status)
    return
  end
  visited[current_status] = true

  if current_status == desired_status then
    on_done(true, nil, current_status)
    return
  end

  M.get_transitions(base_url, email, token, issue_key, function(transitions, trans_err)
    if trans_err then
      on_done(false, trans_err, current_status)
      return
    end

    -- Try direct transition first
    for _, t in ipairs(transitions) do
      if t.to and t.to.name == desired_status then
        if #t.required_fields > 0 then
          local names = {}
          for _, f in ipairs(t.required_fields) do
            table.insert(names, f.name)
          end
          on_done(false, ('Transition to "%s" requires fields: %s'):format(
            desired_status, table.concat(names, ', ')
          ), current_status)
          return
        end
        M.transition_issue(base_url, email, token, issue_key, t.id, function(ok, err)
          if ok then
            on_done(true, nil, desired_status)
          else
            on_done(false, err, current_status)
          end
        end)
        return
      end
    end

    if not status_order or #status_order == 0 then
      local available = {}
      for _, t in ipairs(transitions) do
        table.insert(available, t.to and t.to.name or '?')
      end
      on_done(false, ('No transition to "%s" found for %s. Available: %s'):format(
        desired_status, issue_key, table.concat(available, ', ')
      ), current_status)
      return
    end

    -- Score available transitions by proximity to desired in status_order
    local order_map = {}
    for i, s in ipairs(status_order) do
      order_map[s] = i
    end

    local desired_idx = order_map[desired_status]
    local current_idx = order_map[current_status]

    local best = nil
    local best_score = math.huge

    for _, t in ipairs(transitions) do
      local to_name = t.to and t.to.name
      if to_name and not visited[to_name] then
        local to_idx = order_map[to_name] or 999
        local score = math.abs((desired_idx or 999) - to_idx)

        -- Heavy bonus for forward progress toward desired
        if current_idx and desired_idx then
          if current_idx < desired_idx and to_idx > current_idx and to_idx <= desired_idx then
            score = score - 1000
          elseif current_idx > desired_idx and to_idx < current_idx and to_idx >= desired_idx then
            score = score - 1000
          end
        end

        if score < best_score then
          best_score = score
          best = t
        end
      end
    end

    if not best then
      local available = {}
      for _, t in ipairs(transitions) do
        table.insert(available, t.to and t.to.name or '?')
      end
      on_done(false, ('No unvisited transition from "%s" toward "%s" for %s. Available: %s'):format(
        current_status, desired_status, issue_key, table.concat(available, ', ')
      ), current_status)
      return
    end

    if #best.required_fields > 0 then
      local names = {}
      for _, f in ipairs(best.required_fields) do
        table.insert(names, f.name)
      end
      on_done(false, ('Intermediate transition to "%s" requires fields: %s'):format(
        best.to.name, table.concat(names, ', ')
      ), current_status)
      return
    end

    M.transition_issue(base_url, email, token, issue_key, best.id, function(ok2, err2)
      if not ok2 then
        on_done(false, err2, current_status)
        return
      end

      M.transition_chain(base_url, email, token, issue_key, desired_status, best.to.name, status_order, function(ok3, err3, actual)
        if ok3 then
          on_done(true, nil, actual)
        else
          on_done(false, err3, actual)
        end
      end, depth, visited)
    end)
  end)
end

--- Build a transition graph by sampling one issue per unique status.
--- @param base_url string
--- @param email string
--- @param token string
--- @param samples {key: string, status: string}[]
--- @param on_done fun(graph: table|nil, err: string|nil)
function M.build_transition_graph(base_url, email, token, samples, on_done)
  local by_status = {}
  for _, s in ipairs(samples) do
    if not by_status[s.status] then
      by_status[s.status] = s.key
    end
  end

  local graph = {}
  local pending = vim.tbl_count(by_status)
  local failed = false

  if pending == 0 then
    on_done({}, nil)
    return
  end

  for status, key in pairs(by_status) do
    M.get_transitions(base_url, email, token, key, function(transitions, err)
      if failed then
        return
      end

      if err then
        failed = true
        on_done(nil, err)
        return
      end

      graph[status] = {}
      for _, t in ipairs(transitions) do
        if t.to and t.to.name and t.id then
          if #t.required_fields == 0 then
            graph[status][t.to.name] = t.id
          end
        end
      end

      pending = pending - 1
      if pending == 0 then
        on_done(graph, nil)
      end
    end)
  end
end

--- Find shortest path in transition graph using BFS.
--- @param graph table<string, table<string, string>> status -> {to_status: transition_id}
--- @param from string
--- @param to string
--- @return string[]|nil path list of statuses to traverse through (excluding 'from', including 'to')
function M.find_path_bfs(graph, from, to)
  if from == to then
    return {}
  end
  if not graph[from] then
    return nil
  end

  local visited = { [from] = true }
  local queue = { { status = from, path = {} } }

  local head = 1
  while head <= #queue do
    local current = queue[head]
    head = head + 1

    for next_status, _ in pairs(graph[current.status] or {}) do
      if next_status == to then
        local result = vim.deepcopy(current.path)
        table.insert(result, next_status)
        return result
      end

      if not visited[next_status] then
        visited[next_status] = true
        local new_path = vim.deepcopy(current.path)
        table.insert(new_path, next_status)
        table.insert(queue, { status = next_status, path = new_path })
      end
    end
  end

  return nil
end

--- Walk a pre-computed transition path on a specific issue.
--- @param base_url string
--- @param email string
--- @param token string
--- @param issue_key string
--- @param graph table<string, table<string, string>>
--- @param path string[] list of statuses to visit
--- @param start_status string
--- @param on_done fun(ok: boolean, err: string|nil, actual_status: string|nil)
function M.execute_graph_path(base_url, email, token, issue_key, graph, path, start_status, on_done)
  local step = 1
  local current = start_status

  local function walk()
    if step > #path then
      on_done(true, nil, current)
      return
    end

    local next_status = path[step]
    local transition_id = graph[current] and graph[current][next_status]
    if not transition_id then
      on_done(false, ('No transition edge from %s to %s'):format(current, next_status), current)
      return
    end

    M.transition_issue(base_url, email, token, issue_key, transition_id, function(ok, err)
      if not ok then
        on_done(false, err, current)
        return
      end
      current = next_status
      step = step + 1
      walk()
    end)
  end

  walk()
end

--- Auto-discover transition path and execute it.
--- @param base_url string
--- @param email string
--- @param token string
--- @param issue_key string
--- @param desired_status string
--- @param current_status string
--- @param samples {key: string, status: string}[]
--- @param on_done fun(ok: boolean, err: string|nil, actual_status: string|nil)
function M.auto_transition(base_url, email, token, issue_key, desired_status, current_status, samples, on_done)
  M.build_transition_graph(base_url, email, token, samples, function(graph, err)
    if err then
      on_done(false, 'Auto-discovery failed: ' .. err, current_status)
      return
    end

    local path = M.find_path_bfs(graph, current_status, desired_status)
    if not path or #path == 0 then
      local available = {}
      for s, _ in pairs(graph[current_status] or {}) do
        table.insert(available, s)
      end
      on_done(false, ('No path from "%s" to "%s" discovered. Available from %s: %s'):format(
        current_status, desired_status, current_status, table.concat(available, ', ')
      ), current_status)
      return
    end

    M.execute_graph_path(base_url, email, token, issue_key, graph, path, current_status, on_done)
  end)
end

return M
