# PercyBrain Plugin Reference

**Category**: Reference (Information-Oriented) **Last Updated**: 2025-10-19

Complete catalog of all 67 plugins in PercyBrain organized by workflow category and purpose.

**2025-10-22 Update**: Telekasten removed, IWE-only implementation with custom Telescope-based calendar/tags and LSP-based link navigation.

______________________________________________________________________

## Overview

PercyBrain uses **lazy.nvim** for plugin management with a carefully curated selection of 67 plugins organized into 15 workflow categories. Each plugin is lazy-loaded where appropriate to maintain fast startup times while providing comprehensive functionality for knowledge management, writing, and development.

### Plugin Architecture

```
lua/plugins/
├── init.lua                 # Plugin loader with explicit imports
├── zettelkasten/            # 4 plugins - Core knowledge management (IWE-only)
├── ai-sembr/                # 3 plugins - AI and semantic formatting
├── prose-writing/           # 11 plugins - Writing tools (4 subcategories)
│   ├── editing/             # 5 plugins
│   ├── grammar/             # 3 plugins
│   ├── formatting/          # 2 plugins
│   └── distraction-free/    # 1 plugin
├── academic/                # 4 plugins - LaTeX and academic writing
├── publishing/              # 3 plugins - Export and publishing
├── org-mode/                # 3 plugins - Org-mode support
├── lsp/                     # 4 plugins - Language servers
├── completion/              # 1 plugin - Autocompletion
├── ui/                      # 9 plugins - Themes and interface
├── navigation/              # 3 plugins - File navigation
├── utilities/               # 14 plugins - Git, sessions, tools
├── treesitter/              # 1 plugin - Syntax highlighting
├── lisp/                    # 2 plugins - Common Lisp support
├── experimental/            # 3 plugins - Experimental features
└── diagnostics/             # 1 plugin - Error aggregation
```

### Plugin Loading Strategy

PercyBrain uses **explicit imports** in `lua/plugins/init.lua` to ensure all plugins are loaded:

```lua
return {
  { import = "plugins.zettelkasten" },
  { import = "plugins.ai-sembr" },
  { import = "plugins.prose-writing.distraction-free" },
  { import = "plugins.prose-writing.editing" },
  { import = "plugins.prose-writing.formatting" },
  { import = "plugins.prose-writing.grammar" },
  -- ... all 18 imports (15 categories + 3 prose-writing subcategories)
}
```

**Critical**: Without these explicit imports, lazy.nvim stops auto-scanning and only loads the plugins defined directly in `init.lua`, resulting in a blank screen.

### Lazy Loading Triggers

Plugins are loaded based on:

- **`event`**: Load on Vim events (VeryLazy, InsertEnter, BufReadPre)
- **`ft`**: Load for specific file types (markdown, org, tex)
- **`cmd`**: Load when command is executed
- **`keys`**: Load when keybinding is pressed
- **`lazy = false`**: Load immediately on startup (core plugins)

______________________________________________________________________

## Core Workflows

### 1. Zettelkasten (4 plugins)

The primary knowledge management workflow using IWE LSP with custom Telescope integrations.

| Plugin                | Repository                      | Purpose                                                                               | Key Commands                                      | Status       |
| --------------------- | ------------------------------- | ------------------------------------------------------------------------------------- | ------------------------------------------------- | ------------ |
| **Telescope**         | `nvim-telescope/telescope.nvim` | Fuzzy finder for notes, files, buffers. Powers custom calendar/tag pickers            | `<leader>f/ff/fg/fb/fh/fk`                        | Core, loaded |
| **IWE LSP**           | `iwe-org/iwe`                   | Intelligent Writing Environment LSP. Markdown intelligence, link navigation/insertion | `<leader>zl/zk` (links), configured via lspconfig | ft:markdown  |
| **Img-Clip**          | `HakonHarnes/img-clip.nvim`     | Clipboard image pasting with auto-naming and path management                          | `:PasteImage`, `<leader>pP`                       | Core, loaded |
| **SemBr Integration** | Local plugin                    | Semantic line breaks for better diffs. Extends fugitive/gitsigns                      | `<leader>zs` (format), `<leader>zt` (toggle)      | Core, loaded |

**Dependencies**: plenary.nvim (required by Telescope)

**Configuration**:

- IWE LSP: `lua/plugins/lsp/iwe.lua` (LSP + CLI configuration)
- Zettelkasten module: `lua/config/zettelkasten.lua` (custom calendar/tag/link implementations)
- SemBr: Requires external `sembr` binary (`uv tool install sembr`)

