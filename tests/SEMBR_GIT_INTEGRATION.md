# SemBr Git Integration for PercyBrain

## Philosophy: Extend, Don't Reinvent

We use **industry-standard Git plugins** and extend them for semantic line breaks rather than building custom Git integration.

## The Stack

### 1. vim-fugitive (Tim Pope)
- **Trust Score**: 10/10
- **Purpose**: Core Git operations
- **Why**: Industry standard for 10+ years, millions of users
- **Commands**: `:Git`, `:Gdiff`, `:Gblame`, etc.

### 2. gitsigns.nvim
- **Trust Score**: 9.7/10
- **Purpose**: Visual Git integration (gutters, hunks, inline blame)
- **Why**: Best-in-class visual Git indicators
- **Features**: Async, performant, word-diff support

### 3. diffview.nvim (Optional)
- **Trust Score**: 8.5/10
- **Purpose**: Advanced diff viewing
- **Why**: Side-by-side diffs, file history
- **Features**: Merge tool, conflict resolution

### 4. LazyGit (Keep existing)
- **Purpose**: Complex interactive Git operations
- **Why**: Best TUI for Git, complements fugitive

## Our SemBr Layer

Instead of reinventing Git integration, we created a **thin integration layer** (`lua/percybrain/sembr-git.lua`) that:

### Configures Git for SemBr
```bash
# Word-level diff for markdown
git config diff.markdown.wordRegex "([^[:space:]]|([[:alnum:]]|/)+)"

# Better diff algorithm
git config diff.algorithm patience

# Merge strategy for markdown
git config merge.tool vimdiff
```

### Creates .gitattributes
```gitattributes
*.md diff=markdown
*.md merge=union
```

### Extends Fugitive Commands
- `GSemBrDiff` - Fugitive diff with word wrap and line breaks
- `GSemBrBlame` - Fugitive blame with SemBr formatting
- `GSemBrCommit` - Commit with SemBr-aware message formatting

### Extends Gitsigns
- Auto-enables word diff for markdown buffers
- Preview hunks with proper line wrapping
- Stage hunks with SemBr preview

## Installation

1. **Install the Git plugins** (add to your plugin manager):
```lua
-- lua/plugins/utilities/fugitive.lua
{ "tpope/vim-fugitive" }

-- lua/plugins/utilities/gitsigns.lua
{ "lewis6991/gitsigns.nvim" }

-- lua/plugins/utilities/diffview.lua (optional)
{ "sindrets/diffview.nvim" }
```

2. **Load SemBr integration**:
```lua
-- Already configured in lua/plugins/zettelkasten/sembr-integration.lua
```

3. **Install sembr formatter** (optional but recommended):
```bash
uv tool install sembr
```

## Usage

### Basic Operations
```vim
" Standard fugitive commands work as normal
:Git status
:Git commit
:Git push

" SemBr-enhanced commands
:GSemBrDiff      " Diff with line wrapping
:GSemBrBlame     " Blame with SemBr formatting
:GSemBrCommit    " Commit with SemBr message format
```

### Keymaps
```vim
<leader>gs       " Git status (fugitive)
<leader>gd       " Git diff (fugitive)
<leader>gb       " Git blame (fugitive)

<leader>gsd      " SemBr diff
<leader>gsb      " SemBr blame
<leader>gsc      " SemBr commit

<leader>hs       " Stage hunk (gitsigns)
<leader>hr       " Reset hunk (gitsigns)
<leader>hp       " Preview hunk (gitsigns)
```

### Formatting
```vim
<leader>zs       " Format with semantic line breaks
<leader>zt       " Toggle auto-format on save
:SemBrFormat     " Format buffer/selection
:SemBrToggle     " Toggle auto-format
```

## Testing

Our tests focus on the **integration layer**, not the underlying tools:

```bash
# Run SemBr integration tests
nvim --headless -u tests/minimal_init.lua \
  -c "PlenaryBustedFile tests/plenary/unit/sembr/integration_spec.lua"

# Run formatter tests
nvim --headless -u tests/minimal_init.lua \
  -c "PlenaryBustedFile tests/plenary/unit/sembr/formatter_spec.lua"
```

## Key Design Decisions

### Why Fugitive Over Neogit?
- **Maturity**: 10+ years of development
- **Stability**: Millions of users, battle-tested
- **Simplicity**: Commands map directly to Git
- **Integration**: Works perfectly with our extensions

### Why Not Build Custom?
- **Complexity**: Git integration is hard to get right
- **Maintenance**: Let Tim Pope maintain fugitive
- **Features**: Fugitive has everything we need
- **Philosophy**: "If tooling exists, and it works, use it"

### How We Extend
1. **Wrap commands** with SemBr-specific settings
2. **Configure Git** for better markdown handling
3. **Add formatting** options to existing commands
4. **Preserve** all original functionality

## Benefits

1. **Reliability**: Using proven, stable plugins
2. **Maintainability**: Minimal custom code to maintain
3. **Compatibility**: Works with existing Git workflows
4. **Performance**: Leveraging optimized, async plugins
5. **Simplicity**: Thin layer over standard tools

## Hugo Integration

The SemBr-formatted markdown works seamlessly with Hugo:

1. **Git stores** semantic line breaks
2. **Hugo renders** as continuous paragraphs
3. **Diffs show** meaningful changes
4. **Merges work** better with line-based changes

## Summary

We achieve semantic line break support by:
- Using **vim-fugitive** for Git operations
- Using **gitsigns.nvim** for visual feedback
- Adding a **thin configuration layer**
- Extending, not replacing, existing commands

This approach follows the core Percyism: **"If tooling exists, and it works, use it."**

Total custom code: ~300 lines
Total functionality gained: Complete SemBr Git integration

**Simple. Robust. Maintainable.**