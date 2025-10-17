# PercyBrain Test Suite

**Philosophy**: Simple, pragmatic tests that ensure code works — not enterprise compliance theater.

## Quick Start

```bash
# Run the simple test suite
./simple-test.sh

# That's it!
```

## What Gets Tested

### 1. Lua Syntax Validation
- **All 75 Lua files** (67 plugins + 8 core config files)
- Uses `luac` or Neovim headless mode
- Catches syntax errors that would break Neovim

### 2. Code Formatting (StyLua)
- Ensures consistent code style across **all plugins**
- Checks double quotes, indentation, line width
- Auto-fixable: `stylua lua/`

### 3. Code Quality (Selene)
- Lints **all Lua files** for common mistakes
- Allows warnings (they won't block commits)
- Only errors will fail the test

### 4. Core Config Loading
- Verifies `init.lua` and core modules load without errors
- Ensures basic Neovim functionality works

### 5. Critical Files Exist
- Checks that essential config files are present
- Catches missing files that would break the system

## What We DON'T Test

❌ **External dependencies** (iwe, sembr, ollama versions)
❌ **Directory structures** (Zettelkasten folders)
❌ **Template systems** (template file validation)
❌ **Running processes** (ollama service checks)
❌ **API endpoints** (HTTP requests)
❌ **Keybinding conflicts** (complex validation)
❌ **LSP integration** (editor features)
❌ **Documentation** (file existence checks)

**Why?** These are either:
- User-specific configurations
- Optional features
- Runtime dependencies
- Too fragile for CI environments
- Over-engineered for a hobbyist project

## CI/CD Integration

### GitHub Actions Workflows

**`lua-quality.yml`** - Formatting & Linting
- Runs on every Lua file change
- Uses StyLua + Selene from tools-v1 release
- Fast: ~30 seconds

**`percybrain-tests.yml`** - Simple Tests
- Runs `simple-test.sh`
- Validates syntax + formatting + core config
- Fast: ~1 minute

Both workflows:
- ✅ Install StyLua and Selene automatically
- ✅ Cache tools for faster runs
- ✅ Comment on PRs with results
- ✅ Won't block commits for warnings

## Local Development

### Fix Formatting Issues
```bash
stylua lua/
```

### Fix Syntax Errors
Check the file marked with ✗ in test output

### Run Tests Before Committing
```bash
cd tests
./simple-test.sh
```

**Git Hooks** (optional):
- Pre-commit: Formats and lints staged files
- Pre-push: Runs full test suite
- Skip with: `SKIP_HOOKS=1 git commit`

## Test Output Example

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  PercyBrain Simple Test Suite
  Purpose: Ensure code works, not corporate compliance
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

▶ Testing Lua Syntax
  ✓ All Lua files have valid syntax

▶ Testing Critical Files Exist
  ✓ All critical configuration files exist

▶ Testing Core Configuration Loading
  ✓ Core configuration loads without errors

▶ Testing Code Formatting (StyLua)
  ✓ All code is properly formatted

▶ Testing Code Quality (Selene)
  ⊘ 2 linting warnings (not blocking)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Test Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Tests Passed: 5
Tests Failed: 0

✅ All tests passed! Your code is good to commit.
```

## Design Principles

1. **Fast** - Tests run in under 2 minutes
2. **Practical** - Only test what matters for functionality
3. **Forgiving** - Warnings don't block commits
4. **Simple** - One script, easy to understand
5. **Portable** - Works locally and in CI

## Comparison: Old vs New

| Aspect | Old (percybrain-test.sh) | New (simple-test.sh) |
|--------|--------------------------|----------------------|
| Tests | 36 complex checks | 5 essential checks |
| Time | ~5+ minutes | ~1 minute |
| Scope | Everything + kitchen sink | Lua code + formatting |
| CI Reliability | Fragile (external deps) | Robust (self-contained) |
| Maintenance | High complexity | Low complexity |
| Philosophy | Enterprise compliance | Pragmatic validation |

## Troubleshooting

**"StyLua not found"**
```bash
./scripts/install-lua-tools.sh
export PATH="$HOME/.local/bin:$PATH"
```

**"Syntax error in file"**
Open the file and check the Lua syntax. Common issues:
- Missing `end` keyword
- Unmatched quotes or brackets
- Typos in function names

**"Formatting issues detected"**
```bash
stylua lua/
git add -A
```

**"Core config failed to load"**
Check `init.lua` or `lua/config/init.lua` for errors

## Legacy Files

**Kept for Reference** (not used in CI):
- `percybrain-test.sh` - Complex test suite (36 tests)
- `quick-check.sh` - Quick health check for local development

These can still be run locally if you want more detailed checks, but they're not required for commits or CI.

---

**Remember**: The goal is to ship working code, not to pass audits for a Fortune 500 company. Keep it simple! 🚀
