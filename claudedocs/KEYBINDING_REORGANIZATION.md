# Keybinding Reorganization - Completion Report

**Date**: 2025-10-17 **Status**: ✅ Complete **Reason**: Resolve keybinding conflict and follow Neovim conventions

______________________________________________________________________

## Problem Statement

### Critical Issue Discovered

During system analysis, a **critical keybinding conflict** was identified:

- **`<leader>zw`** was bound to TWO different functions:
  1. `zettelkasten.lua:121` → `ZenMode` (distraction-free writing)
  2. `ollama.lua:343` → `AI Improve Writing` (AI text enhancement)

**Impact**: Plugin loading order meant AI binding overrode ZenMode, making ZenMode completely inaccessible via keyboard shortcut.

### Secondary Issue

All PercyBrain features were crammed under the `<leader>z*` namespace without logical organization:

- Zettelkasten operations (notes, search)
- AI commands (explain, summarize, improve)
- Focus modes (zen, goyo)
- Semantic line breaks (SemBr)

This violated Neovim conventions for mnemonic keybinding organization.

______________________________________________________________________

## Solution: Domain-Based Prefix Organization

Following **classic Neovim mnemonic conventions**, keybindings were reorganized into logical domains:

### New Organization

| Prefix       | Domain           | Mnemonic         | Usage                                    |
| ------------ | ---------------- | ---------------- | ---------------------------------------- |
| `<leader>z*` | **Zettelkasten** | z = Zettelkasten | Core note management, search, publishing |
| `<leader>a*` | **AI Assistant** | a = AI           | All Ollama AI commands                   |
| `<leader>f*` | **Focus Modes**  | f = focus        | Distraction-free writing modes           |

**Note**: User correction applied - `<leader>w*` reserved for window manipulation per Neovim convention, NOT used for writing modes.

______________________________________________________________________

## Changes Made

### 1. AI Commands → `<leader>a*` Prefix

**File Modified**: `/home/percy/.config/nvim/lua/plugins/ollama.lua:328-352`

| Old Binding     | New Binding      | Command           | Description           |
| --------------- | ---------------- | ----------------- | --------------------- |
| `<leader>za`    | **`<leader>aa`** | `:PercyAI`        | AI command menu       |
| `<leader>ze`    | **`<leader>ae`** | `:PercyExplain`   | Explain text          |
| `<leader>zm`    | **`<leader>as`** | `:PercySummarize` | Summarize note        |
| `<leader>zl`    | **`<leader>al`** | `:PercyLinks`     | Suggest related links |
| `<leader>zw` ⚠️ | **`<leader>aw`** | `:PercyImprove`   | Improve writing       |
| `<leader>zq`    | **`<leader>aq`** | `:PercyAsk`       | Ask question          |
| `<leader>zx`    | **`<leader>ax`** | `:PercyIdeas`     | Generate ideas        |

**Rationale**:

- Isolates AI features under dedicated prefix
- Resolves `<leader>zw` conflict ✅
- Logical grouping: all AI operations start with 'a'

### 2. Focus Mode → `<leader>f*` Prefix

**File Modified**: `/home/percy/.config/nvim/lua/config/zettelkasten.lua:106-125`

| Old Binding     | New Binding      | Command    | Description      |
| --------------- | ---------------- | ---------- | ---------------- |
| `<leader>zw` ⚠️ | **`<leader>fz`** | `:ZenMode` | Zen mode (focus) |

**Rationale**:

- 'f' for focus is intuitive and mnemonic
- Leaves room for additional focus modes (goyo, limelight) in future
- Respects Neovim convention: 'w' is for windows, not writing

### 3. Zettelkasten → Kept `<leader>z*` Prefix

**File Modified**: `/home/percy/.config/nvim/lua/config/zettelkasten.lua:106-125`

**No changes** - these bindings remain under `<leader>z*`:

| Binding      | Command         | Description            |
| ------------ | --------------- | ---------------------- |
| `<leader>zn` | `:PercyNew`     | New note with template |
| `<leader>zd` | `:PercyDaily`   | Daily journal note     |
| `<leader>zi` | `:PercyInbox`   | Quick inbox capture    |
| `<leader>zf` | Find notes      | Fuzzy file search      |
| `<leader>zg` | Search notes    | Live grep content      |
| `<leader>zb` | Backlinks       | Find backlinks         |
| `<leader>zp` | `:PercyPublish` | Publish to static site |
| `<leader>zs` | `:SemBrFormat`  | Semantic line breaks   |
| `<leader>zt` | `:SemBrToggle`  | Toggle auto-format     |

**Rationale**:

- Core Zettelkasten operations logically belong in 'z' namespace
- SemBr is Zettelkasten-specific (semantic formatting for notes)
- Publishing is Zettelkasten workflow operation

