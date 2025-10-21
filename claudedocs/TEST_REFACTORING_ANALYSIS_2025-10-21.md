# Test Directory Refactoring Analysis

**Date**: 2025-10-21 **Scope**: Comprehensive analysis of `tests/` directory for refactoring opportunities **Methodology**: Sequential thinking analysis with --ultrathink depth **Status**: Analysis complete, recommendations ready for implementation

## Executive Summary

**Test Suite Health**: 44/44 tests passing with good coverage and organization **Critical Issues Found**: 5 different test initialization configs creating inconsistent test environments **Refactoring Priority**: HIGH - Test reliability at risk due to initialization fragmentation **Estimated Effort**: Medium (15-30K tokens) - Multi-file coordination required

### Key Findings

| Issue                                      | Severity    | Impact                                 | Files Affected |
| ------------------------------------------ | ----------- | -------------------------------------- | -------------- |
| Five different test initialization configs | 🔴 CRITICAL | Test reliability, maintenance overhead | 4 test runners |
| Helper function duplication                | 🟡 HIGH     | Code quality, maintenance burden       | 3 helper files |
| Hardcoded test lists                       | 🟡 MEDIUM   | Maintenance overhead                   | 3 test runners |
| Hardcoded coverage metrics                 | 🟢 LOW      | Reporting accuracy                     | 1 test runner  |
| Runner fragmentation                       | 🟢 LOW      | Organizational clarity                 | 7 test runners |

### Quantitative Analysis

- **Total Test Files**: 42 spec files across 8 categories
- **Test Runners**: 7 different shell scripts
- **Helper Files**: 11 total (3 with significant duplication)
- **Initialization Configs**: 5 different versions (should be 1-2)
- **Lines of Duplicated Code**: ~200+ lines across runners and helpers

______________________________________________________________________

## Detailed Findings

### 1. Critical Issue: Test Initialization Fragmentation

**Problem**: Five different initialization configurations create inconsistent test environments.

#### Configuration Inventory

1. **`tests/minimal_init.lua`** (157 lines) - ✅ COMPREHENSIVE

   - Purpose: Authoritative test initialization
   - Features:
     - vim.inspect polyfill for Neovim 0.10+ compatibility (lines 8-21)
     - Unnecessary plugin disabling for performance (lines 23-41)
     - lazy.nvim bootstrapping (lines 42-54)
     - Plenary loading with fallback (lines 56-85)
     - Test helper runtime/package path setup (lines 87-93)
     - PercyBrain config loading (config.options, config.keymaps) (lines 107-118)
     - Test helper globals (\_G.test_helpers, test_assertions, test_mocks) (lines 120-146)
     - Utility functions for test execution (lines 148-156)

2. **`/tmp/minimal_test_init.lua`** (31 lines) - ❌ INCOMPLETE

   - Source: Inline in `run-all-unit-tests.sh` (lines 29-60)
   - Missing: vim.inspect polyfill, plugin disabling, test helpers, config loading
   - Risk: Vim.inspect errors on Neovim 0.10+, contract test failures

3. **`/tmp/test_init.lua`** - ❌ UNKNOWN CONTENT

   - Source: Inline in `run-ollama-tests.sh` (line 54)
   - Not examined in detail but creates third initialization variant

4. **`integration_minimal_init.lua`** (15 lines) - ❌ BARE BONES

   - Source: Inline in `run-integration-tests.sh` (lines 135-151)
   - Different purpose but creates fourth initialization variant
   - Missing Plenary setup, test helpers, proper bootstrapping

5. **No initialization** - ❌ USES FULL CONFIG

   - Source: `run-health-tests.sh` (lines 23-24)
   - Runs without `-u` flag, loads full PercyBrain configuration
   - May be intentional for health checks but undocumented

#### Test Runner Initialization Patterns

