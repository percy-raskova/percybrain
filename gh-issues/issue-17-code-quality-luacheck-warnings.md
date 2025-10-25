# Issue #17: Code Quality Cleanup - Pre-existing Luacheck Warnings

## Description

Fix 5 pre-existing luacheck warnings identified during Phase 3 Telekasten migration validation. These warnings are not migration-related but represent technical debt that should be addressed for code quality.

## Context

**Source**: `PHASE3_COMPLETION_TELEKASTEN_IWE_MIGRATION.md` (lines 38-44)

**Current State**: 5 luacheck warnings (all pre-existing, none in migration code) **Target State**: 0 luacheck warnings, clean static analysis

**Severity**: LOW - Pre-existing issues, not blocking functionality

## Value

- Clean static analysis (0 warnings)
- Improved code maintainability
- Professional code quality standards
- Easier to spot new issues

## Tasks

### Task 1: Fix Git Keymap Shadowing Warnings

**Files**: `lua/config/keymaps/tools/git.lua` (lines 125, 133) **Estimated**: 5 minutes **Context Window**: Tiny - two line fixes

**Warning**:

```
lua/config/keymaps/tools/git.lua:125:31: (W211) shadowing upvalue 'mode'
lua/config/keymaps/tools/git.lua:133:31: (W211) shadowing upvalue 'mode'
```

**Problem**: Variable `mode` is shadowing an upvalue (defined in outer scope)

**Implementation**:

1. Read context around lines 125 and 133:

```bash
sed -n '120,140p' lua/config/keymaps/tools/git.lua
```

2. Likely pattern:

```lua
-- Line 120 (outer scope)
local mode = "n"

-- Line 125 (inner scope - SHADOWING)
local function some_func(mode)  -- This shadows outer 'mode'
  -- ...
end

-- Line 133 (inner scope - SHADOWING)
local function another_func(mode)  -- This shadows outer 'mode'
  -- ...
end
```

3. **Fix**: Rename inner parameter to avoid shadowing:

```lua
-- Line 125 fix
local function some_func(keymap_mode)  -- Renamed from 'mode'
  -- Update all references inside function
end

-- Line 133 fix
local function another_func(keymap_mode)  -- Renamed from 'mode'
  -- Update all references inside function
end
```

**Validation**:

```bash
mise lint | grep git.lua
# Should show 0 warnings for git.lua
```

**Acceptance Criteria**:

- [ ] Both shadowing warnings resolved
- [ ] Variable renamed to `keymap_mode` (or similar descriptive name)
- [ ] All references inside functions updated
- [ ] Git keybindings still work correctly
- [ ] Luacheck passes with 0 warnings for this file

______________________________________________________________________

### Task 2: Fix Utilities Unused Variable Warning

**File**: `lua/config/keymaps/utilities.lua` (line 33) **Estimated**: 3 minutes **Context Window**: Tiny - single line fix

**Warning**:

```
lua/config/keymaps/utilities.lua:33:10: (W211) unused variable 'count'
```

**Problem**: Variable `count` is defined but never used

**Implementation**:

1. Read context around line 33:

```bash
sed -n '28,38p' lua/config/keymaps/utilities.lua
```

2. Likely pattern:

```lua
local count = vim.v.count  -- Defined but not used
```

3. **Fix Options**:

   **Option A**: If truly unused, remove it:

   ```lua
   -- Just delete the line
   ```

   **Option B**: If it should be used, prefix with underscore:

   ```lua
   local _count = vim.v.count  -- Intentionally unused, reserved for future
   ```

   **Option C**: If it's a legitimate use case, add luacheck ignore:

   ```lua
   local count = vim.v.count  -- luacheck: ignore 211
   ```

**Recommendation**: Use Option A (delete) unless there's clear intent for future use

**Validation**:

```bash
mise lint | grep utilities.lua
# Should show 0 warnings for utilities.lua
```

**Acceptance Criteria**:

- [ ] Unused variable warning resolved
- [ ] Appropriate fix chosen (delete, prefix, or ignore)
- [ ] Functionality unchanged
- [ ] Luacheck passes for this file

______________________________________________________________________

### Task 3: Fix Hugo Plugin Unused Variables

**File**: `lua/plugins/zettelkasten/hugo.lua` (lines 63, 66) **Estimated**: 5 minutes **Context Window**: Small - two similar warnings

**Warning**:

```
lua/plugins/zettelkasten/hugo.lua:63:22: (W211) unused variable 'lines'
lua/plugins/zettelkasten/hugo.lua:66:22: (W211) unused variable 'lines'
```

**Problem**: Variable `lines` defined but not used (appears twice)

**Implementation**:

1. Read context around lines 63 and 66:

```bash
sed -n '58,70p' lua/plugins/zettelkasten/hugo.lua
```

2. Likely pattern:

```lua
-- Line 63
local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
-- lines never used after this

-- Line 66
local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
-- lines never used after this
```

