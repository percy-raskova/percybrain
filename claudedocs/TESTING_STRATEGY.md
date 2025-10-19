# OVIWrite Testing & CI/CD Strategy

**Version**: 1.0 **Date**: 2025-10-16 **Status**: Design Complete, Implementation Pending

## Executive Summary

Comprehensive 4-layer testing strategy preventing plugin conflicts, deprecated APIs, configuration errors, and documentation drift. Fast local validation (\<5s), thorough CI checks (\<3min), accessible to writer-contributors.

**Key Metrics**:

- **Prevention**: 100% of recent issues (duplicates, deprecated APIs, misplaced files) caught automatically
- **Speed**: Layer 1-2 validation in \<5 seconds locally
- **Coverage**: Startup validation, health checks, plugin loading, documentation sync
- **Maintainability**: Standard tools (Neovim, shell, GitHub Actions), minimal custom code

______________________________________________________________________

## 1. Testing Architecture

### 1.1 Four-Layer Validation Pyramid

```
Layer 4: Documentation Sync          [CI + Manual]
         ├─ Plugin list accuracy     (~30s)
         └─ Keymap documentation

Layer 3: Dynamic Validation          [CI Only]
         ├─ Neovim startup test      (~60s)
         ├─ :checkhealth automation
         └─ Plugin load testing

Layer 2: Structural Validation       [Local + CI]
         ├─ Plugin spec validation   (~10s)
         ├─ Dependency graph check
         └─ Keymap conflict detection

Layer 1: Static Validation           [Local + CI]
         ├─ Lua syntax check         (~5s)
         ├─ Duplicate file detection
         ├─ Deprecated API scanning
         └─ File organization rules
```

**Principle**: Fast feedback locally (Layer 1-2), comprehensive coverage in CI (all layers)

### 1.2 Validation Scope Matrix

| Layer       | Runs On                        | Speed | Exit Code     | Prevents                                                      |
| ----------- | ------------------------------ | ----- | ------------- | ------------------------------------------------------------- |
| **Layer 1** | Every commit (pre-commit hook) | \<5s  | Blocks commit | Syntax errors, duplicates, deprecated APIs, file misplacement |
| **Layer 2** | Every commit + CI              | \<10s | Blocks commit | Invalid plugin specs, circular deps, keymap conflicts         |
| **Layer 3** | CI only (push/PR)              | ~60s  | Blocks merge  | Startup failures, plugin load errors, health check failures   |
| **Layer 4** | CI + manual review             | ~30s  | Warning only  | Documentation drift, stale shortcuts, missing plugins         |

______________________________________________________________________

## 2. Implementation Details

### 2.1 Layer 1: Static Validation

#### Script: `scripts/validate-layer1.sh`

**Purpose**: Catch 80% of issues in \<5 seconds

**Checks**:

1. **Lua Syntax Validation**

```bash
for file in $(git diff --cached --name-only --diff-filter=ACM | grep '\.lua$'); do
  nvim --headless -c "luafile $file" -c "quit" 2>&1 | grep -i error && exit 1
done
```

2. **Duplicate Plugin Detection**

```bash
# Problem: nvim-orgmode.lua + nvimorgmode.lua both loaded
# Solution: Normalize plugin names, detect collisions

find lua/plugins -name "*.lua" -not -name "init.lua" | \
  sed 's|lua/plugins/||; s|\.lua$||' | \
  tr '[:upper:]' '[:lower:]' | \
  tr -d '-_' | \
  sort | uniq -d
```

**Exit**: Code 1 if duplicates found, prints collision pairs

3. **Deprecated API Scanning** (patterns file: `scripts/deprecated-patterns.txt`)

```
# Pattern file format: PATTERN|REPLACEMENT|SEVERITY
vim\.highlight\.on_yank|vim.hl.on_yank|ERROR
config\s*=\s*\{\}|opts = {}|WARNING
setup_ts_grammar|[REMOVED]|ERROR
```

