--- GTD Test Helpers
--- Reusable helper functions for GTD system tests
--- @module tests.helpers.gtd_test_helpers

-- luacheck: globals assert (plenary.busted provides assert extensions)

local M = {}

--- Get the GTD root directory path
--- @return string Absolute path to GTD directory
function M.gtd_root()
  return vim.fn.expand("~/Zettelkasten/gtd")
end

--- Build an absolute path to a GTD file or directory
--- @param relative_path string Path relative to GTD root (e.g., "inbox.md")
--- @return string Absolute path to the GTD file
function M.gtd_path(relative_path)
  return M.gtd_root() .. "/" .. relative_path
end

--- Check if a directory exists
--- @param dir_path string Absolute path to directory
--- @return boolean True if directory exists
function M.dir_exists(dir_path)
  return vim.fn.isdirectory(dir_path) == 1
end

--- Check if a file exists and is readable
--- @param file_path string Absolute path to file
--- @return boolean True if file exists and is readable
function M.file_exists(file_path)
  return vim.fn.filereadable(file_path) == 1
end

--- Read a file's contents as a single string
--- @param file_path string Absolute path to the file
--- @return string File contents with lines joined by newlines
function M.read_file_content(file_path)
  if not M.file_exists(file_path) then
    return ""
  end
  return table.concat(vim.fn.readfile(file_path), "\n")
end

--- Check if file content matches a pattern
--- @param file_path string Absolute path to the file
--- @param pattern string Lua pattern to search for
--- @return boolean True if pattern is found in file
function M.file_contains_pattern(file_path, pattern)
  local content = M.read_file_content(file_path)
  return content:match(pattern) ~= nil
end

--- Clean up GTD test directories and files
--- WARNING: Only call this in test teardown!
function M.cleanup_gtd_test_data()
  local gtd_root = M.gtd_root()
  if M.dir_exists(gtd_root) then
    vim.fn.delete(gtd_root, "rf")
  end
end

--- Get expected GTD base files
--- @return table<string> List of base file names
function M.get_base_files()
  return {
    "inbox.md",
    "next-actions.md",
    "projects.md",
    "someday-maybe.md",
    "waiting-for.md",
    "reference.md",
  }
end

--- Get expected GTD context files
--- @return table<string> List of context file names
function M.get_context_files()
  return {
    "contexts/home.md",
    "contexts/work.md",
    "contexts/computer.md",
    "contexts/phone.md",
    "contexts/errands.md",
  }
end

--- Get expected GTD directories
--- @return table<string> List of directory names relative to GTD root
function M.get_gtd_directories()
  return {
    "contexts",
    "projects",
    "archive",
  }
end

--- Clear GTD module cache
--- Useful in before_each/after_each hooks
function M.clear_gtd_cache()
  package.loaded["percybrain.gtd"] = nil
  package.loaded["percybrain.gtd.init"] = nil
  package.loaded["percybrain.gtd.capture"] = nil
  package.loaded["percybrain.gtd.clarify"] = nil
  package.loaded["percybrain.gtd.organize"] = nil
  package.loaded["percybrain.gtd.reflect"] = nil
  package.loaded["percybrain.gtd.engage"] = nil
  package.loaded["percybrain.gtd.ai"] = nil
end

-- ============================================================================
-- AI Testing Helpers (Phase 3 - REFACTOR phase)
-- ============================================================================

--- Wait for async AI callback with standard timeout
--- @param condition function Condition to wait for (returns boolean)
--- @param timeout_ms? number Timeout in milliseconds (default: 10000)
--- @param interval_ms? number Check interval (default: 100)
--- @return boolean success Whether condition was met within timeout
function M.wait_for_ai_response(condition, timeout_ms, interval_ms)
  local timeout = timeout_ms or 10000
  local interval = interval_ms or 100

  return vim.wait(timeout, condition, interval) == 0
end

--- Wait for buffer line count to change (task decomposition)
--- @param buf number Buffer handle
--- @param original_count number Original line count
--- @param timeout_ms? number Timeout in milliseconds (default: 10000)
--- @return boolean success Whether lines changed
function M.wait_for_buffer_change(buf, original_count, timeout_ms)
  return M.wait_for_ai_response(function()
    return vim.api.nvim_buf_line_count(buf) > original_count
  end, timeout_ms)