| Runner                   | Pattern                                    | Status       | Issue            |
| ------------------------ | ------------------------------------------ | ------------ | ---------------- |
| run-unit-tests.sh        | `-u tests/minimal_init.lua`                | ✅ CORRECT   | None             |
| run-keymap-tests.sh      | `-u tests/minimal_init.lua`                | ✅ CORRECT   | None             |
| run-all-unit-tests.sh    | `-u /tmp/minimal_test_init.lua` (inline)   | ❌ WRONG     | Missing features |
| run-integration-tests.sh | `-u integration_minimal_init.lua` (inline) | ❌ WRONG     | Inconsistent     |
| run-ollama-tests.sh      | `-u /tmp/test_init.lua` (inline)           | ❌ WRONG     | Unknown config   |
| run-health-tests.sh      | No `-u` flag                               | ❓ UNCERTAIN | Full config load |
| simple-test.sh           | Not examined                               | -            | -                |

#### Impact Analysis

**Test Reliability**:

- ❌ Vim.inspect errors possible on Neovim 0.10+ with simplified configs
- ❌ Contract tests may fail without config.keymaps loaded
- ❌ Test helper functions unavailable in some environments
- ❌ Inconsistent behavior based on which runner used

**Maintenance Burden**:

- ❌ Changes to test initialization require updating 5 places
- ❌ No single source of truth for test environment
- ❌ Risk of config drift between versions
- ❌ Difficult to ensure all tests run in same environment

**Developer Experience**:

- ❌ Confusion about which runner to use for which tests
- ❌ Difficult to debug failures due to environment differences
- ❌ Undocumented initialization behavior in some runners

### 2. High Priority: Helper Function Duplication

**Problem**: Critical helper functions duplicated across multiple files with different implementations.

#### wait_for() Duplication

**Location 1**: `tests/helpers/init.lua` (lines 35-45)

```lua
-- Simplified version
function M.wait_for(condition, timeout)
  timeout = timeout or 1000
  local start = vim.loop.now()
  while not condition() do
    if vim.loop.now() - start > timeout then
      error("Timeout waiting for condition")
    end
    vim.wait(10)
  end
end
```

- **Characteristics**: Simple, 11 lines, basic timeout check
- **Error Handling**: Throws error on timeout
- **Polling Interval**: Fixed 10ms

**Location 2**: `tests/helpers/async_helpers.lua` (lines 8-33)

```lua
-- Robust version with error capture
function M.wait_for(condition_fn, timeout_ms, poll_interval_ms)
  timeout_ms = timeout_ms or 5000
  poll_interval_ms = poll_interval_ms or 100

  local elapsed = 0
  local last_error = nil

  while elapsed < timeout_ms do
    local success, result = pcall(condition_fn)
    if success and result then
      return true
    end
    if not success then
      last_error = result
    end
    vim.wait(poll_interval_ms)
    elapsed = elapsed + poll_interval_ms
  end

  return false, last_error or ("Timeout after " .. timeout_ms .. "ms")
end
```

- **Characteristics**: Robust, 26 lines, error capture, configurable polling
- **Error Handling**: Returns false + error message instead of throwing
- **Polling Interval**: Configurable (default 100ms)

**Recommendation**: Keep async_helpers.lua version (more robust), remove init.lua version

#### mock_notify() Overlap

**Location 1**: `tests/helpers/init.lua` (lines 62-79)

- Captures vim.notify calls to array
- Returns captured notifications
- Simple implementation for basic mocking

**Location 2**: Similar patterns in other helpers

- Environment setup helpers may have overlapping mock functionality
- Need to consolidate into single notification mocking approach

#### Temporary Directory Creation

**Location 1**: `tests/helpers/init.lua`

- Basic buffer and temporary file creation

**Location 2**: `tests/helpers/environment_setup.lua`

- Sophisticated vault creation with templates and structure
- More complete temporary environment setup

**Recommendation**: Keep environment_setup.lua patterns, ensure init.lua defers to it

