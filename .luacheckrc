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

files["tests/capability/write-quit/pipeline_workflow_spec.lua"] = {
  -- Line 61: Multi-condition assert statement exceeds 120 chars (stylua formatted)
  max_line_length = false, -- Disable line length check for this file
}

files["tests/health/health-validation.test.lua"] = {
  -- Plenary BDD-style test framework globals (describe, it, before_each, etc.)
  globals = { "describe", "it", "before_each", "after_each", "pending", "assert" },
}

files["tests/unit/treesitter_python_parser_spec.lua"] = {
  -- Unused variable in legacy test (tree is for future debugging)
  ignore = { "211/tree" },
}

files["tests/capability/ai/model_selection_workflow_spec.lua"] = {
  -- Unused variables reserved for future test expansion
  ignore = { "211/original_model", "231/has_model_picker_key" },
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
