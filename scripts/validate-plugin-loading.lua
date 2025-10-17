#!/usr/bin/env -S nvim --headless -l
--
-- OVIWrite Layer 3 Validation: Plugin Loading Test
-- Tests: Each plugin can be loaded individually without errors
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

print_colored('blue', '🔌 Layer 3: Plugin Loading Validation')
print('========================================')
print('')

-- Load config first
local config_ok, config_err = pcall(require, 'config')
if not config_ok then
  print_colored('red', '❌ Failed to load config: ' .. tostring(config_err))
  os.exit(1)
end

-- Wait for lazy to initialize
vim.wait(5000, function()
  return pcall(require, 'lazy')
end)

-- Get lazy.nvim
local lazy_ok, lazy = pcall(require, 'lazy')
if not lazy_ok then
  print_colored('red', '❌ lazy.nvim not available')
  os.exit(1)
end

-- Get list of plugins
local plugins = lazy.plugins()
local total = vim.tbl_count(plugins)

print_colored('blue', '📦 Found ' .. total .. ' plugins to test')
print('')

local failures = {}
local successes = {}
local skipped = {}

-- Test each plugin
for name, plugin in pairs(plugins) do
  -- Skip already loaded plugins
  if plugin._.loaded then
    table.insert(skipped, name)
    goto continue
  end

  -- Try loading the plugin
  local ok, err = pcall(function()
    lazy.load({ name })
  end)

  if ok then
    table.insert(successes, name)
    print_colored('green', '  ✓ ' .. name)
  else
    table.insert(failures, {
      name = name,
      error = tostring(err)
    })
    print_colored('red', '  ✗ ' .. name)
    print('    Error: ' .. tostring(err))
  end

  ::continue::
end

-- Print summary
print('')
print('========================================')
print('Plugin Loading Summary:')
print('--------------------')
print_colored('green', '  ✓ Loaded:  ' .. #successes)
print_colored('blue',  '  ⊙ Skipped: ' .. #skipped .. ' (already loaded)')
print_colored('red',   '  ✗ Failed:  ' .. #failures)
print('')

if #failures == 0 then
  print_colored('green', '✅ Plugin loading validation passed')
  print_colored('green', '   All plugins loaded successfully')
  os.exit(0)
else
  print_colored('red', '❌ Plugin loading validation failed')
  print_colored('red', '   ' .. #failures .. ' plugin(s) failed to load:')
  print('')

  for _, failure in ipairs(failures) do
    print('  ❌ ' .. failure.name)
    print('     ' .. failure.error)
    print('')
  end

  os.exit(1)
end
