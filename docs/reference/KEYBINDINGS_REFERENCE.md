# PercyBrain Keybindings Reference

**Category**: Reference (Information-Oriented) **Last Updated**: 2025-10-24 **Major Refactor**: Keybinding architecture migration (Phases 1, 2, 3 complete) **Migration Guide**: See `gh-issues/issue-16-keybinding-phase3-completion.md`

Complete reference of all keybindings in PercyBrain organized by workflow and functionality.

⚠️ **BREAKING CHANGES**: Many keybindings changed in 2025-10-21 refactor (Phase 1 & 2). Phase 3 completed 2025-10-24.

**Phase 3 Highlights** (2025-10-24):

- ✅ Window navigation with Kitty integration (Ctrl+h/j/k/l)
- ✅ Quartz publishing workflow (`<leader>pq*`)
- ✅ Terminal enhancements with toggleterm (`<leader>t*`)
- ✅ Inline image preview with hologram (`<leader>ti`)
- ✅ Trouble v3 diagnostics (toggle-based API)

**Phase 2 Highlights** (2025-10-21):

- ✅ Mode-switching added (`<leader>m*`) - Context-aware workspace configurations
- ✅ Frequency optimization - Most common actions get shortest keys
- ✅ `<leader>f` finds notes (not files), `<leader>n` creates notes, `<leader>i` quick capture

______________________________________________________________________

## Leader Key

PercyBrain uses **Space** (`<space>`) as the leader key.

- **Leader Key**: `<space>`
- **Local Leader**: `<space>` (same as leader)

All keybindings shown below use `<leader>` which represents the space key.

______________________________________________________________________

## Core Navigation & File Management

Essential keybindings for basic Neovim operations and file management.

**Phase 2 Changes**: `<leader>n` now creates new note (frequency optimization). Line numbers moved to `<leader>vn`.

| Keymap       | Mode | Command/Action    | Description                   |
| ------------ | ---- | ----------------- | ----------------------------- |
| `<leader>e`  | n    | `:NvimTreeToggle` | Toggle file explorer          |
| `<leader>x`  | n    | `:NvimTreeFocus`  | Focus file explorer           |
| `<leader>q`  | n    | `:q!`             | Quit without saving           |
| `<leader>s`  | n    | `:w!`             | Save file                     |
| `<leader>c`  | n    | `:close`          | Close current window          |
| `<leader>v`  | n    | `:vsplit`         | Vertical split                |
| `<leader>vn` | n    | Toggle numbers    | Toggle line numbers (Phase 2) |
| `<leader>W`  | n    | `:WhichKey`       | Show which-key help           |
| `<leader>a`  | n    | `:Alpha`          | Show Alpha dashboard          |
| `<leader>nw` | n    | `:NewWriterFile`  | Create new writing file       |

______________________________________________________________________

## Frequency-Optimized Shortcuts (Phase 2)

**Design Philosophy**: Most frequent writer actions get the shortest possible keys (1-2 keystrokes total).

| Keymap      | Mode | Description               | Frequency    | Replaces     |
| ----------- | ---- | ------------------------- | ------------ | ------------ |
| `<leader>f` | n    | Find notes (Zettelkasten) | 50+ /session | `<leader>ff` |
| `<leader>n` | n    | New note (quick)          | 50+ /session | `<leader>zn` |
| `<leader>i` | n    | Inbox capture (quick)     | 20+ /session | `<leader>zq` |

**Displaced keybindings** (moved to longer combos):

- `<leader>ff` - Find files (filesystem) - was `<leader>f`
- `<leader>vn` - Toggle line numbers - was `<leader>n`
- `<leader>zq` - Quick capture (still available for discoverability)

**Justification**:

- Writers create/find notes 50+ times per session
- Toggling line numbers: 1-2 times per session
- Finding filesystem files: 5-10 times per session
- Quick capture: 20+ times per session

______________________________________________________________________

## Zettelkasten Workflow

**Writer-First Philosophy**: ALL Zettelkasten operations consolidated under `<leader>z*` namespace for speed of thought access.

**Phase 2 Optimization**: Most frequent operations also available as single-key shortcuts (see Frequency-Optimized Shortcuts above).

### Core Note Operations

