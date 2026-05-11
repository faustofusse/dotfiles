local M = {}

--- Parse simple YAML frontmatter from buffer lines.
--- Only supports top-level string key: value pairs.
--- @param lines string[]
--- @return table<string, string>|nil frontmatter
--- @return integer end_line 0-indexed line where frontmatter ends (0 if none)
function M.parse_frontmatter(lines)
  if not lines or #lines == 0 then
    return nil, 0
  end

  if not lines[1]:match('^%-%-%-%s*$') then
    return nil, 0
  end

  local result = {}
  local i = 2
  while i <= #lines do
    local line = lines[i]
    if line:match('^%-%-%-%s*$') then
      return result, i
    end

    local key, value = line:match('^([%w_]+):%s*(.-)%s*$')
    if key and value then
      result[key] = M.interpolate_env(value)
    end

    i = i + 1
  end

  -- No closing ---, treat as no frontmatter
  return nil, 0
end

--- Replace ${VAR} or $VAR with environment variable values.
--- @param value string
--- @return string
function M.interpolate_env(value)
  -- Handle ${VAR}
  value = value:gsub('%$%{([%w_]+)%}', function(var)
    return vim.env[var] or ''
  end)
  -- Handle $VAR (only at word boundaries, not inside braces)
  value = value:gsub('%$([%w_]+)', function(var)
    return vim.env[var] or ''
  end)
  return value
end

--- Extract project key from filename like "DPIT.md"
--- @param filename string
--- @return string|nil
function M.project_key_from_filename(filename)
  local name = vim.fn.fnamemodify(filename, ':t:r')
  -- Normalize in case filename contains an issue key like "DPIT-1853.md"
  name = M.normalize_project_key(name)
  return name
end

--- Normalize a project key by stripping issue number suffixes.
--- E.g. "DPIT-1853" -> "DPIT", "PROJ" -> "PROJ"
--- @param key string
--- @return string|nil
function M.normalize_project_key(key)
  if not key or key == '' then
    return nil
  end
  -- Jira issue keys are PROJECTKEY-123; extract just the project part
  local project = key:match('^([A-Z0-9]+)%-%d+$')
  if project then
    return project
  end
  -- Already a clean project key
  if key:match('^[A-Z][A-Z0-9]+$') then
    return key
  end
  return nil
end

--- Validate and normalize a Jira issue key.
--- E.g. "DPIT-1853" -> "DPIT-1853", "PROJ-1" -> "PROJ-1"
--- @param key string
--- @return string|nil
function M.normalize_issue_key(key)
  if not key or key == '' then
    return nil
  end
  if key:match('^[A-Z0-9]+%-%d+$') then
    return key
  end
  return nil
end

return M
