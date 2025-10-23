# LSP Integration Patterns and Troubleshooting

**Date**: 2025-10-23 **Context**: PercyBrain Neovim - Writing environment with IWE LSP, ltex-plus, lua_ls

## Critical Insights

### Mason-LSPConfig Bridge Requirement

**The Problem**: LSP servers with config files in `lspconfig/configs/` weren't accessible via `lspconfig[server_name]`.

**Root Cause**: LSP servers MUST be registered in `mason-lspconfig`'s `ensure_installed` array to be available.

**How It Works**:

```lua
-- mason-lspconfig.lua
local opts = {
  ensure_installed = {
    "lua_ls",      -- Now lspconfig.lua_ls works
    "ltex_plus",   -- Now lspconfig.ltex_plus works
    -- NOT listed = NOT available (even if config exists)
  },
}
```

**Verification Command**:

```lua
:lua print(vim.inspect(require('lspconfig.util').available_servers()))
-- Should return all ensure_installed servers
```

**Key Learning**: Config files don't auto-register. Mason-lspconfig is the bridge that makes servers available to lspconfig.

### IWE LSP Design Philosophy

**What Users Expect** (traditional LSP):

- Hover documentation (`K` key)
- Popup explanations
- Inline documentation

**What IWE Provides** (knowledge management focus):

- Code Actions (`<leader>ca`) - 16 action types
- Completion (`+` character trigger)
- Navigation (`gd`, `gR`)
- Rename (`<leader>rn`)
- **NO hover** (`hoverProvider = false` by design)

**Why This Matters**:

- IWE is for *refactoring notes*, not *documenting code*
- Actions > Documentation: Extract, inline, AI transforms
- Context menus via code actions, not hover popups

**Teaching Point**: Set user expectations - IWE's "popups" are code actions, not hover.

### LSP Server Conflicts

**Scenario**: Multiple markdown LSPs (marksman, markdown-oxide, IWE)

**Problem**: LSPs can conflict, produce duplicate diagnostics, interfere with each other.

**Solution Pattern**:

```lua
-- Explicitly disable conflicting servers
lspconfig.marksman.setup({
  autostart = false,  -- Don't start automatically
})
```

**Best Practice**:

- One LSP per language/filetype
- Disable alternatives explicitly (don't rely on Mason uninstall)
- Document why each LSP is chosen

### Grammar Checker Configuration (ltex-plus)

**Technical Terms Dictionary**:

```lua
dictionary = {
  ["en-US"] = { "reqwest", "tokio", "serde", "async" },
}
```

**Progress Popup Suppression**:

```lua
local ltex_capabilities = vim.deepcopy(capabilities)
ltex_capabilities.window.workDoneProgress = false  -- Disable "Checking..." popups
```

**Status Bar Item Removal**:

```lua
settings = {
  ltex = {
    statusBarItem = false,  -- No "Checking document" status text
  }
}
```

**Why These Matter**: Reduce visual noise for ADHD users, prevent interruptions during flow state.

## File Organization Patterns

### Where LSP Configs Live

```
lua/plugins/lsp/
├── lspconfig.lua        -- Main LSP configuration (lua_ls, ltex_plus)
├── mason-lspconfig.lua  -- Bridge: ensure_installed registration
└── iwe.lua              -- Separate: IWE plugin config (not Mason-managed)
```

**Pattern**: Separate IWE from Mason-managed LSPs because IWE is installed via plugin manager, not Mason.

### Safe Setup Pattern

```lua
-- Helper function to prevent crashes on missing servers
local function safe_setup(server_name, config)
  local ok, server = pcall(function()
    return lspconfig[server_name]
  end)
  if ok and server then
    server.setup(config)
  else
    vim.notify(
      string.format("LSP server '%s' not available - install via Mason or manually", server_name),
      vim.log.levels.WARN
    )
  end
end
```

**Why**: Graceful degradation instead of startup crashes.

## Debugging Process

### When LSP Isn't Working

**Step 1**: Check server registration

```lua
:lua print(vim.inspect(require('lspconfig.util').available_servers()))
```

**Step 2**: Verify binary exists

```bash
which ltex-ls-plus  # or iwes, lua-language-server, etc.
```

**Step 3**: Check Mason installation

```vim
:Mason
# Press 'X' to see installed servers
```

**Step 4**: Check LSP attach status

```vim
:LspInfo
# Shows: attached servers, root directory, config
```

**Step 5**: Check for conflicts

```bash
ps aux | grep -E "ltex|marksman|markdown-oxide|iwes"
# Should only see ONE markdown LSP running
```

### When Diagnostics Are Wrong

**False Positives from Technical Terms**:

- Add to `dictionary` in ltex settings
- Use `# ltex-ignore` comments for one-off suppressions

**Conflicting Markdown Linters**:

- Disable unused LSPs explicitly with `autostart = false`
- Check for system-wide installs (Homebrew, apt, etc.)

**MD013 Line Length Warnings**:

- Usually from marksman, not ltex-plus
- Disable marksman or configure line length rules

## Integration with IWE

### Ollama Configuration

**IWE Project Config** (`~/Zettelkasten/.iwe/config.toml`):

```toml
[models.fast]
base_url = "http://localhost:11434/v1"
name = "llama3.2"  # 3.2B - fast operations

[models.default]
base_url = "http://localhost:11434/v1"
name = "dolphin3"  # 8B - complex operations
```

**No API Key Required**: Ollama is OpenAI-compatible, IWE works seamlessly.

**Restart Required**: After config changes, restart iwes:

```vim
:LspRestart iwes
```

### IWE Code Actions Available

**Refactoring**:

- `refactor.rewrite.*` - Rewrite lists/sections
- `refactor.delete` - Delete sections

**Extract/Inline**:

- `custom.extract*` - Extract sections/quotes to new files
- `custom.inline*` - Inline sections/quotes back

**AI Transforms**:

- `custom.keywords` - Bold important keywords
- `custom.emoji` - Add emojis
- `custom.expand` - Expand text
- `custom.rewrite` - Rewrite for clarity

**Organization**:

- `custom.link` - Link operations
- `custom.sort*` - Sort A-Z, Z-A
- `custom.today` - Add date

## Common Pitfalls

### ❌ Removing from ensure_installed but keeping safe_setup()

**Problem**: Server not registered → safe_setup() fails → startup error

**Fix**: Remove BOTH the ensure_installed entry AND the safe_setup() call

### ❌ Assuming config file existence = server availability

**Problem**: `lspconfig/configs/ltex_plus.lua` exists but server not available

**Fix**: Always check `available_servers()`, not filesystem

### ❌ Using IWE hover (`K`) expecting documentation

**Problem**: Users press `K`, nothing happens, assume IWE broken

**Fix**: Educate that IWE uses code actions (`<leader>ca`), not hover

### ❌ Multiple markdown LSPs competing

**Problem**: Duplicate diagnostics, conflicting actions, performance issues

**Fix**: One LSP per filetype - disable others explicitly

## Testing LSP Integration

### Verify ltex-plus Working

```bash
# Check processes
ps aux | grep ltex
# Should see 2 Java processes (ltex-ls-plus architecture)

# Check diagnostics
# Open markdown file with spelling error
# Should see diagnostic underline
```

### Verify IWE Working

```vim
# Check LSP attached
:LspInfo
# Should show iwes with 27+ buffers attached

# Check code actions
# Place cursor on header, press <leader>ca
# Should see menu with extract/inline/AI options

# Check completion
# Type + character
# Should see link completion suggestions
```

### Verify No Conflicts

```bash
# Only one markdown LSP should be running
ps aux | grep -E "marksman|markdown-oxide|iwes" | wc -l
# Should be 1 (iwes only)
```

## Documentation Created

- `claudedocs/LSP_INTEGRATION_FIXES_2025-10-23.md` - Comprehensive completion report
- All fixes, verification results, IWE capabilities documented
- Created as reference for future LSP integration work

## Related Memories

- `iwe_telekasten_integration_patterns.md` - IWE vs Telekasten migration
- `project_overview.md` - Overall PercyBrain architecture
- `codebase_structure.md` - File organization patterns
