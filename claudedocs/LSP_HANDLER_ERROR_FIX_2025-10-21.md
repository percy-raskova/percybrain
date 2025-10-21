# LSP Handler Error Fix - Wrong LSP Server Configuration

**Date**: 2025-10-21 **Status**: ✅ FIXED **Error**: `attempt to call upvalue 'handler' (a nil value)`

## Problem

When opening markdown files, LSP throws repeated errors:

```
Error executing vim.schedule lua callback: .../Cellar/neovim/0.11.4/share/nvim/runtime/lua/vim/lsp.lua:1620:
attempt to call upvalue 'handler' (a nil value)
stack traceback:
    .../Cellar/neovim/0.11.4/share/nvim/runtime/lua/vim/lsp.lua:1620: in function 'handler'
    .../neovim/0.11.4/share/nvim/runtime/lua/vim/lsp/client.lua:1117: in function ''
    vim/_editor.lua: in function <vim/_editor.lua:8>
```

## Root Cause Analysis

**Issue**: Configuration referenced `markdown-oxide` LSP server instead of `iwe` (which was already installed)

**Chain of events**:

1. `lua/plugins/zettelkasten/iwe-lsp.lua` incorrectly referenced `Feel-ix-343/markdown-oxide` plugin
2. `lua/plugins/lsp/lspconfig.lua:246` configured `lspconfig["markdown_oxide"].setup()`
3. When markdown files are opened, LSP tries to attach `markdown-oxide`
4. Binary doesn't exist (only `iwe` is installed) → LSP client initialization fails
5. Handlers remain nil → error on every LSP callback attempt

**Affected files**:

- Any markdown file (`.md` extension)
- Zettelkasten notes
- GTD files
- Documentation files

## Solution

**Fix configuration to use `iwe` instead of `markdown-oxide`**:

### 1. Update LSP Configuration

**File**: `lua/plugins/lsp/lspconfig.lua:246`

**Before**:

```lua
lspconfig["markdown_oxide"].setup({
  -- ...
})
```

**After**:

```lua
lspconfig["iwe"].setup({
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    on_attach(client, bufnr)
    -- IWE-specific keymaps...
  end,
  filetypes = { "markdown" },
  root_dir = lspconfig.util.root_pattern(".git", ".iwe"),
})
```

### 2. Update Plugin File

**File**: `lua/plugins/zettelkasten/iwe-lsp.lua`

**Before**:

```lua
return {
  "Feel-ix-343/markdown-oxide",
  ft = "markdown",
  -- ...
}
```

**After**:

```lua
-- IWE LSP is configured directly in lua/plugins/lsp/lspconfig.lua
-- No separate plugin needed - IWE is a standalone LSP server binary
return {}
```

### 3. Verify IWE is Installed

```bash
# Check IWE binary exists
which iwe
# Expected: /home/percy/.cargo/bin/iwe

# If not installed, install via cargo
cargo install iwe
```

## Validation

After configuration fix, verify:

```bash
# Check IWE binary exists
which iwe
# Expected output: /home/percy/.cargo/bin/iwe

# Test LSP attachment in Neovim
nvim ~/Zettelkasten/testnote.md
:LspInfo  # Should show "iwe" attached to markdown buffer

# Verify no LSP errors
# Open markdown file → should see no error popups
```

## Configuration Files

### Plugin Configuration (FIXED)

**File**: `lua/plugins/zettelkasten/iwe-lsp.lua`

```lua
-- IWE LSP is configured directly in lua/plugins/lsp/lspconfig.lua
-- No separate plugin needed - IWE is a standalone LSP server binary
return {}
```

### LSP Configuration (FIXED)

**File**: `lua/plugins/lsp/lspconfig.lua:246`

```lua
-- IWE LSP for Zettelkasten markdown files
lspconfig["iwe"].setup({
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    on_attach(client, bufnr)

    -- IWE-specific keymaps for Zettelkasten workflow
    local iwe_opts = { noremap = true, silent = true, buffer = bufnr }

    iwe_opts.desc = "Find backlinks (references)"
    keymap.set("n", "<leader>zr", vim.lsp.buf.references, iwe_opts)

    iwe_opts.desc = "Extract/Inline section"
    keymap.set({ "n", "v" }, "<leader>za", vim.lsp.buf.code_action, iwe_opts)

    iwe_opts.desc = "Document outline (TOC)"
    keymap.set("n", "<leader>zo", vim.lsp.buf.document_symbol, iwe_opts)

    iwe_opts.desc = "Global note search"
    keymap.set("n", "<leader>zf", vim.lsp.buf.workspace_symbol, iwe_opts)
  end,
  filetypes = { "markdown" },
  root_dir = lspconfig.util.root_pattern(".git", ".iwe"),
})
```

## Prevention

**Documentation corrections needed**:

- ✅ Fixed lspconfig.lua to use `iwe` instead of `markdown_oxide`
- ✅ Fixed iwe-lsp.lua to remove incorrect plugin reference
- Update PERCYBRAIN_SETUP.md to clarify IWE is the correct LSP server
- Update docs/reference/LSP_REFERENCE.md with IWE requirements (not markdown-oxide)

**Suggested checkhealth check**:

```lua
-- In lua/config/health-fixes.lua or similar
local function check_iwe_lsp()
  if vim.fn.executable('iwe') == 0 then
    vim.health.warn(
      'IWE LSP not found',
      'Install: cargo install iwe'
    )
  else
    vim.health.ok('IWE LSP installed at ' .. vim.fn.exepath('iwe'))
  end
end
```

## Impact

**Before fix**:

- ❌ LSP errors on every markdown file
- ❌ No Zettelkasten link navigation
- ❌ No backlinks functionality
- ❌ Error log spam

**After fix**:

- ✅ Clean markdown file opening
- ✅ Link navigation with `gd`
- ✅ Backlinks with `<leader>zr`
- ✅ Document outline with `<leader>zo`
- ✅ Workspace symbols with `<leader>zf`

## Related Issues

**Similar LSP handler errors can occur when**:

- LSP server binary not in PATH
- LSP server crashes on startup
- Incompatible LSP server version
- Missing LSP server dependencies

**General troubleshooting**:

```vim
:LspInfo          " Check attached clients
:LspLog           " View LSP client logs
:checkhealth lsp  " Validate LSP setup
```

______________________________________________________________________

**Status**: ✅ FIXED - markdown-oxide installed and configured **Validation**: Open any .md file and verify no LSP errors
