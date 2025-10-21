# Keybinding Migration Guide (2025-10-21)

**Purpose**: Document comprehensive keybinding reorganization for writer-first workflow **Status**: Phase 1 & 2 Complete (Consolidation, Simplification & Frequency Optimization) **Impact**: 40+ keybinding changes, better alignment with PercyBrain philosophy

______________________________________________________________________

## Executive Summary

PercyBrain keybindings have been reorganized to prioritize **writers over programmers**. The core philosophy is "speed of thought" knowledge management, which requires:

**Phase 1** (Consolidation & Simplification):

1. **Unified namespaces**: All Zettelkasten operations under `<leader>z*`
2. **Writer-focused tools**: Expanded prose namespace with focus modes, word counts, timers
3. **Simplified git**: Reduced from 20+ to 11 essential operations (use LazyGit GUI for complex tasks)

**Phase 2** (Frequency Optimization & Mode Switching): 4. **Frequency-based allocation**: Most common actions (`<leader>f/n/i`) get shortest keys 5. **Mode switching**: Context-aware workspace configurations (`<leader>m*`) 6. **Speed of thought**: 50+ note operations per session deserve 1-2 keystroke access

______________________________________________________________________

## Phase 1: Critical Alignment Changes

### 1.1 Zettelkasten Consolidation (`<leader>z*`)

**Philosophy**: All note operations in ONE namespace for cognitive efficiency.

#### IWE Navigation (moved from `g*` to `<leader>z*`)

| Old Keybinding | New Keybinding | Description            | Reason                                    |
| -------------- | -------------- | ---------------------- | ----------------------------------------- |
| `gf`           | `<leader>zF`   | IWE: Find files        | Consolidation (capital F avoids conflict) |
| `gs`           | `<leader>zS`   | IWE: Workspace symbols | Consolidation                             |
| `ga`           | `<leader>zA`   | IWE: Namespace symbols | Consolidation                             |
| `g/`           | `<leader>z/`   | IWE: Live grep         | Consolidation                             |
| `gb`           | `<leader>zB`   | IWE: Backlinks (LSP)   | Consolidation (capital B for emphasis)    |
| `go`           | `<leader>zO`   | IWE: Document outline  | Consolidation                             |

**Rationale**: Previous `g*` prefix scattered navigation across global namespace. Writers need all note operations together.

#### IWE Refactoring (moved from `<leader>i*` to `<leader>zr*`)

| Old Keybinding | New Keybinding | Description            | Reason                                    |
| -------------- | -------------- | ---------------------- | ----------------------------------------- |
| `<leader>ih`   | `<leader>zrh`  | Rewrite list → heading | Consolidation into refactor sub-namespace |
| `<leader>il`   | `<leader>zrl`  | Rewrite heading → list | Consolidation into refactor sub-namespace |

**Rationale**: Refactoring notes is a Zettelkasten operation, not a separate workflow.

#### Quick Capture (moved from `<leader>q*` to `<leader>z*`)

| Old Keybinding | New Keybinding | Description              | Reason                    |
| -------------- | -------------- | ------------------------ | ------------------------- |
| `<leader>qc`   | `<leader>zq`   | Quick capture (floating) | Consolidation (q = quick) |

**Rationale**: Quick capture feeds the Zettelkasten inbox - belongs in same namespace.

#### IWE Preview (unchanged - `<leader>ip*`)

Preview operations remain under `<leader>ip*` because they're **publishing-related**, not core workflow.

______________________________________________________________________

### 1.2 Prose Namespace Expansion (`<leader>p*`)

**Philosophy**: Writers need quick access to writing tools, not just prose mode toggle.

#### New Writer-Focused Keybindings

