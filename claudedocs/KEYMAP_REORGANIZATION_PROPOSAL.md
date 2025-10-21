# Keymap Reorganization Proposal - Quick Reference

**Date**: 2025-10-21 **Status**: PROPOSAL (awaiting user decision) **Complexity**: Medium (4-6 hours) **Risk**: Low-Medium

______________________________________________________________________

## The Problem

**Current structure** (flat 14 modules):

```
lua/config/keymaps/
├── ai.lua
├── core.lua
├── dashboard.lua
├── diagnostics.lua
├── git.lua
├── init.lua (registry)
├── lynx.lua
├── navigation.lua
├── prose.lua
├── quick-capture.lua
├── telescope.lua
├── toggle.lua          # ⚠️ OVERLOADED (13 unrelated keymaps)
├── utilities.lua
├── window.lua
└── zettelkasten.lua
```

**ADHD Usability Issues**:

1. 14 files at same level → "where do I look?" paralysis
2. Module names don't match mental models (toggle, utilities)
3. Mixed abstraction levels (workflows vs. tools vs. infrastructure)
4. Overloaded modules (toggle.lua = terminals + zen + translation + time tracking)

______________________________________________________________________

## The Solution

**Proposed structure** (4-tier hierarchy):

```
lua/config/keymaps/
├── init.lua                      # Registry (unchanged)
├── README.md                     # Documentation
│
├── workflows/                    # "I want to DO something"
│   ├── zettelkasten.lua          # <leader>z* - Notes
│   ├── quick-capture.lua         # <leader>qc - Inbox
│   ├── ai.lua                    # <leader>a* - AI assist
│   ├── prose.lua                 # <leader>p/md - Writing
│   └── research.lua              # <leader>l* - Browser (was lynx.lua)
│
├── tools/                        # "I need to NAVIGATE/FIND"
│   ├── telescope.lua             # <leader>f* - Search
│   ├── navigation.lua            # <leader>e/y - File managers
│   ├── git.lua                   # <leader>g* - Version control
│   ├── diagnostics.lua           # <leader>x* - Errors
│   └── window.lua                # <leader>w* - Window mgmt
│
├── environment/                  # "I want to CONFIGURE my workspace"
│   ├── terminal.lua              # <leader>t/te/ft - 3 terminal types
│   ├── focus.lua                 # <leader>tz/o/sp - Zen/Goyo/SoftPencil
│   ├── translation.lua           # <leader>tf/tt/ts - French/Tamil/Sinhala
│   └── time-tracking.lua         # <leader>tp* - Pendulum
│
└── system/                       # "Core VIM operations"
    ├── core.lua                  # <leader>s/q/c/v/n - Save/quit/split
    ├── dashboard.lua             # <leader>da - Alpha
    └── utilities.lua             # <leader>u/m/al - Undo/MCP/ALE
```

______________________________________________________________________

## Key Changes

### 1. Breaking Up toggle.lua (13 → 4 modules)

**Before**: One file with unrelated features **After**: 4 semantic modules

| Old        | New                           | Keymaps                                     |
| ---------- | ----------------------------- | ------------------------------------------- |
| toggle.lua | environment/terminal.lua      | `<leader>t`, `<leader>te`, `<leader>ft` (3) |
| toggle.lua | environment/focus.lua         | `<leader>tz`, `<leader>sp`, `<leader>o` (3) |
| toggle.lua | environment/translation.lua   | `<leader>tf/tt/ts` (3)                      |
| toggle.lua | environment/time-tracking.lua | `<leader>tp*` (4)                           |

### 2. Renaming for Clarity

| Old Name      | New Name             | Reason                          |
| ------------- | -------------------- | ------------------------------- |
| lynx.lua      | research.lua         | Describes user task, not plugin |
| utilities.lua | system/utilities.lua | Clarifies as infrastructure     |
| prose.lua     | workflows/prose.lua  | Clarifies as workflow           |

### 3. Moving Files (No Content Changes)

Just changing directory location, all keymaps stay the same.

______________________________________________________________________

## Migration Checklist

### Phase 1: Create Directories

```bash
cd /home/percy/.config/nvim/lua/config/keymaps
mkdir -p workflows tools environment system
```

### Phase 2: Move Existing Files

```bash
# Workflows
mv zettelkasten.lua workflows/
mv quick-capture.lua workflows/
mv ai.lua workflows/
mv prose.lua workflows/
mv lynx.lua workflows/research.lua

# Tools
mv telescope.lua tools/
mv navigation.lua tools/
mv git.lua tools/
mv diagnostics.lua tools/
mv window.lua tools/

# System
mv core.lua system/
mv dashboard.lua system/
mv utilities.lua system/
```

