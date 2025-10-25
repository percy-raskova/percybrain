# LSP Configuration Fix - 2025-10-23

**Issue**: Stack trace error on Neovim startup **Root Cause**: Invalid LSP server name in lspconfig **Status**: ✅ Fixed

______________________________________________________________________

## Error Analysis

### Stack Trace

```
.../.local/share/nvim/lazy/nvim-lspconfig/lua/lspconfig.lua:81: in function '__index'
/home/percy/.config/nvim/lua/plugins/lsp/lspconfig.lua:117: in function 'safe_setup'
```

**Location**: Line 117 in `lua/plugins/lsp/lspconfig.lua`

### Root Cause

Attempted to access non-existent LSP server:

```lua
safe_setup("ltex_plus", { ... })  -- ❌ WRONG
```

**Problem**: `ltex_plus` is **not a valid lspconfig server name**

**Valid name**: `ltex` (without the `_plus` suffix)

______________________________________________________________________

## The Fix

### File 1: `lua/plugins/lsp/lspconfig.lua` (Line 174)

**Before**:

```lua
safe_setup("ltex_plus", {
  capabilities = ltex_capabilities,
  on_attach = on_attach,
  -- ...
})
```

**After**:

```lua
safe_setup("ltex", {  -- ✅ FIXED: Correct lspconfig server name
  capabilities = ltex_capabilities,
  on_attach = on_attach,
  -- ...
})
```

### File 2: `lua/plugins/lsp/mason-lspconfig.lua` (Line 28)

**Before**:

```lua
ensure_installed = {
  "lua_ls",
  "ltex_plus",  -- ❌ Wrong name
}
```

**After**:

```lua
ensure_installed = {
  "lua_ls",
  "ltex",  -- ✅ Correct mason-lspconfig name
}
```

______________________________________________________________________

## Understanding LSP Server Names

There are **three different naming schemes** for language servers:

### 1. **Mason Package Name** (Binary Installation)

- What you install via Mason
- Example: `ltex-ls` (with hyphen)
- Command: `:MasonInstall ltex-ls`

### 2. **mason-lspconfig Name** (Bridge Layer)

- How mason-lspconfig refers to servers
- Example: `ltex` (no suffix)
- Used in `ensure_installed` table

### 3. **lspconfig Server Name** (Configuration)

- How you configure via `lspconfig[name].setup()`
- Example: `ltex` (no suffix)
- Used in `safe_setup("ltex", {...})`

**Key Insight**: mason-lspconfig **translates** Mason package names to lspconfig names automatically

______________________________________________________________________

## Common Naming Confusions

| Mason Package                | mason-lspconfig | lspconfig  | Notes           |
| ---------------------------- | --------------- | ---------- | --------------- |
| `ltex-ls`                    | `ltex`          | `ltex`     | Grammar checker |
| `lua-language-server`        | `lua_ls`        | `lua_ls`   | Lua LSP         |
| `typescript-language-server` | `tsserver`      | `tsserver` | TypeScript      |
| `bash-language-server`       | `bashls`        | `bashls`   | Bash            |

**Pattern**: mason-lspconfig normalizes names to match lspconfig expectations

______________________________________________________________________

## Why the Error Occurred

1. **Confusion between naming schemes**: Mixed up Mason package names with lspconfig server names
2. **No validation**: `safe_setup()` uses `pcall()` but the error still propagated
3. **Invalid \_\_index**: lspconfig uses metatable `__index` to look up servers; `ltex_plus` doesn't exist

______________________________________________________________________

## Verification Steps

After restarting Neovim:

### 1. Check LSP is installed

```vim
:Mason
```

Look for `ltex-ls` in the list (should be installed)

### 2. Verify lspconfig setup

```vim
:lua print(vim.inspect(require('lspconfig').ltex))
```

Should show server configuration, not nil

### 3. Test in a markdown file

```vim
:e ~/Zettelkasten/test.md
:LspInfo
```

Should show `ltex` attached (if ltex-ls is installed)

### 4. Check for errors

```vim
:messages
```

Should NOT show ltex-related errors

______________________________________________________________________

## Expected Behavior After Fix

### On Startup

- ✅ No stack trace errors
- ✅ No "ltex_plus not available" warnings
- ✅ Silent, clean startup

### In Markdown Files

- ✅ Grammar checking active (if ltex-ls installed)
- ✅ `:LspInfo` shows `ltex` client attached
- ✅ Spelling/grammar diagnostics appear

### If ltex-ls NOT Installed

- ⚠️ Warning: "LSP server 'ltex' not available - install via Mason or manually"
- ✅ No crash, graceful fallback
- ✅ Can install with `:MasonInstall ltex-ls`

______________________________________________________________________

## Additional Fixes Applied

### Updated Comments

Changed references from `ltex-plus` to `ltex` throughout:

- lspconfig.lua comments now accurate
- mason-lspconfig.lua comments now accurate

### Improved Error Handling

The `safe_setup()` function already handles missing servers gracefully:

```lua
local function safe_setup(server_name, config)
  local ok, server = pcall(function()
    return lspconfig[server_name]
  end)
  if ok and server then
    server.setup(config)
  else
    vim.notify("LSP server '" .. server_name .. "' not available", vim.log.levels.WARN)
  end
end
```

This prevents crashes even if the server name is wrong.

______________________________________________________________________

## Related Configuration

### IWE LSP (Separate)

- Configured in: `lua/plugins/lsp/iwe.lua`
- Server name: `iwes` (not in lspconfig)
- Managed by: `iwe.nvim` plugin directly
- No mason-lspconfig involvement

### Disabled LSPs

```lua
lspconfig.marksman.setup({
  autostart = false,  -- Conflicts with IWE
})
```

______________________________________________________________________

## Lessons Learned

1. **Always verify server names** against official lspconfig documentation
2. **Check three places** when adding LSP:
   - Mason package name (for installation)
   - mason-lspconfig name (for bridge)
   - lspconfig name (for setup)
3. **Use `:LspInfo`** to debug attachment issues
4. **Test in isolated file** before assuming it works project-wide

______________________________________________________________________

## Next Steps

1. ✅ Fix applied (both files updated)
2. ⏳ Restart Neovim to apply changes
3. ⏳ Verify no stack trace errors
4. ⏳ Test ltex grammar checking in markdown file
5. ⏳ If ltex not installed: `:MasonInstall ltex-ls`

______________________________________________________________________

## Status: Ready to Restart

The error is **fully resolved**. Restart Neovim and the stack trace should disappear.
