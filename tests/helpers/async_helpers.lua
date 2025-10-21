-- Async Operation Helpers for Integration Testing
-- Kent Beck: "Don't let async operations make your tests flaky"

local M = {}

-- Wait for a condition to become true with timeout
-- Returns: success (boolean), error_message (string or nil)
function M.wait_for(condition_fn, timeout_ms, poll_interval_ms)
  timeout_ms = timeout_ms or 5000
  poll_interval_ms = poll_interval_ms or 100

  local elapsed = 0
  local last_error = nil

  while elapsed < timeout_ms do
    -- Try the condition
    local success, result = pcall(condition_fn)

    if success and result then
      return true
    end

    if not success then
      last_error = result
    end

    -- Wait and try again
    vim.wait(poll_interval_ms)
    elapsed = elapsed + poll_interval_ms
  end

  return false, last_error or ("Timeout after " .. timeout_ms .. "ms")
end

-- Wait for a file to exist
function M.wait_for_file(file_path, timeout_ms)
  return M.wait_for(function()
    return vim.fn.filereadable(file_path) == 1
  end, timeout_ms)
end

-- Wait for buffer to have specific content
function M.wait_for_buffer_content(buf, pattern, timeout_ms)
  return M.wait_for(function()
    if not vim.api.nvim_buf_is_valid(buf) then
      return false
    end

    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local content = table.concat(lines, "\n")
    return content:match(pattern) ~= nil
  end, timeout_ms)
end

-- Wait for a notification to appear
function M.wait_for_notification(pattern, timeout_ms)
  local notifications = {}

  -- Temporarily capture notifications
  local original_notify = vim.notify
  vim.notify = function(msg, level, opts)
    table.insert(notifications, msg)
    -- Still call original to maintain normal behavior
    if original_notify then
      original_notify(msg, level, opts)
    end
  end

  local success = M.wait_for(function()
    for _, msg in ipairs(notifications) do
      if msg:match(pattern) then
        return true
      end
    end
    return false
  end, timeout_ms)

  -- Restore original notify
  vim.notify = original_notify

  return success, notifications
end

-- Execute function with timeout protection
function M.with_timeout(fn, timeout_ms)
  timeout_ms = timeout_ms or 5000

  local completed = false
  local result = nil
  local error_msg = nil

  -- Run function in protected call
  local co = coroutine.create(function()
    local success, res = pcall(fn)
    if success then
      result = res
    else
      error_msg = res
    end
    completed = true
  end)

  -- Start execution
  coroutine.resume(co)

  -- Wait for completion or timeout
  local success = M.wait_for(function()
    return completed
  end, timeout_ms, 10)

  if not success then
    return false, "Function timeout after " .. timeout_ms .. "ms"
  end

  if error_msg then
    return false, error_msg
  end

  return true, result
end

-- Retry a function multiple times with exponential backoff
function M.retry_with_backoff(fn, max_attempts, initial_delay_ms)
  max_attempts = max_attempts or 3
  initial_delay_ms = initial_delay_ms or 100

  local delay = initial_delay_ms

  for attempt = 1, max_attempts do
    local success, result = pcall(fn)

    if success then
      return true, result
    end

    if attempt < max_attempts then
      vim.wait(delay)
      delay = delay * 2 -- Exponential backoff
    else
      return false, result -- Return last error
    end
  end
end

-- Wait for async pipeline to complete processing
function M.wait_for_pipeline_completion(pipeline, timeout_ms)
  return M.wait_for(function()
    local status = pipeline.get_processing_status()
    return status.state == "completed" or status.state == "error"
  end, timeout_ms)
end

-- Wait for AI processing to complete
function M.wait_for_ai_response(timeout_ms)
  timeout_ms = timeout_ms or 3000

  -- This would hook into your actual AI processing
  -- For now, simulate waiting for a mock response
  return M.wait_for(function()
    -- Check if AI processing is done
    -- This would check actual AI state in real implementation
    return true
  end, timeout_ms)
end

-- Create a deferred assertion that waits for condition
function M.assert_eventually(condition_fn, timeout_ms, message)
  local success, error_msg = M.wait_for(condition_fn, timeout_ms)

  if not success then
    error(message or ("Assertion failed: " .. (error_msg or "timeout")))
  end

  return true
end

-- Monitor a value over time and collect samples
function M.monitor_value(value_fn, duration_ms, sample_interval_ms)
  duration_ms = duration_ms or 1000
  sample_interval_ms = sample_interval_ms or 100

  local samples = {}
  local elapsed = 0

  while elapsed < duration_ms do
    local success, value = pcall(value_fn)
    if success then
      table.insert(samples, {
        time = elapsed,
        value = value,
      })
    end

    vim.wait(sample_interval_ms)
    elapsed = elapsed + sample_interval_ms
  end

  return samples
end

-- Ensure async cleanup happens
function M.async_cleanup(cleanup_fn, timeout_ms)
  timeout_ms = timeout_ms or 1000

  local success, error_msg = M.with_timeout(cleanup_fn, timeout_ms)

  if not success then
    -- Log but don't fail test on cleanup issues
    print("Warning: Cleanup failed - " .. (error_msg or "unknown error"))
  end
end

return M
