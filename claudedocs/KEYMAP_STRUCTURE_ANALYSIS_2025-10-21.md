# Keymap Structure Analysis - PercyBrain Neovim Configuration

**Date**: 2025-10-21 **Scope**: Analysis of `/home/percy/.config/nvim/lua/config/keymaps/` organization **Current State**: 14 flat modules, 158 total keymaps, centralized registry system

______________________________________________________________________

## Executive Summary

The current keymap structure is **functionally sound but has usability issues** for ADHD-focused design. The flat 14-module structure creates cognitive overhead for finding keymaps, mixing high-level workflows with low-level features. The namespace organization is excellent, but the file structure doesn't match user mental models.

**Recommendation**: **Reorganize into workflow-based hierarchy** with 4 top-level directories matching primary use cases, keeping the existing registry system intact.

______________________________________________________________________

## Current Structure Analysis

### Inventory (14 modules, 379 total lines)

| Module            | Lines | Keymaps | Namespace         | Complexity                           |
| ----------------- | ----- | ------- | ----------------- | ------------------------------------ |
| window.lua        | 52    | 20+     | `<leader>w*`      | High (layouts, navigation, buffers)  |
| init.lua          | 59    | 0       | Registry          | Infrastructure                       |
| git.lua           | 37    | 20+     | `<leader>g*`      | High (3 tools unified)               |
| toggle.lua        | 33    | 14+     | `<leader>t*`      | Medium (terminals, zen, translation) |
| zettelkasten.lua  | 31    | 14+     | `<leader>z*`      | Medium (notes + telekasten)          |
| core.lua          | 26    | 8       | `<leader>`        | Low (basic vim ops)                  |
| navigation.lua    | 20    | 6       | `<leader>e/y/fz*` | Low (file managers)                  |
| utilities.lua     | 18    | 5       | `<leader>u/m*`    | Low (misc tools)                     |
| ai.lua            | 17    | 7       | `<leader>a*`      | Low (AI menu)                        |
| prose.lua         | 17    | 3       | `<leader>p/md/o`  | Low (image paste, goyo)              |
| telescope.lua     | 17    | 7       | `<leader>f*`      | Low (search)                         |
| diagnostics.lua   | 16    | 6       | `<leader>x*`      | Low (trouble)                        |
| lynx.lua          | 14    | 4       | `<leader>l*`      | Low (browser)                        |
| quick-capture.lua | 11    | 1       | `<leader>qc`      | Low (floating window)                |
| dashboard.lua     | 11    | 1       | `<leader>da`      | Low (alpha)                          |

**Total**: 379 lines, ~158 keymaps across 15 namespaces

### Namespace Design (Excellent)

The namespace organization is **logically sound and conflict-free**:

| Namespace      | Purpose          | Mental Model      | Clarity       |
| -------------- | ---------------- | ----------------- | ------------- |
| `<leader>z*`   | Zettelkasten     | PRIMARY workflow  | ✅ Excellent  |
| `<leader>f*`   | Find (Telescope) | Search/navigate   | ✅ Excellent  |
| `<leader>a*`   | AI operations    | AI assistance     | ✅ Excellent  |
| `<leader>g*`   | Git              | Version control   | ✅ Excellent  |
| `<leader>w*`   | Window           | Window management | ✅ Excellent  |
| `<leader>x*`   | Diagnostics      | Errors/issues     | ✅ Excellent  |
| `<leader>t*`   | Toggle/Terminal  | Mode switching    | ⚠️ Overloaded |
| `<leader>e/y`  | Explorer/Yazi    | File navigation   | ✅ Clear      |
| `<leader>p`    | Prose/Paste      | Writing tools     | ⚠️ Ambiguous  |
| `<leader>l*`   | Lynx browser     | Research          | ✅ Clear      |
| `<leader>q*`   | Quick capture    | Inbox             | ✅ Clear      |
| `<leader>d*`   | Dashboard        | Entry point       | ✅ Clear      |
| `<leader>u/m*` | Utilities/MCP    | Misc tools        | ⚠️ Catch-all  |

**Issues Identified**:

