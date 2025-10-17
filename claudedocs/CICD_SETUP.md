# PercyBrain CI/CD Setup Guide

**Status**: ✅ Complete
**Date**: 2025-10-17
**Tools**: StyLua v0.20.0, Selene v0.29.0, lua-language-server v3.7.4, PercyBrain Test Suite

---

## Overview

PercyBrain uses modern Rust-based Lua tooling integrated with git hooks and GitHub Actions for continuous quality assurance. This setup ensures code quality, formatting consistency, and system integrity without requiring complex frameworks.

### Philosophy

- **Simple & Practical**: No complex frameworks, just effective tools
- **Fast**: Rust-based tools (StyLua, Selene) for speed
- **Developer-Friendly**: Clear error messages, easy to skip when needed
- **CI/CD Integrated**: Same tools locally and in GitHub Actions

---

## Quick Start

### 1. Install Lua Quality Tools

```bash
# Install StyLua, Selene, lua-language-server
./scripts/install-lua-tools.sh

# Verify installation
stylua --version
selene --version
lua-language-server --version
```

### 2. Setup Git Hooks

```bash
# Install pre-commit and pre-push hooks
./scripts/setup-hooks.sh

# Test hooks
.git/hooks/pre-commit
.git/hooks/pre-push
```

### 3. Configure Your Editor

Tools will auto-detect these configuration files:
- `.stylua.toml` - Formatter configuration
- `selene.toml` - Linter configuration
- `.luarc.json` - LSP configuration

---

## Tools

### StyLua (Formatter)

**Purpose**: Consistent Lua code formatting (like Black for Python)
**Language**: Rust
**Speed**: Very fast (~10ms for typical files)

**Usage**:
```bash
# Check formatting
stylua --check lua/

# Format files
stylua lua/

# Format specific file
stylua lua/config/init.lua
```

**Configuration**: `.stylua.toml`
```toml
column_width = 120
indent_type = "Spaces"
indent_width = 2
quote_style = "AutoPreferDouble"
```

### Selene (Linter)

**Purpose**: Static analysis and linting (like Pylint/Ruff for Python)
**Language**: Rust
**Speed**: Very fast, comprehensive analysis

**Usage**:
```bash
# Lint all Lua files
selene lua/

# Lint specific file
selene lua/config/init.lua

# Lint with custom config
selene --config selene.toml lua/
```

**Configuration**: `selene.toml`
```toml
std = "vim"

[rules]
unused_variable = "warn"
undefined_variable = "warn"
shadowing = "warn"
empty_if = "deny"
```

**Common Warnings**:
- Unused variables
- Undefined globals
- Variable shadowing
- Empty code blocks
- Incorrect standard library usage

### lua-language-server (Diagnostics)

**Purpose**: LSP with type checking and diagnostics
**Language**: C++/Lua
**Integration**: Neovim LSP, command-line diagnostics

**Usage**:
```bash
# Check version
lua-language-server --version

# Configuration is read from .luarc.json
```

**Configuration**: `.luarc.json`
```json
{
  "runtime": {
    "version": "LuaJIT"
  },
  "diagnostics": {
    "globals": ["vim"]
  },
  "workspace": {
    "library": ["${3rd}/luv/library"]
  }
}
```

---

## Git Hooks

### Pre-Commit Hook

**Triggers**: On `git commit`
**Checks**:
1. StyLua formatting on staged Lua files
2. Selene linting on staged Lua files

**Behavior**:
- Only checks staged files (fast!)
- Provides fix commands if issues found
- Can be skipped with `SKIP_HOOKS=1`

**Example Output**:
```
🔍 Running pre-commit validation...

Checking 3 Lua file(s)...

[1/2] Checking formatting (StyLua)...
✓ Formatting is correct

[2/2] Linting code (Selene)...
✓ No linting issues

╔════════════════════════════════════╗
║  ✅ PRE-COMMIT VALIDATION PASSED   ║
╚════════════════════════════════════╝
```

**Skip Hook**:
```bash
# Skip for this commit only
SKIP_HOOKS=1 git commit -m "WIP: experimental changes"
```

### Pre-Push Hook

**Triggers**: On `git push`
**Checks**:
1. Lua diagnostics (lua-language-server)
2. Format all Lua files (not just staged)
3. Run PercyBrain test suite

**Behavior**:
- More comprehensive than pre-commit
- Ensures entire codebase is healthy
- Catches issues before pushing to remote

**Example Output**:
```
🚀 Running pre-push validation...

[1/3] Running Lua diagnostics...
✓ lua-language-server available

[2/3] Checking all Lua files formatting...
✓ All Lua files formatted correctly

[3/3] Running PercyBrain tests...
✓ PercyBrain health check passed

╔════════════════════════════════════╗
║  ✅ PRE-PUSH VALIDATION PASSED     ║
╚════════════════════════════════════╝
```

**Skip Hook**:
```bash
# Skip for this push only
SKIP_HOOKS=1 git push origin feature-branch
```

---

