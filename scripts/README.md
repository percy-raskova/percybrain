# OVIWrite Validation Scripts

Comprehensive validation system ensuring code quality, correctness, and documentation consistency for OVIWrite Neovim configuration.

## Quick Start

```bash
# Standard validation (fast, ~15s)
./scripts/validate.sh

# Full validation (complete, ~90s)
./scripts/validate.sh --full

# Specific check
./scripts/validate.sh --check startup
```

## Architecture Overview

OVIWrite uses a **4-layer validation pyramid** that catches issues progressively:

```
        ┌─────────────────────────────┐
        │  Layer 4: Documentation     │  ~30s  (warnings only)
        │  Sync & Completeness        │
        ├─────────────────────────────┤
        │  Layer 3: Dynamic Runtime   │  ~60s  (full mode)
        │  Startup, Health, Plugins   │
        ├─────────────────────────────┤
        │  Layer 2: Structural        │  ~10s  (standard)
        │  Plugin Specs, Dependencies │
        ├─────────────────────────────┤
        │  Layer 1: Static Analysis   │  ~5s   (standard)
        │  Lua Syntax, Organization   │
        └─────────────────────────────┘
```

**Design Philosophy**: Fast checks first (Layer 1-2), expensive checks only when needed (Layer 3-4 with `--full`).

---

## Scripts Reference

### Core Validation Scripts

#### `validate.sh` - Master Orchestrator

**Purpose**: Entry point for all validation workflows

**Usage**:
```bash
# Standard mode (Layer 1-2, ~15s)
./scripts/validate.sh

# Full mode (Layer 1-4, ~90s)
./scripts/validate.sh --full

# Specific checks
./scripts/validate.sh --check duplicates
./scripts/validate.sh --check startup
./scripts/validate.sh --check health
./scripts/validate.sh --check markdown
```

**Options**:
- `--full` - Run complete validation (Layer 1-4)
- `--check <name>` - Run specific validation component
- `--help` - Show usage information

**Exit Codes**:
- `0` - All validations passed
- `1` - Validation failed (errors found)

**Available Checks**:
- `duplicates` - Check for duplicate plugin files
- `deprecated-apis` - Check for deprecated API patterns
- `markdown` - Check markdown formatting
- `startup` - Test Neovim startup (Layer 3)
- `health` - Run `:checkhealth` diagnostics
- `plugins` - Test plugin loading
- `docs` - Validate documentation sync

---

#### `validate-layer1.sh` - Static Analysis

**Language**: Bash
**Duration**: ~5 seconds
**Blocks Commit**: Yes (on errors)

**Checks Performed**:

1. **Lua Syntax Validation**
   - Uses `nvim --headless -c "luafile"` on all `.lua` files
   - Catches syntax errors before runtime
   - Exit immediately if any file has invalid syntax

2. **Duplicate Plugin Detection**
   - Normalizes plugin filenames (lowercase, remove hyphens/underscores)
   - Detects name collisions (e.g., `nvim-tree.lua` vs `nvimtree.lua`)
   - Prevents lazy.nvim loading conflicts

3. **Deprecated API Scanning**
   - Pattern matching against `deprecated-patterns.txt`
   - Supports ERROR (blocks) and WARNING (advisory) severities
   - Helps migration to newer Neovim APIs

4. **File Organization Validation**
   - Ensures `init.lua` files only in allowed locations
   - Detects utility modules misplaced in `lua/plugins/`
   - Enforces project directory conventions

**Configuration**: Edit `deprecated-patterns.txt` to add new patterns

**Example Output**:
```
✅ All Lua files have valid syntax
✅ No duplicate plugin files detected
⚠️  [WARNING] Deprecated API found:
   Pattern: on_attach\s*=\s*function
   Use instead: Use opts with on_attach
✅ File organization is correct
```

**Recent Fixes**:
- Fixed `tr -d '-_'` command syntax (now `tr -d '_-'`)
- Added `|| true` to arithmetic operations for `set -e` compatibility

---

#### `validate-layer2.lua` - Structural Validation

**Language**: Lua
**Duration**: ~10 seconds
**Blocks Commit**: Yes (on errors)

**Checks Performed**:

1. **Plugin Spec Structure**
   - First element must be string (repository URL)
   - Validates lazy.nvim field names
   - Ensures proper table structure

   **Valid Format**:
   ```lua
   return {
     "author/plugin-name",  -- MUST be string
     opts = {},             -- Configuration
     event = "VeryLazy"     -- Lazy loading trigger
   }
   ```

   **Invalid Format** (caught and rejected):
   ```lua
   return {
     { "author/plugin-name" }  -- ❌ Nested table
   }
   ```