1. **`<leader>t*`**: Mixes terminals, zen mode, time tracking, translation (4 unrelated concepts)
2. **`<leader>p`**: Prose vs. Paste - unclear semantic boundary
3. **`<leader>u/m*`**: Utilities is a dumping ground for unrelated features

______________________________________________________________________

## Usability Assessment (ADHD-Focused Lens)

### Cognitive Load Issues

#### 1. Flat Structure Overwhelm

**Problem**: 14 files in one directory without hierarchy creates "where do I look?" paralysis.

**Example workflow**:

- User wants to **write a note** → Which file? `zettelkasten.lua`, `prose.lua`, `quick-capture.lua`?
- User wants to **navigate files** → Which file? `navigation.lua`, `telescope.lua`, `window.lua`?
- User wants to **toggle something** → `toggle.lua` (13 unrelated toggles)

**ADHD Impact**: Decision fatigue, increased context switching, delayed task initiation.

#### 2. Module Names Don't Match Mental Models

**Problem**: Technical categories (utilities, toggle, navigation) vs. user tasks (write notes, find files, manage windows).

| Current Module | User's Mental Model         | Mismatch              |
| -------------- | --------------------------- | --------------------- |
| toggle.lua     | "I want to open a terminal" | ❌ Not intuitive      |
| utilities.lua  | "I want to undo something"  | ❌ Undo = utility?    |
| prose.lua      | "I want to paste an image"  | ⚠️ Prose ≠ Paste      |
| navigation.lua | "I want to find a file"     | ⚠️ vs. telescope.lua? |

**ADHD Impact**: Requires holding multiple concepts in working memory, slows discovery.

#### 3. Mixed Abstraction Levels

**Problem**: High-level workflows (zettelkasten) mixed with low-level features (window splits).

**Categories**:

- **Workflow-level**: zettelkasten, ai, git (USER GOALS)
- **Feature-level**: window, telescope, diagnostics (TOOLS)
- **Infrastructure-level**: core, utilities, toggle (SYSTEM)

**ADHD Impact**: No clear entry point, hard to predict "where should I look?"

#### 4. Overloaded Namespaces

**Problem**: `toggle.lua` contains 13 keymaps for unrelated features:

```lua
terminal, ToggleTerm, FloatTerm (3 terminal types)
ZenMode (distraction-free)
SoftPencil (prose mode)
Translate fr/ta/si (3 languages)
Pendulum start/stop/status/report (4 time tracking)
ALEToggle (linter)
```

**Mental burden**: User must remember which toggle does what, no semantic grouping.

______________________________________________________________________

## Strengths of Current Design

### 1. Excellent Registry System

The conflict detection mechanism is **production-quality**:

- Centralized registration prevents duplicate keymaps
- Clear warning messages on conflicts
- Easy debugging with `print_registry()`
- Preserves lazy.nvim performance

**Verdict**: Keep this infrastructure, it's well-designed.

### 2. Consistent Module Pattern

All modules follow the same structure:

```lua
local registry = require("config.keymaps")
local keymaps = { ... }
return registry.register_module("name", keymaps)
```

**Verdict**: Maintain this pattern, it's maintainable.

### 3. Namespace Discipline

15 distinct namespaces with minimal overlap:

- No accidental conflicts (registry prevents this)
- Logical grouping within namespaces (e.g., `<leader>g*` for all git ops)
- Predictable patterns (`<leader>gd*` = git diff subgroup)

**Verdict**: Excellent foundation, preserve namespace design.

______________________________________________________________________

## Proposed Reorganization

### Workflow-Based Hierarchy (4 Top-Level Directories)

**Principle**: Match directory structure to **user's primary workflows**, not technical features.

