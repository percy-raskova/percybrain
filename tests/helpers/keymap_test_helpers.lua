--- Keymap Test Helpers
--- Reusable helper functions for keymap centralization tests
--- @module tests.helpers.keymap_test_helpers

local M = {}

--- Build an absolute path to a file within the Neovim config directory
--- @param relative_path string Path relative to config root (e.g., "lua/config/keymaps.lua")
--- @return string Absolute path to the file
function M.config_path(relative_path)
  return vim.fn.stdpath("config") .. "/" .. relative_path
end

--- Read a file's contents as a single string
--- @param file_path string Absolute path to the file
--- @return string File contents with lines joined by newlines
function M.read_file_content(file_path)
  return table.concat(vim.fn.readfile(file_path), "\n")
end

--- Check if a file exists and is readable
--- @param file_path string Absolute path to the file
--- @return boolean True if file exists and is readable
function M.file_exists(file_path)
  return vim.fn.filereadable(file_path) == 1
end

--- Check if file content matches a pattern
--- @param file_path string Absolute path to the file
--- @param pattern string Lua pattern to search for
--- @return boolean True if pattern is found in file
function M.file_contains_pattern(file_path, pattern)
  local content = M.read_file_content(file_path)
  return content:match(pattern) ~= nil
end

--- Clear all keymap module caches
--- Useful in before_each/after_each hooks
function M.clear_keymap_cache()
  package.loaded["config.keymaps"] = nil
end

--- Escape special characters in a module name for pattern matching
--- Handles both dots (module separators) and hyphens (in module names like "quick-capture")
--- @param module_name string Module name (e.g., "config.keymaps.quick-capture")
--- @return string Escaped pattern suitable for Lua pattern matching
function M.escape_module_name(module_name)
  return module_name:gsub("%.", "%%."):gsub("%-", "%%-")
end

--- Check if a module is required/loaded in a file
--- @param file_path string Absolute path to the file
--- @param module_name string Module name to check (e.g., "config.keymaps.core")
--- @return boolean True if module is required in the file
function M.file_requires_module(file_path, module_name)
  local content = M.read_file_content(file_path)
  local escaped_module = M.escape_module_name(module_name)
  local pattern = 'require%("' .. escaped_module .. '"%)'
  return content:match(pattern) ~= nil
end

--- Build a list of all keymap module paths (Phase 3 - Hierarchical Structure)
--- @return table<string> List of absolute paths to all keymap module files
function M.get_all_keymap_module_paths()
  local modules = {
    -- System
    "lua/config/keymaps/system/core.lua",
    "lua/config/keymaps/system/dashboard.lua",
    -- Workflows
    "lua/config/keymaps/workflows/zettelkasten.lua",
    "lua/config/keymaps/workflows/ai.lua",
    "lua/config/keymaps/workflows/prose.lua",
    "lua/config/keymaps/workflows/quick-capture.lua",
    -- Tools
    "lua/config/keymaps/tools/telescope.lua",
    "lua/config/keymaps/tools/navigation.lua",
    "lua/config/keymaps/tools/git.lua",
    "lua/config/keymaps/tools/diagnostics.lua",
    "lua/config/keymaps/tools/window.lua",
    "lua/config/keymaps/tools/lynx.lua",
    -- Environment
    "lua/config/keymaps/environment/terminal.lua",
    "lua/config/keymaps/environment/focus.lua",
    "lua/config/keymaps/environment/translation.lua",
    -- Organization
    "lua/config/keymaps/organization/time-tracking.lua",
    -- Utilities (standalone)
    "lua/config/keymaps/utilities.lua",
  }

  local paths = {}
  for _, module in ipairs(modules) do
    table.insert(paths, M.config_path(module))
  end

  return paths
end

--- Build a list of all keymap module names (Phase 3 - Hierarchical Structure)
--- @return table<string> List of module names (e.g., "config.keymaps.system.core")
function M.get_all_keymap_module_names()
  return {
    -- System
    "config.keymaps.system.core",
    "config.keymaps.system.dashboard",
    -- Workflows
    "config.keymaps.workflows.zettelkasten",
    "config.keymaps.workflows.ai",
    "config.keymaps.workflows.prose",
    "config.keymaps.workflows.quick-capture",
    -- Tools
    "config.keymaps.tools.telescope",
    "config.keymaps.tools.navigation",
    "config.keymaps.tools.git",
    "config.keymaps.tools.diagnostics",
    "config.keymaps.tools.window",
    "config.keymaps.tools.lynx",
    -- Environment
    "config.keymaps.environment.terminal",
    "config.keymaps.environment.focus",
    "config.keymaps.environment.translation",
    -- Organization
    "config.keymaps.organization.time-tracking",
    -- Utilities (standalone)
    "config.keymaps.utilities",
  }
end

return M