| Keymap       | Mode | Description                              | Plugin             |
| ------------ | ---- | ---------------------------------------- | ------------------ |
| `<leader>n`  | n    | **New note (quick)** - OPTIMIZED         | Zettelkasten       |
| `<leader>zn` | n    | Create new permanent note (with options) | Zettelkasten       |
| `<leader>zd` | n    | Open today's daily note                  | Zettelkasten (IWE) |
| `<leader>zi` | n    | Create inbox note                        | Zettelkasten       |
| `<leader>i`  | n    | **Quick capture (quick)** - OPTIMIZED    | QuickCapture       |
| `<leader>zq` | n    | Quick capture (floating window)          | QuickCapture       |
| `<leader>zf` | n    | Fuzzy find notes                         | Telescope          |
| `<leader>zg` | n    | Search note content (grep)               | Telescope          |
| `<leader>zb` | n    | Show backlinks to current note           | Zettelkasten       |
| `<leader>zo` | n    | Find orphan notes                        | PercyOrphans       |
| `<leader>zh` | n    | Find hub notes                           | PercyHubs          |
| `<leader>zp` | n    | Publish to Hugo                          | Hugo               |
| `<leader>zt` | n    | Browse tags (custom Telescope picker)    | Zettelkasten (IWE) |
| `<leader>zc` | n    | Calendar picker (custom Telescope)       | Zettelkasten (IWE) |
| `<leader>zl` | n    | Follow link (LSP definition jump)        | IWE LSP            |
| `<leader>zk` | n    | Insert link (LSP code action)            | IWE LSP            |

### IWE Navigation (Consolidated under `<leader>z*`)

**Note**: These were previously under `g*` prefix - now consolidated to Zettelkasten namespace.

| Keymap       | Mode | Description                     | Plugin |
| ------------ | ---- | ------------------------------- | ------ |
| `<leader>zF` | n    | IWE: Find files                 | IWE    |
| `<leader>zS` | n    | IWE: Workspace symbols          | IWE    |
| `<leader>zA` | n    | IWE: Namespace symbols          | IWE    |
| `<leader>z/` | n    | IWE: Live grep search           | IWE    |
| `<leader>zB` | n    | IWE: Backlinks (LSP references) | IWE    |
| `<leader>zO` | n    | IWE: Document outline (symbols) | IWE    |

### IWE Refactoring (Consolidated under `<leader>zr*`)

**Note**: These were previously under `<leader>i*` prefix - now in refactor sub-namespace.

| Keymap        | Mode | Description            | Plugin |
| ------------- | ---- | ---------------------- | ------ |
| `<leader>zrh` | n    | Rewrite list → heading | IWE    |
| `<leader>zrl` | n    | Rewrite heading → list | IWE    |

______________________________________________________________________

## IWE (Integrated Writing Environment)

### Preview Generation (`<leader>ip*` prefix)

Generate various preview formats for export and visualization. Publishing-related operations kept separate from core Zettelkasten workflow.

| Keymap        | Mode | Command                | Description                               | Plugin |
| ------------- | ---- | ---------------------- | ----------------------------------------- | ------ |
| `<leader>ips` | n    | `:IWEPreviewSquash`    | IWE: Generate squash preview              | IWE    |
| `<leader>ipe` | n    | `:IWEPreviewExport`    | IWE: Generate export graph preview        | IWE    |
| `<leader>iph` | n    | `:IWEPreviewHeaders`   | IWE: Generate export with headers preview | IWE    |
| `<leader>ipw` | n    | `:IWEPreviewWorkspace` | IWE: Generate workspace preview           | IWE    |

### Markdown Editing (built-in)

IWE also provides markdown-specific editing keybindings (managed directly by plugin):

| Keymap  | Mode | Command                   | Description                    | Plugin |
| ------- | ---- | ------------------------- | ------------------------------ | ------ |
| `-`     | n    | Format checklist item     | Format line as checklist       | IWE    |
| `<C-n>` | n    | Navigate to next link     | Jump to next markdown link     | IWE    |
| `<C-p>` | n    | Navigate to previous link | Jump to previous markdown link | IWE    |
| `/d`    | i    | Insert current date       | Insert today's date            | IWE    |
| `/w`    | i    | Insert current week       | Insert current week            | IWE    |

**Note**: IWE keybindings use the `<leader>i*` namespace to avoid conflicts with Lynx browser (`<leader>l*`) and Prose workflow (`<leader>p*`).