```bash
while IFS='|' read -r pattern replacement severity; do
  grep -rn "$pattern" lua/ && echo "[$severity] Use: $replacement"
done < scripts/deprecated-patterns.txt
```

4. **File Organization Rules**

```bash
# No init.lua files except lua/plugins/init.lua and lua/config/init.lua
find lua/plugins -name "init.lua" -not -path "lua/plugins/init.lua" && exit 1

# No utility modules in plugins/ (look for module-like patterns)
grep -l "return {" lua/plugins/*.lua | \
  while read file; do
    # Check if it's a lazy.nvim plugin spec (has [1] string field)
    lua -e "local spec = dofile('$file'); if type(spec[1]) ~= 'string' then print('$file') end"
  done
```

**Output**: Human-readable error messages with file:line context

#### Script: `scripts/validate-layer2.lua`

**Purpose**: Structural validation of plugin specs

```lua
-- Load each plugin file safely and validate structure
local plugins_dir = "lua/plugins"
local errors = {}

for file in vim.fs.dir(plugins_dir) do
  if file:match("%.lua$") and file ~= "init.lua" then
    local ok, spec = pcall(dofile, plugins_dir .. "/" .. file)

    if not ok then
      table.insert(errors, {file = file, error = "Failed to load: " .. spec})
    elseif type(spec) ~= "table" then
      table.insert(errors, {file = file, error = "Must return table"})
    elseif type(spec[1]) ~= "string" then
      table.insert(errors, {file = file, error = "spec[1] must be plugin repo URL"})
    else
      -- Validate lazy.nvim fields
      validate_lazy_spec(file, spec, errors)
    end
  end
end

function validate_lazy_spec(file, spec, errors)
  -- Check for deprecated patterns
  if spec.config and type(spec.config) == "table" and vim.tbl_isempty(spec.config) then
    table.insert(errors, {
      file = file,
      error = "Use 'opts = {}' instead of 'config = {}'",
      severity = "WARNING"
    })
  end

  -- Check for trigger mechanisms (lazy plugins should have event/cmd/keys/ft or lazy=false)
  if spec.lazy ~= false and not (spec.event or spec.cmd or spec.keys or spec.ft) then
    table.insert(errors, {
      file = file,
      error = "Lazy plugin needs trigger: event/cmd/keys/ft or set lazy=false",
      severity = "WARNING"
    })
  end
end

-- Exit with error count
os.exit(#errors)
```

### 2.2 Layer 3: Dynamic Validation (CI Only)

#### Script: `scripts/validate-startup.sh`

**Purpose**: Ensure zero-error startup

```bash
#!/bin/bash
set -euo pipefail

# Create isolated test environment
export HOME=/tmp/nvim-test-$$
mkdir -p "$HOME/.config/nvim"
cp -r . "$HOME/.config/nvim/"

# Run Neovim startup, capture output
nvim --headless \
  +"lua require('config')" \
  +"lua print('STARTUP_SUCCESS')" \
  +quit \
  > /tmp/startup-log.txt 2>&1

# Check for success marker and absence of errors
if grep -q "STARTUP_SUCCESS" /tmp/startup-log.txt && \
   ! grep -qi "error" /tmp/startup-log.txt; then
  echo "✅ Startup validation passed"
  exit 0
else
  echo "❌ Startup validation failed:"
  cat /tmp/startup-log.txt
  exit 1
fi
```

#### Script: `scripts/validate-health.sh`

**Purpose**: Automate `:checkhealth` validation

```bash
#!/bin/bash

# Run checkhealth, save to file
nvim --headless \
  -c "checkhealth" \
  -c "write! /tmp/health-report.txt" \
  -c "quit"

# Parse health report for errors
if grep -E "ERROR|FAIL" /tmp/health-report.txt; then
  echo "❌ Health check failures detected:"
  grep -B2 -A2 -E "ERROR|FAIL" /tmp/health-report.txt
  exit 1
else
  echo "✅ Health check passed"
  # Optional: Post summary to PR
  exit 0
fi
```

