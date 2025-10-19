# PercyBrain Troubleshooting Guide

**Quick Navigation**: [Blank Screen](#blank-screen-no-plugins-loading) | [LSP Issues](#lsp-not-starting) | [Performance](#slow-startup) | [AI Problems](#ollama-not-responding) | [Emergency Reset](#emergency-recovery)

**Audience**: New and existing PercyBrain users experiencing setup or runtime issues **Skill Level**: Basic Neovim knowledge required **Related Docs**: [Setup Guide](../setup/PERCYBRAIN_SETUP.md), [Mise Usage](../development/MISE_USAGE.md)

______________________________________________________________________

## Quick Diagnosis Flowchart

```
┌─────────────────────┐
│  What's wrong?      │
└──────┬──────────────┘
       │
       ├─ Blank screen? ────────────────────────────────> [Section 1: Blank Screen]
       │
       ├─ Plugins not loading? ────────────────────────> [Section 2: Plugin Issues]
       │
       ├─ LSP errors/no completion? ──────────────────> [Section 3: LSP Issues]
       │
       ├─ AI commands not working? ───────────────────> [Section 4: AI Integration]
       │
       ├─ Slow/hanging? ──────────────────────────────> [Section 5: Performance]
       │
       ├─ Keybinding conflicts? ──────────────────────> [Section 6: Keymaps]
       │
       └─ Other errors? ──────────────────────────────> [Section 7: General Errors]
```

______________________________________________________________________

## 1. Blank Screen / No Plugins Loading

### Symptom

- Neovim starts with blank screen
- No dashboard, no statusline, no plugins visible
- `:Lazy` shows only 3 plugins instead of 80+

### Root Cause

**Missing explicit imports in `lua/plugins/init.lua`** (Commit: `f221e35`)

When `lua/plugins/init.lua` returns a table, lazy.nvim **stops** auto-scanning subdirectories. You must explicitly import all workflow directories.

### Diagnosis

```bash
# Check plugin count (should be 80+, not 3)
nvim --headless -c "lua print(#require('lazy').plugins())" -c "qall"
```

**Expected**: `80` or higher **Problem**: `3` or fewer

### Solution

**Check `lua/plugins/init.lua` has all 14 workflow imports**:

```lua
return {
  -- Core utilities
  { "folke/neoconf.nvim", cmd = "Neoconf" },
  { "folke/neodev.nvim", opts = {} },

  -- ALL 14 WORKFLOW IMPORTS REQUIRED
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
  { import = "plugins.diagnostics" },
}
```

**Missing any import?** Plugins in that workflow won't load.

### Fix Command

```bash
# Reload Neovim config
:source ~/.config/nvim/init.lua

# Sync plugins
:Lazy sync

# Restart Neovim
:qa
nvim
```

### Prevention

- **Never** remove import lines from `lua/plugins/init.lua`
- After adding new workflows, **always** add corresponding import
- Run `:Lazy health` to verify plugin loading

______________________________________________________________________

## 2. Plugin Loading Issues

### Symptom: Duplicate Plugin Errors

**Error message**: `Plugin 'nvim-orgmode' already exists`

**Root Cause** (Commit: `af3ae06`): Multiple plugin files for the same plugin

### Diagnosis

```bash
# Find duplicate plugin files
find lua/plugins -name "*.lua" -exec basename {} \; | sort | uniq -d
```

### Solution

**Remove duplicates**:

```bash
# Example: nvim-orgmode.lua vs nvimorgmode.lua
# Keep ONE, delete the other
rm lua/plugins/org-mode/nvim-orgmode.lua  # if nvimorgmode.lua is correct version
```

**Pattern**: Check file timestamps, keep **newer** version unless you know otherwise.

### Symptom: Plugin Won't Load

**Error**: `Plugin 'telescope.nvim' not found`

### Diagnosis

```bash
# Check if plugin spec exists
find lua/plugins -name "*telescope*"

# Check lazy.nvim status
nvim -c ":Lazy health"
```

### Common Causes

1. **Nested plugin spec format** (Commit: `1bd6c91`):

   **Wrong**:

   ```lua
   return {
     { { "nvim-telescope/telescope.nvim" } }  -- Double-nested
   }
   ```

   **Right**:

   ```lua
   return {
     { "nvim-telescope/telescope.nvim", dependencies = {...} }
   }
   ```

2. **Missing dependencies**:

   ```lua
   -- Telescope REQUIRES these
   { "nvim-telescope/telescope.nvim",
     dependencies = {
       "nvim-lua/plenary.nvim",  -- REQUIRED
       "nvim-tree/nvim-web-devicons",
     }
   }
   ```

### Fix

```bash
# Update plugin spec to correct format
# Then:
:Lazy clean   # Remove broken plugins
:Lazy sync    # Reinstall
```

______________________________________________________________________

## 3. LSP Not Starting

### Symptom: IWE LSP Not Working

**Signs**:

- No Markdown link completion
- No backlink suggestions
- `:LspInfo` shows no IWE server

**Root Cause** (Commit: `b488692`): IWE not installed or wrong path

### Diagnosis

```bash
# 1. Check IWE installed
which iwe
# Should show: /home/user/.cargo/bin/iwe

# 2. Check LSP config
nvim -c ":LspInfo"
# Look for: iwe (not attached)

# 3. Check server startup manually
iwe --version
```

### Solution

**Install/Reinstall IWE**:

```bash
# Install IWE LSP
cargo install iwe

# Verify installation
iwe --version

# Restart Neovim
nvim
```

**Check LSP Configuration** (`lua/plugins/lsp/lspconfig.lua`):

```lua
-- Ensure this exists
lspconfig.iwe.setup({
  filetypes = { "markdown" },
  root_dir = function() return vim.fn.getcwd() end,
  on_attach = on_attach,
  capabilities = capabilities,
})
```

**Common typos** (Commit: `1bd6c91`):

- ❌ `keymapsset` → ✅ `keymap.set`
- ❌ `util.keymapper` → ✅ `utils.keymapper`

### Symptom: ltex-ls Not Working

**Signs**: No grammar/spell checking

**Diagnosis**:

```bash
# Check ltex-ls installed
which ltex-ls

# Check Mason
:Mason
# Find "ltex-ls" - should show installed
```

**Solution**:

```bash
# Install via Mason
:Mason
# Search for "ltex-ls"
# Press 'i' to install
```

### Symptom: LSP Crashes on Startup

**Error**: `Failed to start LSP server`

**Diagnosis**:

```bash
# Check LSP logs
:lua vim.cmd('e ' .. vim.lsp.get_log_path())
```

**Common fixes**:

1. **Config typo**: Check `lua/plugins/lsp/lspconfig.lua` for syntax errors
2. **Module path**: Ensure `require('utils.keymapper')` exists
3. **Incomplete comment**: Check for dangling `--` without text

______________________________________________________________________

## 4. Ollama Not Responding

### Symptom: AI Commands Do Nothing

**Keybindings** (`<leader>zas`, `<leader>zac`) have no effect

### Diagnosis

```bash
# 1. Check Ollama running
systemctl status ollama
# or
ps aux | grep ollama

# 2. Check model installed
ollama list
# Should show: llama3.2

# 3. Test API
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2",
  "prompt": "Hello",
  "stream": false
}'
```

### Solution

**Start Ollama service**:

```bash
# Linux (systemd)
sudo systemctl start ollama
sudo systemctl enable ollama

# macOS/manual
ollama serve
```

**Pull model**:

```bash
ollama pull llama3.2
```

**Verify in Neovim**:

```vim
:lua print(vim.fn.system("ollama list"))
```

### Symptom: AI Commands Timeout

**Error**: `Request timeout after 30s`

**Root Cause**: Model too large, hardware too slow

**Solutions**:

1. **Use smaller model**:

   ```bash
   ollama pull llama3.2:1b  # 1B parameter model (faster)
   ```

2. **Increase timeout** (`lua/percybrain/ai-assistant.lua`):

   ```lua
   timeout = 60000,  -- 60 seconds instead of 30
   ```

3. **Check hardware**: Requires 8GB+ RAM for llama3.2

______________________________________________________________________

## 5. Performance Problems

### Symptom: Slow Startup (>3 seconds)

**Diagnosis**:

```bash
# Time startup
nvim --startuptime startup.log +qall
cat startup.log | tail -n 20
```

**Look for**:

- Lines taking >100ms
- Repeated plugin loads (indicates duplicates)
- Blocking operations in `init.lua`

**Common culprits**:

1. **Duplicate plugins**: See [Section 2](#2-plugin-loading-issues)
2. **Sync plugins loading**: Change to `lazy = true`
3. **Heavy `init.lua`**: Move config to `config = function()` blocks

**Solution template**:

```lua
-- Before (slow)
return {
  "heavy-plugin/big.nvim",
  config = function()
    -- runs on startup
  end
}

-- After (fast)
return {
  "heavy-plugin/big.nvim",
  lazy = true,
  event = "VeryLazy",  -- or cmd/keys/ft
  config = function()
    -- runs when needed
  end
}
```

### Symptom: Hanging/Frozen UI

**Signs**: Neovim stops responding, CPU spikes

**Diagnosis**:

```bash
# Check for infinite loops
:messages
# Look for repeating error messages

# Check LSP status
:LspInfo
# Look for "stopped" or "exited" servers
```

**Common causes**:

1. **LSP infinite restart**: Check LSP config for circular dependencies
2. **Recursive autocmd**: Check `lua/config/autocmds.lua`
3. **File watchers**: Disable file watchers temporarily

**Quick fix**:

```vim
" Disable LSP temporarily
:LspStop

" Disable autocmds
:set eventignore=all
```

______________________________________________________________________

## 6. Keybinding Conflicts

### Symptom: `<leader>w` Does Multiple Things

**Historical issue** (Commit: `3854dd0`): ZenMode vs Window Manager conflict

**Current mappings**:

- `<leader>W` (capital) = WhichKey
- `<leader>w` (lowercase) = Window Manager
- `<leader>z` = ZenMode

### Diagnosis

```vim
" Check what <leader>w does
:nmap <leader>w

" Check for conflicts
:verbose nmap <leader>
```

### Solution

**See current keymap assignments**:

```bash
# Check keymaps.lua
grep "leader>w" lua/config/keymaps.lua

# Check window-manager.lua
grep "leader>w" lua/config/window-manager.lua
```

**Fix conflicts**: Edit `lua/config/keymaps.lua`:

```lua
-- Option 1: Change one binding
keymap.set("n", "<leader>wm", ":WhichKey<CR>")  -- w-m for "which-key menu"

-- Option 2: Use different leader for workflow
vim.g.window_leader = "<leader>w"
vim.g.zen_leader = "<leader>f"  -- f for "focus"
```

### Symptom: Zettelkasten Keys Not Working

**Keybindings**: `<leader>zn`, `<leader>zd` do nothing

**Diagnosis**:

```vim
:nmap <leader>z
" Should show: <leader>zn, <leader>zd, <leader>zi, etc.
```

**If empty**:

1. Check `lua/config/zettelkasten.lua` loaded:

   ```vim
   :lua print(package.loaded["config.zettelkasten"])
   ```

2. Check config structure exists:

   ```bash
   ls -l lua/config/zettelkasten.lua
   ```

**Fix**: Reload config:

```vim
:luafile lua/config/zettelkasten.lua
:source ~/.config/nvim/init.lua
```

______________________________________________________________________

## 7. General Configuration Errors

### Symptom: Deprecated API Warnings

**Warning**: `vim.highlight.on_yank is deprecated`

**Root Cause** (Commit: `af3ae06`): Old API usage

**Fix locations**:

```bash
# Find all deprecated APIs
rg "vim\.highlight\.on_yank" lua/

# Replace with new API
# Old: vim.highlight.on_yank(...)
# New: vim.hl.on_yank(...)
```

### Common deprecated patterns

| Old (Deprecated)                      | New (Correct)         | File                         |
| ------------------------------------- | --------------------- | ---------------------------- |
| `vim.highlight.on_yank`               | `vim.hl.on_yank`      | `lua/config/globals.lua:36`  |
| `config = {}`                         | `opts = {}`           | Plugin specs                 |
| `setup_ts_grammar()`                  | (removed)             | `nvim-orgmode.lua` (deleted) |
| `require("orgmode").setup_ts_grammar` | (use built-in parser) | Org-mode config              |

### Symptom: Files in Wrong Locations

**Error**: `module 'plugins.something' not found`

**Root Cause**: Non-plugin files in `lua/plugins/`

**Rule** (Commit: `af3ae06`):

- `lua/plugins/` = ONLY lazy.nvim plugin specs
- `lua/utils/` = Helper functions, templates
- `lua/config/` = Configuration modules
- `lua/percybrain/` = PercyBrain-specific logic

**Fix**:

```bash
# Example: writer_templates was in wrong place
# Moved from lua/plugins/writer_templates/
# To: lua/utils/writer_templates/
```

______________________________________________________________________

## 8. Testing & Validation Issues

### Symptom: Pre-commit Hooks Fail

**Error**: `luacheck: 19 warnings`

**Diagnosis**:

```bash
# Run hooks manually
pre-commit run --all-files

# Or just luacheck
luacheck lua/ tests/
```

**Common issues**:

1. **Unused variables**: Remove or prefix with `_`
2. **Undefined globals**: Add to `.luacheckrc`
3. **Line too long**: Break into multiple lines (120 char limit)

**Fix examples**:

```lua
-- Issue: Unused variable
local result = compute()  -- luacheck: warning unused variable

-- Fix: Use it or remove it
local _ = compute()  -- explicitly ignored
-- or
compute()  -- don't assign if not needed

-- Issue: Line too long (>120 chars)
keymap.set("n", "<leader>something", ":VeryLongCommandNameHere<CR>", { noremap = true, silent = true })

-- Fix: Break it up
keymap.set("n", "<leader>something", ":VeryLongCommandNameHere<CR>", {
  noremap = true,
  silent = true,
})
```

### Symptom: Tests Failing

**Error**: `44 tests passed, 0 failed` becomes failing

**Diagnosis**:

```bash
# Run test suite
./tests/run-all-unit-tests.sh

# Or with mise
mise run test
```

**Common causes** (Commit: `7a4d35d`):

1. **Markdown link format**: Changed from `[[wiki]]` to `[text](link.md)`
2. **Missing imports**: Tests require `helpers` and `mocks`
3. **Global pollution**: Tests modify `_G` without cleanup

**Test standards** (6/6 required):

1. Helper/mock imports (when used)
2. `before_each`/`after_each` state management
3. AAA pattern (Arrange, Act, Assert) comments
4. No global pollution
5. Local helper functions
6. Proper assertion patterns

______________________________________________________________________

## Emergency Recovery

### Full Reset to Defaults

**WARNING**: This deletes all customizations!

```bash
# 1. Backup current config
mv ~/.config/nvim ~/.config/nvim.backup.$(date +%Y%m%d)

# 2. Clone fresh copy
git clone https://github.com/yourusername/percybrain ~/.config/nvim
cd ~/.config/nvim

# 3. Install plugins
nvim --headless "+Lazy! sync" +qa

# 4. Test
nvim
```

### Partial Reset (Keep Data)

**Keep notes, reset config**:

```bash
# Backup notes
cp -r ~/Zettelkasten ~/Zettelkasten.backup

# Reset only Neovim config
cd ~/.config/nvim
git fetch origin
git reset --hard origin/main

# Reinstall plugins
nvim --headless "+Lazy! sync" +qa
```

### Nuclear Option (Start Over)

```bash
# Remove everything
rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim

# Reinstall from scratch
# Follow setup guide: docs/setup/PERCYBRAIN_SETUP.md
```

______________________________________________________________________

## Getting Help

### Before Asking for Help

1. **Check logs**:

   ```vim
   :messages       " Recent error messages
   :checkhealth    " System diagnostics
   :Lazy health    " Plugin diagnostics
   ```

2. **Minimal config test**:

   ```bash
   # Test with minimal config
   nvim --clean -u minimal.lua
   ```

   Where `minimal.lua`:

   ```lua
   -- Add only failing plugin to isolate issue
   vim.cmd [[set runtimepath=$VIMRUNTIME]]
   vim.cmd [[set packpath=/tmp/nvim/site]]
   ```

3. **Search issues**:

   - Check [GitHub Issues](https://github.com/yourusername/percybrain/issues)
   - Search this doc (Ctrl+F)
   - Check git history: `git log --grep="fix"`

### Create Good Bug Report

**Template**:

```markdown
**Problem**: [One sentence description]
**Expected**: [What should happen]
**Actual**: [What actually happens]

**Environment**:

- OS: [Linux/macOS/Windows]
- Neovim version: [run `nvim --version`]
- PercyBrain commit: [run `git rev-parse HEAD`]

**Steps to reproduce**:

1. Start nvim
2. Run command X
3. See error Y

**Logs**:

[Paste `:messages` output or LSP logs]
```

### Useful Debug Commands

```vim
" Plugin information
:Lazy
:Lazy health
:Lazy log

" LSP diagnostics
:LspInfo
:LspLog
:lua vim.lsp.set_log_level("debug")

" Configuration inspection
:lua print(vim.inspect(vim.g))
:lua print(vim.inspect(require("config.zettelkasten")))

" Runtime paths
:echo &runtimepath
:echo stdpath("config")
:echo stdpath("data")
```

______________________________________________________________________

## Common Error Messages Decoded

| Error Message                  | Meaning                      | Fix Section                                      |
| ------------------------------ | ---------------------------- | ------------------------------------------------ |
| `Plugin already exists`        | Duplicate plugin file        | [Section 2](#2-plugin-loading-issues)            |
| `module not found`             | Import path wrong            | [Section 7](#7-general-configuration-errors)     |
| `LSP server failed to start`   | LSP not installed/configured | [Section 3](#3-lsp-not-starting)                 |
| `on_yank deprecated`           | Old API usage                | [Section 7](#7-general-configuration-errors)     |
| `Request timeout`              | Ollama slow/not running      | [Section 4](#4-ollama-not-responding)            |
| `Only 3 plugins loaded`        | Missing imports              | [Section 1](#1-blank-screen--no-plugins-loading) |
| `checkhealth telescope: ERROR` | Missing plenary dependency   | [Section 2](#2-plugin-loading-issues)            |
| `File organization warning`    | File in wrong directory      | [Section 7](#7-general-configuration-errors)     |

______________________________________________________________________

## Related Documentation

- **Setup Guide**: [docs/setup/PERCYBRAIN_SETUP.md](../setup/PERCYBRAIN_SETUP.md) - Initial installation
- **Testing Guide**: [docs/testing/TESTING_GUIDE.md](../testing/TESTING_GUIDE.md) - Running tests
- **Pre-commit Hooks**: [docs/development/PRECOMMIT_HOOKS.md](../development/PRECOMMIT_HOOKS.md) - Quality gates
- **Mise Usage**: [docs/development/MISE_USAGE.md](../development/MISE_USAGE.md) - Task runner
- **Design Document**: [PERCYBRAIN_DESIGN.md](../../PERCYBRAIN_DESIGN.md) - Architecture

______________________________________________________________________

**Last Updated**: 2025-10-19 **Maintainer**: PercyBrain Project **Feedback**: [GitHub Issues](https://github.com/yourusername/percybrain/issues/new?labels=documentation)
