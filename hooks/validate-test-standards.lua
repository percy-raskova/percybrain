#!/usr/bin/env lua

-- Test Standards Validator
-- Enforces PercyBrain 6/6 testing standards
-- Run: lua hooks/validate-test-standards.lua <file1_spec.lua> <file2_spec.lua> ...

local standards = {
  {
    name = "Helper/Mock Imports",
    check = function(content)
      -- Only require imports if helpers/mocks are actually used
      local uses_helpers = content:match("helpers%.") or content:match("mocks%.")
      local has_imports = content:match("require%('tests%.helpers'%)")
        or content:match("require%('tests%.helpers%.mocks'%)")

      -- If not using helpers/mocks, pass automatically
      if not uses_helpers then
        return true
      end

      -- If using them, must have imports
      return has_imports
    end,
    fix = "Add: local helpers = require('tests.helpers') (only if using helpers/mocks)",
  },
  {
    name = "State Management (before_each/after_each)",
    check = function(content)
      return content:match("before_each") and content:match("after_each")
    end,
    fix = "Add before_each/after_each functions for test isolation",
  },
  {
    name = "AAA Pattern Comments",
    check = function(content)
      local arrange = content:match("%-%-+%s*Arrange")
      local act = content:match("%-%-+%s*Act")
      local assert = content:match("%-%-+%s*Assert")
      return arrange and act and assert
    end,
    fix = "Add AAA comments: -- Arrange, -- Act, -- Assert",
  },
  {
    name = "No Global Pollution",
    check = function(content)
      return not content:match("_G%.")
    end,
    fix = "Remove _G. references, use local variables instead",
  },
  {
    name = "Local Helper Functions",
    check = function(content)
      -- Should have 'local function' or is simple enough not to need it
      return content:match("local function") or #content < 200
    end,
    fix = "Define helper functions as 'local function name()'",
  },
  {
    name = "No Raw assert.contains",
    check = function(content)
      -- Should use local contains() helper, not assert.contains directly
      if content:match("assert%.contains") then
        return content:match("local function contains")
      end
      return true -- No assert.contains used, that's fine
    end,
    fix = "Use local contains() helper instead of assert.contains",
  },
}

local exit_code = 0
local files = { ... }

if #files == 0 then
  io.stderr:write("❌ No files provided\n")
  os.exit(1)
end

for _, file in ipairs(files) do
  local function validate_file()
    local f = io.open(file, "r")
    if not f then
      return
    end

    local content = f:read("*all")
    f:close()

    local failures = {}

    for i, standard in ipairs(standards) do
      if not standard.check(content) then
        table.insert(failures, {
          number = i,
          name = standard.name,
          fix = standard.fix,
        })
      end
    end

    if #failures > 0 then
      io.stderr:write(string.format("\n⚠️  %s: %d/%d standards\n", file, 6 - #failures, 6))
      for _, failure in ipairs(failures) do
        io.stderr:write(string.format("   ❌ [%d/6] %s\n", failure.number, failure.name))
        io.stderr:write(string.format("      Fix: %s\n", failure.fix))
      end
      exit_code = 1
    else
      io.stderr:write(string.format("✅ %s: 6/6 standards\n", file))
    end
  end

  validate_file()
end

os.exit(exit_code)