#### Script: `scripts/validate-plugin-loading.lua`

**Purpose**: Test individual plugin loading

```lua
-- Attempt to load each plugin via lazy.nvim
local lazy = require("lazy")
local plugins = lazy.plugins()
local failures = {}

for name, plugin in pairs(plugins) do
  -- Try loading the plugin
  local ok, err = pcall(lazy.load, {name})
  if not ok then
    table.insert(failures, {plugin = name, error = err})
  end
end

if #failures > 0 then
  print("❌ Plugin loading failures:")
  for _, failure in ipairs(failures) do
    print(string.format("  - %s: %s", failure.plugin, failure.error))
  end
  os.exit(1)
else
  print("✅ All plugins loaded successfully")
  os.exit(0)
end
```

### 2.3 Layer 4: Documentation Sync

#### Script: `scripts/validate-documentation.lua`

**Purpose**: Detect documentation drift

```lua
-- Extract plugin list from lua/plugins/*.lua
local installed_plugins = {}
for file in vim.fs.dir("lua/plugins") do
  if file:match("%.lua$") and file ~= "init.lua" then
    -- Remove .lua extension, convert to human-readable name
    local name = file:gsub("%.lua$", ""):gsub("%-", " "):gsub("_", " ")
    table.insert(installed_plugins, name)
  end
end

-- Parse CLAUDE.md for documented plugins (in tables)
local claude_md = io.open("CLAUDE.md", "r"):read("*all")
local documented_plugins = {}
for plugin in claude_md:gmatch("%*%*([^%*]+)%.lua%*%*") do
  table.insert(documented_plugins, plugin)
end

-- Find differences
local missing_from_docs = vim.tbl_filter(function(p)
  return not vim.tbl_contains(documented_plugins, p)
end, installed_plugins)

local removed_from_code = vim.tbl_filter(function(p)
  return not vim.tbl_contains(installed_plugins, p)
end, documented_plugins)

-- Report (warnings only, don't block)
if #missing_from_docs > 0 then
  print("⚠️  Plugins missing from CLAUDE.md:")
  for _, p in ipairs(missing_from_docs) do print("  - " .. p) end
end

if #removed_from_code > 0 then
  print("⚠️  Documented plugins not found in code:")
  for _, p in ipairs(removed_from_code) do print("  - " .. p) end
end

-- Exit 0 (warnings don't block)
os.exit(0)
```

#### Script: `scripts/extract-keymaps.lua`

**Purpose**: Auto-generate keymap documentation

```lua
-- Parse lua/config/keymaps.lua for vim.keymap.set() calls
local keymaps_file = io.open("lua/config/keymaps.lua", "r"):read("*all")
local keymaps = {}

-- Pattern: vim.keymap.set("n", "<leader>x", ...)
for mode, key, desc in keymaps_file:gmatch('vim%.keymap%.set%("([^"]+)","%s*([^"]+)"[^,]*,[^,]*,%s*{[^}]*desc%s*=%s*"([^"]+)"') do
  if key:match("^<leader>") then
    table.insert(keymaps, {mode = mode, key = key, desc = desc})
  end
end

-- Generate markdown table
print("| Key Combo | Action | Mode |")
print("|-----------|--------|------|")
for _, km in ipairs(keymaps) do
  print(string.format("| `%s` | %s | %s |", km.key, km.desc, km.mode))
end

-- Optional: Compare to CLAUDE.md and offer to update
```

______________________________________________________________________

## 3. GitHub Actions Workflows

### 3.1 Quick Validation (Every Push/PR)

**File**: `.github/workflows/quick-validation.yml`

