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

return M
