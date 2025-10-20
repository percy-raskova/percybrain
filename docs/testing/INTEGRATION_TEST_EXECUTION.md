# Integration Test Execution & CI/CD Guide

**Author**: Kent Beck Testing Persona **Date**: October 20, 2025 **Philosophy**: "Tests that don't run are tests that don't exist. Make them easy to run, impossible to ignore."

## Test Execution Strategy

### Execution Timing Targets

**Answer to Q7**: Integration tests should be **fast enough to run on every commit**:

```yaml
timing_targets:
  single_workflow_test: < 2 seconds
  integration_suite: < 30 seconds
  full_test_pyramid: < 60 seconds

execution_frequency:
  unit_tests: every_save (watch mode)
  integration_tests: every_commit
  e2e_tests: every_pr (if implemented)
```

### Test Runner Script

```bash
#!/usr/bin/env bash
# tests/run-integration-tests.sh

set -e  # Fail fast on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔄 Running PercyBrain Integration Tests..."

# Setup test environment
export PERCYBRAIN_TEST_MODE=integration
export PERCYBRAIN_TEST_VAULT=$(mktemp -d)/test_zettelkasten

# Create test structure
mkdir -p "$PERCYBRAIN_TEST_VAULT"/{inbox,templates,.iwe}
cp tests/integration/fixtures/templates/* "$PERCYBRAIN_TEST_VAULT/templates/" 2>/dev/null || true

# Run tests with timing
STARTTIME=$(date +%s)

nvim --headless \
  -u tests/integration/minimal_init.lua \
  -c "PlenaryBustedDirectory tests/integration/workflows/ { minimal_init = 'tests/integration/minimal_init.lua', sequential = true }" \
  -c "qa!"

EXITCODE=$?
ENDTIME=$(date +%s)
DURATION=$((ENDTIME - STARTTIME))

# Cleanup
rm -rf "$PERCYBRAIN_TEST_VAULT"

# Report results
if [ $EXITCODE -eq 0 ]; then
  echo -e "${GREEN}✅ Integration tests passed in ${DURATION} seconds${NC}"
else
  echo -e "${RED}❌ Integration tests failed after ${DURATION} seconds${NC}"
fi

exit $EXITCODE
```

### Parallel Execution Strategy

```lua
-- tests/integration/helpers/parallel_runner.lua
local M = {}

-- Run workflow tests in parallel where safe
function M.run_parallel_safe_tests()
  local safe_to_parallelize = {
    "quick_capture_spec.lua",
    "template_selection_spec.lua",
    "ai_model_selection_spec.lua"
  }

  local sequential_required = {
    "wiki_creation_spec.lua",  -- Modifies global state
    "publishing_spec.lua"       -- Depends on wiki creation
  }

  -- Run parallel tests
  for _, spec in ipairs(safe_to_parallelize) do
    -- Each gets its own test vault
    coroutine.create(function()
      run_spec_isolated(spec)
    end)
  end

  -- Then run sequential tests
  for _, spec in ipairs(sequential_required) do
    run_spec_isolated(spec)
  end
end

return M
```

## CI/CD Integration

### GitHub Actions Workflow

```yaml
# .github/workflows/integration-tests.yml
name: Integration Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  integration-tests:
    runs-on: ubuntu-latest
    timeout-minutes: 10  # Fail if tests take too long

    strategy:
      matrix:
        neovim_version: ['v0.9.0', 'v0.10.0', 'nightly']

    steps:
    - uses: actions/checkout@v3

    - name: Install Neovim
      uses: rhysd/action-setup-nvim@v1
      with:
        version: ${{ matrix.neovim_version }}

    - name: Cache Dependencies
      uses: actions/cache@v3
      with:
        path: |
          ~/.local/share/nvim/site/pack
          ~/.cache/nvim
        key: ${{ runner.os }}-nvim-${{ matrix.neovim_version }}-${{ hashFiles('**/lazy-lock.json') }}

    - name: Setup Test Environment
      run: |
        # Install test dependencies
        git clone --depth 1 https://github.com/nvim-lua/plenary.nvim \
          ~/.local/share/nvim/site/pack/vendor/start/plenary.nvim

        # Create test structure
        mkdir -p tests/integration/fixtures/templates
        echo "---\ntitle: Test\n---" > tests/integration/fixtures/templates/wiki.md

    - name: Run Unit Tests First
      run: ./tests/run-all-unit-tests.sh
      continue-on-error: false  # Must pass before integration

    - name: Run Integration Tests
      run: ./tests/run-integration-tests.sh
      env:
        PERCYBRAIN_CI: true
        PERCYBRAIN_TEST_TIMEOUT: 5000  # 5 second timeout per test

    - name: Upload Test Results
      if: always()
      uses: actions/upload-artifact@v3
      with:
        name: test-results-${{ matrix.neovim_version }}
        path: tests/output/

    - name: Report Coverage
      if: matrix.neovim_version == 'v0.10.0'  # Only on one version
      run: |
        # Generate coverage report
        ./tests/coverage.sh
        # Upload to service (e.g., Codecov)
```

