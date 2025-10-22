# PercyBrain UI Design Patterns

**Purpose**: Core UI/UX design decisions, ADHD-optimized visual organization, and consistent interface patterns

## Blood Moon Theme System

### Color Foundation

**Base Palette**:

- Background: `#1a0000` (deep blood red/black)
- Gold accent: `#ffd700` (primary highlights, important elements)
- Crimson: `#dc143c` (borders, cursor, active states)
- Black: Pure black for contrast depth
- Muted red tones for secondary elements

**Design Philosophy**:

- Refined Kitty aesthetic with improved contrast
- Prose-optimized (comfortable for long reading/writing sessions)
- Cybernetic/Borg-like visual coherence
- Dramatic but functional (not sacrificing readability for aesthetics)

### Theme Integration Pattern

```lua
-- Priority loading (before other UI)
lazy = false
priority = 1000

-- Override tokyonight base, maintain plugin compatibility
config = function()
  vim.cmd([[colorscheme tokyonight]])
  -- Apply Blood Moon overrides
end
```

**Plugin Integration Coverage**:

- Telescope (search UI)
- NvimTree (file explorer)
- WhichKey (keybinding discovery)
- Alpha (dashboard)
- Statusline components
- Floating windows
- LSP diagnostics
- Markdown/LaTeX syntax

### Syntax Highlighting (Prose-Optimized)

- Headers: Bold gold hierarchy
- Emphasis: Distinct italic/bold treatment
- Links: Crimson with subtle underline
- Code blocks: Muted contrast (not distracting in prose)
- Comments: Low-contrast gray (background noise)

## Floating Window Pattern

### Standard Configuration

**Dimensions**:

- Width: 75-77 columns (optimal reading width)
- Height: Adaptive (content-dependent, max 80% of screen)
- Centered positioning

**Visual Treatment**:

```lua
border = "double"          -- Double borders for clarity
title = " Title "          -- Centered with padding
title_pos = "center"
style = "minimal"          -- No status/tabline
relative = "editor"
```

**Buffer Lifecycle**:

```lua
bufhidden = "wipe"         -- Auto-cleanup on close
buflisted = false          -- Don't pollute buffer list
```

**Keybindings (Universal)**:

- `q` - Close window (primary escape)
- `<Esc>` - Close window (alternative)
- Context-specific actions on other keys

### Use Cases

**Information Display**:

- Network graph visualization
- AI metrics dashboard
- Error logs
- Help text
- Documentation previews

**Interactive**:

- Quick capture notes
- Bibliography search
- File navigation
- Command palettes

## Dashboard Layouts

### Alpha Dashboard Structure

**Visual Hierarchy**:

1. ASCII header (identity/branding)
2. Primary menu (12 items max - ADHD optimization)
3. Footer (status/quotes)

**Menu Organization** (3 sections):

**Start Writing** (immediate action):

- `z` - New zettelkasten note
- `n` - New note (choose type)
- `d` - Daily note
- `D` - Distraction free writing

**Workflows** (domain-specific):

- `w` - Wiki explorer
- `a` - AI assistant
- `b` - Lynx browser
- `l` - BibTeX library

**Tools** (system functions):

- `d` - AI Dashboards
- `m` - MCP Hub
- `t` - Terminal
- `g` - Network graph (Borg visualization)
- `q` - Quit

### Window Layout Presets

**Wiki Workflow** (`<leader>wW`):

```
┌─────────────┬─────────────┐
│   Explorer  │   Document  │
│   (tree)    │   (active)  │
│             │             │
├─────────────┴─────────────┤
│      Lynx Browser         │
└───────────────────────────┘
```

**Focus Mode** (`<leader>wF`):

- Single window, clean
- No explorer, no splits
- Goyo-compatible

**Research Mode** (`<leader>wG`):

```
┌─────────────┬─────────────┐
│    Lynx     │   Document  │
│  (browser)  │   (notes)   │
│             │             │
└─────────────┴─────────────┘
```

**Reset** (`<leader>wR`):

- Default NvimTree + single document state

## Notification Patterns

### Standard Notification

```lua
vim.notify("📝 Message text", vim.log.levels.INFO, {
  title = "Component Name"
})
```

**Emoji Convention**:

- ✅ Success operations
- ❌ Errors or failures
- ⚠️ Warnings (non-blocking issues)
- 📝 Document operations
- 🔍 Search/analysis
- 🤖 AI operations
- 🌐 Network/external operations
- 📊 Metrics/data

### Timing

- **Immediate**: User-initiated actions (save, create, delete)
- **Deferred**: Background operations (AI analysis, network scans)
- **Persistent**: Errors requiring attention
- **Ephemeral**: Status updates (analysis complete)

### Verbosity Levels

