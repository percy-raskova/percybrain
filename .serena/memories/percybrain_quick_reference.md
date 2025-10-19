# PercyBrain Quick Reference Guide

**For**: Future sessions and rapid context recovery **Last Updated**: 2025-10-17

## System Overview

PercyBrain is a comprehensive Neovim-based Integrated Writing Environment (IWE) with AI-powered knowledge management, featuring:

- Blood Moon aesthetic (deep red/black with gold accents)
- Intuitive window management (`<leader>w`)
- Cybernetic Borg network visualization
- AI meta-metrics dashboard with Ollama
- Quick capture distraction-free writing
- BibTeX citation management
- Zettelkasten method implementation

## Key Files and Locations

### Configuration

- `~/.config/nvim/lua/config/init.lua` - Bootstrap
- `~/.config/nvim/lua/config/window-manager.lua` - Window system
- `~/.config/nvim/.mcp.json` - MCP server configuration

### PercyBrain Modules

- `~/.config/nvim/lua/percybrain/dashboard.lua` - AI metrics
- `~/.config/nvim/lua/percybrain/network-graph.lua` - Borg visualization
- `~/.config/nvim/lua/percybrain/quick-capture.lua` - Note creation
- `~/.config/nvim/lua/percybrain/bibtex.lua` - Citations

### Theme and UI

- `~/.config/nvim/lua/plugins/ui/percybrain-theme.lua` - Blood Moon theme
- `~/.config/nvim/lua/plugins/ui/alpha.lua` - Dashboard

### Documentation

- `~/.config/nvim/claudedocs/UI_UX_IMPLEMENTATION_COMPLETE.md` - Full implementation docs
- `~/.config/nvim/claudedocs/CRITICAL_IMPLEMENTATION_COMPLETE.md` - Plugin configuration docs

### Zettelkasten

- `~/Zettelkasten/` - Main vault
- `~/Zettelkasten/inbox/` - Quick captures
- `~/Zettelkasten/daily/` - Daily notes
- `~/Zettelkasten/web-clips/` - Exported web pages
- `~/Zettelkasten/bibliography.bib` - BibTeX citations

## Alpha Dashboard Quick Keys

Press from dashboard (on startup):

- `z` - New zettelkasten note
- `w` - Wiki explorer (NvimTree)
- `d` - AI Dashboards
- `m` - MCP Hub
- `t` - Terminal
- `a` - AI assistant menu
- `n` - New note (choose type)
- `D` - Distraction free writing (prompt → inbox → Goyo)
- `b` - Lynx browser
- `l` - BibTeX library
- `g` - Network graph (BORG!)
- `q` - Quit

## Window Management (`<leader>w`)

### Navigation

- `<leader>wh/j/k/l` - Move to window (left/down/up/right)

### Moving Windows

- `<leader>wH/J/K/L` - Move window to edge (left/bottom/top/right)

### Splitting

- `<leader>ws` - Horizontal split
- `<leader>wv` - Vertical split

### Closing

- `<leader>wc` - Close current window
- `<leader>wo` - Close other windows (only)
- `<leader>wq` - Quit window

### Resizing

- `<leader>w=` - Equalize windows
- `<leader>w<` - Maximize width
- `<leader>w>` - Maximize height

### Buffers

- `<leader>wb` - List buffers (Telescope)
- `<leader>wn` - Next buffer
- `<leader>wp` - Previous buffer
- `<leader>wd` - Delete buffer

### Layout Presets

- `<leader>wW` - Wiki workflow (3-pane: explorer | document | Lynx)
- `<leader>wF` - Focus mode (single window)
- `<leader>wG` - Research layout (Lynx | document)
- `<leader>wR` - Reset to default

### Info

- `<leader>wi` - Window statistics

## Zettelkasten Commands

### Core Operations

- `:PercyNew` - Create new note with template
- `:PercyDaily` - Today's daily note
- `:PercyInbox` - Quick capture to inbox
- `:PercyPublish` - Export to static site

### Search and Navigation

