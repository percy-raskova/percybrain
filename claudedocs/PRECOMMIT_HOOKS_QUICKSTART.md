# Pre-Commit Hooks Quick Start Guide

**TL;DR**: Simple, robust git hooks for PercyBrain code quality checks using industry-standard tools.

______________________________________________________________________

## 3-Minute Setup

```bash
# 1. Install pre-commit hooks
uvx --from pre-commit-uv pre-commit install

# 2. Initialize secrets baseline
uvx --from detect-secrets detect-secrets scan > .secrets.baseline

# 3. Test on all files (optional - see what would be caught)
uvx --from pre-commit-uv pre-commit run --all-files
```

**Done!** Hooks now run automatically on every `git commit`.

______________________________________________________________________

## What Gets Checked?

### Security (BLOCKS COMMIT)

- ❌ **Secrets**: API keys, tokens, passwords detected by Yelp's detect-secrets
- ❌ **Large files**: Files >500KB (should use Git LFS)

### Code Quality (BLOCKS COMMIT)

- ❌ **Lua syntax**: Invalid Lua code (`luac -p`)
- ❌ **Undefined globals**: Luacheck static analysis

### Formatting (WARNINGS)

- ⚠️ **StyLua**: Code formatting issues (run `stylua .` to fix)
- ⚠️ **Whitespace**: Trailing whitespace, line endings

### PercyBrain Specific (WARNINGS)

- ⚠️ **Plugin specs**: Invalid lazy.nvim structures
- ⚠️ **Test standards**: 6/6 quality standards compliance
- ⚠️ **Debug code**: Leftover `print()`, TODO without #issue

______________________________________________________________________

## Daily Usage

### Normal Commit (hooks run automatically)

```bash
git add lua/plugins/my-plugin.lua
git commit -m "feat: add new plugin"

# Output:
# ✅ Secret scanner...........Passed
# ✅ Lua syntax..............Passed
# ⚠️  StyLua.................Failed (run 'stylua .')
```

### Fix Formatting

```bash
stylua .            # Auto-fix formatting
git add -u          # Re-stage fixed files
git commit -m "feat: add new plugin"
```

### Emergency Bypass (use sparingly!)

```bash
git commit --no-verify -m "emergency fix"
```

______________________________________________________________________

## Common Scenarios

### StyLua Formatting Issues

```bash
# Check what StyLua would change
stylua --check .

# Apply formatting
stylua .

# Commit
git add -u && git commit -m "style: apply formatting"
```

### Secrets Scanner False Positive

```bash
# Add to whitelist (interactive)
uvx --from detect-secrets detect-secrets audit .secrets.baseline

# Or update baseline automatically
uvx --from detect-secrets detect-secrets scan --baseline .secrets.baseline

# Commit updated baseline
git add .secrets.baseline
git commit -m "chore: update secrets baseline"
```

### Luacheck Warnings

```bash
# See detailed error
luacheck lua/plugins/my-plugin.lua

# Fix or add to .luacheckrc:
# ignore = { "211/_.*" }  -- Ignore unused vars starting with _
```

______________________________________________________________________

## Hook Management

```bash
# Run hooks manually (without committing)
uvx --from pre-commit-uv pre-commit run

# Run on all files
uvx --from pre-commit-uv pre-commit run --all-files

# Run specific hook
uvx --from pre-commit-uv pre-commit run luacheck

# Update hook versions
uvx --from pre-commit-uv pre-commit autoupdate

# Temporarily disable hooks
uvx --from pre-commit-uv pre-commit uninstall
```

______________________________________________________________________

## Tools Used

| Tool               | Purpose        | Why This Tool                             |
| ------------------ | -------------- | ----------------------------------------- |
| **pre-commit**     | Hook manager   | Industry standard, 10K+ stars             |
| **detect-secrets** | Secret scanner | Yelp-maintained, low false positives      |
| **stylua**         | Lua formatter  | Official formatter, community standard    |
| **luacheck**       | Lua linter     | De facto standard (already in PercyBrain) |

**Philosophy**: Use proven tools, add custom logic only for PercyBrain-specific needs.

______________________________________________________________________

## Troubleshooting

**"Command not found" errors**:

```bash
# Install missing tools
cargo install stylua
# or
brew install stylua
```

**Hooks are slow**:

```bash
# First run is slow (caches results)
# Only checks changed files automatically
# For faster manual runs:
uvx --from pre-commit-uv pre-commit run luacheck  # Just one hook
```

**Want to skip a hook once**:

```bash
SKIP=stylua-check git commit -m "quick fix"
```

______________________________________________________________________

## Full Documentation

See `PRECOMMIT_HOOKS_DESIGN.md` for complete design, custom hook implementations, and troubleshooting guide.

______________________________________________________________________

## Summary

✅ **Simple**: 3-command setup with `uvx` ✅ **Robust**: Industry-standard tools (detect-secrets, stylua, luacheck) ✅ **Helpful**: Clear errors with actionable fixes ✅ **Fast**: Only checks staged files, caches results ✅ **Configurable**: Easy to enable/disable individual hooks

**Next Steps**: See full design document for custom hook implementations and advanced configuration! 🎯
