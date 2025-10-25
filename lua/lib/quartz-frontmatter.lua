-- PercyBrain Quartz Publishing Frontmatter Validation
-- Purpose: Validate frontmatter for Quartz static site publishing
-- Quartz v4 frontmatter spec: https://quartz.jzhao.xyz/features/frontmatter

local M = {}

-- Configuration
M.config = {
  zettel_path = vim.fn.expand("~/Zettelkasten"),
  quartz_root = vim.fn.expand("~/projects/quartz"),
  quartz_content = vim.fn.expand("~/projects/quartz/content"),
}

-- Parse YAML frontmatter from content string
-- Returns table with frontmatter fields or nil if no frontmatter
M.parse_frontmatter = function(content)
  -- Extract frontmatter block between --- markers
  local frontmatter_pattern = "^%-%-%-\n(.-)%-%-%-"
  local frontmatter_text = content:match(frontmatter_pattern)

  if not frontmatter_text then
    return nil
  end

  -- Simple YAML parser for frontmatter fields
  local frontmatter = {}

  for line in frontmatter_text:gmatch("[^\r\n]+") do
    -- Parse key: value pairs
    local key, value = line:match("^(%w+):%s*(.+)$")

    if key and value then
      -- Check for quoted strings FIRST (preserve as strings, don't convert)
      local quoted_value = value:match('^"(.-)"$')
      if quoted_value then
        -- Quoted string - keep as string (even if it looks like "true" or "false")
        frontmatter[key] = quoted_value
      -- Parse unquoted boolean values
      elseif value == "true" then
        frontmatter[key] = true
      elseif value == "false" then
        frontmatter[key] = false
      -- Parse array values [item1, item2]
      elseif value:match("^%[.*%]$") then
        local array = {}
        for item in value:gmatch("%[?([^,%]]+)") do
          item = item:gsub("^%s*", ""):gsub("%s*$", "") -- trim whitespace
          if #item > 0 then
            table.insert(array, item)
          end
        end
        frontmatter[key] = array
      else
        -- Regular unquoted string value
        frontmatter[key] = value
      end
    end
  end

  return frontmatter
end

-- Extract frontmatter from note content (alias for parse_frontmatter)
M.extract_frontmatter = M.parse_frontmatter

-- Validate frontmatter structure for Quartz compatibility
-- Returns: is_valid (boolean), errors (string or nil)
-- Quartz frontmatter spec:
--   Required: title, date
--   Optional: draft, tags, aliases, description, permalink
-- luacheck: ignore 561 (cyclomatic complexity acceptable for validation logic)
M.validate_frontmatter = function(content)
  local frontmatter = M.parse_frontmatter(content)

  if not frontmatter then
    return false, "No frontmatter found"
  end

  local errors = {}

  -- Validate required fields exist
  if not frontmatter.title then
    table.insert(errors, "missing required field: title")
  elseif type(frontmatter.title) ~= "string" then
    table.insert(errors, "Field 'title' must be string")
  end

  if not frontmatter.date then
    table.insert(errors, "missing required field: date")
  elseif type(frontmatter.date) ~= "string" or not frontmatter.date:match("^%d%d%d%d%-%d%d%-%d%d$") then
    table.insert(errors, "Field 'date' must be YYYY-MM-DD format")
  end

  -- Validate optional fields if present
  if frontmatter.draft ~= nil and type(frontmatter.draft) ~= "boolean" then
    table.insert(errors, "Field 'draft' must be boolean (true/false), not string")
  end

  if frontmatter.tags and type(frontmatter.tags) ~= "table" then
    table.insert(errors, "Field 'tags' must be array format [tag1, tag2]")
  end

  if frontmatter.aliases and type(frontmatter.aliases) ~= "table" then
    table.insert(errors, "Field 'aliases' must be array format [alias1, alias2]")
  end

  if frontmatter.description and type(frontmatter.description) ~= "string" then
    table.insert(errors, "Field 'description' must be string")
  end

  if frontmatter.permalink and type(frontmatter.permalink) ~= "string" then
    table.insert(errors, "Field 'permalink' must be string")
  end

  -- Return validation result
  if #errors > 0 then
    return false, table.concat(errors, "; ")
  end

  return true, nil
end

-- Check if file should be published (exclude inbox directory and drafts)
M.should_publish_file = function(filepath)
  -- Exclude inbox directory
  if filepath:match("/inbox/") then
    return false
  end

  -- Exclude private directories
  if filepath:match("/private/") then
    return false
  end

  -- Exclude templates
  if filepath:match("/templates/") then
    return false
  end

  -- Include root zettelkasten notes
  if filepath:match("^" .. vim.fn.expand("~/Zettelkasten") .. "/[^/]+%.md$") then
    return true
  end

  return true
end

-- Validate file for publishing (reads file and validates frontmatter)
M.validate_file_for_publishing = function(filepath)
  if vim.fn.filereadable(filepath) ~= 1 then
    return false, "File not readable: " .. filepath
  end

  -- Read file content
  local file = io.open(filepath, "r")
  if not file then
    return false, "Could not open file: " .. filepath
  end

  local content = file:read("*all")
  file:close()

  -- Validate frontmatter
  return M.validate_frontmatter(content)
end

return M
