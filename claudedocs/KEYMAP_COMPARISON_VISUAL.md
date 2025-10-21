# Keymap Structure Comparison - Visual Guide

**Quick visual reference** for understanding the proposed reorganization.

______________________________________________________________________

## Current vs. Proposed Structure

### BEFORE (Flat - 14 modules)

```
lua/config/keymaps/
├── ai.lua                    <leader>a*   (7 keymaps)
├── core.lua                  <leader>s/q  (8 keymaps)
├── dashboard.lua             <leader>da   (1 keymap)
├── diagnostics.lua           <leader>x*   (6 keymaps)
├── git.lua                   <leader>g*   (20 keymaps)
├── init.lua                  REGISTRY
├── lynx.lua                  <leader>l*   (4 keymaps)
├── navigation.lua            <leader>e/y  (6 keymaps)
├── prose.lua                 <leader>p    (3 keymaps)
├── quick-capture.lua         <leader>qc   (1 keymap)
├── README.md
├── telescope.lua             <leader>f*   (7 keymaps)
├── toggle.lua                <leader>t*   (13 keymaps) ⚠️ OVERLOADED
├── utilities.lua             <leader>u/m  (5 keymaps)
├── window.lua                <leader>w*   (20 keymaps)
└── zettelkasten.lua          <leader>z*   (14 keymaps)

TOTAL: 14 files, 115+ keymaps
```

**User experience**:

```
User: "I want to write a note"
System: "Check... zettelkasten.lua? prose.lua? quick-capture.lua? utilities.lua?"
Cognitive load: HIGH (decision paralysis)
```

______________________________________________________________________

### AFTER (Hierarchical - 4 directories, 18 modules)

```
lua/config/keymaps/
├── init.lua                  REGISTRY (unchanged)
├── README.md
│
├── workflows/                ← "I want to DO something"
│   ├── ai.lua                <leader>a*   (7 keymaps)
│   ├── prose.lua             <leader>p    (3 keymaps)
│   ├── quick-capture.lua     <leader>qc   (1 keymap)
│   ├── research.lua          <leader>l*   (4 keymaps)  [was lynx.lua]
│   └── zettelkasten.lua      <leader>z*   (14 keymaps)
│
├── tools/                    ← "I need to NAVIGATE/FIND"
│   ├── diagnostics.lua       <leader>x*   (6 keymaps)
│   ├── git.lua               <leader>g*   (20 keymaps)
│   ├── navigation.lua        <leader>e/y  (6 keymaps)
│   ├── telescope.lua         <leader>f*   (7 keymaps)
│   └── window.lua            <leader>w*   (20 keymaps)
│
├── environment/              ← "I want to CONFIGURE workspace"
│   ├── focus.lua             <leader>tz/o/sp  (3 keymaps) [from toggle.lua]
│   ├── terminal.lua          <leader>t/te/ft  (3 keymaps) [from toggle.lua]
│   ├── time-tracking.lua     <leader>tp*      (4 keymaps) [from pendulum]
│   └── translation.lua       <leader>tf/tt/ts (3 keymaps) [from toggle.lua]
│
└── system/                   ← "Core VIM operations"
    ├── core.lua              <leader>s/q/c/v/n (8 keymaps)
    ├── dashboard.lua         <leader>da        (1 keymap)
    └── utilities.lua         <leader>u/m/al    (5 keymaps)

TOTAL: 4 directories, 18 modules, 115+ keymaps (same keymaps, better organization)
```

**User experience**:

```
User: "I want to write a note"
System: "Check workflows/ directory"
User: "I see: zettelkasten, quick-capture, prose, ai, research"
Cognitive load: LOW (predictable grouping)
```

______________________________________________________________________

## toggle.lua Breakdown (13 keymaps → 4 modules)

### BEFORE (One Overloaded File)

```lua
# toggle.lua (33 lines, 13 keymaps, 4 unrelated features)

<leader>t       → terminal           ┐
<leader>te      → ToggleTerm         │ TERMINALS (3)
<leader>ft      → FloatermToggle     ┘

<leader>tz      → ZenMode            ┐
<leader>sp      → SoftPencil         │ FOCUS MODES (2)
                                     ┘

<leader>tf      → Translate fr       ┐
<leader>tt      → Translate ta       │ TRANSLATION (3)
<leader>ts      → Translate si       ┘

<leader>tps     → Pendulum start     ┐
<leader>tpe     → Pendulum end       │ TIME TRACKING (4)
<leader>tpt     → Pendulum status    │
<leader>tpr     → Pendulum report    ┘

<leader>al      → ALEToggle          ← LINTER (1)
```

**Problems**:

- Mixing terminals, focus modes, translation, time tracking, linter
- No semantic relationship between features
- Hard to find specific toggle ("which toggle do I need?")

______________________________________________________________________