**Custom Implementations** (2025-10-22 migration):

- **Calendar Picker** (`show_calendar()`): Telescope-based date picker with -30/+30 day range, preview, TODAY marker
- **Tag Browser** (`show_tags()`): Ripgrep-based tag extraction with frequency counts and Telescope display
- **Link Navigation** (`follow_link()`): LSP-based definition jumps via `vim.lsp.buf.definition()`
- **Link Insertion** (`insert_link()`): LSP code actions filtered for link insertion

**Integration**: Works with AI-SemBr workflow for enhanced note management.

______________________________________________________________________

### 2. AI & SemBr (3 plugins)

Local AI assistance using Ollama for privacy-preserving knowledge work.

| Plugin       | Repository        | Purpose                                                                              | Key Commands             | Status       |
| ------------ | ----------------- | ------------------------------------------------------------------------------------ | ------------------------ | ------------ |
| **Ollama**   | Local integration | Local LLM integration (llama3.2) for AI-assisted writing, summarization, explanation | `<leader>aa/ae/as/al/aw` | Core, loaded |
| **AI Draft** | Local integration | Collect workspace notes and generate comprehensive drafts                            | `<leader>ad`             | Core, loaded |
| **SemBr**    | Local integration | Semantic line break formatting for better version control                            | `<leader>zs/zt`          | Core, loaded |

**Dependencies**:

- External: Ollama (`ollama pull llama3.2`)
- External: SemBr binary (`uv tool install sembr`)
- Internal: Telescope (for note collection in AI Draft)

**Configuration**: `lua/plugins/ai-sembr/`

**Use Cases**:

- **Explain**: Clarify complex sections (`<leader>ae`)
- **Summarize**: Generate note summaries (`<leader>as`)
- **Draft**: Create comprehensive documents from workspace notes (`<leader>ad`)
- **Format**: Apply semantic line breaks for cleaner git diffs (`<leader>zs`)

______________________________________________________________________

### 3. Prose Writing (11 plugins)

Professional writing tools organized into 4 subcategories.

#### 3.1 Editing Tools (5 plugins)

| Plugin                   | Repository                       | Purpose                                                    | Key Commands                      | Status         |
| ------------------------ | -------------------------------- | ---------------------------------------------------------- | --------------------------------- | -------------- |
| **Vim-Pencil**           | `reedes/vim-pencil`              | Prose-optimized editing: soft wrapping, proper line breaks | Auto-configured for markdown/text | Core, loaded   |
| **Nvim-Surround**        | `kylechui/nvim-surround`         | Manipulate surrounding quotes, brackets, tags              | `ys/cs/ds` motions                | event:VeryLazy |
| **Vim-Repeat**           | `tpope/vim-repeat`               | Repeat plugin commands with `.`                            | Enables `.` for surround, etc     | event:VeryLazy |
| **Vim-Textobj-Sentence** | `preservim/vim-textobj-sentence` | Sentence text objects for prose navigation                 | `as/is` text objects              | Core, loaded   |
| **Undotree**             | `mbbill/undotree`                | Visual undo history tree for tracking document evolution   | `:UndotreeToggle`, `<leader>u`    | Core, loaded   |

**Dependencies**: Vim-Textobj-Sentence requires `kana/vim-textobj-user`

#### 3.2 Grammar & Language (3 plugins)

| Plugin        | Repository                  | Purpose                                                                 | Key Commands             | Status       |
| ------------- | --------------------------- | ----------------------------------------------------------------------- | ------------------------ | ------------ |
| **ltex-ls**   | Installed via Mason         | LanguageTool Language Server for grammar/style checking (20+ languages) | Configured via LSP       | Core, loaded |
| **Vale**      | `dense-analysis/ale`        | Prose linting with style guides (write-good, proselint)                 | Runs via ALE             | Core, loaded |
| **Thesaurus** | `ron89/thesaurus_query.vim` | Synonym lookup for word choice enhancement                              | `:ThesaurusQueryReplace` | Core, loaded |

**External Dependencies**:

- ltex-ls: Installed via Mason LSP
- Vale: Requires Vale CLI (`mise install vale`)

**Configuration**: ltex-ls configured in `lua/plugins/prose-writing/grammar/ltex-ls.lua` with Mason integration.

#### 3.3 Formatting (2 plugins)

| Plugin           | Repository              | Purpose                                          | Key Commands                | Status            |
| ---------------- | ----------------------- | ------------------------------------------------ | --------------------------- | ----------------- |
| **Autopairs**    | `windwp/nvim-autopairs` | Auto-close quotes, brackets, markdown formatting | Automatic in insert mode    | event:InsertEnter |
| **Comment.nvim** | `numToStr/Comment.nvim` | Smart commenting for multiple file types         | `gcc` (line), `gc` (motion) | Core, loaded      |