### 3. Medium Priority: Hardcoded Test Lists

**Problem**: Test runners maintain manual lists requiring updates when tests are added.

#### Affected Runners

**`run-unit-tests.sh`** (lines 19-25):

```bash
UNIT_TESTS=(
    "tests/unit/config_spec.lua"
    "tests/unit/options_spec.lua"
    "tests/unit/keymaps_spec.lua"
    "tests/unit/globals_spec.lua"
    "tests/unit/window_manager_spec.lua"
)
```

- **Count**: 5 hardcoded tests
- **Risk**: New unit tests not automatically discovered
- **Maintenance**: Manual update required

**`run-keymap-tests.sh`** (lines 16-22):

```bash
test_files=(
  "cleanup_spec.lua"
  "loading_spec.lua"
  "registry_spec.lua"
  "syntax_spec.lua"
  "namespace_spec.lua"
)
```

- **Count**: 5 hardcoded tests in tests/unit/keymap/
- **Risk**: New keymap tests ignored
- **Maintenance**: Manual update required

**`run-all-unit-tests.sh`**:

- Multiple hardcoded test categories
- 10+ individual test files listed explicitly
- Most comprehensive but most maintenance-heavy

#### Auto-Discovery Solution

Replace hardcoded lists with dynamic discovery:

```bash
# Instead of hardcoded list
UNIT_TESTS=$(find tests/unit -name "*_spec.lua" -type f | sort)

# Or for specific subdirectory
KEYMAP_TESTS=$(find tests/unit/keymap -name "*_spec.lua" -type f | sort)

# Or using plenary's directory runner
nvim --headless -u tests/minimal_init.lua \
  -c "lua require('plenary.test_harness').test_directory('tests/unit', {minimal_init='tests/minimal_init.lua'})" \
  -c "qa!"
```

**Benefits**:

- ✅ Automatic test discovery - no manual updates
- ✅ Impossible to forget to add new tests
- ✅ Alphabetically sorted for consistency
- ✅ Simpler runner scripts

### 4. Low Priority: Hardcoded Coverage Metrics

**Problem**: Coverage percentages manually specified instead of calculated.

**Location**: `run-all-unit-tests.sh` (lines 194-210, 250-253)

```bash
# Hardcoded estimates
CORE_COVERAGE=96
PLUGIN_COVERAGE=80
WORKFLOW_COVERAGE=70
```

**Issues**:

- ❌ Metrics become outdated as tests change
- ❌ No verification against actual coverage
- ❌ False sense of coverage quality

**Solution**: Calculate from test output or coverage tools

```bash
# Extract actual pass/fail counts from Plenary output
TOTAL_TESTS=$(grep -c "^Testing:" "$OUTPUT_FILE")
PASSED_TESTS=$(grep -c "Success" "$OUTPUT_FILE")
COVERAGE_PERCENT=$((PASSED_TESTS * 100 / TOTAL_TESTS))
```

### 5. Low Priority: Test Runner Fragmentation

**Current State**: 7 different test runners with overlapping purposes

| Runner                   | Purpose                             | Lines   | Duplication Risk |
| ------------------------ | ----------------------------------- | ------- | ---------------- |
| run-unit-tests.sh        | Run 5 core unit tests               | 89      | Medium           |
| run-all-unit-tests.sh    | Run all unit tests with coverage    | 309     | High             |
| run-keymap-tests.sh      | Run keymap centralization tests     | 54      | Low              |
| run-integration-tests.sh | Run workflow integration tests      | 303     | High             |
| run-health-tests.sh      | Run health validation + checkhealth | 130     | Low              |
| run-ollama-tests.sh      | Run AI/Ollama-dependent tests       | ~100    | Medium           |
| simple-test.sh           | Quick test execution (not examined) | Unknown | Unknown          |

**Analysis**:

- ✅ Specialized purposes justify most runners
- ⚠️ run-unit-tests.sh vs run-all-unit-tests.sh overlap
- ⚠️ Shared patterns could be extracted to library

