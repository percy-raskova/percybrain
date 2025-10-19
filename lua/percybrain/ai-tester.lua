-- PercyBrain AI Testing Module
-- Proof-of-concept for AI-driven environment validation

local M = {}

-- Test results storage
M.results = {
  passed = {},
  failed = {},
  warnings = {},
  discoveries = {},
}

-- Test 1: Basic connectivity
function M.test_connection()
  local ok, result = pcall(vim.api.nvim_eval, "v:version")
  if ok then
    table.insert(M.results.passed, "✅ Connection: Neovim " .. tostring(result))
    return true
  else
    table.insert(M.results.failed, "❌ Connection: Failed")
    return false
  end
end

-- Test 2: Navigation capabilities
function M.test_navigation()
  local start_line = vim.fn.line(".")
  vim.cmd("normal gg")
  local after_gg = vim.fn.line(".")
  vim.cmd("normal G")
  local after_G = vim.fn.line(".")
  vim.cmd("normal " .. start_line .. "G")

  if after_gg == 1 and after_G == vim.fn.line("$") then
    table.insert(M.results.passed, "✅ Navigation: gg/G commands work")
    return true
  else
    table.insert(M.results.failed, "❌ Navigation: Movement commands failed")
    return false
  end
end

-- Test 3: Plugin detection
function M.test_plugins()
  local plugins_found = {}

  -- Check for key plugins
  local plugin_checks = {
    ["telescope"] = "Telescope",
    ["which-key"] = "WhichKey",
    ["nvim-tree"] = "NvimTree",
    ["lazy"] = "Lazy",
    ["treesitter"] = "TSInstall",
  }

  for name, command in pairs(plugin_checks) do
    if vim.fn.exists(":" .. command) > 0 then
      table.insert(plugins_found, name)
    end
  end

  if #plugins_found > 0 then
    table.insert(M.results.passed, "✅ Plugins: Found " .. table.concat(plugins_found, ", "))
    return true
  else
    table.insert(M.results.failed, "❌ Plugins: No plugins detected")
    return false
  end
end

-- Test 4: Keybinding availability
function M.test_keybindings()
  local leader = vim.g.mapleader or "\\"
  local keymaps = vim.api.nvim_get_keymap("n")
  local leader_maps = 0

  for _, map in ipairs(keymaps) do
    if map.lhs:match("^" .. vim.pesc(leader)) then
      leader_maps = leader_maps + 1
    end
  end

  if leader_maps > 0 then
    table.insert(M.results.passed, "✅ Keybindings: " .. leader_maps .. " leader mappings found")
    return true
  else
    table.insert(M.results.failed, "❌ Keybindings: No leader mappings found")
    return false
  end
end

-- Test 5: Security/Privacy checks
function M.test_security()
  local issues = {}

  -- Check for sensitive data in registers
  local sensitive_patterns = {
    "password",
    "secret",
    "token",
    "key",
    "api",
    "ssh",
  }

  for i = 0, 9 do
    local reg_content = vim.fn.getreg(tostring(i))
    if reg_content and reg_content ~= "" then
      for _, pattern in ipairs(sensitive_patterns) do
        if reg_content:lower():match(pattern) then
          table.insert(issues, "Register " .. i .. " may contain sensitive data")
          break
        end
      end
    end
  end

  if #issues == 0 then
    table.insert(M.results.passed, "✅ Security: No sensitive data in registers")
    return true
  else
    table.insert(M.results.warnings, "⚠️  Security: " .. table.concat(issues, ", "))
    return false
  end
end

-- Test 6: Interactive UI limitations (discovered!)
function M.test_ui_limitations()
  table.insert(
    M.results.discoveries,
    [[
🔍 DISCOVERY: Interactive UI Limitation
- WhichKey, Telescope, and other floating windows cannot be properly controlled via MCP
- These require user input that MCP cannot simulate
- Workaround: Test non-interactive alternatives or command-line equivalents
  ]]
  )

  -- List interactive commands to avoid
  local interactive_commands = {
    "WhichKey",
    "Telescope",
    "Lazy",
    ":help",
    "fzf",
  }

  table.insert(
    M.results.warnings,
    "⚠️  UI: Cannot test interactive commands: " .. table.concat(interactive_commands, ", ")
  )
  return true