### Local Development Workflow

```bash
# mise.toml additions
[tasks.test-integration]
description = "Run integration tests"
run = "./tests/run-integration-tests.sh"

[tasks.test-watch-integration]
description = "Watch and run integration tests on change"
run = """
  watchexec -e lua -w lua/percybrain -w tests/integration \
    -- ./tests/run-integration-tests.sh
"""

[tasks.test-all]
description = "Run complete test pyramid"
run = """
  echo "Running complete test suite..."
  mise run test:unit &&
  mise run test:contract &&
  mise run test:capability &&
  mise run test:integration &&
  echo "✅ All tests passed!"
"""

[tasks.test-quick]
description = "Run fast subset for quick feedback"
run = """
  # Run only critical path tests
  nvim --headless -u tests/minimal_init.lua \
    -c "PlenaryBustedFile tests/integration/workflows/wiki_creation_spec.lua" \
    -c "qa!"
"""
```

## Test Data Management

### Fixture Strategy

```lua
-- tests/integration/fixtures/fixture_manager.lua
local M = {}

M.templates = {
  wiki = [[---
title: {{title}}
date: {{date}}
draft: false
tags: []
categories: []
description: ""
---

# {{title}}
]],

  fleeting = [[---
title: {{title}}
created: {{timestamp}}
---

{{content}}
]]
}

M.mock_ai_responses = {
  default = {
    summary = "This is a test summary",
    tags = {"test", "integration"},
    connections = {"note1", "note2"}
  },

  error = {
    error = "Connection timeout",
    code = "TIMEOUT"
  }
}

-- Load fixtures dynamically
function M.get_fixture(type, name)
  local fixture_file = string.format(
    "tests/integration/fixtures/%s/%s.json",
    type, name
  )

  if vim.fn.filereadable(fixture_file) == 1 then
    local content = vim.fn.readfile(fixture_file)
    return vim.json.decode(table.concat(content, "\n"))
  end

  -- Return default if no specific fixture
  return M[type] and M[type][name] or M[type].default
end

return M
```

## Success Metrics & Monitoring

### Integration Test Quality Metrics

```lua
-- tests/integration/helpers/metrics.lua
local M = {}

function M.collect_metrics(test_results)
  return {
    -- Coverage metrics
    workflows_covered = M.count_workflows_tested(),
    integration_points_covered = M.count_integration_points(),
    error_scenarios_covered = M.count_error_tests(),

    -- Performance metrics
    average_test_time = M.calculate_average_time(test_results),
    slowest_test = M.find_slowest_test(test_results),
    total_execution_time = M.sum_execution_times(test_results),

    -- Quality metrics
    flaky_tests = M.identify_flaky_tests(test_results),
    test_clarity_score = M.assess_test_clarity(),  -- Based on naming, structure

    -- Maintenance metrics
    mock_complexity = M.measure_mock_complexity(),
    fixture_usage = M.analyze_fixture_usage()
  }
end

function M.report_metrics(metrics)
  print("=== Integration Test Metrics ===")
  print(string.format("Workflows Covered: %d/3", metrics.workflows_covered))
  print(string.format("Integration Points: %d/5", metrics.integration_points_covered))
  print(string.format("Error Scenarios: %d", metrics.error_scenarios_covered))
  print(string.format("Average Test Time: %.2fs", metrics.average_test_time))
  print(string.format("Total Suite Time: %.2fs", metrics.total_execution_time))

  if #metrics.flaky_tests > 0 then
    print("⚠️ Flaky Tests Detected:")
    for _, test in ipairs(metrics.flaky_tests) do
      print("  - " .. test)
    end
  end
end

return M
```