**Potential Consolidation**:

- Merge run-unit-tests.sh into run-all-unit-tests.sh with --quick flag
- Extract shared functions (logging, reporting) to tests/lib/runner-common.sh
- Keep specialized runners (keymap, integration, health, ollama) as-is

______________________________________________________________________

## Test Organization Assessment

### Current Structure

```
tests/
├── capability/           # User-centric behavioral tests ("CAN user X?")
│   └── zettelkasten/
├── contract/            # System specification tests ("MUST/MAY system Y?")
├── unit/                # Isolated function/module tests
│   ├── ai/
│   ├── gtd/
│   ├── keymap/
│   ├── sembr/
│   └── zettelkasten/
├── integration/         # Cross-module interaction tests
│   └── workflows/
├── performance/         # Benchmarking and timing tests
├── regression/          # Bug prevention tests
├── health/              # System health validation
└── helpers/             # Test utilities and mocks
    ├── init.lua
    ├── async_helpers.lua
    ├── environment_setup.lua
    ├── gtd_test_helpers.lua
    ├── keymap_test_helpers.lua
    ├── workflow_builders.lua
    ├── mock_services.lua
    └── assertions.lua
```

### Organization Quality: ✅ GOOD

**Strengths**:

- ✅ Clear separation of concerns with purpose-driven categories
- ✅ Follows Kent Beck philosophy in capability tests
- ✅ Contract tests enforce specifications explicitly
- ✅ Domain-based grouping within unit/ (ai/, gtd/, zettelkasten/)
- ✅ Helper files organized by domain (gtd, keymap, workflow)

**Test Philosophy Adherence**:

- **Kent Beck**: "Test behavior, not implementation" → capability/ demonstrates this
- **Contract Testing**: Explicit MUST/MUST NOT/MAY specifications
- **AAA Pattern**: Arrange-Act-Assert comments in specs
- **TDD Standards**: 6/6 standards enforced via pre-commit hooks

**Minor Improvements**:

- Consider README.md in each category explaining purpose and examples
- Document when to use capability vs contract vs unit tests
- Provide templates for each test type

______________________________________________________________________

## Refactoring Recommendations

### Phase 1: Critical - Test Initialization Consolidation

**Priority**: 🔴 HIGH **Effort**: High (20-30K tokens) **Impact**: Critical for test reliability **Risk**: Medium (requires careful validation)

#### Action Items

1. **Standardize on Single Initialization File**

   ```bash
   # All runners should use:
   nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedFile $test" -c "qa!"
   ```

2. **Update run-all-unit-tests.sh**

   - Remove inline config creation (lines 29-60)
   - Change line 54 from `/tmp/minimal_test_init.lua` to `tests/minimal_init.lua`
   - Verify all tests still pass with comprehensive config

3. **Update run-integration-tests.sh**

   - Option A: Use tests/minimal_init.lua directly
   - Option B: Create dedicated tests/integration_init.lua if truly different needs
   - Document why integration init differs if Option B chosen
   - Remove inline config creation (lines 135-151)

4. **Update run-ollama-tests.sh**

   - Remove inline `/tmp/test_init.lua` creation
   - Use `tests/minimal_init.lua` or document why AI tests need different init

5. **Document run-health-tests.sh Behavior**

   - Add comment explaining why no `-u` flag (intentional full config load)
   - Or add `-u tests/minimal_init.lua` if health tests should be isolated

6. **Create Specialized Init Files (If Needed)**

   - `tests/minimal_init.lua` - Default for most tests (current)
   - `tests/integration_init.lua` - ONLY if integration needs truly differ
   - `tests/health_init.lua` - ONLY if health checks need full config
   - Document each file's purpose and when to use

#### Validation Steps

