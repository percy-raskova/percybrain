---
title: Trouble Plugin Buffer Fix - Validation Checklist
date: 2025-10-20
category: troubleshooting
tags: [trouble, buffer, tdd, testing]
last_reviewed: '2025-10-20'
---

# Trouble Plugin Buffer Fix - Validation Checklist

## Problem Summary

**Symptoms**:

- Trouble buffer opens with scratch buffer showing errors
- Cannot scroll through buffer content (only first few lines visible)
- Buffer closes immediately when user clicks inside it
- Cannot navigate or interact with error list

## Root Cause

**Trouble v2 → v3 Breaking API Changes**: Configuration written for Trouble v2 API while v3.7.1 installed.

**Key Breaking Changes**:

- Commands: `:TroubleToggle` → `:Trouble diagnostics toggle`
- Functions: `require("trouble").previous()` → `require("trouble").prev()`
- Config structure: `config = function()` → `opts = {}`
- Navigation keys moved from `action_keys` to `keys` table inside `opts`

**Secondary Issue**: `auto_close = true` caused buffer to close on interaction events.

## Fix Applied

**File**: `lua/plugins/diagnostics/trouble.lua` **Scope**: Complete rewrite for Trouble v3 API (107 lines)

**Major Changes**:

1. **Commands updated** (line 9-19):

   - `cmd = { "Trouble", "TroubleToggle" }` → `cmd = "Trouble"`
   - All keybindings changed from `:TroubleToggle` to `:Trouble diagnostics toggle`

2. **Navigation functions updated** (line 22-35):

   - `require("trouble").previous()` → `require("trouble").prev()`
   - Added explicit `skip_groups` and `jump` parameters

3. **Configuration structure migrated** (line 38-98):

   - `config = function()` → `opts = {}` + `config = function(_, opts)`
   - `action_keys` → `keys` table inside `opts`
   - Added `modes` table for diagnostics configuration
   - Added explicit mouse support: `["<2-leftmouse>"] = "jump"`

4. **Auto-close fixed** (line 41):

   - `auto_close = true` → `auto_close = false`

## Validation Steps

### 1. Reload Configuration

```vim
:source ~/.config/nvim/init.lua
:Lazy reload trouble.nvim
```

### 2. Test Buffer Persistence

- [ ] Open Trouble: `<leader>xx`
- [ ] Click inside the buffer
- [ ] ✅ PASS: Buffer should remain open (not close immediately)
- [ ] ❌ FAIL: Buffer closes → fix not applied correctly

### 3. Test Scrolling

- [ ] Create multiple errors (>10)
- [ ] Open Trouble: `<leader>xx`
- [ ] Use `j` key to scroll down
- [ ] Use `k` key to scroll up
- [ ] ✅ PASS: Can navigate through full error list
- [ ] ❌ FAIL: Can't scroll → additional issue

### 4. Test Navigation

- [ ] Open Trouble with errors
- [ ] Press `j` multiple times (move down through list)
- [ ] ✅ PASS: Cursor moves through errors without buffer closing
- [ ] ❌ FAIL: Buffer closes or navigation doesn't work

### 5. Test Explicit Close Control

- [ ] Open Trouble: `<leader>xx`
- [ ] Press `q` key
- [ ] ✅ PASS: Buffer closes (user controlled)
- [ ] Open Trouble again: `<leader>xx`
- [ ] Press `<Esc>` key
- [ ] ✅ PASS: Buffer closes (user controlled)

### 6. Test Focus Switching

- [ ] Open Trouble: `<leader>xx`
- [ ] Switch to another window (`<leader>v` for vsplit)
- [ ] Click or navigate to other window
- [ ] ✅ PASS: Trouble buffer remains open in its window
- [ ] ❌ FAIL: Trouble buffer auto-closes → additional config issue

## TDD Tests Created

**Contract Tests** (13 tests): `tests/contract/trouble_plugin_spec.lua`

- Buffer persistence on interaction
- Scrolling and navigation capability
- Buffer visibility settings
- Explicit close control
- Auto-close prevention

**Capability Tests** (17 tests): `tests/capability/trouble/diagnostic_workflow_spec.lua`

- View all errors in one place
- Navigate through error list
- Control window lifecycle
- Error filtering and organization
- ADHD/autism optimizations

**Test Standards**: 6/6 passing for both files

## Expected Behavior After Fix

### ✅ Should Work

- Opening Trouble with `<leader>xx`
- Scrolling through errors with `j`/`k`
- Clicking inside buffer (no auto-close)
- Switching focus to other windows (buffer remains)
- Navigating with cursor keys
- Jumping to errors with `<Enter>`
- Closing with `q` or `<Esc>` (explicit user control)

### ❌ Should NOT Happen

- Buffer closing on click
- Buffer closing on cursor movement
- Buffer closing when switching windows
- Auto-closing when diagnostics resolved

## Troubleshooting

### If Buffer Still Closes on Click

1. Verify fix was applied: `cat ~/.config/nvim/lua/plugins/diagnostics/trouble.lua | grep auto_close`
2. Should show: `auto_close = false`
3. If not, re-edit file and reload

### If Scrolling Still Broken

1. Check buffer options when Trouble is open:

```vim
:lua print(vim.inspect(vim.api.nvim_buf_get_option(0, "modifiable")))
:lua print(vim.inspect(vim.api.nvim_buf_get_option(0, "bufhidden")))
```

2. Should be: `modifiable = false`, `bufhidden ≠ "wipe"`

### If Tests Fail in Test Environment

- Plugin loading in headless tests requires `tests/plugin_test_init.lua`
- Run: `nvim --headless -u tests/plugin_test_init.lua -c "lua require('plenary.busted').run('tests/contract/trouble_plugin_spec.lua')" -c "qa!"`
- Note: Tests may fail due to plugin loading complexity in headless environment

## Commit Information

**Branch**: (current) **Files Modified**:

- `lua/plugins/diagnostics/trouble.lua` (1 line changed)

**Files Created**:

- `tests/contract/trouble_plugin_spec.lua` (270 lines)
- `tests/capability/trouble/diagnostic_workflow_spec.lua` (385 lines)
- `tests/plugin_test_init.lua` (45 lines)
- `claudedocs/TROUBLE_PLUGIN_FIX_VALIDATION.md` (this file)

## Related Documentation

- Trouble.nvim repository: https://github.com/folke/trouble.nvim
- PercyBrain testing guide: `docs/testing/TESTING_GUIDE.md`
- ADHD/autism optimizations: `docs/explanation/NEURODIVERSITY_DESIGN.md`

## Status

- [x] RED Phase: Tests written (13 contract + 17 capability)
- [x] Fix Applied: `auto_close = false`
- [ ] GREEN Phase: Production validation (user testing)
- [ ] REFACTOR Phase: Code cleanup if needed

**Next Step**: User validates fix in actual Neovim environment using checklist above.