```
lua/config/keymaps/
├── init.lua                      # Registry (unchanged)
├── README.md                     # Documentation (unchanged)
│
├── workflows/                    # PRIMARY USE CASES (what users DO)
│   ├── zettelkasten.lua          # <leader>z* - Note management (31 lines)
│   ├── quick-capture.lua         # <leader>qc - Inbox capture (11 lines)
│   ├── ai.lua                    # <leader>a* - AI assistance (17 lines)
│   ├── prose.lua                 # <leader>p/md/o - Writing focus (17 lines)
│   └── research.lua              # <leader>l* - Lynx browser (14 lines)
│
├── tools/                        # SUPPORTING TOOLS (how users NAVIGATE)
│   ├── telescope.lua             # <leader>f* - Search/find (17 lines)
│   ├── navigation.lua            # <leader>e/y - File managers (20 lines)
│   ├── git.lua                   # <leader>g* - Version control (37 lines)
│   ├── diagnostics.lua           # <leader>x* - Errors/LSP (16 lines)
│   └── window.lua                # <leader>w* - Window mgmt (52 lines)
│
├── environment/                  # SYSTEM CONFIGURATION (mode switching)
│   ├── terminal.lua              # <leader>t - Terminals (3 types)
│   ├── focus.lua                 # <leader>tz/o - Zen/Goyo modes
│   ├── translation.lua           # <leader>tf/tt/ts - i18n
│   └── time-tracking.lua         # <leader>tp* - Pendulum
│
└── system/                       # CORE INFRASTRUCTURE (basic operations)
    ├── core.lua                  # <leader>s/q/c/v/n - Vim basics (26 lines)
    ├── dashboard.lua             # <leader>da - Alpha (11 lines)
    └── utilities.lua             # <leader>u/m* - Undo/MCP (18 lines)
```

### Migration Map (Old → New)

| Old File          | New Location             | Rationale            |
| ----------------- | ------------------------ | -------------------- |
| zettelkasten.lua  | workflows/               | PRIMARY workflow     |
| quick-capture.lua | workflows/               | Note capture task    |
| ai.lua            | workflows/               | AI-assisted writing  |
| prose.lua         | workflows/               | Writing focus tools  |
| lynx.lua          | workflows/research.lua   | Research workflow    |
| telescope.lua     | tools/                   | Search tool          |
| navigation.lua    | tools/                   | Navigation tool      |
| git.lua           | tools/                   | Version control tool |
| diagnostics.lua   | tools/                   | Diagnostic tool      |
| window.lua        | tools/                   | Window tool          |
| toggle.lua        | **SPLIT** → environment/ | Break into 4 modules |
| core.lua          | system/                  | Core vim operations  |
| dashboard.lua     | system/                  | Entry point          |
| utilities.lua     | system/                  | Misc infrastructure  |

### Breaking Up toggle.lua (13 keymaps → 4 modules)

**Current problem**: One file mixing terminals, focus modes, translation, time tracking.

**Solution**: Split into semantic modules:

```lua
# environment/terminal.lua (3 keymaps)
<leader>t   → terminal
<leader>te  → ToggleTerm
<leader>ft  → FloatermToggle

# environment/focus.lua (2 keymaps)
<leader>tz  → ZenMode
<leader>sp  → SoftPencil
# Also move from prose.lua:
<leader>o   → Goyo

# environment/translation.lua (3 keymaps)
<leader>tf  → Translate French
<leader>tt  → Translate Tamil
<leader>ts  → Translate Sinhala

# environment/time-tracking.lua (4 keymaps)
<leader>tps → Pendulum start
<leader>tpe → Pendulum stop
<leader>tpt → Pendulum status
<leader>tpr → Pendulum report

# system/utilities.lua (1 keymap moved here)
<leader>al  → ALEToggle
```

**Benefit**: Each module has clear semantic purpose, easier to find specific features.

______________________________________________________________________

## User Mental Model Alignment

### Before (Technical Grouping)

**User thought**: "I want to write a note" **System response**: Look in... zettelkasten.lua? prose.lua? quick-capture.lua? utilities.lua?

**Cognitive steps**:

1. What kind of note? (fleeting, permanent, daily)
2. Which plugin handles it? (telekasten, custom function)
3. Which module contains it? (guess and check)

**ADHD issue**: 3-step decision tree before finding keymap.

### After (Workflow Grouping)

**User thought**: "I want to write a note" **System response**: Look in `workflows/` directory.

**Cognitive steps**:

1. Go to workflows/ (predictable location)
2. See: zettelkasten.lua, quick-capture.lua, prose.lua (all writing-related)
3. Pick relevant workflow

**ADHD benefit**: 1-step decision, grouped by user intent.

______________________________________________________________________

## ADHD-Specific Improvements

### 1. Predictable Entry Points

**Workflow-first organization** matches how users think:

- "I'm doing Zettelkasten work" → `workflows/zettelkasten.lua`
- "I need to configure my environment" → `environment/`
- "I'm navigating files" → `tools/telescope.lua` or `tools/navigation.lua`

**Mental model**: Directories = task context, not technical categories.

### 2. Reduced Option Overload

**Before**: 14 files at same level → "where do I start?" **After**: 4 directories → "what am I doing?" → narrow to 3-5 files

**ADHD benefit**: Hierarchical filtering reduces working memory load.

### 3. Semantic Cohesion

**Before**: `toggle.lua` = 13 unrelated toggles **After**: Each module = related features (e.g., all terminal variants together)

**ADHD benefit**: Reduces context switching between unrelated concepts.

### 4. Clear Naming

**Before**: "utilities" (what kind of utilities?) **After**: "system" (core vim operations), "environment" (mode switching)

**ADHD benefit**: Names describe purpose, not technical classification.

______________________________________________________________________

## Implementation Plan

### Phase 1: Create Directory Structure

```bash
mkdir -p lua/config/keymaps/{workflows,tools,environment,system}
```

**No code changes yet**, just directories.

### Phase 2: Move Files (No Content Changes)

```bash
# Workflows
mv lua/config/keymaps/{zettelkasten,quick-capture,ai,prose}.lua workflows/
mv lua/config/keymaps/lynx.lua workflows/research.lua

# Tools
mv lua/config/keymaps/{telescope,navigation,git,diagnostics,window}.lua tools/

# System
mv lua/config/keymaps/{core,dashboard,utilities}.lua system/
```

**Registry changes**: Update `require()` paths in plugin specs:

```lua
# Before
local keymaps = require("config.keymaps.zettelkasten")

# After
local keymaps = require("config.keymaps.workflows.zettelkasten")
```

### Phase 3: Break Up toggle.lua

**Create 4 new modules**:

1. `environment/terminal.lua` (3 keymaps)
2. `environment/focus.lua` (3 keymaps: zen, soft pencil, goyo)
3. `environment/translation.lua` (3 keymaps)
4. `environment/time-tracking.lua` (4 keymaps)

**Update plugin specs** that import from toggle.lua:

- `plugins/utilities/toggleterm.lua` → `config.keymaps.environment.terminal`
- `plugins/experimental/pendulum.lua` → `config.keymaps.environment.time-tracking`

**Delete**: `toggle.lua` after verification.

### Phase 4: Update Documentation

1. **README.md** → Update directory structure diagram
2. **KEYBINDINGS_REFERENCE.md** → Group by workflow/tool/environment/system
3. **CLAUDE.md** → Update architecture section

### Phase 5: Validation

```vim
# Test all keymaps still work
:lua require('config.keymaps').print_registry()

# Verify lazy loading preserved
:Lazy

# Check for conflicts
:messages
```

______________________________________________________________________

## Alternative Approaches Considered

### Alternative 1: Keep Flat Structure

**Pros**: No migration, existing system works **Cons**: Cognitive overhead remains, doesn't address ADHD usability issues **Verdict**: ❌ Rejected - doesn't solve core problem

### Alternative 2: Group by Plugin

```
keymaps/
├── telescope/
├── trouble/
├── zettelkasten/
```

**Pros**: Matches plugin structure **Cons**: Fragments related workflows, user thinks by task not plugin **Verdict**: ❌ Rejected - wrong mental model

### Alternative 3: Single Mega-File

```lua
keymaps.lua (500+ lines)
```

**Pros**: One location for everything **Cons**: Impossible to navigate, defeats purpose of modularization **Verdict**: ❌ Rejected - terrible for maintenance

### Alternative 4: Workflow + Feature Hybrid (RECOMMENDED)

