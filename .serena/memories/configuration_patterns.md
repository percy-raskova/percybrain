# Neovim Configuration Patterns - Essential Practices

**Purpose**: Consolidated patterns for lazy.nvim setup, LSP configuration, plugin specs, and error handling **Sources**: config_improvements_2025-10-21, critical_implementation_session_2025-10-17, LSP_HANDLER_ERROR_FIX_2025-10-21

______________________________________________________________________

## lazy.nvim Core Patterns

### Critical: Explicit Import Pattern

**Problem**: lazy.nvim stops auto-scanning when `lua/plugins/init.lua` returns a table **Symptom**: Blank screen on startup, plugin count shows 3 instead of 68+ **Solution**: MUST have explicit imports for all workflow directories

```lua
-- lua/plugins/init.lua - REQUIRED PATTERN
return {
  { import = "plugins.zettelkasten" },
  { import = "plugins.ai-sembr" },
  { import = "plugins.prose-writing" },
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

**Validation**: `nvim --headless -c "lua print(#require('lazy').plugins())" -c "qall"` should show 68+

### Bootstrap Pattern

```lua
-- init.lua
require('config')  -- Load core config

-- lua/config/init.lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { import = "plugins" },  -- Imports lua/plugins/init.lua
})
```

______________________________________________________________________

## Plugin Specification Best Practices

### Standard Plugin Spec Template

```lua
-- File: lua/plugins/category/plugin-name.lua
-- Purpose: [What this plugin does]
-- Workflow: [Which workflow(s) it belongs to]
-- Config Level: [Minimal/Basic/Comprehensive]

return {
  "author/plugin-name",

  -- Loading strategy (choose one)
  lazy = true,                    -- Lazy load
  event = "VeryLazy",             -- Load after startup
  cmd = { "CommandName" },        -- Load on command
  keys = { "<leader>x" },         -- Load on keymap
  ft = { "markdown", "tex" },     -- Load on filetype

  -- Dependencies
  dependencies = {
    "dependency/plugin",
    { "optional/plugin", optional = true },
  },

  -- Build steps
  build = "make",                 -- Or function() end

  -- Configuration
  config = function()
    -- Plugin setup
    require("plugin").setup({
      -- Options
    })

    -- Keymaps with descriptions
    vim.keymap.set("n", "<leader>x", ":Command<CR>", {
      desc = "Action description",
      noremap = true,
      silent = true
    })
  end,

  -- Initialization (runs before config)
  init = function()
    -- Set vim variables/globals
    vim.g.plugin_option = value
  end,
}
```

### Configuration Complexity Levels

**Minimal (3-10 lines)**: Just plugin spec, no config

```lua
return { "author/plugin", event = "VeryLazy" }
```

**Basic (10-30 lines)**: Essential setup, minimal keymaps

```lua
return {
  "author/plugin",
  config = function()
    require("plugin").setup({ option = value })
    vim.keymap.set("n", "<leader>x", ":Command<CR>", { desc = "Action" })
  end
}
```

**Comprehensive (30-100 lines)**: Full feature set, multiple keymaps, integrations

```lua
return {
  "author/plugin",
  dependencies = { "dep/plugin" },
  config = function()
    local plugin = require("plugin")
    plugin.setup({
      -- Extensive options
      option1 = value1,
      option2 = value2,
      callbacks = {
        on_event = function() end,
      },
    })

    -- Multiple keymaps with clear descriptions
    local opts = { noremap = true, silent = true }
    vim.keymap.set("n", "<leader>x1", plugin.action1, vim.tbl_extend("force", opts, { desc = "Action 1" }))
    vim.keymap.set("n", "<leader>x2", plugin.action2, vim.tbl_extend("force", opts, { desc = "Action 2" }))

    -- Integration with other plugins
    vim.api.nvim_create_autocmd("User", {
      pattern = "OtherPluginEvent",
      callback = function() plugin.integrate() end,
    })
  end
}
```

### Header Documentation Standard

Every plugin file should have:

```lua
-- Purpose: Brief one-line description of plugin function
-- Workflow: [Zettelkasten/Prose Writing/Academic/etc.]
-- Config Level: [Minimal/Basic/Comprehensive]
-- Dependencies: [External tools if any]
-- Keybindings: [Primary keymaps if configured]
```

______________________________________________________________________

## LSP Configuration Patterns

### Correct LSP Server Setup

**Anti-Pattern**: Configuring non-existent LSP servers

```lua
-- WRONG - markdown_oxide binary doesn't exist
lspconfig["markdown_oxide"].setup({ ... })
```

**Correct Pattern**: Verify binary exists first

```lua
-- RIGHT - Check binary, use correct server name
if vim.fn.executable('iwe') == 1 then
  lspconfig["iwe"].setup({
    capabilities = capabilities,
    on_attach = on_attach,
    filetypes = { "markdown" },
    root_dir = lspconfig.util.root_pattern(".git", ".iwe"),
  })