### Success Criteria

```yaml
integration_test_success_criteria:
  coverage:
    workflows: 100%  # All 3 primary workflows
    integration_points: 100%  # All 5 integration points
    error_paths: >= 80%  # Most common error scenarios

  performance:
    single_test_p95: < 3s
    full_suite_p95: < 30s
    flaky_rate: < 2%

  maintainability:
    mock_loc_ratio: < 0.3  # Mock code < 30% of test code
    test_clarity_score: > 8.0  # Subjective but measurable
    fixture_reuse_rate: > 60%

  reliability:
    false_positive_rate: 0%
    false_negative_rate: < 5%
    ci_success_rate: > 95%
```

## Debugging Integration Tests

### Debug Helpers

```lua
-- tests/integration/helpers/debug.lua
local M = {}

-- Enhanced debugging for integration tests
function M.debug_workflow_state(checkpoint_name)
  if not vim.env.DEBUG_INTEGRATION then
    return
  end

  print("\n=== Workflow State: " .. checkpoint_name .. " ===")
  print("Buffers: " .. vim.inspect(vim.api.nvim_list_bufs()))
  print("Current Buffer: " .. vim.api.nvim_get_current_buf())
  print("Autocmds: " .. vim.inspect(vim.api.nvim_get_autocmds({})))

  -- Component states
  local pipeline = require("percybrain.write-quit-pipeline")
  print("Pipeline State: " .. vim.inspect(pipeline.get_processing_status()))

  -- File system state
  local test_vault = vim.env.PERCYBRAIN_TEST_VAULT
  if test_vault then
    local files = vim.fn.globpath(test_vault, "**/*.md", false, true)
    print("Test Files: " .. vim.inspect(files))
  end

  print("=====================================\n")
end

-- Capture and replay integration test scenarios
function M.record_test_scenario(name)
  local recording = {
    name = name,
    timestamp = os.time(),
    actions = {},
    states = {}
  }

  -- Hook into component calls
  local original_save = pipeline.on_save
  pipeline.on_save = function(...)
    table.insert(recording.actions, {
      type = "save",
      args = {...},
      time = os.time()
    })
    return original_save(...)
  end

  return recording
end

return M
```

### Debug Mode Execution

```bash
# Run with debug output
DEBUG_INTEGRATION=1 ./tests/run-integration-tests.sh

# Run single test with debugging
DEBUG_INTEGRATION=1 nvim --headless \
  -u tests/integration/minimal_init.lua \
  -c "PlenaryBustedFile tests/integration/workflows/wiki_creation_spec.lua" \
  -c "qa!"

# Run with recording for replay
RECORD_SCENARIOS=1 ./tests/run-integration-tests.sh
```

## Migration Path from Current Tests

### Phase 1: Setup Infrastructure (Week 1)

1. Create directory structure
2. Write helper modules
3. Set up CI/CD pipeline
4. Create fixture management

### Phase 2: Implement Core Workflows (Week 2)

1. Quick capture workflow
2. Wiki creation workflow
3. Publishing workflow

### Phase 3: Add Error Scenarios (Week 3)

1. AI processing failures
2. Invalid frontmatter
3. Filesystem errors
4. Concurrent access

### Phase 4: Optimization & Polish (Week 4)

1. Parallel execution
2. Performance tuning
3. Flaky test elimination
4. Documentation

## Summary

This integration testing framework provides:

1. **Clear Organization**: Separation of workflows, interactions, and fixtures
2. **Fast Execution**: \< 30 second target with parallel support
3. **Real Enough Mocking**: Balance between speed and reality
4. **CI/CD Ready**: GitHub Actions + local development workflow
5. **Debugging Support**: Comprehensive tools for test troubleshooting
6. **Success Metrics**: Clear criteria for test quality

The framework follows Kent Beck's principles:

- **Tests as Documentation**: Each test tells a user story
- **Fast Feedback**: Quick enough to run on every commit
- **Maintainable**: Clear structure, minimal mocking complexity
- **Reliable**: Handles async operations, prevents flaky tests

Ready to implement? Start with the directory structure and first workflow test!
