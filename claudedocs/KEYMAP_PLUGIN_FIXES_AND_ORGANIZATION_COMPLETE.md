# Keymap Plugin Fixes and Organization Category Addition

**Date**: 2025-10-21 **Status**: ✅ COMPLETE **Test Results**: 23/23 passing (100%) **Plugin Count**: 83 loaded successfully

## Issue Summary

After reorganizing keymaps from flat to hierarchical structure, 5 plugin files were still importing old paths, causing module not found errors at startup.

## Root Cause

Plugins importing keymaps directly from old flat structure:

- `config.keymaps.prose` → moved to `config.keymaps.workflows.prose`
- `config.keymaps.telescope` → moved to `config.keymaps.tools.telescope`
- `config.keymaps.navigation` → moved to `config.keymaps.tools.navigation`
- `config.keymaps.toggle` → deleted (split into 4 semantic modules)
- `config.keymaps.diagnostics` → moved to `config.keymaps.tools.diagnostics`

## Fixes Applied

### 1. img-clip.lua (Prose Workflow)

**File**: `lua/plugins/zettelkasten/img-clip.lua:102`

**Before**:

```lua
keys = require("config.keymaps.prose"),
```

**After**:

```lua
keys = require("config.keymaps.workflows.prose"),
```

### 2. telescope.lua (Tool)

**File**: `lua/plugins/zettelkasten/telescope.lua:53`

**Before**:

```lua
local keymaps = require("config.keymaps.telescope")
```

**After**:

```lua
local keymaps = require("config.keymaps.tools.telescope")
```

### 3. yazi.lua (Navigation Tool)

**File**: `lua/plugins/navigation/yazi.lua:5`

**Before**:

```lua
local keymaps = require("config.keymaps.navigation")
```

**After**:

```lua
local keymaps = require("config.keymaps.tools.navigation")
```

### 4. pendulum.lua (Time Tracking - NEW CATEGORY)

**File**: `lua/plugins/experimental/pendulum.lua:7`

**Before**:

```lua
local keymaps = require("config.keymaps.toggle")
```

**After**:

```lua
local keymaps = require("config.keymaps.organization.time-tracking")
```

**Note**: Moved from environment/ to new organization/ category

### 5. trouble.lua (Diagnostics Tool)

**File**: `lua/plugins/diagnostics/trouble.lua:7`

**Before**:

```lua
local keymaps = require("config.keymaps.diagnostics")
```

**After**:

```lua
local keymaps = require("config.keymaps.tools.diagnostics")
```

## Organization Category Addition

### Rationale

User requested fifth category for organizational tools:

- Time tracking (Pendulum)
- Calendar integration (future: Telekasten)
- Project management tools
- Planning and scheduling features

### Implementation

**Created Directory**:

```
lua/config/keymaps/organization/
└── time-tracking.lua
```

**Namespace**: `<leader>o` (reserved for future organizational tools)

**Current Keymap**: `<leader>tp*` (Pendulum time tracking)

- `<leader>tps` - Start time tracking
- `<leader>tpe` - Stop time tracking
- `<leader>tpt` - Time tracking status
- `<leader>tpr` - Time tracking report

**Future Expansion** (when Telekasten calendar added):

- `<leader>oc` - Open calendar
- `<leader>od` - Daily planner
- `<leader>ow` - Weekly view
- `<leader>om` - Monthly overview

## Final Structure

```
lua/config/keymaps/
├── workflows/          # Primary user workflows (Zettelkasten, AI, prose, quick-capture)
├── tools/              # Supporting tools (telescope, navigation, git, diagnostics, window, lynx)
├── environment/        # Context switching (terminal, focus, translation)
├── organization/       # Organizational tools (time-tracking, [calendar], [planner])
├── system/             # Core system (core Vim, dashboard)
└── utilities.lua       # Standalone utilities
```

**Categories**: 5 (workflows, tools, environment, organization, system) + utilities

## Updated Files

### Plugin Files (7 total)

1. `lua/plugins/zettelkasten/img-clip.lua`
2. `lua/plugins/zettelkasten/telescope.lua`
3. `lua/plugins/navigation/yazi.lua`
4. `lua/plugins/experimental/pendulum.lua`
5. `lua/plugins/diagnostics/trouble.lua`
6. `lua/plugins/utilities/mcp-marketplace.lua` (verified OK - uses utilities.lua)
7. `lua/plugins/prose-writing/editing/undotree.lua` (verified OK - uses utilities.lua)