#### 3.4 Distraction-Free (1 plugin)

| Plugin       | Repository            | Purpose                                                        | Key Commands | Status       |
| ------------ | --------------------- | -------------------------------------------------------------- | ------------ | ------------ |
| **Zen Mode** | `folke/zen-mode.nvim` | ADHD-optimized focus mode: centers text, hides UI distractions | `:ZenMode`   | Core, loaded |

**Integration**: Telekasten's `:QuickNote` automatically activates Zen Mode for focused writing.

______________________________________________________________________

### 4. Academic Writing (4 plugins)

Comprehensive LaTeX and academic publishing support.

| Plugin                | Repository                      | Purpose                                                            | Key Commands                    | Status       |
| --------------------- | ------------------------------- | ------------------------------------------------------------------ | ------------------------------- | ------------ |
| **VimTeX**            | `lervag/vimtex`                 | Comprehensive LaTeX support: compilation, viewing, syntax, folding | `:VimtexCompile`, `:VimtexView` | Core, loaded |
| **Vim-Pandoc**        | `vim-pandoc/vim-pandoc`         | Pandoc integration for document conversion (markdown → LaTeX/PDF)  | `:Pandoc` commands              | Core, loaded |
| **Vim-LaTeX-Preview** | `xuhdev/vim-latex-live-preview` | Live LaTeX preview in PDF viewer                                   | `:LLPStartPreview`              | Core, loaded |
| **Cmp-Dictionary**    | `uga-rosa/cmp-dictionary`       | Dictionary completion for academic vocabulary                      | Integrates with nvim-cmp        | Core, loaded |

**Dependencies**:

- External: LaTeX distribution (texlive, mactex)
- External: Pandoc (`mise install pandoc`)
- Internal: vim-pandoc-syntax (required by vim-pandoc)

**Configuration**: VimTeX configured in `lua/plugins/academic/vimtex.lua` with PDF viewer settings.

______________________________________________________________________

### 5. Publishing (3 plugins)

Export notes to various formats and publish to web.

| Plugin               | Repository                     | Purpose                                                 | Key Commands                            | Status       |
| -------------------- | ------------------------------ | ------------------------------------------------------- | --------------------------------------- | ------------ |
| **Markdown-Preview** | `iamcco/markdown-preview.nvim` | Live markdown preview in browser with scroll sync       | `:MarkdownPreview`                      | ft:markdown  |
| **Auto-Pandoc**      | `jghauser/auto-pandoc.nvim`    | Automatic pandoc conversion on save                     | Auto-configured                         | ft:markdown  |
| **Hugo**             | Local integration              | Hugo static site generation for publishing Zettelkasten | `<leader>zp/zv/zb` (publish/view/build) | Core, loaded |

**Dependencies**:

- External: Hugo static site generator (`mise install hugo`)
- External: Pandoc
- Internal: plenary.nvim (auto-pandoc), jsonpath.nvim (hugo)

**Use Cases**:

- Preview markdown locally (markdown-preview)
- Auto-convert markdown to other formats on save (auto-pandoc)
- Publish Zettelkasten as static website (hugo)

______________________________________________________________________

### 6. Org-Mode (3 plugins)

Emacs Org-mode compatibility for users transitioning from Spacemacs/Doom Emacs.

| Plugin           | Repository                     | Purpose                                                           | Key Commands        | Status         |
| ---------------- | ------------------------------ | ----------------------------------------------------------------- | ------------------- | -------------- |
| **Nvim-Orgmode** | `nvim-orgmode/orgmode`         | Full org-mode implementation: TODOs, agenda, captures, timestamps | `:Orgmode` commands | event:VeryLazy |
| **Org-Bullets**  | `akinsho/org-bullets.nvim`     | Replace org-mode `*` with prettier Unicode bullets                | Auto-configured     | Core, loaded   |
| **Headlines**    | `lukas-reineke/headlines.nvim` | Visual heading backgrounds for org-mode and markdown              | Auto-configured     | Core, loaded   |

**Dependencies**: nvim-treesitter (required by nvim-orgmode)

**Configuration**: Configured in `lua/plugins/org-mode/nvimorgmode.lua` with custom treesitter grammar.

**Note**: Org-mode is optional. PercyBrain primarily uses markdown + Telekasten, but org-mode is available for compatibility.

______________________________________________________________________

### 7. LSP (4 plugins)

