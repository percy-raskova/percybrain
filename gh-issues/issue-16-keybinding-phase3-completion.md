# Issue #16: Complete Keybinding Architecture - Phase 3

## Description

Complete the keybinding migration by adding plugin-level `keys = {}` definitions to remaining critical plugins. Phases 1-2 are complete (IWE built-ins + Zettelkasten core), this finalizes the architecture for all documented workflows.

**Architecture**: All keybindings are defined within plugin files using lazy.nvim's `keys = {}` table. The centralized keybinding approach (`lua/config/keymaps/`) was removed due to maintainability issues.

## Context

- **Phase 1**: ✅ Complete - IWE built-in keybindings enabled
- **Phase 2**: ✅ Complete - Core Zettelkasten keybindings added
- **Phase 3**: ⏳ This issue - Remaining plugin keybindings

**Current State**: 25% complete (2/8 tasks)

- ✅ Lynx browser keybindings (5 keys in `lua/plugins/experimental/lynx-wiki.lua`)
- ✅ AI visual mode keybindings (6+ keys in `lua/plugins/ai-sembr/ollama.lua`)

**Target State**: All plugin keybindings defined in-plugin via lazy.nvim `keys = {}` architecture

## Value

- 100% keybinding documentation parity
- Proper lazy loading (performance improvement)
- Maintainable plugin-based architecture
- No orphaned or centralized keybinding files

## Current Progress

**✅ Completed (2/8 tasks = 25%)**:

- Task 4: Lynx browser keybindings - `lua/plugins/experimental/lynx-wiki.lua:16-22`
- Task 7: AI visual mode keybindings - `lua/plugins/ai-sembr/ollama.lua:326-353`

**❌ Not Started (6/8 tasks = 75%)**:

- Task 1: Telescope - TODO comment at line 60, needs `keys = {}` table
- Task 2: Window manager plugin - file doesn't exist, needs creation
- Task 3: Quartz publishing plugin - file doesn't exist, needs creation
- Task 5: Trouble diagnostics - TODO comment at line 12, needs `keys = {}` table
- Task 6: Terminal/toggleterm - minimal config, needs `keys = {}` table
- Task 8: Documentation - needs Phase 3 sections added

## Tasks

### Task 1: Add Telescope Keybindings ❌ NOT DONE

**File**: `lua/plugins/zettelkasten/telescope.lua` **Estimated**: 15 minutes **Context Window**: Small - single plugin file

**Current State**: Line 60 has TODO comment referencing removed centralized keymap file

**Requirements**:

- Replace TODO comment with proper `keys = {}` table
- Add 5 keybindings: find files, live grep, buffers, keymaps, help tags
- Use `<leader>f*` namespace

**Implementation**: Replace line 60:

```lua
-- keys = {}, -- TODO: Add keybindings here -- All telescope keymaps managed in lua/config/keymaps/telescope.lua
```

With:

```lua
keys = {
  { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
  { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
  { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
  { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
  { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
},
```

**Acceptance Criteria**:

- [ ] TODO comment removed
- [ ] 5 keybindings added to `keys = {}` table
- [ ] Each key has proper `desc` field
- [ ] All keybindings tested and working
- [ ] Luacheck passes (no warnings)

______________________________________________________________________

### Task 2: Create Window Manager Keybindings Plugin ❌ NOT DONE

**File**: `lua/plugins/navigation/window-manager.lua` (NEW) **Estimated**: 30 minutes **Context Window**: Medium - new plugin with 26 keybindings

**Current State**: File doesn't exist. `lua/config/window-manager.lua` exists for functionality but NOT for keybindings.

**Requirements**:

- Create virtual plugin for window management keybindings
- Implement 26 window operations
- Use `<leader>w*` namespace
- Plugin loads native Neovim window commands (no external dependencies)

**Implementation**: Create new file:

```lua
-- Window management keybindings
-- Virtual plugin to load window management keys via lazy.nvim
return {
  dir = vim.fn.stdpath("config") .. "/lua",
  name = "window-manager-keys",
  lazy = false,
  priority = 50,
  keys = {
    -- Split management
    { "<leader>wv", "<cmd>vsplit<cr>", desc = "Vertical split" },
    { "<leader>wh", "<cmd>split<cr>", desc = "Horizontal split" },
    { "<leader>wc", "<cmd>close<cr>", desc = "Close window" },
    { "<leader>wo", "<cmd>only<cr>", desc = "Close other windows" },

    -- Navigation
    { "<leader>wj", "<C-w>j", desc = "Move to window below" },
    { "<leader>wk", "<C-w>k", desc = "Move to window above" },
    { "<leader>wl", "<C-w>l", desc = "Move to window right" },
    { "<leader>wh", "<C-w>h", desc = "Move to window left" },

    -- Resizing
    { "<leader>w=", "<C-w>=", desc = "Equalize windows" },
    { "<leader>w+", "<cmd>resize +5<cr>", desc = "Increase height" },
    { "<leader>w-", "<cmd>resize -5<cr>", desc = "Decrease height" },
    { "<leader>w>", "<cmd>vertical resize +5<cr>", desc = "Increase width" },
    { "<leader>w<", "<cmd>vertical resize -5<cr>", desc = "Decrease width" },

    -- Layout
    { "<leader>wH", "<C-w>H", desc = "Move window far left" },
    { "<leader>wJ", "<C-w>J", desc = "Move window far down" },
    { "<leader>wK", "<C-w>K", desc = "Move window far up" },
    { "<leader>wL", "<C-w>L", desc = "Move window far right" },

    -- Rotation
    { "<leader>wr", "<C-w>r", desc = "Rotate windows down/right" },
    { "<leader>wR", "<C-w>R", desc = "Rotate windows up/left" },

    -- Special
    { "<leader>wt", "<C-w>T", desc = "Move window to new tab" },
    { "<leader>wp", "<C-w>p", desc = "Go to previous window" },
    { "<leader>ww", "<C-w>w", desc = "Cycle through windows" },
    { "<leader>wq", "<cmd>q<cr>", desc = "Quit window" },

    -- Focus/Swap
    { "<leader>wf", "<C-w>_<C-w>|", desc = "Focus current window (maximize)" },
    { "<leader>wx", "<C-w>x", desc = "Swap with next window" },
  },
}
```

**Acceptance Criteria**:

- [ ] New file created in `lua/plugins/navigation/`
- [ ] All 26 keybindings implemented
- [ ] Each binding has descriptive `desc` field
- [ ] Virtual plugin loads correctly (lazy.nvim detects it)
- [ ] All window operations tested and working

______________________________________________________________________

### Task 3: Create Quartz Publishing Keybindings Plugin ❌ NOT DONE

**File**: `lua/plugins/publishing/quartz.lua` (NEW) **Estimated**: 15 minutes **Context Window**: Small - new plugin with 4 keybindings

**Current State**: File doesn't exist. Quartz publishing is documented but keybindings not yet created.

**Requirements**:

- Create plugin for Quartz publishing workflow
- Add 4 keybindings: preview, build, publish, open
- Use `<leader>pq*` namespace
- Integrate with Mise tasks (requires Issue #15 completion)

**Implementation**: Create new file:

```lua
-- Quartz publishing integration
-- Virtual plugin for Quartz publishing keybindings
return {
  dir = vim.fn.stdpath("config") .. "/lua",
  name = "quartz-publishing",
  lazy = false,
  priority = 40,
  keys = {
    {
      "<leader>pqp",
      "<cmd>!mise quartz-preview &<cr>",
      desc = "Quartz: Preview locally (port 8080)"
    },
    {
      "<leader>pqb",
      "<cmd>!mise quartz-build<cr>",
      desc = "Quartz: Build static site"
    },
    {
      "<leader>pqs",
      "<cmd>!mise quartz-publish<cr>",
      desc = "Quartz: Publish to GitHub Pages"
    },
    {
      "<leader>pqo",
      "<cmd>!xdg-open http://localhost:8080<cr>",
      desc = "Quartz: Open preview in browser"
    },
  },
  config = function()
    -- User command for convenience
    vim.api.nvim_create_user_command("QuartzPreview", function()
      vim.cmd("!mise quartz-preview &")
      vim.notify("🌐 Quartz preview starting at http://localhost:8080", vim.log.levels.INFO)
    end, { desc = "Start Quartz preview server" })

    vim.api.nvim_create_user_command("QuartzPublish", function()
      vim.cmd("!mise quartz-publish")
      vim.notify("📤 Publishing to GitHub Pages...", vim.log.levels.INFO)
    end, { desc = "Publish Zettelkasten to GitHub Pages" })
  end,
}
```

**Dependencies**: Requires Issue #15 (Mise tasks) to be complete for commands to work.

**Acceptance Criteria**:

- [ ] New file created in `lua/plugins/publishing/`
- [ ] 4 keybindings implemented
- [ ] Commands use Mise tasks from Issue #15
- [ ] User commands `QuartzPreview` and `QuartzPublish` created
- [ ] All operations tested and working (after Issue #15 complete)

______________________________________________________________________

### Task 4: Lynx Browser Keybindings ✅ COMPLETE

**File**: `lua/plugins/experimental/lynx-wiki.lua` **Status**: ✅ Already implemented (lines 16-22)

**Evidence**:

```lua
keys = {
  { "<leader>lo", "<cmd>LynxOpen<cr>", desc = "Open URL in Lynx" },
  { "<leader>le", "<cmd>LynxExport<cr>", desc = "Export page to Wiki" },
  { "<leader>lc", "<cmd>LynxCite<cr>", desc = "Generate BibTeX citation" },
  { "<leader>ls", "<cmd>LynxSummarize<cr>", desc = "AI Summarize page" },
  { "<leader>lx", "<cmd>LynxExtract<cr>", desc = "AI Extract key points" },
},
```

**Completion**: 5 keybindings implemented (exceeds original 4-keybinding requirement)

______________________________________________________________________

### Task 5: Add Trouble Diagnostics Keybindings ❌ NOT DONE

**File**: `lua/plugins/diagnostics/trouble.lua` **Estimated**: 15 minutes **Context Window**: Small - existing plugin update

**Current State**: Line 12 has TODO comment referencing removed centralized keymap file. Plugin has internal window navigation keys (lines 53-73) but NOT lazy.nvim loading keys.

**Requirements**:

- Update existing trouble.nvim plugin configuration
- Add `keys = {}` table with 6 diagnostic keybindings
- Use `<leader>x*` namespace

**Implementation**: Replace line 12:

```lua
-- keys = {}, -- TODO: Add keybindings here -- All trouble keymaps managed in lua/config/keymaps/diagnostics.lua
```

With:

```lua
keys = {
  {
    "<leader>xx",
    "<cmd>Trouble diagnostics toggle<cr>",
    desc = "Trouble: Toggle diagnostics"
  },
  {
    "<leader>xw",
    "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
    desc = "Trouble: Workspace diagnostics"
  },
  {
    "<leader>xd",
    "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
    desc = "Trouble: Document diagnostics"
  },
  {
    "<leader>xq",
    "<cmd>Trouble qflist toggle<cr>",
    desc = "Trouble: Quickfix list"
  },
  {
    "<leader>xl",
    "<cmd>Trouble loclist toggle<cr>",
    desc = "Trouble: Location list"
  },
  {
    "<leader>xr",
    "<cmd>Trouble lsp toggle focus=false<cr>",
    desc = "Trouble: LSP references"
  },
},
```

**Note**: Commands updated for Trouble v3 API (file comment confirms v3.7.1)

**Acceptance Criteria**:

- [ ] TODO comment removed
- [ ] 6 keybindings added to lazy.nvim keys table
- [ ] Commands use Trouble v3 API syntax
- [ ] Each command tested and working
- [ ] Trouble UI displays correctly

______________________________________________________________________

### Task 6: Add Terminal Keybindings ❌ NOT DONE

**File**: `lua/plugins/utilities/toggleterm.lua` **Estimated**: 15 minutes **Context Window**: Small - existing plugin update

**Current State**: Minimal 30-line config with only `config = true`. No keybindings defined.

**Requirements**:

- Update toggleterm.nvim configuration
- Add `keys = {}` table with 10 terminal/utility keybindings
- Use `<leader>t*` namespace

**Implementation**: Replace entire file with:

```lua
-- Plugin: toggleterm
-- Purpose: Persistent terminal windows with toggle/multi-terminal support
-- Workflow: utilities
-- Why: Seamless terminal integration with ADHD-optimized quick toggle,
--      state persistence, and multiple terminal support for different contexts.

return {
  "akinsho/toggleterm.nvim",
  version = "*",
  keys = {
    -- Terminal modes
    { "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
    { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Terminal: Float" },
    { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Terminal: Horizontal" },
    { "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", desc = "Terminal: Vertical" },

    -- Time utilities (writer convenience)
    { "<leader>td", "<cmd>put =strftime('%Y-%m-%d')<cr>", desc = "Insert date" },
    { "<leader>ts", "<cmd>put =strftime('%Y%m%d%H%M%S')<cr>", desc = "Insert timestamp" },
    { "<leader>tn", "<cmd>put =strftime('%Y-%m-%d %H:%M')<cr>", desc = "Insert datetime" },

    -- Quick access to common terminals
    { "<leader>tm", "<cmd>ToggleTerm direction=float<cr>mise<cr>", desc = "Terminal: Mise runner" },
    { "<leader>tg", "<cmd>ToggleTerm direction=float<cr>lazygit<cr>", desc = "Terminal: LazyGit" },
  },
  config = function()
    require("toggleterm").setup({
      size = 20,
      open_mapping = [[<c-\>]],
      hide_numbers = true,
      shade_terminals = true,
      start_in_insert = true,
      insert_mappings = true,
      terminal_mappings = true,
      persist_size = true,
      persist_mode = true,
      direction = "float",
      close_on_exit = true,
      shell = vim.o.shell,
      float_opts = {
        border = "curved",
        winblend = 0,
      },
    })
  end,
}
```

**Acceptance Criteria**:

- [ ] 9 keybindings added (terminal modes + time utilities + quick access)
- [ ] Terminal commands tested (float, horizontal, vertical)
- [ ] Date/timestamp insertion works
- [ ] Mise and LazyGit terminal shortcuts work
- [ ] Config preserves ADHD-optimized behavior (persistence, quick toggle)

______________________________________________________________________

### Task 7: Visual Mode AI Keybindings ✅ COMPLETE

**File**: `lua/plugins/ai-sembr/ollama.lua` **Status**: ✅ Already implemented (lines 326-353)

**Evidence**:

```lua
-- AI menu
vim.keymap.set("n", "<leader>aa", M.ai_menu, vim.tbl_extend("force", opts, { desc = "AI: Command Menu" }))

-- Individual AI commands (all support visual mode)
vim.keymap.set({ "n", "v" }, "<leader>ae", M.explain, vim.tbl_extend("force", opts, { desc = "AI: Explain" }))
vim.keymap.set({ "n", "v" }, "<leader>as", M.summarize, vim.tbl_extend("force", opts, { desc = "AI: Summarize" }))
vim.keymap.set("n", "<leader>al", M.suggest_links, vim.tbl_extend("force", opts, { desc = "AI: Suggest Links" }))
vim.keymap.set({ "n", "v" }, "<leader>aw", M.improve, vim.tbl_extend("force", opts, { desc = "AI: Improve Writing" }))
vim.keymap.set("n", "<leader>aq", M.answer_question, vim.tbl_extend("force", opts, { desc = "AI: Ask Question" }))
vim.keymap.set("n", "<leader>ax", M.generate_ideas, vim.tbl_extend("force", opts, { desc = "AI: Generate Ideas (eXplore)" }))
```

**Completion**: 6+ keybindings with full visual mode support via `{ "n", "v" }` mode specification

______________________________________________________________________

### Task 8: Update Documentation ❌ NOT DONE

**Files**:

- `docs/reference/KEYBINDINGS_REFERENCE.md` (primary)
- `docs/reference/IWE_REFERENCE.md` (if keybindings referenced)
- `docs/tutorials/IWE_KEYBINDINGS_TESTING_GUIDE.md` (testing procedures)

**Estimated**: 30 minutes **Context Window**: Medium - multi-file documentation update

**Current State**:

- KEYBINDINGS_REFERENCE.md shows "Last Updated: 2025-10-21 (Phase 1 & 2)"
- Phase 3 sections missing or incomplete
- Some keybindings documented but NOT aligned with Issue #16 requirements

**Requirements**:

- Add/update Phase 3 keybinding sections
- Organize by namespace (`<leader>w*`, `<leader>pq*`, `<leader>x*`, `<leader>t*`, `<leader>l*`)
- Update header to reflect Phase 3 completion
- Ensure consistency across all documentation files

**Implementation for KEYBINDINGS_REFERENCE.md**:

1. **Update header** (lines 1-15):

```markdown
# PercyBrain Keybindings Reference

**Category**: Reference (Information-Oriented)
**Last Updated**: 2025-10-24
**Architecture**: Phases 1-3 complete - All keybindings in plugin files
**Migration**: Centralized keybinds removed, lazy.nvim keys architecture only

Complete reference of all keybindings in PercyBrain organized by workflow.

**Phase 3 Complete (2025-10-24)**:
- ✅ Window management (`<leader>w*`) - 26 keybindings
- ✅ Quartz publishing (`<leader>pq*`) - 4 keybindings
- ✅ Trouble diagnostics (`<leader>x*`) - 6 keybindings
- ✅ Terminal utilities (`<leader>t*`) - 9 keybindings
- ✅ Lynx browser (`<leader>l*`) - 5 keybindings
- ✅ AI visual mode (`<leader>a*`) - 6+ keybindings
```

2. **Add Window Management section** (new):

```markdown
## Window Management (`<leader>w*`)

Neovim window operations for split management, navigation, and layout control.

**Phase 3 Addition**: Complete window management namespace (26 keybindings)

### Split Management
| Keymap       | Mode | Description           |
|--------------|------|-----------------------|
| `<leader>wv` | n    | Vertical split        |
| `<leader>wh` | n    | Horizontal split      |
| `<leader>wc` | n    | Close window          |
| `<leader>wo` | n    | Close other windows   |

### Navigation
| Keymap       | Mode | Description           |
|--------------|------|-----------------------|
| `<leader>wj` | n    | Move to window below  |
| `<leader>wk` | n    | Move to window above  |
| `<leader>wl` | n    | Move to window right  |
| `<leader>wh` | n    | Move to window left   |

### Resizing
| Keymap        | Mode | Description          |
|---------------|------|----------------------|
| `<leader>w=`  | n    | Equalize windows     |
| `<leader>w+`  | n    | Increase height      |
| `<leader>w-`  | n    | Decrease height      |
| `<leader>w>`  | n    | Increase width       |
| `<leader>w<`  | n    | Decrease width       |

### Layout & Rotation
| Keymap        | Mode | Description               |
|---------------|------|---------------------------|
| `<leader>wH`  | n    | Move window far left      |
| `<leader>wJ`  | n    | Move window far down      |
| `<leader>wK`  | n    | Move window far up        |
| `<leader>wL`  | n    | Move window far right     |
| `<leader>wr`  | n    | Rotate windows down/right |
| `<leader>wR`  | n    | Rotate windows up/left    |

### Special Operations
| Keymap        | Mode | Description                      |
|---------------|------|----------------------------------|
| `<leader>wt`  | n    | Move window to new tab           |
| `<leader>wp`  | n    | Go to previous window            |
| `<leader>ww`  | n    | Cycle through windows            |
| `<leader>wq`  | n    | Quit window                      |
| `<leader>wf`  | n    | Focus current (maximize)         |
| `<leader>wx`  | n    | Swap with next window            |
```

3. **Add Quartz Publishing section** (new):

```markdown
## Quartz Publishing (`<leader>pq*`)

Static site publishing workflow for Zettelkasten knowledge base.

**Phase 3 Addition**: Quartz publishing keybindings (4 keybindings)
**Requirements**: Mise tasks from Issue #15 must be configured

| Keymap        | Mode | Description                       |
|---------------|------|-----------------------------------|
| `<leader>pqp` | n    | Preview locally (port 8080)       |
| `<leader>pqb` | n    | Build static site                 |
| `<leader>pqs` | n    | Publish to GitHub Pages           |
| `<leader>pqo` | n    | Open preview in browser           |

**Commands**: `:QuartzPreview`, `:QuartzPublish`
```

4. **Update Diagnostics section** (replace existing):

```markdown
## Diagnostics & Trouble (`<leader>x*`)

Code diagnostics, error lists, and LSP references via Trouble.nvim.

**Phase 3 Update**: Trouble v3 API keybindings (6 keybindings)

| Keymap        | Mode | Description                  |
|---------------|------|------------------------------|
| `<leader>xx`  | n    | Toggle diagnostics panel     |
| `<leader>xw`  | n    | Workspace diagnostics        |
| `<leader>xd`  | n    | Document diagnostics         |
| `<leader>xq`  | n    | Quickfix list                |
| `<leader>xl`  | n    | Location list                |
| `<leader>xr`  | n    | LSP references               |
```

5. **Update Terminal section** (replace existing):

```markdown
## Terminal & Utilities (`<leader>t*`)

Terminal integration and time utilities for writing workflows.

**Phase 3 Update**: Comprehensive terminal keybindings (9 keybindings)

### Terminal Modes
| Keymap        | Mode | Description            |
|---------------|------|------------------------|
| `<leader>tt`  | n    | Toggle terminal        |
| `<leader>tf`  | n    | Floating terminal      |
| `<leader>th`  | n    | Horizontal split term  |
| `<leader>tv`  | n    | Vertical split term    |

### Time Utilities
| Keymap        | Mode | Description          |
|---------------|------|----------------------|
| `<leader>td`  | n    | Insert date          |
| `<leader>ts`  | n    | Insert timestamp     |
| `<leader>tn`  | n    | Insert datetime      |

### Quick Access
| Keymap        | Mode | Description          |
|---------------|------|----------------------|
| `<leader>tm`  | n    | Mise runner terminal |
| `<leader>tg`  | n    | LazyGit terminal     |

**Global**: `<C-\>` toggles last terminal from any mode
```

6. **Add Lynx Browser section** (new):

```markdown
## Lynx Browser Integration (`<leader>l*`)

Text-based web browser with Wiki export and AI analysis.

**Phase 3 Addition**: Lynx browser workflow (5 keybindings)

| Keymap        | Mode | Description                    |
|---------------|------|--------------------------------|
| `<leader>lo`  | n    | Open URL in Lynx browser       |
| `<leader>le`  | n    | Export page to Wiki (Markdown) |
| `<leader>lc`  | n    | Generate BibTeX citation       |
| `<leader>ls`  | n    | AI summarize page              |
| `<leader>lx`  | n    | AI extract key points          |

**Commands**: `:LynxOpen`, `:LynxExport`, `:LynxCite`, `:LynxSummarize`, `:LynxExtract`
```

7. **Update AI Commands section** (confirm visual mode):

```markdown
## AI Commands (`<leader>a*`)

Local AI integration via Ollama for writing assistance.

**Phase 3 Verification**: Visual mode support confirmed (6+ keybindings)

| Keymap        | Mode  | Description                   |
|---------------|-------|-------------------------------|
| `<leader>aa`  | n     | AI command menu               |
| `<leader>ae`  | n, v  | Explain text/selection        |
| `<leader>as`  | n, v  | Summarize note/selection      |
| `<leader>al`  | n     | Suggest related links         |
| `<leader>aw`  | n, v  | Improve writing               |
| `<leader>aq`  | n     | Answer question about note    |
| `<leader>ax`  | n     | Generate ideas                |

**Visual Mode**: `<leader>ae`, `<leader>as`, `<leader>aw` work on selections
```

**Acceptance Criteria**:

- [ ] Header updated to reflect Phase 3 completion (2025-10-24)
- [ ] All 6 new/updated sections added
- [ ] Tables formatted consistently
- [ ] Total keybinding count accurate
- [ ] Cross-references to plugin files included
- [ ] Markdown formatting validated (mdformat passes)
- [ ] Related docs (IWE_REFERENCE.md, testing guides) updated if needed

______________________________________________________________________

## Dependencies

- **Prerequisite**: Phases 1-2 complete (IWE + Zettelkasten core) ✅
- **Requires**: lazy.nvim plugin manager ✅
- **Related**: Issue #15 (Quartz Mise tasks) - required for Task 3 keybindings to work
- **Architecture**: Centralized keybinds (`lua/config/keymaps/`) removed, plugin-only approach

## Estimated Effort

- **Total**: 2.5-3 hours (reduced from 3-4 hours due to 2 tasks already complete)
- **Task 1**: 15 min (Telescope) ❌
- **Task 2**: 30 min (Window manager) ❌
- **Task 3**: 15 min (Quartz) ❌
- **Task 4**: ~~10 min~~ ✅ COMPLETE
- **Task 5**: 15 min (Trouble) ❌
- **Task 6**: 15 min (Terminal) ❌
- **Task 7**: ~~10 min~~ ✅ COMPLETE
- **Task 8**: 30 min (Documentation) ❌

**Remaining effort**: ~2 hours for 6 incomplete tasks

## Success Criteria

- [ ] All 8 tasks completed
- [x] Lynx browser keybindings working (Task 4) ✅
- [x] AI visual mode keybindings working (Task 7) ✅
- [ ] All plugins use lazy.nvim `keys = {}` architecture
- [ ] No centralized keybinding files (architecture verified)
- [ ] KEYBINDINGS_REFERENCE.md updated with Phase 3 sections
- [ ] All documentation files updated and consistent
- [ ] All keybindings tested and validated

## Related Files

**Plugin Files**:

- `lua/plugins/zettelkasten/telescope.lua` - Needs keys table (Task 1)
- `lua/plugins/navigation/window-manager.lua` - NEW, needs creation (Task 2)
- `lua/plugins/publishing/quartz.lua` - NEW, needs creation (Task 3)
- `lua/plugins/experimental/lynx-wiki.lua` - ✅ Complete (Task 4)
- `lua/plugins/diagnostics/trouble.lua` - Needs keys table (Task 5)
- `lua/plugins/utilities/toggleterm.lua` - Needs keys table + config (Task 6)
- `lua/plugins/ai-sembr/ollama.lua` - ✅ Complete (Task 7)

**Documentation Files**:

- `docs/reference/KEYBINDINGS_REFERENCE.md` - Primary documentation (Task 8)
- `docs/reference/IWE_REFERENCE.md` - May need keybinding updates
- `docs/tutorials/IWE_KEYBINDINGS_TESTING_GUIDE.md` - May need test procedures

**Architecture Reference**:

- `claudedocs/KEYBINDING_ARCHITECTURE_ANALYSIS_2025-10-23.md` - Historical context