### AFTER (4 Semantic Modules)

```lua
# environment/terminal.lua (11 lines, 3 keymaps)
<leader>t       → terminal
<leader>te      → ToggleTerm
<leader>ft      → FloatermToggle

# environment/focus.lua (14 lines, 3 keymaps)
<leader>tz      → ZenMode
<leader>sp      → SoftPencil
<leader>o       → Goyo               [moved from prose.lua]

# environment/translation.lua (13 lines, 3 keymaps)
<leader>tf      → Translate French
<leader>tt      → Translate Tamil
<leader>ts      → Translate Sinhala

# environment/time-tracking.lua (17 lines, 4 keymaps)
<leader>tps     → Pendulum start
<leader>tpe     → Pendulum end
<leader>tpt     → Pendulum status
<leader>tpr     → Pendulum report

# system/utilities.lua (add 1 keymap)
<leader>al      → ALEToggle
```

**Benefits**:

- Each module has clear purpose
- Related features grouped together
- Easy to find ("I need terminal" → `environment/terminal.lua`)
- Scalable (add new terminals to terminal.lua, not toggle.lua)

______________________________________________________________________

## Mental Model Alignment

### User Task: "Write a Note"

#### BEFORE (Flat Structure)

```
Mental process:
1. "I need to write a note"
2. "Which module has note-writing?"
3. Scan 14 files: ai? prose? zettelkasten? quick-capture?
4. Try zettelkasten.lua first
5. If not there, try prose.lua
6. If not there, try quick-capture.lua

Decision points: 3-4
Time to find: 15-30 seconds
Cognitive load: HIGH
```

#### AFTER (Hierarchical Structure)

```
Mental process:
1. "I need to write a note"
2. "That's a workflow, check workflows/"
3. See: zettelkasten, quick-capture, prose, ai, research
4. Pick zettelkasten.lua

Decision points: 1
Time to find: 5-10 seconds
Cognitive load: LOW
```

______________________________________________________________________

## Directory Purpose Guide

### workflows/ - "What am I DOING today?"

Primary use cases, user goals, main tasks.

**Questions answered**:

- How do I create a note?
- How do I use AI assistance?
- How do I write prose?
- How do I research with browser?

**Mental model**: These are my WORKFLOWS, my primary activities.

______________________________________________________________________

### tools/ - "What tool do I NEED right now?"

Supporting tools, navigation aids, utility features.

**Questions answered**:

- How do I find a file?
- How do I search content?
- How do I manage git?
- How do I navigate windows?
- How do I check errors?

**Mental model**: These are my TOOLS, things that support my workflows.

______________________________________________________________________

### environment/ - "How do I CONFIGURE my workspace?"

Mode switching, workspace setup, environment toggles.

**Questions answered**:

- How do I open a terminal?
- How do I enter focus mode?
- How do I translate text?
- How do I track time?

**Mental model**: These configure my ENVIRONMENT, how my editor behaves.

______________________________________________________________________

### system/ - "Basic VIM operations"

Core editor functionality, infrastructure, basics.

**Questions answered**:

- How do I save/quit?
- How do I split windows?
- Where's the dashboard?
- Core vim keymaps?

**Mental model**: These are SYSTEM basics, foundational editor operations.

______________________________________________________________________

## File Organization Comparison

### Finding "Quick Capture" Keymap

#### BEFORE

```
Step 1: "Where is quick capture?"
Step 2: Scan file list (14 files)
Step 3: Notice quick-capture.lua
Step 4: Open file
Step 5: Find <leader>qc

Cognitive effort: MEDIUM (had to scan flat list)
```

#### AFTER

```
Step 1: "Quick capture is a workflow for capturing notes"
Step 2: Open workflows/ directory
Step 3: See quick-capture.lua (among 5 workflow files)
Step 4: Open file
Step 5: Find <leader>qc

Cognitive effort: LOW (predictable location)
```

______________________________________________________________________

### Finding "Git Diff" Keymap

#### BEFORE

```
Step 1: "Where is git diff?"
Step 2: Scan file list (14 files)
Step 3: Try git.lua (correct)
Step 4: Find <leader>gd

Cognitive effort: LOW-MEDIUM (git.lua is obvious, but among 14 files)
```

#### AFTER

```
Step 1: "Git is a tool for version control"
Step 2: Open tools/ directory
Step 3: See git.lua (among 5 tool files)
Step 4: Find <leader>gd

Cognitive effort: LOW (predictable location, fewer files to scan)
```

______________________________________________________________________

### Finding "Terminal Toggle" Keymap

#### BEFORE

```
Step 1: "Where is terminal toggle?"
Step 2: Guess toggle.lua? core.lua? utilities.lua?
Step 3: Open toggle.lua
Step 4: Scan 13 keymaps (terminals, zen, translation, time tracking)
Step 5: Find <leader>t

Cognitive effort: HIGH (overloaded file, unclear name)
```

