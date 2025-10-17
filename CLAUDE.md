# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**PercyBrain** (formerly OVIWrite) is a Neovim-based Integrated Writing Environment (IWE) designed for writers, not programmers. Built on lazy.nvim plugin manager, it transforms Neovim into a comprehensive Zettelkasten knowledge management system with AI-assisted writing capabilities.

**Primary Use Cases** (in priority order):
1. **Knowledge Management/Zettelkasten** (PRIMARY) - Interconnected note-taking with IWE LSP, backlinks, and knowledge graphs
2. **AI-Assisted Writing** - Local LLM integration (Ollama) for draft generation from notes
3. **Long-form Prose** - LaTeX, Markdown with semantic line breaks, grammar checking
4. **Static Site Publishing** - Hugo integration for publishing notes as websites

**Key Philosophy**: Plain text over rich text, modal editing efficiency, extensibility for writers' workflows, local-first AI assistance.

**Target Audience**: Writers and knowledge workers willing to learn Vim motions for speed-of-thought note-taking, writing, and knowledge management.

## Architecture

### Bootstrap & Configuration Structure

```
init.lua                        # Entry point: NeoVide config + requires('config')
├── lua/config/
│   ├── init.lua               # Bootstrap: lazy.nvim setup + loads globals/keymaps/options
│   ├── globals.lua            # Global variables and settings
│   ├── keymaps.lua            # Leader key mappings (<space> is <leader>)
│   ├── options.lua            # Vim options (spell, search, appearance, behavior)
│   └── zettelkasten.lua       # PercyBrain Zettelkasten core module
└── lua/plugins/
    ├── init.lua               # Plugin loader with explicit workflow imports (CRITICAL)
    ├── zettelkasten/          # 6 plugins: IWE LSP, vim-wiki, vim-zettel, obsidian, etc.
    ├── ai-sembr/              # 3 plugins: AI Draft Generator, SemBr, ollama
    ├── prose-writing/         # 14 plugins across 4 subdirs (distraction-free, editing, formatting, grammar)
    ├── academic/              # 4 plugins: vimtex, vim-latex-preview, etc.
    ├── publishing/            # 3 plugins: Hugo, markdown-preview, etc.
    ├── org-mode/              # 3 plugins: nvim-orgmode, org-bullets, headlines
    ├── lsp/                   # 3 plugins: mason, lspconfig, none-ls
    ├── completion/            # 5 plugins: nvim-cmp and sources
    ├── ui/                    # 7 plugins: alpha, whichkey, lualine, etc.
    ├── navigation/            # 8 plugins: telescope, fzf-lua, nvim-tree, etc.
    ├── utilities/             # 15 plugins: lazygit, translate, img-clip, etc.
    ├── treesitter/            # 2 plugins: nvim-treesitter and context
    ├── lisp/                  # 2 plugins: conjure, parinfer
    └── experimental/          # 4 plugins: pendulum, styledoc, vim-dialect, w3m
```

**Loading Sequence**: `init.lua` → `require('config')` → `lua/config/init.lua` → lazy.nvim setup → `lua/plugins/init.lua` → explicit imports from 14 workflow directories

**Plugin Architecture**: 68 plugins organized into 14 workflow-based directories (+ 15 dependencies = 83 total). Each plugin is a separate Lua file returning a lazy.nvim spec. Plugins are lazy-loaded by default.

**⚠️ CRITICAL: lazy.nvim Subdirectory Loading Pattern**
When `lua/plugins/init.lua` returns a table, lazy.nvim **stops auto-scanning subdirectories**. You MUST use explicit imports:
```lua
return {
  { import = "plugins.zettelkasten" },
  { import = "plugins.ai-sembr" },
  -- ... all 14 workflow directories
}
```
Without explicit imports, only the plugins directly listed in `init.lua` will load, causing a blank screen on startup.

### Core Configuration Files

- **lua/config/options.lua**: Writer-focused defaults
  - Spell checking enabled (`opt.spell = true`, `opt.spelllang = 'en'`)
  - Line wrapping for prose (`opt.wrap = true`)
  - Smart indentation, relative numbers, scrolloff=10

