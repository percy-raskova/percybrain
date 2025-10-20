-- PercyBrain Test Framework Helpers
-- Kent Beck: "Make tests so clear that they serve as documentation"

local M = {}

-- ============================================================================
-- TEST ISOLATION HELPERS
-- ============================================================================

-- Save and restore Vim state for test isolation
M.StateManager = {}
M.StateManager.__index = M.StateManager

function M.StateManager:new()
  local instance = {
    saved_opts = {},
    saved_vars = {},
    saved_keymaps = {},
    saved_autocmds = {},
  }
  setmetatable(instance, M.StateManager)
  return instance
end

-- Save current Vim state
function M.StateManager:save()
  -- Save options we care about
  local options_to_save = {
    "spell",
    "spelllang",
    "wrap",
    "linebreak",
    "hlsearch",
    "cursorline",
    "number",
    "relativenumber",
    "expandtab",
    "shiftwidth",
    "tabstop",
    "softtabstop",
  }

  for _, opt in ipairs(options_to_save) do
    self.saved_opts[opt] = vim.opt[opt]:get()
  end

  -- Save global variables
  self.saved_vars = vim.deepcopy(vim.g)

  -- Save keymaps
  for _, mode in ipairs({ "n", "i", "v", "x" }) do
    self.saved_keymaps[mode] = vim.api.nvim_get_keymap(mode)
  end

  return self
end

-- Restore saved Vim state
function M.StateManager:restore()
  -- Restore options
  for opt, value in pairs(self.saved_opts) do
    vim.opt[opt] = value
  end

  -- Restore global variables
  for key, value in pairs(self.saved_vars) do
    vim.g[key] = value
  end

  -- Clear and restore keymaps would be more complex
  -- For now, we just ensure critical ones are preserved

  return self
end

-- Create isolated test environment
function M.StateManager:isolate()
  -- Clear all user configuration
  vim.cmd("silent! mapclear")
  vim.cmd("silent! mapclear!")

  -- Reset to minimal defaults
  vim.opt.spell = false
  vim.opt.wrap = false
  vim.opt.hlsearch = false
  vim.opt.swapfile = false
  vim.opt.backup = false
  vim.opt.undofile = false

  return self
end

-- ============================================================================
-- CAPABILITY TESTING HELPERS
-- ============================================================================

M.Capability = {}
M.Capability.__index = M.Capability

function M.Capability:new(name)
  local instance = {
    name = name,
    tests = {},
    results = {},
  }
  setmetatable(instance, M.Capability)
  return instance
end

-- Test that a user can perform an action
function M.Capability:can(action, test_fn)
  table.insert(self.tests, {
    action = action,
    test = test_fn,
    type = "can",
  })
  return self
end

-- Test that a feature works correctly
function M.Capability:works(feature, test_fn)
  table.insert(self.tests, {
    feature = feature,
    test = test_fn,
    type = "works",
  })
  return self
end

-- Test that a behavior is preserved
function M.Capability:preserves(behavior, test_fn)
  table.insert(self.tests, {
    behavior = behavior,
    test = test_fn,
    type = "preserves",
  })
  return self
end

-- Run all capability tests
function M.Capability:run()
  for _, test_spec in ipairs(self.tests) do
    local success, result = pcall(test_spec.test)

    local test_name = test_spec.type .. ": " .. (test_spec.action or test_spec.feature or test_spec.behavior)

    self.results[test_name] = {
      success = success,
      result = result,
      type = test_spec.type,
    }
  end

  return self.results
end

-- ============================================================================
-- REGRESSION TESTING HELPERS
-- ============================================================================

M.Regression = {}
M.Regression.__index = M.Regression

function M.Regression:new(name)
  local instance = {
    name = name,
    protections = {},
  }
  setmetatable(instance, M.Regression)
  return instance
end

-- Protect a critical setting
function M.Regression:protect_setting(setting, expected_value, reason)
  table.insert(self.protections, {
    type = "setting",
    setting = setting,
    expected = expected_value,
    reason = reason,
  })
  return self
end

-- Protect a critical behavior
function M.Regression:protect_behavior(behavior, test_fn, reason)
  table.insert(self.protections, {
    type = "behavior",
    behavior = behavior,
    test = test_fn,
    reason = reason,
  })
  return self
end

-- Validate all protections
function M.Regression:validate()
  local violations = {}

  for _, protection in ipairs(self.protections) do
    if protection.type == "setting" then
      local actual = vim.opt[protection.setting]:get()
      if actual ~= protection.expected then
        table.insert(violations, {
          type = "setting",
          message = string.format(
            "Setting '%s' was changed to %s (expected %s). Reason: %s",
            protection.setting,
            vim.inspect(actual),
            vim.inspect(protection.expected),
            protection.reason
          ),
        })
      end
    elseif protection.type == "behavior" then
      local success, result = pcall(protection.test)
      if not success or not result then
        table.insert(violations, {
          type = "behavior",
          message = string.format("Behavior '%s' was broken. Reason: %s", protection.behavior, protection.reason),
        })
      end
    end
  end

  return violations
end

-- ============================================================================
-- CONTRACT TESTING HELPERS
-- ============================================================================

M.Contract = {}
M.Contract.__index = M.Contract