- `<leader>zf` - Find notes (fuzzy)
- `<leader>zg` - Search content (live grep)
- `<leader>zb` - Find backlinks
- `gd` - Follow wiki link (LSP)

### AI Operations

- `:PercyAI` - AI command menu
- `:PercyExplain` - AI explain text
- `:PercySummarize` - AI summarize note
- `:PercyLinks` - AI suggest links
- `:PercyImprove` - AI improve writing
- `:PercyAsk` - AI answer question
- `:PercyIdeas` - AI generate ideas

### Network Analysis

- `:PercyOrphans` - Find orphan notes
- `:PercyHubs` - Find hub notes (most connected)

## Lynx Browser Operations

### Commands

- `:LynxOpen` - Open URL in Lynx terminal
- `:LynxExport` - Export page to Markdown
- `:LynxCite` - Generate BibTeX citation
- `:LynxSummarize` - AI summarize webpage
- `:LynxExtract` - AI extract key points

### Keybindings

- `<leader>lo` - Open URL
- `<leader>le` - Export to wiki
- `<leader>lc` - Create citation
- `<leader>ls` - AI summary
- `<leader>lx` - AI extraction

## AI Dashboard Functions

### Access

- Press `d` from alpha dashboard
- Or: `:lua require('percybrain.dashboard').toggle()`

### Interactive Keys (in dashboard)

- `q` or `Esc` - Close
- `r` - Refresh (clear cache)
- `g` - Jump to network graph

### Metrics Displayed

- Link density (total, hubs, orphans, average)
- 7-day note growth bar chart
- Top 10 tags by frequency
- AI suggested connections (if available)
- Network health indicator

### Auto-Analysis

Runs automatically on every `.md` file save:

- Analysis time: \<30 seconds
- Non-blocking background execution
- Cache duration: 5 minutes
- Results appear in dashboard

## Network Graph (Borg Collective)

### Access

- Press `g` from alpha dashboard
- Or: `:lua require('percybrain.network-graph').show_borg()`

### Features

- Hexagonal hub clusters (⬢)
- Diamond nodes (◆)
- Orphan circles (○)
- Network statistics
- Health indicators
- Cybernetic ASCII patterns

### Node Classification

- **Hub**: 3+ wiki links
- **Connected**: 1-2 wiki links
- **Orphan**: 0 wiki links

## Quick Capture Workflow

### Distraction-Free (Press `D` from dashboard)

1. System prompts for note title
2. Generates filename: `YYYYMMDDHHMMSS-title.md`
3. Creates YAML front matter
4. Saves to `~/Zettelkasten/inbox/`
5. Opens file in editor
6. Auto-activates Goyo mode
7. Cursor positioned at end, insert mode

### Note Types (Press `n` from dashboard)

1. Zettelkasten (permanent note)
2. Daily journal entry
3. Fleeting note (inbox)
4. Literature note (with source)
5. Project note
6. Meeting notes

## BibTeX Browser

### Access

- Press `l` from alpha dashboard
- Or: `:lua require('percybrain.bibtex').browse()`

### Usage

1. Telescope opens with all citations
2. Search by key, title, or author
3. Select citation
4. Inserts `[@key]` at cursor
5. Cite key copied to clipboard

### Additional Functions

- `<C-p>` in Telescope - Preview full entry
- `:lua require('percybrain.bibtex').add_from_note()` - Extract citation from current note
- `:lua require('percybrain.bibtex').export_to_note()` - Export citation to note

## MCP Hub

### Access

- Press `m` from alpha dashboard
- Or: `:MCPHub`

### Commands

- `:MCPHub` - Open marketplace
- `:MCPHubList` - List installed servers
- `:MCPHubInstall` - Install server
- `:MCPHubUpdate` - Update servers

### Keybindings

- `<leader>mm` - Open MCP Hub
- `<leader>ml` - List installed

## Color Scheme

### Blood Moon Palette

