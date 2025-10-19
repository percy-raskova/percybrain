-- Luacheck configuration for PercyBrain
-- Static analysis rules for Neovim plugin development
-- Run: luacheck . (to check all Lua files)
-- Run: luacheck --no-color lua/plugins/my-plugin.lua (specific file)

-- Ignore W211 (unused variable) for specific patterns
ignore = {
  "211/_.*",     -- Ignore unused variables starting with _
  "212",         -- Unused argument
}

-- Allow vim global (Neovim API)
globals = {
  "vim",
}

-- Per-file configurations
files["tests/helpers/assertions.lua"] = {
  -- Allow extending assert global with custom assertions (intentional for test framework)
  globals = { "assert" },
}

files["tests/helpers/mocks.lua"] = {
  -- Mock factory module - exports functions for other tests to use
  -- Functions unused within this file but imported by other tests
  ignore = { "M" }, -- Ignore unused assignments to module table
}

files["tests/plenary/unit/config_spec.lua"] = {
  -- Test needs to inspect _G for global pollution detection (intentional)
  globals = { "_G" },
}

-- Exclude directories
exclude_files = {
  ".git",
  "lazy-lock.json",
}

-- Max line length
max_line_length = 120

-- Max code complexity
max_cyclomatic_complexity = 15