function M.Contract:new(spec_path)
  local instance = {
    spec = nil,
    results = {
      required = { passed = {}, failed = {} },
      forbidden = { violations = {} },
      optional = { available = {}, unavailable = {} },
    },
  }
  setmetatable(instance, M.Contract)

  -- Load contract specification
  if spec_path then
    instance.spec = dofile(spec_path)
  end

  return instance
end

-- Validate required contract elements
function M.Contract:validate_required()
  if not self.spec or not self.spec.REQUIRED then
    return self
  end

  local results = self.spec.validate_required()
  self.results.required = results
  return self
end

-- Validate forbidden elements aren't present
function M.Contract:validate_forbidden()
  if not self.spec or not self.spec.FORBIDDEN then
    return self
  end

  local violations = self.spec.validate_forbidden()
  self.results.forbidden.violations = violations
  return self
end

-- Check optional features
function M.Contract:check_optional()
  if not self.spec or not self.spec.OPTIONAL then
    return self
  end

  -- Check which optional features are available
  -- This would be implemented based on the specific optional features

  return self
end

-- Get validation report
function M.Contract:report()
  local report = {
    summary = {
      required_passed = #self.results.required.passed,
      required_failed = #self.results.required.failed,
      forbidden_violations = #self.results.forbidden.violations,
    },
    details = self.results,
  }

  return report
end

-- ============================================================================
-- ASSERTION HELPERS
-- ============================================================================

-- Assert a capability is available
function M.assert_can(action, test_fn, message)
  local success, result = pcall(test_fn)
  if not success or not result then
    error(message or ("Cannot " .. action))
  end
  return true
end

-- Assert a feature works
function M.assert_works(feature, test_fn, message)
  local success, result = pcall(test_fn)
  if not success or not result then
    error(message or (feature .. " doesn't work"))
  end
  return true
end

-- Assert a protection is maintained
function M.assert_protected(setting, expected, actual, reason)
  if actual ~= expected then
    error(
      string.format(
        "Protection violated: %s changed to %s (expected %s). %s",
        setting,
        vim.inspect(actual),
        vim.inspect(expected),
        reason or ""
      )
    )
  end
  return true
end

-- ============================================================================
-- TEST EXECUTION HELPERS
-- ============================================================================

-- Run tests with proper isolation
function M.run_isolated(test_fn)
  local state = M.StateManager:new()
  state:save()

  local success, result = pcall(function()
    state:isolate()
    return test_fn()
  end)

  state:restore()

  if not success then
    error(result)
  end

  return result
end

-- Run tests with timing
function M.run_timed(test_fn, max_ms)
  local start = vim.loop.hrtime()
  local result = test_fn()
  local elapsed = (vim.loop.hrtime() - start) / 1000000 -- Convert to ms

  if max_ms and elapsed > max_ms then
    error(string.format("Test took %.2fms (max: %dms)", elapsed, max_ms))
  end

  return result, elapsed
end

-- Run tests with retry for flaky operations
function M.run_with_retry(test_fn, retries)
  retries = retries or 3
  local last_error

  for i = 1, retries do
    local success, result = pcall(test_fn)
    if success then
      return result
    end
    last_error = result
    if i < retries then
      vim.wait(100 * i) -- Exponential backoff
    end
  end

  error("Test failed after " .. retries .. " retries: " .. last_error)
end

-- ============================================================================
-- TEST ORGANIZATION HELPERS
-- ============================================================================

-- Create a test suite with consistent structure
function M.suite(name, setup_fn)
  return {
    name = name,
    setup = setup_fn,
    tests = {},

    add_test = function(self, test_name, test_fn)
      table.insert(self.tests, {
        name = test_name,
        test = test_fn,
      })
      return self
    end,

    run = function(self)
      if self.setup then
        self.setup()
      end

      local results = {}
      for _, test in ipairs(self.tests) do
        local success, result = pcall(test.test)
        results[test.name] = {
          success = success,
          result = result,
        }
      end

      return results
    end,
  }
end

-- ============================================================================
-- STARTUP TESTING HELPERS
-- ============================================================================

-- Validate Neovim startup behavior and configuration health
M.Startup = {}
M.Startup.__index = M.Startup

function M.Startup:new()
  local instance = {
    warnings = {},
    errors = {},
    deprecations = {},
  }
  setmetatable(instance, M.Startup)
  return instance
end

-- Capture startup messages
function M.Startup:capture_messages()
  -- Run Neovim headless and capture output
  local handle = io.popen("nvim --headless -c 'messages' -c 'qa!' 2>&1")
  if not handle then
    return {}
  end

  local output = handle:read("*all")
  handle:close()

  local messages = {}
  for line in output:gmatch("[^\r\n]+") do
    table.insert(messages, line)
  end

  return messages
end

-- Check for deprecation warnings
function M.Startup:has_deprecations()
  local messages = self:capture_messages()
  for _, msg in ipairs(messages) do
    if msg:match("[Dd]eprecated") then
      table.insert(self.deprecations, msg)
    end
  end
  return #self.deprecations > 0
end

-- Check for errors
function M.Startup:has_errors()
  local messages = self:capture_messages()
  for _, msg in ipairs(messages) do
    if msg:match("[Ee]rror") or msg:match("failed") then
      table.insert(self.errors, msg)
    end
  end
  return #self.errors > 0
end

-- Validate clean startup
function M.Startup:is_clean()
  return not self:has_deprecations() and not self:has_errors()
end

return M