______________________________________________________________________

## AI Commands (Ollama Integration)

Local AI assistance for writing and knowledge management. All AI commands use the `<leader>a*` prefix.

| Keymap       | Mode | Description                    | Plugin |
| ------------ | ---- | ------------------------------ | ------ |
| `<leader>a`  | n    | **(Group)** AI commands prefix | Ollama |
| `<leader>aa` | n    | Show AI command menu           | Ollama |
| `<leader>ac` | n    | AI chat                        | Ollama |
| `<leader>ad` | n    | AI draft                       | Ollama |
| `<leader>ae` | n, v | AI: Explain text/selection     | Ollama |
| `<leader>am` | n    | AI model select                | Ollama |
| `<leader>ar` | n    | AI rewrite                     | Ollama |
| `<leader>as` | n, v | AI: Summarize note/selection   | Ollama |

______________________________________________________________________

## Telescope Fuzzy Finder

Fast fuzzy finding for files, content, and metadata using the `<leader>f*` prefix.

**Phase 2 Optimization**: `<leader>f` now finds NOTES (most frequent operation for writers), not generic files.

| Keymap        | Mode | Description                               |
| ------------- | ---- | ----------------------------------------- |
| `<leader>f`   | n    | **Find notes (Zettelkasten)** - OPTIMIZED |
| `<leader>ff`  | n    | Telescope: Find files (filesystem)        |
| `<leader>fg`  | n    | Telescope: Live grep content              |
| `<leader>fb`  | n    | Telescope: List open buffers              |
| `<leader>fc`  | n    | Telescope: Commands                       |
| `<leader>fh`  | n    | Telescope: Search help tags               |
| `<leader>fk`  | n    | Telescope: Search keymaps                 |
| `<leader>fr`  | n    | Telescope: Recent files                   |
| `<leader>ft`  | n    | Telescope: Tags                           |
| `<leader>fzg` | n    | FzfLua: Live grep (alternative interface) |
| `<leader>fzl` | n    | FzfLua: Find files (alternative)          |
| `<leader>fzm` | n    | FzfLua: Marks (alternative)               |

______________________________________________________________________

## Prose Writing

**Writer-First Philosophy**: Expanded prose tools for focused writing, time tracking, and document management.

| Keymap        | Mode | Description                | Plugin     |
| ------------- | ---- | -------------------------- | ---------- |
| `<leader>pp`  | n    | Prose mode toggle          | Prose      |
| `<leader>pf`  | n    | Focus mode (Goyo)          | Goyo       |
| `<leader>pr`  | n    | Reading mode (hide UI)     | Built-in   |
| `<leader>pm`  | n    | Toggle StyledDoc preview   | StyledDoc  |
| `<leader>pP`  | n    | Paste image (capital P)    | PasteImage |
| `<leader>pw`  | n    | Word count stats           | Built-in   |
| `<leader>ps`  | n    | Toggle spell check         | Built-in   |
| `<leader>pg`  | n    | Start grammar check (ltex) | ltex-ls    |
| `<leader>pts` | n    | Timer start                | Pendulum   |
| `<leader>pte` | n    | Timer stop                 | Pendulum   |
| `<leader>ptt` | n    | Timer status               | Pendulum   |
| `<leader>ptr` | n    | Timer report               | Pendulum   |

**Note**: Time tracking moved from `<leader>op*` to `<leader>pt*` for better integration with writing workflow.

______________________________________________________________________

## Mode Switching (Phase 2)

Context-aware workspace configurations for different writing workflows. Each mode optimizes vim settings and plugin states for specific contexts.

| Keymap       | Mode | Description                             | Features Enabled                                     |
| ------------ | ---- | --------------------------------------- | ---------------------------------------------------- |
| `<leader>m`  | n    | **(Group)** Mode switching prefix       | —                                                    |
| `<leader>mw` | n    | Writing mode (focus, spell, prose)      | Goyo, spell check, SemBr, soft wrap, no line numbers |
| `<leader>mr` | n    | Research mode (splits, backlinks, tree) | Splits, NvimTree, line numbers, spell check          |
| `<leader>me` | n    | Editing mode (diagnostics, LSP, errors) | Trouble panel, diagnostics, LSP, line numbers        |
| `<leader>mp` | n    | Publishing mode (Hugo, preview, build)  | Hugo server, markdown preview, spell check           |
| `<leader>mn` | n    | Normal mode (reset to defaults)         | Baseline PercyBrain configuration                    |