```yaml
name: Quick Validation

on:
  push:
    branches: ['*']
  pull_request:
    branches: ['*']

jobs:
  validate:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Neovim
        uses: rhysd/action-setup-vim@v1
        with:
          neovim: true
          version: stable

      - name: Cache lazy.nvim plugins
        uses: actions/cache@v4
        with:
          path: ~/.local/share/nvim/lazy
          key: ${{ runner.os }}-lazy-${{ hashFiles('lazy-lock.json') }}
          restore-keys: |
            ${{ runner.os }}-lazy-

      - name: Run Layer 1 validation
        run: ./scripts/validate-layer1.sh

      - name: Run Layer 2 validation
        run: nvim --headless -l scripts/validate-layer2.lua

      - name: Upload validation report
        if: failure()
        uses: actions/upload-artifact@v4
        with:
          name: validation-report
          path: /tmp/validation-*.txt
```

### 3.2 Full Validation (PR to main, Weekly)

**File**: `.github/workflows/full-validation.yml`

```yaml
name: Full Validation

on:
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 0 * * 0'  # Every Sunday at midnight UTC

jobs:
  full-test:
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
        nvim-version: ['stable', 'nightly']
      fail-fast: false

    runs-on: ${{ matrix.os }}

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Neovim ${{ matrix.nvim-version }}
        uses: rhysd/action-setup-vim@v1
        with:
          neovim: true
          version: ${{ matrix.nvim-version }}

      - name: Cache plugins
        uses: actions/cache@v4
        with:
          path: |
            ~/.local/share/nvim/lazy
            ~/.cache/nvim
          key: ${{ runner.os }}-${{ matrix.nvim-version }}-lazy-${{ hashFiles('lazy-lock.json') }}

      - name: Run Layer 1-2 validation
        run: |
          ./scripts/validate-layer1.sh
          nvim --headless -l scripts/validate-layer2.lua

      - name: Run Layer 3 validation (startup test)
        run: ./scripts/validate-startup.sh

      - name: Run Layer 3 validation (health check)
        run: ./scripts/validate-health.sh

      - name: Run Layer 3 validation (plugin loading)
        run: nvim --headless -l scripts/validate-plugin-loading.lua

      - name: Run Layer 4 validation (documentation)
        run: nvim --headless -l scripts/validate-documentation.lua

      - name: Generate validation summary
        if: always()
        run: |
          echo "# Validation Summary" > /tmp/summary.md
          echo "**OS**: ${{ matrix.os }}" >> /tmp/summary.md
          echo "**Neovim**: ${{ matrix.nvim-version }}" >> /tmp/summary.md
          echo "**Status**: ${{ job.status }}" >> /tmp/summary.md

      - name: Comment PR with results
        if: github.event_name == 'pull_request'
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const summary = fs.readFileSync('/tmp/summary.md', 'utf8');
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: summary
            });

      - name: Upload artifacts
        if: failure()
        uses: actions/upload-artifact@v4
        with:
          name: validation-report-${{ matrix.os }}-${{ matrix.nvim-version }}
          path: /tmp/*.txt
```

______________________________________________________________________

## 4. Git Hooks & Local Development

### 4.1 Pre-commit Hook

**File**: `.git/hooks/pre-commit` (installed by `scripts/setup-dev-env.sh`)

```bash
#!/bin/bash

# Allow skip with SKIP_VALIDATION=1 git commit
if [ "$SKIP_VALIDATION" = "1" ]; then
  echo "⏭️  Skipping validation (SKIP_VALIDATION=1)"
  exit 0
fi

echo "🔍 Running pre-commit validation..."

# Run Layer 1 validation
if ! ./scripts/validate-layer1.sh; then
  echo ""
  echo "❌ Pre-commit validation failed"
  echo "Fix errors above or skip with: SKIP_VALIDATION=1 git commit"
  exit 1
fi

# Run Layer 2 validation
if ! nvim --headless -l scripts/validate-layer2.lua; then
  echo ""
  echo "❌ Plugin spec validation failed"
  exit 1
fi

echo "✅ Pre-commit validation passed"
exit 0
```

### 4.2 Pre-push Hook

**File**: `.git/hooks/pre-push`

