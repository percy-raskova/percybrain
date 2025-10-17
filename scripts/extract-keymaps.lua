#!/usr/bin/env -S nvim --headless -l
--
-- OVIWrite Documentation Helper: Extract Keymaps
-- Generates markdown table of keyboard shortcuts from keymaps.lua
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

print_colored('blue', '⌨️  Keymap Documentation Generator')
print('========================================')
print('')

-- Read keymaps.lua
local keymaps_file = io.open("lua/config/keymaps.lua", "r")
if not keymaps_file then
  print_colored('red', '❌ Could not read lua/config/keymaps.lua')
  os.exit(1)
end

local content = keymaps_file:read("*all")
keymaps_file:close()

-- Extract keymaps
local keymaps = {}

-- Pattern: vim.keymap.set("mode", "key", command, { desc = "description" })
for mode, key, desc in content:gmatch('vim%.keymap%.set%s*%(%s*["\']([^"\']+)["\']%s*,%s*["\']([^"\']+)["\']%s*,[^,]*,%s*{[^}]*desc%s*=%s*["\']([^"\']+)["\']') do
  table.insert(keymaps, {
    mode = mode,
    key = key,
    desc = desc
  })
end

-- Alternative pattern without desc field
for mode, key in content:gmatch('vim%.keymap%.set%s*%(%s*["\']([^"\']+)["\']%s*,%s*["\']([^"\']+)["\']') do
  -- Check if we already have this keymap (from first pattern)
  local exists = false
  for _, km in ipairs(keymaps) do
    if km.mode == mode and km.key == key then
      exists = true
      break
    end
  end

  if not exists then
    table.insert(keymaps, {
      mode = mode,
      key = key,
      desc = "[No description]"
    })
  end
end

print_colored('blue', '📋 Found ' .. #keymaps .. ' keymaps')
print('')

-- Filter to leader keymaps only
local leader_keymaps = {}
for _, km in ipairs(keymaps) do
  if km.key:match("^<leader>") then
    table.insert(leader_keymaps, km)
  end
end

print_colored('blue', '🎯 Found ' .. #leader_keymaps .. ' leader key shortcuts')
print('')

-- Sort by key
table.sort(leader_keymaps, function(a, b)
  return a.key < b.key
end)

-- Generate markdown table
print('========================================')
print('Markdown Output (copy to CLAUDE.md):')
print('========================================')
print('')
print('### Core Shortcuts (lua/config/keymaps.lua)')
print('| Key Combo | Action | Mode |')
print('|-----------|--------|------|')

for _, km in ipairs(leader_keymaps) do
  local mode_name = km.mode == "n" and "Normal" or
                    km.mode == "i" and "Insert" or
                    km.mode == "v" and "Visual" or
                    km.mode

  print(string.format('| `%s` | %s | %s |', km.key, km.desc, mode_name))
end

print('')
print('========================================')
print_colored('green', '✅ Keymap documentation generated')
print('')
print_colored('yellow', '💡 Copy the table above to CLAUDE.md "Keyboard Shortcuts" section')

os.exit(0)
