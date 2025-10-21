# PercyBrain Checkhealth TDD Analysis & Test Design

## Executive Summary

This document provides a Test-Driven Development (TDD) approach to resolving critical failures identified in PercyBrain's Neovim checkhealth output. Following Kent Beck's RED-GREEN-REFACTOR methodology, we design tests first to drive the implementation of fixes.

## Issue Severity Classification

### 🔴 CRITICAL (Breaks Core Functionality)

1. **nvim-treesitter Python highlights error** (Line 230)
   - Error: "Invalid node type 'except\*'" in Python parser
   - Impact: Python syntax highlighting completely broken
   - Root Cause: Python parser version mismatch with highlight queries

### 🟡 HIGH (Performance/Quality Degradation)

1. **auto-session localoptions warning** (Line 13)

   - Warning: sessionoptions missing 'localoptions'
   - Impact: Filetype/highlighting broken after session restore
   - Root Cause: Incomplete sessionoptions configuration

2. **vim.deprecated diagnostic signs** (Line 272)

   - Warning: Using deprecated :sign-define API
   - Impact: Will break in Neovim 0.12
   - Root Cause: LSP diagnostic configuration using old API

### 🟠 MEDIUM (Optional Features Affected)

1. **vim.lsp file watcher performance** (Line 544)

   - Warning: libuv-watchdirs performance issues
   - Impact: LSP performance degradation on large projects
   - Root Cause: Missing inotify-tools dependency

2. **vim.provider yarn error** (Line 559)

   - Error: Failed to run yarn info neovim
   - Impact: Node.js provider health check incomplete
   - Root Cause: Network connectivity or yarn configuration

### 🟢 LOW (Informational Warnings)

1. **which-key overlapping keymaps** (Lines 678-813)

   - 22 warnings about keymap overlaps
   - Impact: Potential keymap conflicts (currently working)
   - Root Cause: Hierarchical keymap design pattern

2. **Mason missing language tools** (Lines 102-116)

   - Missing: Composer, PHP, Julia
   - Impact: No support for these languages (not core to PercyBrain)
   - Root Cause: Not installed (acceptable for Zettelkasten focus)

______________________________________________________________________

## TDD Test Designs for Critical Issues

### 1. Python Treesitter Parser Health Tests

#### Contract Tests (What the System MUST Do)

```lua
-- tests/treesitter/python-parser-contract.test.lua

describe("Python Treesitter Parser Contract", function()
  -- Arrange
  local ts_utils = require("nvim-treesitter.ts_utils")
  local parser_config = require("nvim-treesitter.parsers").get_parser_configs()

  before_each(function()
    -- Act: Setup test environment
    vim.cmd("edit test_python.py")
  end)

  after_each(function()
    -- Clean up
    vim.cmd("bdelete!")
  end)

  it("MUST parse Python exception handling correctly", function()
    -- Arrange
    local test_code = [[
try:
    dangerous_operation()
except ValueError as e:
    handle_error(e)
except* ExceptionGroup as eg:
    handle_exception_group(eg)
    ]]

    -- Act
    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(test_code, "\n"))
    local parser = vim.treesitter.get_parser(0, "python")
    local tree = parser:parse()[1]

    -- Assert
    assert.is_not_nil(tree, "Parser MUST return valid syntax tree")
    assert.is_nil(tree:root():has_error(), "Parser MUST NOT have syntax errors")
  end)

  it("MUST NOT break on Python 3.11+ syntax", function()
    -- Arrange
    local modern_syntax = [[
match value:
    case pattern if guard:
        action()
    case _:
        default()
    ]]

    -- Act
    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(modern_syntax, "\n"))
    local success, parser = pcall(vim.treesitter.get_parser, 0, "python")

    -- Assert
    assert.is_true(success, "Parser MUST handle modern Python syntax")
  end)

  it("MUST provide working highlights for Python code", function()
    -- Arrange
    local code = "def function(): pass"
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {code})

    -- Act
    local highlights = vim.treesitter.highlighter.active[0]

    -- Assert
    assert.is_not_nil(highlights, "Highlighter MUST be active for Python")
    assert.has_no.errors(function()
      vim.treesitter.query.get("python", "highlights")
    end, "Highlight queries MUST load without errors")
  end)
end)
```