### Phase 3: Break Up toggle.lua

Create 4 new files from toggle.lua content:

1. `environment/terminal.lua` (3 keymaps)
2. `environment/focus.lua` (3 keymaps)
3. `environment/translation.lua` (3 keymaps)
4. `environment/time-tracking.lua` (4 keymaps)

Delete `toggle.lua` after verification.

### Phase 4: Update Plugin Specs

Find all references:

```bash
cd /home/percy/.config/nvim
grep -r 'require("config.keymaps' lua/plugins/
```

Update paths:

```lua
# Before
local keymaps = require("config.keymaps.zettelkasten")

# After
local keymaps = require("config.keymaps.workflows.zettelkasten")
```

**Affected plugins** (~30 files):

- All plugins that use centralized keymaps
- See `claudedocs/KEYMAP_CENTRALIZATION_2025-10-20.md` for list

### Phase 5: Update Documentation

- `lua/config/keymaps/README.md` - Update directory structure
- `docs/reference/KEYBINDINGS_REFERENCE.md` - Group by workflow
- `CLAUDE.md` - Update architecture section
- `PROJECT_INDEX.json` - Update file paths

### Phase 6: Testing

```vim
# Verify all keymaps registered
:lua require('config.keymaps').print_registry()

# Check lazy loading works
:Lazy

# Look for conflicts
:messages
```

______________________________________________________________________

## Benefits

### ADHD-Focused Improvements

1. **Predictable entry points**: "I'm doing Zettelkasten" → `workflows/`
2. **Reduced options**: 4 directories vs. 14 files → less decision fatigue
3. **Clear naming**: Workflow/tool/environment vs. toggle/utilities
4. **Semantic grouping**: Related features together

### Technical Benefits

1. **Modularity**: Break up overloaded files (toggle.lua → 4 modules)
2. **Maintainability**: Clear place for new features
3. **Scalability**: Add new workflows without bloat
4. **Documentation**: Structure matches user mental model

______________________________________________________________________

## Risks & Mitigation

### Low Risk

✅ Registry system unchanged ✅ Namespace organization preserved ✅ Lazy loading maintained

### Medium Risk

⚠️ Plugin spec updates (~30 files need `require()` path changes) ⚠️ Documentation updates (4+ docs reference keymap structure)

**Mitigation**:

1. Test incrementally (migrate 2-3 modules first)
2. Use grep to find all references
3. Git commit per phase for easy rollback

### Rollback Plan

If issues occur:

```bash
git revert HEAD~5  # Back to flat structure
```

Flat structure is stable, no data loss.

______________________________________________________________________

## Decision Points

### Option 1: Accept Proposal

**Action**: Implement workflow-based hierarchy **Effort**: 4-6 hours **Benefit**: Improved ADHD usability, clearer structure **Risk**: Medium (requires careful migration)

### Option 2: Modify Proposal

**Action**: Adjust directory names/grouping **Questions**:

- Different top-level categories?
- Different breakdown of toggle.lua?
- Keep some modules flat?

### Option 3: Reject Proposal

**Action**: Keep current flat structure **Benefit**: No migration effort **Trade-off**: Cognitive overhead remains

______________________________________________________________________

## Recommendation

**Accept with incremental implementation**:

1. **Prototype** (1-2 hours):

   - Create directory structure
   - Migrate 3 modules (zettelkasten, telescope, core)
   - Test for 1-2 days

2. **Evaluate**:

   - Does hierarchy match mental model?
   - Is it easier to find keymaps?
   - Any usability issues?

3. **Complete Migration** (2-4 hours):

   - If validated, migrate remaining modules
   - Break up toggle.lua
   - Update all documentation

4. **Validation** (1 hour):

   - Test all keymaps work
   - Verify lazy loading
   - Check documentation accuracy

**Total effort**: 4-7 hours **Expected outcome**: More intuitive keymap organization for ADHD-focused usage

______________________________________________________________________

## Next Steps

**Awaiting user decision**:

1. ✅ Approve proposal → Begin prototype
2. 🔄 Request modifications → Adjust structure
3. ❌ Reject proposal → Document decision, keep flat structure

**If approved**:

1. Create branch: `feature/keymap-hierarchy`
2. Implement Phase 1-2 (prototype)
3. Test for 48 hours
4. Complete migration if successful
5. Merge to main

______________________________________________________________________

**Proposal created**: 2025-10-21 **Analysis document**: `/home/percy/.config/nvim/claudedocs/KEYMAP_STRUCTURE_ANALYSIS_2025-10-21.md` **Status**: AWAITING USER DECISION
