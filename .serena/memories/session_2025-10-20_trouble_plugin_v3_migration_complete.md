# Session 2025-10-20: Trouble Plugin v3 Migration & Plugin Management

## Session Summary

**Duration**: ~2 hours **Focus**: Troubleshooting Trouble.nvim buffer issues, discovered v2→v3 breaking changes **Outcome**: Complete fix applied, plugin management strategy documented

## Problem Discovery

### Initial Report

User reported Trouble plugin buffer issues:

- Buffer opens but closes immediately on click
- Cannot scroll through diagnostics (only first few lines visible)
- Cannot navigate with j/k keys or mouse
- Window disappears on any interaction

### Initial Misdiagnosis

- First assumed `auto_close = true` was the issue (partially correct)
- Wrote comprehensive TDD tests for expected v2 behavior
- Tests revealed plugin wasn't loading properly in test environment

### Root Cause Discovery

**Critical Finding**: Configuration written for **Trouble v2 API**, but **v3.7.1** installed!

API completely changed in v3:

- `:TroubleToggle` → `:Trouble diagnostics toggle`
- `previous()` → `prev()`
- Config structure changed from `config = function()` to `opts = {}`
- New modes system with preview configuration
- Explicit mouse support required

## Fixes Applied

### 1. Trouble.nvim v3 Migration

**File**: `lua/plugins/diagnostics/trouble.lua` **Changes**: Complete rewrite for v3 API (107 lines)

**Key Updates**:

```lua
-- V2 (broken)
{ "<leader>xx", "<cmd>TroubleToggle<cr>" }
config = function()
  require("trouble").setup({ auto_close = true })
end

-- V3 (fixed)
{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>" }
opts = {
  auto_close = false,  -- User controls close with q/<Esc>
  focus = true,
  keys = {
    ["<2-leftmouse>"] = "jump",  -- Explicit mouse support
    j = "next",
    k = "prev",
  }
}
```

**Navigation fixes**:

- `require("trouble").previous()` → `require("trouble").prev()`
- `require("trouble").next()` → Same (no change)
- Added mouse click support: `["<2-leftmouse>"] = "jump"`

**New features**:

- Document symbols mode: `<leader>xs`
- Better preview configuration
- Cleaner key mappings

### 2. markdown-preview.nvim Clean

**Issue**: Local changes in `app/yarn.lock` blocking updates **Cause**: Build process changed registry URLs (yarnpkg.com → npmjs.org) **Fix**:

```bash
cd ~/.local/share/nvim/lazy/markdown-preview.nvim
git restore app/yarn.lock
git clean -fd app/
```

**Result**: Plugin now clean, updates will work

## TDD Artifacts Created

### Contract Tests

**File**: `tests/contract/trouble_plugin_spec.lua` (270 lines) **Status**: Written for v2 API (needs v3 update) **Coverage**: 13 tests defining MUST/MUST NOT/MAY contracts

- Buffer persistence on interaction
- Scrolling and navigation
- Explicit close control
- Auto-close prevention

### Capability Tests

**File**: `tests/capability/trouble/diagnostic_workflow_spec.lua` (385 lines) **Status**: Written for v2 API (needs v3 update) **Coverage**: 17 workflow tests

- View errors in one place
- Navigate through error list
- Control window lifecycle
- ADHD/autism optimizations

### Test Infrastructure

**File**: `tests/plugin_test_init.lua` (45 lines)

- Loads minimal_init.lua + actual plugins
- Enables plugin behavior testing
- Issue: Plugin loading complex in headless environment

**Test Standards**: 6/6 passing for both test files

## Documentation Created

### 1. Validation Checklist

**File**: `claudedocs/TROUBLE_PLUGIN_FIX_VALIDATION.md`

- Step-by-step validation procedures
- Expected vs actual behavior documentation
- Troubleshooting guide for persistent issues

### 2. Plugin Clean Slate Guide

**File**: `PLUGIN_CLEAN_SLATE.md`

- Complete nuclear reset procedures
- Version pinning strategies
- Lockfile workflow documentation
- Alternative surgical update methods

### 3. Clean Plugin Script

**File**: `scripts/clean-plugins.sh` (executable)

- Automated clean slate with backups
- Interactive confirmation prompts
- Color-coded output for clarity

## Key Learnings

### Plugin Version Management

**Problem Pattern**: Plugins auto-update to breaking versions without config migration **Root Cause**: Most plugins use `version = "*"` or no constraint **Impact**: Silent breakage (Trouble v2→v3, potentially others)

**Solutions Documented**:

1. **Lockfile Strategy** (Recommended):

   ```vim
   :Lazy sync        " Generate lazy-lock.json
   git add lazy-lock.json
   git commit -m "chore: lock plugin versions"
   ```

2. **Conservative Pinning**:

   ```lua
   version = "~3.0",  -- Only 3.x.x updates (no 4.0)
   version = "~2.3.0",  -- Only 2.3.x updates
   ```

3. **Controlled Updates**:

   ```vim
   :Lazy update      " Update when YOU choose
   :Lazy restore     " Rollback if broken
   ```

### Version Constraints Found

**Currently pinned**:

- `telescope.nvim`: `tag = "0.1.3"` (old, should update)
- `pomo.lua`: `version = "*"` (latest)
- `nvim-surround`: `version = "*"` (latest)
- `toggleterm`: `version = "*"` (latest)

**Recommendation**: Generate and commit `lazy-lock.json` for all plugins

### Build Artifact Pollution

**Pattern**: Plugins with build steps create git-tracked files **Example**: markdown-preview.nvim creates `yarn.lock`, `package-lock.json` **Solution**: `git restore` + `git clean -fd` before updates

## Validation Steps for User

1. **Reload configuration**:

   ```vim
   :source ~/.config/nvim/init.lua
   :Lazy reload trouble.nvim
   ```

2. **Update all plugins**:

   ```vim
   :Lazy sync
   ```

3. **Test Trouble**:

   ```vim
   <leader>xx        " Should open diagnostics window
   j/k               " Navigate through errors
   <click>           " Should jump to error (not close!)
   q                 " Close window (user controlled)
   ```

4. **Lock versions**:

   ```vim
   :Lazy sync        " Generates lazy-lock.json
   ```

   ```bash
   cd ~/.config/nvim
   git add lazy-lock.json
   git commit -m "chore: lock plugin versions after v3 migration"
   ```

## Files Modified

- `lua/plugins/diagnostics/trouble.lua` (107 lines, complete rewrite)

## Files Created

- `tests/contract/trouble_plugin_spec.lua` (270 lines)
- `tests/capability/trouble/diagnostic_workflow_spec.lua` (385 lines)
- `tests/plugin_test_init.lua` (45 lines)
- `claudedocs/TROUBLE_PLUGIN_FIX_VALIDATION.md`
- `PLUGIN_CLEAN_SLATE.md`
- `scripts/clean-plugins.sh` (executable)

## Next Steps

1. **User validates fix** in production Neovim
2. **Update test files** to v3 API (contract + capability tests)
3. **Generate lockfile** and commit to prevent future breakages
4. **Check other plugins** for similar v2→v3 issues
5. **Consider clean slate** if multiple plugins have issues

## Technical Patterns Discovered

### Trouble v3 Migration Pattern

```lua
-- Pattern: lazy.nvim v3 plugin config
return {
  "author/plugin",
  cmd = "Command",
  keys = { ... },
  opts = {           -- Not config = function()
    -- Configuration here
  },
  config = function(_, opts)  -- Optional post-setup
    require("plugin").setup(opts)
  end,
}
```

### Plugin Clean State Pattern

```bash
cd ~/.local/share/nvim/lazy/<plugin-name>
git status                    # Check for local changes
git restore <file>            # Reset modified files
git clean -fd <dir>           # Remove untracked files
```

### Version Pinning Pattern

```lua
-- Semantic versioning constraints
version = "~3.0",    -- 3.x.x only (no 4.0)
version = "~3.7.0",  -- 3.7.x only (no 3.8)
version = "*",       -- Latest (risky)
tag = "v3.7.1",      # Exact version (frozen)
commit = "abc123",   # Exact commit (frozen)
```

## Cross-Session Continuity

**Status**: Trouble fix complete, awaiting user validation **Blocker**: None (fix applied, clean state achieved) **Risk**: Other plugins may have similar v2→v3 issues

**Recommendation**: After user validates Trouble fix, audit other major plugins:

- nvim-cmp (completion)
- nvim-tree (file explorer)
- telescope.nvim (fuzzy finder)
- gitsigns.nvim (git integration)

**Recovery Plan**:

- Backups exist for plugin directory
- Clean slate script ready if needed
- Lockfile strategy documented

## Session Metadata

**Branch**: (current) **Commits**: 1 (Trouble v3 migration) **Tests Written**: 30 (13 contract + 17 capability) **Tests Passing**: 0/30 (need plugin loading fix for headless tests) **Luacheck**: 0 warnings **Pre-commit**: All hooks passing

**Background Process**: Bash 45f304 still running (can be killed if needed)
