# Issue #6: Keymap Centralization Phase 3 - Refactoring

**Labels:** `refactor`, `code-quality`, `keymaps`, `medium-priority`

## Description

Improve code quality of keymap centralization system while maintaining all 37 passing test assertions.

## Context

- Phase 1 (RED): Test suite created ✅
- Phase 2 (GREEN): All tests passing ✅
- Phase 3 (REFACTOR): Improve code quality ⏳ NOT STARTED

## Requirements

1. Split monolithic test file into 5 focused modules
2. Extract helper functions for DRY code
3. Add comprehensive module documentation with LuaCATS
4. Ensure pattern consistency across all 14 keymap modules
5. Create template for new keymap modules

## Acceptance Criteria

- [ ] Test suite reorganized: 37 assertions across 5 files
- [ ] Helper functions extracted: `window_notifications.lua` created
- [ ] All 14 modules have comprehensive docstrings
- [ ] LuaCATS type annotations added for KeymapEntry
- [ ] Template file created: `lua/config/keymaps/_TEMPLATE.lua`
- [ ] All 37 tests still passing (no regressions)
- [ ] Code reduction: ~30% in window.lua via helpers

## Implementation Tasks

### 1. Test Organization (Priority: HIGH)

Create `tests/unit/keymap/` directory and split into:

- `cleanup_spec.lua` (4 assertions)

  - Test cleanup on disable
  - Test cleanup with namespaces
  - Test auto-cleanup on module updates
  - Test namespace preservation

- `loading_spec.lua` (16 assertions)

  - Test basic loading
  - Test namespaced loading
  - Test conditional loading
  - Test lazy loading
  - Test error handling

- `registry_spec.lua` (2 assertions)

  - Test conflict detection
  - Test namespace validation

- `syntax_spec.lua` (14 assertions)

  - Test entry format validation
  - Test keymap syntax
  - Test description requirements
  - Test mode specifications

- `namespace_spec.lua` (1 assertion)

  - Test namespace allocation

### 2. Helper Extraction (Priority: HIGH)

Create `lua/config/keymaps/helpers/window_notifications.lua`:

```lua
local M = {}

--- Execute window command with notification
--- @param cmd string Window command to execute
--- @param message string Notification message
--- @param level? string Log level (default: INFO)
function M.with_notification(cmd, message, level)
  level = level or vim.log.levels.INFO
  vim.cmd(cmd)
  vim.notify(message, level)
end

return M
```

Refactor `window.lua` to use helper (~30% code reduction).

### 3. Documentation (Priority: HIGH)

Add to all 14 modules:

- LuaCATS type annotations
- Module-level docstrings
- Namespace allocation documentation
- Complete keymap listings with descriptions

### 4. Pattern Consistency (Priority: MEDIUM)

Audit all modules against template for:

- Variable naming conventions
- Comment style and emoji usage
- Error handling patterns
- Return value consistency

### 5. Template Creation (Priority: MEDIUM)

Create `lua/config/keymaps/_TEMPLATE.lua` with:

- Boilerplate structure
- Documentation examples
- Best practices
- Common patterns

## Testing Strategy

- Run full test suite after each refactoring step
- Verify 37 assertions still passing
- No performance regression (timing unchanged)
- Validate helper function coverage

## Estimated Effort

3-5 hours

## Related Files

- `tests/unit/keymap_centralization_spec.lua` (SPLIT into 5 files)
- `lua/config/keymaps/window.lua` (REFACTOR)
- `lua/config/keymaps/helpers/` (NEW directory)
- `lua/config/keymaps/_TEMPLATE.lua` (NEW)
- `claudedocs/KEYMAP_REFACTORING_PHASE3_PLAN.md` (REFERENCE - to be deleted)
