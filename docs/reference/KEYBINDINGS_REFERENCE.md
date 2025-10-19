# PercyBrain Keybindings Reference

**Category**: Reference (Information-Oriented) **Last Updated**: 2025-10-19

Complete reference of all keybindings in PercyBrain organized by workflow and functionality.

______________________________________________________________________

## Leader Key

PercyBrain uses **Space** (`<space>`) as the leader key.

- **Leader Key**: `<space>`
- **Local Leader**: `<space>` (same as leader)

All keybindings shown below use `<leader>` which represents the space key.

______________________________________________________________________

## Core Navigation & File Management

Essential keybindings for basic Neovim operations and file management.

| Keymap       | Mode | Command/Action    | Description                      |
| ------------ | ---- | ----------------- | -------------------------------- |
| `<leader>e`  | n    | `:NvimTreeToggle` | Toggle file explorer             |
| `<leader>x`  | n    | `:NvimTreeFocus`  | Focus file explorer              |
| `<leader>q`  | n    | `:q!`             | Quit without saving              |
| `<leader>s`  | n    | `:w!`             | Save file                        |
| `<leader>c`  | n    | `:close`          | Close current window             |
| `<leader>v`  | n    | `:vsplit`         | Vertical split                   |
| `<leader>W`  | n    | `:WhichKey`       | Show which-key help              |
| `<leader>a`  | n    | `:Alpha`          | Show Alpha dashboard             |
| `<leader>n`  | n    | Set numbers       | Enable line numbers & cursorline |
| `<leader>rn` | n    | Unset numbers     | Disable line numbers             |
| `<leader>nw` | n    | `:NewWriterFile`  | Create new writing file          |

______________________________________________________________________

## Zettelkasten Workflow

Core keybindings for the Zettelkasten knowledge management system. All Zettelkasten commands use the `z` prefix.

### Note Creation & Management

| Keymap       | Mode | Command                     | Description               | Plugin     |
| ------------ | ---- | --------------------------- | ------------------------- | ---------- |
| `<leader>zn` | n    | `:Telekasten new_note`      | Create new permanent note | Telekasten |
| `<leader>zd` | n    | `:Telekasten goto_today`    | Open today's daily note   | Telekasten |
| `<leader>zw` | n    | `:Telekasten goto_thisweek` | Open this week's note     | Telekasten |
| `<leader>zr` | n    | `:Telekasten rename_note`   | Rename current note       | Telekasten |

### Search & Navigation

| Keymap       | Mode | Command                      | Description                | Plugin     |
| ------------ | ---- | ---------------------------- | -------------------------- | ---------- |
| `<leader>zf` | n    | `:Telekasten find_notes`     | Fuzzy find notes           | Telekasten |
| `<leader>zg` | n    | `:Telekasten search_notes`   | Search note content (grep) | Telekasten |
| `<leader>zb` | n    | `:Telekasten show_backlinks` | Show notes linking here    | Telekasten |
| `<leader>zt` | n    | `:Telekasten show_tags`      | Browse all tags            | Telekasten |
| `<leader>z[` | n    | `:Telekasten goto_prev_note` | Go to previous note        | Telekasten |
| `<leader>z]` | n    | `:Telekasten goto_next_note` | Go to next note            | Telekasten |

### Linking & Organization

| Keymap       | Mode | Command                     | Description         | Plugin     |
| ------------ | ---- | --------------------------- | ------------------- | ---------- |
| `<leader>zl` | n    | `:Telekasten insert_link`   | Insert link to note | Telekasten |
| `<leader>zy` | n    | `:Telekasten yank_notelink` | Copy note link      | Telekasten |

### Visual Features

| Keymap       | Mode | Command                       | Description          | Plugin     |
| ------------ | ---- | ----------------------------- | -------------------- | ---------- |
| `<leader>zi` | n    | `:Telekasten insert_img_link` | Insert image link    | Telekasten |
| `<leader>zp` | n    | `:Telekasten preview_img`     | Preview image        | Telekasten |
| `<leader>zm` | n    | `:Telekasten browse_media`    | Browse media files   | Telekasten |
| `<leader>zc` | n    | `:Telekasten show_calendar`   | Show visual calendar | Telekasten |

### Formatting (SemBr)

Semantic line breaks for better diffs and version control.

| Keymap       | Mode | Command                 | Description                           | Plugin |
| ------------ | ---- | ----------------------- | ------------------------------------- | ------ |
| `<leader>zs` | n    | `:SemBrFormat`          | Format buffer with semantic breaks    | SemBr  |
| `<leader>zs` | v    | `:SemBrFormatSelection` | Format selection with semantic breaks | SemBr  |
| `<leader>zt` | n    | `:SemBrToggle`          | Toggle auto-format on save            | SemBr  |