```bash
#!/bin/bash

if [ "$SKIP_VALIDATION" = "1" ]; then
  exit 0
fi

echo "🔍 Running pre-push validation (includes startup test)..."

# Run Layer 1-2
./scripts/validate-layer1.sh || exit 1
nvim --headless -l scripts/validate-layer2.lua || exit 1

# Run Layer 3 (startup test only, not full health check)
./scripts/validate-startup.sh || exit 1

echo "✅ Pre-push validation passed"
exit 0
```

### 4.3 Setup Script

**File**: `scripts/setup-dev-env.sh`

```bash
#!/bin/bash
set -euo pipefail

echo "🔧 Setting up OVIWrite development environment..."

# Check dependencies
command -v nvim >/dev/null 2>&1 || { echo "❌ Neovim not found"; exit 1; }
command -v git >/dev/null 2>&1 || { echo "❌ Git not found"; exit 1; }

NVIM_VERSION=$(nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+')
if [ "$(echo "$NVIM_VERSION < 0.8" | bc)" -eq 1 ]; then
  echo "⚠️  Neovim $NVIM_VERSION detected. Recommend >= 0.8.0"
fi

# Install git hooks
echo "📦 Installing git hooks..."
cp scripts/pre-commit .git/hooks/pre-commit
cp scripts/pre-push .git/hooks/pre-push
chmod +x .git/hooks/pre-commit .git/hooks/pre-push

# Create isolated test environment directory
echo "📁 Creating .nvim-test/ directory for isolated testing..."
mkdir -p .nvim-test
echo ".nvim-test/" >> .gitignore

# Make validation scripts executable
chmod +x scripts/validate-*.sh

echo ""
echo "✅ Development environment setup complete!"
echo ""
echo "Available commands:"
echo "  ./scripts/validate.sh              # Quick validation (Layer 1-2)"
echo "  ./scripts/validate.sh --full       # Full validation (Layer 1-3)"
echo "  SKIP_VALIDATION=1 git commit       # Skip pre-commit checks"
echo ""
echo "Git hooks installed:"
echo "  - pre-commit: Runs Layer 1-2 validation"
echo "  - pre-push: Runs Layer 1-3 validation (includes startup test)"
```

### 4.4 Main Validation Script

**File**: `scripts/validate.sh`

```bash
#!/bin/bash
set -euo pipefail

FULL_MODE=false
CHECK_SPECIFIC=""

# Parse arguments
for arg in "$@"; do
  case $arg in
    --full) FULL_MODE=true ;;
    --check) CHECK_SPECIFIC="$2"; shift ;;
    --help)
      echo "Usage: ./scripts/validate.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --full              Run full validation (Layer 1-3)"
      echo "  --check <name>      Run specific check: duplicates|deprecated-apis|startup|docs"
      echo "  --help              Show this help"
      exit 0
      ;;
  esac
done

echo "🔍 OVIWrite Validation"
echo "======================"

# Specific check mode
if [ -n "$CHECK_SPECIFIC" ]; then
  case $CHECK_SPECIFIC in
    duplicates)
      echo "Checking for duplicate plugin files..."
      ./scripts/validate-layer1.sh --only-duplicates
      ;;
    deprecated-apis)
      echo "Checking for deprecated APIs..."
      ./scripts/validate-layer1.sh --only-deprecated
      ;;
    startup)
      echo "Testing Neovim startup..."
      ./scripts/validate-startup.sh
      ;;
    docs)
      echo "Validating documentation..."
      nvim --headless -l scripts/validate-documentation.lua
      ;;
    *)
      echo "❌ Unknown check: $CHECK_SPECIFIC"
      exit 1
      ;;
  esac
  exit 0
fi

# Normal validation flow
echo ""
echo "Layer 1: Static validation..."
./scripts/validate-layer1.sh || exit 1

echo ""
echo "Layer 2: Structural validation..."
nvim --headless -l scripts/validate-layer2.lua || exit 1

if [ "$FULL_MODE" = true ]; then
  echo ""
  echo "Layer 3: Dynamic validation (startup test)..."
  ./scripts/validate-startup.sh || exit 1

  echo ""
  echo "Layer 4: Documentation validation..."
  nvim --headless -l scripts/validate-documentation.lua || exit 1
fi

echo ""
echo "✅ Validation complete!"
```