#### Capability Tests (What Users CAN Do)

```lua
-- tests/treesitter/python-capabilities.test.lua

describe("Python Development Capabilities", function()
  it("users CAN write Python with exception groups", function()
    -- Arrange
    local exception_group_code = [[
def process_batch(items):
    errors = []
    for item in items:
        try:
            process(item)
        except* ValueError as eg:
            errors.extend(eg.exceptions)
    return errors
    ]]

    -- Act
    vim.cmd("edit test_exceptions.py")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(exception_group_code, "\n"))

    -- Assert: No errors should be thrown
    assert.has_no.errors(function()
      vim.cmd("write! /tmp/test_exceptions.py")
      vim.cmd("TSHighlightCapturesUnderCursor")
    end)

    -- Clean up
    vim.cmd("bdelete!")
    os.remove("/tmp/test_exceptions.py")
  end)

  it("users CAN see Python syntax errors", function()
    -- Arrange
    local invalid_code = "def function( return"

    -- Act
    vim.cmd("edit test_error.py")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {invalid_code})
    local parser = vim.treesitter.get_parser(0, "python")
    local tree = parser:parse()[1]

    -- Assert
    assert.is_true(tree:root():has_error(), "Users CAN see syntax errors")

    -- Clean up
    vim.cmd("bdelete!")
  end)
end)
```

#### Health Check Validation Tests

```lua
-- tests/health/treesitter-health.test.lua

describe("Treesitter Health Validation", function()
  it("should detect Python parser health issues", function()
    -- Arrange
    local health_output = {}
    local original_report = vim.health.report_error
    vim.health.report_error = function(msg)
      table.insert(health_output, {type = "error", msg = msg})
    end

    -- Act
    require("nvim-treesitter.health").check()

    -- Assert
    local python_errors = vim.tbl_filter(function(item)
      return item.msg:match("python") and item.msg:match("except%*")
    end, health_output)

    if #python_errors > 0 then
      assert.is_true(#python_errors > 0, "Health check MUST detect Python parser issues")
    end

    -- Restore
    vim.health.report_error = original_report
  end)

  it("should validate parser-query compatibility", function()
    -- Arrange
    local parsers = require("nvim-treesitter.parsers")

    -- Act
    local python_parser = parsers.get_parser_configs().python
    local parser_version = python_parser.install_info.revision

    -- Assert
    assert.is_not_nil(parser_version, "Parser version MUST be detectable")

    -- Check if highlights query is compatible
    local success, query = pcall(vim.treesitter.query.get, "python", "highlights")
    if not success then
      assert.fail("Python highlights query incompatible with parser version")
    end
  end)
end)
```

### 2. Session Restoration Tests

#### Contract Tests

```lua
-- tests/session/auto-session-contract.test.lua

describe("Auto-session Contract", function()
  it("MUST preserve filetype after session restore", function()
    -- Arrange
    local test_file = "/tmp/test.py"
    local original_ft = nil

    -- Create Python file and save session
    vim.cmd("edit " .. test_file)
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {"print('test')"})
    original_ft = vim.bo.filetype
    vim.cmd("SessionSave test_session")
    vim.cmd("qall!")

    -- Act: Restore session
    vim.cmd("SessionRestore test_session")

    -- Assert
    assert.equals(original_ft, vim.bo.filetype,
      "Filetype MUST be preserved after session restore")
    assert.equals("python", vim.bo.filetype,
      "Python filetype MUST be correctly restored")

    -- Clean up
    vim.cmd("SessionDelete test_session")
    os.remove(test_file)
  end)

  it("MUST preserve highlight groups after restore", function()
    -- Arrange
    vim.cmd("edit /tmp/test.lua")
    vim.cmd("SessionSave highlight_test")
    local original_highlights = vim.api.nvim_exec2("highlight", {output = true}).output

    -- Act
    vim.cmd("qall!")
    vim.cmd("SessionRestore highlight_test")
    local restored_highlights = vim.api.nvim_exec2("highlight", {output = true}).output

    -- Assert
    assert.equals(#original_highlights, #restored_highlights,
      "Highlight groups MUST be preserved")

    -- Clean up
    vim.cmd("SessionDelete highlight_test")
  end)
end)
```