**Note**: There's a keymap conflict - `<leader>zt` is used for both tags (Telekasten) and SemBr toggle. The SemBr toggle overwrites the tags command.

______________________________________________________________________

## AI Commands (Ollama Integration)

Local AI assistance for writing and knowledge management. All AI commands use the `a` prefix under leader.

### AI Command Menu

| Keymap       | Mode | Command    | Description          | Plugin |
| ------------ | ---- | ---------- | -------------------- | ------ |
| `<leader>aa` | n    | `:PercyAI` | Show AI command menu | Ollama |

### Individual AI Commands

| Keymap       | Mode | Command           | Description                    | Plugin |
| ------------ | ---- | ----------------- | ------------------------------ | ------ |
| `<leader>ae` | n, v | `:PercyExplain`   | AI: Explain text/selection     | Ollama |
| `<leader>as` | n, v | `:PercySummarize` | AI: Summarize note/selection   | Ollama |
| `<leader>al` | n    | `:PercyLinks`     | AI: Suggest related links      | Ollama |
| `<leader>aw` | n, v | `:PercyImprove`   | AI: Improve writing quality    | Ollama |
| `<leader>aq` | n    | `:PercyAsk`       | AI: Answer question about note | Ollama |
| `<leader>ax` | n    | `:PercyIdeas`     | AI: Generate ideas (eXplore)   | Ollama |

**Note**: `<leader>al` conflicts with ALE linting toggle from base keymaps. The AI suggest links command overwrites ALE toggle.

______________________________________________________________________

## Publishing & Hugo Integration

Static site generation and publishing workflow.

| Keymap       | Mode | Command        | Description                   | Plugin |
| ------------ | ---- | -------------- | ----------------------------- | ------ |
| `<leader>zp` | n    | `:HugoPublish` | Build, commit, and push site  | Hugo   |
| `<leader>zv` | n    | `:HugoServer`  | Start Hugo development server | Hugo   |
| `<leader>zb` | n    | `:HugoBuild`   | Build Hugo site               | Hugo   |

**Note**: `<leader>zp` is used for both preview image (Telekasten) and Hugo publish. Hugo command overwrites Telekasten preview.

**Note**: `<leader>zb` is used for both backlinks (Telekasten) and Hugo build. Hugo command overwrites Telekasten backlinks.

______________________________________________________________________

## Telescope Fuzzy Finder

Fast fuzzy finding for files, content, and metadata.

| Keymap       | Mode | Command                 | Description       |
| ------------ | ---- | ----------------------- | ----------------- |
| `<leader>ff` | n    | `:Telescope find_files` | Find files        |
| `<leader>fg` | n    | `:Telescope live_grep`  | Live grep content |
| `<leader>fb` | n    | `:Telescope buffers`    | List open buffers |
| `<leader>fk` | n    | `:Telescope keymaps`    | Search keymaps    |
| `<leader>fh` | n    | `:Telescope help_tags`  | Search help tags  |

### FzfLua Alternative

| Keymap        | Mode | Command             | Description       |
| ------------- | ---- | ------------------- | ----------------- |
| `<leader>fzl` | n    | `:FzfLua files`     | FzfLua find files |
| `<leader>fzg` | n    | `:FzfLua live_grep` | FzfLua grep       |
| `<leader>fzm` | n    | `:FzfLua marks`     | FzfLua marks      |

### Telescope Internal Keymaps (Insert Mode)

When inside a Telescope picker:

| Keymap  | Mode | Action                     |
| ------- | ---- | -------------------------- |
| `<C-j>` | i    | Move to next selection     |
| `<C-k>` | i    | Move to previous selection |

______________________________________________________________________

## Git Integration (Fugitive)

Comprehensive Git operations within Neovim.

### Status & Viewing

| Keymap       | Mode | Command       | Description             |
| ------------ | ---- | ------------- | ----------------------- |
| `<leader>gs` | n    | `:Git`        | Git status              |
| `<leader>gd` | n    | `:Gdiffsplit` | Git diff split          |
| `<leader>gb` | n    | `:Git blame`  | Git blame               |
| `<leader>gl` | n    | `:Gclog`      | Git log (quickfix)      |
| `<leader>gL` | n    | `:Glog`       | Git log (location list) |

### Commits