______________________________________________________________________

## 5. Migration Plan

### Phase 1: Foundation (Week 1)

**Goal**: Core validation scripts operational

- [ ] Create `scripts/` directory structure
- [ ] Implement `validate-layer1.sh` (duplicates, syntax, deprecated APIs, file organization)
- [ ] Create `deprecated-patterns.txt` with known issues
- [ ] Implement `validate-layer2.lua` (plugin spec validation)
- [ ] Write basic GitHub Actions workflow (quick validation only)
- [ ] Test on current codebase, document known issues in baseline report

**Deliverables**:

- 2 validation scripts working locally
- GitHub Actions workflow running on push
- Baseline report documenting current validation status

### Phase 2: Local Development Workflow (Week 2)

**Goal**: Developer-friendly local testing

- [ ] Implement `setup-dev-env.sh` with dependency checks
- [ ] Create pre-commit and pre-push hooks
- [ ] Write `validate.sh` master script with `--full`, `--check` options
- [ ] Create CONTRIBUTING.md with development workflow guide
- [ ] Test workflow with sample contributions (dummy PRs)

**Deliverables**:

- Git hooks auto-installed on setup
- Clear developer documentation
- Tested workflow with skip options

### Phase 3: CI/CD Enhancement (Week 3)

**Goal**: Comprehensive CI coverage

- [ ] Add `full-validation.yml` workflow with OS + Neovim matrix
- [ ] Implement `validate-startup.sh` (Layer 3)
- [ ] Implement `validate-health.sh` (Layer 3)
- [ ] Implement `validate-plugin-loading.lua` (Layer 3)
- [ ] Set up caching for faster CI (lazy.nvim plugins)
- [ ] Add PR comment bot with validation results

**Deliverables**:

- Matrix testing across Linux/macOS/Windows
- Health check automation
- PR comments with validation summary

### Phase 4: Documentation Sync (Week 4)

**Goal**: Prevent documentation drift

- [ ] Implement `validate-documentation.lua` (plugin list comparison)
- [ ] Implement `extract-keymaps.lua` (auto-generate keymap tables)
- [ ] Manually sync CLAUDE.md to current state (one-time)
- [ ] Enable documentation validation in CI (warnings only)
- [ ] Create helper script: `scripts/update-docs.sh` (assisted doc updates)

**Deliverables**:

- Documentation validation detecting 90%+ drift
- Helper tools for maintaining docs
- CLAUDE.md fully synchronized

### Phase 5: Refinement (Ongoing)

**Goal**: Continuous improvement

- [ ] Collect feedback from contributors
- [ ] Add more patterns to `deprecated-patterns.txt` as discovered
- [ ] Improve error messages based on user confusion
- [ ] Optimize CI caching for faster runs
- [ ] Add more specific validations (e.g., colorscheme conflicts, LSP config validation)

______________________________________________________________________

## 6. Success Metrics

### Quantitative Metrics

- **Issue Prevention**: 100% of recent issues (duplicates, deprecated APIs, file misplacement) caught
- **Local Speed**: Layer 1-2 validation completes in \<5 seconds
- **CI Speed**: Full validation completes in \<3 minutes
- **False Positive Rate**: \<5% (validation errors that are actually correct code)
- **Documentation Accuracy**: ≥90% sync between code and CLAUDE.md

### Qualitative Metrics

- **Developer Experience**: Contributors report validation helpful, not burdensome
- **Maintainability**: New maintainers can understand and extend validation with minimal effort
- **Accessibility**: Writer-contributors (non-programmers) can interpret validation errors