- **lua/config/keymaps.lua**: Leader key shortcuts (see Keyboard Shortcuts section)

- **lua/config/globals.lua**: Global variables and theme settings

## Key Writing-Focused Plugins

### Long-form Writing
- **vimtex.lua**: LaTeX support for novels, academic writing, reports
- **vim-pencil.lua**: Line wrapping and soft breaks for prose
- **nvim-orgmode.lua**: Org-mode support for structured writing
- **nvim-surround.lua**: Surround text objects with quotes, brackets, tags (`ys`, `ds`, `cs`)
- **vim-repeat.lua**: Enhanced dot-repeat for plugin operations
- **vim-textobj-sentence.lua**: Sentence text objects for prose editing (`as`, `is`)
- **undotree.lua**: Visual undo history tree (`<leader>u`)

### Spell/Grammar
- **ltex-ls** (via lspconfig.lua): LanguageTool LSP with 5000+ grammar rules, real-time checking
- **vale.lua**: Prose linting for style guides
- Built-in spell check (enabled by default in options.lua)

### AI-Assisted Writing
- **ai-draft.lua**: AI Draft Generator - collects notes on a topic and synthesizes into prose
  - Command: `<leader>ad` - Generate draft from Zettelkasten notes
  - Uses local Ollama LLM (llama3.2) for privacy
  - 158-line implementation with note collection and synthesis
- **ollama.lua**: Local LLM integration for AI assistance

### Note-taking & Knowledge Management
- **vim-wiki.lua**: Personal wiki system
- **vim-zettel.lua**: Zettelkasten method implementation
- **obsidianNvim.lua**: Obsidian vault editing support
- **org-bullets.lua / headlines.lua**: Visual enhancements for org/markdown headings

### PercyBrain Knowledge Management System (PRIMARY USE CASE)
**PercyBrain** is a comprehensive Zettelkasten system that transforms Neovim into a complete Obsidian replacement with terminal integration. This is the **primary focus** of the project.

#### Core Components
- **lua/config/zettelkasten.lua**: Core PercyBrain module providing note capture, search, and publishing
- **IWE LSP** (lua/plugins/lsp/lspconfig.lua): Intelligent markdown server for wiki-style linking
  - Link completion and navigation (`gd` to follow links)
  - Backlinks tracking (`<leader>zr`)
  - Knowledge graph generation
  - Rename refactoring across vault (`<leader>rn`)
- **SemBr** (lua/plugins/sembr.lua): ML-based semantic line breaks for better git diffs
  - BERT transformer-based (not rule-based)
  - `<leader>zs` to format buffer/selection
  - `<leader>zt` to toggle auto-format on save
- **Static Site Publishing**: Automated Hugo/Quartz/Jekyll export from within Neovim

#### Two-Part Workflow
1. **Quick Capture**: Fleeting notes → Inbox → Processing
   - `<leader>zi`: Quick inbox capture
   - `<leader>zn`: New permanent note with timestamp ID
   - `<leader>zd`: Daily journal entry
2. **Organize & Publish**: Link notes → Build knowledge graph → Export
   - `<leader>zf`: Find notes (fuzzy search)
   - `<leader>zg`: Search note content (live grep)
   - `<leader>zb`: Find backlinks to current note
   - `<leader>zp`: Publish to static site

#### PercyBrain Commands
| Command | Action |
|---------|--------|
| `:PercyNew` | Create new note with template picker |
| `:PercyDaily` | Open today's daily note |
| `:PercyInbox` | Quick capture to inbox |
| `:PercyPublish` | Export to static site |
| `:PercyPreview` | Start local Hugo server |
| `:PercyOrphans` | Find orphan notes (no links) |
| `:PercyHubs` | Find hub notes (most connected) |
| `:PercyAI` | AI command menu |
| `:PercyExplain` | AI: Explain text |
| `:PercySummarize` | AI: Summarize note |
| `:PercyLinks` | AI: Suggest related links |
| `:PercyImprove` | AI: Improve writing |
| `:PercyAsk` | AI: Answer question |
| `:PercyIdeas` | AI: Generate ideas |
| `:SemBrFormat` | Format with semantic line breaks |
| `:SemBrToggle` | Toggle auto-format on save |

