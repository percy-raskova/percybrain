# Keybinding Architecture Analysis - PercyBrain Neovim

**Date**: 2025-10-23 **Analysis Type**: Deep architectural review with ultrathink **Status**: 🔴 CRITICAL - Keybinding system in broken state **Priority**: P0 - Blocks primary Zettelkasten workflow

______________________________________________________________________

## Executive Summary

**Critical Finding**: The keybinding architecture is in a FAILED REFACTOR state. A migration from centralized registry to lazy.nvim native approach was started (commit 7a6ca78, Oct 23 2025) but never completed. Result: **~100 documented keybindings are non-functional**, leaving core workflows broken.

**Impact**:

- **Primary workflow broken**: Zettelkasten operations require typing `:PercyNew` instead of `<leader>zn` (5-8 keystrokes vs 3)
- **ADHD optimizations destroyed**: Which-key shows empty namespaces, muscle memory lost, cognitive load increased
- **Workflow misalignment**: "Speed of thought knowledge management" philosophy violated - command typing breaks flow state
- **Documentation fantasy**: Memories document 14 namespaces with 121 keybindings - only ~20 actually work

**Root Cause**: Commit 7a6ca78 deleted 1,474 lines of centralized keybinding system with plan for "incremental migration" to lazy.nvim native approach. Migration was abandoned after only sembr.lua was converted.

______________________________________________________________________

## Architectural States Comparison

### DOCUMENTED (Memories) - OBSOLETE ARCHITECTURE

**Source**: `keymap_architecture_patterns` memory (last updated 2025-10-21)

**Design**:

```
lua/config/keymaps/
├── init.lua                # Registry system with conflict detection
├── workflows/              # 5 files: zettelkasten, ai, prose, quick-capture, gtd
├── tools/                  # 6 files: telescope, git, diagnostics, etc.
├── environment/            # 3 files: terminal, focus, translation
├── organization/           # 1 file: time-tracking
└── system/                 # 2 files: core, dashboard
```

**Features**:

- Centralized registry with `M.register_module()` conflict detection
- 14 semantic namespaces (z=zettelkasten, g=git, a=ai, etc.)
- Hierarchical organization (5 directories, 21 files)
- 121 total keybindings documented
- Frequency-optimized (<leader>f for most common, <leader>L for rare)
- ADHD-optimized (predictable structure, reduced cognitive load)

**Status**: ❌ **DELETED** - Entire lua/config/keymaps/ directory removed Oct 23, 2025

______________________________________________________________________

### ACTUAL (Current Codebase) - INCOMPLETE MIGRATION

**Reality Check**:

```
lua/
├── config/
│   ├── init.lua                # ~10 basic keybindings (save, quit, splits)
│   ├── zettelkasten.lua        # Business logic EXISTS, keybindings MISSING
│   └── (NO keymaps/ directory)
└── plugins/                    # 65 plugin files
    ├── utilities/fugitive.lua      # ✅ ~20 git keybindings in keys = {}
    ├── utilities/gitsigns.lua      # ✅ ~8 git hunk keybindings in keys = {}
    ├── ai-sembr/sembr.lua          # ✅ 2 keybindings in keys = {}
    ├── ai-sembr/ollama.lua         # ✅ 7 AI keybindings via vim.keymap.set()
    ├── zettelkasten/sembr-integration.lua  # ✅ 2 keybindings via vim.keymap.set()
    ├── zettelkasten/telescope.lua  # ❌ Empty keys = {}, TODO comment
    ├── utilities/gtd.lua           # ❌ Empty keys = {}, TODO comment
    └── [55+ other plugins]         # ❌ No keybindings defined
```

**Working Keybindings** (~37 total):

1. **Core operations** (10): save, quit, close, split, line numbers, plugin manager
2. **Git** (20): fugitive operations (status, diff, blame, commit, push, etc.)
3. **Git hunks** (8): gitsigns operations (next/prev hunk, stage, undo, preview)
4. **AI** (7): Ollama operations (menu, chat, explain, summarize, model selection)
5. **SemBr** (4): Format, toggle, keybindings in sembr.lua + sembr-integration.lua