2. **Lazy.nvim Field Validation**
   - Warns if using `config = {}` instead of `opts = {}`
   - Checks for missing lazy loading triggers
   - Detects invalid field combinations (`config` + `opts`)
   - Validates dependency format

3. **Keymap Conflict Detection**
   - Scans `lua/config/keymaps.lua` for duplicate bindings
   - Detects mode + key collisions (e.g., two `<leader>s` in normal mode)
   - Prevents user confusion from shadowed keymaps

4. **Circular Dependency Detection**
   - Builds plugin dependency graph
   - Checks for direct circular dependencies
   - Warns about plugin A → B → A cycles

**Example Output**:
```
📦 Validating plugin spec structures...
  ✓ telescope.lua
  ✓ nvim-tree.lua
  ✗ bad-plugin.lua - Missing repo URL

✅ All plugin specs are valid
✅ No keymap conflicts detected
✅ Dependency check complete

⚠️  47 warnings (non-blocking):
   - goyo.lua: Lazy plugin needs trigger: event, cmd, keys, ft
   - alpha.lua: Cannot use both 'config' and 'opts' - choose one
```

---

#### `validate-startup.sh` - Runtime Startup Test

**Language**: Bash
**Duration**: ~30 seconds
**Blocks Push**: Yes (in full mode)

**Test Process**:

1. **Isolated Environment**
   - Creates `/tmp/nvim-test-$$` temporary directory
   - Copies OVIWrite config to test location
   - Sets XDG environment variables for isolation

2. **Startup Script**
   - Loads main configuration (`require('config')`)
   - Checks lazy.nvim availability
   - Reports success/failure markers

3. **Validation**
   - Searches for `STARTUP_SUCCESS` marker
   - Checks for error messages in output
   - Captures full startup log for debugging

4. **Cleanup**
   - On success: Removes test environment
   - On failure: Preserves logs for debugging

**What It Catches**:
- Runtime Lua errors
- Missing dependencies
- Configuration conflicts
- Plugin initialization failures
- Circular require() loops

**Example Output**:
```
🚀 Layer 3: Startup Validation
📁 Creating isolated test environment: /tmp/nvim-test-12345
🔄 Running Neovim startup...

Startup log:
----------------------------------------
STARTUP_SUCCESS
lazy.nvim loaded: 62 plugins
----------------------------------------

✅ Startup validation passed
   Neovim started successfully with zero errors
```

---

#### `validate-health.sh` - Health Check

**Language**: Bash
**Duration**: ~15 seconds
**Blocks Push**: Yes (in full mode)

**Checks Performed**:
- LSP server availability (lua_ls, pyright, etc.)
- External tool dependencies (ripgrep, fzf, fd, LaTeX)
- Plugin health status
- System environment configuration
- Clipboard integration

**Uses**: Neovim's built-in `:checkhealth` system

---

#### `validate-markdown.sh` - Documentation Quality

**Language**: Bash
**Duration**: ~2 seconds
**Blocks Commit**: No (warnings only)

**Checks Performed**:

1. **Basic Formatting**
   - Trailing whitespace detection
   - Consistent line endings

2. **Heading Structure**
   - Top-level heading presence (`# Title`)
   - Proper heading hierarchy

3. **Markdown Syntax**
   - Bare URLs (should use `[text](url)`)
   - Broken reference links
   - Malformed lists

4. **Documentation Best Practices**
   - Code block language tags
   - Table formatting
   - Link text quality

**Example Output**:
```
📝 Markdown Formatting Validation

Found 19 markdown files

Checking basic formatting...
⚠️  ./README.md: Has trailing whitespace
   💡 Fix: sed -i 's/[[:space:]]*$//' ./README.md

⚠️  Found 8 warnings (non-blocking)
```

---

### Supporting Scripts

#### `deprecated-patterns.txt` - API Pattern Database

**Format**:
```
PATTERN|REPLACEMENT|SEVERITY
```

**Example**:
```
# Neovim 0.9+ API changes
vim\.highlight\.on_yank|vim.hl.on_yank|ERROR

# lazy.nvim best practices
config\s*=\s*\{\}|opts = {}|WARNING
on_attach\s*=\s*function|Use opts with on_attach|WARNING
```