end
```

### LSP Handler Error Prevention

**Symptom**: `attempt to call upvalue 'handler' (a nil value)` **Root Cause**: LSP client initialization fails due to missing binary **Impact**: Repeated errors on every LSP callback

**Prevention**:

1. Always check `vim.fn.executable('binary')` before LSP setup
2. Use correct LSP server names (not plugin names)
3. Verify binary installation in documentation
4. Add health checks for LSP dependencies

```lua
-- Health check pattern
local function check_lsp_binary(name, binary)
  if vim.fn.executable(binary) == 0 then
    vim.health.warn(
      string.format('%s LSP not found', name),
      string.format('Install: [installation command]', binary)
    )
  else
    vim.health.ok(string.format('%s LSP installed at %s', name, vim.fn.exepath(binary)))
  end
end
```

### LSP Configuration Template

```lua
-- File: lua/plugins/lsp/lspconfig.lua
local lspconfig = require("lspconfig")

-- Shared capabilities (nvim-cmp integration)
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Shared on_attach with keymaps
local on_attach = function(client, bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }

  -- Standard LSP keymaps
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
end

-- Server-specific setup with binary check
if vim.fn.executable('iwe') == 1 then
  lspconfig["iwe"].setup({
    capabilities = capabilities,
    on_attach = function(client, bufnr)
      on_attach(client, bufnr)

      -- Server-specific keymaps
      local iwe_opts = { noremap = true, silent = true, buffer = bufnr }
      vim.keymap.set("n", "<leader>zr", vim.lsp.buf.references,
        vim.tbl_extend("force", iwe_opts, { desc = "Find backlinks" }))
    end,
    filetypes = { "markdown" },
    root_dir = lspconfig.util.root_pattern(".git", ".iwe"),
  })
end
```

______________________________________________________________________

## Error Handling & Defensive Programming

### File Existence Validation

```lua
-- Before operations, check file exists
local function safe_read(filepath)
  if vim.fn.filereadable(filepath) == 0 then
    vim.notify("File not found: " .. filepath, vim.log.levels.WARN)
    return nil
  end
  return vim.fn.readfile(filepath)
end
```

### Error Suppression with Fallbacks

```bash
# In shell scripts/mise tasks
passed=$(grep -c "PASSED" "$cache_file" 2>/dev/null || echo "0")
failed=$(grep -c "FAILED" "$cache_file" 2>/dev/null || echo "0")
```

### Structured Error Reporting

```lua
-- Machine-readable status tracking
local status = {
  passed = 0,
  failed = 0,
  errors = {},
}

-- Collect results
for _, test in ipairs(tests) do
  local ok, result = pcall(run_test, test)
  if ok then
    status.passed = status.passed + 1
  else
    status.failed = status.failed + 1
    table.insert(status.errors, { test = test.name, error = result })
  end
end

-- JSON output for machine parsing
print(vim.json.encode(status))
```

### Actionable Error Messages

```lua
-- BAD: Silent failure
if not ok then return end

-- GOOD: Clear error with next steps
if not ok then
  vim.notify(
    string.format("Failed to load %s. Check :messages for details.", plugin_name),
    vim.log.levels.ERROR
  )
  vim.notify("Try: :Lazy sync", vim.log.levels.INFO)
  return
end
```

______________________________________________________________________

## Configuration Anti-Patterns (AVOID)

### ❌ DRY Violations

**Problem**: Repeated bash commands across multiple tasks

```toml
# BAD - Duplicated 15+ times
[tasks."test:contract"]
run = 'nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/contract_tests/ { minimal_init = \"tests/minimal_init.lua\" }" || echo "FAILED: contract" >> "$cache_file"'

[tasks."test:capability"]
run = 'nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/capability_tests/ { minimal_init = \"tests/minimal_init.lua\" }" || echo "FAILED: capability" >> "$cache_file"'
```

**Solution**: Extract to parameterized helper

```toml
# GOOD - Single source of truth
[tasks."test:_run_plenary_dir"]
run = '''
nvim --headless -u tests/minimal_init.lua \
  -c "PlenaryBustedDirectory tests/$1/ { minimal_init = \"tests/minimal_init.lua\" }" \
  || echo "FAILED: $1" >> "$MISE_PROJECT_ROOT/.test_results.cache"
'''

[tasks."test:contract"]
run = "mise run test:_run_plenary_dir contract_tests"

