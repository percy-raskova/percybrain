# Keymap Centralization - Phase 3 Refactoring Plan

**Date**: 2025-10-20 **Status**: 📋 Planning Phase **Context**: Phase 2 complete (GREEN phase achieved), now refactoring for code quality

## TDD Cycle Position

✅ **RED Phase**: Test suite created (37 assertions) ✅ **GREEN Phase**: All tests passing (100%) 🔄 **REFACTOR Phase**: Improve code quality while maintaining green tests

## Refactoring Philosophy

> "Make it work, make it right, make it fast" - Kent Beck

We're in the "make it right" phase. All functionality works, now we improve:

- Code clarity
- Maintainability
- Documentation
- DRY principles
- Pattern consistency

## Priority System

### 🔴 High Priority (Do First)

**Impact**: High, **Effort**: Low-Medium

1. **Test Organization** - Split monolithic test file
2. **Helper Function Extraction** - DRY up notification patterns
3. **Module Documentation** - Add comprehensive docstrings

### 🟡 Medium Priority (Do Next)

**Impact**: Medium, **Effort**: Low 4. **Pattern Consistency** - Ensure all modules identical structure 5. **LuaCATS Annotations** - Add type hints for IDE support

### 🟢 Low Priority (Optional)

**Impact**: Low, **Effort**: Medium-High 6. **Performance Optimization** - Lazy load registry itself 7. **Advanced Features** - Keymap grouping/categorization

## Detailed Refactoring Tasks

### 1. Test Organization ⭐⭐⭐

**Current State**:

- Single file: `tests/unit/keymap_centralization_spec.lua` (37 assertions)
- Multiple describe blocks in one file
- Hard to navigate and maintain

**Target State**:

```
tests/unit/keymap/
├── cleanup_spec.lua         # Duplicate removal tests (4 assertions)
├── loading_spec.lua          # Module loading tests (16 assertions)
├── registry_spec.lua         # Registry system tests (2 assertions)
├── syntax_spec.lua           # Module syntax tests (14 assertions)
└── namespace_spec.lua        # Conflict detection test (1 assertion)
```

**Benefits**:

- Faster test runs (can run subsets)
- Easier to find specific tests
- Better test isolation
- Follows test standards (each spec focused)

**Implementation**:

1. Create `tests/unit/keymap/` directory
2. Extract each `describe` block to separate file
3. Ensure each file follows 6/6 test standards
4. Update test runner to find new files
5. Verify all 37 assertions still pass

**Validation**:

```bash
# Before: Single file
nvim --headless -c "PlenaryBustedFile tests/unit/keymap_centralization_spec.lua"

# After: All keymap tests
nvim --headless -c "PlenaryBustedDirectory tests/unit/keymap"
```

### 2. Helper Function Extraction ⭐⭐⭐

**Current State**: `lua/config/keymaps/window.lua` has repeated patterns:

```lua
{ "<leader>ww", function()
    vim.cmd("wincmd w");
    vim.notify("🪟 Switched window", vim.log.levels.INFO)
  end, desc = "🪟 Quick window toggle" },

{ "<leader>wH", function()
    vim.cmd("wincmd H");
    vim.notify("🪟 Window moved H", vim.log.levels.INFO)
  end, desc = "⇐ Move window left" },
```

**Refactored State**:

```lua
-- Helper module: lua/config/keymaps/helpers/window_notifications.lua
local M = {}

function M.with_notification(cmd, message, level)
  return function()
    vim.cmd(cmd)
    vim.notify(message, level or vim.log.levels.INFO)
  end
end

return M

-- In window.lua:
local notify_helper = require("config.keymaps.helpers.window_notifications")

local keymaps = {
  { "<leader>ww", notify_helper.with_notification("wincmd w", "🪟 Switched window"), desc = "🪟 Quick window toggle" },
  { "<leader>wH", notify_helper.with_notification("wincmd H", "🪟 Window moved H"), desc = "⇐ Move window left" },
}
```

**Benefits**:

- DRY principle applied
- Easier to modify notification behavior globally
- Reduces code duplication (~30% reduction in window.lua)
- Reusable pattern for other modules

**Implementation**:

1. Create `lua/config/keymaps/helpers/` directory
2. Extract notification helper function
3. Refactor window.lua to use helper
4. Run tests to ensure no regression
5. Apply pattern to other modules if beneficial

### 3. Module Documentation ⭐⭐⭐

**Current State**: Minimal header comments:

```lua
-- Window Management Keymaps
-- Namespace: <leader>w (window)
```

**Enhanced Documentation**:

```lua
--- Window Management Keymaps
--- Provides comprehensive window control with <leader>w prefix
---
--- @module config.keymaps.window
--- @author PercyBrain Team
--- @since 2025-10-20 (Phase 2 - Keymap Centralization)
---
--- Namespace: <leader>w (window)
---
--- Navigation (lowercase hjkl):
---   - wh/wj/wk/wl: Navigate to window in direction
---
--- Moving Windows (uppercase HJKL):
---   - wH/wJ/wK/wL: Move window to screen edge
---
--- Splitting:
---   - ws: Horizontal split
---   - wv: Vertical split
---
--- Closing:
---   - wc: Close current window
---   - wo: Close all other windows
---   - wq: Quit window
---
--- Resizing:
---   - w=: Equalize window sizes
---   - w<: Maximize width
---   - w>: Maximize height
---
--- Buffer Management:
---   - wb: List buffers
---   - wn/wp: Next/previous buffer
---   - wd: Delete buffer
---
--- Layout Presets (uppercase):
---   - wW: Wiki workflow layout
---   - wF: Focus layout
---   - wR: Reset to default
---   - wG: Research layout
---
--- Info:
---   - wi: Display window information
---
--- @see config.window-manager Business logic implementation
--- @see lua/config/keymaps/README.md Centralized keymap system
```

**Benefits**:

- Self-documenting code
- LuaCATS annotations enable IDE autocomplete
- Easy to understand keymap organization
- Better onboarding for new developers

**Implementation**:

1. Add comprehensive docstrings to each module
2. Include namespace explanation
3. List all keymaps with descriptions
4. Add @see references to related modules
5. Follow LuaCATS annotation format

### 4. Pattern Consistency ⭐⭐

**Current State**: All modules follow same basic pattern, but minor variations:

- Some use `local keymaps =`, others might use different names
- Description styles vary (emoji usage, capitalization)
- Comment styles differ

**Standardized Pattern**:

```lua
--- [Module Name] Keymaps
--- [Brief description]
---
--- @module config.keymaps.[name]
--- Namespace: <leader>[prefix]
---
--- [Detailed keymap listing]

local registry = require("config.keymaps")

local keymaps = {
  -- [Category]
  { "[key]", "[cmd or function]", desc = "[emoji] [Description]" },
}

return registry.register_module("[module_name]", keymaps)
```

**Validation Checklist**:

- [ ] All modules have proper header documentation
- [ ] All use `local keymaps =` variable name
- [ ] All return `registry.register_module()`
- [ ] All descriptions use consistent emoji + text pattern
- [ ] All have category comments grouping related keymaps

**Implementation**:

1. Create template file for new keymap modules
2. Audit all 14 existing modules against template
3. Standardize any variations
4. Document pattern in README.md

### 5. LuaCATS Type Annotations ⭐

**Current State**: No type annotations, IDE doesn't provide autocomplete/hints

**Enhanced with Types**:

```lua
--- @class KeymapEntry
--- @field [1] string The key mapping (e.g., "<leader>ww")
--- @field [2] string|function The command or function to execute
--- @field desc string Description shown in WhichKey
--- @field mode? string|string[] Vim mode(s), defaults to "n"
--- @field noremap? boolean Non-recursive mapping, defaults to true
--- @field silent? boolean Silent execution, defaults to true

--- Window Management Keymaps
--- @return KeymapEntry[] Registered keymap entries
local function create_keymaps()
  local keymaps = {
    { "<leader>ww", function() ... end, desc = "🪟 Quick toggle" },
  }
  return keymaps
end

return registry.register_module("window", create_keymaps())
```