```bash
# Test each runner after changes
./tests/run-unit-tests.sh
./tests/run-all-unit-tests.sh
./tests/run-keymap-tests.sh
./tests/run-integration-tests.sh
./tests/run-health-tests.sh
./tests/run-ollama-tests.sh

# Verify all 44 tests still pass
# Check for vim.inspect errors on Neovim 0.10+
# Ensure contract tests have access to config.keymaps
```

### Phase 2: High Priority - Helper Consolidation

**Priority**: 🟡 HIGH **Effort**: Medium (10-15K tokens) **Impact**: Code quality, maintainability **Risk**: Low (well-tested patterns)

#### Action Items

1. **Consolidate wait_for() Functions**

   - Keep `tests/helpers/async_helpers.lua` version (more robust)
   - Remove `tests/helpers/init.lua` version (lines 35-45)
   - Update init.lua to re-export from async_helpers:
     ```lua
     local async = require('tests.helpers.async_helpers')
     M.wait_for = async.wait_for  -- Re-export robust version
     ```

2. **Consolidate Mock Patterns**

   - Review `mock_notify()` in init.lua vs other helpers
   - Create single authoritative mock in `tests/helpers/mocks.lua`
   - Update all helpers to use common mock functions

3. **Consolidate Environment Setup**

   - Keep `environment_setup.lua` as authoritative for vault creation
   - Update init.lua to defer to environment_setup patterns
   - Document which helper to use for what purpose

4. **Create Helper Usage Guide**

   - Document in `tests/helpers/README.md`:
     - When to use each helper file
     - Common patterns and examples
     - How to add new helpers

#### Validation Steps

```bash
# Run all tests to verify helpers still work
./tests/run-all-unit-tests.sh

# Check for import errors
grep -r "require.*helpers" tests/ | grep -v ".git"

# Verify no functionality lost
diff tests/helpers/init.lua.backup tests/helpers/init.lua
```

### Phase 3: Medium Priority - Test Auto-Discovery

**Priority**: 🟢 MEDIUM **Effort**: Low (5-8K tokens) **Impact**: Maintenance reduction **Risk**: Very Low (additive change)

#### Action Items

1. **Update run-unit-tests.sh**

   ```bash
   # Replace hardcoded UNIT_TESTS array with:
   UNIT_TESTS=$(find tests/unit -maxdepth 1 -name "*_spec.lua" -type f | sort)

   # Or use Plenary directory runner:
   nvim --headless -u tests/minimal_init.lua \
     -c "lua require('plenary.test_harness').test_directory('tests/unit', {minimal_init='tests/minimal_init.lua'})" \
     -c "qa!"
   ```

2. **Update run-keymap-tests.sh**

   ```bash
   # Replace hardcoded test_files array with:
   test_files=$(find tests/unit/keymap -name "*_spec.lua" -type f | sort | xargs basename -a)
   ```

3. **Update run-all-unit-tests.sh**

   - Replace hardcoded test lists with find commands
   - Organize by category using find with path filters
   - Maintain reporting structure with dynamic counts

4. **Add Exclusion Patterns (If Needed)**

   ```bash
   # Skip WIP or broken tests
   UNIT_TESTS=$(find tests/unit -name "*_spec.lua" -not -name "*_wip_spec.lua" | sort)
   ```

#### Validation Steps

```bash
# Verify same tests run before and after
./tests/run-unit-tests.sh 2>&1 | tee before.log
# Make changes
./tests/run-unit-tests.sh 2>&1 | tee after.log
diff before.log after.log

# Add a new test and verify it's auto-discovered
touch tests/unit/new_feature_spec.lua
./tests/run-unit-tests.sh | grep -q "new_feature_spec.lua"
```

### Phase 4: Low Priority - Dynamic Coverage Calculation

**Priority**: 🟢 LOW **Effort**: Low (3-5K tokens) **Impact**: Reporting accuracy **Risk**: Very Low (reporting only)

#### Action Items