| Keybinding    | Description                | Category                 |
| ------------- | -------------------------- | ------------------------ |
| `<leader>pp`  | Prose mode toggle          | Core (was `<leader>p`)   |
| `<leader>pf`  | Focus mode (Goyo)          | Focus (was `<leader>pd`) |
| `<leader>pr`  | Reading mode               | Focus (NEW)              |
| `<leader>pm`  | StyledDoc preview          | Preview                  |
| `<leader>pP`  | Paste image                | Content (capital P)      |
| `<leader>pw`  | Word count stats           | Writing (NEW)            |
| `<leader>ps`  | Toggle spell check         | Writing (NEW)            |
| `<leader>pg`  | Start grammar check (ltex) | Writing (NEW)            |
| `<leader>pts` | Timer start                | Tracking (NEW)           |
| `<leader>pte` | Timer stop                 | Tracking (NEW)           |
| `<leader>ptt` | Timer status               | Tracking (NEW)           |
| `<leader>ptr` | Timer report               | Tracking (NEW)           |

#### Changes Summary

| Old Keybinding | New Keybinding | Description       | Reason                      |
| -------------- | -------------- | ----------------- | --------------------------- |
| `<leader>p`    | `<leader>pp`   | Prose mode toggle | Clarity (double p)          |
| `<leader>pd`   | `<leader>pf`   | Focus mode        | More mnemonic (f = focus)   |
| `<leader>pp`   | `<leader>pP`   | Paste image       | Capital P to avoid conflict |
| `<leader>ops`  | `<leader>pts`  | Timer start       | Writer workflow integration |
| `<leader>ope`  | `<leader>pte`  | Timer stop        | Writer workflow integration |
| `<leader>opt`  | `<leader>ptt`  | Timer status      | Writer workflow integration |
| `<leader>opr`  | `<leader>ptr`  | Timer report      | Writer workflow integration |

**Rationale**: Time tracking is a writer activity - belongs with prose tools, not organization tools.

______________________________________________________________________

### 1.3 Git Simplification (`<leader>g*`)

**Philosophy**: Most writers use LazyGit GUI for complex operations. Keybindings should cover only essentials.

#### Removed Keybindings (use LazyGit GUI instead)

| Removed Keybinding | Description           | Alternative                         |
| ------------------ | --------------------- | ----------------------------------- |
| `<leader>gd`       | Git diff split        | `<leader>gg` → LazyGit diff view    |
| `<leader>gL`       | Git log (was capital) | `<leader>gl` (lowercase)            |
| `<leader>gdo`      | Open diff view        | `<leader>gg` → LazyGit              |
| `<leader>gdc`      | Close diff view       | `<leader>gg` → LazyGit              |
| `<leader>gdh`      | File history          | `<leader>gg` → LazyGit file history |
| `<leader>gdf`      | Full history          | `<leader>gg` → LazyGit full history |
| `<leader>ghr`      | Reset hunk            | `<leader>gg` → LazyGit reset        |
| `<leader>ghb`      | Blame line            | `<leader>gb` (git blame)            |

#### Kept Essential Operations (11 total)

| Keybinding    | Description               | Category    |
| ------------- | ------------------------- | ----------- |
| `<leader>gg`  | **LazyGit GUI (primary)** | Primary     |
| `<leader>gs`  | Git status                | Essential   |
| `<leader>gc`  | Git commit                | Essential   |
| `<leader>gp`  | Git push                  | Essential   |
| `<leader>gb`  | Git blame                 | Essential   |
| `<leader>gl`  | Git log                   | Essential   |
| `<leader>ghp` | Preview hunk              | Hunk review |
| `<leader>ghs` | Stage hunk                | Hunk review |
| `<leader>ghu` | Undo stage hunk           | Hunk review |
| `]c`          | Next hunk                 | Navigation  |
| `[c`          | Previous hunk             | Navigation  |

**Rationale**: LazyGit provides visual interface for all complex operations. Writers review paragraph changes (hunks) frequently, so hunk operations kept.

______________________________________________________________________

## Migration Checklist

### For Existing Users

- [ ] Review new Zettelkasten keybindings under `<leader>z*`
- [ ] Test IWE navigation with capital letters (`zF`, `zS`, `zA`, etc.)
- [ ] Adjust muscle memory for quick capture: `<leader>qc` → `<leader>zq`
- [ ] Explore new prose tools: word count (`pw`), spell check (`ps`), reading mode (`pr`)
- [ ] Update time tracking workflow: `<leader>op*` → `<leader>pt*`
- [ ] Switch to LazyGit GUI for complex git operations (`<leader>gg`)
- [ ] Test git essentials: status, commit, push, blame, log

