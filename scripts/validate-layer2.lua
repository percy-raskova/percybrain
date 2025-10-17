#!/usr/bin/env -S nvim --headless -l
--
-- OVIWrite Layer 2 Validation: Structural Analysis
-- Checks: Plugin spec structure, lazy.nvim field validation, keymap conflicts
--

local errors = {}
local warnings = {}

-- Utility: Add error
local function add_error(file, msg, severity)
  severity = severity or "ERROR"
  local entry = {file = file, msg = msg, severity = severity}

  if severity == "ERROR" then
    table.insert(errors, entry)
  else
    table.insert(warnings, entry)
  end
end

-- Utility: Safe require
local function safe_require(path)
  local ok, result = pcall(function()
    return dofile(path)
  end)

  if not ok then
    return nil, result
  end
  return result, nil
end

-- Utility: Print colored output
local function print_colored(color, text)
  local colors = {
    red = '\27[0;31m',
    green = '\27[0;32m',
    yellow = '\27[1;33m',
    blue = '\27[0;34m',
    reset = '\27[0m'
  }
  print(colors[color] .. text .. colors.reset)
end

-- Utility: Get plugin directory files
local function get_plugin_files()
  local plugins_dir = "lua/plugins"
  local files = {}

  local handle = vim.loop.fs_scandir(plugins_dir)
  if handle then
    while true do
      local name, typ = vim.loop.fs_scandir_next(handle)
      if not name then break end

      if typ == "file" and name:match("%.lua$") and name ~= "init.lua" then
        table.insert(files, {
          name = name,
          path = plugins_dir .. "/" .. name
        })
      end
    end
  end

  return files
end

-- Check 1: Plugin Spec Structure Validation
local function validate_plugin_specs()
  print_colored('blue', '📦 Validating plugin spec structures...')
  print('')

  local plugin_files = get_plugin_files()

  if #plugin_files == 0 then
    print_colored('yellow', '⚠️  No plugin files found in lua/plugins/')
    return
  end

  for _, file_info in ipairs(plugin_files) do
    local spec, err = safe_require(file_info.path)

    if not spec then
      add_error(file_info.name, "Failed to load: " .. tostring(err))
      print_colored('red', '  ✗ ' .. file_info.name .. ' - Load failed')
    elseif type(spec) ~= "table" then
      add_error(file_info.name, "Must return table (got " .. type(spec) .. ")")
      print_colored('red', '  ✗ ' .. file_info.name .. ' - Not a table')
    elseif type(spec[1]) ~= "string" then
      add_error(file_info.name, "spec[1] must be plugin repo URL (string)")
      print_colored('red', '  ✗ ' .. file_info.name .. ' - Missing repo URL')
    else
      -- Validate lazy.nvim fields
      validate_lazy_fields(file_info.name, spec)
      print_colored('green', '  ✓ ' .. file_info.name)
    end
  end

  if #errors == 0 then
    print('')
    print_colored('green', '✅ All plugin specs are valid')
  end
end

-- Check 2: Lazy.nvim Field Validation
function validate_lazy_fields(filename, spec)
  -- Check for deprecated 'config = {}' pattern
  if spec.config and type(spec.config) == "table" and vim.tbl_isempty(spec.config) then
    add_error(filename, "Use 'opts = {}' instead of 'config = {}'", "WARNING")
  end

  -- Check for lazy loading configuration
  -- Lazy plugins should have a trigger (event/cmd/keys/ft) or set lazy=false
  if spec.lazy ~= false then
    local has_trigger = spec.event or spec.cmd or spec.keys or spec.ft

    if not has_trigger then
      add_error(
        filename,
        "Lazy plugin needs trigger: event, cmd, keys, ft (or set lazy=false)",
        "WARNING"
      )
    end
  end

  -- Check for invalid field combinations
  if spec.config and spec.opts then
    add_error(
      filename,
      "Cannot use both 'config' and 'opts' - choose one",
      "WARNING"
    )
  end

  -- Validate dependencies format
  if spec.dependencies then
    if type(spec.dependencies) == "string" then
      add_error(
        filename,
        "dependencies should be array: dependencies = { 'plugin' }",
        "WARNING"
      )
    end
  end
end