1. **Parse Plenary Output for Actual Metrics**

   ```bash
   # Extract test counts from output
   TOTAL_TESTS=$(grep -c "Testing:" "$OUTPUT_FILE")
   PASSED_TESTS=$(grep -c "Success" "$OUTPUT_FILE")
   FAILED_TESTS=$(grep -c "Failure\|Error" "$OUTPUT_FILE")

   # Calculate coverage
   COVERAGE_PERCENT=$((PASSED_TESTS * 100 / TOTAL_TESTS))
   ```

2. **Replace Hardcoded Percentages**

   - Remove lines 194-210 in run-all-unit-tests.sh
   - Calculate from actual test results
   - Show breakdown by category (unit, integration, etc.)

3. **Add Coverage Trends (Optional)**

   - Store coverage history in tests/output/coverage-history.csv
   - Show ↑/↓ trends in reports
   - Alert if coverage drops below threshold

### Phase 5: Optional - Runner Consolidation

**Priority**: 🟢 LOW **Effort**: Medium (10-15K tokens) **Impact**: Organizational clarity **Risk**: Low (careful migration)

#### Action Items

1. **Extract Shared Library**

   - Create `tests/lib/runner-common.sh`
   - Move shared functions: log_info, log_success, log_error, etc.
   - Standardize reporting format

2. **Consolidate Overlapping Runners**

   - Merge run-unit-tests.sh into run-all-unit-tests.sh
   - Add `--quick` flag for subset run:
     ```bash
     ./tests/run-all-unit-tests.sh --quick  # Run core 5 tests only
     ./tests/run-all-unit-tests.sh          # Run all tests
     ```

3. **Keep Specialized Runners**

   - ✅ run-keymap-tests.sh (focused domain)
   - ✅ run-integration-tests.sh (different environment needs)
   - ✅ run-health-tests.sh (runs checkhealth)
   - ✅ run-ollama-tests.sh (optional AI dependencies)

4. **Document Runner Purposes**

   - Create `tests/README.md` with runner guide:
     - Quick validation: `run-all-unit-tests.sh --quick`
     - Full unit tests: `run-all-unit-tests.sh`
     - Keymap tests: `run-keymap-tests.sh`
     - Integration: `run-integration-tests.sh`
     - Health check: `run-health-tests.sh`
     - AI features: `run-ollama-tests.sh`

______________________________________________________________________

## Implementation Plan

### Recommended Sequence

1. **Week 1: Critical Initialization Fix**

   - Phase 1: Consolidate test initialization
   - Validate all 44 tests still pass
   - Checkpoint with git commit

2. **Week 2: Helper Consolidation**

   - Phase 2: Consolidate helper duplication
   - Update all test files using old helpers
   - Create helper usage guide
   - Checkpoint with git commit

3. **Week 3: Auto-Discovery**

   - Phase 3: Implement test auto-discovery
   - Validate coverage unchanged
   - Checkpoint with git commit

4. **Week 4: Polish (Optional)**

   - Phase 4: Dynamic coverage calculation
   - Phase 5: Runner consolidation (if desired)
   - Update documentation
   - Final checkpoint

### Risk Mitigation

**Before Each Phase**:

- ✅ Create git branch for changes
- ✅ Run all tests to establish baseline
- ✅ Document current behavior

**During Implementation**:

- ✅ Make one change at a time
- ✅ Run tests after each change
- ✅ Revert if tests fail

**After Each Phase**:

- ✅ Full test suite validation (44/44 passing)
- ✅ Git commit with detailed message
- ✅ Update this document with completion status

### Success Metrics

**Phase 1 Success**:

- [ ] All runners use same initialization file (or documented specialized variants)
- [ ] Zero inline initialization configs
- [ ] All 44 tests still passing
- [ ] No vim.inspect errors on Neovim 0.10+

**Phase 2 Success**:

- [ ] No duplicated helper functions
- [ ] Single authoritative source for each pattern
- [ ] Helper usage guide created
- [ ] All tests using consolidated helpers

