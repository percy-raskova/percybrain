# OVIWrite Testing & CI/CD Quick Start Guide

**Purpose**: Get started with OVIWrite's validation system in 5 minutes

## For Contributors (First-Time Setup)

### 1. Install Git Hooks & Scripts

```bash
cd /path/to/OVIWrite
./scripts/setup-dev-env.sh
```

This installs:
- Pre-commit hook (validates before each commit)
- Pre-push hook (validates before each push)
- Makes all scripts executable
- Creates test directories

### 2. Verify Installation

```bash
# Quick validation (Layer 1-2, ~10 seconds)
./scripts/validate.sh

# Should output: ✅ Layer 1-2 validation passed
```

### 3. Make Your First Commit

```bash
# Edit a file
nvim lua/plugins/my-plugin.lua

# Stage and commit (validation runs automatically)
git add lua/plugins/my-plugin.lua
git commit -m "feat: add my plugin"

# Validation runs automatically via git hook
# ✅ Pass: Commit succeeds
# ❌ Fail: Fix errors shown, retry commit
```

## Common Commands

### Validation Commands

```bash
# Quick validation (Layer 1-2, ~5 seconds)
./scripts/validate.sh

# Full validation (Layer 1-4, ~2 minutes)
# Run before pushing to ensure CI will pass
./scripts/validate.sh --full

# Run specific check
./scripts/validate.sh --check duplicates
./scripts/validate.sh --check deprecated-apis
./scripts/validate.sh --check startup
./scripts/validate.sh --check health
./scripts/validate.sh --check docs
```

### Skip Validation (Use Sparingly)

```bash
# Skip pre-commit hook
SKIP_VALIDATION=1 git commit -m "WIP: experimental"

# Skip pre-push hook
SKIP_VALIDATION=1 git push

# Or use git's built-in skip
git commit --no-verify
git push --no-verify
```

**Note**: CI will still run validation. Skip is only for local development.

### Documentation Commands

```bash
# Check documentation sync
./scripts/validate.sh --check docs

# Generate keymap table for CLAUDE.md
./scripts/extract-keymaps.lua
```

## Understanding Validation Layers

OVIWrite uses a **4-layer validation pyramid**:

### Layer 1: Static (Fast, ~5s)
✅ What it checks:
- Lua syntax errors
- Duplicate plugin files
- Deprecated API usage
- File organization

✅ When it runs:
- Pre-commit git hook
- CI on every push

### Layer 2: Structural (~10s)
✅ What it checks:
- Plugin spec structure
- lazy.nvim field validation
- Keymap conflicts
- Circular dependencies

✅ When it runs:
- Pre-commit git hook
- CI on every push

### Layer 3: Dynamic (~60s)
✅ What it checks:
- Neovim startup without errors
- `:checkhealth` passes
- Plugin loading

✅ When it runs:
- Pre-push git hook
- CI on PR to main

### Layer 4: Documentation (~30s)
✅ What it checks:
- Plugin list matches CLAUDE.md
- Keyboard shortcuts current

✅ When it runs:
- CI only (warnings, doesn't block)

## Common Validation Errors

### Error: "Duplicate plugin files detected"

```bash
# Example: nvim-tree.lua and nvimtree.lua
# Fix: Remove one file
rm lua/plugins/nvimtree.lua

# Verify fix
./scripts/validate.sh --check duplicates
```

### Error: "Deprecated API: vim.highlight.on_yank"

```bash
# Find usage
./scripts/validate.sh --check deprecated-apis

# Fix: Replace in your code
# Old: vim.highlight.on_yank
# New: vim.hl.on_yank
```

### Error: "Plugin spec must return table with [1] = string"

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

### Error: "Startup validation failed"

```bash
# Test startup manually
nvim --headless -c "lua require('config')" -c "quit"

# Or use validation script
./scripts/validate.sh --check startup

# Check for syntax errors in init.lua or config files
```

## CI/CD Workflows

### Quick Validation (Every Push)

Runs: Layer 1-2
Time: ~30 seconds
Triggers: Every push, every PR

### Full Validation (PR to Main)

Runs: Layer 1-4
Time: ~3 minutes per job
Matrix: Linux/macOS/Windows × Neovim stable/nightly
Triggers: PR to main branch, weekly schedule

## Troubleshooting

### Validation Passes Locally But Fails in CI

```bash
# Run the same validation as CI
./scripts/validate.sh --full

# Check Neovim version
nvim --version

# CI tests both stable and nightly
```

### Git Hook Doesn't Run

```bash
# Check if hook is installed
ls -la .git/hooks/pre-commit

# Reinstall hooks
./scripts/setup-dev-env.sh

# Make executable
chmod +x .git/hooks/pre-commit
```

### "Command not found" Errors

```bash
# Make scripts executable
chmod +x scripts/*.sh scripts/*.lua

# Or reinstall
./scripts/setup-dev-env.sh
```

## Getting Help

- **Full documentation**: See [TESTING_STRATEGY.md](TESTING_STRATEGY.md)
- **Contributing guide**: See [CONTRIBUTING.md](../CONTRIBUTING.md)
- **Migration plan**: See [MIGRATION_PLAN.md](MIGRATION_PLAN.md)
- **Issues**: [GitHub Issues](https://github.com/MiragianCycle/OVIWrite/issues)

## Quick Reference Card

```
┌─────────────────────────────────────────────────────────────┐
│ OVIWrite Validation Quick Reference                        │
├─────────────────────────────────────────────────────────────┤
│ SETUP (once)                                                │
│   ./scripts/setup-dev-env.sh                                │
│                                                               │
│ VALIDATE (before commit)                                    │
│   ./scripts/validate.sh                                     │
│                                                               │
│ VALIDATE (before push)                                      │
│   ./scripts/validate.sh --full                              │
│                                                               │
│ SPECIFIC CHECKS                                             │
│   ./scripts/validate.sh --check duplicates                  │
│   ./scripts/validate.sh --check startup                     │
│   ./scripts/validate.sh --check docs                        │
│                                                               │
│ SKIP VALIDATION (emergencies only)                         │
│   SKIP_VALIDATION=1 git commit                              │
│   SKIP_VALIDATION=1 git push                                │
│                                                               │
│ HELP                                                        │
│   ./scripts/validate.sh --help                              │
└─────────────────────────────────────────────────────────────┘
```

---

**That's it!** You're ready to contribute to OVIWrite with confidence. 🎉
