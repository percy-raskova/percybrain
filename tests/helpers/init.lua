-- PercyBrain Test Helpers
-- Common utilities for Plenary test suites

local M = {}

-- Path utilities
M.test_dir = vim.fn.fnamemodify(debug.getinfo(1).source:sub(2), ":h:h")
M.root_dir = vim.fn.fnamemodify(M.test_dir, ":h")
M.fixture_dir = M.test_dir .. "/fixtures"

-- Load a fixture file
function M.load_fixture(name)
  local path = M.fixture_dir .. "/" .. name
  if vim.fn.filereadable(path) == 1 then
    return vim.fn.readfile(path)
  end
  error("Fixture not found: " .. path)
end

-- Create temporary test directory
function M.create_temp_dir()
  local tmpdir = vim.fn.tempname()
  vim.fn.mkdir(tmpdir, "p")
  return tmpdir
end

-- Clean up temporary directory
function M.cleanup_temp_dir(dir)
  if vim.fn.isdirectory(dir) == 1 then
    vim.fn.delete(dir, "rf")
  end
end

-- Wait for condition with timeout
function M.wait_for(condition, timeout)
  timeout = timeout or 1000 -- 1 second default
  local start = vim.loop.now()

  while not condition() do
    if vim.loop.now() - start > timeout then
      error("Timeout waiting for condition")
    end
    vim.wait(10)
  end
end

-- Async test helper
function M.async_test(fn)
  local co = coroutine.create(fn)
  local ok, err = coroutine.resume(co)
  if not ok then
    error(err)
  end

  -- Wait for coroutine to complete
  while coroutine.status(co) ~= "dead" do
    vim.wait(10)
  end
end

-- Mock vim.notify for testing
function M.mock_notify()
  local notifications = {}
  local original = vim.notify

  vim.notify = function(msg, level)
    table.insert(notifications, {
      message = msg,
      level = level,
    })
  end

  return {
    notifications = notifications,
    restore = function()
      vim.notify = original
    end,
  }
end

-- Ensure plugin is loaded
function M.ensure_plugin(name)
  local lazy = require("lazy")
  local plugin = lazy.plugins()[name]

  if plugin and not plugin.loaded then
    -- Force load the plugin
    require("lazy").load({ plugins = { name } })
  end

  return plugin
end

-- Create a test buffer
function M.create_test_buffer(options)
  options = options or {}
  local buf = vim.api.nvim_create_buf(false, true)

  if options.content then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, options.content)
  end

  if options.filetype then
    vim.api.nvim_buf_set_option(buf, "filetype", options.filetype)
  end

  if options.name then
    vim.api.nvim_buf_set_name(buf, options.name)
  end

  return buf
end

-- Switch to test buffer
function M.switch_to_buffer(buf)
  vim.api.nvim_set_current_buf(buf)
end

-- Clean up test buffer
function M.cleanup_buffer(buf)
  if vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_buf_delete(buf, { force = true })
  end
end

return M