#### Installation Requirements
- **IWE LSP**: `cargo install iwe` (Rust-based markdown server) ✅ Installed
- **SemBr**: `uv tool install sembr` (Python ML tool) ✅ Installed
- **Ollama**: `curl -fsSL https://ollama.com/install.sh | sh && ollama pull llama3.2` ✅ Installed
  - Local LLM support for AI features
  - Model: llama3.2:latest (2.0 GB)

#### Configuration
- **Workspace**: `~/Zettelkasten/` (configured in lua/config/zettelkasten.lua)
- **Structure**:
  - `inbox/` - Fleeting notes
  - `daily/` - Daily journal entries
  - `templates/` - Note templates
  - `.iwe/` - IWE LSP configuration and index

#### Documentation
- **PERCYBRAIN_DESIGN.md**: Complete system architecture (1,129 lines)
- **PERCYBRAIN_SETUP.md**: User setup guide and workflows
- **PERCYBRAIN_README.md**: Feature comparison and quick start

### Distraction-Free Writing
- **zen-mode.lua**: Centered, clean writing interface
- **goyo.lua**: Minimalist writing mode
- **limelight.lua**: Dim paragraphs except current one
- **centerpad.lua**: Center text in buffer
- **typewriter.lua**: Typewriter scrolling mode
- **stay-centered.lua**: Keep cursor centered

### Static Site Publishing
- **hugo.lua**: Hugo static site generator integration
  - Commands: `:HugoNew`, `:HugoServer`, `:HugoPublish`, `:HugoBuild`
  - 40-line pragmatic implementation for publishing notes as websites
  - Local preview with live reload
  - Build and deploy from within Neovim

### Utilities
- **telescope.lua**: Fuzzy finder for files, buffers, help docs
- **fzf-lua.lua**: Fast file/text search (primary fuzzy finder)
- **nvim-tree.lua**: File explorer
- **lazygit.lua**: Git version control integration
- **translate.lua**: Built-in translator (English, French, Tamil, Sinhala)
- **img-clip.lua**: Paste images into Markdown/LaTeX
- **markdown-preview.lua / vim-latex-preview.lua**: Live preview
- **pomo.lua**: Pomodoro timer
- **alpha.lua**: Custom splash screen
- **whichkey.lua**: Keyboard shortcut discovery

### Color Schemes
- **catppuccin.lua**: Default theme (multiple flavors)
- **gruvbox.lua**: Retro groove color scheme
- **nightfox.lua**: Multiple fox-themed variants (NightFox, DawnFox, NordFox)

## Development Commands

### Essential Operations
```bash
# Start Neovim
nvim

# Install/Update plugins (from within Neovim)
:Lazy
:Lazy sync              # Update all plugins
:Lazy load all          # Load all lazy plugins immediately
:Lazy clean             # Remove unused plugins

# Check plugin status
:checkhealth            # Diagnose Neovim setup issues
:Lazy health            # Check lazy.nvim plugin health
```

### Testing Plugins
```bash
# Test individual plugin loading
:Lazy load [plugin-name]

# Reload configuration (after editing)
:source ~/.config/nvim/init.lua
:source ~/.config/nvim/lua/config/init.lua
```

### File Operations
- Config location: `~/.config/nvim/` (Unix/Linux/macOS)
- Plugin cache: `~/.local/share/nvim/lazy/`
- Data directory: `~/.local/share/nvim/`

### Common Development Tasks
```bash
# Edit plugin configuration
nvim ~/.config/nvim/lua/plugins/[plugin-name].lua

# Edit keymaps
nvim ~/.config/nvim/lua/config/keymaps.lua

# Edit options (spell, wrap, etc.)
nvim ~/.config/nvim/lua/config/options.lua

# View lazy.nvim lockfile (installed versions)
nvim ~/.config/nvim/lazy-lock.json
```

## Keyboard Shortcuts

**Leader key**: `<space>` (spacebar)

