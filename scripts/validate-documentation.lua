#!/usr/bin/env -S nvim --headless -l
--
-- OVIWrite Layer 4 Validation: Documentation Sync
-- Tests: CLAUDE.md plugin list matches actual plugins
--

local function print_colored(color, text)
  local colors = {
    red = '\27[0;31m',
    green = '\27[0;32m',
    yellow = '\27[1;33m',
    blue = '\27[0;34m',
    reset = '\27[0m'
  }
  print((colors[color] or '') .. text .. colors.reset)
end

print_colored('blue', '📚 Layer 4: Documentation Sync Validation')
print('========================================')
print('')

-- Get installed plugins from lua/plugins/*.lua
local function get_installed_plugins()
  local plugins = {}
  local plugins_dir = "lua/plugins"

  local handle = vim.loop.fs_scandir(plugins_dir)
  if not handle then
    print_colored('red', '❌ Cannot read lua/plugins/ directory')
    return {}
  end

  while true do
    local name, typ = vim.loop.fs_scandir_next(handle)
    if not name then break end

    if typ == "file" and name:match("%.lua$") and name ~= "init.lua" then
      -- Convert filename to human-readable format
      -- Example: nvim-tree.lua → nvim-tree
      local plugin_name = name:gsub("%.lua$", "")
      table.insert(plugins, {
        filename = name,
        name = plugin_name,
        normalized = plugin_name:lower():gsub("[-_]", "")
      })
    end
  end

  return plugins
end

-- Parse CLAUDE.md for documented plugins
local function get_documented_plugins()
  local plugins = {}
  local claude_file = io.open("CLAUDE.md", "r")

  if not claude_file then
    print_colored('yellow', '⚠️  CLAUDE.md not found')
    return {}
  end

  local content = claude_file:read("*all")
  claude_file:close()

  -- Pattern 1: **plugin-name.lua** in plugin lists
  for plugin in content:gmatch("%*%*([^%*]+)%.lua%*%*") do
    table.insert(plugins, {
      name = plugin,
      normalized = plugin:lower():gsub("[-_]", "")
    })
  end

  -- Pattern 2: ## Plugin Name headings
  -- (Some plugins documented without .lua extension)
  for plugin in content:gmatch("###?%s+([^#\n]+)%.lua") do
    local trimmed = plugin:match("^%s*(.-)%s*$")
    if trimmed then
      table.insert(plugins, {
        name = trimmed,
        normalized = trimmed:lower():gsub("[-_]", "")
      })
    end
  end

  return plugins
end

-- Compare plugin lists
local function compare_plugins(installed, documented)
  local missing_from_docs = {}
  local removed_from_code = {}
  local accuracy_score = 0

  -- Build lookup tables (normalized names for comparison)
  local doc_lookup = {}
  for _, p in ipairs(documented) do
    doc_lookup[p.normalized] = true
  end

  local installed_lookup = {}
  for _, p in ipairs(installed) do
    installed_lookup[p.normalized] = true
  end

  -- Find plugins in code but not documented
  for _, plugin in ipairs(installed) do
    if not doc_lookup[plugin.normalized] then
      table.insert(missing_from_docs, plugin.filename)
    end
  end

  -- Find documented plugins not in code
  for _, plugin in ipairs(documented) do
    if not installed_lookup[plugin.normalized] then
      table.insert(removed_from_code, plugin.name)
    end
  end

  -- Calculate accuracy score
  local total_plugins = #installed
  local matched = total_plugins - #missing_from_docs
  accuracy_score = total_plugins > 0 and math.floor((matched / total_plugins) * 100) or 0

  return {
    missing_from_docs = missing_from_docs,
    removed_from_code = removed_from_code,
    accuracy_score = accuracy_score,
    total_installed = total_plugins,
    total_documented = #documented,
    matched = matched
  }
end

-- Main validation
print_colored('blue', '🔍 Scanning installed plugins...')
local installed = get_installed_plugins()
print('   Found ' .. #installed .. ' plugin files')
print('')

print_colored('blue', '📖 Parsing CLAUDE.md...')
local documented = get_documented_plugins()
print('   Found ' .. #documented .. ' documented plugins')
print('')

print_colored('blue', '🔄 Comparing plugin lists...')
local comparison = compare_plugins(installed, documented)
print('')

-- Print results
print('========================================')
print('Documentation Sync Results:')
print('--------------------')
print('  Total installed:  ' .. comparison.total_installed)
print('  Total documented: ' .. comparison.total_documented)
print('  Matched:          ' .. comparison.matched)
print_colored('blue', '  Accuracy score:   ' .. comparison.accuracy_score .. '%')
print('')

-- Report missing from docs
if #comparison.missing_from_docs > 0 then
  print_colored('yellow', '⚠️  Plugins missing from CLAUDE.md (' .. #comparison.missing_from_docs .. '):')
  for _, plugin in ipairs(comparison.missing_from_docs) do
    print('  - ' .. plugin)
  end
  print('')
end

-- Report removed from code
if #comparison.removed_from_code > 0 then
  print_colored('yellow', '⚠️  Documented plugins not found in code (' .. #comparison.removed_from_code .. '):')
  for _, plugin in ipairs(comparison.removed_from_code) do
    print('  - ' .. plugin)
  end
  print('')
end

-- Determine result
-- Note: This is WARNING-only, doesn't block CI
print('========================================')

if comparison.accuracy_score == 100 then
  print_colored('green', '✅ Documentation fully synchronized')
  print_colored('green', '   All plugins documented correctly')
  os.exit(0)
elseif comparison.accuracy_score >= 90 then
  print_colored('green', '✅ Documentation sync passed (good)')
  print_colored('yellow', '⚠️  Minor drift detected (' .. (100 - comparison.accuracy_score) .. '% missing)')
  print_colored('yellow', '   Consider updating CLAUDE.md plugin list')
  os.exit(0)
else
  print_colored('yellow', '⚠️  Documentation sync needs attention')
  print_colored('yellow', '   Accuracy: ' .. comparison.accuracy_score .. '% (target: 90%+)')
  print('')
  print('💡 Action items:')
  if #comparison.missing_from_docs > 0 then
    print('  1. Add missing plugins to CLAUDE.md "Key Writing-Focused Plugins" section')
  end
  if #comparison.removed_from_code > 0 then
    print('  2. Remove outdated plugins from CLAUDE.md')
  end
  print('  3. Run: ./scripts/extract-keymaps.lua to update keyboard shortcuts')
  print('')

  -- Exit 0 (warnings don't block)
  os.exit(0)
end