#### AFTER

```
Step 1: "Terminal is an environment configuration"
Step 2: Open environment/ directory
Step 3: See terminal.lua (clear name)
Step 4: Find <leader>t (only 3 keymaps in file)

Cognitive effort: LOW (semantic grouping, small file)
```

______________________________________________________________________

## ADHD-Specific Benefits Visualization

### Reduced Option Overload

```
BEFORE:
lua/config/keymaps/ (14 files)
│
├─ Where do I start? ❓
├─ Too many options! 😰
└─ Decision paralysis! 😵

AFTER:
lua/config/keymaps/ (4 directories)
│
├─ workflows/     ← "I'm doing Zettelkasten work"
├─ tools/         ← "I need to search files"
├─ environment/   ← "I need focus mode"
└─ system/        ← "Basic vim operations"

Clear hierarchy! ✅
```

### Predictable Navigation

```
BEFORE:
"I want to write a note"
  ↓
Scan 14 files
  ↓
Guess zettelkasten.lua
  ↓
Hope it's correct
  ↓
Mental exhaustion 😓

AFTER:
"I want to write a note"
  ↓
Check workflows/
  ↓
See 5 workflow files
  ↓
Pick zettelkasten.lua
  ↓
Success! 🎉
```

### Semantic Cohesion

```
BEFORE: toggle.lua (13 keymaps)
┌─────────────────────────────────┐
│ terminals (3)                   │
│ zen modes (2)                   │
│ translation (3)                 │
│ time tracking (4)               │
│ linter (1)                      │
└─────────────────────────────────┘
"What is this file even about?" 🤔

AFTER: environment/ (4 modules)
┌──────────────┬──────────────┐
│ terminal.lua │ focus.lua    │
│ (3 keymaps)  │ (3 keymaps)  │
├──────────────┼──────────────┤
│ translation  │ time-tracking│
│ (3 keymaps)  │ (4 keymaps)  │
└──────────────┴──────────────┘
"Each file has clear purpose!" ✅
```

______________________________________________________________________

## Migration Safety Visualization

### What Changes

```
✅ UNCHANGED:
- Registry system (init.lua)
- Namespace organization (<leader>z*, <leader>f*, etc.)
- Lazy loading behavior
- Total number of keymaps (115+)
- Keymap functionality (all work the same)

🔄 CHANGED:
- File locations (flat → hierarchical)
- require() paths in plugin specs
- Documentation references
- toggle.lua split into 4 modules

❌ REMOVED:
- Nothing! All keymaps preserved
```

### Rollback Plan

```
Git history:
┌────────────────────────────────────┐
│ BEFORE: Flat structure (stable)   │
├────────────────────────────────────┤
│ AFTER: Hierarchical (new)         │
└────────────────────────────────────┘

If issues: git revert HEAD~5
         ↓
Back to flat structure (no data loss)
```

______________________________________________________________________

## Quick Decision Matrix

| Aspect                 | Flat (Current)            | Hierarchical (Proposed)  |
| ---------------------- | ------------------------- | ------------------------ |
| **Files at top level** | 14                        | 4 directories            |
| **Cognitive load**     | HIGH (scan all files)     | LOW (pick directory)     |
| **Predictability**     | MEDIUM (unclear names)    | HIGH (semantic grouping) |
| **Scalability**        | LOW (gets bloated)        | HIGH (add to categories) |
| **ADHD-friendly**      | ❌ (decision fatigue)     | ✅ (clear hierarchy)     |
| **Maintenance**        | MEDIUM (overloaded files) | HIGH (small modules)     |
| **Migration effort**   | 0 (current)               | 4-6 hours                |
| **Risk**               | 0 (stable)                | LOW-MEDIUM               |

______________________________________________________________________

## Recommendation Summary

**ACCEPT hierarchical reorganization** for ADHD-focused usability improvements:

✅ **Better mental model**: Workflows → Tools → Environment → System ✅ **Reduced cognitive load**: 4 directories vs. 14 files ✅ **Predictable navigation**: Clear entry points ✅ **Semantic clarity**: Related features grouped ✅ **Scalable design**: Easy to add new features

**Implement incrementally**:

1. Prototype with 3 modules (test for 48 hours)
2. If validated, complete migration
3. Update documentation
4. Validate all keymaps work

**Estimated effort**: 4-6 hours **Expected outcome**: More intuitive keymap organization

______________________________________________________________________

**Visual guide created**: 2025-10-21 **Full analysis**: `/home/percy/.config/nvim/claudedocs/KEYMAP_STRUCTURE_ANALYSIS_2025-10-21.md` **Proposal**: `/home/percy/.config/nvim/claudedocs/KEYMAP_REORGANIZATION_PROPOSAL.md`