**Use Cases**:

- **Writing Mode** (`<leader>mw`): Deep focus prose creation with minimal distractions
- **Research Mode** (`<leader>mr`): Multi-window note exploration and cross-referencing
- **Editing Mode** (`<leader>me`): Technical editing with full diagnostic support
- **Publishing Mode** (`<leader>mp`): Content preparation with live preview
- **Normal Mode** (`<leader>mn`): Reset after mode switching

**Design Philosophy**: Writers work in distinct contexts requiring different tool configurations. One-key mode switching removes friction from context transitions.

______________________________________________________________________

## Git Integration

**Writer-First Philosophy**: Simplified to essential operations. Use LazyGit GUI (`<leader>gg`) for complex operations.

### Primary Interface

| Keymap       | Mode | Description                         | Plugin  |
| ------------ | ---- | ----------------------------------- | ------- |
| `<leader>gg` | n    | **LazyGit GUI (primary interface)** | LazyGit |

### Essential Operations

| Keymap       | Mode | Description | Plugin   |
| ------------ | ---- | ----------- | -------- |
| `<leader>gs` | n    | Git status  | Fugitive |
| `<leader>gc` | n    | Git commit  | Fugitive |
| `<leader>gp` | n    | Git push    | Fugitive |
| `<leader>gb` | n    | Git blame   | Fugitive |
| `<leader>gl` | n    | Git log     | Fugitive |

### Hunk Operations (Review Writing Changes)

| Keymap        | Mode | Description       | Plugin   |
| ------------- | ---- | ----------------- | -------- |
| `<leader>ghp` | n    | Preview hunk      | Gitsigns |
| `<leader>ghs` | n    | Stage hunk        | Gitsigns |
| `<leader>ghu` | n    | Undo stage hunk   | Gitsigns |
| `]c`          | n    | Next git hunk     | Gitsigns |
| `[c`          | n    | Previous git hunk | Gitsigns |

**Removed Operations** (use LazyGit GUI instead):

- Diffview operations (`<leader>gd*`) - Use LazyGit diff view
- Advanced hunk operations (`<leader>ghr`, `<leader>ghb`) - Use LazyGit

______________________________________________________________________

## Terminal & Task Management

Terminal integration and development tools.

| Keymap       | Mode | Command           | Description              |
| ------------ | ---- | ----------------- | ------------------------ |
| `<leader>t`  | n    | `:terminal`       | Open terminal            |
| `<leader>ft` | n    | `:FloatermToggle` | Toggle floating terminal |
| `<leader>te` | n    | `:ToggleTerm`     | Toggle terminal          |

______________________________________________________________________

## Translation

Multi-language translation support.

| Keymap       | Mode | Command         | Description          |
| ------------ | ---- | --------------- | -------------------- |
| `<leader>tf` | n    | `:Translate fr` | Translate to French  |
| `<leader>tt` | n    | `:Translate ta` | Translate to Tamil   |
| `<leader>ts` | n    | `:Translate si` | Translate to Sinhala |

______________________________________________________________________

## Plugin Management

Lazy.nvim plugin manager.

| Keymap      | Mode | Description                 |
| ----------- | ---- | --------------------------- |
| `<leader>L` | n    | Open Lazy plugin manager UI |

______________________________________________________________________

## Diagnostics & Lists

Code quality, error checking, and quickfix navigation.

| Keymap       | Mode | Description                    |
| ------------ | ---- | ------------------------------ |
| `<leader>x`  | n    | **(Group)** Diagnostics prefix |
| `<leader>xd` | n    | Trouble: Diagnostics           |
| `<leader>xl` | n    | Trouble: Location list         |
| `<leader>xL` | n    | Trouble: LSP definitions       |
| `<leader>xQ` | n    | Trouble: Quickfix list         |
| `<leader>xs` | n    | Trouble: Document symbols      |
| `<leader>xx` | n    | Trouble: Toggle                |

______________________________________________________________________

## Keymap Conflicts & Resolutions

**After 2025-10-21 Refactor**: Most conflicts resolved through namespace consolidation.

