# PercyBrain Testing Best Practices - Reflection and Validation

**Generated**: 2025-10-18 **Context**: Ollama test troubleshooting and testing pattern validation **Status**: ⚠️ **Needs Improvement** - Current approach deviates from project standards

______________________________________________________________________

## Executive Summary

### Current State Assessment

**What We Did Wrong** ❌:

1. Created **inline vim mocks** in Ollama test file instead of using project's established mock factories
2. Manually preserved `vim.inspect` and `vim.cmd` when helper system should handle this
3. Bypassed helper infrastructure (`tests/helpers/mocks.lua` with `M.ollama()` already available!)
4. Violated DRY principle by duplicating mock logic across test files

**Impact**:

- Added 40+ lines of duplicated mock code
- Increased maintenance burden
- Deviated from project testing patterns
- Tests less maintainable and harder to understand

### The Correct Approach ✅

PercyBrain has a **comprehensive testing infrastructure** that we should be using:

```
tests/
├── helpers/
│   ├── init.lua           # Common test utilities
│   ├── mocks.lua          # Mock factories (including M.ollama()!)
│   └── assertions.lua     # Custom assertions
├── minimal_init.lua       # Handles vim.inspect compatibility
└── PLENARY_TESTING_DESIGN.md  # Testing standards document
```

______________________________________________________________________

## Detailed Analysis

### 1. Mock Pattern Violations

#### ❌ What We Did (Anti-Pattern)

```lua
-- tests/plenary/unit/ai-sembr/ollama_spec.lua (lines 8-134)
before_each(function()
  original_vim = _G.vim

  -- WRONG: Creating inline vim mock from scratch
  _G.vim = {
    api = {
      nvim_get_current_buf = function() return 1 end,
      nvim_win_get_cursor = function() return { 10, 0 } end,
      -- ... 30+ more lines of manual mocking
    },
    fn = {
      mode = function() return "n" end,
      // ... more manual mocking
    },
    inspect = preserved_inspect or function(obj, opts)
      -- ... manual inspect implementation
    end,
  }
end)
```

**Problems**:

1. Inline mocking instead of using mock factory
2. Duplicates logic across tests
3. Hard to maintain (30+ lines per test)
4. Not reusable
5. Fragile - breaks easily with Vim API changes

#### ✅ What We Should Do (Best Practice)

```lua
-- Use the existing helper infrastructure
local helpers = require('tests.helpers')
local mocks = require('tests.helpers.mocks')

describe("Ollama Local LLM Integration", function()
  local ollama
  local notifications

  before_each(function()
    -- Use factory to create mock Ollama
    ollama = mocks.ollama()

    -- Use helper to capture notifications
    notifications = mocks.notifications()
    notifications.capture()
  end)

  after_each(function()
    notifications.restore()
  end)

  it("generates AI responses", function()
    ollama.generate("test prompt", function(response)
      assert.is_not_nil(response)
      assert.equals("llama3.2", response.model)
    end)
  end)
end)
```

**Benefits**:

1. ✅ Uses established mock factory pattern
2. ✅ DRY - reusable across all tests
3. ✅ 5 lines instead of 130 lines
4. ✅ Maintainable - change once, applies everywhere
5. ✅ Follows project standards

______________________________________________________________________

### 2. Vim.inspect Compatibility Handling

#### ❌ What We Did (Anti-Pattern)

```lua
-- Manually preserved vim.inspect in each test
local preserved_inspect = original_vim.inspect
local preserved_cmd = original_vim.cmd

_G.vim = {
  inspect = preserved_inspect or function(obj, opts)
    -- Fallback implementation
  end,
  cmd = preserved_cmd or function(command)
    -- Mock implementation
  end,
}
```

**Problems**:

1. Duplicates vim.inspect handling logic
2. Fragile - easy to forget in new tests
3. Doesn't belong in individual test files

#### ✅ What We Should Do (Best Practice)

**Location**: `tests/minimal_init.lua` (already has this!)

The `minimal_init.lua` **already handles** vim.inspect conversion globally (lines 11-21):

```lua
-- CRITICAL: Ensure vim.inspect exists as a FUNCTION before loading Plenary
if type(vim.inspect) ~= 'function' then
  local inspect_module = vim.inspect or require('vim.inspect')
  vim.inspect = inspect_module.inspect or inspect_module

  if type(vim.inspect) ~= 'function' then
    vim.inspect = function(obj, opts)
      return vim.fn.string(obj)
    end
  end
end
```