3. **Fix Options**:

   **Option A**: If reading lines but not using result, use underscore:

   ```lua
   local _ = vim.api.nvim_buf_get_lines(0, 0, -1, false)
   ```

   **Option B**: If lines should be used later, this is a bug:

   ```lua
   local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
   -- Add missing logic that uses 'lines'
   for _, line in ipairs(lines) do
     -- Process line
   end
   ```

   **Option C**: If legitimately needed for side effects:

   ```lua
   local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)  -- luacheck: ignore 211
   ```

**Investigation Required**: Determine if this is dead code or incomplete implementation

**Validation**:

```bash
mise lint | grep hugo.lua
# Should show 0 warnings for hugo.lua
```

**Acceptance Criteria**:

- [ ] Both unused variable warnings resolved
- [ ] Intent clarified (dead code vs incomplete feature)
- [ ] Appropriate fix applied
- [ ] Hugo functionality tested and working
- [ ] Luacheck passes for this file

______________________________________________________________________

### Task 4: Validation - Full Luacheck Pass

**Files**: All Lua files in project **Estimated**: 5 minutes **Context Window**: N/A - validation only

**Requirements**:

- Run full luacheck on entire project
- Confirm 0 warnings, 0 errors
- Document any new warnings (none expected)

**Implementation**:

```bash
# Full project lint
mise lint

# Expected output:
# Total: 0 warnings / 0 errors in [N] files
```

If any new warnings appear:

1. Investigate root cause
2. Fix or document reason for deferring
3. Update this issue with findings

**Acceptance Criteria**:

- [ ] `mise lint` runs successfully
- [ ] 0 warnings reported
- [ ] 0 errors reported
- [ ] All modified files pass luacheck
- [ ] No regressions introduced

______________________________________________________________________

### Task 5: Update Documentation

**File**: `docs/development/CODE_QUALITY.md` (create if doesn't exist) **Estimated**: 10 minutes **Context Window**: Small - documentation creation

**Requirements**:

- Document code quality standards
- List luacheck rules enforced
- Provide examples of common warnings and fixes

**Implementation**: Create or update file:

````markdown
# Code Quality Standards

## Static Analysis

PercyBrain uses luacheck for Lua static analysis.

### Running Luacheck

```bash
# Full project lint
mise lint

# Specific file
luacheck lua/plugins/specific-file.lua
````

### Common Warnings and Fixes

#### W211: Unused Variable

**Problem**: Variable defined but never used **Fix**: Remove variable or prefix with underscore if intentional

```lua
-- Bad
local unused = 42

-- Good (if removing)
-- Just delete it

-- Good (if intentional)
local _reserved = 42
```

#### W211: Shadowing Upvalue

**Problem**: Inner scope variable shadows outer scope **Fix**: Rename inner variable

```lua
-- Bad
local mode = "normal"
local function set_mode(mode)  -- Shadows outer 'mode'
  return mode
end

-- Good
local mode = "normal"
local function set_mode(keymap_mode)  -- Different name
  return keymap_mode
end
```

#### W211: Unused Function Parameter

**Fix**: Prefix with underscore if required by API

```lua
-- Bad
local function on_attach(client, bufnr)  -- bufnr unused
  client.setup()
end

-- Good
local function on_attach(client, _bufnr)  -- Explicitly unused
  client.setup()
end
```

## Pre-commit Integration

Luacheck runs automatically via pre-commit hooks:

- Blocks commits with errors
- Warnings are allowed but logged
- Run `mise lint` before committing

## Luacheck Configuration

See `.luacheckrc` for:

- Global variable allowlist
- Ignored patterns
- Maximum line length
- Complexity limits

```

**Acceptance Criteria**:
- [ ] Documentation file created or updated
- [ ] Common warnings documented with examples
- [ ] Integration with mise/pre-commit explained
- [ ] Markdown formatting validated

---

## Dependencies

- **Prerequisite**: None - independent code quality work
- **Requires**: luacheck installed (already in project)
- **Follows**: Phase 3 migration completion

## Estimated Effort

- **Total**: 30 minutes
- **Task 1**: 5 min (Git shadowing)
- **Task 2**: 3 min (Utilities unused var)
- **Task 3**: 5 min (Hugo unused vars)
- **Task 4**: 5 min (Full validation)
- **Task 5**: 10 min (Documentation)

## Success Criteria

- [ ] All 5 tasks completed
- [ ] `mise lint` reports 0 warnings, 0 errors
- [ ] All pre-existing warnings fixed
- [ ] No functionality regressions
- [ ] Code quality documentation created
- [ ] Pre-commit hooks still pass

## Related Files

- `lua/config/keymaps/tools/git.lua` - 2 shadowing warnings
- `lua/config/keymaps/utilities.lua` - 1 unused variable
- `lua/plugins/zettelkasten/hugo.lua` - 2 unused variables
- `.luacheckrc` - Luacheck configuration
- `docs/development/CODE_QUALITY.md` - Documentation (NEW)
- `claudedocs/PHASE3_COMPLETION_TELEKASTEN_IWE_MIGRATION.md` - Source of warnings

## Notes

**Priority**: LOW - These are pre-existing issues, not urgent
**Risk**: VERY LOW - Fixes are isolated and straightforward
**Impact**: Code quality improvement, no functional changes expected
```