### 3. LSP Diagnostic Signs Tests

#### Contract Tests

```lua
-- tests/lsp/diagnostic-signs-contract.test.lua

describe("LSP Diagnostic Signs Contract", function()
  it("MUST use vim.diagnostic.config() API", function()
    -- Arrange
    local config = {
      virtual_text = true,
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = "✗",
          [vim.diagnostic.severity.WARN] = "⚠",
          [vim.diagnostic.severity.INFO] = "ℹ",
          [vim.diagnostic.severity.HINT] = "➤",
        }
      },
      underline = true,
      update_in_insert = false,
      severity_sort = true,
    }

    -- Act
    assert.has_no.errors(function()
      vim.diagnostic.config(config)
    end, "MUST use modern diagnostic.config API")

    -- Assert
    local actual_config = vim.diagnostic.config()
    assert.equals(config.virtual_text, actual_config.virtual_text)
    assert.is_not_nil(actual_config.signs)
  end)

  it("MUST NOT use deprecated sign_define()", function()
    -- Arrange
    local deprecated_calls = {}
    local original_sign_define = vim.fn.sign_define
    vim.fn.sign_define = function(...)
      table.insert(deprecated_calls, {...})
      return original_sign_define(...)
    end

    -- Act: Reload LSP config
    package.loaded["plugins.lsp"] = nil
    require("plugins.lsp")

    -- Assert
    assert.equals(0, #deprecated_calls,
      "MUST NOT use deprecated sign_define API")

    -- Restore
    vim.fn.sign_define = original_sign_define
  end)
end)
```

______________________________________________________________________

## Implementation Recommendations (RED-GREEN-REFACTOR)

### Priority 1: Fix Python Treesitter Parser (CRITICAL)

#### RED Phase (Write Failing Test)

```bash
# Run the contract test - it should fail
./tests/run-test.sh tests/treesitter/python-parser-contract.test.lua
# Expected: FAIL - "Invalid node type 'except*'"
```

#### GREEN Phase (Make Test Pass)

```lua
-- lua/config/treesitter-fix.lua
local function fix_python_parser()
  -- Solution 1: Update parser to version supporting except*
  vim.cmd("TSUpdate python")

  -- Solution 2: Override highlight query to remove except*
  local queries_dir = vim.fn.stdpath("config") .. "/after/queries/python"
  vim.fn.mkdir(queries_dir, "p")

  -- Copy and patch the highlights.scm file
  local original = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter/queries/python/highlights.scm"
  local patched = queries_dir .. "/highlights.scm"

  local content = vim.fn.readfile(original)
  -- Remove the problematic except* node reference
  content = vim.tbl_filter(function(line)
    return not line:match('"except%*"')
  end, content)

  vim.fn.writefile(content, patched)
end

return {
  setup = fix_python_parser
}
```

#### REFACTOR Phase (Improve Solution)

```lua
-- lua/plugins/treesitter-override.lua
return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    -- Ensure parser auto-update for compatibility
    opts.auto_install = true
    opts.ensure_installed = vim.list_extend(
      opts.ensure_installed or {},
      { "python" }
    )

    -- Add parser version pinning
    opts.parser_install_info = {
      python = {
        revision = "4e66e6fa7dc0e9ce91de89414a0f0aa27c8b9df0", -- Known good version
      }
    }

    return opts
  end,
}
```

### Priority 2: Fix Session Options (HIGH)

#### RED Phase

```bash
./tests/run-test.sh tests/session/auto-session-contract.test.lua
# Expected: FAIL - Filetype not preserved
```