| Keymap       | Mode | Command               | Description      |
| ------------ | ---- | --------------------- | ---------------- |
| `<leader>gc` | n    | `:Git commit`         | Git commit       |
| `<leader>gC` | n    | `:Git commit --amend` | Git commit amend |

### Push/Pull/Fetch

| Keymap       | Mode | Command      | Description |
| ------------ | ---- | ------------ | ----------- |
| `<leader>gp` | n    | `:Git push`  | Git push    |
| `<leader>gP` | n    | `:Git pull`  | Git pull    |
| `<leader>gf` | n    | `:Git fetch` | Git fetch   |

### Stage/Unstage

| Keymap       | Mode | Command   | Description                  |
| ------------ | ---- | --------- | ---------------------------- |
| `<leader>ga` | n    | `:Gwrite` | Git add (stage) current file |
| `<leader>gr` | n    | `:Gread`  | Git checkout (reset) file    |

### Branches

| Keymap       | Mode | Command         | Description     |
| ------------ | ---- | --------------- | --------------- |
| `<leader>gB` | n    | `:Git branch`   | Git branch list |
| `<leader>go` | n    | `:Git checkout` | Git checkout    |

### Merge/Rebase

| Keymap       | Mode | Command       | Description |
| ------------ | ---- | ------------- | ----------- |
| `<leader>gm` | n    | `:Git merge`  | Git merge   |
| `<leader>gR` | n    | `:Git rebase` | Git rebase  |

### Browse

| Keymap       | Mode | Command    | Description                          |
| ------------ | ---- | ---------- | ------------------------------------ |
| `<leader>gO` | n, v | `:GBrowse` | Open file in browser (GitHub/GitLab) |

### LazyGit Integration

| Keymap      | Mode | Command    | Description      |
| ----------- | ---- | ---------- | ---------------- |
| `<leader>g` | n    | `:LazyGit` | Open LazyGit TUI |

**Note**: `<leader>g` conflicts with the Git fugitive prefix. LazyGit overwrites the fugitive keymaps.

______________________________________________________________________

## Writing & Distraction-Free Modes

Focus modes and writing-specific features.

| Keymap       | Mode | Command       | Description               |
| ------------ | ---- | ------------- | ------------------------- |
| `<leader>z`  | n    | `:ZenMode`    | Toggle Zen mode           |
| `<leader>o`  | n    | `:Goyo`       | Toggle Goyo focus mode    |
| `<leader>sp` | n    | `:SoftPencil` | Enable soft line wrapping |

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

## Plugin Management & Development

Lazy.nvim plugin manager and development tools.

| Keymap      | Mode | Command          | Description                 |
| ----------- | ---- | ---------------- | --------------------------- |
| `<leader>l` | n    | `:Lazy load all` | Load all lazy plugins       |
| `<leader>L` | n    | `:Lazy`          | Open Lazy plugin manager UI |

______________________________________________________________________

## Linting & Diagnostics

Code quality and error checking.

| Keymap       | Mode | Command      | Description        |
| ------------ | ---- | ------------ | ------------------ |
| `<leader>al` | n    | `:ALEToggle` | Toggle ALE linting |

**Note**: This conflicts with `<leader>al` for AI suggest links. The AI command overwrites this.

______________________________________________________________________

## Default Neovim Keybindings

Important default Vim/Neovim keybindings used in PercyBrain workflows.

### Motion & Navigation

| Keymap  | Mode | Description           |
| ------- | ---- | --------------------- |
| `h`     | n    | Move left             |
| `j`     | n    | Move down             |
| `k`     | n    | Move up               |
| `l`     | n    | Move right            |
| `w`     | n    | Word forward          |
| `b`     | n    | Word backward         |
| `gg`    | n    | Go to first line      |
| `G`     | n    | Go to last line       |
| `0`     | n    | Go to line start      |
| `$`     | n    | Go to line end        |
| `{`     | n    | Previous paragraph    |
| `}`     | n    | Next paragraph        |
| `<C-d>` | n    | Scroll half page down |
| `<C-u>` | n    | Scroll half page up   |

### Editing

| Keymap  | Mode | Description          |
| ------- | ---- | -------------------- |
| `i`     | n    | Insert before cursor |
| `a`     | n    | Insert after cursor  |
| `I`     | n    | Insert at line start |
| `A`     | n    | Insert at line end   |
| `o`     | n    | New line below       |
| `O`     | n    | New line above       |
| `x`     | n    | Delete character     |
| `dd`    | n    | Delete line          |
| `yy`    | n    | Yank (copy) line     |
| `p`     | n    | Paste after          |
| `P`     | n    | Paste before         |
| `u`     | n    | Undo                 |
| `<C-r>` | n    | Redo                 |