### Core Shortcuts (lua/config/keymaps.lua)
| Key Combo | Action | Notes |
|-----------|--------|-------|
| `<leader>e` | Toggle file tree | NvimTree explorer |
| `<leader>x` | Focus file tree | Jump to file explorer |
| `<leader>s` | Save file | Force write |
| `<leader>q` | Quit (force) | No save confirmation |
| `<leader>c` | Close window | Close current split |
| `<leader>v` | Vertical split | Open new vertical split |
| `<leader>t` | Open terminal | Built-in terminal |
| `<leader>l` | Lazy load all | Load all lazy plugins |
| `<leader>L` | Lazy menu | Open plugin manager UI |
| `<leader>w` | WhichKey | Show keybinding help |
| `<leader>a` | Alpha screen | Return to splash screen |
| `<leader>g` | LazyGit | Git interface |

### Writing Mode Shortcuts
| Key Combo | Action | Plugin |
|-----------|--------|--------|
| `<leader>fz` | ZenMode | Distraction-free writing (f = focus) |
| `<leader>o` | Goyo | Minimal writing mode |
| `<leader>sp` | SoftPencil | Enable soft line wrapping |
| `<leader>n` | Enable numbers | Show line numbers + cursorline |
| `<leader>rn` | Disable numbers | Hide all line numbers |
| `<leader>wn` | New writer file | Create from template |
| `<leader>u` | UndoTree | Visual undo history tree |
| `<leader>ad` | AI Draft | Generate draft from Zettelkasten notes |

### PercyBrain Zettelkasten Shortcuts

#### Core Note Management (z = Zettelkasten)
| Key Combo | Action | Description |
|-----------|--------|-------------|
| `<leader>zn` | `:PercyNew` | Create new note with template picker |
| `<leader>zd` | `:PercyDaily` | Open today's daily note |
| `<leader>zi` | `:PercyInbox` | Quick capture to inbox |
| `<leader>zf` | Find notes | Fuzzy find by filename |
| `<leader>zg` | Search notes | Live grep through content |
| `<leader>zb` | Backlinks | Find links to current note |
| `<leader>zp` | `:PercyPublish` | Export to static site |

#### AI Assistant (a = AI)
| Key Combo | Command | Description |
|-----------|---------|-------------|
| `<leader>aa` | `:PercyAI` | AI command menu (Telescope picker) |
| `<leader>ae` | `:PercyExplain` | AI: Explain text |
| `<leader>as` | `:PercySummarize` | AI: Summarize note |
| `<leader>al` | `:PercyLinks` | AI: Suggest related links |
| `<leader>aw` | `:PercyImprove` | AI: Improve writing |
| `<leader>aq` | `:PercyAsk` | AI: Answer question |
| `<leader>ax` | `:PercyIdeas` | AI: Generate ideas (eXplore) |

#### Focus Modes (f = focus)
| Key Combo | Action | Description |
|-----------|--------|-------------|
| `<leader>fz` | `:ZenMode` | Zen mode (distraction-free writing) |

#### Semantic Line Breaks (SemBr)
| Key Combo | Action | Description |
|-----------|--------|-------------|
| `<leader>zs` | `:SemBrFormat` | Format with ML-based semantic breaks |
| `<leader>zt` | `:SemBrToggle` | Toggle auto-format on save |

#### Knowledge Graph Analysis
| Command | Action | Description |
|---------|--------|-------------|
| `:PercyOrphans` | Find orphans | Notes with no links in/out |
| `:PercyHubs` | Find hubs | Top 10 most-connected notes |

#### LSP Navigation (IWE)
| Key Combo | Action | Description |
|-----------|--------|-------------|
| `<leader>zr` | LSP references | Find all backlinks (IWE LSP) |
| `gd` | Go to definition | Follow wiki link |
| `K` | Hover | Show link preview |
| `<leader>rn` | Rename | Rename across vault |

### Search & Find (FzfLua)
| Key Combo | Action |
|-----------|--------|
| `<leader>fzl` | Find files |
| `<leader>fzg` | Live grep (search text) |
| `<leader>fzm` | Search marks |

### Translation
| Key Combo | Language |
|-----------|----------|
| `<leader>tf` | Translate to/from French |
| `<leader>tt` | Translate to/from Tamil |
| `<leader>ts` | Translate to/from Sinhala |

### Terminal
| Key Combo | Action |
|-----------|--------|
| `<leader>ft` | FloatermToggle | Floating terminal |
| `<leader>te` | ToggleTerm | Terminal toggle |