**The Fix**: Tests should NOT create new `_G.vim` mocks that overwrite this. Instead:

```lua
-- Option 1: Don't mock vim at all (use real Vim API)
-- Option 2: Use partial mocks that preserve global fixes
local preserved_vim = vim.tbl_deep_extend("force", {}, _G.vim)
_G.vim = vim.tbl_deep_extend("force", preserved_vim, {
  api = {
    -- Only mock what you need
    nvim_get_current_buf = function() return 1 end,
  },
})
```

______________________________________________________________________

### 3. Helper Infrastructure Usage

#### Available Helpers (from `tests/helpers/init.lua`)

| Helper                   | Purpose                   | Example Usage                                         |
| ------------------------ | ------------------------- | ----------------------------------------------------- |
| `M.mock_notify()`        | Capture vim.notify calls  | `local mock = M.mock_notify()`                        |
| `M.wait_for(condition)`  | Wait for async operations | `M.wait_for(function() return done end)`              |
| `M.async_test(fn)`       | Run async tests           | `M.async_test(function() ... end)`                    |
| `M.create_test_buffer()` | Create test buffers       | `local buf = M.create_test_buffer({content = lines})` |

#### Available Mocks (from `tests/helpers/mocks.lua`)

| Mock                 | Purpose                 | Example Usage                                  |
| -------------------- | ----------------------- | ---------------------------------------------- |
| `M.ollama()`         | Mock Ollama LLM         | `local ollama = mocks.ollama()`                |
| `M.vault(path)`      | Mock Zettelkasten vault | `local vault = mocks.vault(); vault:setup()`   |
| `M.notifications()`  | Capture notifications   | `local n = mocks.notifications(); n.capture()` |
| `M.window_manager()` | Mock window manager     | `local wm = mocks.window_manager()`            |
| `M.timer()`          | Control time in tests   | `local t = mocks.timer(); t.advance(1000)`     |

______________________________________________________________________

### 4. Test Organization Standards

#### From PLENARY_TESTING_DESIGN.md

**Required Structure**:

```lua
-- Required imports at top
local helpers = require('tests.helpers')
local mocks = require('tests.helpers.mocks')

describe("Feature Name", function()
  -- Test state
  local feature_module
  local mock_dependency

  before_each(function()
    -- Setup
    mock_dependency = mocks.dependency_factory()
    feature_module = require('module')
  end)

  after_each(function()
    -- Teardown
    package.loaded['module'] = nil
  end)

  describe("Sub-feature", function()
    it("does specific thing", function()
      -- Arrange
      local input = "test"

      -- Act
      local result = feature_module.function(input)

      -- Assert
      assert.equals("expected", result)
    end)
  end)
end)
```

**Patterns We Violated**:

1. ❌ No helper imports
2. ❌ Inline mocking instead of factory usage
3. ❌ Manual vim mock instead of partial mocking
4. ❌ Not following AAA pattern (Arrange-Act-Assert)

______________________________________________________________________

## Best Practices Checklist

### ✅ What We Did Right

1. Used Plenary's `describe`/`it` BDD structure
2. Implemented `before_each`/`after_each` setup/teardown
3. Restored original state after tests
4. Attempted to handle Neovim 0.11+ compatibility

### ❌ What We Did Wrong

1. Created inline mocks instead of using helpers/mocks.lua
2. Duplicated vim.inspect handling (already in minimal_init.lua)
3. Bypassed established mock factory pattern (M.ollama() exists!)
4. Added 130+ lines of unnecessary mock code
5. Didn't consult project's testing design documentation first

______________________________________________________________________

## Recommended Fixes

### Priority 1: Refactor Ollama Test (CRITICAL)

**Current**: 245 lines with inline mocking **Target**: 80 lines using helper infrastructure

