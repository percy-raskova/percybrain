# PercyBrain Lazy.nvim Import Pattern

**Critical Learning**: Subdirectory plugin loading requires explicit imports

## Problem Pattern

When `lua/plugins/init.lua` returns a table with plugin specs, lazy.nvim **stops automatic subdirectory scanning**. This broke PercyBrain after reorganizing 68 plugins into 14 workflow subdirectories.

**Symptom**: 
- Neovim starts with blank screen
- Only 3 plugins load instead of 83
- No Alpha splash screen, no colorscheme, no keybindings

**Root Cause**:
```lua
-- THIS BREAKS SUBDIRECTORY SCANNING:
return {
  { "folke/neoconf.nvim", cmd = "Neoconf" },
  { "folke/neodev.nvim", opts = {} },
}
```

Lazy.nvim sees the returned table and doesn't scan `lua/plugins/*/` subdirectories.

## Solution Pattern

Use explicit `import` declarations for each subdirectory:

```lua
-- lua/plugins/init.lua
return {
  -- Core plugins that need early loading
  { "folke/neoconf.nvim", cmd = "Neoconf" },
  { "folke/neodev.nvim", opts = {} },

  -- Import all workflow subdirectories
  { import = "plugins.zettelkasten" },
  { import = "plugins.ai-sembr" },
  { import = "plugins.prose-writing.distraction-free" },
  { import = "plugins.prose-writing.editing" },
  { import = "plugins.prose-writing.formatting" },
  { import = "plugins.prose-writing.grammar" },
  { import = "plugins.academic" },
  { import = "plugins.publishing" },
  { import = "plugins.org-mode" },
  { import = "plugins.lsp" },
  { import = "plugins.completion" },
  { import = "plugins.ui" },
  { import = "plugins.navigation" },
  { import = "plugins.utilities" },
  { import = "plugins.treesitter" },
  { import = "plugins.lisp" },
  { import = "plugins.experimental" },
}
```

**Result**: All 68 plugins + 15 dependencies = 83 plugins loaded

## Directory Structure Supported

```
lua/plugins/
├── init.lua                # Explicit imports for all subdirs
├── zettelkasten/          # 6 plugin files
│   ├── iwe-lsp.lua
│   ├── vim-wiki.lua
│   └── ...
├── ai-sembr/              # 3 plugin files
├── prose-writing/         # Nested subdirectories
│   ├── distraction-free/  # 4 plugin files
│   ├── editing/           # 5 plugin files
│   ├── formatting/        # 2 plugin files
│   └── grammar/           # 3 plugin files
└── [10 more top-level dirs]
```

## Key Rules

1. **Explicit imports required** for nested directory structures
2. **Use dot notation** for paths: `"plugins.prose-writing.editing"`
3. **Import statement per directory** - no wildcards
4. **Top-level plugins** in init.lua load first (e.g., neoconf, neodev)
5. **Order matters** - dependencies should be imported before dependents

## Alternative Pattern (Not Recommended)

Empty init.lua + flat structure:
```lua
-- lua/plugins/init.lua
return {} -- Lazy.nvim auto-scans plugins/*.lua
```

**Works for**: Flat directory structure (`plugins/*.lua`)
**Breaks for**: Nested subdirectories (`plugins/category/*.lua`)

## Lazy.nvim Behavior Reference

- **Auto-scan**: Lazy.nvim auto-scans `lua/plugins/*.lua` when init.lua returns empty table or doesn't exist
- **Manual import**: When init.lua returns plugin specs, auto-scan disabled, must use `{ import = "..." }`
- **Nested dirs**: Always require explicit imports, never auto-scanned

## Diagnostic Commands

```lua
-- Check plugin count in Neovim headless
nvim --headless -c "lua print(#require('lazy').plugins())" -c "qall"

-- Expected: 80+ plugins (including dependencies)
-- If <10: Import configuration broken
```

## Testing Pattern

After modifying init.lua:
1. Test plugin count: `nvim --headless -c "lua print(#require('lazy').plugins())" -c "qall"`
2. Open Neovim normally: Check splash screen loads
3. Run `:Lazy` to verify all plugins discovered
4. Check `:checkhealth lazy` for any issues

## Common Mistakes

❌ **Returning only some plugins** - Breaks auto-scan
❌ **Missing import for subdirectory** - Plugins in that dir won't load
❌ **Wrong path syntax** - Use `"plugins.dir"` not `"plugins/dir"`
❌ **Empty table without imports** - Works only for flat structure

✅ **Explicit imports for all subdirs** - Always works
✅ **Consistent naming** - Match directory names exactly
✅ **Test after changes** - Verify plugin count immediately