### For New Users

- [ ] Learn Zettelkasten namespace: `<leader>z*` for all note operations
- [ ] Learn Prose namespace: `<leader>p*` for all writing tools
- [ ] Learn Git essentials: `<leader>g*` for version control
- [ ] Primary git interface: `<leader>gg` (LazyGit GUI)
- [ ] Explore Which-Key help: `<leader>W` to discover keybindings

______________________________________________________________________

## Breaking Changes (Phase 1 & 2)

### High Impact (muscle memory adjustment required)

**Phase 1**:

1. **IWE Navigation**: `gf`, `gs`, `ga`, `g/`, `gb`, `go` → `<leader>z[F|S|A|/|B|O]`
2. **Quick Capture**: `<leader>qc` → `<leader>zq`
3. **Focus Mode**: `<leader>pd` → `<leader>pf`
4. **Time Tracking**: `<leader>op*` → `<leader>pt*`

**Phase 2**: 5. **Find Notes**: `<leader>f` now finds NOTES, generic files moved to `<leader>ff` 6. **New Note**: `<leader>n` creates new note, line numbers moved to `<leader>vn` 7. **Quick Capture**: `<leader>i` for inbox capture (also still at `<leader>zq`)

### Medium Impact (less frequent operations)

**Phase 1**:

1. **IWE Refactoring**: `<leader>i[h|l]` → `<leader>zr[h|l]`
2. **Diffview Operations**: Removed (use LazyGit GUI)
3. **Paste Image**: `<leader>pp` → `<leader>pP`
4. **Prose Mode**: `<leader>p` → `<leader>pp`

**Phase 2**: 5. **Line Number Toggle**: `<leader>n` → `<leader>vn` 6. **Find Files**: `<leader>f` → `<leader>ff`

### Low Impact (additions, not replacements)

**Phase 1**:

1. **Reading Mode**: `<leader>pr` (NEW)
2. **Word Count**: `<leader>pw` (NEW)
3. **Spell Check**: `<leader>ps` (NEW)
4. **Grammar Check**: `<leader>pg` (NEW)

**Phase 2**: 5. **Mode Switching**: `<leader>m*` (NEW - 5 modes) 6. **Optimized Shortcuts**: `<leader>f/n/i` for most frequent operations

______________________________________________________________________

## Rationale Summary

### Writer-First Philosophy

**Before**: Keybindings optimized for developers

- Git operations: 20+ keybindings
- Prose tools: 4 keybindings
- Zettelkasten: Scattered across 4 namespaces

**After**: Keybindings optimized for writers

- Git operations: 11 essential keybindings (use GUI for rest)
- Prose tools: 12+ keybindings
- Zettelkasten: Unified in ONE namespace

### Cognitive Load Reduction

**Scattered Operations** (old):

- Note navigation: `g*` prefix
- Note refactoring: `<leader>i*` prefix
- Quick capture: `<leader>q*` prefix
- Zettelkasten core: `<leader>z*` prefix

**Unified Operations** (new):

- ALL note operations: `<leader>z*` prefix
- Sub-namespaces: `<leader>zr*` (refactoring), `<leader>ip*` (preview)

**Result**: Writers only need to remember ONE prefix for all knowledge management.

______________________________________________________________________

## Phase 2: Writer Experience Enhancements (COMPLETE)

**Philosophy**: Most frequent writer actions deserve the shortest possible keys.

### 2.1 Mode-Switching Shortcuts (`<leader>m*`)

Context-aware workspace configurations for different writing workflows.

