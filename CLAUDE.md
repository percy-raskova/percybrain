# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**OVIWrite** is a Neovim-based Integrated Writing Environment (IWE) designed for writers, not programmers. Built on lazy.nvim plugin manager, it transforms Neovim into a full-featured writing tool supporting long-form prose (LaTeX), screenwriting (Fountain), note-taking (Markdown, Org-mode), and personal knowledge management (vim-wiki, Zettelkasten).

**Key Philosophy**: Plain text over rich text, modal editing efficiency, extensibility for writers' workflows.

**Target Audience**: Writers willing to learn Vim motions for speed-of-thought writing, editing, and world-building capabilities.

## Architecture

### Bootstrap & Configuration Structure

```
init.lua                        # Entry point: NeoVide config + requires('config')
├── lua/config/
│   ├── init.lua               # Bootstrap: lazy.nvim setup + loads globals/keymaps/options
│   ├── globals.lua            # Global variables and settings
│   ├── keymaps.lua            # Leader key mappings (<space> is <leader>)
│   └── options.lua            # Vim options (spell, search, appearance, behavior)
└── lua/plugins/
    ├── init.lua               # Minimal plugin loader (neoconf, neodev)
    ├── [plugin-name].lua      # Individual plugin configurations (lazy-loaded)
    └── lsp/                   # LSP configurations (mason, lspconfig, none-ls)
```

**Loading Sequence**: `init.lua` → `require('config')` → `lua/config/init.lua` → lazy.nvim setup → loads all `lua/plugins/*.lua`

**Plugin Architecture**: Each plugin is a separate Lua file in `lua/plugins/` returning a table with lazy.nvim spec. Plugins are lazy-loaded by default (see `config/init.lua` defaults).

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
- **fountain.lua**: Screenwriting in Fountain format
- **nvim-orgmode.lua / vimorg.lua**: Org-mode support for structured writing

### Spell/Grammar
- **LanguageTool.lua**: Advanced grammar and style checking
- **vim-grammarous.lua**: Grammar checker integration
- **vale.lua**: Prose linting
- Built-in spell check (enabled by default in options.lua)

### Note-taking & Knowledge Management
- **vim-wiki.lua**: Personal wiki system
- **vim-zettel.lua**: Zettelkasten method implementation
- **obsidianNvim.lua**: Obsidian vault editing support
- **org-bullets.lua / headlines.lua**: Visual enhancements for org/markdown headings

### PercyBrain Knowledge Management System
**PercyBrain** is a comprehensive Zettelkasten system that transforms OVIWrite into a complete Obsidian replacement with terminal integration.

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
- **twilight.lua**: Additional focus mode
- **centerpad.lua**: Center text in buffer
- **typewriter.lua**: Typewriter scrolling mode
- **stay-centered.lua**: Keep cursor centered

### Utilities
- **telescope.lua**: Fuzzy finder for files, buffers, help docs
- **fzf-lua.lua / fzf-vim.lua**: Fast file/text search
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

### Startup Screen Shortcuts
From Alpha splash screen:
- `f` - Find files
- `n` - New file
- `r` - Recent files
- `g` - Grep (find word)
- `l` - Lazy package manager
- `q` - Quit OVIWrite

## Plugin Development Guidelines

### Adding New Plugins

1. Create new file: `lua/plugins/plugin-name.lua`
2. Return lazy.nvim spec table:
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
3. Plugin loads automatically (lazy.nvim scans `lua/plugins/`)

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
- **Spell check not working**: Check `opt.spell = true` in options.lua
- **Lazy loading breaks plugin**: Set `lazy = false` or adjust trigger event
- **Keymaps not working**: Check for conflicts in keymaps.lua or plugin key specs
- **LaTeX not compiling**: Ensure LaTeX distribution installed (texlive, miktex)
- **Missing icons**: Install a Nerd Font and set terminal font

## Dependencies

### Required
- Neovim >= 0.8.0 (with LuaJIT)
- Git >= 2.19.0
- Nerd Font (for icons)

### Recommended for Full Functionality
- LaTeX distribution (TexLive, MikTeX)
- Pandoc (document conversion)
- LanguageTool (grammar checking)
- Node.js (for some LSP servers)
- ripgrep (for telescope/fzf searching)

## Testing Platforms
✅ Tested: Linux (Debian/Ubuntu), macOS (>10.0), Android (Termux)
❌ Limited testing: Windows, iPad
