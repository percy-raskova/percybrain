# Alpha Dashboard Polish - Game Plan for Main Branch Merge

**Date**: 2025-10-21 **Status**: Pre-merge polish **Branch**: `workflow/zettelkasten-wiki-ai-pipeline` → `main` **Goal**: Address user feedback before local merge to main

## User Feedback Analysis

### ✅ What's Working

- Dashboard looks "beautiful! almost perfect!"
- Clean, minimal visual noise (ADHD optimization successful)
- Good workflow organization (Start Writing → Workflows → Tools)

### ❌ Issues to Fix

1. **Which-Key Menu Descriptions**

   - Current: Ugly technical names like "pandoc-keyboard-toggle-strong)"
   - Needed: Human-readable + emoji descriptions like "📝 Bold text"

2. **Missing Basic Neovim Operations**

   - No way to access window management from first level
   - No buffer/split/navigation operations in which-key menu

3. **Template Bloat (Decision Fatigue)**

   - Current: 10 templates causing choice paralysis
   - Needed: 5 core templates (ADHD principle: reduce decisions)

## Priority Assessment

### 🔴 High Priority (Blocking Merge)

1. **Template Consolidation** - Core ADHD optimization
2. **Which-Key Polish** - User-facing experience
3. **Window Management Access** - Basic functionality gap

### 🟡 Medium Priority (Nice to Have)

4. **Which-Key Group Names** - Better than "+8 keymaps"

### 🟢 Low Priority (Post-Merge)

5. **Advanced Customization**
6. **Additional Polish**

## Phase 1: Template Consolidation

### Problem

10 templates in `~/Zettelkasten/templates/` causing decision fatigue:

01. daily.md ✅ (IWE integration)
02. fleeting.md ❌ (redundant → use daily)
03. literature.md ❌ (redundant → use source)
04. meeting.md ❌ (redundant → use daily)
05. moc.md ✅ (IWE integration)
06. permanent.md ❌ (redundant → use note)
07. project.md ❌ (redundant → use moc)
08. source.md ✅ (IWE integration)
09. weekly.md ✅ (IWE integration)
10. wiki.md ❌ (redundant → use moc)

IWE integration created 5 modern templates:

- note.md (standard zettel)
- daily.md (daily capture)
- weekly.md (weekly review)
- source.md (literature notes with citations)
- moc.md (Maps of Content)

### Solution

**Remove 5 redundant templates:**

```bash
cd ~/Zettelkasten/templates/
rm fleeting.md literature.md meeting.md permanent.md project.md wiki.md
```

**Mapping for users:**

- fleeting → daily (transient capture)
- literature → source (citations + references)
- meeting → daily (dated capture)
- permanent → note (atomic insight)
- project → moc (navigation hub)
- wiki → moc (knowledge navigation)

**Update contract test:**

```lua
-- specs/iwe_telekasten_contract.lua
templates = {
  note = "~/Zettelkasten/templates/note.md",      -- replaces: permanent
  daily = "~/Zettelkasten/templates/daily.md",    -- replaces: fleeting, meeting
  weekly = "~/Zettelkasten/templates/weekly.md",  -- new
  source = "~/Zettelkasten/templates/source.md",  -- replaces: literature
  moc = "~/Zettelkasten/templates/moc.md",        -- replaces: project, wiki
}
```

**Verification:**

```bash
# Count should be exactly 5
ls ~/Zettelkasten/templates/ | wc -l

# Run contract test
mise run test:_run_plenary_file tests/contract/iwe_telekasten_contract_spec.lua
```

**Time Estimate**: 15-20 minutes **Risk**: Low (just file deletion + test update)

## Phase 2: Which-Key Polish

### Problem

Which-key shows technical command names without emojis:

- "pandoc-keyboard-toggle-strong)" → Should be "📝 Bold text"
- "pandoc-keyboard-toggle-emphasis)" → Should be "✍️ Italic text"
- "+8 keymaps" → Should be "✏️ Writing (8)"

### Solution

**Audit keymap files for missing descriptions:**

```bash
# Find keymaps without desc or with ugly desc
rg 'vim\.keymap\.set|vim\.api\.nvim_set_keymap' lua/config/keymaps/ -A 2 | grep -v 'desc'
```

**Pattern for fixes:**

```lua
-- Before (ugly)
{ "<leader>pb", "<cmd>PandocToggleStrong<CR>" }

-- After (polished)
{ "<leader>pb", "<cmd>PandocToggleStrong<CR>", desc = "📝 Bold text" }
```

**Key areas requiring polish:**

1. **Prose Writing Keymaps** (`lua/config/keymaps/workflows/prose.lua`)

   - Bold, italic, code, strikethrough
   - Headers (H1-H6)
   - Lists, quotes, links

