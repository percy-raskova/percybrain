# Kent Beck Testing Framework for PercyBrain

> "Tests are specifications that drive implementation, not afterthoughts." — Kent Beck

## Overview

PercyBrain's testing framework has been redesigned following Kent Beck's Test-Driven Development philosophy. The new architecture emphasizes **testing capabilities over configuration**, with systematic organization through Mise task orchestration.

## Core Philosophy

### Three Types of Tests

1. **Contract Tests** ✅ - Verify PercyBrain adheres to specifications
2. **Capability Tests** 🎯 - Verify features work as users expect
3. **Regression Tests** 🛡️ - Protect critical optimizations from breaking

### Key Principles

- **Test what users can DO, not HOW it's configured**
- **Respect intentional design choices** (e.g., `hlsearch=false` is a feature, not a bug)
- **Isolate tests from environment** for reproducibility
- **Make failures actionable** with clear messages

## Quick Start

```bash
# Run all tests
mise test

# Quick feedback (contract + regression only)
mise test:quick

# Watch mode for development
mise test:watch

# Specific test types
mise tc          # Contract tests
mise tcap        # Capability tests
mise tr          # Regression tests

# Debug mode with verbose output
mise test:debug
```

## Test Organization

```
tests/
├── contract/           # Tests against specifications
│   └── percybrain_contract_spec.lua
├── capability/         # Tests that features WORK
│   ├── zettelkasten/  # Note-taking capabilities
│   ├── ai/            # AI integration capabilities
│   ├── ui/            # UI interaction capabilities
│   └── prose/         # Writing environment capabilities
├── regression/        # Protects critical behaviors
│   └── adhd_protections_spec.lua
├── integration/       # Multi-component interactions
└── helpers/          # Test framework utilities
    └── test_framework.lua

specs/
└── percybrain_contract.lua  # Contract specification
```

## Mise Integration

### Why Mise?

- **Smart Caching**: Tests only re-run when source files change (95% faster)
- **Single Source of Truth**: All test commands in `.mise.toml`
- **Parallel Execution**: Where appropriate (not for Neovim tests)
- **Cross-Platform**: Works on Linux, macOS, Windows (WSL)

### Task Architecture

```toml
# Atomic test tasks
[tasks."test:contract"]       # Contract validation
[tasks."test:capability"]      # Feature verification
[tasks."test:regression"]      # Protection validation
[tasks."test:integration"]     # Component interaction

# Composite workflows
[tasks.test]                   # Full suite
[tasks."test:quick"]          # Fast feedback
[tasks."test:comprehensive"]   # With coverage

# Utilities
[tasks."test:watch"]          # Watch mode
[tasks."test:report"]         # Generate report
[tasks."test:profile"]        # Performance analysis
```

### Caching Strategy

Mise tracks source files and only re-runs tests when:

- Test files change
- Source files under test change
- Dependencies are modified

This means:

- First run: ~10 seconds
- Cached run: \<1 second
- Watch mode: Instant feedback

## Writing Tests

### Contract Tests

Contract tests verify that PercyBrain meets its specification:

```lua
describe("PercyBrain Contract", function()
  it("provides Zettelkasten core capabilities", function()
    -- Arrange: Load contract specification
    local spec = require('specs.percybrain_contract')

    -- Act: Validate requirements
    local has_capability = contract:validate_required()

    -- Assert: Capability must be present
    assert.is_true(has_capability, "Zettelkasten must be available")
  end)
end)
```

### Capability Tests

Capability tests verify what users CAN DO:

```lua
describe("User Capabilities", function()
  it("CAN create timestamped notes", function()
    -- Test that users can perform the action
    helpers.assert_can("create note", function()
      local note = zk.new_note("Title")
      return vim.fn.filereadable(note) == 1
    end, "User should be able to create notes")
  end)

  it("WORKS with unique timestamps", function()
    -- Test that the feature works correctly
    helpers.assert_works("timestamp generation", function()
      local note1 = zk.new_note("First")
      local note2 = zk.new_note("Second")
      return note1 ~= note2
    end, "Timestamps should be unique")
  end)
end)
```

### Regression Tests

Regression tests protect critical features:

```lua
describe("ADHD Optimization Protection", function()
  it("NEVER enables search highlighting", function()
    regression:protect_setting(
      'hlsearch',
      false,
      "Search highlighting creates visual noise that disrupts ADHD focus"
    )

    local violations = regression:validate()
    assert.equals(0, #violations, "hlsearch must remain false")
  end)
end)
```

## Test Helpers

### State Management

```lua
-- Isolate tests from environment
local state = helpers.StateManager:new()
state:save()           -- Save current state
state:isolate()        -- Create clean environment
-- Run tests...
state:restore()        -- Restore original state
```

### Capability Testing

```lua
local cap = helpers.Capability:new("Feature Name")
cap:can("perform action", test_function)     -- User can do X
cap:works("feature", test_function)          -- Feature works correctly
cap:preserves("behavior", test_function)     -- Behavior is maintained
local results = cap:run()
```