### Failure Rate Targets

- **Before Merge**: 0 duplicate plugin incidents in PRs
- **Before Merge**: 0 deprecated API usage in new code
- **Before Merge**: 0 startup failures in PRs
- **Post-Merge**: \<1 regression per quarter escaping validation

______________________________________________________________________

## 7. Developer Documentation

### 7.1 Quick Start (for Contributors)

```bash
# First time setup (after cloning)
./scripts/setup-dev-env.sh

# Before committing (runs automatically via git hook)
./scripts/validate.sh

# Full validation (before pushing)
./scripts/validate.sh --full

# Check specific aspect
./scripts/validate.sh --check duplicates
./scripts/validate.sh --check startup

# Skip validation temporarily (use sparingly)
SKIP_VALIDATION=1 git commit -m "WIP: experimental feature"
```

### 7.2 Common Validation Errors

**Error**: `Duplicate plugin files detected: nvim-orgmode.lua, nvimorgmode.lua`

- **Cause**: Two files with similar names (after normalization) in `lua/plugins/`
- **Fix**: Remove one file, ensure only one plugin configuration per plugin

**Error**: `Plugin spec must return table with [1] = string (repo URL)`

- **Cause**: Plugin file returns wrong structure (module vs lazy.nvim spec)
- **Fix**: Check file returns `{ "author/repo", config = ... }` format

**Error**: `Deprecated API: vim.highlight.on_yank`

- **Cause**: Using old Neovim API
- **Fix**: Replace with `vim.hl.on_yank` (see `scripts/deprecated-patterns.txt`)

**Error**: `File organization: init.lua not allowed in lua/plugins/subdir/`

- **Cause**: Utility module in plugins directory
- **Fix**: Move to `lua/utils/` or `lua/lib/`, or rename to proper plugin spec

**Warning**: `Plugin missing from CLAUDE.md: [name]`

- **Cause**: Documentation drift (non-blocking)
- **Fix**: Add plugin to appropriate section in CLAUDE.md, or run `scripts/update-docs.sh`

### 7.3 Debugging Validation Failures

**CI fails but local validation passes**:

```bash
# Reproduce CI environment locally
./scripts/validate-startup.sh  # CI-only startup test
./scripts/validate-health.sh   # CI-only health check
```

**Pre-commit hook blocks commit**:

```bash
# See detailed error output
./scripts/validate-layer1.sh

# Fix issues, or skip if experimenting
SKIP_VALIDATION=1 git commit -m "message"
```

**False positive (validation error is incorrect)**:

1. Verify the code is actually correct
2. File issue in OVIWrite repo with details
3. Add exception to validation script if appropriate
4. Use `SKIP_VALIDATION=1` as temporary workaround

______________________________________________________________________

## 8. Maintenance Guide (for Project Maintainers)

### 8.1 Adding New Validation Rules

**Example**: Detect new deprecated API pattern

1. Add pattern to `scripts/deprecated-patterns.txt`:

```
new_deprecated_api|new_replacement_api|ERROR
```

2. Test against codebase:

```bash
grep -rn "new_deprecated_api" lua/
```

3. If matches found, fix or document as known issue

4. Validation automatically includes new pattern

### 8.2 Updating for New Neovim Versions

**When Neovim releases breaking changes**:

1. Update `deprecated-patterns.txt` with old → new API mappings
2. Update CI matrix in `.github/workflows/full-validation.yml` to test new version
3. Run full validation locally with new Neovim version
4. Document any compatibility issues in CLAUDE.md

### 8.3 Handling Validation Script Bugs

**If validation script has false positives/negatives**:

1. File issue with reproduction case
2. Fix script locally, test thoroughly
3. Add test case to prevent regression
4. Update script in repository
5. Communicate fix to contributors (PR comment, README update)

### 8.4 Performance Optimization

**If validation becomes slow**:

- **Local**: Profile with `time ./scripts/validate.sh`, optimize bottleneck layer
- **CI**: Check GitHub Actions cache hit rate, adjust cache keys if needed
- **Startup test**: Run in parallel for multiple Neovim versions if possible

**Target**: Keep Layer 1-2 \<5s, full CI run \<3min

______________________________________________________________________

## 9. Appendix: Tool Reference

### 9.1 Script Inventory

| Script                        | Purpose                                             | Runs On     | Speed  | Exit Code  |
| ----------------------------- | --------------------------------------------------- | ----------- | ------ | ---------- |
| `validate-layer1.sh`          | Static validation (syntax, duplicates, APIs, files) | Local + CI  | \<5s   | 1 on error |
| `validate-layer2.lua`         | Plugin spec validation                              | Local + CI  | \<10s  | 1 on error |
| `validate-startup.sh`         | Neovim startup test                                 | CI + manual | ~30s   | 1 on error |
| `validate-health.sh`          | Health check automation                             | CI + manual | ~30s   | 1 on error |
| `validate-plugin-loading.lua` | Individual plugin load test                         | CI          | ~30s   | 1 on error |
| `validate-documentation.lua`  | Doc sync check                                      | CI + manual | ~10s   | 0 (warns)  |
| `extract-keymaps.lua`         | Generate keymap docs                                | Manual      | \<5s   | 0          |
| `validate.sh`                 | Master validation script                            | Local       | varies | 1 on error |
| `setup-dev-env.sh`            | Install hooks + setup                               | Once        | ~10s   | 1 on error |

### 9.2 Configuration Files

| File                                     | Purpose                                       |
| ---------------------------------------- | --------------------------------------------- |
| `scripts/deprecated-patterns.txt`        | Pattern database for API deprecation scanning |
| `.github/workflows/quick-validation.yml` | CI: Layer 1-2 on every push                   |
| `.github/workflows/full-validation.yml`  | CI: All layers on PR to main, weekly          |
| `.git/hooks/pre-commit`                  | Git hook: Layer 1-2 before commit             |
| `.git/hooks/pre-push`                    | Git hook: Layer 1-3 before push               |
| `CONTRIBUTING.md`                        | Developer workflow guide                      |

### 9.3 Dependencies

**Required**:

- Neovim >= 0.8.0
- Git >= 2.19.0
- Bash (for shell scripts)

**Optional** (for enhanced validation):

- `luacheck` (Lua linting)
- `stylua` (Lua formatting)
- `ripgrep` (faster grep)

**CI-specific**:

- GitHub Actions (free tier sufficient)
- rhysd/action-setup-vim (Neovim installation action)

______________________________________________________________________

## 10. Future Enhancements

### 10.1 Planned Features (Beyond Phase 5)

- **Auto-fix mode**: `./scripts/validate.sh --fix` attempts to fix common issues
- **Plugin compatibility database**: Track known plugin conflicts, warn on incompatible combinations
- **Performance regression testing**: Measure Neovim startup time, alert on slowdowns
- **LSP configuration validation**: Ensure mason/lspconfig/null-ls configs are consistent
- **Visual regression testing**: Screenshot comparison for alpha screen, UI components
- **Localization testing**: Ensure plugins work with non-English locales (for international writers)

### 10.2 Integration Opportunities

- **Pre-commit framework**: Migrate to pre-commit.com if project adopts it ecosystem-wide
- **Dependabot**: Auto-update lazy-lock.json, validate plugin updates don't break config
- **Renovate**: Alternative to Dependabot with more Neovim-specific config
- **GitHub Discussions**: Auto-post validation results to discussions for community review

______________________________________________________________________

## Conclusion

This testing strategy provides comprehensive, fast, maintainable validation for OVIWrite. The layered approach ensures quick feedback locally (\<5s) while catching all issues before merge. The phased migration plan allows incremental adoption without blocking current development.

**Next Steps**: Begin Phase 1 implementation (Foundation week), starting with `validate-layer1.sh` and basic GitHub Actions workflow.