### Hugo Publishing Shortcuts
| Command | Action |
|---------|--------|
| `:HugoNew` | Create new Hugo post |
| `:HugoServer` | Start local Hugo preview server |
| `:HugoBuild` | Build static site |
| `:HugoPublish` | Build and deploy site |

### Startup Screen Shortcuts
From Alpha splash screen:
- `f` - Find files
- `n` - New file
- `r` - Recent files
- `g` - Grep (find word)
- `l` - Lazy package manager
- `q` - Quit PercyBrain

## Plugin Development Guidelines

### Adding New Plugins

1. **Choose appropriate workflow directory**:
   - Zettelkasten features → `lua/plugins/zettelkasten/`
   - AI/writing assistance → `lua/plugins/ai-sembr/`
   - Prose editing tools → `lua/plugins/prose-writing/editing/`
   - Grammar/spell → `lua/plugins/prose-writing/grammar/`
   - Publishing → `lua/plugins/publishing/`
   - Experimental → `lua/plugins/experimental/`

2. **Create plugin file**: `lua/plugins/[workflow-dir]/plugin-name.lua`
```lua
return {
  "author/plugin-repo",
  lazy = true,           -- Lazy load (default)
  event = "VeryLazy",    -- or cmd, keys, ft triggers
  config = function()
    -- Plugin setup here
  end,
}
```

3. **Plugin loads automatically** from existing workflow directory

4. **For NEW workflow directories**: Must add explicit import to `lua/plugins/init.lua`:
```lua
{ import = "plugins.new-workflow-dir" }
```

### Plugin Spec Structure
```lua
return {
  "plugin/repo",
  dependencies = { "other/plugin" },  -- Load these first
  event = "VeryLazy",                 -- Load trigger
  cmd = "PluginCommand",              -- Command trigger
  keys = {                            -- Keymap trigger
    { "<leader>key", "<cmd>Command<cr>", desc = "Description" }
  },
  ft = "markdown",                    -- Filetype trigger
  config = function()
    require("plugin").setup({
      -- Plugin configuration
    })
  end,
}
```

### Common Triggers
- `event = "VeryLazy"` - Load after startup
- `event = "BufReadPre"` - Load before reading buffer
- `cmd = "Command"` - Load when command executed
- `ft = "filetype"` - Load for specific filetype
- `keys = {...}` - Load when key pressed
- `lazy = false` - Load immediately on startup

## Important Notes

### Writer-Centric Design
- **Spell checking is ON by default** (opt.spell = true)
- Line wrapping enabled (opt.wrap = true) - prose-friendly
- Clipboard integration with system clipboard
- Distraction-free modes prioritized (zen-mode, goyo, limelight)

### NeoVide Support
- GUI-specific settings in init.lua (lines 6-45)
- Custom font: Hack Nerd Font Mono 18pt
- Transparency and blur effects configured
- macOS-style keyboard shortcuts (Cmd+S, Cmd+C, Cmd+V)

### LaTeX Integration
- vimtex.lua handles LaTeX compilation
- Commented-out Skim viewer config (macOS PDF viewer) in init.lua
- Use vim-latex-preview.lua for live preview

### Git Workflow
- LazyGit integration (`<leader>g`) for visual git interface
- Assumes git repo context (see README.md - encourages version control for writers)

### Project Status
**⚠️ Maintenance Notice**: Project is seeking new maintainers (see README.md). Original author moved to Emacs. Active but not heavily maintained.

## Troubleshooting

### Plugin Issues
```vim
:checkhealth            " Diagnose all issues
:Lazy health            " Check plugin health
:Lazy restore           " Restore from lazy-lock.json
```

### Configuration Reload
After editing configs:
```vim
:source ~/.config/nvim/init.lua
:source ~/.config/nvim/lua/config/init.lua
:Lazy reload [plugin-name]
```