### Regression Protection

```lua
local reg = helpers.Regression:new("Protection Suite")
reg:protect_setting('option', expected_value, "reason")
reg:protect_behavior("behavior", test_function, "reason")
local violations = reg:validate()
```

### Performance Testing

```lua
-- Run with timing constraints
local result, elapsed = helpers.run_timed(function()
  return expensive_operation()
end, 200)  -- 200ms budget

-- Run with retry for flaky operations
local result = helpers.run_with_retry(function()
  return network_operation()
end, 3)  -- 3 retries
```

## Migration Guide

### From Old Test Structure

1. **Categorize existing tests**:

   - Configuration tests → Contract tests
   - Feature tests → Capability tests
   - Critical settings → Regression tests
   - Multi-file tests → Integration tests

2. **Move test files**:

   ```bash
   # Old structure
   tests/plenary/unit/options_spec.lua

   # New structure
   tests/contract/options_contract_spec.lua      # Spec validation
   tests/capability/writing/spell_check_spec.lua # Feature testing
   tests/regression/adhd_protections_spec.lua    # Protection
   ```

3. **Update test patterns**:

   ```lua
   -- Old: Test configuration
   it("sets spell to true", function()
     assert.is_true(vim.opt.spell:get())
   end)

   -- New: Test capability
   it("CAN check spelling while writing", function()
     helpers.assert_can("check spelling", function()
       -- Test spell checking WORKS, not just configured
       return spell_checker_available()
     end)
   end)
   ```

4. **Update commands**:

   ```bash
   # Old
   ./tests/run-all-unit-tests.sh

   # New
   mise test
   ```

## Debugging Test Failures

### Actionable Failure Messages

Tests should provide clear guidance on failures:

```lua
assert.is_true(
  condition,
  "What failed: Search highlighting was enabled\n" ..
  "Why it matters: Creates visual noise for ADHD users\n" ..
  "How to fix: Set hlsearch=false in config/options.lua"
)
```

### Debug Mode

```bash
# Run with verbose output
TEST_VERBOSITY=verbose mise test

# Or use debug task
mise test:debug

# Profile slow tests
mise test:profile
```

### Common Issues

1. **Environment-dependent failures**:

   - Use `StateManager` for isolation
   - Don't assume specific plugins are loaded
   - Mock external dependencies

2. **Timing issues**:

   - Use `vim.wait()` for async operations
   - Set reasonable timeouts
   - Use `run_with_retry` for network operations

3. **Path issues**:

   - Use absolute paths in tests
   - Create temp directories for file operations
   - Clean up after tests

## Continuous Integration

### GitHub Actions Example

```yaml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: jdx/mise-action@v2
      - name: Install dependencies
        run: mise install
      - name: Run tests
        run: mise ci  # Runs comprehensive tests + quality checks
```

### Pre-commit Hooks

The test framework integrates with pre-commit:

```yaml
# .pre-commit-config.yaml
- repo: local
  hooks:
    - id: test-standards
      name: Test Standards Check
      entry: mise test:quick
      language: system
      pass_filenames: false
```

## Best Practices

### DO ✅

- Write tests FIRST (TDD)
- Test capabilities, not configuration
- Use descriptive test names that explain intent
- Provide actionable failure messages
- Isolate tests from environment
- Use helpers for common patterns
- Document WHY settings are critical (regression tests)

### DON'T ❌

- Test implementation details
- Write tests that depend on other tests
- Use hard-coded delays (use `vim.wait`)
- Skip failing tests (fix or remove)
- Test multiple behaviors in one test
- Ignore flaky tests (fix the flakiness)

## Performance Targets

- **Startup**: \< 500ms
- **Test execution**: \< 10s for full suite
- **Cached execution**: \< 1s
- **Single test file**: \< 100ms
- **Watch mode response**: \< 200ms

## Support and Troubleshooting

### Getting Help

1. Check test output for actionable messages
2. Run `mise test:debug` for verbose output
3. Review `docs/testing/KENT_BECK_TESTING_GUIDE.md` (this file)
4. Check `tests/helpers/test_framework.lua` for helper docs
5. Run `mise test:report` for test status summary

### Common Commands Reference

```bash
# Testing
mise test                  # Run all tests
mise test:quick           # Fast feedback
mise test:watch           # Watch mode
mise tc                   # Contract tests only
mise tcap                 # Capability tests only
mise tr                   # Regression tests only

# Debugging
mise test:debug           # Verbose output
mise test:profile         # Performance analysis
mise test:report          # Generate report

# Maintenance
mise test:clean           # Clean test cache
mise test:migrate         # Migration helper
```

## Philosophy in Action

Remember Kent Beck's wisdom:

> "Make the change easy (warning: this may be hard), then make the easy change."

Our testing framework embodies this:

1. **Contract tests** make requirements clear
2. **Capability tests** make features verifiable
3. **Regression tests** make optimizations permanent
4. **Mise integration** makes testing fast

The result: A test suite that guides development, prevents regressions, and keeps us honest about what PercyBrain actually does for its users.