**Severity Levels**:
- `ERROR` - Blocks commit (critical migrations)
- `WARNING` - Advisory only (best practices)

**Maintenance**: Add patterns as Neovim APIs evolve

---

#### `extract-keymaps.lua` - Keymap Documentation

**Purpose**: Generate markdown table of keyboard shortcuts

**Usage**:
```bash
nvim --headless -l scripts/extract-keymaps.lua > keymaps.md
```

**Output**: Markdown table for `CLAUDE.md` documentation

---

#### `setup-dev-env.sh` - Development Setup

**Purpose**: Configure development environment

**Actions**:
- Install git hooks (`pre-commit`, `pre-push`)
- Check external tool dependencies
- Configure git settings
- Create `.gitignore` entries

**Usage**:
```bash
./scripts/setup-dev-env.sh
```

---

#### `fix-nested-specs.sh` - Migration Utility

**Purpose**: Batch fix nested plugin spec format

**Usage**:
```bash
./scripts/fix-nested-specs.sh
```

**What It Does**:
- Finds plugins with `{ { "repo" } }` format
- Unwraps to `{ "repo", ... }` format
- Preserves other fields (opts, config, dependencies)

**Note**: Created during validation fix session, kept as reference

---

### Git Hooks

#### `pre-commit` - Fast Validation

**Triggers**: Before every commit
**Duration**: ~15 seconds
**Validation**: Layer 1-2

```bash
#!/bin/bash
if ! ./scripts/validate.sh; then
  echo "❌ Validation failed!"
  echo "Fix errors or skip: SKIP_VALIDATION=1 git commit"
  exit 1
fi
```

**Skip Mechanism**:
```bash
SKIP_VALIDATION=1 git commit -m "WIP: experimental feature"
```

---

#### `pre-push` - Complete Validation

**Triggers**: Before every push
**Duration**: ~90 seconds
**Validation**: Layer 1-4 (full)

```bash
#!/bin/bash
if ! ./scripts/validate.sh --full; then
  echo "❌ Full validation failed!"
  echo "Fix errors or skip: SKIP_VALIDATION=1 git push"
  exit 1
fi
```

---

## Validation Workflows

### Standard Development Flow

```
Edit code → Save
         ↓
     git add
         ↓
    git commit → pre-commit hook → Layer 1-2 (~15s)
         ↓                             ↓
         ↓                          ✅ Pass → Commit created
         ↓                             ↓
         ↓                          ❌ Fail → Fix or skip
         ↓
    git push → pre-push hook → Layer 1-4 (~90s)
         ↓                          ↓
         ↓                       ✅ Pass → Push to remote
         ↓                          ↓
         ↓                       ❌ Fail → Fix or skip
         ↓
    Remote CI (future)
```

### Troubleshooting Workflow

```
Validation fails
      ↓
 Identify layer
      ↓
   ┌──┴────┬────────┬────────┐
   │       │        │        │
Layer 1  Layer 2  Layer 3  Layer 4
   │       │        │        │
Syntax  Struct  Runtime   Docs
   │       │        │        │
  Fix    Fix      Fix      Fix
   │       │        │        │
   └──┬────┴────────┴────────┘
      ↓
./scripts/validate.sh
      ↓
  ✅ Pass
```

---

## Performance Characteristics

| Layer | Tool | Duration | Blocks Commit | Blocks Push |
|-------|------|----------|---------------|-------------|
| Layer 1 | Bash | ~5s | Yes (errors) | Yes |
| Layer 2 | Lua | ~10s | Yes (errors) | Yes |
| Markdown | Bash | ~2s | No | No |
| Layer 3a | Bash | ~30s | No | Yes |
| Layer 3b | Bash | ~15s | No | Yes |
| Layer 4 | Lua | ~30s | No | No |

**Total Standard**: ~17 seconds (pre-commit)
**Total Full**: ~107 seconds (pre-push)

---

## Common Issues and Solutions

### Issue: "tr: invalid option -- '_'"

**Cause**: Bash `tr` command syntax ambiguity with `-d '-_'`
**Fix**: Changed to `tr -d '_-'` (underscore first)
**Location**: `validate-layer1.sh` lines 76, 92

### Issue: "Layer 1 failed" with all checks passing

**Cause**: `((COUNT++))` returns exit code 1 when COUNT=0 with `set -e`
**Fix**: Added `|| true` to all arithmetic increment operations
**Location**: `validate-layer1.sh` lines 49, 50, 78, 82, 85, etc.