**Missing Keybindings** (~100+):

01. **Zettelkasten core** (13): new note, daily, inbox, find, grep, backlinks, tags, calendar, publish, etc.
02. **Telescope** (7): find files, grep, buffers, keymaps, help
03. **GTD** (3): capture, process, inbox count
04. **Window manager** (26): navigation, splits, layouts, buffer operations
05. **IWE refactoring** (6): extract, inline, normalize, pathways, contents, squash
06. **AI transforms** (6): expand, rewrite, keywords, emoji (visual mode)
07. **Prose** (3): focus mode, paste, markdown formatting
08. **Publishing** (4): Quartz digital garden operations
09. **Lynx** (4): citation operations
10. **Diagnostics** (6): trouble operations
11. **Terminal/translation/time-tracking** (10+)

**How They Work Currently**:

- **User commands** exist (`:PercyNew`, `:PercyDaily`, etc.) - functional but slow
- **Functions** exist in `config/zettelkasten.lua` - business logic intact
- **Keybindings** don't exist - no way to call functions via shortcuts
- **Which-key** shows namespaces (`<leader>z`, `<leader>a`, etc.) but no actual keys

______________________________________________________________________

## Root Cause Analysis

### The Refactor That Failed

**Commit**: `7a6ca78` - "refactor: remove centralized keybinding system, use lazy.nvim native approach" **Date**: Oct 23, 2025 (TODAY - very recent!) **Changes**: -1,474 lines, deleted 23 files

**Stated Rationale** (from commit message):

> The centralized system was over-engineered and caused friction:
>
> - Plugins fought to set their own keybindings
> - Maintenance burden (create file + update init + prevent plugin keys)
> - Indirection (functions just called commands anyway)
> - Discovery harder (hunt through multiple files)

**Intended Plan**:

> Remaining plugin keybindings can be migrated incrementally using the pattern established in sembr.lua

**What Actually Happened**:

1. ✅ Deleted centralized system (23 files, 1,474 lines)
2. ✅ Migrated sembr.lua (2 keybindings)
3. ❌ Abandoned migration for remaining 100+ keybindings
4. ❌ Left system in broken state - documented shortcuts don't work

### Why This Is Critical

**ADHD Optimization Lost**:

- **Before**: `<leader>zn` → instant new note (muscle memory, 3 keystrokes)
- **After**: `:PercyNew<CR>` → type command (breaks flow, 10+ keystrokes)
- **Impact**: Flow state destroyed, cognitive load increased

**Workflow Philosophy Violated**:

- **PercyBrain goal**: "Speed of thought knowledge management for writers"
- **Current reality**: Slow command typing interrupts writing flow
- **Frequency optimization**: Most common operations (50+ uses/session) now hardest to access

**Discovery Mechanism Broken**:

- **Which-key** shows namespace groups (`📓 Zettelkasten`, `🤖 AI`) but pressing them shows NOTHING
- **Muscle memory**: Users expect `<leader>zn` but it doesn't exist
- **Documentation** promises 121 keybindings, only 37 work (31% functional)

______________________________________________________________________

## IWE Built-in Keybindings Analysis

### Current Configuration (SUBOPTIMAL)

**File**: `lua/plugins/lsp/iwe.lua` lines 79-86

```lua
mappings = {
  enable_markdown_mappings = true,      -- ✅ ENABLED: -, <C-n>, <C-p>, /d, /w
  enable_telescope_keybindings = false, -- ❌ DISABLED: gf, gs, ga, g/, gb, go
  enable_lsp_keybindings = false,       -- ❌ DISABLED: <leader>h, <leader>l
  enable_preview_keybindings = false,   -- ❌ DISABLED: preview operations
  leader = "<leader>",
  localleader = "<localleader>",
},
```

**Problem**: IWE provides **built-in keybindings** that are intentionally disabled, then custom implementations were created in the centralized system (now deleted). Result: NEITHER IWE built-ins NOR custom implementations work.

### IWE Built-in Keybindings Available

**Source**: `/home/percy/.local/share/nvim/lazy/iwe.nvim/README.md` lines 149-200