| Keybinding   | Mode | Description     | Features Enabled                                     |
| ------------ | ---- | --------------- | ---------------------------------------------------- |
| `<leader>mw` | n    | Writing mode    | Goyo, spell check, SemBr, soft wrap, no line numbers |
| `<leader>mr` | n    | Research mode   | Splits, NvimTree, line numbers, spell check          |
| `<leader>me` | n    | Editing mode    | Trouble panel, diagnostics, LSP, line numbers        |
| `<leader>mp` | n    | Publishing mode | Hugo server, markdown preview, spell check           |
| `<leader>mn` | n    | Normal mode     | Reset to baseline PercyBrain configuration           |

**Rationale**: Writers work in distinct contexts (deep writing, research, editing, publishing). One-key mode switching removes friction from context transitions.

**Use Cases**:

- `<leader>mw` - Deep focus prose creation with minimal distractions
- `<leader>mr` - Multi-window note exploration and cross-referencing
- `<leader>me` - Technical editing with full diagnostic support
- `<leader>mp` - Content preparation with live preview
- `<leader>mn` - Reset after mode switching

### 2.2 Frequency-Based Optimization

Reallocated keybindings based on actual usage frequency for writers.

#### Most Frequent Operations (Single-Key Access)

| New Keybinding | Old Keybinding | Description               | Frequency    | Impact |
| -------------- | -------------- | ------------------------- | ------------ | ------ |
| `<leader>f`    | `<leader>ff`   | Find notes (Zettelkasten) | 50+ /session | HIGH   |
| `<leader>n`    | `<leader>zn`   | New note (quick)          | 50+ /session | HIGH   |
| `<leader>i`    | `<leader>zq`   | Inbox capture (quick)     | 20+ /session | HIGH   |

#### Displaced Functions (Moved to Longer Combos)

| Old Keybinding | New Keybinding | Description                     | Frequency     | Reason                                       |
| -------------- | -------------- | ------------------------------- | ------------- | -------------------------------------------- |
| `<leader>f`    | `<leader>ff`   | Find files (filesystem)         | 5-10 /session | Generic files less frequent than notes       |
| `<leader>n`    | `<leader>vn`   | Toggle line numbers             | 1-2 /session  | Toggling numbers very infrequent             |
| (none)         | `<leader>zq`   | Quick capture (still available) | N/A           | Maintained for discoverability via Which-Key |

**Justification**:

- Writers find/create notes 50+ times per session
- Toggling line numbers: 1-2 times per session
- Finding filesystem files: 5-10 times per session
- Quick capture: 20+ times per session

**Speed of Thought**: Shortest keys = highest frequency operations

### Phase 2 Breaking Changes

#### High Impact (muscle memory adjustment required)

1. **Find Notes**: `<leader>f` now finds NOTES (in Zettelkasten), not generic files

   - Generic files moved to `<leader>ff`
   - **Mitigation**: Notes are primary content for writers

2. **New Note**: `<leader>n` creates new note (most frequent writer action)

   - Line number toggle moved to `<leader>vn`
   - **Mitigation**: Creating notes 50x more frequent than toggling numbers

3. **Quick Capture**: `<leader>i` for rapid inbox capture

   - Still available at `<leader>zq` for discoverability
   - **Mitigation**: Single-key reduces friction for fleeting thoughts

#### Medium Impact (less frequent operations)

1. **Line Number Toggle**: `<leader>n` → `<leader>vn`

   - **Mitigation**: Mnemonic "v = view", very infrequent operation

2. **Find Files**: `<leader>f` → `<leader>ff`

   - **Mitigation**: Double keystroke acceptable for less frequent operation

### Phase 3: Documentation & Validation (FUTURE)

- Create interactive keybinding map
- Validate no keybinding conflicts
- Create visual cheat sheet
- Video walkthrough of new workflow

______________________________________________________________________

## Support & Feedback

**Questions**: Check `docs/reference/KEYBINDINGS_REFERENCE.md` for complete reference **Issues**: Report via GitHub issues if keybindings don't work as expected **Philosophy**: Read `docs/explanation/WHY_PERCYBRAIN.md` for design rationale

______________________________________________________________________

**Last Updated**: 2025-10-21 **Author**: PercyBrain AI Assistant **Phase**: 1 & 2 Complete (Consolidation, Simplification & Frequency Optimization)