### Common Issues
- **Blank screen on startup**: Check `lua/plugins/init.lua` has explicit imports for all workflow directories
- **Plugins not loading**: Verify workflow directory has explicit `{ import = "plugins.dir" }` in `init.lua`
- **Spell check not working**: Check `opt.spell = true` in options.lua
- **Lazy loading breaks plugin**: Set `lazy = false` or adjust trigger event
- **Keymaps not working**: Check for conflicts in keymaps.lua or plugin key specs
- **LaTeX not compiling**: Ensure LaTeX distribution installed (texlive, miktex)
- **Missing icons**: Install a Nerd Font and set terminal font
- **IWE LSP not working**: Verify `cargo install iwe` completed, check `:LspInfo` in markdown buffer
- **AI features failing**: Verify Ollama installed and running: `ollama list`, `ollama pull llama3.2`

### Blank Screen Bug (Critical)
If Neovim starts with a blank screen showing no plugins:

**Cause**: `lua/plugins/init.lua` doesn't have explicit imports for workflow subdirectories. When `init.lua` returns a table, lazy.nvim stops auto-scanning subdirectories.

**Diagnosis**:
```bash
nvim --headless -c "lua print(#require('lazy').plugins())" -c "qall"
# Should show 80+, not 3
```

**Fix**: Ensure `lua/plugins/init.lua` contains explicit imports:
```lua
return {
  { "folke/neoconf.nvim", cmd = "Neoconf" },
  { "folke/neodev.nvim", opts = {} },

  -- ALL workflow directories must be explicitly imported
  { import = "plugins.zettelkasten" },
  { import = "plugins.ai-sembr" },
  -- ... all 14 directories
}
```

## Dependencies

### Required
- Neovim >= 0.8.0 (with LuaJIT)
- Git >= 2.19.0
- Nerd Font (for icons)

### Recommended for Full Functionality
- **LaTeX distribution** (TexLive, MikTeX) - for vimtex
- **Pandoc** - document conversion
- **Node.js** - for some LSP servers
- **ripgrep** - for telescope/fzf searching
- **IWE LSP** - `cargo install iwe` - Markdown LSP for wiki-linking
- **SemBr** - `uv tool install sembr` - ML-based semantic line breaks
- **Ollama** - `curl -fsSL https://ollama.com/install.sh | sh` - Local LLM runtime
  - Model: `ollama pull llama3.2` - 2.0 GB download
- **Hugo** - `snap install hugo` or from https://gohugo.io/ - Static site generator

## Testing Platforms
✅ Tested: Linux (Debian/Ubuntu), macOS (>10.0), Android (Termux)
❌ Limited testing: Windows, iPad

## Project Evolution

### Recent Refactoring (October 2025)
The project underwent a major reorganization from a flat 67-plugin structure to 14 workflow-based directories:

**What Changed**:
- 68 plugins reorganized into logical workflow categories
- Flat `lua/plugins/*.lua` → Hierarchical `lua/plugins/[workflow]/[plugin].lua`
- 8 new plugins added with full implementations
- 7 redundant plugins removed
- Focus shifted from "writing environment" to "Zettelkasten-first knowledge management system"

**Plugins Added**:
1. **IWE LSP** (markdown-oxide) - Wiki-style linking with LSP features
2. **AI Draft Generator** - Synthesize notes into prose using local LLM
3. **Hugo integration** - Static site publishing from Neovim
4. **ltex-ls** - LanguageTool grammar checking via LSP
5. **nvim-surround** - Surround operations for text objects
6. **vim-repeat** - Enhanced dot-repeat for plugins
7. **vim-textobj-sentence** - Sentence text objects for prose
8. **undotree** - Visual undo history tree

**Plugins Removed** (redundant/deprecated):
1. **fountain.lua** - Screenwriting (explicitly removed per user preference)
2. **twilight.lua** - Redundant with limelight for focus mode
3. **vim-grammarous.lua** - Replaced by ltex-ls LSP implementation
4. **LanguageTool.lua** - Replaced by ltex-ls LSP implementation
5. **gen.lua** - Redundant with ollama.lua for AI features
6. **fzf-vim.lua** - Redundant with fzf-lua
7. **vimorg.lua** - Deprecated in favor of nvim-orgmode

**Philosophy Shift**:
- **Before**: "Writing environment for multiple formats (LaTeX, Fountain, Org)"
- **After**: "Zettelkasten knowledge management system (PRIMARY) with writing support (SECONDARY)"