#### 1. Markdown Editing (CURRENTLY ENABLED)

```
-        → Format current line as checklist item
<C-n>    → Navigate to next link
<C-p>    → Navigate to previous link
/d       → Insert current date
/w       → Insert current week
```

**Status**: ✅ Working (enable_markdown_mappings = true)

#### 2. Telescope Navigation (CURRENTLY DISABLED)

```
gf       → Find files (IWE project-wide)
gs       → Workspace symbols (paths)
ga       → Namespace symbols (roots)
g/       → Live grep search
gb       → LSP references (backlinks)
go       → Document symbols (headers)
```

**Status**: ❌ Disabled (enable_telescope_keybindings = false) **Custom overlap**: zettelkasten.lua has find_notes(), backlinks() functions that implement similar functionality **Recommendation**: ENABLE IWE built-ins, remove custom implementations

#### 3. IWE LSP Refactoring (CURRENTLY DISABLED)

```
<leader>h → Rewrite list section (refactor)
<leader>l → Rewrite section list (refactor)
```

**Status**: ❌ Disabled (enable_lsp_keybindings = false) **Custom overlap**: zettelkasten.lua has extract_section(), inline_section() with <leader>zre, <leader>zri bindings (but those don't exist anymore) **Recommendation**: ENABLE IWE built-ins OR implement custom bindings (not both)

#### 4. Standard Neovim LSP (AVAILABLE WHEN IWES ATTACHED)

```
gD        → Go to declaration
gd        → Go to definition
gi        → Go to implementation
gr        → Show references
K         → Show hover documentation
<C-k>     → Show signature help (insert mode)
[d        → Go to previous diagnostic
]d        → Go to next diagnostic
<leader>ca → Show code actions
<leader>rn → Rename symbol
```

**Status**: ✅ Available automatically (standard LSP integration) **Note**: These work when iwes LSP server is attached to markdown buffers

### Keybinding Overlap Analysis

**Overlap Between IWE Built-ins and Custom Implementations**:

| Function        | IWE Built-in               | Custom (DELETED)                | Current Status               |
| --------------- | -------------------------- | ------------------------------- | ---------------------------- |
| Find notes      | `gf` (find_files)          | `<leader>zf` (find_notes)       | ❌ Both disabled             |
| Backlinks       | `gb` (backlinks)           | `<leader>zb` (backlinks)        | ❌ Both disabled             |
| Grep notes      | `g/` (grep)                | `<leader>zg` (search_notes)     | ❌ Both disabled             |
| Follow link     | `gd` (LSP definition)      | `<leader>zl` (follow_link)      | ⚠️ LSP works, custom deleted |
| Insert link     | `<leader>ca` (code action) | `<leader>zk` (insert_link)      | ⚠️ LSP works, custom deleted |
| Extract section | IWE code action            | `<leader>zre` (extract_section) | ❌ Both disabled             |
| Inline section  | IWE code action            | `<leader>zri` (inline_section)  | ❌ Both disabled             |

**Key Insight**: Custom implementations were REDUNDANT - they wrapped IWE LSP operations. Enabling IWE built-in keybindings would restore functionality WITHOUT custom code.

______________________________________________________________________

## Workflow Misalignment Assessment

### Documented vs Actual Workflow

**Documented Workflow** (from memories, tutorials, quick references):

```
ZETTELKASTEN (Primary - 50+ uses/session):
<leader>zn  → New note (quick capture thought)
<leader>zd  → Daily note (today's journal)
<leader>zi  → Inbox note (raw capture)
<leader>zf  → Find notes (fuzzy search)
<leader>zg  → Grep notes (content search)
<leader>zb  → Backlinks (who links here?)
<leader>zt  → Tags browser (explore by tag)
<leader>zc  → Calendar picker (±30 days)
<leader>pqp → Publish to Quartz digital garden

IWE REFACTORING (<leader>zr* namespace):
<leader>zre → Extract section to new note
<leader>zri → Inline section from note
<leader>zrn → Normalize links (CLI)
<leader>zrp → Show pathways (graph)
<leader>zrc → Show contents (TOC)
<leader>zrs → Squash notes (merge)
```

**Actual Workflow** (what currently works):

```
ZETTELKASTEN:
:PercyNew      → New note (10+ keystrokes, breaks flow)
:PercyDaily    → Daily note (12 keystrokes)
:PercyInbox    → Inbox note (12 keystrokes)
:PercyPublish  → Publish (14 keystrokes)
(no shortcuts for find, grep, backlinks, tags, calendar, refactoring)

WORKAROUNDS:
gd             → Follow link (standard LSP, works)
<leader>ca     → Code actions menu (includes extract/inline if cursor positioned correctly)
```

**User Experience Impact**:

| Task            | Documented Method      | Current Method               | Difference       |
| --------------- | ---------------------- | ---------------------------- | ---------------- |
| Create note     | `<leader>zn` (3 keys)  | `:PercyNew<CR>` (10 keys)    | +233% keystrokes |
| Find note       | `<leader>zf` (3 keys)  | No method available          | ∞                |
| View backlinks  | `<leader>zb` (3 keys)  | No method available          | ∞                |
| Daily journal   | `<leader>zd` (3 keys)  | `:PercyDaily<CR>` (12 keys)  | +300% keystrokes |
| Extract section | `<leader>zre` (4 keys) | `<leader>ca` + navigate menu | Inconsistent UX  |

**Cognitive Load Analysis**:

1. **Before (centralized system)**: User learns 14 namespace prefixes, which-key shows options, muscle memory develops
2. **After (broken state)**: User must remember :commands, no discovery mechanism, typing breaks flow
3. **ADHD Impact**: Higher cognitive load (command names vs patterns), flow state disruption (typing vs shortcuts), no predictable muscle memory

______________________________________________________________________

## Recommended Solution

### Strategy: Complete Lazy.nvim Native Migration + Enable IWE Built-ins

**Rationale**:

1. ✅ Aligns with stated refactor goal (lazy.nvim native approach)
2. ✅ Reduces custom code (use IWE built-ins where possible)
3. ✅ Maintains lazy-loading benefits (plugins load on keypress)
4. ✅ Simpler architecture (no central registry complexity)
5. ✅ Follows lazy.nvim best practices (keys = {} colocated with functionality)

### Three-Phase Implementation

#### Phase 1: Enable IWE Built-in Keybindings (IMMEDIATE - P0)

**File**: `lua/plugins/lsp/iwe.lua` lines 79-86

**Change**:

```lua
mappings = {
  enable_markdown_mappings = true,      -- Keep
  enable_telescope_keybindings = true,  -- ENABLE (gf, gs, ga, g/, gb, go)
  enable_lsp_keybindings = false,       -- Keep disabled (conflicts with <leader>h prose, <leader>l lynx)
  enable_preview_keybindings = false,   -- Consider enabling if no conflicts
  leader = "<leader>",
  localleader = "<localleader>",
},
```

**Result**: Immediately restores 6 navigation operations (gf find, gb backlinks, g/ grep, etc.)

**Trade-off**: Uses `g*` namespace instead of `<leader>z*` (different from documented workflow, but functional)

#### Phase 2: Add Critical Zettelkasten Keybindings (HIGH - P1)

**Create virtual plugin** with zettelkasten keybindings:

**File**: `lua/plugins/zettelkasten/keybindings.lua` (NEW)

```lua
return {
  dir = vim.fn.stdpath("config") .. "/lua/config",
  name = "zettelkasten-keybindings",
  lazy = false,
  keys = {
    -- Creation (uses functions from config.zettelkasten)
    {
      "<leader>zn",
      function() require("config.zettelkasten").new_note() end,
      desc = "Zettelkasten: New note",
    },
    {
      "<leader>zd",
      function() require("config.zettelkasten").daily_note() end,
      desc = "Zettelkasten: Daily note",
    },
    {
      "<leader>zi",
      function() require("config.zettelkasten").inbox_note() end,
      desc = "Zettelkasten: Inbox capture",
    },

    -- Tags & Calendar (custom Telescope implementations)
    {
      "<leader>zt",
      function() require("config.zettelkasten").show_tags() end,
      desc = "Zettelkasten: Tags browser",
    },
    {
      "<leader>zc",
      function() require("config.zettelkasten").show_calendar() end,
      desc = "Zettelkasten: Calendar picker",
    },

    -- Publishing
    {
      "<leader>zp",
      function() require("config.zettelkasten").publish() end,
      desc = "Publish: Quartz digital garden",
    },

    -- IWE refactoring (code action wrappers)
    {
      "<leader>zre",
      function() require("config.zettelkasten").extract_section() end,
      desc = "IWE: Extract section",
    },
    {
      "<leader>zri",
      function() require("config.zettelkasten").inline_section() end,
      desc = "IWE: Inline section",
    },
    {
      "<leader>zrn",
      function() require("config.zettelkasten").normalize_links() end,
      desc = "IWE: Normalize links (CLI)",
    },
    {
      "<leader>zrp",
      function() require("config.zettelkasten").show_pathways() end,
      desc = "IWE: Show pathways",
    },
    {
      "<leader>zrc",
      function() require("config.zettelkasten").show_contents() end,
      desc = "IWE: Show contents",
    },
    {
      "<leader>zrs",
      function() require("config.zettelkasten").squash_notes() end,
      desc = "IWE: Squash notes",
    },
  },
}
```

**Pattern**: Virtual plugin (no actual plugin to load) with keys = {} spec that calls config.zettelkasten functions.

**Result**: Restores 12 essential Zettelkasten keybindings aligned with documented workflow.

#### Phase 3: Complete Remaining Plugins (MEDIUM - P2)

**Add keys = {} to remaining critical plugins**:

1. **Telescope** (`lua/plugins/zettelkasten/telescope.lua`):

   - Replace TODO comment with keys = {}
   - Add <leader>ff, <leader>fg, <leader>fb, <leader>fk, <leader>fh

2. **GTD** (`lua/plugins/utilities/gtd.lua`):

   - Add <leader>oc, <leader>op, <leader>oi

3. **Window manager** (create `lua/plugins/navigation/window-keys.lua`):

   - 26 window operations documented in memories

4. **Quartz publishing** (`lua/plugins/publishing/quartz.lua`):

   - 3 publishing operations

5. **Lynx** (`lua/plugins/experimental/lynx-wiki.lua`):

   - 4 citation operations

6. **Trouble** (`lua/plugins/diagnostics/trouble.lua`):

   - 6 diagnostic operations

7. **AI visual mode** (already exists in memories):

   - 6 AI transform operations in visual mode

**Total**: ~60 additional keybindings across 7 plugin files.

### Keybinding Namespace Allocation

**Proposed Final State** (after migration complete):

| Namespace           | Count | Plugin/Location           | Notes                      |
| ------------------- | ----- | ------------------------- | -------------------------- |
| `<leader>z*`        | 12    | zettelkasten-keybindings  | Custom implementations     |
| `g*`                | 6     | IWE built-in              | gf, gs, ga, g/, gb, go     |
| `<leader>g*`        | 20    | fugitive                  | ✅ Already working         |
| `<leader>h*`        | 8     | gitsigns                  | ✅ Already working (hunks) |
| `<leader>a*`        | 7     | ollama                    | ✅ Already working         |
| `<leader>f*`        | 5     | telescope                 | TODO: add keys = {}        |
| `<leader>o*`        | 3     | gtd                       | TODO: add keys = {}        |
| `<leader>w*`        | 26    | window-keys               | TODO: create plugin        |
| `<leader>pq*`       | 4     | quartz                    | TODO: create quartz.lua    |
| `<leader>l*`        | 4     | lynx                      | TODO: add keys = {}        |
| `<leader>x*`        | 6     | trouble                   | TODO: add keys = {}        |
| `<leader>t*`        | 10    | terminal/translation/time | TODO: add keys = {}        |
| Visual `<leader>z*` | 4     | visual-zettelkasten       | ✅ Already exists          |
| Visual `<leader>a*` | 6     | AI transforms             | TODO: verify               |
| Core                | 10    | init.lua                  | ✅ Already working         |

**Total**: ~130 keybindings (more than documented 121 - includes recent additions)

______________________________________________________________________

## Migration Checklist

### ✅ Phase 1: IWE Built-ins (P0 - Immediate)

- [ ] Enable `enable_telescope_keybindings = true` in iwe.lua
- [ ] Test navigation: gf (find), gb (backlinks), g/ (grep)
- [ ] Update QUICK_REFERENCE.md with IWE built-in shortcuts
- [ ] Update which-key labels if needed

### ⏸️ Phase 2: Zettelkasten Core (P1 - High Priority)

- [ ] Create `lua/plugins/zettelkasten/keybindings.lua`
- [ ] Add 12 keybindings (zn, zd, zi, zt, zc, zp, zre, zri, zrn, zrp, zrc, zrs)
- [ ] Test all operations end-to-end
- [ ] Update KEYBINDINGS_REFERENCE.md

### ⏸️ Phase 3: Remaining Plugins (P2 - Medium Priority)

- [ ] Telescope: add keys = {} (ff, fg, fb, fk, fh)
- [ ] GTD: add keys = {} (oc, op, oi)
- [ ] Window manager: create window-keys.lua (26 operations)
- [ ] Quartz: create quartz.lua with keys = {} (4 operations: publish, preview, build, sync)
- [ ] Lynx: add keys = {} (4 operations)
- [ ] Trouble: add keys = {} (6 operations)
- [ ] Terminal/translation/time: add keys = {} (~10 operations)
- [ ] Verify visual mode AI operations

### 📝 Documentation Updates

- [ ] Update CLAUDE.md with current keybinding architecture
- [ ] Archive obsolete memory: keymap_architecture_patterns (mark as historical)
- [ ] Create new memory: lazy_nvim_native_keybindings_2025-10-23
- [ ] Update QUICK_REFERENCE.md with all working shortcuts
- [ ] Update KEYBINDINGS_REFERENCE.md with migration notes

### 🧪 Validation

- [ ] Run `:checkhealth` - verify no errors
- [ ] Test primary workflow: new note → link → find → backlinks
- [ ] Verify which-key discovery shows correct keybindings
- [ ] Performance test: lazy-loading works on keypress
- [ ] User acceptance: 5-minute real-world Zettelkasten session

______________________________________________________________________

## Alternative Approaches Considered

### ❌ Option A: Revert Centralized System

**Approach**: `git revert 7a6ca78` to restore lua/config/keymaps/

**Pros**:

- Instant restoration of all 121 keybindings
- Conflict detection registry restored
- ADHD-optimized hierarchical organization

**Cons**:

- Re-introduces "over-engineering" that was explicitly removed
- Loses lazy-loading benefits
- Contradicts stated refactor goal
- Maintenance burden returns (create file + update init + prevent plugin keys)

**Verdict**: ❌ **Rejected** - Goes against commit intent, loses simplification benefits

### ⚠️ Option B: Hybrid Approach

**Approach**: Core operations in init.lua, plugin-specific in keys = {}

**Pros**:

- Flexible middle ground
- No registry complexity
- Still lazy-loading where applicable

**Cons**:

- Inconsistent pattern (some in init, some in plugins)
- No clear organization principle
- Discovery harder (hunt in multiple places)
- Doesn't solve IWE built-in overlap

**Verdict**: ⚠️ **Possible but suboptimal** - Use only if lazy.nvim native approach fails

### ✅ Option C: Complete Lazy.nvim Native Migration (RECOMMENDED)

**Approach**: Add keys = {} to all relevant plugins, enable IWE built-ins

**Pros**:

- ✅ Aligns with commit 7a6ca78 stated goal
- ✅ Simpler architecture (no central registry)
- ✅ Lazy-loading performance benefits
- ✅ Self-documenting (read plugin = see keys)
- ✅ Reduces custom code (use IWE built-ins)
- ✅ Follows lazy.nvim best practices

**Cons**:

- Requires implementing ~100 keybindings across 15-20 files
- Medium effort (estimated 4-6 hours of work)
- No centralized conflict detection (rely on which-key warnings)

**Verdict**: ✅ **RECOMMENDED** - Best long-term solution, aligns with architecture goals

______________________________________________________________________

## Risk Assessment

### High Risk (Immediate Action Required)

**1. User Workflow Completely Broken**

- **Risk**: Users following tutorials/documentation encounter non-functional shortcuts
- **Impact**: Frustration, loss of confidence in system, workflow abandonment
- **Mitigation**: Phase 1 (enable IWE built-ins) provides immediate partial restoration

**2. Documentation Drift**

- **Risk**: Memories, tutorials, quick references document phantom keybindings
- **Impact**: Confusion, time wasted troubleshooting "broken" features that don't exist
- **Mitigation**: Update all docs immediately after Phase 1, mark memory as historical

**3. Muscle Memory Disruption**

- **Risk**: Users accustomed to documented shortcuts experience broken workflow
- **Impact**: ADHD users particularly affected - unpredictable behavior increases cognitive load
- **Mitigation**: Provide migration guide showing :commands as temporary workaround

### Medium Risk (Address in Phase 2-3)

**4. Incomplete Migration**

- **Risk**: Migration stalls again, leaving system in partially-broken state
- **Impact**: Recurring tech debt, user frustration
- **Mitigation**: Create GitHub issue, assign priority, track in project board

**5. Keybinding Conflicts**

- **Risk**: Without central registry, conflicts possible between plugins
- **Impact**: Silent overrides, unpredictable behavior
- **Mitigation**: Use which-key warnings, document namespace ownership

### Low Risk (Monitor)

**6. IWE Built-in Limitations**

- **Risk**: IWE built-ins may not perfectly match custom implementation UX
- **Impact**: Minor workflow adjustments needed
- **Mitigation**: User feedback loop, document differences, provide alternatives

______________________________________________________________________

## Success Criteria

### ✅ Phase 1 Complete When:

1. IWE telescope keybindings enabled (gf, gb, g/ work in markdown files)
2. Users can navigate Zettelkasten via IWE shortcuts
3. Documentation updated to reflect IWE built-in usage
4. Zero critical workflow blockers

### ✅ Phase 2 Complete When:

1. All essential Zettelkasten operations have <leader>z\* shortcuts
2. Custom implementations (calendar, tags) accessible via shortcuts
3. IWE refactoring operations (<leader>zr\*) functional
4. 5-minute real-world Zettelkasten session smooth

### ✅ Phase 3 Complete When:

1. All documented namespaces implemented (f, o, w, p, l, x, t)
2. Parity with pre-refactor functionality (100+ keybindings)
3. Which-key shows complete namespace structure
4. Documentation 100% accurate to implementation
5. Zero TODOs in plugin keybinding specs

### ✅ Migration Fully Successful When:

1. User workflow restored to "speed of thought" efficiency
2. ADHD optimizations preserved (predictable patterns, muscle memory)
3. Lazy-loading benefits realized (faster startup, keypress plugin loading)
4. Simpler architecture achieved (no central registry complexity)
5. User satisfaction: 5/5 on workflow smoothness survey

______________________________________________________________________

## Timeline Estimate

**Phase 1** (Enable IWE built-ins): 30 minutes

- Change 1 line in iwe.lua
- Test navigation operations
- Update documentation

**Phase 2** (Zettelkasten core): 2-3 hours

- Create zettelkasten-keybindings.lua plugin
- Implement 12 keybindings
- Test end-to-end workflow
- Update docs

**Phase 3** (Remaining plugins): 3-4 hours

- Add keys = {} to 7 plugin files
- Implement ~60 keybindings
- Test each namespace
- Complete documentation

**Total Effort**: 6-8 hours over 2-3 sessions

**Recommended Schedule**:

- **Session 1** (today): Phase 1 + start Phase 2 (3 hours)
- **Session 2** (tomorrow): Complete Phase 2 (2 hours)
- **Session 3** (next week): Phase 3 (4 hours)

______________________________________________________________________

## Conclusion

The keybinding architecture is in a **critical failure state** due to an incomplete migration. The centralized registry system was removed with good intentions (simplification, lazy-loading), but the migration to lazy.nvim native approach was abandoned after only 3% completion (2/65 plugins migrated).

**Impact on User**: Primary Zettelkasten workflow is broken. Documented shortcuts don't work. "Speed of thought knowledge management" philosophy is violated - users must type `:Percy*` commands (10+ keystrokes) instead of using shortcuts (3 keystrokes).

**Recommended Solution**: Complete the lazy.nvim native migration by:

1. **Immediately** enabling IWE built-in keybindings (restores 6 navigation ops)
2. **High priority** adding zettelkasten-keybindings.lua (restores 12 core ops)
3. **Medium priority** completing remaining plugins (adds ~60 ops)

This approach aligns with the stated refactor goal, maintains simplification benefits, and fully restores workflow functionality. Estimated effort: 6-8 hours over 3 sessions.

**Status**: Analysis complete. Awaiting user approval to proceed with Phase 1 implementation.

______________________________________________________________________

## Appendices

### A. Git History Context

```
commit 7a6ca78 (Oct 23, 2025 - TODAY)
refactor: remove centralized keybinding system, use lazy.nvim native approach

BREAKING CHANGE: Complete removal of centralized keymap registry system.
Keybindings now managed per-plugin using lazy.nvim's native keys = {} spec.

Removed: lua/config/keymaps/ entire directory (23 files, ~1500 lines)
Impact: Much simpler architecture, easier maintenance, better lazy loading
Plan: Remaining plugin keybindings can be migrated incrementally

-1,474 lines deleted
```

### B. IWE Built-in Keybindings Reference

**Source**: `/home/percy/.local/share/nvim/lazy/iwe.nvim/README.md`

**Telescope Navigation** (enable_telescope_keybindings = true):

- `gf` - Find files (project-wide search)
- `gs` - Workspace symbols (all paths in project)
- `ga` - Namespace symbols (root-level entries)
- `g/` - Live grep (content search across notes)
- `gb` - LSP references (backlinks to current file)
- `go` - Document symbols (headers in current file)

**LSP Refactoring** (enable_lsp_keybindings = true):

- `<leader>h` - Rewrite list section
- `<leader>l` - Rewrite section list

**Markdown Editing** (enable_markdown_mappings = true):

- `-` - Format line as checklist
- `<C-n>` - Next link
- `<C-p>` - Previous link
- `/d` - Insert date
- `/w` - Insert week

### C. Function Inventory

**Functional** (config/zettelkasten.lua - business logic exists):

- new_note() - Template-based note creation
- daily_note() - Daily journal with template
- inbox_note() - Quick capture to inbox
- find_notes() - Telescope file picker
- search_notes() - Telescope live grep
- backlinks() - Telescope grep for links
- show_tags() - Tag browser with frequency counts
- show_calendar() - Calendar picker (±30 days)
- publish() - Quartz digital garden export (needs rewrite for Quartz)
- extract_section() - IWE LSP code action wrapper
- inline_section() - IWE LSP code action wrapper
- normalize_links() - IWE CLI wrapper
- show_pathways() - IWE CLI wrapper
- show_contents() - IWE CLI wrapper
- squash_notes() - IWE CLI wrapper

**Accessible Via** (workarounds until keybindings restored):

- :commands - `:PercyNew`, `:PercyDaily`, etc. (slow, breaks flow)
- IWE LSP - `gd` (follow link), `<leader>ca` (code actions)
- Direct function call - `:lua require('config.zettelkasten').new_note()`

### D. Memory Update Requirements

**Archive**:

- `keymap_architecture_patterns` - Mark as historical, pre-refactor state

**Create**:

- `lazy_nvim_native_keybindings_2025-10-23` - Document new architecture

**Update**:

- `project_overview` - Correct plugin count, keybinding architecture
- `percy_development_patterns` - New keybinding implementation pattern

______________________________________________________________________

**Report Status**: ✅ Complete **Next Action**: Await user decision on Phase 1 implementation **Questions for User**:

1. Approve Phase 1 (enable IWE built-ins)?
2. Proceed with Phase 2 (zettelkasten-keybindings.lua)?
3. Timeline preference (all phases at once vs incremental)?