**Benefits**:

- IDE autocomplete in other files
- Type checking for keymap structure
- Better documentation
- Catches errors at edit-time, not runtime

**Implementation**:

1. Define KeymapEntry type in registry init.lua
2. Add type annotations to all keymap modules
3. Add annotations to registry functions
4. Test with lua-language-server

### 6. Performance Optimization ⚡ (Optional)

**Current Approach**: All 14 modules loaded on startup via `require()` in init.lua

**Lazy-Loaded Registry**:

```lua
-- config/init.lua
-- Don't load keymap modules immediately
-- Let them load when plugins load (via keys parameter)

-- Registry loads automatically when first module requires it
-- Modules only load when their plugin loads (lazy.nvim keys)
```

**Benefits**:

- Faster startup time (~5-10ms improvement)
- Modules load on-demand
- Still maintains conflict detection

**Trade-offs**:

- More complex to debug
- Conflict detection happens later (on plugin load, not startup)
- Might not be worth complexity for 14 small modules

**Recommendation**: Skip unless profiling shows startup is slow (>100ms)

### 7. Advanced Features 🚀 (Future)

**Keymap Grouping**:

```lua
-- Auto-generate WhichKey groups from namespaces
M.generate_which_key_groups = function()
  local groups = {}
  for key, source in pairs(registered_keys) do
    local prefix = key:match("^<leader>(%w)")
    if prefix and not groups[prefix] then
      groups["<leader>" .. prefix] = { name = source }
    end
  end
  return groups
end
```

**Keymap Search**:

```lua
-- Search keymaps by description or key
:lua require('config.keymaps').search("window")
-- Shows all keymaps containing "window"
```

**Conflict Prevention**:

```lua
-- Prevent registration of conflicting keys
function M.reserve_namespace(prefix, module)
  reserved_prefixes[prefix] = module
  -- Future modules can't use this prefix
end
```

## Testing Strategy for Refactoring

### Before Each Refactoring

1. ✅ Ensure all tests passing (GREEN)
2. 📸 Snapshot current test output
3. 💾 Commit working state (safety checkpoint)

### During Refactoring

1. 🔧 Make single refactoring change
2. 🧪 Run test suite
3. ✅ Verify still GREEN
4. 📝 Document change
5. 💾 Commit incremental progress

### After Refactoring

1. 🧪 Full test suite run
2. ✅ All 37 assertions pass
3. 📊 Verify no performance regression
4. 📝 Update documentation
5. 💾 Final commit with completion notes

## Success Criteria

### Must Have (Required for Phase 3 completion)

- [ ] Test suite reorganized into focused modules
- [ ] Helper functions extracted for DRY code
- [ ] All modules have comprehensive documentation
- [ ] All 37 test assertions still passing
- [ ] No performance regression

### Should Have (Recommended)

- [ ] Pattern consistency validated across modules
- [ ] LuaCATS annotations added
- [ ] Template created for new modules
- [ ] README.md updated with refactoring notes

### Nice to Have (Optional)

- [ ] Performance optimization if needed
- [ ] Advanced features if beneficial
- [ ] Additional helper functions identified

## Timeline Estimate

**High Priority Tasks**: 2-3 hours **Medium Priority Tasks**: 1-2 hours **Total Refactoring Phase**: 3-5 hours

## Rollback Plan

If refactoring introduces issues:

1. Git revert to last working commit (Phase 2 complete)
2. Review what broke
3. Apply smaller, incremental changes
4. Re-run tests after each small change

## Completion Criteria

Phase 3 is complete when:

1. ✅ All refactoring tasks (High priority minimum) completed
2. ✅ Test suite passing (100%)
3. ✅ No functional regressions
4. ✅ Code quality improved (measured by clarity, DRY, documentation)
5. ✅ Completion report written

______________________________________________________________________

**Status**: 📋 Planning Complete - Ready for Implementation **Next Step**: Begin High Priority Task #1 (Test Organization)