```lua
background    = "#1a0000"  -- Deep blood red/black
foreground    = "#e8e8e8"  -- Light gray
gold          = "#ffd700"  -- Primary accent
crimson       = "#dc143c"  -- Secondary accent
red           = "#ff4444"  -- Errors
orange        = "#ff8844"  -- Warnings
yellow        = "#ffcc44"  -- Modified
green         = "#44ff88"  -- Success
cyan          = "#44ccff"  -- Info
blue          = "#4488ff"  -- Functions
purple        = "#cc88ff"  -- Constants
magenta       = "#ff44cc"  -- Types
```

### Theme Switching

```vim
:colorscheme tokyonight  " Blood Moon theme (default)
:colorscheme catppuccin  " Alternative
```

## Common Tasks

### Start New Writing Session

1. Launch Neovim (dashboard appears)
2. Press `D` for distraction-free
3. Enter title
4. Write in Goyo mode
5. `:w` to save (AI analyzes)
6. Press `<Esc>` twice to exit Goyo

### Research Workflow

1. Press `<leader>wW` for Wiki layout
2. Navigate to topic in file tree (left)
3. Open note in center pane
4. Use Lynx in right pane for research
5. Press `<leader>le` to export pages
6. Link notes with `[[title]]`

### Review Knowledge Network

1. Press `d` for AI dashboard
2. Check metrics and orphan percentage
3. Press `g` for network graph
4. Identify hub notes and clusters
5. Review AI suggestions
6. Connect isolated notes

### Citation Management

1. Browse web with Lynx
2. Press `<leader>lc` to generate citation
3. Press `l` from dashboard to browse library
4. Search for citation
5. Insert `[@key]` in note
6. Add reference section

## Troubleshooting

### Dashboard Not Loading

```vim
:lua require('percybrain.dashboard').toggle()
" Check for errors in :messages
```

### Theme Not Applied

```vim
:colorscheme tokyonight
" Or restart Neovim
```

### Window Manager Not Responding

```vim
:lua require('config.window-manager').setup()
" Or check :messages for errors
```

### AI Analysis Not Working

```bash
# Check Ollama status
ollama list

# Test Ollama
ollama run llama3.2 "test"

# Check URL in config
# Should be: http://localhost:11434
```

### Network Graph Empty

```bash
# Check Zettelkasten directory
ls ~/Zettelkasten/*.md

# Ensure wiki links format: [[link]]
```

## Performance Tips

### Speed Up Startup

- Only load essential plugins
- Use lazy loading extensively
- Keep plugin count reasonable

### Optimize AI Analysis

- Keep notes under 5000 words
- Use caching (built-in, 5min)
- Limit Ollama to simple prompts

### Reduce Memory Usage

- Close unused buffers regularly
- Clear dashboard cache: refresh with `r`
- Restart Neovim daily

## Dependencies

### Required

- Neovim ≥ 0.9.0
- Ollama with llama3.2
- Telescope.nvim
- NvimTree
- Goyo
- ToggleTerm

### Optional

- Lynx browser (web clipping)
- Pandoc (HTML conversion)
- ripgrep (fast search)
- bat (preview)

## Session Workflow

### Load Session

```vim
" Sessions auto-restore with last workspace
" Or manually with session plugin
```

### Save Progress

```bash
# Git commit for safety
cd ~/.config/nvim
git add .
git commit -m "checkpoint: description"
```

### Update Plugins

```vim
:Lazy sync
```

## Support and Documentation

### Get Help

- `:help percybrain` (if help tags generated)
- Read: `~/.config/nvim/claudedocs/`
- Check: `~/.config/nvim/CLAUDE.md`

### Key Documentation Files

1. `UI_UX_IMPLEMENTATION_COMPLETE.md` - UI/UX features
2. `CRITICAL_IMPLEMENTATION_COMPLETE.md` - Plugin configs
3. `PERCYBRAIN_DESIGN.md` - System architecture

## Version Information

**Current Version**: PercyBrain v2.0 (UI/UX Overhaul) **Last Major Update**: 2025-10-17 **Neovim Version**: 0.9.0+ **Plugin Count**: 68 plugins (48 well-configured)

______________________________________________________________________

**Quick Start**: Launch Neovim → See dashboard → Press keys → Write beautifully 🌙