Language Server Protocol integration for intelligent editing.

| Plugin              | Repository                          | Purpose                                                           | Key Commands        | Status           |
| ------------------- | ----------------------------------- | ----------------------------------------------------------------- | ------------------- | ---------------- |
| **Nvim-Lspconfig**  | `neovim/nvim-lspconfig`             | Official LSP configurations (markdown-oxide, lua_ls, bashls, etc) | `<leader>ca/rn/d/D` | Core, loaded     |
| **Mason**           | `williamboman/mason.nvim`           | LSP/DAP/linter installer with UI                                  | `:Mason`            | Core, loaded     |
| **Mason-Lspconfig** | `williamboman/mason-lspconfig.nvim` | Bridges Mason and nvim-lspconfig for auto-setup                   | Auto-configured     | event:BufReadPre |
| **None-ls**         | `nvimtools/none-ls.nvim`            | Use Neovim as LSP for formatters/linters (disabled by default)    | Configured but lazy | lazy             |

**Dependencies**:

- Internal: cmp-nvim-lsp (LSP source for completion)
- Internal: nvim-lsp-file-operations (file operation support)
- Mason plugins: mason-lspconfig, mason-tool-installer

**Configured LSPs**:

- **markdown-oxide** (IWE LSP): Zettelkasten intelligence
- **lua_ls**: Neovim configuration
- **bashls**: Shell scripting
- **ltex**: Grammar/style checking

**Configuration**: `lua/plugins/lsp/lspconfig.lua` with keybindings and server-specific settings.

______________________________________________________________________

### 8. Completion (1 plugin)

| Plugin       | Repository         | Purpose                                                       | Key Commands                                | Status            |
| ------------ | ------------------ | ------------------------------------------------------------- | ------------------------------------------- | ----------------- |
| **Nvim-Cmp** | `hrsh7th/nvim-cmp` | Autocompletion engine with LSP, buffer, path, snippet sources | `<C-n>/<C-p>` (navigate), `<C-y>` (confirm) | event:InsertEnter |

**Dependencies**:

- **cmp-buffer**: Buffer word completion
- **cmp-path**: File path completion
- **LuaSnip**: Snippet engine
- **cmp_luasnip**: Snippet completion source
- **friendly-snippets**: Pre-configured snippets
- **lspkind.nvim**: VSCode-like icons

**Configuration**: `lua/plugins/completion/nvim-cmp.lua` with custom mappings and sources.

______________________________________________________________________

### 9. UI & Themes (9 plugins)

Visual customization and interface enhancements.

| Plugin                | Repository                     | Purpose                                                                | Key Commands              | Status          |
| --------------------- | ------------------------------ | ---------------------------------------------------------------------- | ------------------------- | --------------- |
| **PercyBrain-Theme**  | `folke/tokyonight.nvim` (base) | Custom Blood Moon theme: deep blood red/black background, gold accents | `:colorscheme percybrain` | Core, loaded    |
| **Catppuccin**        | `catppuccin/nvim`              | Catppuccin theme (alternative)                                         | `:colorscheme catppuccin` | Core, loaded    |
| **Gruvbox**           | `ellisonleao/gruvbox.nvim`     | Gruvbox theme (alternative)                                            | `:colorscheme gruvbox`    | Core, loaded    |
| **Nightfox**          | `EdenEast/nightfox.nvim`       | Nightfox theme (disabled, using PercyBrain)                            | `:colorscheme nightfox`   | lazy (disabled) |
| **Transparent**       | `xiyaowong/transparent.nvim`   | Transparent background for terminal aesthetics                         | `:TransparentToggle`      | Core, loaded    |
| **Alpha**             | `goolord/alpha-nvim`           | Startup dashboard with PercyBrain ASCII logo and Blood Moon aesthetic  | `:Alpha`                  | event:VimEnter  |
| **Which-Key**         | `folke/which-key.nvim`         | Popup showing available keybindings (ADHD helpful)                     | `<leader>` (show menu)    | event:VeryLazy  |
| **Noice**             | `folke/noice.nvim`             | Modern UI for messages, cmdline, popups with Treesitter markdown       | Auto-configured           | event:VeryLazy  |
| **Nvim-Web-Devicons** | `nvim-tree/nvim-web-devicons`  | File icons for file explorers and UI elements                          | Auto-configured           | Core, loaded    |

**Dependencies**:

- **Noice**: Requires nui.nvim, nvim-notify
- All themes: Independent (can switch between them)

**Configuration**:

- PercyBrain theme: `lua/plugins/ui/percybrain-theme.lua` (custom colors)
- Which-Key: `lua/plugins/ui/whichkey.lua` (group labels)
- Alpha: `lua/plugins/ui/alpha.lua` (custom dashboard)

**Active Theme**: PercyBrain Blood Moon (deep red/black with gold accents)

______________________________________________________________________

### 10. Navigation (3 plugins)

File system and buffer navigation tools.

| Plugin        | Repository                | Purpose                                                | Key Commands                   | Status       |
| ------------- | ------------------------- | ------------------------------------------------------ | ------------------------------ | ------------ |
| **Nvim-Tree** | `nvim-tree/nvim-tree.lua` | File explorer tree with git integration                | `:NvimTreeToggle`, `<leader>e` | Core, loaded |
| **Yazi**      | `mikavilpas/yazi.nvim`    | Terminal file manager integration (modern alternative) | `:Yazi`                        | Core, loaded |
| **Neoscroll** | `karb94/neoscroll.nvim`   | Smooth scrolling animations                            | Auto-configured                | Core, loaded |

**Configuration**: Nvim-Tree configured in `lua/plugins/navigation/nvim-tree.lua`

**Choice**: Use either Nvim-Tree (GUI-like) or Yazi (terminal-based) based on preference.

______________________________________________________________________

### 11. Utilities (14 plugins)

Essential development and productivity tools.

#### Git & Version Control (4 plugins)

| Plugin       | Repository                | Purpose                                                                   | Key Commands                               | Status       |
| ------------ | ------------------------- | ------------------------------------------------------------------------- | ------------------------------------------ | ------------ |
| **Fugitive** | `tpope/vim-fugitive`      | Industry-standard Git plugin (10+ years): :Git, :Gstatus, :Gdiff, :Gblame | `<leader>gs/gd/gb/gl/gL`                   | Core, loaded |
| **Gitsigns** | `lewis6991/gitsigns.nvim` | Visual Git indicators: sign column changes, inline blame, hunk actions    | `<leader>hs/hr/hS/hR/hu` (hunk operations) | Core, loaded |
| **Diffview** | `sindrets/diffview.nvim`  | Advanced diff viewer: side-by-side diffs, merge tool, file history        | `<leader>gdo/gdc/gdh/gdH/gdt`              | Core, loaded |
| **Lazygit**  | `kdheepak/lazygit.nvim`   | Terminal UI for Git (alternative to fugitive)                             | `:LazyGit`                                 | Core, loaded |

**Dependencies**: plenary.nvim (gitsigns, diffview)

**Integration**: SemBr integration extends fugitive/gitsigns with semantic line break diffs.

#### Session & State (2 plugins)

| Plugin           | Repository               | Purpose                                                                        | Key Commands          | Status       |
| ---------------- | ------------------------ | ------------------------------------------------------------------------------ | --------------------- | ------------ |
| **Auto-Session** | `rmagatti/auto-session`  | ADHD protection: auto-save/restore sessions, resume exactly where you left off | `<leader>ss/sr/sd/sf` | Core, loaded |
| **Auto-Save**    | `pocco81/auto-save.nvim` | Hyperfocus protection: auto-save on text change/leave insert mode              | `<leader>as` (toggle) | Core, loaded |

**ADHD Features**: Prevent context loss during hyperfocus or interruptions.

#### Productivity (5 plugins)

| Plugin         | Repository                | Purpose                            | Key Commands                     | Status       |
| -------------- | ------------------------- | ---------------------------------- | -------------------------------- | ------------ |
| **Toggleterm** | `akinsho/toggleterm.nvim` | Toggle floating/split terminals    | `:ToggleTerm`                    | Core, loaded |
| **Floaterm**   | `voldikss/vim-floaterm`   | Alternative floating terminal      | `:FloatermToggle`                | Core, loaded |
| **Pomo**       | `epwalsh/pomo.nvim`       | Pomodoro timer with notifications  | `:TimerStart`, `:TimerStop`      | lazy         |
| **Translate**  | `uga-rosa/translate.nvim` | Multi-language translation support | `:Translate`                     | Core, loaded |
| **High-Str**   | `Pocco81/HighStr.nvim`    | Text highlighting for note-taking  | `:HSHighlight`, `:HSRmHighlight` | Core, loaded |

**Dependencies**: Pomo requires nvim-notify

#### Development Tools (3 plugins)