2. **Zettelkasten Keymaps** (`lua/config/keymaps/workflows/zettelkasten.lua`)

   - Note creation, navigation
   - Backlinks, search
   - Daily/weekly notes

3. **Window Management** (`lua/config/keymaps/tools/window.lua`)

   - Split horizontal/vertical
   - Navigate windows
   - Resize, close

4. **IWE Keymaps** (`lua/config/keymaps/workflows/iwe.lua`)

   - Extract, inline, format
   - LSP navigation

**Which-Key Group Configuration:**

```lua
-- lua/plugins/ui/whichkey.lua
require("which-key").setup({
  -- Add group names
  groups = {
    ["<leader>p"] = "✏️ Prose",
    ["<leader>z"] = "📓 Zettelkasten",
    ["<leader>zr"] = "🔧 Refactor",
    ["<leader>w"] = "🪟 Windows",
    ["<leader>a"] = "🤖 AI",
    ["<leader>g"] = "📦 Git",
    ["<leader>f"] = "🔍 Find",
  }
})
```

**Emoji Guide:**

- Writing: 📝✍️📋🖊️
- Zettelkasten: 📓🗒️📑🔗
- System: 🪟💾⚙️🔧
- AI: 🤖🧠💬
- Git: 📦🔀🌿
- Find: 🔍🔎📂

**Verification:**

1. Open Neovim
2. Press `<leader>` and wait for which-key
3. Verify all groups have emoji + readable names
4. Check nested groups (like `<leader>zr`)

**Time Estimate**: 30-45 minutes **Risk**: Medium (many files to edit, visual verification needed)

## Phase 3: Window Management Access

### Problem

No clear way to access window management from which-key menu.

### Investigation Required

**Check existing window keybindings:**

```bash
# Find window-related keymaps
rg 'split|vsplit|wincmd' lua/config/keymaps/
```

**Likely locations:**

- `lua/config/keymaps/tools/window.lua`
- `lua/config/keymaps/system/core.lua`

### Solution

**Option A: Keybindings exist, just need descriptions**

- Add emoji + descriptions to existing bindings
- Ensure they're under `<leader>w` namespace
- Add group name in which-key config

**Option B: Create window management namespace**

```lua
-- lua/config/keymaps/tools/window.lua
{
  { "<leader>wh", "<cmd>split<CR>", desc = "➖ Split horizontal" },
  { "<leader>wv", "<cmd>vsplit<CR>", desc = "➗ Split vertical" },
  { "<leader>wc", "<cmd>close<CR>", desc = "❌ Close window" },
  { "<leader>wo", "<cmd>only<CR>", desc = "⬜ Only this window" },
  { "<leader>w=", "<C-w>=", desc = "⚖️ Equalize windows" },
  -- Navigation
  { "<leader>wh", "<C-w>h", desc = "← Left window" },
  { "<leader>wj", "<C-w>j", desc = "↓ Down window" },
  { "<leader>wk", "<C-w>k", desc = "↑ Up window" },
  { "<leader>wl", "<C-w>l", desc = "→ Right window" },
}
```

**Buffer management:**

```lua
{ "<leader>bb", "<cmd>Telescope buffers<CR>", desc = "📋 Buffer list" },
{ "<leader>bd", "<cmd>bdelete<CR>", desc = "❌ Delete buffer" },
{ "<leader>bn", "<cmd>bnext<CR>", desc = "→ Next buffer" },
{ "<leader>bp", "<cmd>bprevious<CR>", desc = "← Previous buffer" },
```

**Verification:**

1. Press `<leader>w` → should show window operations
2. Press `<leader>b` → should show buffer operations
3. Test actual functionality

**Time Estimate**: 10-15 minutes (if exists) or 30 minutes (if creating) **Risk**: Low (core Neovim functionality)

## Phase 4: Testing and Validation

### TDD Approach (Kent Beck)

**Update Contract Test:**

```lua
-- specs/iwe_telekasten_contract.lua
-- Update template count expectation
templates = {
  note = "~/Zettelkasten/templates/note.md",
  daily = "~/Zettelkasten/templates/daily.md",
  weekly = "~/Zettelkasten/templates/weekly.md",
  source = "~/Zettelkasten/templates/source.md",
  moc = "~/Zettelkasten/templates/moc.md",
}
-- Should be exactly 5, no more
```

**Run Test Suite:**

```bash
# Contract tests (specification compliance)
mise tc

# Capability tests (user workflows)
mise tcap

# All tests
mise test
```

**Visual Verification Checklist:**

- [ ] Alpha dashboard loads cleanly
- [ ] Which-key shows at `<leader>` with emoji + descriptions
- [ ] All prose keybindings have emoji + readable names
- [ ] All zettelkasten keybindings have emoji + readable names
- [ ] Window management accessible via `<leader>w`
- [ ] Buffer management accessible via `<leader>b`
- [ ] Group names show clearly (not "+8 keymaps")
- [ ] Only 5 templates in ~/Zettelkasten/templates/
- [ ] Template creation still works (test daily, note, moc)