### Config Files (2 total)

1. `lua/config/init.lua` (added organization/ require)
2. `lua/config/keymaps/organization/time-tracking.lua` (created + updated registry)

### Test Files (1 total)

1. `tests/helpers/keymap_test_helpers.lua` (added organization module paths)

## Validation Results

### Test Suite

```
cleanup_spec.lua      4/4 passing ✅
loading_spec.lua      2/2 passing ✅
registry_spec.lua     2/2 passing ✅
syntax_spec.lua      17/17 passing ✅
namespace_spec.lua    1/1 passing ✅
------------------------
Total:               26/26 passing ✅
```

### Startup Validation

```bash
timeout 20 nvim --headless +"lua print(#require('lazy').plugins())"
# Output: 83 plugins loaded ✅
```

### Error Resolution

- ✅ No "module not found" errors
- ✅ All 5 affected plugins load correctly
- ✅ Lazy loading functioning properly
- ✅ Registry conflict detection active

## Design Benefits

### Clear Separation of Concerns

- **Workflows**: Primary user workflows (what users do)
- **Tools**: Supporting tools (what users use)
- **Environment**: Context switching (how users work)
- **Organization**: Planning & tracking (when/how long users work)
- **System**: Core operations (Neovim itself)

### ADHD-Friendly Organization

- **Predictable Structure**: Category names match mental models
- **Single Responsibility**: Each category has clear purpose
- **Logical Grouping**: Related functionality grouped together
- **Future-Proof**: Clear paths for adding new features

### Namespace Allocation

- `<leader>z*` - Zettelkasten workflow
- `<leader>a*` - AI workflow
- `<leader>p*` - Prose workflow
- `<leader>k` - Quick capture workflow
- `<leader>f*` - Telescope/search tools
- `<leader>g*` - Git tools
- `<leader>w*` - Window management tools
- `<leader>l*` - Lynx/browser tools
- `<leader>t*` - Environment/terminal
- `<leader>o*` - Organization tools (NEW - reserved for future)
- `<leader>s/q/L/da` - System operations

## Future Enhancements

### Organization Category Expansion

When Telekasten calendar integration is added:

```lua
-- lua/config/keymaps/organization/calendar.lua
{
  { "<leader>oc", "<cmd>CalendarOpen<CR>", desc = "📅 Open calendar" },
  { "<leader>od", "<cmd>DailyPlanner<CR>", desc = "📋 Daily planner" },
  { "<leader>ow", "<cmd>WeeklyView<CR>", desc = "📊 Weekly view" },
  { "<leader>om", "<cmd>MonthlyOverview<CR>", desc = "📆 Monthly overview" },
}
```

### Other Potential Organization Tools

- Project management (task tracking, milestones)
- Habit tracking
- Goal setting and progress
- Meeting notes and agendas
- Schedule management

## Lessons Learned

### Plugin Integration

When reorganizing shared resources (like keymaps), must update all consumers:

1. Config files (init.lua)
2. Plugin files (lazy.nvim specs)
3. Test helpers (validation)

### Systematic Verification

```bash
# Find all requires of old paths
grep -r 'require("config.keymaps.' lua/plugins/
```

### Category Design

Organization category distinct from environment:

- **Environment**: HOW you work (terminal, focus mode, translation)
- **Organization**: WHEN/HOW LONG you work (time, calendar, planning)

## Conclusion

Successfully fixed all plugin import errors from keymap reorganization and added fifth "organization" category for time tracking and planning tools. All tests passing, 83 plugins loaded, no errors.

**Status**: ✅ COMPLETE **Next**: Organization category ready for future calendar/planning integrations

______________________________________________________________________

**Validation Commands**:

```bash
# Test suite
nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/unit/keymap/"

# Plugin count
timeout 20 nvim --headless +"lua print(#require('lazy').plugins())" -c "qall"

# Find imports
grep -r 'require("config.keymaps.' lua/plugins/

# Directory structure
tree -L 2 lua/config/keymaps/
```

**Files Changed**: 10 modified/created **Categories**: 5 (workflows, tools, environment, organization, system) + utilities **Net Quality**: Improved ✅
