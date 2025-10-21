-- Central Keymap Registry
-- Purpose: Single source of truth for all keymaps with conflict detection
-- Usage: Import keymap modules into plugin specs for lazy loading

local M = {}

-- Keymap conflict detection
local registered_keys = {}

-- Register a keymap and check for conflicts
local function register(key, description, source)
  if registered_keys[key] then
    vim.notify(
      string.format(
        "⚠️  Keymap conflict: %s\n  Already used by: %s\n  New mapping: %s",
        key,
        registered_keys[key],
        source
      ),
      vim.log.levels.WARN
    )
  end
  registered_keys[key] = source
end

-- Validate and register keymaps from a module
function M.register_module(module_name, keymaps)
  for _, keymap in ipairs(keymaps) do
    local key = keymap[1] or keymap.key
    local desc = keymap.desc or keymap[3] or "No description"
    register(key, desc, module_name)
  end
  return keymaps
end

-- Get all registered keymaps (for debugging)
function M.list_all()
  local sorted = {}
  for key, source in pairs(registered_keys) do
    table.insert(sorted, { key = key, source = source })
  end
  table.sort(sorted, function(a, b)
    return a.key < b.key
  end)
  return sorted
end

-- Print keymap registry (useful for :lua require('config.keymaps').list_all())
function M.print_registry()
  local all = M.list_all()
  print("\n📋 Keymap Registry:")
  print("==================")
  for _, entry in ipairs(all) do
    print(string.format("%-20s → %s", entry.key, entry.source))
  end
  print("\nTotal keymaps: " .. #all)
end

return M