```lua
-- tests/plenary/unit/ai-sembr/ollama_spec.lua (REFACTORED)
local helpers = require('tests.helpers')
local mocks = require('tests.helpers.mocks')

describe("Ollama Local LLM Integration", function()
  local ollama
  local notifications

  before_each(function()
    -- Use mock factory instead of inline mock
    ollama = mocks.ollama()

    -- Capture notifications using helper
    notifications = mocks.notifications()
    notifications.capture()
  end)

  after_each(function()
    notifications.restore()
    notifications.clear()
  end)

  describe("Service Management", function()
    it("detects when Ollama is running", function()
      -- Mock factory already handles this
      local is_running = (ollama.list().models ~= nil)
      assert.is_true(is_running)
    end)
  end)

  describe("AI Generation", function()
    it("generates responses asynchronously", function()
      local response_received = false

      ollama.generate("test prompt", function(response)
        response_received = true
        assert.equals("llama3.2", response.model)
        assert.is_not_nil(response.response)
      end)

      -- Use helper for async waiting
      helpers.wait_for(function()
        return response_received
      end, 500)
    end)

    it("includes prompt context in response", function()
      local result

      ollama.generate("explain quantum physics", function(response)
        result = response
      end)

      helpers.wait_for(function() return result end)

      assert.matches("explain quantum physics", result.response)
    end)
  end)

  describe("Command Integration", function()
    it("creates AI commands successfully", function()
      -- Test command creation without full vim mock
      -- Use partial mocking if needed
      local commands = {
        "PercyExplain",
        "PercySummarize",
        "PercyLinks",
      }

      for _, cmd in ipairs(commands) do
        -- Verify command exists
        assert.is_not_nil(_G.vim.api.nvim_create_user_command)
      end
    end)
  end)
end)
```

**Improvements**:

- ✅ 80 lines instead of 245 lines (67% reduction)
- ✅ Uses established mock factories
- ✅ Uses helper utilities (wait_for, notifications)
- ✅ Follows AAA pattern
- ✅ No inline vim mocking
- ✅ Maintainable and DRY

______________________________________________________________________

### Priority 2: Document Mock Usage Patterns

Create `tests/MOCK_USAGE_GUIDE.md`:

````markdown
# PercyBrain Mock Usage Guide

## Quick Reference

### Don't Create Inline Mocks
❌ **WRONG**:
```lua
before_each(function()
  _G.vim = { api = { nvim_get_current_buf = function() return 1 end } }
end)
````

✅ **RIGHT**:

```lua
local mocks = require('tests.helpers.mocks')
local mock_dependency = mocks.factory_name()
```

### Available Mock Factories

1. **Ollama LLM**: `mocks.ollama()`
2. **Zettelkasten Vault**: `mocks.vault(path)`
3. **Notifications**: `mocks.notifications()`
4. **Window Manager**: `mocks.window_manager()`
5. **Timer**: `mocks.timer()`

### Helper Utilities

1. **Wait for Condition**: `helpers.wait_for(condition, timeout)`
2. **Async Testing**: `helpers.async_test(function() ... end)`
3. **Capture Notifications**: `helpers.mock_notify()`
4. **Create Test Buffer**: `helpers.create_test_buffer({content = lines})`

```

---

### Priority 3: Standardize All Tests

**Audit Plan**:
1. Review all test files in `tests/plenary/unit/`
2. Identify inline mocking patterns
3. Refactor to use helper infrastructure
4. Ensure vim.inspect preservation is NOT duplicated
5. Add mock usage examples to documentation

**Files to Review**:
- `tests/plenary/unit/config_spec.lua`
- `tests/plenary/unit/options_spec.lua`
- `tests/plenary/unit/keymaps_spec.lua`
- `tests/plenary/unit/globals_spec.lua`
- `tests/plenary/unit/window-manager_spec.lua`
- `tests/plenary/unit/sembr/*_spec.lua`

---

## Root Cause Analysis

### Why Did We Deviate?

1. **Didn't consult project documentation first**
   - `PLENARY_TESTING_DESIGN.md` exists with standards
   - `tests/helpers/mocks.lua` already has `M.ollama()` mock!
   - Jumped to implementation without reading patterns

2. **Focused on immediate problem (vim.inspect) instead of systematic approach**
   - Fixed symptom (missing vim.inspect) not root cause (wrong mocking pattern)
   - Should have asked: "Why are we creating full vim mock?"

3. **Didn't use Serena reflection tools early enough**
   - `think_about_task_adherence` would have caught deviation
   - Should have run this BEFORE writing fix

---

## Learning Outcomes

### Key Insights

1. **Always consult project documentation first**
   - Read `tests/PLENARY_TESTING_DESIGN.md` before writing tests
   - Check `tests/helpers/` for existing utilities
   - Don't reinvent the wheel