| Plugin              | Repository                  | Purpose                                                                  | Key Commands    | Status       |
| ------------------- | --------------------------- | ------------------------------------------------------------------------ | --------------- | ------------ |
| **Hardtime**        | `m4xshen/hardtime.nvim`     | Vim motion training: discourages hjkl spam, encourages efficient motions | Auto-configured | Core, loaded |
| **Screenkey**       | `NStefan002/screenkey.nvim` | Display pressed keys on screen (for demos/teaching)                      | `:Screenkey`    | Core, loaded |
| **MCP Marketplace** | `ravitemer/mcphub.nvim`     | Browse and manage Model Context Protocol servers                         | `<leader>mm/ml` | lazy         |

**Dependencies**:

- Hardtime: nui.nvim, plenary.nvim
- MCP Marketplace: plenary.nvim, telescope.nvim

______________________________________________________________________

### 12. Treesitter (1 plugin)

| Plugin              | Repository                        | Purpose                                                                 | Key Commands              | Status       |
| ------------------- | --------------------------------- | ----------------------------------------------------------------------- | ------------------------- | ------------ |
| **Nvim-Treesitter** | `nvim-treesitter/nvim-treesitter` | Syntax highlighting, code folding, text objects via tree-sitter parsers | `:TSUpdate`, `:TSInstall` | Core, loaded |

**Installed Parsers**: markdown, markdown_inline, lua, vim, vimdoc, bash, python, javascript, typescript, rust, go, etc.

**Configuration**: `lua/plugins/treesitter/nvim-treesitter.lua` with auto-install and highlighting.

**Integration**: Required by nvim-orgmode, noice, styledoc.

______________________________________________________________________

### 13. Lisp (2 plugins)

Common Lisp development support (experimental/legacy).

| Plugin             | Repository               | Purpose                               | Key Commands | Status       |
| ------------------ | ------------------------ | ------------------------------------- | ------------ | ------------ |
| **Quicklisp.nvim** | `HiPhish/quicklisp.nvim` | Quicklisp package manager integration | `:Quicklisp` | Core, loaded |
| **CL-Neovim**      | `adolenc/cl-neovim`      | Common Lisp REPL integration          | `:CLRepl`    | Core, loaded |

**Note**: Lisp support is legacy/experimental. PercyBrain focuses on knowledge management, not Lisp development.

______________________________________________________________________

### 14. Experimental (3 plugins)

Experimental features and plugins under evaluation.

| Plugin        | Repository               | Purpose                                                                          | Key Commands             | Status       |
| ------------- | ------------------------ | -------------------------------------------------------------------------------- | ------------------------ | ------------ |
| **Pendulum**  | `ptdewey/pendulum-nvim`  | Time tracking and task management for productivity analysis                      | `<leader>ts/te/tt/tr`    | Core, loaded |
| **Lynx-Wiki** | `mjbrownie/browser.vim`  | Lynx browser integration: export webpages to markdown, generate BibTeX citations | `<leader>lo/le/lc/ls/lx` | Core, loaded |
| **StyledDoc** | `denstiny/styledoc.nvim` | Markdown styling with image rendering support                                    | `<leader>md`             | ft:markdown  |

**Dependencies**:

- **Lynx-Wiki**: jgm/pandoc (external Pandoc binary)
- **StyledDoc**: nvim-treesitter, luarocks.nvim, 3rd/image.nvim

**Evaluation Status**: These plugins are being tested for integration into core workflows.

______________________________________________________________________

### 15. Diagnostics (1 plugin)

| Plugin      | Repository           | Purpose                                                                                   | Key Commands             | Status       |
| ----------- | -------------------- | ----------------------------------------------------------------------------------------- | ------------------------ | ------------ |
| **Trouble** | `folke/trouble.nvim` | Unified error/diagnostic aggregation: ONE place for ALL errors (LSP, quickfix, locations) | `<leader>xx/xw/xd/xq/xl` | Core, loaded |

**Dependencies**: nvim-web-devicons

**ADHD Feature**: Consolidates errors from multiple sources into single interface, preventing context switching.

**Configuration**: `lua/plugins/diagnostics/trouble.lua` with custom keybindings.

______________________________________________________________________

## Plugin Management

### Adding New Plugins

1. **Create plugin spec file** in appropriate workflow category:

   ```lua
   -- lua/plugins/category/plugin-name.lua
   return {
     "author/repo",
     lazy = true,
     event = "VeryLazy",  -- or cmd/keys/ft
     config = function()
       -- Plugin configuration
     end,
   }
   ```

2. **Update init.lua** if creating new category (add `{ import = "plugins.new-category" }`)

3. **Sync plugins**: `:Lazy sync`

4. **Check health**: `:checkhealth lazy`

### Removing Plugins

1. **Delete plugin spec file** from `lua/plugins/category/`

2. **Remove import** from `init.lua` if removing entire category