**INFO**: Confirmation of successful operations **WARN**: Non-critical issues (missing optional dependencies) **ERROR**: Critical failures requiring user action **DEBUG**: Disabled by default (development only)

## Visual Organization Principles

### ADHD Optimization

**Decision Fatigue Reduction**:

- Limit choices to 5-7 items per menu
- Clear default options
- Progressive disclosure (hide complexity until needed)
- Consistent patterns (same operation, same key across contexts)

**Visual Noise Minimization**:

- No animated elements
- Minimal color variation (Blood Moon palette only)
- Emoji for clarity, not decoration
- Clean borders, no excessive ornamentation

**Spatial Consistency**:

- Same information, same location (statusline muscle memory)
- Floating windows always centered
- Predictable layout patterns

### Discoverability Through WhichKey

**Group Naming Pattern**:

```lua
["<leader>p"] = "✏️ Prose"          -- Single emoji + clear label
["<leader>z"] = "📓 Zettelkasten"
["<leader>zr"] = "🔧 Refactor"      -- Nested with context
["<leader>w"] = "🪟 Windows"
["<leader>a"] = "🤖 AI"
```

**Description Pattern**:

```lua
{ key, command, desc = "📝 Human-readable action" }
```

**Anti-Patterns**:

- ❌ Technical command names (`pandoc-keyboard-toggle-strong`)
- ❌ Cryptic labels (`+8 keymaps`)
- ❌ Missing descriptions (forces user to test)
- ❌ Inconsistent emoji usage (confusing signals)

### Information Density

**Dashboard/Menus**: Low density (breathing room for ADHD focus) **Status Information**: Medium density (glanceable) **Data Visualizations**: High density (ASCII art network graphs) **Documentation**: Variable (based on content type)

## Cybernetic Visualization Patterns

### Network Graph Aesthetic

**ASCII Symbols**:

- Nodes: `⬢` (hexagons), `◆` (diamonds), `○` (circles)
- Connections: `─`, `│`, `├`, `┤`, `┬`, `┴`
- Hubs: Larger hexagons with multiple connections
- Orphans: Isolated circles

**Layout Algorithm**:

- Hubs at center
- Connected clusters grouped
- Orphans at periphery
- Density visualization through spacing

**Statistics Display**:

```
Network Health: ██████░░░░ 60%
Total Nodes: 247
Hub Notes: 12
Orphans: 34
Density: 0.42
```

**Footer Treatment**:

```
═══════════════════════════════════
 RESISTANCE IS FUTILE • BORG NETWORK
═══════════════════════════════════
```

### AI Metrics Dashboard

**Layout Sections**:

1. Link Analysis (total/hubs/orphans/density)
2. Growth Trends (7-day bar chart)
3. Tag Frequency (top 10 with counts)
4. AI Suggestions (Ollama-powered insights)
5. Network Health (composite score)

**Performance Requirements**:

- Auto-analysis on buffer save
- \<30 seconds for AI suggestions
- Non-blocking background execution
- Cache results (5-minute TTL)

**Visual Treatment**:

- Box drawing characters for structure
- Bar charts with filled/empty blocks
- Color-coded health indicators
- Compact single-screen layout

## Quick Capture Flow

### Distraction-Free Workflow

**Steps**:

1. Prompt for title (vim.ui.input)
2. Generate filename (`YYYYMMDDHHMMSS-title.md`)
3. Create YAML frontmatter (tags, status, created date)
4. Save to inbox directory
5. Auto-activate Goyo mode (distraction-free)

**Visual Progression**:

```
Prompt → Generate → Create → Save → Focus
  ↓        ↓         ↓        ↓       ↓
Input    Filename   YAML    Inbox   Goyo
```

**Template Types** (5 core):

- `note.md` - Standard atomic zettel
- `daily.md` - Daily capture notes
- `weekly.md` - Weekly review notes
- `source.md` - Literature notes with citations
- `moc.md` - Maps of Content (navigation hubs)

### Note Type Selection UI

**Telescope Picker**:

- Fuzzy search by template name
- Preview pane showing template structure
- One-key selection
- ESC to cancel

## Window Management System

### Navigation Keybindings

**Under `<leader>w` prefix**:

**Movement**:

- `h/j/k/l` - Navigate between windows (vim directions)
- `H/J/K/L` - Move window itself (capital = stronger action)

**Splitting**:

- `s` - Horizontal split (➖)
- `v` - Vertical split (➗)

**Closing**:

- `c` - Close current window (❌)
- `o` - Only this window (⭕)
- `q` - Quit window (🚪)

**Resizing**:

- `=` - Equalize all windows (⚖️)
- `<` - Shrink width (◀)
- `>` - Grow width (▶)
- `+` - Increase height (▲)

**Buffers**:

