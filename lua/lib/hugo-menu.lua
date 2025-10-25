-- PercyBrain Hugo Publishing Menu
-- Purpose: Unified menu for Hugo static site publishing and configuration
-- Keybinding: <leader>h (h for Hugo)

local M = {}

-- Configuration
M.config = {
  zettel_path = vim.fn.expand("~/Zettelkasten"),
  export_path = vim.fn.expand("~/blog/content/zettelkasten"),
  hugo_root = vim.fn.expand("~/blog"),
  hugo_config = vim.fn.expand("~/blog/config.toml"),
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

-- Validate frontmatter structure for Hugo compatibility
-- Returns: is_valid (boolean), errors (string or nil)
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

  if frontmatter.draft == nil then
    table.insert(errors, "missing required field: draft")
  elseif type(frontmatter.draft) ~= "boolean" then
    table.insert(errors, "Field 'draft' must be boolean (true/false), not string")
  end

  -- Validate optional array fields if present
  if frontmatter.tags and type(frontmatter.tags) ~= "table" then
    table.insert(errors, "Field 'tags' must be array format [tag1, tag2]")
  end

  if frontmatter.categories and type(frontmatter.categories) ~= "table" then
    table.insert(errors, "Field 'categories' must be array format [cat1, cat2]")
  end

  -- Return validation result
  if #errors > 0 then
    return false, table.concat(errors, "; ")
  end

  return true, nil
end

-- Check if file should be published (exclude inbox directory)
M.should_publish_file = function(filepath)
  -- Exclude inbox directory
  if filepath:match("/inbox/") then
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

-- Publish notes to Hugo
local function publish()
  vim.notify("📤 Publishing to Hugo...", vim.log.levels.INFO)

  -- Copy notes to export path
  local cmd = string.format('rsync -av --exclude="inbox" %s/ %s/', M.config.zettel_path, M.config.export_path)
  local result = vim.fn.system(cmd)

  if vim.v.shell_error ~= 0 then
    vim.notify("❌ Publishing failed: " .. result, vim.log.levels.ERROR)
    return
  end

  -- Build static site
  vim.fn.system("cd " .. M.config.hugo_root .. " && hugo")

  if vim.v.shell_error == 0 then
    vim.notify("✅ Published successfully!", vim.log.levels.INFO)
  else
    vim.notify("❌ Hugo build failed", vim.log.levels.ERROR)
  end
end

-- Open Hugo configuration
local function open_config()
  if vim.fn.filereadable(M.config.hugo_config) == 1 then
    vim.cmd("edit " .. M.config.hugo_config)
  else
    vim.notify("❌ Hugo config not found: " .. M.config.hugo_config, vim.log.levels.ERROR)
  end
end

-- Start Hugo development server
local function start_server()
  vim.notify("🚀 Starting Hugo development server...", vim.log.levels.INFO)
  vim.fn.jobstart("cd " .. M.config.hugo_root .. " && hugo server -D", {
    on_stdout = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line:match("Web Server is available at") then
            vim.notify("✅ " .. line, vim.log.levels.INFO)
          end
        end
      end
    end,
  })
end

-- Preview latest build in browser
local function preview()
  vim.notify("🌐 Opening Hugo preview...", vim.log.levels.INFO)
  vim.fn.system("xdg-open http://localhost:1313 &")
end

-- Clean Hugo build cache
local function clean()
  vim.notify("🧹 Cleaning Hugo build cache...", vim.log.levels.INFO)
  vim.fn.system("cd " .. M.config.hugo_root .. " && hugo --cleanDestinationDir")
  vim.notify("✅ Hugo cache cleaned!", vim.log.levels.INFO)
end

-- Show Hugo menu using vim.ui.select
M.show_menu = function()
  local options = {
    "📤 Publish to Hugo",
    "⚙️  Open Hugo Config",
    "🚀 Start Dev Server",
    "🌐 Preview in Browser",
    "🧹 Clean Build Cache",
  }

  vim.ui.select(options, {
    prompt = "Hugo Menu:",
  }, function(choice)
    if choice == options[1] then
      publish()
    elseif choice == options[2] then
      open_config()
    elseif choice == options[3] then
      start_server()
    elseif choice == options[4] then
      preview()
    elseif choice == options[5] then
      clean()
    end
  end)
end

-- Direct publish function (for backward compatibility)
M.publish = publish

-- Setup keybindings
M.setup = function()
  vim.keymap.set("n", "<leader>h", M.show_menu, { desc = "Hugo Menu" })
  vim.keymap.set("n", "<leader>hp", publish, { desc = "Hugo Publish" })
  vim.keymap.set("n", "<leader>hc", open_config, { desc = "Hugo Config" })
  vim.keymap.set("n", "<leader>hs", start_server, { desc = "Hugo Server" })
  vim.keymap.set("n", "<leader>hv", preview, { desc = "Hugo Preview" })
  vim.keymap.set("n", "<leader>hx", clean, { desc = "Hugo Clean" })
end

return M