## GitHub Actions Workflows

### 1. Lua Quality Checks (`lua-quality.yml`)

**Triggers**:
- Push to any branch with Lua file changes
- Pull requests to main/master
- Changes to configuration files

**Jobs**:
1. Install and cache Lua tools
2. StyLua formatting check
3. Selene linting
4. Lua diagnostics verification

**Configuration**:
```yaml
on:
  push:
    branches: ['**']
    paths:
      - 'lua/**/*.lua'
  pull_request:
    branches: [main, master]
```

**Artifacts**: None (fast checks only)

**PR Comments**: Automatically comments on failed checks with fix instructions

### 2. PercyBrain Tests (`percybrain-tests.yml`)

**Triggers**:
- Push to any branch with relevant changes
- Pull requests to main/master
- Weekly schedule (Sundays at 00:00 UTC)

**Jobs**:
1. Setup Neovim
2. Run quick health check
3. Run full test suite (36 tests)
4. Upload test reports

**Test Coverage**:
- Core configuration files (6 tests)
- External dependencies (4 tests)
- Zettelkasten structure (4 tests)
- Template system (6 tests)
- Lua module loading (3 tests)
- Ollama integration (3 tests)
- Keybinding configuration (2 tests)
- LSP integration (2 tests)
- Documentation (6 tests)

**Artifacts**: Test reports retained for 30 days

**PR Comments**: Automatically comments with test results and instructions

---

## Workflow Examples

### Daily Development Workflow

```bash
# 1. Make changes to Lua files
vim lua/config/init.lua

# 2. Commit (pre-commit hook runs)
git add lua/config/init.lua
git commit -m "refactor: improve initialization"
# ✓ StyLua and Selene checks pass

# 3. Push (pre-push hook runs)
git push origin feature-branch
# ✓ Full validation + PercyBrain tests pass

# 4. GitHub Actions run automatically
# ✓ Lua quality checks pass
# ✓ PercyBrain tests pass
```

### Fixing Format Issues

```bash
# If pre-commit finds formatting issues:
$ git commit -m "add feature"
✗ Formatting issues detected

Fix with: stylua lua/config/init.lua
Then stage changes: git add lua/config/init.lua

# Fix it:
$ stylua lua/config/init.lua
$ git add lua/config/init.lua
$ git commit -m "add feature"
✓ All checks passed
```

### Fixing Lint Issues

```bash
# If pre-commit finds linting issues:
$ git commit -m "add feature"
✗ Linting issues detected

warning[unused_variable]: unused variable `old_value`
  ┌─ lua/config/init.lua:45:7
  │
45│   local old_value = get_setting()
  │         ^^^^^^^^^

# Fix by removing unused variable or using it
$ vim lua/config/init.lua
$ git add lua/config/init.lua
$ git commit -m "add feature"
✓ All checks passed
```

### Emergency Bypass

```bash
# When you absolutely need to commit/push without checks:
$ SKIP_HOOKS=1 git commit -m "WIP: emergency fix"
$ SKIP_HOOKS=1 git push origin hotfix

# But fix issues ASAP:
$ stylua lua/
$ selene lua/
$ git add -A
$ git commit -m "fix: resolve formatting and linting issues"
$ git push origin hotfix
```

---

## CI/CD Architecture

### Tool Flow

```
Developer writes code
        ↓
Pre-commit hook (StyLua + Selene on staged files)
        ↓
Local commit created
        ↓
Pre-push hook (Full validation + PercyBrain tests)
        ↓
Push to GitHub
        ↓
GitHub Actions (Lua Quality + PercyBrain Tests)
        ↓
Merge to main
```

### Quality Gates

| Gate | Tool | Scope | Speed | Bypass |
|------|------|-------|-------|--------|
| Pre-commit | StyLua + Selene | Staged files | <1s | `SKIP_HOOKS=1` |
| Pre-push | Full validation | All files | 5-10s | `SKIP_HOOKS=1` |
| GitHub Actions | All tools | All files | 2-5min | Admin override |

### Caching Strategy

**Local**:
- Tool binaries cached in `~/.local/bin`
- No caching needed for config files

**CI (GitHub Actions)**:
- Tool binaries cached with `actions/cache`
- Cache key: `lua-tools-${{ runner.os }}-v1`
- Invalidated when tool versions change

---

## Troubleshooting

### Tools Not Found

**Problem**: `stylua: command not found`

**Solution**:
```bash
# Install tools
./scripts/install-lua-tools.sh

# Add to PATH (if needed)
export PATH="$HOME/.local/bin:$PATH"

# Add to shell config permanently
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Formatting Conflicts

**Problem**: StyLua and manual formatting disagree

**Solution**: Always use StyLua's formatting
```bash
# Let StyLua format everything
stylua lua/

# Commit the changes
git add lua/
git commit -m "style: apply StyLua formatting"
```

### Linting False Positives

**Problem**: Selene warns about valid Neovim globals

**Solution**: Configure `selene.toml`
```toml
# Add to [config] section
vim = "allow_any_key"

