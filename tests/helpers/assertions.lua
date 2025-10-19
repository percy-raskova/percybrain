-- PercyBrain Custom Assertions
-- Extended assertions for Plenary tests

local M = {}

-- Assert file exists
function M.file_exists(path)
  local stat = vim.loop.fs_stat(path)
  assert.is_not_nil(stat, "File does not exist: " .. path)
  assert.equals("file", stat.type, path .. " is not a file")
end

-- Assert directory exists
function M.dir_exists(path)
  local stat = vim.loop.fs_stat(path)
  assert.is_not_nil(stat, "Directory does not exist: " .. path)
  assert.equals("directory", stat.type, path .. " is not a directory")
end

-- Assert plugin is loaded
function M.plugin_loaded(name)
  local lazy = require('lazy')
  local plugin = lazy.plugins()[name]
  assert.is_not_nil(plugin, "Plugin not found: " .. name)
  assert.is_true(plugin.loaded, "Plugin not loaded: " .. name)
end

-- Assert plugin is NOT loaded (lazy)
function M.plugin_lazy(name)
  local lazy = require('lazy')
  local plugin = lazy.plugins()[name]
  assert.is_not_nil(plugin, "Plugin not found: " .. name)
  assert.is_false(plugin.loaded or false, "Plugin should be lazy: " .. name)
end

-- Assert keymap exists
function M.keymap_exists(mode, lhs)
  local keymaps = vim.api.nvim_get_keymap(mode)
  local found = false
  for _, keymap in ipairs(keymaps) do
    if keymap.lhs == lhs then
      found = true
      break
    end
  end
  assert.is_true(found, string.format("Keymap not found: %s %s", mode, lhs))
end

-- Assert keymap has specific rhs
function M.keymap_equals(mode, lhs, expected_rhs)
  local keymaps = vim.api.nvim_get_keymap(mode)
  for _, keymap in ipairs(keymaps) do
    if keymap.lhs == lhs then
      assert.equals(expected_rhs, keymap.rhs,
        string.format("Keymap %s %s has wrong rhs", mode, lhs))
      return
    end
  end
  error(string.format("Keymap not found: %s %s", mode, lhs))
end

-- Assert autocmd exists
function M.autocmd_exists(event, pattern)
  local autocmds = vim.api.nvim_get_autocmds({ event = event })
  for _, autocmd in ipairs(autocmds) do
    if not pattern or autocmd.pattern == pattern then
      return true
    end
  end
  assert.is_true(false, string.format("Autocmd not found: %s %s", event, pattern or "*"))
end

-- Assert buffer content
function M.buffer_contains(buf, text)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local content = table.concat(lines, "\n")
  assert.is_true(content:find(text, 1, true) ~= nil,
    "Buffer does not contain: " .. text)
end

-- Assert LSP client attached
function M.lsp_attached(buf)
  buf = buf or 0
  local clients = vim.lsp.get_active_clients({ bufnr = buf })
  assert.is_true(#clients > 0, "No LSP clients attached to buffer")
end

-- Assert specific LSP client attached
function M.lsp_client_attached(buf, client_name)
  buf = buf or 0
  local clients = vim.lsp.get_active_clients({ bufnr = buf })
  for _, client in ipairs(clients) do
    if client.name == client_name then
      return true
    end
  end
  assert.is_true(false, "LSP client not attached: " .. client_name)
end

-- Assert performance metric
function M.performance_under(metric_fn, threshold, message)
  local value = metric_fn()
  assert.is_true(value < threshold,
    string.format("%s: %s (threshold: %s)", message or "Performance exceeded", value, threshold))
end

-- Assert memory usage
function M.memory_under_mb(max_mb)
  collectgarbage('collect')
  local memory_kb = collectgarbage('count')
  local memory_mb = memory_kb / 1024
  assert.is_true(memory_mb < max_mb,
    string.format("Memory usage: %.2fMB (max: %.2fMB)", memory_mb, max_mb))
end

-- Assert table contains value
function M.contains(tbl, value)
  for _, v in ipairs(tbl) do
    if v == value then
      return true
    end
  end
  assert.is_true(false, "Table does not contain value: " .. tostring(value))
end

-- Assert table contains key
function M.has_key(tbl, key)
  assert.is_not_nil(tbl[key], "Table missing key: " .. tostring(key))
end

-- Assert neurodiversity feature enabled
function M.neurodiversity_feature_enabled(feature)
  local features = {
    auto_save = function()
      return pcall(require, 'auto-save')
    end,
    auto_session = function()
      return pcall(require, 'auto-session')
    end,
    telekasten = function()
      return pcall(require, 'telekasten')
    end,
    trouble = function()
      return pcall(require, 'trouble')
    end,
  }

  local check = features[feature]
  assert.is_not_nil(check, "Unknown neurodiversity feature: " .. feature)

  local ok = check()
  assert.is_true(ok, "Neurodiversity feature not enabled: " .. feature)
end

-- Add assertion shortcuts to global assert
local function extend_assert()
  assert.file_exists = M.file_exists
  assert.dir_exists = M.dir_exists
  assert.plugin_loaded = M.plugin_loaded
  assert.plugin_lazy = M.plugin_lazy
  assert.keymap_exists = M.keymap_exists
  assert.keymap_equals = M.keymap_equals
  assert.autocmd_exists = M.autocmd_exists
  assert.buffer_contains = M.buffer_contains
  assert.lsp_attached = M.lsp_attached
  assert.lsp_client_attached = M.lsp_client_attached
  assert.performance_under = M.performance_under
  assert.memory_under_mb = M.memory_under_mb
  assert.contains = M.contains
  assert.has_key = M.has_key
  assert.neurodiversity_feature_enabled = M.neurodiversity_feature_enabled
end

-- Auto-extend on require
extend_assert()

return M