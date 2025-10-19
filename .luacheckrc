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

-- Exclude directories
exclude_files = {
  ".git",
  "lazy-lock.json",
}

-- Max line length
max_line_length = 120

-- Max code complexity
max_cyclomatic_complexity = 15