end

--- Wait for line to be modified (context/priority suggestion)
--- @param buf number Buffer handle
--- @param line_num number Line number (1-indexed)
--- @param original_line string Original line content
--- @param timeout_ms? number Timeout in milliseconds (default: 10000)
--- @return boolean success Whether line changed
function M.wait_for_line_change(buf, line_num, original_line, timeout_ms)
  return M.wait_for_ai_response(function()
    local lines = vim.api.nvim_buf_get_lines(buf, line_num - 1, line_num, false)
    return lines[1] and lines[1] ~= original_line
  end, timeout_ms)
end

--- Create test buffer with GTD task
--- @param lines string|table Task line(s) to set
--- @param set_current? boolean Whether to set as current buffer (default: true)
--- @return number buf Buffer handle
function M.create_task_buffer(lines, set_current)
  local buf = vim.api.nvim_create_buf(false, true)

  local line_table = type(lines) == "string" and { lines } or lines
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, line_table)

  if set_current ~= false then
    vim.api.nvim_set_current_buf(buf)
  end

  return buf
end

--- Create task buffer with specific indentation
--- @param task string Task text (without checkbox)
--- @param indent number Number of spaces to indent
--- @return number buf Buffer handle
function M.create_indented_task_buffer(task, indent)
  local indent_str = string.rep(" ", indent)
  local line = indent_str .. "- [ ] " .. task
  return M.create_task_buffer(line)
end

--- Assert line contains valid GTD context
--- @param line string Line to check
--- @param expected_context? string Expected context (optional)
function M.assert_has_context(line, expected_context)
  local context = line:match("@(%w+)")

  assert.is_not_nil(context, "Line should contain @context tag")

  if expected_context then
    assert.equals(expected_context, context, "Context should match expected value")
  else
    -- Validate it's a known GTD context
    local valid = { home = true, work = true, computer = true, phone = true, errands = true }
    assert.is_true(valid[context], "Context '" .. context .. "' should be valid GTD context")
  end
end

--- Assert line contains valid GTD priority
--- @param line string Line to check
--- @param expected_priority? string Expected priority (optional: HIGH, MEDIUM, LOW)
function M.assert_has_priority(line, expected_priority)
  local priority = line:match("!(HIGH|MEDIUM|LOW)")

  assert.is_not_nil(priority, "Line should contain priority tag (!HIGH, !MEDIUM, or !LOW)")

  if expected_priority then
    assert.equals(expected_priority, priority, "Priority should match expected value")
  end
end

--- Assert buffer contains subtasks at correct indentation
--- @param buf number Buffer handle
--- @param parent_indent number Parent task indentation level (spaces)
--- @param min_subtasks? number Minimum expected subtasks (default: 1)
function M.assert_has_subtasks(buf, parent_indent, min_subtasks)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local expected_indent = string.rep(" ", parent_indent + 2)

  local subtask_count = 0
  for i = 2, #lines do
    if lines[i]:match("^" .. expected_indent .. "%- %[ %]") then
      subtask_count = subtask_count + 1
    end
  end

  local min = min_subtasks or 1
  assert.is_true(subtask_count >= min, string.format("Should have at least %d subtasks, found %d", min, subtask_count))
end

--- Add a test item to inbox.md
--- Useful for testing clarify workflow with pre-populated inbox
--- @param text string The text to add to inbox
function M.add_inbox_item(text)
  local inbox_path = M.gtd_path("inbox.md")
  local timestamp = os.date("%Y-%m-%d %H:%M")
  local formatted = string.format("- [ ] %s (captured: %s)", text, timestamp)

  -- Read existing content
  local content = {}
  if M.file_exists(inbox_path) then
    content = vim.fn.readfile(inbox_path)
  end

  -- Append new item
  table.insert(content, formatted)

  -- Write back to file
  vim.fn.writefile(content, inbox_path)
end

return M
