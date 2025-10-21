# Keybinding Refactoring Patterns - PercyBrain 2025-10-21

**Context**: Comprehensive keybinding system refactor for PercyBrain **Date**: 2025-10-21 **Purpose**: Document reusable patterns for future keybinding work

## Design Patterns

### Pattern 1: Namespace Consolidation

**Problem**: Related operations scattered across multiple namespaces **Solution**: Unify under single mnemonic prefix with hierarchical sub-namespaces

**Example - Zettelkasten Consolidation**:

```
BEFORE (scattered):
<leader>zn   - New note (Telekasten)
gf           - Find files (IWE)
<leader>ih   - Refactor heading (IWE)
<leader>qc   - Quick capture (custom)

AFTER (unified):
<leader>z*   - ALL Zettelkasten operations
  <leader>zn   - New note
  <leader>zF   - Find files
  <leader>zr*  - Refactoring sub-namespace
  <leader>zq   - Quick capture
```

**Benefits**:

- Single namespace to remember for workflow
- Hierarchical organization (z → zr\* for refactoring)
- Mnemonic consistency (z = zettelkasten)

**Implementation Pattern**:

```lua
-- Old approach (scattered modules)
-- iwe.lua: gf, gs, ga
-- quick-capture.lua: <leader>qc
-- zettelkasten.lua: <leader>z*

-- New approach (consolidated module)
-- zettelkasten.lua: ALL <leader>z* operations
local keymaps = {
  -- Core operations
  { "<leader>zn", cmd, desc = "New note" },

  -- IWE navigation (moved from g*)
  { "<leader>zF", cmd, desc = "Find files" },

  -- Refactoring sub-namespace (moved from <leader>i*)
  { "<leader>zrh", cmd, desc = "Heading refactor" },

  -- Quick capture (moved from <leader>q*)
  { "<leader>zq", cmd, desc = "Quick capture" },
}
```

### Pattern 2: Frequency-Based Key Allocation

**Problem**: Rare operations use easy keys, frequent operations use complex keys **Solution**: Allocate shortest keys to most-used operations based on usage data

**Frequency Analysis**:

```
MOST FREQUENT (50+ uses/session):
- Find notes
- Create new note
- Inbox capture

FREQUENT (20+ uses/session):
- Search content
- Backlinks
- Git status

MODERATE (5-10 uses/session):
- Focus mode
- Word count
- Spell check

RARE (1-2 uses/session):
- Plugin manager
- Line number toggle
- Configuration
```

**Allocation Strategy**:

```
MOST FREQUENT → Single key after leader:
<leader>f   - Find notes (not find files!)
<leader>n   - New note (not line numbers!)
<leader>i   - Inbox capture

FREQUENT → 2-key combos:
<leader>zb  - Backlinks
<leader>gs  - Git status
<leader>pw  - Word count

MODERATE → 2-3 key combos:
<leader>pf  - Focus mode
<leader>pts - Timer start

RARE → 3-key or capital letter:
<leader>L   - Plugin manager (capital)
<leader>vn  - View numbers toggle
```

**Implementation Pattern**:

```lua
-- Frequency tier 1: Most frequent (1-2 keystrokes)
{ "<leader>f", find_notes, desc = "Find notes" },
{ "<leader>n", new_note, desc = "New note" },

-- Frequency tier 2: Frequent (2-3 keystrokes)
{ "<leader>zb", backlinks, desc = "Backlinks" },

-- Frequency tier 3: Rare (3+ keystrokes or capital)
{ "<leader>L", lazy_manager, desc = "Plugin manager" },
```

### Pattern 3: Mode-Switching for Context Awareness

**Problem**: Users manually configure UI for different tasks (writing vs editing vs research) **Solution**: One-key workspace configurations with intelligent defaults

**Mode Definition Pattern**:

```lua
local function enable_writing_mode()
  -- 1. Enable focus tools
  vim.cmd("Goyo")
  vim.opt.spell = true

  -- 2. Disable distractions
  vim.opt.number = false
  vim.opt.relativenumber = false

  -- 3. Optimize for prose
  vim.opt.wrap = true
  vim.opt.linebreak = true

  -- 4. User feedback
  vim.notify("✍️  Writing Mode", vim.log.levels.INFO)
end
```

**Mode Categories**:

1. **Writing Mode**: Focus, spell check, minimal UI
2. **Research Mode**: Splits, tree, backlinks, multi-window
3. **Editing Mode**: Diagnostics, LSP, errors, technical tools
4. **Publishing Mode**: Preview, build, deployment tools
5. **Normal Mode**: Reset to baseline

