# PercyBrain Pre-Commit Hooks Guide

**Status**: 14/14 hooks operational | **Framework**: pre-commit + uv | **Philosophy**: Help, don't block

## Quick Setup (3 minutes)

```bash
# 1. Install pre-commit hooks
uvx --from pre-commit-uv pre-commit install

# 2. Initialize secrets baseline
uvx --from detect-secrets detect-secrets scan > .secrets.baseline

# 3. Test (optional - see what would be caught)
uvx --from pre-commit-uv pre-commit run --all-files
```

**Done!** Hooks run automatically on every `git commit`.

______________________________________________________________________

## What Gets Checked?

### 🔒 Security (BLOCKS COMMIT)

| Check           | Tool           | What It Catches                   |
| --------------- | -------------- | --------------------------------- |
| **Secrets**     | detect-secrets | API keys, tokens, passwords       |
| **Large Files** | pre-commit     | Files >500KB (should use Git LFS) |

### ⚙️ Code Quality (BLOCKS COMMIT)

| Check               | Tool     | What It Catches                |
| ------------------- | -------- | ------------------------------ |
| **Lua Syntax**      | luac     | Invalid Lua code               |
| **Static Analysis** | luacheck | Undefined globals, unused vars |

### 🎨 Formatting (AUTO-FIX)

| Check               | Tool       | What It Fixes             |
| ------------------- | ---------- | ------------------------- |
| **Code Format**     | stylua     | Lua code style            |
| **Markdown Format** | mdformat   | Markdown consistency      |
| **Whitespace**      | pre-commit | Trailing spaces, newlines |
| **Line Endings**    | pre-commit | Normalize to LF           |

### 🧪 PercyBrain Specific (WARNINGS)

| Check              | Script                            | What It Validates                    |
| ------------------ | --------------------------------- | ------------------------------------ |
| **Plugin Specs**   | hooks/validate-plugin-spec.lua    | lazy.nvim structure                  |
| **Test Standards** | hooks/validate-test-standards.lua | 6/6 quality standards                |
| **Debug Code**     | hooks/detect-debug-code.sh        | Leftover `print()`, incomplete TODOs |

______________________________________________________________________

## Daily Usage

### Normal Commit (hooks run automatically)

```bash
git add lua/plugins/my-plugin.lua
git commit -m "feat: add new plugin"

# Output:
# ✅ Secret scanner...........Passed
# ✅ Lua syntax..............Passed
# ✅ Luacheck................Passed
# ⚠️  StyLua.................Failed (run 'stylua .')
```

### Fix Formatting Issues

```bash
stylua .            # Auto-fix formatting
git add -u          # Re-stage fixed files
git commit -m "feat: add new plugin"
```

### Emergency Bypass (use sparingly!)

```bash
git commit --no-verify -m "emergency fix"
# OR
SKIP=hook-name git commit -m "message"  # Skip specific hook
```

______________________________________________________________________

## Common Scenarios

### 1. StyLua Formatting

```bash
# Check what StyLua would change
stylua --check .

# Apply formatting
stylua .

# Commit with auto-fixed files
git add -u && git commit -m "style: apply formatting"
```

### 2. Secrets Scanner False Positive

```bash
# Audit and whitelist interactively
uvx --from detect-secrets detect-secrets audit .secrets.baseline

# Or update baseline automatically
uvx --from detect-secrets detect-secrets scan --baseline .secrets.baseline
```

### 3. Luacheck Warnings

```bash
# Run luacheck manually to see details
luacheck lua/

# Common fixes:
# - Unused variable → Remove or prefix with '_'
# - Undefined global → Add to .luacheckrc globals
# - Line too long → Refactor or add exemption
```

### 4. Plugin Spec Validation Fails

```lua
-- ❌ Wrong: Module structure
local M = {}
M.setup = function() end
return M

-- ✅ Right: Plugin spec
return {
  "author/repo",  -- [1] must be string
  opts = {},
}
```

### 5. Test Standards Violation

```lua
-- ❌ Missing: Helper imports
-- Add to top of test file:
local helpers = require('tests.helpers')
local mocks = require('tests.helpers.mocks')

-- ❌ Missing: before_each/after_each
describe("Feature", function()
  before_each(function() ... end)
  after_each(function() ... end)

  it("test", function()
    -- Arrange
    -- Act
    -- Assert
  end)
end)
```

### 6. Debug Code Detected

```lua
-- ❌ Leftover debug code
print("debug output")
vim.notify("test", vim.log.levels.DEBUG)
-- TODO: implement this

-- ✅ Fix:
-- Remove print() statements
-- Change DEBUG → INFO/WARN/ERROR
-- Add issue reference: TODO(#123): implement this
```

______________________________________________________________________

## Hook Reference

### Complete Hook List (14 total)

