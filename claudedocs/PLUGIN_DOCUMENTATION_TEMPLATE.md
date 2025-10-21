# Plugin Documentation Template

**Purpose**: Standardized header comment template for all lazy.nvim plugin specifications

**Apply to**: All 67 plugin files in `lua/plugins/`

______________________________________________________________________

## Template Structure

```lua
-- [Plugin Name]: [Primary purpose with neurodiversity context]
-- [Key features for PercyBrain workflow]
-- Repository: [GitHub URL]
-- Lazy Loading: [Strategy - event/cmd/keys/ft/lazy=true]
return {
  "[author]/[repo]",
  -- ... plugin spec ...
}
```

______________________________________________________________________

## Field Definitions

### Plugin Name

- **Format**: Title case, official plugin name
- **Example**: `Trouble.nvim`, `Telekasten`, `Auto-Save`

### Primary Purpose

- **Required**: Clear one-line description
- **Include neurodiversity context when applicable**:
  - ADHD optimizations (hyperfocus protection, reduced context switching)
  - Autism-friendly patterns (predictable behavior, reduced sensory overload)
  - Unified interfaces (ONE place for errors, notes, etc.)

### Key Features

- **1-3 bullet points** highlighting PercyBrain-relevant features
- Focus on workflow integration and user benefits
- Use **active voice** and **concise language**

### Repository

- **Format**: `Repository: https://github.com/[author]/[repo]`
- **Required**: For third-party plugins
- **Optional**: For custom PercyBrain plugins (dashboard, etc.)

### Lazy Loading Strategy

- **Document the approach** used for lazy loading:
  - `event = "VeryLazy"` - Loads after UI initialization
  - `cmd = "CommandName"` - Loads on command execution
  - `keys = { ... }` - Loads on keybinding press
  - `ft = { "filetype" }` - Loads for specific filetypes
  - `lazy = true` - Manual loading only

______________________________________________________________________

## Examples

### Example 1: ADHD-Optimized Plugin (Trouble.nvim)

```lua
-- Trouble.nvim: Unified error aggregation for ADHD/autism
-- ONE place for ALL errors - no hunting through multiple systems
-- Repository: https://github.com/folke/trouble.nvim
-- Lazy Loading: cmd + keys (loads on :Trouble or <leader>xx)
return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = "Trouble",
  keys = {
    { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "🚨 Toggle diagnostics" },
  },
}
```

**Why this works**:

- ✅ Clear neurodiversity context (ADHD/autism focus)
- ✅ Explains benefit (ONE place for errors)
- ✅ Documents lazy loading strategy
- ✅ Includes repository URL

### Example 2: Filetype-Specific Plugin (VimTeX)

```lua
-- VimTeX: Professional LaTeX workflow for academic writing
-- Live compilation, citation management, PDF preview integration
-- Repository: https://github.com/lervag/vimtex
-- Lazy Loading: ft (only loads for .tex files)
return {
  "lervag/vimtex",
  ft = { "tex", "plaintex", "bib" },
  config = function()
    vim.g.vimtex_view_method = "zathura"
  end,
}
```

**Why this works**:

- ✅ Clear purpose (academic writing)
- ✅ Lists key features (compilation, citations, preview)
- ✅ Documents lazy loading (filetype trigger)
- ✅ Workflow-relevant configuration shown

### Example 3: Optional Theme Plugin

```lua
-- Gruvbox: Alternative color scheme (warm, high contrast)
-- Lazy-loaded: Only active if manually selected via :colorscheme gruvbox
-- Repository: https://github.com/ellisonleao/gruvbox.nvim
-- Lazy Loading: lazy = true (manual activation only)
return {
  "ellisonleao/gruvbox.nvim",
  lazy = true,
}
```

**Why this works**:

- ✅ Describes aesthetic (warm, high contrast)
- ✅ Explains loading strategy (manual only)
- ✅ Simple and clear for optional plugins

### Example 4: Custom PercyBrain Plugin

```lua
-- PercyBrain Dashboard: Unified stats and quick actions
-- Zettelkasten metrics, network graph, Hugo publishing, AI model selection
-- Lazy Loading: lazy = false (always available for quick access)
return {
  "percybrain-dashboard",
  dir = vim.fn.stdpath("config"),
  lazy = false,
  priority = 100,
  config = function()
    require("percybrain.dashboard").setup()
  end,
}
```

**Why this works**:

- ✅ No repository URL (custom plugin)
- ✅ Lists dashboard features
- ✅ Explains eager loading rationale (always available)

______________________________________________________________________

## Application Checklist

When applying this template to existing plugins:

- [ ] Add header comment block
- [ ] Include neurodiversity context (if applicable)
- [ ] List 1-3 key features
- [ ] Add repository URL (third-party plugins only)
- [ ] Document lazy loading strategy
- [ ] Verify comment formatting (max 80 chars per line)
- [ ] Ensure comments are above `return` statement

______________________________________________________________________

## Migration Strategy

**Priority 1: Core Workflows** (18 plugins)

- Zettelkasten (5)
- AI-SemBr (3)
- Prose-writing (9)
- Publishing (1)

**Priority 2: Infrastructure** (6 plugins)

- LSP (4)
- Completion (1)
- Treesitter (1)

**Priority 3: Remaining** (43 plugins)

- UI, navigation, utilities, experimental, etc.

**Timeline**:

- Priority 1: Immediate (core functionality)
- Priority 2: Week 1 (infrastructure)
- Priority 3: Week 2-3 (comprehensive coverage)

______________________________________________________________________

## Verification

After applying template:

```bash
# Check documentation coverage
grep -c "^-- .*: " lua/plugins/**/*.lua

# Target: 67/67 files with structured headers
```

**Quality Standards**:

- ✅ All 67 plugins have structured header
- ✅ Neurodiversity context where applicable (12+ plugins)
- ✅ Repository URLs for third-party plugins (60+ plugins)
- ✅ Lazy loading strategy documented (67 plugins)

______________________________________________________________________

## Notes

- **Concise > Verbose**: Aim for clarity, not length
- **User-Focused**: Explain benefits, not just features
- **Workflow-Relevant**: Connect to PercyBrain use cases
- **Consistent Format**: Follow template structure exactly

This template supports PercyBrain's philosophy of **intentional design with neurodiversity-first principles**.