#### GREEN Phase

```lua
-- lua/config/session-fix.lua
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
```

#### REFACTOR Phase

```lua
-- lua/plugins/auto-session-override.lua
return {
  "rmagatti/auto-session",
  opts = {
    -- Ensure localoptions is included
    pre_save_cmds = {
      function()
        -- Validate sessionoptions before save
        local opts = vim.o.sessionoptions
        if not opts:match("localoptions") then
          vim.o.sessionoptions = opts .. ",localoptions"
        end
      end,
      "TroubleClose",
    },
  },
}
```

### Priority 3: Fix Diagnostic Signs (HIGH)

#### RED Phase

```bash
./tests/run-test.sh tests/lsp/diagnostic-signs-contract.test.lua
# Expected: FAIL - Using deprecated API
```

#### GREEN Phase

```lua
-- lua/plugins/lsp-diagnostic-fix.lua
return {
  "neovim/nvim-lspconfig",
  config = function()
    -- Modern diagnostic configuration
    vim.diagnostic.config({
      virtual_text = {
        prefix = "●",
        source = "if_many",
      },
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = "✗",
          [vim.diagnostic.severity.WARN] = "⚠",
          [vim.diagnostic.severity.INFO] = "ℹ",
          [vim.diagnostic.severity.HINT] = "➤",
        },
        linehl = {
          [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
        },
        numhl = {
          [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
        },
      },
      float = {
        source = "always",
        border = "rounded",
      },
      update_in_insert = false,
      severity_sort = true,
    })
  end,
}
```

______________________________________________________________________

## Health Check Validation Strategy

### Continuous Health Monitoring

```lua
-- tests/health/continuous-validation.test.lua

describe("Continuous Health Validation", function()
  local function parse_checkhealth_output()
    local output = vim.fn.system("nvim --headless -c 'checkhealth' -c 'qa' 2>&1")
    local critical_errors = {}
    local high_warnings = {}

    for line in output:gmatch("[^\n]+") do
      if line:match("ERROR") then
        table.insert(critical_errors, line)
      elseif line:match("WARNING") and
             (line:match("deprecated") or line:match("localoptions")) then
        table.insert(high_warnings, line)
      end
    end

    return {
      critical = critical_errors,
      high = high_warnings,
    }
  end

  it("should have no CRITICAL errors in checkhealth", function()
    -- Act
    local health = parse_checkhealth_output()

    -- Assert
    assert.equals(0, #health.critical,
      "No CRITICAL errors allowed in checkhealth:\n" ..
      table.concat(health.critical, "\n"))
  end)

  it("should track HIGH priority warnings", function()
    -- Act
    local health = parse_checkhealth_output()

    -- Report but don't fail
    if #health.high > 0 then
      print("HIGH priority warnings detected:")
      for _, warning in ipairs(health.high) do
        print("  - " .. warning)
      end
    end

    -- Assert: Just track count for trend analysis
    assert.is_true(#health.high <= 5,
      "HIGH warnings should be decreasing over time")
  end)
end)
```

### Pre-commit Hook Integration

```bash
#!/bin/bash
# .git/hooks/pre-commit-checkhealth

# Run health validation tests
nvim --headless -c "PlenaryBustedFile tests/health/continuous-validation.test.lua" -c "qa"

if [ $? -ne 0 ]; then
  echo "❌ Health check validation failed. Fix critical issues before committing."
  exit 1
fi

echo "✅ Health check validation passed"
exit 0
```

### Quality Gates Configuration

```yaml
# .github/workflows/health-check.yml
name: Health Check Validation

on: [push, pull_request]

jobs:
  health-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Install Neovim
        run: |
          curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
          tar xzf nvim-linux64.tar.gz
          echo "$PWD/nvim-linux64/bin" >> $GITHUB_PATH

      - name: Run Health Check Tests
        run: |
          nvim --version
          nvim --headless -c "PlenaryBustedFile tests/health/continuous-validation.test.lua" -c "qa"

      - name: Generate Health Report
        if: always()
        run: |
          nvim --headless -c "checkhealth" -c "qa" > health-report.txt 2>&1
          cat health-report.txt

      - name: Upload Health Report
        if: always()
        uses: actions/upload-artifact@v2
        with:
          name: health-report
          path: health-report.txt
```

