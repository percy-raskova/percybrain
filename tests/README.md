# PercyBrain Test Suite

Simple, pragmatic test suite for OVIWrite/PercyBrain Neovim configuration.

## Philosophy

**Not Enterprise Compliance Theater** - This test suite ensures:

1. Code is syntactically valid (no broken Lua)
2. Code is formatted consistently (StyLua)
3. Code follows best practices (Selene linting)
4. Critical configuration files exist
5. Core config can load without errors

**What this is NOT:**

- Performance testing
- Security auditing
- Enterprise-grade compliance
- Corporate-level gatekeeping

## Test Files

- **`simple-test.sh`** - Main test suite (5 essential tests)
- **`README.md`** - This file

## Running Tests Locally

### Quick Start

```bash
# Run all tests
cd tests/
./simple-test.sh

# Run unit tests only
./run-unit-tests.sh

# Run keymap tests only
./run-keymap-tests.sh

# Run comprehensive test suite with coverage
./run-all-unit-tests.sh
```

### Auto-Discovery System

**All test runners use automatic test discovery** - new test files are automatically included without manual configuration updates.

**Convention**: Test files must end with `_spec.lua` to be discovered.

**Location Patterns**:

- `tests/unit/*_spec.lua` - Core unit tests (top-level only)
- `tests/unit/ai/*_spec.lua` - AI integration tests
- `tests/unit/gtd/*_spec.lua` - GTD module tests
- `tests/unit/keymap/*_spec.lua` - Keymap centralization tests
- `tests/unit/sembr/*_spec.lua` - SemBr integration tests
- `tests/unit/zettelkasten/*_spec.lua` - Zettelkasten tests
- `tests/integration/*_spec.lua` - Integration/workflow tests
- `tests/performance/*_spec.lua` - Performance benchmarks

**Adding New Tests**:

1. Create file ending in `_spec.lua` in appropriate directory
2. Run the relevant test runner - file will be auto-discovered
3. No manual configuration needed
4. Tests run in alphabetical order

**Benefits**:

- ✅ New tests automatically discovered
- ✅ No manual test list maintenance
- ✅ Prevents tests from being forgotten
- ✅ Alphabetically sorted for consistency

### Expected Output

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
  ℹ Running StyLua format check (timeout: 30s)...
  ✓ All code is properly formatted

▶ Testing Code Quality (Selene)
  ℹ Running Selene linter (timeout: 60s)...
  ✓ No linting issues

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Test Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Tests Passed: 5
Tests Failed: 0

✅ All tests passed! Your code is good to commit.
```

## Test Details

### 1. Lua Syntax Validation

- **Tool**: `luac` (if available) or `nvim --headless`
- **Purpose**: Catch syntax errors before commit
- **Files**: All `*.lua` files in `lua/` directory
- **Pass**: All files parse without errors
- **Fail**: Any syntax errors detected

### 2. Critical Files Exist

- **Purpose**: Ensure core configuration structure intact
- **Files Checked**:
  - `init.lua`
  - `lua/config/init.lua`
  - `lua/config/options.lua`
  - `lua/config/keymaps.lua`
- **Pass**: All files exist
- **Fail**: Any files missing

### 3. Core Config Loads

- **Environment Aware**:
  - **CI**: Syntax validation only (plugins not installed)
  - **Local**: Full config load test with Neovim headless
- **Purpose**: Verify config can initialize
- **Pass**: Config loads without errors
- **Fail**: Any load-time errors

### 4. Code Formatting (StyLua)

- **Tool**: StyLua v2.3.0
- **Purpose**: Consistent code style
- **Timeout**: 30 seconds
- **Pass**: All files formatted correctly
- **Fail**: Any formatting violations
- **Fix**: Run `stylua lua/`

### 5. Code Quality (Selene)

- **Tool**: Selene v0.29.0
- **Purpose**: Catch common Lua mistakes
- **Timeout**: 60 seconds
- **Pass**: No errors (warnings are OK)
- **Fail**: Any linting errors
- **Note**: Warnings won't block commits

## Debugging Tests

### Test Hangs or Times Out

```bash
# Run individual test components manually
cd /home/percy/.config/nvim

# Test syntax
find lua/ -name "*.lua" -exec luac -p {} \;

# Test formatting
stylua --check lua/

# Test linting
selene lua/

# Test config loading
nvim --headless -c "lua require('config')" -c "qall"
```

### Tests Fail in CI but Pass Locally

Common causes:

1. **Tool version mismatch**: Check CI uses same versions
2. **Path issues**: Verify tools are in PATH
3. **Cache issues**: Clear GitHub Actions cache
4. **Timeout too aggressive**: Increase timeout values

### GitHub Actions Cache Issues

If tests hang due to old cached tools:

1. Update cache key in workflows (already using version-specific keys)
2. Manually clear cache: Settings → Actions → Caches → Delete
3. Force reinstall: Remove cache step temporarily

## CI Integration

### GitHub Actions Workflows

- **`percybrain-tests.yml`** - Main test workflow (uses `simple-test.sh`)
- **`lua-quality.yml`** - Format/lint only workflow

Both workflows:

- Run on push to any branch (if Lua files changed)
- Run on pull requests to main/master
- Cache tools for faster execution (~30s with cache)
- Timeout after 5 minutes
- Post PR comments with results

### Testing Workflows Locally

Use [Act](https://github.com/nektos/act) to test GitHub Actions locally:

```bash
# Install Act (if not already installed)
# macOS: brew install act
# Linux: See https://github.com/nektos/act#installation

# Test main workflow
act push --job test

# Test with verbose output
act push --job test --verbose

# Test specific workflow file
act -W .github/workflows/percybrain-tests.yml
```

### Act Configuration

Create `.actrc` in project root for Act defaults:

```
-P ubuntu-latest=catthehacker/ubuntu:act-latest
--container-architecture linux/amd64
```

## Troubleshooting

### "StyLua not found"

```bash
# Install tools
./scripts/install-lua-tools.sh

# Add to PATH (add to ~/.bashrc or ~/.zshrc)
export PATH="$HOME/.local/bin:$PATH"
```

### "Selene not found"

Same as StyLua above.

### "luac not found"

Tests will automatically fall back to `nvim --headless` for syntax checking.

### Formatting Issues

```bash
# Auto-fix formatting
stylua lua/

# Check what would change (dry run)
stylua --check lua/
```

### Linting Errors

```bash
# View all linting issues
selene lua/

# Focus on specific files
selene lua/plugins/ollama.lua

# Get help on linting rules
selene --help
```

## Tool Installation

```bash
# Install all tools at once
./scripts/install-lua-tools.sh

# CI mode (skip PATH verification)
./scripts/install-lua-tools.sh --ci
```

Installs:

- **StyLua v2.3.0** - Rust-based formatter
- **Selene v0.29.0** - Rust-based linter

## Configuration Files

- **`.stylua.toml`** - StyLua formatting rules
- **`selene.toml`** - Selene linting rules
- **`.luarc.json`** - Lua language server config

## Contributing

When adding new tests:

1. Keep them simple and fast
2. Add timeouts to prevent hangs
3. Use temporary files for output capture (not command substitution)
4. Make CI/local behavior explicit
5. Document in this README

## Philosophy Reminder

> "The intent isn't for some enterprise grade production suite. We don't need performance testing. We need to make sure that our code base is free of errors that would cause the entire system to not work, and we need to make sure our code is well formatted and adheres to best practices and standards for Lua. The tests should facilitate the app functioning, they shouldn't deny commits because they don't meet the standards of a large corporation."

Keep tests pragmatic, fast, and focused on preventing breakage.
