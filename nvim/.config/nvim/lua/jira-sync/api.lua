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

  local url = ('%s/rest/api/3/issue/%s/transitions'):format(base_url, vim.uri_encode(issue_key))

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

    on_done(data.transitions or {}, nil)
  end)
end

--- Execute a transition on an issue.
--- @param base_url string
--- @param email string
--- @param token string
--- @param issue_key string
--- @param transition_id string
--- @param on_done fun(ok: boolean, err: string|nil)
function M.transition_issue(base_url, email, token, issue_key, transition_id, on_done)
  local auth = vim.base64.encode(email .. ':' .. token)
  local headers = {
    Authorization = 'Basic ' .. auth,
    ['Content-Type'] = 'application/json',
    Accept = 'application/json',
  }

  local url = ('%s/rest/api/3/issue/%s/transitions'):format(base_url, vim.uri_encode(issue_key))
  local body = vim.json.encode({ transition = { id = transition_id } })

  vim.net.request('POST', url, { headers = headers, body = body }, function(err, res)
    if err then
      on_done(false, err)
      return
    end
    on_done(true, nil)
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

    local transition_id = nil
    for _, t in ipairs(transitions) do
      if t.to and t.to.name == desired_status then
        transition_id = t.id
        break
      end
    end

    if not transition_id then
      local available = {}
      for _, t in ipairs(transitions) do
        table.insert(available, (t.to and t.to.name or t.name or '?'))
      end
      on_done(false, ('No transition to "%s" found for %s. Available: %s'):format(
        desired_status, issue_key, table.concat(available, ', ')
      ))
      return
    end

    M.transition_issue(base_url, email, token, issue_key, transition_id, on_done)
  end)
end

--- Transition an issue to a desired status, automatically chaining through intermediates.
--- Uses status_order to pick the best intermediate step when a direct transition is unavailable.
--- @param base_url string
--- @param email string
--- @param token string
--- @param issue_key string
--- @param desired_status string
--- @param current_status string
--- @param status_order string[]|nil ordered statuses to guide path selection
--- @param on_done fun(ok: boolean, err: string|nil)
--- @param depth integer|nil internal recursion depth
function M.transition_chain(base_url, email, token, issue_key, desired_status, current_status, status_order, on_done, depth)
  depth = (depth or 0) + 1
  if depth > 10 then
    on_done(false, ('Transition chain too deep for %s'):format(issue_key))
    return
  end

  if current_status == desired_status then
    on_done(true, nil)
    return
  end

  M.get_transitions(base_url, email, token, issue_key, function(transitions, trans_err)
    if trans_err then
      on_done(false, trans_err)
      return
    end

    -- Try direct transition first
    for _, t in ipairs(transitions) do
      if t.to and t.to.name == desired_status then
        M.transition_issue(base_url, email, token, issue_key, t.id, on_done)
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
      ))
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
      if to_name then
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
      on_done(false, ('No transition to "%s" found for %s. Available: %s'):format(
        desired_status, issue_key, table.concat(available, ', ')
      ))
      return
    end

    M.transition_issue(base_url, email, token, issue_key, best.id, function(ok2, err2)
      if not ok2 then
        on_done(false, err2)
        return
      end

      M.transition_chain(base_url, email, token, issue_key, desired_status, best.to.name, status_order, on_done, depth)
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
          graph[status][t.to.name] = t.id
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
local function find_path_bfs(graph, from, to)
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

--- Auto-discover transition path and execute it.
--- @param base_url string
--- @param email string
--- @param token string
--- @param issue_key string
--- @param desired_status string
--- @param current_status string
--- @param samples {key: string, status: string}[]
--- @param on_done fun(ok: boolean, err: string|nil)
function M.auto_transition(base_url, email, token, issue_key, desired_status, current_status, samples, on_done)
  M.build_transition_graph(base_url, email, token, samples, function(graph, err)
    if err then
      on_done(false, 'Auto-discovery failed: ' .. err)
      return
    end

    local path = find_path_bfs(graph, current_status, desired_status)
    if not path or #path == 0 then
      local available = {}
      for s, _ in pairs(graph[current_status] or {}) do
        table.insert(available, s)
      end
      on_done(false, ('No path from "%s" to "%s" discovered. Available from %s: %s'):format(
        current_status, desired_status, current_status, table.concat(available, ', ')
      ))
      return
    end

    local step = 1
    local walk_status = current_status

    local function walk()
      if step > #path then
        on_done(true, nil)
        return
      end

      local next_status = path[step]
      local transition_id = graph[walk_status] and graph[walk_status][next_status]
      if not transition_id then
        on_done(false, ('Lost transition from %s to %s'):format(walk_status, next_status))
        return
      end

      M.transition_issue(base_url, email, token, issue_key, transition_id, function(ok, trans_err)
        if not ok then
          on_done(false, trans_err)
          return
        end
        walk_status = next_status
        step = step + 1
        walk()
      end)
    end

    walk()
  end)
end

return M