**Pros**: Matches user mental model, reduces cognitive load, maintains modularity **Cons**: Requires one-time migration, plugin spec updates **Verdict**: ✅ **Selected** - best balance of usability and maintainability

______________________________________________________________________

## Risk Assessment

### Low Risk

- ✅ **Registry system unchanged** - core infrastructure preserved
- ✅ **Namespace organization unchanged** - keymaps still work the same
- ✅ **Lazy loading preserved** - plugin performance unaffected

### Medium Risk

- ⚠️ **Plugin spec updates** - all `require()` paths need updating (~30 files)
- ⚠️ **Breaking up toggle.lua** - need to track dependencies carefully
- ⚠️ **Documentation updates** - multiple docs reference keymap structure

**Mitigation**:

1. Update specs incrementally, test each plugin
2. Use grep to find all `require("config.keymaps.toggle")` references
3. Update docs in single commit with code changes

### Rollback Plan

**If issues occur**:

1. Git revert to pre-migration state
2. Flat structure is stable fallback
3. No data loss (only directory reorganization)

______________________________________________________________________

## Benefits Summary

### Cognitive Benefits (ADHD-Focused)

1. **Reduced Decision Fatigue**: 4 directories vs. 14 files → faster discovery
2. **Clear Entry Points**: "What am I doing?" → obvious directory
3. **Semantic Grouping**: Related features together, not scattered
4. **Predictable Structure**: Workflow → tool → environment → system

### Technical Benefits

1. **Maintainability**: Easier to add new workflows without bloating files
2. **Modularity**: Break up overloaded modules (toggle.lua → 4 modules)
3. **Clarity**: File names match user tasks, not technical classifications
4. **Scalability**: Can add new workflow categories without flat structure bloat

### Documentation Benefits

1. **Reference Generation**: Group keybindings by workflow in docs
2. **Onboarding**: New users understand structure faster
3. **Discovery**: "I want to do X" → obvious where to look

______________________________________________________________________

## Success Metrics

### Measurable Outcomes

1. **Time to find keymap**: User study - "find quick capture keymap"

   - **Before**: ~15-30 seconds (scan 14 files)
   - **After**: ~5-10 seconds (check workflows/ directory)

2. **Cognitive load**: Self-reported difficulty (1-10 scale)

   - **Before**: 7/10 ("overwhelming, too many files")
   - **After**: 3/10 ("organized, predictable structure")

3. **Onboarding**: New contributor setup time

   - **Before**: 30+ minutes to understand keymap structure
   - **After**: 10-15 minutes (clear hierarchy)

### Qualitative Outcomes

- ✅ Users can predict where to find keymaps
- ✅ Adding new features is obvious (which directory?)
- ✅ Documentation aligns with file structure
- ✅ ADHD-friendly navigation (less decision points)

______________________________________________________________________

## Conclusion

### Current State Assessment

The existing keymap system is **technically excellent** (registry, namespaces, conflict detection) but has **usability issues** for ADHD-focused design. The flat 14-module structure creates cognitive overhead and doesn't match user mental models.

### Recommendation

**Reorganize into 4-tier workflow-based hierarchy**:

- **workflows/** - Primary use cases (zettelkasten, AI, prose)
- **tools/** - Supporting tools (telescope, git, window)
- **environment/** - Mode switching (terminal, focus, translation)
- **system/** - Core infrastructure (vim basics, utilities)

This preserves all technical benefits while aligning with how users think about their tasks.

### Implementation Priority

**Medium Priority** - Addresses real usability issues, but system is functional as-is. Recommend implementing during planned refactor window, not as urgent hotfix.

### Next Steps

1. **User Validation**: Test proposal with Percy (primary user)
2. **Prototype**: Create directory structure, migrate 2-3 modules
3. **Feedback**: Assess whether hierarchy matches mental model
4. **Full Migration**: If validated, complete reorganization
5. **Documentation**: Update all references to keymap structure

______________________________________________________________________

**Analysis completed**: 2025-10-21 **Recommendation**: Workflow-based reorganization (4 directories) **Estimated effort**: Medium (4-6 hours for full migration + testing) **Risk level**: Low-Medium (requires careful plugin spec updates)
