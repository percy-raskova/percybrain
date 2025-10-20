-- lua/config/health-fixes.lua
-- Master health fix module that applies all checkhealth fixes
-- Part of TDD implementation for PercyBrain health issues

local M = {}

-- Load all health fix modules
local fixes = {
  treesitter = require("config.treesitter-health-fix"),
  session = require("config.session-health-fix"),
  lsp_diagnostic = require("config.lsp-diagnostic-fix"),
}

-- Track fix status
M.status = {
  applied = {},
  failed = {},
  skipped = {},
}

-- Apply a single fix module
local function apply_fix(name, module)
  if not module or not module.setup then
    table.insert(M.status.skipped, name)
    return false
  end

  local success, result = pcall(module.setup)
  if success then
    table.insert(M.status.applied, name)
    return true
  else
    table.insert(M.status.failed, {
      name = name,
      error = tostring(result),
    })
    return false
  end
end

-- Apply all health fixes
function M.apply_all_fixes()
  local start_time = vim.loop.hrtime()

  -- Apply fixes in priority order
  local fix_order = {
    "session", -- Fix sessionoptions first (HIGH priority)
    "lsp_diagnostic", -- Fix deprecated diagnostic API (HIGH priority)
    "treesitter", -- Fix Python parser (CRITICAL but may take longer)
  }

  for _, name in ipairs(fix_order) do
    if fixes[name] then
      apply_fix(name, fixes[name])
    end
  end

  local elapsed_ms = (vim.loop.hrtime() - start_time) / 1000000

  -- Report results
  M.report_status(elapsed_ms)

  return #M.status.failed == 0
end

-- Generate status report
function M.report_status(elapsed_ms)
  local report_lines = {
    "══════════════════════════════════════",
    " PercyBrain Health Fixes Applied",
    "══════════════════════════════════════",
    "",
  }

  if #M.status.applied > 0 then
    table.insert(report_lines, "✅ Successfully Applied:")
    for _, name in ipairs(M.status.applied) do
      table.insert(report_lines, "   • " .. name)
    end
    table.insert(report_lines, "")
  end

  if #M.status.failed > 0 then
    table.insert(report_lines, "❌ Failed to Apply:")
    for _, failure in ipairs(M.status.failed) do
      table.insert(report_lines, "   • " .. failure.name .. ": " .. failure.error)
    end
    table.insert(report_lines, "")
  end

  if #M.status.skipped > 0 then
    table.insert(report_lines, "⏭️  Skipped:")
    for _, name in ipairs(M.status.skipped) do
      table.insert(report_lines, "   • " .. name)
    end
    table.insert(report_lines, "")
  end

  table.insert(report_lines, string.format("⏱️  Completed in %.2f ms", elapsed_ms))
  table.insert(
    report_lines,
    "══════════════════════════════════════"
  )

  -- Show notification
  local level = #M.status.failed > 0 and vim.log.levels.WARN or vim.log.levels.INFO
  vim.notify(table.concat(report_lines, "\n"), level, { title = "Health Fixes" })

  -- Also log to file for debugging
  M.log_to_file(report_lines)
end

-- Log status to file for debugging
function M.log_to_file(lines)
  local log_dir = vim.fn.stdpath("state") .. "/percybrain"
  vim.fn.mkdir(log_dir, "p")

  local log_file = log_dir .. "/health-fixes.log"
  local timestamp = os.date("%Y-%m-%d %H:%M:%S")

  -- Prepend timestamp
  table.insert(lines, 1, "Timestamp: " .. timestamp)

  -- Append to log file
  local file = io.open(log_file, "a")
  if file then
    file:write(table.concat(lines, "\n") .. "\n\n")
    file:close()
  end
end

-- Run health check and return results
function M.check_health()
  local health_results = {
    critical = {},
    high = {},
    medium = {},
    low = {},
  }

  -- Check Python Treesitter
  local success, _ = pcall(function()
    vim.treesitter.query.get("python", "highlights")
  end)
  if not success then
    table.insert(health_results.critical, "Python Treesitter highlights error")
  end

  -- Check sessionoptions
  if not vim.o.sessionoptions:match("localoptions") then
    table.insert(health_results.high, "Missing 'localoptions' in sessionoptions")
  end

  -- Check for deprecated diagnostic signs (harder to detect programmatically)
  -- This would require checking all loaded plugins

  return health_results
end

-- Setup function to be called from init.lua
function M.setup()
  -- Apply fixes asynchronously to not block startup
  vim.defer_fn(function()
    M.apply_all_fixes()
  end, 200)

  -- Create user command for manual health fix
  vim.api.nvim_create_user_command("PercyBrainHealthFix", function()
    M.status = { applied = {}, failed = {}, skipped = {} } -- Reset status
    M.apply_all_fixes()
  end, { desc = "Apply PercyBrain health fixes" })

  -- Create user command for health check
  vim.api.nvim_create_user_command("PercyBrainHealthCheck", function()
    local results = M.check_health()
    local report = { "PercyBrain Health Check Results:", "" }

    for level, issues in pairs(results) do
      if #issues > 0 then
        table.insert(report, string.format("%s Priority:", level:upper()))
        for _, issue in ipairs(issues) do
          table.insert(report, "  • " .. issue)
        end
        table.insert(report, "")
      end
    end

    vim.notify(table.concat(report, "\n"), vim.log.levels.INFO, { title = "Health Check" })
  end, { desc = "Run PercyBrain health check" })
end

return M
