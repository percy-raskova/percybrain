# Keymap Namespace Design Patterns

**Context**: PercyBrain Neovim configuration centralization **Date**: 2025-10-20

## Namespace Allocation Strategy

### Primary Workflow Namespaces

| Namespace    | Workflow        | Mnemonic                | Examples                            |
| ------------ | --------------- | ----------------------- | ----------------------------------- |
| `<leader>a*` | AI/SemBr        | **a**i                  | aa (menu), ac (chat), am (model)    |
| `<leader>d*` | Dashboard       | **d**ashboard           | da (Alpha)                          |
| `<leader>e`  | Explorer        | **e**xplore             | e (NvimTree)                        |
| `<leader>f*` | Find            | **f**ind                | ff (files), fg (grep), fb (buffers) |
| `<leader>g*` | Git             | **g**it                 | gg (gui), gs (status), gd (diff)    |
| `<leader>l*` | Lynx/Browser    | **l**ynx                | lo (open), le (export), lc (cite)   |
| `<leader>m*` | MCP/Markdown    | **m**cp/**m**arkdown    | mm (hub), md (styledoc)             |
| `<leader>p`  | Paste/Prose     | **p**aste/**p**rose     | p (image), o (goyo)                 |
| `<leader>q*` | Quick Capture   | **q**uick               | qc (capture)                        |
| `<leader>t*` | Toggle/Terminal | **t**oggle/**t**erminal | t, te, tz, tp\*                     |
| `<leader>u`  | Utilities       | **u**tilities           | u (undo tree)                       |
| `<leader>w*` | Window          | **w**indow              | ww, wh/j/k/l, ws/v                  |
| `<leader>x*` | Diagnostics     | e**x**ceptions          | xx (toggle), xd, xs                 |
| `<leader>y`  | Yazi            | **y**azi                | y (file manager)                    |
| `<leader>z*` | Zettelkasten    | **z**ettelkasten        | zn, zd, zf, zg, zb                  |

### Hierarchical Sub-namespaces

**Git (`<leader>g*`) - 4 tools unified**:

- `<leader>gg` - LazyGit GUI (primary interface)
- `<leader>g[sdbc]` - Fugitive core ops (status, diff, blame, commit)
- `<leader>gd*` - Diffview enhanced diffs (gdo, gdc, gdh, gdf)
- `<leader>gh*` - Gitsigns hunk ops (ghp, ghs, ghu, ghr, ghb)
- `]c`, `[c` - Gitsigns navigation (next/prev hunk)

**Window (`<leader>w*`) - Comprehensive system**:

- `<leader>ww` - Quick toggle
- `<leader>w[hjkl]` - Navigation (lowercase = navigate)
- `<leader>w[HJKL]` - Moving windows (uppercase = move to edge)
- `<leader>w[sv]` - Splitting (s=horizontal, v=vertical)
- `<leader>w[coq]` - Closing (c=close, o=only, q=quit)
- `<leader>w[=<>]` - Resizing (=equalize, \<>max width/height)
- `<leader>w[bnpd]` - Buffers (b=list, n=next, p=prev, d=delete)
- `<leader>w[WFRG]` - Layouts (W=wiki, F=focus, R=reset, G=research)
- `<leader>wi` - Info

**Zettelkasten (`<leader>z*`) - Note management**:

- `<leader>z[ndi]` - Creation (n=new, d=daily, i=inbox)
- `<leader>z[fgb]` - Navigation (f=find, g=grep, b=backlinks)
- `<leader>z[oh]` - Graph (o=orphans, h=hubs)
- `<leader>zp` - Publishing
- `<leader>z[tclk]` - Telekasten integration (t=tags, c=calendar, l=follow link, k=insert link)

**Toggle (`<leader>t*`) - UI/Terminal/Time**:

- `<leader>t` - Terminal
- `<leader>te` - ToggleTerm
- `<leader>ft` - Floaterm
- `<leader>tz` - ZenMode
- `<leader>t[fts]` - Translation (f=french, t=tamil, s=sinhala)
- `<leader>tp*` - Pendulum time tracking (tps=start, tpe=stop, tpt=status, tpr=report)

## Conflict Resolution Patterns

### Pattern 1: Move to Descriptive Namespace

**Conflict**: Single-key binding conflicts with namespace prefix **Solution**: Move single-key to descriptive multi-key

**Example**:

```
<leader>a (Alpha dashboard) CONFLICTS WITH <leader>a* (AI namespace)
RESOLUTION: <leader>a → <leader>da (dashboard alpha)
RESULT: AI keeps <leader>a* namespace, Alpha gets descriptive keymap
```

### Pattern 2: Add Second Character

**Conflict**: Primary tool needs single-key but conflicts **Solution**: Use doubled character for primary tool

**Example**:

```
<leader>g (LazyGit) CONFLICTS WITH <leader>g* (Git namespace)
RESOLUTION: <leader>g → <leader>gg (git gui)
RESULT: Git namespace <leader>g* available, LazyGit gets mnemonic gg
```

### Pattern 3: Use Capitalization

**Conflict**: Plugin manager vs namespace **Solution**: Capitalize for less-frequent operation

**Example**:

```
<leader>l (:Lazy) CONFLICTS WITH <leader>l* (Lynx namespace)
RESOLUTION: <leader>l → <leader>L (capital)
RESULT: Lynx keeps <leader>l* namespace, Lazy gets capital L
```

### Pattern 4: Move to Related Namespace

**Conflict**: UI toggle conflicts with namespace **Solution**: Move to toggle namespace with descriptive key

**Example**:

```
<leader>z (ZenMode) CONFLICTS WITH <leader>z* (Zettelkasten namespace)
RESOLUTION: <leader>z → <leader>tz (toggle zen)
RESULT: Zettelkasten keeps <leader>z*, ZenMode in logical toggle namespace
```

## Design Principles

### 1. Mnemonic Consistency

- First letter matches function (f=find, g=git, z=zettelkasten)
- Predictable muscle memory patterns
- Avoid arbitrary letter choices

### 2. Hierarchical Organization

- Primary namespace: `<leader>x*`
- Sub-namespaces: `<leader>xy*` (e.g., `<leader>gh*` for git hunks)
- Related operations grouped together

### 3. Frequency-Based Allocation

- Most frequent operations get shortest keys
- Less frequent get longer keys or capital letters
- Balance between ergonomics and namespace preservation

### 4. Workflow Alignment

- Namespaces match 14 PercyBrain workflows
- Related tools unified under single namespace
- Cross-tool consistency (git consolidation)

### 5. Conflict Prevention

- Registry system detects duplicates automatically
- Warn on startup about conflicts
- Debug command for visualization

## Anti-Patterns (Avoid)

❌ **Arbitrary letters**: `<leader>q` for git status (not mnemonic) ❌ **Scattered related operations**: Git operations across multiple namespaces ❌ **No hierarchy**: Flat namespace without logical grouping ❌ **Duplicate registrations**: Same key in multiple places ❌ **No conflict detection**: Silent keymap overrides

✅ **Correct approach**: Mnemonic, hierarchical, unified, detected, validated

## Module Organization

### By Workflow

- **core.lua** - Basic vim (cross-workflow)
- **window.lua** - Window management (cross-workflow)
- **git.lua** - Version control (utilities workflow)
- **zettelkasten.lua** - Note management (zettelkasten workflow)
- **ai.lua** - AI operations (ai-sembr workflow)
- **prose.lua** - Writing tools (prose-writing workflow)
- **diagnostics.lua** - Errors (diagnostics workflow)
- **navigation.lua** - File browsing (navigation workflow)
- **toggle.lua** - UI controls (ui workflow)
- **utilities.lua** - Misc tools (utilities workflow)
- **lynx.lua** - Browser (experimental workflow)
- **dashboard.lua** - UI (ui workflow)
- **quick-capture.lua** - Note intake (zettelkasten workflow)
- **telescope.lua** - Fuzzy find (navigation workflow)

### Module Size Guidelines

- **Small modules** (5-10 keymaps): Single-purpose tools (dashboard, lynx, utilities)
- **Medium modules** (10-20 keymaps): Focused workflows (toggle, diagnostics, prose, ai, zettelkasten)
- **Large modules** (20+ keymaps): Comprehensive systems (window, git)

### Separation Criteria

- **Distinct namespace** = separate module (e.g., git vs zettelkasten)
- **Shared namespace** = single module (e.g., all git tools in git.lua)
- **Cross-workflow tools** = core module (e.g., window management)

## Registry System

### Conflict Detection

```lua
-- Automatic detection on module registration
local registered_keys = {}

function register(key, source)
  if registered_keys[key] then
    vim.notify("⚠️  Keymap conflict: " .. key, vim.log.levels.WARN)
  end
  registered_keys[key] = source
end
```

### Debug Commands

```lua
-- List all registered keymaps
:lua require('config.keymaps').print_registry()

-- Check specific namespace
:verbose map <leader>z

-- Verify plugin loaded
:Lazy
```

## lazy.nvim Integration

### Lazy Loading Preservation

```lua
-- Plugin spec maintains lazy loading via keys parameter
return {
  "author/plugin",
  keys = require("config.keymaps.module"),
}
```

### Loading Behavior

- Plugin loads ONLY when keymap pressed
- Keymaps registered globally at startup via require()
- Conflict detection happens at registration time
- lazy.nvim handles actual plugin loading on keypress

## Migration Checklist

For each plugin:

1. ✅ Identify all keymaps (inline keys = {}, vim.keymap.set calls)
2. ✅ Determine appropriate namespace and module
3. ✅ Add keymaps to centralized module with registry.register_module()
4. ✅ Update plugin spec to require("config.keymaps.module")
5. ✅ Remove inline keymap definitions
6. ✅ Test lazy loading still works
7. ✅ Verify conflict detection triggers if duplicate

## Future Considerations

### Scalability

- Current 15 namespaces can handle 100+ plugins
- Hierarchical sub-namespaces (e.g., `<leader>gh*`) allow infinite expansion
- Registry system handles arbitrary number of keymaps

### Maintainability

- Single source of truth in lua/config/keymaps/
- Easy to find and modify keymaps
- Automatic conflict detection prevents errors
- Documentation auto-generated from registry

### Extensibility

- New workflows get dedicated namespace
- New tools join existing namespaces
- Pattern-based organization scales naturally