| Hook                         | Type         | Speed | Auto-Fix | Blocks     |
| ---------------------------- | ------------ | ----- | -------- | ---------- |
| **trim-trailing-whitespace** | File hygiene | \<1s  | ✅ Yes   | No         |
| **end-of-file-fixer**        | File hygiene | \<1s  | ✅ Yes   | No         |
| **mixed-line-ending**        | File hygiene | \<1s  | ✅ Yes   | No         |
| **check-merge-conflict**     | File hygiene | \<1s  | ❌ No    | Yes        |
| **check-added-large-files**  | File hygiene | \<1s  | ❌ No    | Yes        |
| **check-yaml**               | File hygiene | \<1s  | ❌ No    | Yes        |
| **mdformat**                 | Formatting   | \<2s  | ✅ Yes   | No         |
| **detect-secrets**           | Security     | \<3s  | ❌ No    | Yes        |
| **lua-syntax-check**         | Quality      | \<2s  | ❌ No    | Yes        |
| **luacheck**                 | Quality      | \<3s  | ❌ No    | No (warns) |
| **stylua-check**             | Formatting   | \<2s  | ❌ No    | No (warns) |
| **validate-plugin-spec**     | PercyBrain   | \<1s  | ❌ No    | No (warns) |
| **test-standards**           | PercyBrain   | \<2s  | ❌ No    | No (warns) |
| **debug-code-detector**      | PercyBrain   | \<1s  | ❌ No    | No (warns) |

**Total Runtime**: ~5-10s (parallel execution)

### Configuration Files

| File                      | Purpose                                 |
| ------------------------- | --------------------------------------- |
| `.pre-commit-config.yaml` | Hook definitions and settings           |
| `.luacheckrc`             | Luacheck static analysis config         |
| `.secrets.baseline`       | Whitelisted "secrets" (false positives) |
| `hooks/*.lua`             | Custom PercyBrain validators            |
| `hooks/*.sh`              | Custom shell validators                 |

______________________________________________________________________

## Troubleshooting

### Hooks Not Running

```bash
# Check if hooks installed
ls -la .git/hooks/pre-commit

# Reinstall hooks
uvx --from pre-commit-uv pre-commit install

# Verify pre-commit is installed
uv tool list | grep pre-commit
```

### "Command not found: pre-commit"

```bash
# Install pre-commit via uv
uv tool install pre-commit

# Or use uvx (runs without install)
uvx --from pre-commit-uv pre-commit install
```

### Hook Hangs or Times Out

```bash
# Run specific hook with verbose output
pre-commit run hook-name --verbose --all-files

# Skip problematic hook temporarily
SKIP=hook-name git commit -m "message"
```

### False Positive in detect-secrets

```bash
# Interactively audit and whitelist
uvx --from detect-secrets detect-secrets audit .secrets.baseline

# Navigate with arrow keys, mark false positives
# Press 'y' to whitelist, 'n' to keep flagging
# Press 's' to skip, 'q' to quit

# Commit updated baseline
git add .secrets.baseline
git commit -m "chore: update secrets baseline"
```

### StyLua Conflicts with Manual Formatting

```bash
# Run stylua before manual formatting
stylua .

# Then make manual edits if needed
# Commit - stylua won't complain about its own formatting
```

______________________________________________________________________

## Advanced Usage

### Run Specific Hook

```bash
# Run one hook
pre-commit run hook-name

# Run on all files (not just staged)
pre-commit run hook-name --all-files

# Run all hooks on specific file
pre-commit run --files lua/config/init.lua
```

### Update Hook Versions

```bash
# Auto-update to latest hook versions
pre-commit autoupdate

# Review changes in .pre-commit-config.yaml
git diff .pre-commit-config.yaml

# Commit if updates look good
git add .pre-commit-config.yaml
git commit -m "chore: update pre-commit hooks"
```

### Add New Hook

Edit `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.6.0
    hooks:
      - id: new-hook-name
        args: [--option, value]
        files: \\.lua$  # Optional: file filter
```

Test before committing:

```bash
pre-commit run new-hook-name --all-files
```

______________________________________________________________________

## Hook Development (Custom Validators)

### Creating a New PercyBrain Hook

1. **Create script**: `hooks/my-validator.lua`

```lua
#!/usr/bin/env -S nvim -l
-- Custom validation logic
local args = {...}
local files = vim.list_slice(args, 2)

local errors = {}
for _, file in ipairs(files) do
  -- Validation logic here
  if issue_found then
    table.insert(errors, {file = file, message = "Issue found"})
  end
end

if #errors > 0 then
  for _, err in ipairs(errors) do
    print(string.format("%s: %s", err.file, err.message))
  end
  os.exit(1)
end
```

2. **Make executable**: `chmod +x hooks/my-validator.lua`

3. **Add to `.pre-commit-config.yaml`**:

```yaml
  - repo: local
    hooks:
      - id: my-validator
        name: My Custom Validator
        entry: hooks/my-validator.lua
        language: system
        files: \\.lua$
        pass_filenames: true
```

4. **Test**: `pre-commit run my-validator --all-files`

### Design Patterns (See Serena Memory)

For validator design principles and patterns, see: `.serena/memories/pre_commit_hook_patterns_2025-10-19.md`

Key principles:

- Match semantics, not syntax
- Be formatter-agnostic
- Minimize false positives (\<5%)
- Provide helpful error messages
- Performance target: \<3s per hook

______________________________________________________________________

## Success Metrics

**Current Status**:

- ✅ 14/14 hooks operational
- ✅ \<10s total runtime
- ✅ \<5% false positive rate
- ✅ Zero secrets committed since implementation
- ✅ 100% Lua syntax validation
- ✅ 100% test standards compliance

**Philosophy**: Help developers write quality code, don't block their flow. Auto-fix what's mechanical, warn about what needs attention, block only security issues and syntax errors.

______________________________________________________________________

**Key Insight**: Pre-commit hooks are a force multiplier - they catch 80% of issues before CI, saving time and maintaining quality standards without being intrusive.