### Visual Mode

| Keymap  | Mode | Description             |
| ------- | ---- | ----------------------- |
| `v`     | n    | Enter visual mode       |
| `V`     | n    | Enter visual line mode  |
| `<C-v>` | n    | Enter visual block mode |

### Search

| Keymap | Mode | Description              |
| ------ | ---- | ------------------------ |
| `/`    | n    | Search forward           |
| `?`    | n    | Search backward          |
| `n`    | n    | Next search result       |
| `N`    | n    | Previous search result   |
| `*`    | n    | Search word under cursor |

______________________________________________________________________

## Keymap Conflicts & Resolutions

The following keymaps have conflicts where later definitions overwrite earlier ones:

### Major Conflicts

| Keymap       | Primary Command             | Conflicting Command       | Resolution   |
| ------------ | --------------------------- | ------------------------- | ------------ |
| `<leader>zt` | Show tags (Telekasten)      | SemBr toggle auto-format  | SemBr wins   |
| `<leader>al` | Toggle ALE linting          | AI suggest links (Ollama) | AI wins      |
| `<leader>zp` | Preview image (Telekasten)  | Hugo publish              | Hugo wins    |
| `<leader>zb` | Show backlinks (Telekasten) | Hugo build                | Hugo wins    |
| `<leader>g`  | LazyGit TUI                 | Git fugitive prefix       | LazyGit wins |

### Recommendations

1. **Zettelkasten users**: Use `:Telekasten show_tags` command directly for tags
2. **AI users**: Access AI suggest links via `<leader>aa` menu if needed
3. **Publishing**: Use Hugo commands, access Telekasten preview via command palette
4. **Git workflow**: Choose either LazyGit TUI (`<leader>g`) or Fugitive (`<leader>g*` commands)

______________________________________________________________________

## Which-Key Groups

Organized prefix groups shown by Which-Key plugin:

| Prefix      | Group Name         | Description                |
| ----------- | ------------------ | -------------------------- |
| `<leader>f` | Find/File          | File finding and search    |
| `<leader>t` | Translate/Terminal | Translation and terminal   |
| `<leader>w` | Window Management  | Window operations          |
| `<leader>z` | Zettelkasten       | Knowledge management       |
| `<leader>a` | AI/Assistant       | AI commands and assistance |
| `<leader>g` | Git                | Git operations             |

______________________________________________________________________

## Custom User Commands

User commands that complement keybindings:

### Zettelkasten Commands

| Command      | Description                           |
| ------------ | ------------------------------------- |
| `:QuickNote` | Create note with auto-focus (ZenMode) |

### AI Commands

| Command           | Description                |
| ----------------- | -------------------------- |
| `:PercyExplain`   | Explain text with AI       |
| `:PercySummarize` | Summarize note with AI     |
| `:PercyLinks`     | Suggest related links      |
| `:PercyImprove`   | Improve writing quality    |
| `:PercyAsk`       | Answer question about note |
| `:PercyIdeas`     | Generate new ideas         |
| `:PercyAI`        | Show AI command menu       |

### SemBr Commands

| Command                 | Description                           |
| ----------------------- | ------------------------------------- |
| `:SemBrFormat`          | Format buffer with semantic breaks    |
| `:SemBrFormatSelection` | Format selection with semantic breaks |
| `:SemBrToggle`          | Toggle auto-format on save            |

### Hugo Commands

| Command        | Description                   |
| -------------- | ----------------------------- |
| `:HugoNew`     | Create new Hugo post          |
| `:HugoServer`  | Start Hugo development server |
| `:HugoBuild`   | Build Hugo site               |
| `:HugoPublish` | Build, commit, and push       |

### Git Commands

| Command       | Description                            |
| ------------- | -------------------------------------- |
| `:Gac`        | Git add current file and commit        |
| `:Gacp`       | Git add current file, commit, and push |
| `:GSemBrDiff` | Show diff with semantic line breaks    |

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
- **Conflicts**: Some keymaps override others. Check the Conflicts section for details.
- **Plugin Dependencies**: Some keymaps require specific plugins to be loaded
- **Custom Commands**: Many keymaps have corresponding `:Command` versions
- **Which-Key**: Press `<leader>W` to see available keybindings interactively

______________________________________________________________________

**Last Review**: 2025-10-19 **Plugin Count**: 68 plugins across 14 workflows **Total Keybindings**: 100+ custom keybindings