### 4. Documentation Updated

**File Modified**: `/home/percy/.config/nvim/CLAUDE.md:226-283`

- Updated "Writing Mode Shortcuts" section (line 229)
- Updated "PercyBrain Zettelkasten Shortcuts" section (lines 236-283)
- Added mnemonic indicators: "(z = Zettelkasten)", "(a = AI)", "(f = focus)"
- Reorganized AI section as separate subsection

______________________________________________________________________

## Verification

### Conflict Resolution

✅ **`<leader>zw` conflict resolved**:

- Old: `<leader>zw` → ZenMode (zettelkasten.lua) → **OVERRIDDEN**
- Old: `<leader>zw` → AI Improve (ollama.lua) → **ACTIVE**
- New: `<leader>fz` → ZenMode ✅
- New: `<leader>aw` → AI Improve ✅

**Result**: Both functions now accessible with unique keybindings.

### Mnemonic Compliance

✅ **Follows Neovim conventions**:

- Domain-based prefixes (z/a/f)
- Mnemonic clarity (Zettelkasten, AI, focus)
- 'w' reserved for windows (not writing)
- Logical grouping by functionality

### User Experience

✅ **Improved discoverability**:

- Clear domain separation
- Logical prefix meanings
- Room for future expansion within each domain

______________________________________________________________________

## Migration Notes

### For Existing Users

**Old muscle memory will break**. Update habits:

| Old          | New          | Memory Aid                    |
| ------------ | ------------ | ----------------------------- |
| `<leader>za` | `<leader>aa` | **a**a = **A**I menu          |
| `<leader>ze` | `<leader>ae` | **a**e = **A**I **e**xplain   |
| `<leader>zm` | `<leader>as` | **a**s = **A**I **s**ummarize |
| `<leader>zl` | `<leader>al` | **a**l = **A**I **l**inks     |
| `<leader>zw` | `<leader>aw` | **a**w = **A**I **w**riting   |
| `<leader>zq` | `<leader>aq` | **a**q = **A**I **q**uestion  |
| `<leader>zx` | `<leader>ax` | **a**x = **A**I e**x**plore   |
| `<leader>zw` | `<leader>fz` | **f**z = **f**ocus **z**en    |

**Tip**: Use `<leader>aa` (AI menu) for discovery while learning new bindings.

### Testing Recommended

After restarting Neovim:

1. **Test ZenMode accessibility**: `<leader>fz` → Should enter zen mode
2. **Test AI commands**: `<leader>aa` → Should show AI menu
3. **Test AI improve**: `<leader>aw` → Should call AI text improvement
4. **Verify no conflicts**: Both functions work independently

______________________________________________________________________

## Future Expansion

### Available Prefixes

**Focus modes** (`<leader>f*`) can expand:

- `<leader>fg` → Goyo mode
- `<leader>fl` → Limelight mode
- `<leader>ft` → Twilight mode
- `<leader>fc` → Centerpad mode

**AI commands** (`<leader>a*`) can expand:

- `<leader>at` → AI translate
- `<leader>ar` → AI refactor
- `<leader>ad` → AI documentation

**Zettelkasten** (`<leader>z*`) has room for:

- `<leader>zh` → Zettel home/index
- `<leader>zo` → Zettel orphan check
- `<leader>zk` → Zettel graph (knowledge map)

______________________________________________________________________

## Technical Details

### Files Modified

1. **`/home/percy/.config/nvim/lua/plugins/ollama.lua`**

   - Lines 328-352: Changed all AI keybindings from `<leader>z*` to `<leader>a*`
   - Updated notification message (line 352)

2. **`/home/percy/.config/nvim/lua/config/zettelkasten.lua`**

   - Lines 106-125: Moved ZenMode from `<leader>zw` to `<leader>fz`
   - Added mnemonic comments
   - Reorganized structure for clarity

3. **`/home/percy/.config/nvim/CLAUDE.md`**

   - Lines 226-283: Updated all keybinding documentation
   - Added mnemonic indicators
   - Reorganized sections with clear domain headers

### Implementation Time

**~15 minutes** (code changes + documentation + verification)

### Testing Status

⏳ **Requires Neovim restart** - Changes not yet active in running instance

______________________________________________________________________

## Conclusion

✅ **Keybinding conflict resolved** - ZenMode now accessible ✅ **Neovim conventions followed** - Domain-based mnemonic organization ✅ **User correction applied** - 'w' reserved for windows ✅ **Future-proof design** - Room for expansion in each domain ✅ **Documentation updated** - CLAUDE.md reflects new organization

**Recommendation**: Restart Neovim and test all new bindings to verify functionality.

______________________________________________________________________

**Completion Status**: ✅ All tasks complete **Next Action**: User testing and feedback
