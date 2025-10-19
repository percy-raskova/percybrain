#!/usr/bin/env lua

-- Plugin Spec Validator for lazy.nvim
-- Ensures plugin files return proper table structures
-- Run: lua hooks/validate-plugin-spec.lua <file1.lua> <file2.lua> ...

local exit_code = 0
local files = { ... } -- Files passed by pre-commit

if #files == 0 then
  io.stderr:write("❌ No files provided\n")
  os.exit(1)
end

for _, file in ipairs(files) do
  local function validate_file()
    -- Read file content
    local f = io.open(file, "r")
    if not f then
      io.stderr:write(string.format("❌ %s: Cannot read file\n", file))
      exit_code = 1
      return
    end

    local content = f:read("*all")
    f:close()

    -- Check 1: Must have return statement
    if not content:match("return%s+{") and not content:match("return%s+M") then
      io.stderr:write(string.format("❌ %s: Missing return statement\n", file))
      io.stderr:write("   Fix: Add 'return { ... }' for plugin spec\n")
      exit_code = 1
      return
    end

    -- Check 2: Plugin files should return table
    if content:match("return%s+{") then
      -- Valid: return { "plugin/repo", ... }
      -- Valid: return { import = "plugins.dir" }

      -- Check for import specs
      if content:match('import%s*=%s*"plugins%.') then
        -- Import spec - this is fine, no further checks needed
        return
      end

      -- Check for plugin repo in first element
      local has_plugin_repo = content:match('return%s+{%s*"[^"]+/[^"]+"')
      local has_plugin_string = content:match('return%s+{%s*"[^"]+"')

      if has_plugin_string and not has_plugin_repo then
        io.stderr:write(string.format("⚠️  %s: Plugin string doesn't look like 'author/repo' format\n", file))
        io.stderr:write('   Expected: return { "author/repo", ... }\n')
        -- Warning only, not an error
      end
    end

    -- Check 3: Warn about potentially incomplete specs
    local simple_plugin = content:match('return%s+{%s*"[^"]+"')
    local has_config = content:match("config%s*=%s*function") or content:match("opts%s*=")
    if simple_plugin and not has_config then
      io.stderr:write(string.format("ℹ️  %s: Plugin spec has no config function or opts\n", file))
      io.stderr:write("   This is OK for simple plugins, but consider adding config if needed\n")
    end
  end

  validate_file()
end

os.exit(exit_code)