### Issue: "spec[1] must be plugin repo URL"

**Cause**: Nested plugin spec format `{ { "repo" } }`
**Fix**: Unwrap to single-spec format `{ "repo", ... }`
**Tool**: `fix-nested-specs.sh` for batch conversion

### Issue: Validation too slow

**Solution**: Use standard mode for development (`./scripts/validate.sh`)
**Full mode** only needed before pushing to remote

---

## Extending the System

### Adding New Deprecated Patterns

Edit `scripts/deprecated-patterns.txt`:

```bash
# Add pattern at end of file
echo "old_api\s*\(|new_api()|ERROR" >> scripts/deprecated-patterns.txt
```

### Adding Custom Checks

Create new script in `scripts/`:

```bash
#!/bin/bash
# scripts/validate-custom.sh

echo "Running custom validation..."
# Your checks here
exit 0
```

Add to `validate.sh`:

```bash
# In validate.sh, add case in specific checks
custom)
  exec "$SCRIPT_DIR/validate-custom.sh"
  ;;
```

### Modifying Layer 2 Checks

Edit `scripts/validate-layer2.lua`:

```lua
-- Add new validation function
local function validate_custom()
  print_colored('blue', '🔍 Custom check...')
  -- Your validation logic
end

-- Call in main execution
validate_plugin_specs()
validate_keymaps()
validate_dependencies()
validate_custom()  -- Add here
```

---

## CI Integration (Future)

Validation scripts are designed for CI/CD integration:

```yaml
# .github/workflows/validate.yml
name: Validation
on: [push, pull_request]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install Neovim
        run: sudo apt-get install -y neovim
      - name: Run Validation
        run: ./scripts/validate.sh --full
```

---

## Best Practices

### For Developers

1. **Run validation before committing**
   ```bash
   ./scripts/validate.sh && git commit
   ```

2. **Fix errors, not skip validation**
   - Use `SKIP_VALIDATION=1` only for experimental/WIP commits
   - Always validate before PR

3. **Use specific checks for debugging**
   ```bash
   ./scripts/validate.sh --check duplicates
   ```

4. **Update deprecated patterns**
   - Add new patterns as Neovim APIs change
   - Document migration paths

### For Maintainers

1. **Keep validation fast**
   - Layer 1-2 should stay under 20 seconds
   - Expensive checks only in full mode

2. **Provide clear error messages**
   - Include file name and line number
   - Suggest fix commands when possible

3. **Document validation changes**
   - Update this README when adding checks
   - Update CONTRIBUTING.md with new patterns

4. **Test validation scripts**
   ```bash
   # Test with known-good config
   ./scripts/validate.sh --full

   # Test with intentional errors
   echo "bad lua syntax" > test.lua
   ./scripts/validate-layer1.sh
   ```

---

## Debugging Validation Failures

### Layer 1 Failures

1. **Check specific file**:
   ```bash
   nvim --headless -c "luafile lua/plugins/problem.lua" -c "quit"
   ```

2. **Test deprecated patterns**:
   ```bash
   grep -rn "pattern" lua/
   ```

3. **Verify organization**:
   ```bash
   find lua/ -name "init.lua"
   ```

### Layer 2 Failures

1. **Test single plugin**:
   ```bash
   nvim --headless -c "lua print(vim.inspect(dofile('lua/plugins/test.lua')))" -c "quit"
   ```

2. **Check keymap conflicts**:
   ```bash
   grep "vim.keymap.set" lua/config/keymaps.lua | sort
   ```

### Layer 3 Failures

1. **Check startup logs**:
   ```bash
   # Logs saved to /tmp/nvim-test-*/startup-log.txt on failure
   cat /tmp/nvim-test-*/startup-log.txt
   ```

2. **Manual startup test**:
   ```bash
   nvim --headless -c "quit" 2>&1 | grep -i error
   ```

3. **Health check details**:
   ```bash
   nvim -c "checkhealth" -c "qall"
   ```

---

## Credits

Validation system developed for OVIWrite by Percy Raskova.

**Contributors**:
- Percy Raskova - Initial system design and implementation
- Claude Code - Troubleshooting and documentation

**Inspired by**:
- LazyVim validation patterns
- Neovim core CI practices
- lazy.nvim plugin spec standards

---

## License

Same as OVIWrite project (see root LICENSE file).