-- Check 3: Keymap Conflict Detection
local function validate_keymaps()
  print('')
  print_colored('blue', '⌨️  Checking for keymap conflicts...')
  print('')

  local keymaps_file = "lua/config/keymaps.lua"
  local ok, content = pcall(function()
    local f = io.open(keymaps_file, "r")
    if not f then return nil end
    local c = f:read("*all")
    f:close()
    return c
  end)

  if not ok or not content then
    print_colored('yellow', '⚠️  Could not read keymaps.lua')
    return
  end

  -- Extract keymaps: vim.keymap.set("mode", "key", ...)
  local seen_keymaps = {}
  local conflicts = {}

  for mode, key in content:gmatch('vim%.keymap%.set%s*%(%s*["\']([^"\']+)["\']%s*,%s*["\']([^"\']+)["\']') do
    local keymap_id = mode .. ":" .. key

    if seen_keymaps[keymap_id] then
      table.insert(conflicts, {
        mode = mode,
        key = key,
        first_line = seen_keymaps[keymap_id],
        conflict_line = "unknown"  -- Would need line number parsing
      })
      add_error("keymaps.lua", "Duplicate keymap: mode=" .. mode .. " key=" .. key, "WARNING")
    else
      seen_keymaps[keymap_id] = "unknown"
    end
  end

  if #conflicts == 0 then
    print_colored('green', '✅ No keymap conflicts detected')
  else
    print_colored('yellow', '⚠️  ' .. #conflicts .. ' keymap conflicts found')
    for _, conflict in ipairs(conflicts) do
      print(string.format("  - %s: %s", conflict.mode, conflict.key))
    end
  end
end

-- Check 4: Circular Dependency Detection (basic)
local function validate_dependencies()
  print('')
  print_colored('blue', '🔄 Checking plugin dependencies...')
  print('')

  local plugin_files = get_plugin_files()
  local plugin_deps = {}

  -- Build dependency graph
  for _, file_info in ipairs(plugin_files) do
    local spec, _ = safe_require(file_info.path)

    if spec and type(spec) == "table" and type(spec[1]) == "string" then
      local plugin_name = spec[1]
      plugin_deps[plugin_name] = {
        file = file_info.name,
        deps = {}
      }

      if spec.dependencies then
        if type(spec.dependencies) == "table" then
          for _, dep in ipairs(spec.dependencies) do
            if type(dep) == "string" then
              table.insert(plugin_deps[plugin_name].deps, dep)
            elseif type(dep) == "table" and type(dep[1]) == "string" then
              table.insert(plugin_deps[plugin_name].deps, dep[1])
            end
          end
        end
      end
    end
  end

  -- Simple circular dependency check (only direct cycles)
  for plugin, info in pairs(plugin_deps) do
    for _, dep in ipairs(info.deps) do
      if plugin_deps[dep] then
        for _, dep2 in ipairs(plugin_deps[dep].deps) do
          if dep2 == plugin then
            add_error(
              info.file,
              "Circular dependency detected: " .. plugin .. " ↔ " .. dep,
              "WARNING"
            )
          end
        end
      end
    end
  end

  print_colored('green', '✅ Dependency check complete')
end

-- Main execution
print_colored('blue', '🔍 Layer 2: Structural Validation')
print('========================================')
print('')

validate_plugin_specs()
validate_keymaps()
validate_dependencies()

-- Print summary
print('')
print('========================================')

if #errors == 0 then
  print_colored('green', '✅ Layer 2 validation passed')
  if #warnings > 0 then
    print_colored('yellow', '⚠️  ' .. #warnings .. ' warnings (non-blocking):')
    for _, warning in ipairs(warnings) do
      print(string.format('   - %s: %s', warning.file, warning.msg))
    end
  end
  os.exit(0)
else
  print_colored('red', '❌ Layer 2 validation failed')
  print_colored('red', '   Errors: ' .. #errors)
  if #warnings > 0 then
    print_colored('yellow', '   Warnings: ' .. #warnings)
  end
  print('')

  print('Errors:')
  for _, error in ipairs(errors) do
    print(string.format('  ❌ %s: %s', error.file, error.msg))
  end

  if #warnings > 0 then
    print('')
    print('Warnings:')
    for _, warning in ipairs(warnings) do
      print(string.format('  ⚠️  %s: %s', warning.file, warning.msg))
    end
  end

  os.exit(1)
end