| Keymap       | Primary Command      | Notes                               |
| ------------ | -------------------- | ----------------------------------- |
| `<leader>zi` | Create inbox note    | Quick capture moved to `<leader>zq` |
| `<leader>zt` | Telekasten show tags | Kept for tag browsing               |
| `<leader>zp` | Hugo publish         | Publishing workflow                 |

**Resolved Conflicts** (2025-10-21):

- IWE navigation (`g*`) → Consolidated to `<leader>z*` (no more Vim built-in conflicts)
- IWE refactoring (`<leader>i*`) → Consolidated to `<leader>zr*`
- Quick capture (`<leader>qc`) → Consolidated to `<leader>zq`
- Time tracking (`<leader>op*`) → Consolidated to `<leader>pt*`

______________________________________________________________________

## Which-Key Group Prefixes

Organized prefix groups shown by Which-Key plugin. These are NOT executable keybindings themselves, but rather organizational prefixes that show a submenu of related commands.

| Prefix       | Group Name                            | Description                       |
| ------------ | ------------------------------------- | --------------------------------- |
| `<leader>a`  | **(Group)** AI                        | AI commands and assistance        |
| `<leader>f`  | **(Group)** Find                      | File finding and search           |
| `<leader>g`  | **(Group)** Git                       | Git operations (simplified)       |
| `<leader>ip` | **(Group)** IWE Preview               | IWE publishing previews           |
| `<leader>l`  | **(Group)** Lynx                      | Lynx browser integration          |
| `<leader>m`  | **(Group)** MCP                       | MCP Hub operations                |
| `<leader>o`  | **(Group)** Org                       | Organization tools                |
| `<leader>p`  | **(Group)** Prose                     | Prose writing features (expanded) |
| `<leader>pt` | **(Sub-Group)** Prose Timer           | Time tracking for writing         |
| `<leader>t`  | **(Group)** Terminal                  | Terminal and translation          |
| `<leader>w`  | **(Group)** Window                    | Window management                 |
| `<leader>x`  | **(Group)** Diagnostics               | Code diagnostics and lists        |
| `<leader>z`  | **(Group)** Zettelkasten              | All knowledge management          |
| `<leader>zr` | **(Sub-Group)** Zettelkasten Refactor | Note refactoring                  |

**Removed Groups** (2025-10-21):

- `<leader>i` (IWE general) → Consolidated to `<leader>z*` and `<leader>ip*`
- `<leader>q` (Quick capture) → Consolidated to `<leader>zq`
- `<leader>op` (Time tracking) → Consolidated to `<leader>pt*`

______________________________________________________________________

## See Also

- **[Getting Started](../tutorials/GETTING_STARTED.md)**: First-time setup
- **[Zettelkasten Workflow](../how-to/ZETTELKASTEN_WORKFLOW.md)**: Daily/weekly knowledge management
- **[AI Usage Guide](../how-to/AI_USAGE_GUIDE.md)**: Ollama AI assistant setup
- **[Quick Reference](../../QUICK_REFERENCE.md)**: Essential commands overview
- **[PERCYBRAIN_DESIGN.md](../../PERCYBRAIN_DESIGN.md)**: System architecture

______________________________________________________________________

## Notes

- **Leader Key**: All `<leader>` references mean the space key (`<space>`)
- **Mode Abbreviations**: `n` = normal, `v` = visual, `i` = insert
- **Group Prefixes**: Entries marked **(Group)** are not executable keybindings, they show a submenu
- **Conflicts**: Some keymaps override others. Check the Conflicts section for details.
- **Plugin Dependencies**: Some keymaps require specific plugins to be loaded
- **Which-Key**: Press `<leader>W` to see available keybindings interactively
- **Scope**: This reference contains ONLY custom PercyBrain keybindings, not standard Vim commands

______________________________________________________________________

**Last Review**: 2025-10-22 **Major Refactor**: Writer-first keybinding consolidation (Phase 1 & 2 complete) + Telekasten → IWE migration **Total Custom Keybindings**: 138+ PercyBrain-specific keybindings **Breaking Changes**: See `claudedocs/KEYBINDING_MIGRATION_2025-10-21.md` and `claudedocs/TELEKASTEN_IWE_MIGRATION_STATUS.md` **Philosophy**: Speed of thought knowledge management for writers