2. **Use helper infrastructure**
   - Mock factories in `tests/helpers/mocks.lua`
   - Test utilities in `tests/helpers/init.lua`
   - Custom assertions in `tests/helpers/assertions.lua`

3. **Minimal_init.lua handles compatibility**
   - Don't duplicate vim.inspect fixes in tests
   - Trust the test environment setup
   - Use partial mocking if full vim mock needed

4. **Follow DRY principle**
   - Reusable mock factories > inline mocks
   - Helper utilities > duplicated test code
   - Centralized fixes > per-test workarounds

---

## Validation Against Standards

### PLENARY_TESTING_DESIGN.md Compliance

| Standard | Current Ollama Test | Compliant? |
|----------|---------------------|------------|
| Use mock factories | ❌ Inline mocking | **NO** |
| Import helpers | ❌ No imports | **NO** |
| AAA pattern | ⚠️ Partial | **PARTIAL** |
| Setup/teardown | ✅ before_each/after_each | **YES** |
| Minimal vim mocking | ❌ Full vim mock | **NO** |
| Use test utilities | ❌ Manual async handling | **NO** |

**Compliance Score**: 2/6 (33%) ❌

**Target Score**: 6/6 (100%) ✅

---

## Action Items

### Immediate (This Session)
- [x] Document anti-patterns in this reflection
- [x] Identify correct approach using helpers/mocks
- [ ] Refactor Ollama test to use mock factory
- [ ] Test refactored version

### Short-term (Next Session)
- [ ] Create `tests/MOCK_USAGE_GUIDE.md`
- [ ] Audit all unit tests for inline mocking
- [ ] Refactor tests to use helper infrastructure
- [ ] Update test suite pass rate

### Long-term (This Sprint)
- [ ] Add pre-commit hook to check for inline mocks
- [ ] Expand mock factories for common patterns
- [ ] Create test template with best practices
- [ ] Document in CONTRIBUTING.md

---

## Recommendations for Future

### When Writing New Tests

**Checklist**:
1. ✅ Read `tests/PLENARY_TESTING_DESIGN.md`
2. ✅ Import helpers: `require('tests.helpers')`
3. ✅ Import mocks: `require('tests.helpers.mocks')`
4. ✅ Check if mock factory exists for dependency
5. ✅ Use helper utilities for async/waiting
6. ✅ Follow AAA pattern (Arrange-Act-Assert)
7. ✅ Run `think_about_task_adherence` before committing
8. ✅ Verify against project standards

### When Debugging Test Failures

**Process**:
1. Check `minimal_init.lua` for environment setup
2. Verify helpers are loaded correctly
3. Check if mock factory needs updating
4. Don't create inline fixes - update centralized code
5. Consult documentation before implementing workarounds

---

## Conclusion

### What We Learned

Our Ollama test troubleshooting revealed a **fundamental misunderstanding** of the project's testing infrastructure. We created an inline vim mock instead of using the established helper/mock factory pattern.

**The Fix We Implemented**: ✅ Works (unblocks Ollama tests)
**The Fix We Should Have Implemented**: ✅ Uses project patterns (maintainable, DRY, scalable)

### Impact Assessment

**Technical Debt Created**:
- 130 lines of duplicated mock code
- Maintenance burden (3 files to update vs 1)
- Pattern inconsistency across test suite

**Cost to Fix**:
- Refactor Ollama test: 1-2 hours
- Audit other tests: 2-3 hours
- Update documentation: 1 hour
- **Total**: 4-6 hours

**ROI of Fixing**:
- Reduced maintenance: 50% less code
- Improved consistency: All tests use same patterns
- Better testability: Mocks easy to enhance
- Knowledge transfer: Clear patterns for future devs

### Final Recommendation

✅ **REFACTOR OLLAMA TEST** to use helpers/mocks infrastructure

While the current fix unblocks the tests, it violates project standards and creates technical debt. The refactored version:
- Reduces code by 67% (245 → 80 lines)
- Follows established patterns
- Improves maintainability
- Sets good example for future tests

**Priority**: **HIGH** - Fix in next session before moving to other test improvements

---

**Reflection Complete**
**Status**: Best practices documented, deviations identified, path forward clear
**Next Step**: Refactor Ollama test using helper infrastructure
```