end

-- Test 7: Performance baseline
function M.test_performance()
  local start_time = vim.loop.hrtime()

  -- Simple performance test
  for _ = 1, 100 do
    vim.cmd("normal j")
    vim.cmd("normal k")
  end

  local end_time = vim.loop.hrtime()
  local elapsed_ms = (end_time - start_time) / 1000000

  if elapsed_ms < 1000 then
    table.insert(M.results.passed, string.format("✅ Performance: 200 movements in %.2fms", elapsed_ms))
    return true
  else
    table.insert(M.results.warnings, string.format("⚠️  Performance: Slow - %.2fms for 200 movements", elapsed_ms))
    return false
  end
end

-- Test 8: Error detection capabilities
function M.test_error_detection()
  -- Try to trigger a safe error
  local ok = pcall(vim.cmd, "ThisCommandDoesNotExist")

  if not ok then
    table.insert(M.results.passed, "✅ Error Detection: Can capture and handle errors")
    return true
  else
    table.insert(M.results.failed, "❌ Error Detection: Failed to catch obvious error")
    return false
  end
end

-- Run all tests
function M.run_all_tests()
  M.results = {
    passed = {},
    failed = {},
    warnings = {},
    discoveries = {},
  }

  vim.notify("🤖 AI Testing Protocol Starting...", vim.log.levels.INFO)

  local tests = {
    { "Connection", M.test_connection },
    { "Navigation", M.test_navigation },
    { "Plugins", M.test_plugins },
    { "Keybindings", M.test_keybindings },
    { "Security", M.test_security },
    { "UI Limitations", M.test_ui_limitations },
    { "Performance", M.test_performance },
    { "Error Detection", M.test_error_detection },
  }

  for _, test in ipairs(tests) do
    local name, func = test[1], test[2]
    local ok, result = pcall(func)
    if not ok then
      table.insert(M.results.failed, "❌ " .. name .. ": Test crashed - " .. tostring(result))
    end
  end

  return M.generate_report()
end

-- Generate test report
function M.generate_report()
  local report = {}

  table.insert(report, "# 🤖 AI Testing Report")
  table.insert(report, "Generated: " .. os.date("%Y-%m-%d %H:%M:%S"))
  table.insert(report, "")

  if #M.results.passed > 0 then
    table.insert(report, "## ✅ Passed Tests")
    for _, msg in ipairs(M.results.passed) do
      table.insert(report, msg)
    end
    table.insert(report, "")
  end

  if #M.results.warnings > 0 then
    table.insert(report, "## ⚠️  Warnings")
    for _, msg in ipairs(M.results.warnings) do
      table.insert(report, msg)
    end
    table.insert(report, "")
  end

  if #M.results.failed > 0 then
    table.insert(report, "## ❌ Failed Tests")
    for _, msg in ipairs(M.results.failed) do
      table.insert(report, msg)
    end
    table.insert(report, "")
  end

  if #M.results.discoveries > 0 then
    table.insert(report, "## 🔍 Discoveries")
    for _, msg in ipairs(M.results.discoveries) do
      table.insert(report, msg)
    end
    table.insert(report, "")
  end

  table.insert(report, "## Summary")
  table.insert(report, string.format("- Passed: %d", #M.results.passed))
  table.insert(report, string.format("- Warnings: %d", #M.results.warnings))
  table.insert(report, string.format("- Failed: %d", #M.results.failed))
  table.insert(report, string.format("- Discoveries: %d", #M.results.discoveries))

  return table.concat(report, "\n")
end

-- Create command for manual testing
vim.api.nvim_create_user_command("AITest", function()
  local report = M.run_all_tests()

  -- Create a new buffer with the report
  vim.cmd("new")
  vim.cmd("setlocal buftype=nofile bufhidden=wipe noswapfile")
  vim.cmd("file AI-Test-Report")

  local lines = vim.split(report, "\n")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)

  -- Make it read-only
  vim.cmd("setlocal readonly nomodifiable")

  -- Add keybinding to close
  vim.keymap.set("n", "q", ":close<CR>", { buffer = true, silent = true })
end, { desc = "Run AI testing suite" })

return M
