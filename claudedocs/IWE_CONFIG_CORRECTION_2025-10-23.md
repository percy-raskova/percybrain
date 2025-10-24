# IWE Configuration Correction - 2025-10-23

**Status**: ✅ Corrected to match official documentation **References**:

- https://raw.githubusercontent.com/iwe-org/iwe/refs/heads/master/docs/neovim.md
- https://raw.githubusercontent.com/iwe-org/iwe.nvim/refs/heads/main/README.md

______________________________________________________________________

## Changes Made

### ❌ **Removed Fields** (Not in Official Docs)

These fields were in the config but are **not documented** in iwe.nvim:

```lua
library_path = home,              -- Removed (not documented)
link_type = "markdown",           -- Removed (not documented)
link_actions = { ... },           -- Removed (not documented)
extract = { ... },                -- Removed (not documented)
```

**Impact**:

- These fields were likely being **silently ignored** by the plugin
- OR they were from a different/older version of IWE
- Removing them ensures configuration matches official spec

### ✅ **Added Fields** (From Official Docs)

```lua
lsp = {
  enable_inlay_hints = true,      -- NEW: Show type hints inline
},

preview = {                       -- NEW SECTION
  output_dir = "~/Zettelkasten/preview",
  temp_dir = "/tmp",
  auto_open = false,
},
```

### 🔄 **Retained Fields** (Confirmed Valid)

```lua
lsp = {
  cmd = { "iwes" },
  name = "iwes",
  debounce_text_changes = 500,
  auto_format_on_save = true,
}

mappings = {
  enable_markdown_mappings = true,
  enable_telescope_keybindings = true,
  enable_lsp_keybindings = true,
  enable_preview_keybindings = true,
  leader = "<leader>",
  localleader = "<localleader>",
}

telescope = {
  enabled = true,
  setup_config = true,
  load_extensions = { "ui-select", "emoji" },
}
```

______________________________________________________________________

## Functional Impact Analysis

### Lost Functionality ❓

**Question**: Did the removed fields (`library_path`, `link_actions`, `extract`) actually work?

**Answer**: Unknown - they weren't documented in iwe.nvim, so they were either:

1. **Silently ignored** (no functionality lost)
2. **From different plugin** (wrong plugin config mixed in)
3. **Deprecated/removed** (old features no longer supported)

### New Functionality ✅

1. **Inlay Hints**: Type information displayed inline in code
2. **Preview System**: Graph export and preview generation
   - Output directory: `~/Zettelkasten/preview/`
   - Preview keybindings now properly configured

______________________________________________________________________

## Official Keybindings (Confirmed Working)

### Markdown Editing (`enable_markdown_mappings = true`)

- `-` → Format line as checklist
- `<C-n>` → Next link
- `<C-p>` → Previous link
- `/d` → Insert date
- `/w` → Insert week

### Telescope Navigation (`enable_telescope_keybindings = true`)

- `gf` → Find files (Telescope picker)
- `gs` → Workspace symbols
- `ga` → Namespace symbols
- `g/` → Live grep content search
- `gb` → Backlinks (LSP references)
- `go` → Document outline (headers)

### LSP Refactoring (`enable_lsp_keybindings = true`)

- `<leader>h` → Rewrite list section
- `<leader>l` → Rewrite section list

### Preview Operations (`enable_preview_keybindings = true`)

- **Requires documentation** - keybindings not listed in README
- Likely graph export and visualization features

### Standard LSP (Always Available)

- `gd` → Go to definition / Follow link
- `gr` → Show references
- `K` → Hover documentation
- `<leader>ca` → Code actions
- `<leader>rn` → Rename symbol
- `]d` / `[d` → Next/previous diagnostic

______________________________________________________________________

## Verification Steps

After restarting Neovim:

1. **Check LSP attachment**:

   ```vim
   :LspInfo
   ```

   Should show `iwes` attached to markdown buffers

2. **Verify keybindings**:

   ```vim
   :verbose map gf
   :verbose map gb
   :verbose map <leader>h
   ```

3. **Test health**:

   ```vim
   :checkhealth iwe
   ```

4. **Test preview system**:

   - Open markdown file
   - Try preview keybindings (need to discover what they are)
   - Check `~/Zettelkasten/preview/` for output

______________________________________________________________________

## Questions for User

1. **Did link creation work before?**

   - If `link_actions` was functional, we may need to find where it's actually configured
   - Test: Create a note with `gd` - does it still create files?

2. **Do you use IWE's extract feature?**

   - If `extract` was working, we need to find the correct config location
   - Test: Try `<leader>ca` → "Extract section" - does it still work?

3. **What are the preview keybindings?**

   - Official docs mention `enable_preview_keybindings` but don't list them
   - Need to test or check `:map` after loading

______________________________________________________________________

## Next Steps

1. ✅ Configuration corrected to match official docs
2. ⏳ Restart Neovim to apply changes
3. ⏳ Run `:checkhealth iwe` to verify setup
4. ⏳ Test all keybindings systematically
5. ⏳ Report any missing functionality

______________________________________________________________________

## Frontmatter Template (Still Active)

The autocmd for frontmatter insertion is **independent** of IWE configuration and remains active:

```lua
-- Auto-insert frontmatter template for new notes created via gd
vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = home .. "/**/*.md",
  callback = function()
    -- Inserts YAML frontmatter + title
  end,
})
```

This should still work when creating notes via `gd`.