- `b` - List buffers (📝)
- `n` - Next buffer (➡️)
- `p` - Previous buffer (⬅️)
- `d` - Delete buffer (🗑️)

**Layouts**:

- `f` - Focus mode (📚)
- `w` - Writing mode (✍️)
- `r` - Rotate windows (🔄)
- `m` - Maximize current (🔬)

### Muscle Memory Patterns

**Consistency**:

- All window operations under `<leader>w`
- Lowercase = navigate/view
- Uppercase = modify/move
- Same keys as Vim native (h/j/k/l)

**Frequency Optimization**:

- Most common: Split (`s`), Navigate (`h/j/k/l`), Close (`c`)
- Less common: Layouts, resizing, rotating
- Rare: Equalize, maximize

## Privacy Protection Patterns

### Register Clearing

**Sensitive Data Locations**:

- Registers (`:reg` output)
- Command history (`:history`)
- Search history
- Clipboard integration

**Auto-Clear Strategy**:

```lua
-- On buffer save, clear potentially sensitive registers
-- Preserve unnamed register for normal editing
-- Clear search patterns after completion
```

**User Control**:

- Manual clear command (`<leader>pc`)
- Auto-clear on exit (opt-in)
- Whitelist for safe data

## Error Logging UI

### Native Neovim Display

**Floating Window**:

- Dedicated error log viewer
- Chronological error list
- Stack traces with syntax highlighting
- Filter by severity

**Integration**:

- Auto-populate on error events
- Keybinding to open (`<leader>el`)
- Clear errors command
- Export to file option

**Visual Treatment**:

- Errors in crimson
- Warnings in gold
- Info in muted tones
- Timestamps for context

## Performance Considerations

### Lazy Loading Strategy

**Immediate Load** (priority 1000):

- Theme (visual consistency)
- Window manager (core functionality)

**On Event**:

- Dashboard (VimEnter)
- Which-key (first keypress)
- Telescope (search command)

**On Command**:

- Network graph (manual invocation)
- AI dashboard (periodic, not startup)
- BibTeX browser (research workflow)

**Deferred**:

- MCP integrations (background services)
- Analytics (non-blocking)

### Caching Strategy

**AI Suggestions**:

- TTL: 5 minutes
- Invalidate on buffer save
- Shared across buffers (note-level, not buffer-level)

**Network Analysis**:

- TTL: 10 minutes
- Invalidate on note creation/deletion
- Background refresh (non-blocking)

**File Trees**:

- Lazy expand (load on navigate)
- Cache expanded state
- Invalidate on file system change

## Testing Patterns

### Visual Verification Checklist

Before merge:

- [ ] Alpha dashboard loads cleanly
- [ ] Which-key shows emoji + descriptions
- [ ] Floating windows centered with double borders
- [ ] Notifications use consistent emoji
- [ ] Theme applied to all UI elements
- [ ] Window management accessible
- [ ] Quick capture workflow seamless
- [ ] Network graph renders correctly

### Contract Tests

**UI Component Specs**:

- Floating window dimensions (75-77 columns)
- Border style (double)
- Color palette adherence
- Keybinding consistency

**ADHD Optimization Specs**:

- Template count ≤ 5
- Menu items ≤ 12
- Decision points minimized
- Visual noise eliminated

## Design Anti-Patterns

**Avoid**:

- ❌ Animated UI elements (distracting for ADHD)
- ❌ Modal dialogs (interrupting flow state)
- ❌ Excessive color variation (cognitive load)
- ❌ Nested menus >2 levels deep (decision fatigue)
- ❌ Technical jargon in UI (accessibility)
- ❌ Inconsistent keybindings (muscle memory disruption)
- ❌ Blocking operations without progress indication
- ❌ Auto-save without user control (anxiety)

**Prefer**:

- ✅ Floating windows (non-intrusive)
- ✅ Single-screen layouts (no hunting)
- ✅ Consistent symbol language (emoji)
- ✅ Flat menu structures
- ✅ Human-readable labels
- ✅ Predictable keybinding patterns
- ✅ Background operations with notifications
- ✅ Explicit save with confirmation

## Documentation Integration

**UI Element Documentation**:

- QUICK_REFERENCE.md: Keyboard shortcuts
- KEYBINDINGS_REFERENCE.md: Complete keymap catalog
- Inline help: `<leader>?` context-sensitive help

**Discovery Mechanisms**:

1. Which-key (primary)
2. Alpha dashboard (entry point)
3. Quick reference (lookup)
4. Inline help (context-specific)

______________________________________________________________________

**Design Philosophy**: Beautiful, minimal, ADHD-optimized. Reduce cognitive load, maintain flow state, enable speed of thought. Blood Moon aesthetic is signature, but function over form. Every UI element serves writer's focus.