______________________________________________________________________

## Test Execution Plan

### Phase 1: CRITICAL Issues (Immediate)

1. Write Python parser contract tests
2. Implement parser fix
3. Validate fix with capability tests
4. Run full test suite to ensure no regressions

### Phase 2: HIGH Priority (Within 24 hours)

1. Write session restoration tests
2. Fix sessionoptions configuration
3. Write diagnostic signs tests
4. Migrate to modern diagnostic API
5. Validate all HIGH priority fixes

### Phase 3: MEDIUM Priority (Within 1 week)

1. Install inotify-tools for file watcher
2. Configure yarn properly or disable check
3. Add performance tests for LSP

### Phase 4: Continuous Improvement

1. Add health check to pre-commit hooks
2. Set up CI/CD health monitoring
3. Create dashboard for health metrics
4. Regular parser update validation

______________________________________________________________________

## Success Criteria

### Immediate Success (After Phase 1)

- [ ] Python syntax highlighting works
- [ ] No "Invalid node type" errors
- [ ] All Python contract tests pass

### Short-term Success (After Phase 2)

- [ ] Session restoration preserves state
- [ ] No deprecated API warnings
- [ ] Health check shows 0 CRITICAL, \<3 HIGH

### Long-term Success (Ongoing)

- [ ] CI/CD validates health on every commit
- [ ] Health metrics trend improvement
- [ ] \<5% test failures from environment issues
- [ ] 100% test coverage for critical paths

______________________________________________________________________

## Appendix: Helper Scripts

### Quick Health Check Script

```bash
#!/bin/bash
# scripts/check-health-status.sh

echo "🔍 Running PercyBrain Health Check..."

# Count issues by severity
CRITICAL=$(nvim --headless -c 'checkhealth' -c 'qa' 2>&1 | grep -c "ERROR")
HIGH=$(nvim --headless -c 'checkhealth' -c 'qa' 2>&1 | grep -c "WARNING.*deprecated\|localoptions")
MEDIUM=$(nvim --headless -c 'checkhealth' -c 'qa' 2>&1 | grep -c "WARNING" | awk -v h="$HIGH" '{print $1-h}')

echo "📊 Health Status:"
echo "  🔴 CRITICAL: $CRITICAL"
echo "  🟡 HIGH: $HIGH"
echo "  🟠 MEDIUM: $MEDIUM"

if [ "$CRITICAL" -gt 0 ]; then
  echo "❌ CRITICAL issues detected! Fix immediately."
  exit 1
elif [ "$HIGH" -gt 3 ]; then
  echo "⚠️ HIGH priority issues need attention."
  exit 2
else
  echo "✅ System health acceptable."
  exit 0
fi
```

### Test Runner with Health Validation

```bash
#!/bin/bash
# tests/run-with-health-check.sh

echo "🧪 Running tests with health validation..."

# Run health check first
./scripts/check-health-status.sh
HEALTH_STATUS=$?

# Run tests
./tests/run-all-unit-tests.sh
TEST_STATUS=$?

# Combined status
if [ "$HEALTH_STATUS" -eq 0 ] && [ "$TEST_STATUS" -eq 0 ]; then
  echo "✅ All tests pass and system healthy!"
  exit 0
else
  echo "❌ Issues detected:"
  [ "$HEALTH_STATUS" -ne 0 ] && echo "  - Health check failed"
  [ "$TEST_STATUS" -ne 0 ] && echo "  - Unit tests failed"
  exit 1
fi
```

______________________________________________________________________

**Author**: Kent Beck TDD Specialist **Date**: October 2025 **Version**: 1.0.0 **Test Coverage Goal**: 100% for critical paths
