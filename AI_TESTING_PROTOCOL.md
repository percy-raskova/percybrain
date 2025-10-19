# AI-Driven Environment Validation (AIDEV) Protocol

**Category**: Technical Reference | **For**: Neovim MCP Testing | **Philosophy**: See [docs/explanation/AI_TESTING_PHILOSOPHY.md](docs/explanation/AI_TESTING_PHILOSOPHY.md)

## Core Testing Dimensions

### 1. 🔍 Sensory Testing (Perception)

**Goal**: Can the AI perceive the environment accurately?

```lua
-- Test Examples
vim_status()        -- What mode? Where's the cursor?
vim_buffer()        -- What's on screen?
health_check()      -- What's broken?
register_contents() -- What's in memory? (privacy check!)
```

**What We Found**: Discovered sensitive data in registers - SSH keys, API configs!

### 2. 🎮 Motor Testing (Actions)

**Goal**: Can the AI perform actions correctly?

```lua
-- Test Examples
navigation_test()   -- Move cursor (gg, G, hjkl)
command_test()      -- Execute commands
window_test()       -- Split, close, switch windows
editing_test()      -- Insert, delete, change text
```

### 3. 🧩 Integration Testing (Features)

**Goal**: Do plugins and features work together?

```lua
-- Test Examples
telescope_test()    -- Fuzzy finder working?
lsp_test()         -- Language servers active?
percybrain_test()  -- Dashboard, network graph functional?
keybinding_test()  -- Do leader mappings work?
```

### 4. 🚨 Error Detection (Diagnostics)

**Goal**: Can the AI identify and diagnose issues?

```lua
-- Test Examples
deprecation_check()  -- Found: vim.tbl_islist deprecated
conflict_check()     -- Found: keybinding conflicts
performance_check()  -- Measure response times
security_check()     -- Found: sensitive data exposure
```

## Test Suite Structure

### Level 1: Smoke Tests (Basic Validation)

```yaml
quick_tests:
  - connection: "Can connect to Neovim?"
  - status: "Can read status?"
  - command: "Can execute basic command?"
  - buffer: "Can read buffer content?"

time: < 5 seconds
purpose: "Rapid validation that basics work"
```

### Level 2: Feature Tests (Component Validation)

```yaml
feature_tests:
  - navigation: "Test all movement commands"
  - editing: "Test insert/delete/change"
  - plugins: "Verify each plugin loads"
  - keybindings: "Test all leader mappings"

time: < 30 seconds
purpose: "Verify individual features work"
```

### Level 3: Integration Tests (Workflow Validation)

```yaml
workflow_tests:
  - create_note: "New note → Edit → Save → Navigate"
  - search_workflow: "Telescope → Select → Edit"
  - git_workflow: "Edit → Stage → Commit"
  - ai_workflow: "Generate → Review → Apply"

time: < 2 minutes
purpose: "Validate complete user workflows"
```

### Level 4: Stress Tests (Limits & Performance)

```yaml
stress_tests:
  - large_file: "Open 10MB file - responsive?"
  - many_windows: "20 splits - still navigable?"
  - rapid_commands: "100 commands/second - stable?"
  - memory_usage: "After 1 hour - memory leak?"

time: Variable
purpose: "Find breaking points and limits"
```

## Implementation Example

```lua
-- AI Test Runner (pseudo-code)
local AITester = {}

function AITester:run_smoke_tests()
  local results = {}

  -- Test 1: Connection
  results.connection = self:test_connection()

  -- Test 2: Navigation
  local start_pos = vim.api.nvim_win_get_cursor(0)
  vim.cmd("normal gg")
  local end_pos = vim.api.nvim_win_get_cursor(0)
  results.navigation = (end_pos[1] == 1)

  -- Test 3: Command execution
  local ok, err = pcall(vim.cmd, "echo 'test'")
  results.commands = ok

  -- Test 4: Buffer reading
  local content = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  results.buffer_read = (#content > 0)

  return results
end

function AITester:generate_report(results)
  local report = "# AI Testing Report\n\n"
  for test, passed in pairs(results) do
    local status = passed and "✅" or "❌"
    report = report .. status .. " " .. test .. "\n"
  end
  return report
end
```

## Metrics & Reporting

### Test Coverage Metrics

```yaml
coverage:
  commands_tested: "45/120 (37.5%)"
  keybindings_tested: "28/85 (32.9%)"
  plugins_tested: "9/68 (13.2%)"
  workflows_tested: "3/12 (25%)"
```

### Performance Baselines

```yaml
performance:
  startup_time: "168ms"
  command_latency: "~50ms"
  file_open_1mb: "200ms"
  telescope_search: "150ms"
```

### Security Findings

```yaml
security:
  sensitive_data_in_registers: "CRITICAL - Fixed"
  world_readable_configs: "WARNING"
  unencrypted_credentials: "None found"
```

## Next Steps

1. **Automate Test Suite** - Create scheduled test runs
2. **Build Test Library** - Comprehensive test collection
3. **Create Benchmarks** - Performance baselines
4. **Develop AI Test Personas** - Different testing styles
5. **Open Source Protocol** - Share with community

______________________________________________________________________

**See Also**: [AI Testing Philosophy](docs/explanation/AI_TESTING_PHILOSOPHY.md) for conceptual foundations and paradigm shifts.