**Regression Check:**

```bash
# Ensure no existing functionality broke
mise tr

# Full test suite
mise test
```

## Phase 5: Documentation and Commit

### Update Documentation

**Files to update:**

1. `QUICK_REFERENCE.md` - Reflect new keybindings
2. `docs/reference/KEYBINDINGS_REFERENCE.md` - Complete keymap documentation
3. `claudedocs/IWE_TELEKASTEN_INTEGRATION_2025-10-21.md` - Note template consolidation

**Create completion report:**

```bash
claudedocs/ALPHA_DASHBOARD_POLISH_COMPLETION_2025-10-21.md
```

### Git Commit

```bash
git add -A
git commit -m "$(cat <<'EOF'
polish(ui): Alpha dashboard final touches before main merge

BREAKING CHANGE: Template consolidation from 10 to 5 templates.
Old templates (fleeting, literature, meeting, permanent, project, wiki)
removed. Use modern equivalents (daily, source, note, moc).

## Template Consolidation
- Removed 5 redundant templates (decision fatigue reduction)
- Kept 5 core templates: note, daily, weekly, source, moc
- Updated contract test to enforce 5-template limit
- Migration guide: fleeting→daily, literature→source, permanent→note

## Which-Key Polish
- Added emoji + human-readable descriptions to ALL keybindings
- Configured group names (no more "+8 keymaps")
- Prose: 📝 Bold, ✍️ Italic, 📋 Headers
- Zettelkasten: 📓 Notes, 🗒️ Daily, 🔗 Links
- Windows: 🪟 Split, ❌ Close, ⚖️ Equalize
- Buffers: 📋 List, ❌ Delete, → Next

## Window Management
- Added/polished <leader>w namespace for window operations
- Added/polished <leader>b namespace for buffer management
- All operations accessible from first-level which-key menu

## Testing
✅ Contract tests: 5/5 passing (template count enforced)
✅ Capability tests: 9/9 passing
✅ Visual verification: Complete
✅ Regression tests: Passing

## Documentation
- Updated QUICK_REFERENCE.md
- Updated KEYBINDINGS_REFERENCE.md
- Created completion report

Ready for merge to main branch.
EOF
)"
```

## Time and Risk Assessment

### Total Time Estimate

- **Phase 1 (Templates)**: 15-20 minutes
- **Phase 2 (Which-Key)**: 30-45 minutes
- **Phase 3 (Windows)**: 10-30 minutes
- **Phase 4 (Testing)**: 15-20 minutes
- **Phase 5 (Docs/Commit)**: 10-15 minutes

**Total**: 1.5 - 2.5 hours

### Risk Assessment

**Low Risk:**

- Template deletion (easily reversible)
- Adding descriptions (cosmetic)
- Window keybindings (standard Neovim)

**Medium Risk:**

- Which-key configuration (many files to touch)
- Group name setup (may need iteration)

**Mitigation:**

- Work on feature branch (already on workflow branch)
- Test after each phase
- Keep backups of deleted templates (git history)
- Incremental commits for each phase

## Success Criteria

### Technical

- [ ] Exactly 5 templates in ~/Zettelkasten/templates/
- [ ] All contract tests passing
- [ ] All capability tests passing
- [ ] No luacheck warnings
- [ ] All pre-commit hooks passing

### User Experience

- [ ] Which-key shows emoji + readable descriptions
- [ ] Group names are clear (no cryptic "+N keymaps")
- [ ] Window/buffer management accessible
- [ ] Decision fatigue reduced (fewer templates)
- [ ] Maintains "beautiful! almost perfect!" quality

### Ready for Merge

- [ ] All tests passing
- [ ] Documentation updated
- [ ] Commit message complete
- [ ] Visual verification complete
- [ ] User approval obtained

## Next Steps After Merge

1. **User testing period** - 1-2 weeks of daily use
2. **Feedback collection** - Note any remaining friction
3. **Iteration** - Small improvements based on usage
4. **Stability period** - Lock in configuration once stable

## Notes

- **ADHD Optimization**: Every decision adds cognitive load - ruthlessly eliminate unnecessary choices
- **Minimal Visual Noise**: Emoji should clarify, not distract - use sparingly and consistently
- **Discoverability**: Which-key is the primary discovery mechanism - make it count
- **Frequency Optimization**: Most-used operations should be shortest path (fewest keystrokes)

______________________________________________________________________

**Status**: Ready to execute **Approval**: Pending user review **Branch**: workflow/zettelkasten-wiki-ai-pipeline **Target**: main (local merge)
