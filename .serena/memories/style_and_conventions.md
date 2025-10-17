# OVIWrite Code Style and Conventions

## Lua Style Guide
- **Indentation**: 2 spaces (no tabs)
- **Line length**: ~100 characters (flexible for plugin specs)
- **Naming conventions**:
  - Variables: `snake_case`
  - Functions: `snake_case`
  - Constants: `UPPER_CASE`

## Plugin Configuration Standards

### Required Structure
```lua
return {
  "author/repo",             -- [1] REQUIRED: Plugin URL (must be string)
  lazy = true,               -- Recommended: Lazy load by default
  event = "VeryLazy",        -- Trigger: event, cmd, keys, ft, or lazy=false
  dependencies = {           -- Optional: Dependencies (array)
    "other/plugin",
  },
  opts = {                   -- Preferred: Use opts instead of config = {}
    option = value,
  },
  keys = {                   -- Optional: Keymap triggers
    { "key", "command", desc = "description" },
  },
  config = function()        -- Use when setup() needs custom logic
    require("plugin").setup({
      -- ...
    })
  end,
}
```

### Plugin Spec Rules
✅ **Correct**:
```lua
return {
  "author/repo",  -- [1] must be string
  opts = {},
}
```

❌ **Wrong** (module structure):
```lua
local M = {}
M.setup = function() ... end
return M
```

### Lazy Loading Triggers
- `event = "VeryLazy"` - Load after startup
- `event = "BufReadPre"` - Load before reading buffer
- `cmd = "Command"` - Load when command executed
- `ft = "markdown"` - Load for specific filetype
- `keys = {...}` - Load when key pressed
- `lazy = false` - Load immediately on startup

## File Organization Rules

### Allowed Structure
```
lua/
├── config/             # Core configuration
│   ├── init.lua       # ALLOWED (bootstrap loader)
│   ├── globals.lua
│   ├── keymaps.lua
│   └── options.lua
├── plugins/            # Plugin specifications (lazy.nvim auto-loads)
│   ├── init.lua       # ALLOWED (minimal plugin loader)
│   ├── plugin1.lua    # Each plugin in separate file
│   └── lsp/           # LSP configurations
└── utils/              # Utility modules (NOT auto-loaded)
    └── helpers.lua
```

### Rules
- ✅ One plugin per file in `lua/plugins/*.lua`
- ✅ Plugin files must return lazy.nvim spec: `{ "author/repo", ... }`
- ✅ Utility modules go in `lua/utils/`, NOT `lua/plugins/`
- ✅ Only `lua/plugins/init.lua` and `lua/config/init.lua` allowed as init.lua
- ❌ No duplicate plugin files (e.g., `nvim-tree.lua` + `nvimtree.lua`)
- ❌ No module structures in `lua/plugins/` (return spec, not module)

## Keymap Standards
```lua
-- In lua/config/keymaps.lua
vim.keymap.set("n", "<leader>x", "<cmd>Command<cr>", {
  desc = "Clear description of action",  -- Always include desc
  silent = true,                         -- Optional: don't show command
  noremap = true,                        -- Optional: non-recursive (default)
})
```

## Commit Message Convention
Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add new writing plugin
fix: resolve duplicate plugin loading
docs: update CLAUDE.md with new keymaps
refactor: simplify plugin configuration
test: add validation for deprecated APIs
chore: update dependencies
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `refactor`: Code refactoring (no behavior change)
- `test`: Adding or fixing tests/validation
- `chore`: Maintenance tasks

## Deprecated API Patterns to Avoid
- ❌ `vim.highlight.on_yank` → ✅ `vim.hl.on_yank`
- Check `scripts/deprecated-patterns.txt` for full list