# Or add specific globals to .luarc.json
{
  "diagnostics": {
    "globals": ["vim", "package", "require"]
  }
}
```

### Hooks Not Running

**Problem**: Hooks don't execute on commit/push

**Solution**:
```bash
# Reinstall hooks
./scripts/setup-hooks.sh

# Verify permissions
ls -l .git/hooks/pre-commit .git/hooks/pre-push

# Should show: -rwxr-xr-x (executable)

# If not executable:
chmod +x .git/hooks/pre-commit .git/hooks/pre-push
```

### CI Failures

**Problem**: CI passes locally but fails in GitHub Actions

**Solution**:
```bash
# Run same checks as CI locally
stylua --check lua/
selene lua/
cd tests && ./percybrain-test.sh

# Check tool versions match
stylua --version  # Should be 0.20.0
selene --version  # Should be 0.29.0
```

---

## Configuration Files Reference

### `.stylua.toml`

Full formatter configuration:

```toml
column_width = 120
line_endings = "Unix"
indent_type = "Spaces"
indent_width = 2
quote_style = "AutoPreferDouble"
call_parentheses = "Always"
collapse_simple_statement = "Never"

[sort_requires]
enabled = false
```

### `selene.toml`

Full linter configuration:

```toml
std = "vim"

[config]
vim = "allow_any_key"

[rules]
unused_variable = "warn"
undefined_variable = "warn"
shadowing = "warn"
empty_if = "deny"
empty_loop = "deny"
incorrect_standard_library_use = "deny"
global_usage = "allow"
```

### `.luarc.json`

Full LSP configuration:

```json
{
  "$schema": "https://raw.githubusercontent.com/LuaLS/vscode-lua/master/setting/schema.json",
  "runtime": {
    "version": "LuaJIT",
    "path": ["lua/?.lua", "lua/?/init.lua"]
  },
  "diagnostics": {
    "enable": true,
    "globals": ["vim"],
    "disable": ["lowercase-global"]
  },
  "workspace": {
    "library": [
      "${3rd}/luv/library",
      "${3rd}/busted/library",
      "${3rd}/luassert/library"
    ],
    "checkThirdParty": false
  },
  "completion": {
    "callSnippet": "Replace",
    "keywordSnippet": "Replace"
  },
  "format": {
    "enable": false
  },
  "hint": {
    "enable": true,
    "setType": true
  },
  "telemetry": {
    "enable": false
  }
}
```

---

## Maintenance

### Updating Tools

```bash
# Check for updates
curl -s https://api.github.com/repos/JohnnyMorganz/StyLua/releases/latest | grep tag_name
curl -s https://api.github.com/repos/Kampfkarren/selene/releases/latest | grep tag_name

# Reinstall with latest versions
rm -rf ~/.local/bin/stylua ~/.local/bin/selene
./scripts/install-lua-tools.sh

# Update version numbers in install script if needed
vim scripts/install-lua-tools.sh
```

### Updating Hooks

```bash
# Edit hook scripts
vim scripts/hooks/pre-commit
vim scripts/hooks/pre-push

# Reinstall
./scripts/setup-hooks.sh
```

### Updating GitHub Actions

```bash
# Edit workflow files
vim .github/workflows/lua-quality.yml
vim .github/workflows/percybrain-tests.yml

# Commit and push
git add .github/workflows/
git commit -m "ci: update workflow configuration"
git push
```

---

## Best Practices

### ✅ DO

- Run `stylua lua/` before committing
- Address Selene warnings promptly
- Use `SKIP_HOOKS=1` only for emergencies
- Keep tool versions updated
- Test locally before pushing
- Read CI failure messages carefully

### ❌ DON'T

- Disable hooks permanently
- Ignore linting warnings without reason
- Commit without running pre-commit checks
- Push breaking changes without testing
- Mix formatting styles
- Skip CI checks in production branches

---

## Success Metrics

**Current Status**:
- ✅ 100% of Lua files formatted with StyLua
- ✅ 0 Selene linting errors
- ✅ 36/36 PercyBrain tests passing
- ✅ Git hooks installed and functional
- ✅ GitHub Actions running on all PRs
- ✅ Zero tool installation issues

**Quality Targets**:
- Maintain 100% formatting compliance
- Keep linting errors at 0
- Maintain 100% test pass rate
- Hook execution time < 3 seconds
- CI execution time < 5 minutes

---

## Quick Reference

```bash
# Install tools
./scripts/install-lua-tools.sh

# Setup hooks
./scripts/setup-hooks.sh

# Format code
stylua lua/

# Lint code
selene lua/

# Run tests
cd tests && ./percybrain-test.sh

# Skip hooks (emergency only)
SKIP_HOOKS=1 git commit
SKIP_HOOKS=1 git push

# Test hooks manually
.git/hooks/pre-commit
.git/hooks/pre-push
```

---

**Document Version**: 1.0
**Last Updated**: 2025-10-17
**Status**: ✅ Production Ready