3. **Clean plugins**: `:Lazy clean`

4. **Restart Neovim**

### Updating Plugins

- **Update all**: `:Lazy sync`
- **Update specific**: `:Lazy update <plugin-name>`
- **Check updates**: `:Lazy check`
- **View changes**: `:Lazy log`

### Plugin Health Checks

```vim
:checkhealth                " Check all plugins
:checkhealth lazy           " Check lazy.nvim
:checkhealth telescope      " Check specific plugin
:Lazy health                " Lazy.nvim plugin health UI
```

______________________________________________________________________

## Plugin Interactions & Dependencies

### Core Dependencies

These plugins are required by multiple other plugins:

| Dependency            | Required By                                                                                                                  | Purpose                         |
| --------------------- | ---------------------------------------------------------------------------------------------------------------------------- | ------------------------------- |
| **plenary.nvim**      | Telescope, Telekasten, gitsigns, diffview, auto-pandoc, lazygit, hardtime, mcp-marketplace, ai-draft, sembr, ollama, iwe-lsp | Lua utility functions           |
| **nvim-treesitter**   | Noice, nvim-orgmode, styledoc                                                                                                | Syntax parsing and highlighting |
| **nvim-web-devicons** | Nvim-tree, trouble, diffview, alpha                                                                                          | File and UI icons               |
| **nui.nvim**          | Noice, hardtime                                                                                                              | UI components library           |
| **nvim-notify**       | Noice, pomo                                                                                                                  | Notification system             |

### Workflow Integrations

#### Zettelkasten → AI Workflow

- **Telekasten** creates/manages notes
- **Ollama** provides AI assistance on note content
- **AI Draft** collects notes via Telescope for document generation
- **SemBr** formats notes for better version control

#### Writing → Publishing Workflow

- **Telekasten** writes markdown notes
- **Vim-Pencil** optimizes prose editing
- **ltex-ls** checks grammar
- **Auto-Pandoc** converts to other formats on save
- **Hugo** publishes as static website

#### LSP → Completion Workflow

- **Nvim-Lspconfig** provides language intelligence
- **Mason** installs LSP servers
- **Nvim-Cmp** uses LSP as completion source
- **IWE LSP** provides markdown-specific intelligence

#### Git Workflow

- **Fugitive** for Git operations
- **Gitsigns** for visual indicators
- **Diffview** for advanced diffs
- **SemBr** for semantic line break diffs

______________________________________________________________________

## Troubleshooting

### Blank Screen on Startup

**Symptom**: Neovim starts but no plugins load (only 3 plugins show in `:Lazy`)

**Cause**: Missing explicit imports in `lua/plugins/init.lua`

**Solution**: Verify all 18 imports are present (15 categories + 3 prose-writing subcategories):

```bash
nvim --headless -c "lua print(#require('lazy').plugins())" -c "qall"
# Should show 80+ plugins, not 3
```

### Plugin Not Loading

**Check loading trigger**:

```vim
:Lazy load <plugin-name>  " Manually load
:Lazy log <plugin-name>   " View error logs
```

**Common issues**:

- **ft**: File type not detected → check `:set ft?`
- **event**: Event not firing → check `:autocmd` for events
- **cmd**: Command typo → verify command exists in plugin
- **keys**: Keybinding conflict → check with `:verbose map <leader>...`

### External Dependencies Missing

Many plugins require external tools:

| Tool        | Required By          | Install Method                                |
| ----------- | -------------------- | --------------------------------------------- |
| **Ollama**  | AI-SemBr             | `mise install ollama && ollama pull llama3.2` |
| **SemBr**   | SemBr                | `uv tool install sembr`                       |
| **IWE**     | Zettelkasten         | `cargo install iwe`                           |
| **Hugo**    | Publishing           | `mise install hugo`                           |
| **Pandoc**  | Academic, Publishing | `mise install pandoc`                         |
| **LaTeX**   | Academic             | `mise install texlive` or distro package      |
| **Vale**    | Grammar              | `mise install vale`                           |
| **ripgrep** | Telescope            | `mise install ripgrep`                        |

**Check installed tools**: `mise list`

### LSP Not Working

1. **Check LSP is running**: `:LspInfo`
2. **Install missing servers**: `:Mason`
3. **Check LSP logs**: `:LspLog`
4. **Restart LSP**: `:LspRestart`

**IWE LSP specific**:

```bash
cargo install iwe  # Install IWE LSP
nvim --version     # Ensure Neovim >= 0.8.0
```

### Performance Issues

**Too many plugins loading on startup**:

1. Check which plugins aren't lazy-loaded: `:Lazy profile`
2. Add lazy-loading triggers (event/cmd/keys/ft) to heavy plugins
3. Use `lazy = true` for non-essential plugins

**Slow startup time**:

```vim
:Lazy profile    " Show plugin load times
```

**Reduce startup plugins**:

- Move more plugins to `lazy = true`
- Use `event = "VeryLazy"` instead of immediate loading
- Defer UI plugins to `event = "VimEnter"`

______________________________________________________________________

## Plugin Categories Summary

| Category          | Count  | Primary Purpose                                       | Core Plugins                       |
| ----------------- | ------ | ----------------------------------------------------- | ---------------------------------- |
| **Zettelkasten**  | 5      | Knowledge management foundation                       | Telekasten, Telescope, IWE LSP     |
| **AI-SemBr**      | 3      | Local AI assistance and formatting                    | Ollama, AI Draft, SemBr            |
| **Prose-Writing** | 11     | Professional writing tools                            | Vim-Pencil, ltex-ls, Zen Mode      |
| **Academic**      | 4      | LaTeX and academic publishing                         | VimTeX, Vim-Pandoc                 |
| **Publishing**    | 3      | Export and web publishing                             | Hugo, Markdown-Preview             |
| **Org-Mode**      | 3      | Emacs org-mode compatibility                          | Nvim-Orgmode                       |
| **LSP**           | 4      | Language server intelligence                          | Lspconfig, Mason, IWE LSP          |
| **Completion**    | 1      | Autocompletion                                        | Nvim-Cmp                           |
| **UI**            | 9      | Themes and interface                                  | PercyBrain-Theme, Which-Key, Alpha |
| **Navigation**    | 3      | File system navigation                                | Nvim-Tree, Yazi                    |
| **Utilities**     | 14     | Development and productivity                          | Fugitive, Gitsigns, Auto-Session   |
| **Treesitter**    | 1      | Syntax highlighting                                   | Nvim-Treesitter                    |
| **Lisp**          | 2      | Common Lisp support                                   | Quicklisp, CL-Neovim               |
| **Experimental**  | 3      | Experimental features                                 | Pendulum, Lynx-Wiki, StyledDoc     |
| **Diagnostics**   | 1      | Error aggregation                                     | Trouble                            |
| **Total**         | **67** | Complete knowledge management environment (IWE-based) | 15 categories                      |

______________________________________________________________________

## Related Documentation

- **Installation**: See `PERCYBRAIN_SETUP.md` for complete setup guide
- **Workflows**: See `docs/how-to/ZETTELKASTEN_WORKFLOW.md` for daily usage patterns
- **AI Usage**: See `docs/how-to/AI_USAGE_GUIDE.md` for Ollama integration
- **Keybindings**: See `docs/reference/KEYBINDINGS_REFERENCE.md` for complete keymap reference
- **LSP Reference**: See `docs/reference/LSP_REFERENCE.md` for language server details
- **Architecture**: See `PERCYBRAIN_DESIGN.md` for technical architecture
- **Testing**: See `docs/testing/TESTING_GUIDE.md` for plugin validation

______________________________________________________________________

## Plugin Homepage Links

For detailed documentation, visit the official plugin repositories:

### Zettelkasten

- Telescope: <https://github.com/nvim-telescope/telescope.nvim>
- IWE LSP: <https://github.com/iwe-org/iwe> (CLI + LSP server)
- Img-Clip: <https://github.com/HakonHarnes/img-clip.nvim>

### AI & Writing

- Ollama: <https://ollama.ai/>
- SemBr: <https://github.com/sembr-org/sembr>
- Vim-Pencil: <https://github.com/reedes/vim-pencil>
- ltex-ls: <https://github.com/valentjn/ltex-ls>

### UI

- PercyBrain Theme: Custom theme based on Tokyonight
- Which-Key: <https://github.com/folke/which-key.nvim>
- Alpha: <https://github.com/goolord/alpha-nvim>

### Git

- Fugitive: <https://github.com/tpope/vim-fugitive>
- Gitsigns: <https://github.com/lewis6991/gitsigns.nvim>
- Diffview: <https://github.com/sindrets/diffview.nvim>

### Academic

- VimTeX: <https://github.com/lervag/vimtex>
- Vim-Pandoc: <https://github.com/vim-pandoc/vim-pandoc>

______________________________________________________________________

**Last Updated**: 2025-10-22 **Plugin Count**: 67 plugins across 15 categories **Neovim Version**: ≥0.8.0 required **Migration**: Telekasten → IWE-only (custom Telescope/LSP implementations)