[tasks."test:capability"]
run = "mise run test:_run_plenary_dir capability_tests"
```

### ❌ Silent Failures

**Problem**: Operations fail without user awareness

```lua
-- BAD
pcall(function() require("plugin").setup() end)
```

**Solution**: Report failures with context

```lua
-- GOOD
local ok, err = pcall(function() require("plugin").setup() end)
if not ok then
  vim.notify("Plugin setup failed: " .. tostring(err), vim.log.levels.ERROR)
end
```

### ❌ Missing Binary Checks

**Problem**: LSP/tool configured but binary missing

```lua
-- BAD - Will error on first use
lspconfig["server"].setup({ ... })
```

**Solution**: Check before setup

```lua
-- GOOD
if vim.fn.executable('server') == 1 then
  lspconfig["server"].setup({ ... })
else
  vim.notify("LSP server 'server' not found. Install: [command]", vim.log.levels.WARN)
end
```

### ❌ Incomplete Error Reporting

**Problem**: Only showing passed counts, hiding failures

```bash
# BAD
echo "Tests Passed: $(grep -c PASSED $cache)"
```

**Solution**: Show both success and failure

```bash
# GOOD
passed=$(grep -c "PASSED" "$cache" 2>/dev/null || echo "0")
failed=$(grep -c "FAILED" "$cache" 2>/dev/null || echo "0")
echo "Tests Passed: $passed"
echo "Tests Failed: $failed"
```

### ❌ Undocumented Configuration

**Problem**: No context for why plugin exists or how it's used

```lua
-- BAD
return { "author/plugin" }
```

**Solution**: Always include header documentation

```lua
-- GOOD
-- Purpose: Brief description
-- Workflow: [Primary workflow]
-- Config Level: [Minimal/Basic/Comprehensive]
return { "author/plugin" }
```

______________________________________________________________________

## Best Practices Summary

### Plugin Development

1. **Always add header documentation** (Purpose, Workflow, Config Level)
2. **Use explicit imports** in lua/plugins/init.lua
3. **Check binaries before setup** (vim.fn.executable)
4. **Describe all keymaps** ({ desc = "Action name" })
5. **Follow complexity levels** (Minimal/Basic/Comprehensive)

### LSP Configuration

1. **Verify binary exists** before lspconfig setup
2. **Share on_attach** across servers for consistency
3. **Use server-specific callbacks** for custom keymaps
4. **Set filetypes explicitly** to avoid conflicts
5. **Add health checks** for LSP dependencies

### Error Handling

1. **Check file existence** before operations
2. **Use pcall with reporting** (don't silent fail)
3. **Provide actionable errors** (next steps, commands)
4. **Structure error data** (JSON for machine parsing)
5. **Suppress errors with fallbacks** (|| echo "0")

### Code Quality

1. **Extract helpers for DRY** (parameterized tasks)
2. **Single source of truth** for repeated commands
3. **Report both success and failure** (complete metrics)
4. **Document environment variables** (rationale in comments)
5. **Validate backward compatibility** when refactoring

### Testing Integration

1. **Environment variables**: LUA_PATH, TEST_PARALLEL=false
2. **Helper extraction**: Reduce duplication in test tasks
3. **Status tracking**: JSON for machine-readable results
4. **Comprehensive reporting**: Passed + failed counts
5. **File validation**: Check existence before reading

______________________________________________________________________

## Configuration Debt Reduction Pattern

**Progression**: Minimal (3 lines) → Basic (30 lines) → Comprehensive (60-100 lines)

**Prioritization**:

1. **CRITICAL**: PRIMARY workflow plugins (Zettelkasten, Prose Writing)
2. **HIGH**: Frequently used plugins with minimal config
3. **MEDIUM**: Secondary workflows (Academic, Publishing)
4. **LOW**: Experimental/rarely used plugins

**Template Usage**:

- Create plugin templates for each complexity level
- Document configuration patterns in workflow READMEs
- Standardize header format across all plugins
- Include installation commands for external dependencies

**Validation**:

- Run health checks after configuration changes
- Test keymaps work as expected
- Verify LSP attachment with :LspInfo
- Check plugin count with lazy.nvim diagnostic

______________________________________________________________________

## Critical Patterns for Documentation Sync

**Rule**: Configuration changes MUST update CLAUDE.md immediately

**Common Mismatches**:

- .mise.toml has comprehensive testing, CLAUDE.md shows legacy scripts
- Plugin changes without README updates
- LSP configuration without dependency documentation
- Environment variables without rationale

**Sync Checklist**:

1. Config change in .mise.toml → Update CLAUDE.md Testing section
2. Plugin added/removed → Update Architecture Essentials + Dependencies
3. LSP configuration → Update LSP_REFERENCE.md + CLAUDE.md
4. Environment variable → Document in .mise.toml + CLAUDE.md
5. Keybinding change → Update KEYBINDINGS_REFERENCE.md

**Prevention**: Run documentation validation after config changes
