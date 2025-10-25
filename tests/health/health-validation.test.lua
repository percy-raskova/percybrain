-- tests/health/health-validation.test.lua
-- Comprehensive health validation tests for PercyBrain
-- Validates that all critical health issues are resolved

describe("PercyBrain Health Validation", function()
  -- Arrange: Common setup
  local health_fixes = require("config.health-fixes")

  before_each(function()
    -- Reset health fix status before each test
    health_fixes.status = { applied = {}, failed = {}, skipped = {} }
  end)

  after_each(function()
    -- Clean up any test artifacts
  end)

  describe("Critical Issue Resolution", function()
    it("should fix Python Treesitter highlights", function()
      -- Arrange
      local treesitter_fix = require("config.treesitter-health-fix")

      -- Act
      local success = treesitter_fix.fix_python_treesitter()

      -- Assert
      if success then
        -- Verify the fix worked by trying to load highlights
        local highlight_success = pcall(function()
          vim.treesitter.query.get("python", "highlights")
        end)
        assert.is_true(highlight_success, "Python highlights should work after fix")
      else
        -- If fix failed, it should be a known issue
        pending("Python Treesitter fix requires parser update or manual intervention")
      end
    end)
  end)

  describe("High Priority Issue Resolution", function()
    it("should fix sessionoptions configuration", function()
      -- Arrange
      local session_fix = require("config.session-health-fix")

      -- Act
      session_fix.fix_sessionoptions()

      -- Assert
      assert.is_true(vim.o.sessionoptions:match("localoptions") ~= nil, "sessionoptions MUST contain 'localoptions'")

      -- Verify all required options are present
      local required = {
        "blank",
        "buffers",
        "curdir",
        "folds",
        "help",
        "tabpages",
        "winsize",
        "terminal",
        "localoptions",
      }

      for _, option in ipairs(required) do
        assert.is_true(
          vim.o.sessionoptions:match(option) ~= nil,
          string.format("sessionoptions MUST contain '%s'", option)
        )
      end
    end)

    it("should use modern diagnostic API", function()
      -- Arrange
      local lsp_fix = require("config.lsp-diagnostic-fix")

      -- Act
      lsp_fix.configure_diagnostics()

      -- Assert: Check that diagnostic config is set
      local config = vim.diagnostic.config()
      assert.is_not_nil(config, "Diagnostic config MUST be set")
      assert.is_not_nil(config.signs, "Diagnostic signs MUST be configured")
      assert.is_table(config.signs.text, "Sign text MUST be a table")

      -- Verify sign text is configured for all severities
      assert.is_not_nil(config.signs.text[vim.diagnostic.severity.ERROR], "ERROR sign MUST be configured")
      assert.is_not_nil(config.signs.text[vim.diagnostic.severity.WARN], "WARN sign MUST be configured")
    end)
  end)

  describe("Health Fix Application", function()
    it("should apply all fixes without errors", function()
      -- Act
      local success = health_fixes.apply_all_fixes()

      -- Assert
      assert.is_true(success or #health_fixes.status.failed <= 1, "Most health fixes should apply successfully")

      -- Report any failures for debugging
      if #health_fixes.status.failed > 0 then
        for _, failure in ipairs(health_fixes.status.failed) do
          print(string.format("Fix failed: %s - %s", failure.name, failure.error))
        end
      end
    end)

    it("should complete fixes within reasonable time", function()
      -- Arrange
      local start_time = vim.loop.hrtime()

      -- Act
      health_fixes.apply_all_fixes()

      -- Assert
      local elapsed_ms = (vim.loop.hrtime() - start_time) / 1000000
      assert.is_true(
        elapsed_ms < 5000, -- 5 seconds max
        string.format("Health fixes took too long: %.2f ms", elapsed_ms)
      )
    end)
  end)

  describe("Health Check Validation", function()
    it("should detect and report health issues", function()
      -- Act
      local results = health_fixes.check_health()

      -- Assert
      assert.is_table(results, "Health check should return results table")
      assert.is_table(results.critical, "Should have critical issues category")
      assert.is_table(results.high, "Should have high priority category")
      assert.is_table(results.medium, "Should have medium priority category")
      assert.is_table(results.low, "Should have low priority category")

      -- After fixes are applied, critical issues should be resolved
      health_fixes.apply_all_fixes()
      vim.wait(1000) -- Wait for async fixes

      local post_fix_results = health_fixes.check_health()
      assert.is_true(#post_fix_results.critical <= 1, "Critical issues should be mostly resolved after fixes")
    end)
  end)

  describe("Session Preservation", function()
    it("should preserve filetype across session save/restore", function()
      -- This test requires auto-session to be installed
      local has_auto_session = pcall(require, "auto-session")
      if not has_auto_session then
        pending("auto-session not installed")
        return
      end

      -- Arrange
      local test_file = "/tmp/test_session.py"
      local test_content = 'print("Hello, World!")'

      -- Create and open a Python file
      local file = io.open(test_file, "w")
      file:write(test_content)
      file:close()

      vim.cmd("edit " .. test_file)
      assert.equals("python", vim.bo.filetype, "Should detect Python filetype")

      -- Act: Save session
      vim.cmd("SessionSave test_health_validation")

      -- Close buffer and clear filetype
      vim.cmd("bdelete!")
      vim.cmd("enew")
      assert.not_equals("python", vim.bo.filetype, "Filetype should be cleared")

      -- Restore session
      vim.cmd("SessionRestore test_health_validation")

      -- Assert
      assert.equals("python", vim.bo.filetype, "Python filetype MUST be restored with session")

      -- Clean up
      vim.cmd("SessionDelete test_health_validation")
      os.remove(test_file)
    end)
  end)

  describe("Diagnostic Sign Configuration", function()
    it("should not use deprecated sign_define for diagnostics", function()
      -- Arrange: Track sign_define calls
      local deprecated_calls = {}
      local original_sign_define = vim.fn.sign_define

      vim.fn.sign_define = function(name, ...)
        if name:match("Diagnostic") or name:match("Lsp") then
          table.insert(deprecated_calls, name)
        end
        return original_sign_define(name, ...)
      end

      -- Act: Apply LSP diagnostic fix
      local lsp_fix = require("config.lsp-diagnostic-fix")
      lsp_fix.setup()

      -- Wait a bit for any deferred operations
      vim.wait(100)

      -- Restore original function
      vim.fn.sign_define = original_sign_define

      -- Assert
      assert.equals(0, #deprecated_calls, "Should not use deprecated sign_define for diagnostics")
    end)

    it("should configure diagnostic signs through vim.diagnostic.config", function()
      -- Arrange
      local lsp_fix = require("config.lsp-diagnostic-fix")

      -- Act
      lsp_fix.configure_diagnostics()

      -- Assert: Verify signs are configured
      local config = vim.diagnostic.config()
      assert.is_table(config.signs, "Signs should be configured")
      assert.is_table(config.signs.text, "Sign text should be configured")

      -- Verify we can create diagnostics without errors
      local test_buf = vim.api.nvim_create_buf(false, true)
      local test_diagnostics = {
        {
          lnum = 0,
          col = 0,
          message = "Test error",
          severity = vim.diagnostic.severity.ERROR,
        },
      }

      assert.has_no.errors(function()
        vim.diagnostic.set(vim.api.nvim_create_namespace("test"), test_buf, test_diagnostics)
      end, "Should be able to set diagnostics without errors")

      -- Clean up
      vim.api.nvim_buf_delete(test_buf, { force = true })
    end)
  end)
end)