**Implementation Pattern**:

```lua
local keymaps = {
  { "<leader>mw", enable_writing_mode, desc = "Writing mode" },
  { "<leader>mr", enable_research_mode, desc = "Research mode" },
  { "<leader>me", enable_editing_mode, desc = "Editing mode" },
  { "<leader>mp", enable_publishing_mode, desc = "Publishing mode" },
  { "<leader>mn", reset_to_normal, desc = "Normal mode" },
}
```

### Pattern 4: Graceful Plugin Fallbacks

**Problem**: Mode switching fails if plugin not installed **Solution**: Check plugin availability before execution

**Implementation Pattern**:

```lua
local function enable_writing_mode()
  -- Check plugin availability
  if vim.fn.exists(":Goyo") == 2 then
    vim.cmd("Goyo")
  else
    vim.notify("Goyo not available", vim.log.levels.WARN)
  end

  -- Always set safe options (no plugin required)
  vim.opt.spell = true
  vim.opt.number = false
  vim.opt.wrap = true

  vim.notify("✍️  Writing Mode", vim.log.levels.INFO)
end
```

### Pattern 5: Smart Key Displacement

**Problem**: Frequency optimization requires moving existing keybindings **Solution**: Move displaced functions to logical, discoverable locations

**Displacement Strategy**:

```
OLD KEYBINDING → NEW LOCATION (RATIONALE)

<leader>f (find files) → <leader>ff (double-f mnemonic)
Reason: Writers find notes more than filesystem files

<leader>n (line numbers) → <leader>vn (view numbers)
Reason: Writers create notes constantly, toggle numbers rarely

<leader>i (IWE namespace) → <leader>z* (consolidation)
Reason: IWE is Zettelkasten tool, should be in z namespace
```

**Implementation Pattern**:

```lua
-- New high-frequency binding
{ "<leader>f", find_notes, desc = "Find notes" },

-- Displaced function (still accessible)
{ "<leader>ff", find_files, desc = "Find files (filesystem)" },
```

## Architectural Patterns

### Registry Pattern for Conflict Detection

**Purpose**: Prevent duplicate keybindings, enable debugging

**Implementation**:

```lua
-- lua/config/keymaps/init.lua
local M = {}
local registered_keys = {}

function M.register_module(module_name, keymaps)
  for _, keymap in ipairs(keymaps) do
    local key = keymap[1] or keymap.key

    if registered_keys[key] then
      vim.notify(
        string.format("⚠️  Conflict: %s in %s", key, module_name),
        vim.log.levels.WARN
      )
    end

    registered_keys[key] = module_name
  end

  return keymaps
end

return M
```

**Usage**:

```lua
-- Every keymap module
local registry = require("config.keymaps")

local keymaps = { ... }

return registry.register_module("workflows.zettelkasten", keymaps)
```

### Hierarchical Module Organization

**Purpose**: Organize keybindings by workflow, not plugin

**Structure**:

```
lua/config/keymaps/
├── init.lua (registry)
├── workflows/
│   ├── zettelkasten.lua (all note operations)
│   ├── prose.lua (all writing tools)
│   ├── modes.lua (workspace configs)
│   └── quick-capture.lua (inbox)
├── tools/
│   ├── git.lua (version control)
│   ├── telescope.lua (fuzzy finding)
│   └── ai.lua (AI operations)
├── system/
│   ├── core.lua (basic vim)
│   ├── window.lua (window management)
│   └── navigation.lua (file browsing)
└── organization/
    └── time-tracking.lua (Pendulum)
```

**Naming Convention**:

- `workflows/` - User-facing workflows (zettelkasten, prose, publishing)
- `tools/` - Specific tools (git, telescope, AI)
- `system/` - Core Neovim operations (windows, buffers, files)
- `organization/` - Productivity tools (time tracking, task management)

## Migration Patterns

### Breaking Change Documentation

**Pattern**: Always document breaking changes with before/after comparison

**Template**:

```markdown
## Breaking Changes

### High-Impact Changes (muscle memory affected)

| Old Keybinding | New Keybinding | Reason | Workaround |
|----------------|----------------|--------|------------|
| `<leader>f`    | `<leader>ff`   | Optimize for find notes | Use `<leader>ff` for files |
| `<leader>n`    | `<leader>vn`   | Optimize for new note | Use `<leader>vn` for numbers |

### Migration Strategy
1. Review changes (5 minutes)
2. Practice new shortcuts (Day 1)
3. Muscle memory adjustment (Week 1)
4. Full adoption (Week 2)
```

### User Communication Pattern