**Phase 3 Success**:

- [ ] Zero hardcoded test lists
- [ ] New tests automatically discovered
- [ ] Test count matches before/after
- [ ] All categories using auto-discovery

**Phase 4 Success**:

- [ ] Coverage calculated from actual test output
- [ ] Metrics accurate and up-to-date
- [ ] Reporting shows actual pass/fail counts

**Overall Success**:

- [ ] Test reliability improved (consistent environment)
- [ ] Maintenance burden reduced (auto-discovery, single source)
- [ ] Code quality improved (no duplication)
- [ ] All 44 tests passing
- [ ] Documentation updated

______________________________________________________________________

## Conclusion

The PercyBrain test suite demonstrates strong organization with 44/44 passing tests and thoughtful categorization (capability, contract, unit, integration, performance, regression, health). However, **critical test initialization fragmentation** creates inconsistent test environments that risk reliability.

**Top Priority**: Consolidate five different initialization configs into single source of truth (`tests/minimal_init.lua`). This single change will improve test reliability, reduce maintenance burden, and eliminate environment inconsistencies.

**Secondary Priorities**: Helper consolidation and test auto-discovery will further reduce maintenance overhead and improve code quality.

**Timeline**: Phases 1-3 can be completed in 3 weeks with low risk. Phases 4-5 are optional polish for incremental improvements.

**Recommendation**: Proceed with Phase 1 immediately to address critical reliability issue, then evaluate Phase 2-3 based on available time and priority.

______________________________________________________________________

## Appendix: File Reference

### Test Runners (7 total)

- `tests/run-unit-tests.sh` (89 lines) - Core unit tests, uses correct init
- `tests/run-all-unit-tests.sh` (309 lines) - All unit tests with coverage, **has inline init**
- `tests/run-keymap-tests.sh` (54 lines) - Keymap tests, uses correct init
- `tests/run-integration-tests.sh` (303 lines) - Integration tests, **has inline init**
- `tests/run-health-tests.sh` (130 lines) - Health validation, **no init flag**
- `tests/run-ollama-tests.sh` (~100 lines) - AI tests, **has inline init**
- `tests/simple-test.sh` - Not examined

### Initialization Files

- `tests/minimal_init.lua` (157 lines) - Authoritative test initialization ✅
- `/tmp/minimal_test_init.lua` (31 lines inline) - Incomplete subset ❌
- `/tmp/test_init.lua` (inline) - Unknown content ❌
- `integration_minimal_init.lua` (15 lines inline) - Bare bones ❌

### Helper Files (11 total)

- `tests/helpers/init.lua` (2.7KB) - Common utilities, **has wait_for duplication**
- `tests/helpers/async_helpers.lua` (5.2KB, 214 lines) - Async operations, **robust wait_for**
- `tests/helpers/environment_setup.lua` (3.6KB) - Vault creation
- `tests/helpers/gtd_test_helpers.lua` - GTD-specific helpers
- `tests/helpers/keymap_test_helpers.lua` - Keymap-specific helpers
- `tests/helpers/workflow_builders.lua` - Integration test builders
- `tests/helpers/mock_services.lua` - Service mocking
- `tests/helpers/assertions.lua` - Custom assertions
- Others not examined in detail

### Test Categories (42 spec files total)

- `capability/` - User behavioral tests
- `contract/` - System specification tests
- `unit/` - Isolated function tests (config, core, globals, keymaps, options, window_manager, treesitter, zettelkasten, + subdirs: ai/, gtd/, keymap/, sembr/, zettelkasten/)
- `integration/` - Cross-module tests
- `performance/` - Benchmarking
- `regression/` - Bug prevention
- `health/` - Health validation

______________________________________________________________________

**Analysis Complete**: 2025-10-21 **Next Action**: Review recommendations with maintainer **Estimated Implementation**: 3-4 weeks for Phases 1-3