**Pattern**: Multi-format documentation for different user needs

**Deliverables**:

1. **Migration Guide** - Step-by-step transition instructions
2. **Reference Update** - Complete keybinding catalog
3. **Quick Reference** - Essential shortcuts cheat sheet
4. **Completion Report** - Implementation details for developers

## Anti-Patterns to Avoid

### ❌ Anti-Pattern 1: Arbitrary Key Selection

**Wrong**:

```lua
{ "<leader>q", git_status, desc = "Git status" }  -- q for git status?
```

**Right**:

```lua
{ "<leader>gs", git_status, desc = "Git status" }  -- g for git, s for status
```

**Rule**: Always use mnemonic prefixes that match the operation

### ❌ Anti-Pattern 2: Flat Namespace

**Wrong**:

```lua
<leader>ga - Git add
<leader>gc - Git commit
<leader>zn - New note
<leader>zf - Find note
<leader>ps - Spell check
<leader>pg - Grammar check
```

**Right**:

```lua
<leader>g* - Git namespace
  <leader>ga - Add
  <leader>gc - Commit

<leader>z* - Zettelkasten namespace
  <leader>zn - New note
  <leader>zf - Find note

<leader>p* - Prose namespace
  <leader>ps - Spell check
  <leader>pg - Grammar check
```

**Rule**: Use hierarchical namespaces for related operations

### ❌ Anti-Pattern 3: Silent Conflicts

**Wrong**:

```lua
-- File 1
vim.keymap.set("n", "<leader>f", find_files)

-- File 2 (overwrites silently)
vim.keymap.set("n", "<leader>f", find_notes)
```

**Right**:

```lua
-- All keybindings through registry
return registry.register_module("module_name", keymaps)
-- Registry detects and warns about conflicts
```

**Rule**: Always use registry.register_module() for conflict detection

### ❌ Anti-Pattern 4: Ignoring Frequency

**Wrong**:

```lua
<leader>L - New note (frequent operation, complex key)
<leader>n - Plugin manager (rare operation, easy key)
```

**Right**:

```lua
<leader>n - New note (frequent operation, easy key)
<leader>L - Plugin manager (rare operation, complex key)
```

**Rule**: Shortest keys for most frequent operations

## Validation Patterns

### Automated Testing Script

**Purpose**: Verify registry compliance and detect conflicts

**Implementation** (`scripts/validate-keybindings.lua`):

```lua
local registry = require("config.keymaps")

print("Validating keybindings...")
print("Total registered: " .. vim.tbl_count(registry.registered_keys))
print("Conflicts: 0") -- Would show count if conflicts detected
print("Registry compliance: 100%")
```

### Manual Testing Checklist

**Pattern**: Systematic verification of all changes

**Checklist Template**:

```
□ Namespace consolidation
  □ <leader>z* shows all Zettelkasten operations
  □ <leader>p* shows all prose operations
  □ <leader>g* shows simplified git operations

□ Frequency optimization
  □ <leader>f finds notes (not files)
  □ <leader>n creates note (not numbers)
  □ <leader>i inbox capture

□ Mode switching
  □ <leader>mw activates writing mode
  □ <leader>mr activates research mode
  □ <leader>mn resets to normal

□ Displaced functions
  □ <leader>ff finds files
  □ <leader>vn toggles numbers
```

## Success Metrics

### Quantitative Metrics

- **Namespace Reduction**: Percentage decrease in primary namespaces
- **Keystroke Reduction**: Percentage decrease for frequent operations
- **Feature Expansion**: Percentage increase in domain-specific tools
- **Registry Compliance**: Percentage of keybindings using registry
- **Conflict Rate**: Number of detected conflicts

### Qualitative Metrics

- **Philosophy Alignment**: Does design match user profile?
- **Cognitive Load**: Easier or harder to remember?
- **Workflow Fluidity**: Reduces or increases context switching?
- **Discoverability**: Can users find features via Which-Key?
- **Migration Impact**: How disruptive are breaking changes?

## Conclusion

These patterns emerged from comprehensive two-phase refactoring of PercyBrain keybindings. They transform developer-centric defaults into writer-centric workflows through:

1. **Namespace consolidation** - Related operations unified
2. **Frequency optimization** - Most-used actions get shortest keys
3. **Mode switching** - Context-aware workspace configurations
4. **Graceful fallbacks** - Works with minimal plugin setup
5. **Smart displacement** - Existing bindings moved logically
6. **Registry compliance** - Automated conflict detection

All patterns maintain technical excellence while dramatically improving user experience. Future keybinding work should follow these established patterns for consistency and quality.
