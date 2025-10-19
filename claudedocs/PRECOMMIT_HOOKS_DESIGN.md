# PercyBrain Pre-Commit Hook Suite Design

**Date**: 2025-10-18 **Purpose**: Simple, robust, helpful Lua-based git hooks for code quality sanity checks **Philosophy**: Use proven tools, add custom logic only for PercyBrain-specific needs

______________________________________________________________________

## Overview

Comprehensive pre-commit hook suite using the industry-standard `pre-commit` framework with battle-tested tools for secrets scanning, formatting, and linting, plus custom validators for PercyBrain-specific patterns.

**Design Principles**:

- ✅ **Don't Reinvent the Wheel**: Use existing, maintained tools (detect-secrets, stylua, luacheck)
- ✅ **Fast**: Only check staged files, cache results, parallel execution
- ✅ **Helpful**: Clear error messages with actionable fixes
- ✅ **Robust**: Battle-tested tools, simple custom logic
- ✅ **Configurable**: Easy to enable/disable individual hooks

______________________________________________________________________

## Architecture

### Tool Selection Strategy

| Category           | Tool                 | Why This Tool                               | Alternative          |
| ------------------ | -------------------- | ------------------------------------------- | -------------------- |
| **Hook Manager**   | pre-commit           | Industry standard, 10K+ stars, auto-updates | Manual git hooks     |
| **Secret Scanner** | detect-secrets       | Yelp-maintained, low false positives        | gitleaks, trufflehog |
| **Lua Formatter**  | stylua               | Official formatter, 1K+ stars               | lua-format           |
| **Lua Linter**     | luacheck             | De facto standard, already in use           | selene               |
| **Syntax Check**   | luac                 | Built-in Lua compiler                       | N/A                  |
| **File Hygiene**   | pre-commit built-ins | Whitespace, line endings, file size         | Custom scripts       |

### Hook Categories

**1. Security Hooks** (CRITICAL - Block commits)

- Secret scanner (detect-secrets)
- Large file detector

**2. Code Quality Hooks** (ERROR - Block commits)

- Lua syntax validation (luac)
- Luacheck static analysis (undefined globals, unused vars)

**3. Formatting Hooks** (WARNING - Allow commits)

- StyLua code formatting
- Trailing whitespace
- Line ending normalization

**4. PercyBrain Hooks** (WARNING - Custom validators)

- Plugin spec validator (lazy.nvim structure)
- Test standards validator (6/6 standards compliance)
- Debug code detector (print statements, TODO comments)

______________________________________________________________________

## Installation & Setup

### Prerequisites

```bash
# Install uv (if not already installed)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install luac (Lua compiler - usually comes with Lua)
lua -v  # Verify Lua is installed

# Install stylua (Lua formatter)
cargo install stylua
# OR via package manager
brew install stylua  # macOS
snap install stylua  # Linux
```

### Quick Start (3 steps)

```bash
# 1. Install pre-commit via uvx
uvx --from pre-commit-uv pre-commit install

# 2. Initialize secrets baseline (first-time setup)
uvx --from detect-secrets detect-secrets scan > .secrets.baseline

# 3. Run initial check on all files
uvx --from pre-commit-uv pre-commit run --all-files
```

**That's it!** Hooks are now active. Every `git commit` will run the checks automatically.

______________________________________________________________________

## Configuration Files

### `.pre-commit-config.yaml` (Main Configuration)

```yaml
# Pre-commit hook configuration for PercyBrain
# Install: uvx --from pre-commit-uv pre-commit install
# Run manually: uvx --from pre-commit-uv pre-commit run --all-files

repos:
  # ============================================================================
  # BASIC FILE HYGIENE (Built-in hooks)
  # ============================================================================
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
        name: Trim trailing whitespace

      - id: end-of-file-fixer
        name: Fix end-of-file (ensure newline)

      - id: mixed-line-ending
        name: Normalize line endings (LF)
        args: ['--fix=lf']

      - id: check-merge-conflict
        name: Check for merge conflict markers

      - id: check-added-large-files
        name: Prevent large files (>500KB)
        args: ['--maxkb=500']

      - id: check-yaml
        name: Validate YAML syntax
        files: \.ya?ml$

  # ============================================================================
  # SECURITY - SECRET SCANNING (CRITICAL)
  # ============================================================================
  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.4.0
    hooks:
      - id: detect-secrets
        name: Scan for secrets (API keys, tokens, passwords)
        args:
          - '--baseline'
          - '.secrets.baseline'
          - '--exclude-files'
          - 'lazy-lock.json'
        exclude: ^tests/.*_spec\.lua$  # Allow test fixtures

        # Common secret patterns detected:
        # - AWS keys, GitHub PATs, Slack tokens
        # - Private keys, API keys, passwords
        # - High entropy strings (base64, hex)

  # ============================================================================
  # LUA CODE QUALITY (Syntax & Static Analysis)
  # ============================================================================
  - repo: local
    hooks:
      - id: lua-syntax-check
        name: Lua Syntax Validation (luac)
        entry: luac -p
        language: system
        files: \.lua$
        description: Fast syntax check using Lua compiler

  - repo: https://github.com/luarocks/luacheck
    rev: v1.1.0
    hooks:
      - id: luacheck
        name: Luacheck Static Analysis
        args:
          - '--globals'
          - 'vim'           # Allow vim global (Neovim API)
          - '--no-color'    # Clean output
          - '--codes'       # Show error codes
        files: \.lua$

        # Detects:
        # - Undefined global variables
        # - Unused variables and function arguments
        # - Shadowing of variables
        # - Unreachable code

  # ============================================================================
  # LUA FORMATTING (Code Style)
  # ============================================================================
  - repo: https://github.com/JohnnyMorganz/StyLua
    rev: v0.19.1
    hooks:
      - id: stylua-check
        name: StyLua Formatting Check
        args: ['--check']
        description: Check Lua code formatting (run 'stylua .' to auto-fix)

        # If this fails:
        # Fix with: stylua .
        # Or configure exceptions in .stylua.toml

  # ============================================================================
  # PERCYBRAIN-SPECIFIC HOOKS (Custom Validators)
  # ============================================================================
  - repo: local
    hooks:
      - id: plugin-spec-validator
        name: Validate Plugin Specs (lazy.nvim)
        entry: hooks/validate-plugin-spec.lua
        language: script
        files: ^lua/plugins/.*\.lua$
        description: Ensure plugin files return valid lazy.nvim specs

        # Validates:
        # - Returns table with plugin repo or import spec
        # - No broken lazy.nvim configurations
        # - Proper plugin structure

      - id: test-standards-validator
        name: Test Standards Compliance (6/6)
        entry: hooks/validate-test-standards.lua
        language: script
        files: ^tests/.*_spec\.lua$
        description: Enforce PercyBrain test quality standards

        # Checks:
        # 1. Helper/mock imports at top
        # 2. before_each/after_each present
        # 3. AAA pattern comments
        # 4. No _G. global pollution
        # 5. Local helper functions
        # 6. No raw assert.contains

      - id: debug-code-detector
        name: Debug Code Detection
        entry: hooks/detect-debug-code.sh
        language: script
        files: \.lua$
        exclude: ^tests/
        description: Catch leftover debug statements

        # Detects:
        # - print() statements
        # - vim.notify with DEBUG level
        # - TODO/FIXME without issue references
        # - XXX markers

# ============================================================================
# HOOK EXECUTION BEHAVIOR
# ============================================================================
# - Hooks run on 'git commit' automatically
# - Only staged files are checked (fast!)
# - Results are cached (re-runs only on changes)
# - Skip all hooks: git commit --no-verify
# - Skip specific hook: SKIP=hook-id git commit
# - Run manually: uvx --from pre-commit-uv pre-commit run
# - Run on all files: uvx --from pre-commit-uv pre-commit run --all-files
# - Update hook versions: uvx --from pre-commit-uv pre-commit autoupdate
```

### `.stylua.toml` (StyLua Configuration)

```toml
# StyLua configuration for PercyBrain
# Lua code formatting standards

column_width = 120
line_endings = "Unix"
indent_type = "Spaces"
indent_width = 2
quote_style = "AutoPreferDouble"
call_parentheses = "Always"

[sort_requires]
enabled = false
```

### `.luacheckrc` (Luacheck Configuration)

**Note**: This file likely already exists in PercyBrain. Update if needed:

```lua
-- Luacheck configuration for PercyBrain
-- Static analysis rules for Neovim plugin development

-- Ignore W211 (unused variable) for specific patterns
ignore = {
  "211/_.*",     -- Ignore unused variables starting with _
  "212",         -- Unused argument
}

-- Allow vim global (Neovim API)
globals = {
  "vim",
}

-- Exclude directories
exclude_files = {
  ".git",
  "lazy-lock.json",
}

-- Max line length
max_line_length = 120

-- Max code complexity
max_cyclomatic_complexity = 15
```

### `.secrets.baseline` (Secrets Whitelist)

Generated automatically on first run. Contains hashes of known false positives:

```bash
# Initialize (first-time setup)
uvx --from detect-secrets detect-secrets scan > .secrets.baseline

# Update baseline (whitelist new false positives)
uvx --from detect-secrets detect-secrets scan --baseline .secrets.baseline

# Audit baseline (review whitelisted secrets)
uvx --from detect-secrets detect-secrets audit .secrets.baseline
```

______________________________________________________________________

## Custom Hook Implementations

### 1. Plugin Spec Validator (`hooks/validate-plugin-spec.lua`)

**Purpose**: Ensure plugin files in `lua/plugins/` return valid lazy.nvim specs

**Validation Logic**:

```lua
#!/usr/bin/env lua

-- Plugin Spec Validator for lazy.nvim
-- Ensures plugin files return proper table structures

local exit_code = 0
local files = {...}  -- Passed by pre-commit

for _, file in ipairs(files) do
  -- Read file content
  local f = io.open(file, "r")
  if not f then
    print(string.format("❌ %s: Cannot read file", file))
    exit_code = 1
    goto continue
  end

  local content = f:read("*all")
  f:close()

  -- Check 1: Must have return statement
  if not content:match("return%s+{") and not content:match("return%s+M") then
    print(string.format("❌ %s: Missing return statement", file))
    print("   Fix: Add 'return { ... }' for plugin spec")
    exit_code = 1
    goto continue
  end

  -- Check 2: Plugin files should return table
  if content:match("return%s+{") then
    -- Valid: return { "plugin/repo", ... }
    -- Valid: return { import = "plugins.dir" }

    -- Check for common mistakes
    if content:match('return%s+{%s*"[^"]+"%s*}%s*$') then
      -- Just plugin repo, no config - this is fine
    elseif content:match('import%s*=%s*"plugins%.') then
      -- Import spec - this is fine
    end
  end

  -- Check 3: Warn about missing config function
  if content:match('return%s+{%s*"[^"]+"') and not content:match("config%s*=%s*function") then
    print(string.format("ℹ️  %s: Plugin spec has no config function", file))
    print("   This is OK for simple plugins, but consider adding config if needed")
  end

  ::continue::
end

os.exit(exit_code)
```

**What It Catches**:

- ❌ Missing return statements
- ❌ Wrong return types (not a table)
- ❌ Broken lazy.nvim syntax
- ℹ️ Warnings for potentially incomplete specs

### 2. Test Standards Validator (`hooks/validate-test-standards.lua`)

**Purpose**: Enforce PercyBrain 6/6 test quality standards

**Validation Logic**:

```lua
#!/usr/bin/env lua

-- Test Standards Validator
-- Enforces PercyBrain 6/6 testing standards

local standards = {
  {
    name = "Helper/Mock Imports",
    check = function(content)
      return content:match("require%('tests%.helpers'%)") or
             content:match("require%('tests%.helpers%.mocks'%)")
    end,
    fix = "Add: local helpers = require('tests.helpers')"
  },
  {
    name = "State Management (before_each/after_each)",
    check = function(content)
      return content:match("before_each") and content:match("after_each")
    end,
    fix = "Add before_each/after_each functions for test isolation"
  },
  {
    name = "AAA Pattern Comments",
    check = function(content)
      local arrange = content:match("%-%-+%s*Arrange")
      local act = content:match("%-%-+%s*Act")
      local assert = content:match("%-%-+%s*Assert")
      return arrange and act and assert
    end,
    fix = "Add AAA comments: -- Arrange, -- Act, -- Assert"
  },
  {
    name = "No Global Pollution",
    check = function(content)
      return not content:match("_G%.")
    end,
    fix = "Remove _G. references, use local variables instead"
  },
  {
    name = "Local Helper Functions",
    check = function(content)
      -- Should have 'local function' or is simple enough not to need it
      return content:match("local function") or #content < 200
    end,
    fix = "Define helper functions as 'local function name()'"
  },
  {
    name = "No Raw assert.contains",
    check = function(content)
      -- Should use local contains() helper, not assert.contains directly
      if content:match("assert%.contains") then
        return content:match("local function contains")
      end
      return true  -- No assert.contains used, that's fine
    end,
    fix = "Use local contains() helper instead of assert.contains"
  }
}

local exit_code = 0
local files = {...}

for _, file in ipairs(files) do
  local f = io.open(file, "r")
  if not f then goto continue end

  local content = f:read("*all")
  f:close()

  local failures = {}

  for i, standard in ipairs(standards) do
    if not standard.check(content) then
      table.insert(failures, {
        number = i,
        name = standard.name,
        fix = standard.fix
      })
    end
  end

  if #failures > 0 then
    print(string.format("\n⚠️  %s: %d/%d standards", file, 6 - #failures, 6))
    for _, failure in ipairs(failures) do
      print(string.format("   ❌ [%d/6] %s", failure.number, failure.name))
      print(string.format("      Fix: %s", failure.fix))
    end
    exit_code = 1
  else
    print(string.format("✅ %s: 6/6 standards", file))
  end

  ::continue::
end

os.exit(exit_code)
```

**What It Checks** (6/6 Standards):

1. ✅ Helper/mock imports at file top
2. ✅ before_each/after_each state management
3. ✅ AAA pattern comments (Arrange-Act-Assert)
4. ✅ No \_G. global pollution
5. ✅ Local helper functions present
6. ✅ No raw assert.contains (use local helper)

### 3. Debug Code Detector (`hooks/detect-debug-code.sh`)

**Purpose**: Catch leftover debug statements and incomplete TODOs

**Implementation**:

```bash
#!/bin/bash

# Debug Code Detector
# Catches leftover print statements, debug code, and incomplete TODOs

exit_code=0
files="$@"

for file in $files; do
  issues=()

  # Check for print() statements
  if grep -n "print(" "$file" > /dev/null 2>&1; then
    while IFS=: read -r line_num line_content; do
      issues+=("Line $line_num: print() statement found")
    done < <(grep -n "print(" "$file")
  fi

  # Check for vim.notify with DEBUG level
  if grep -n "vim\.notify.*DEBUG" "$file" > /dev/null 2>&1; then
    while IFS=: read -r line_num line_content; do
      issues+=("Line $line_num: DEBUG vim.notify found")
    done < <(grep -n "vim\.notify.*DEBUG" "$file")
  fi

  # Check for TODO/FIXME without issue reference
  if grep -n "-- TODO:" "$file" | grep -v "#[0-9]" > /dev/null 2>&1; then
    while IFS=: read -r line_num line_content; do
      issues+=("Line $line_num: TODO without issue reference (add #123)")
    done < <(grep -n "-- TODO:" "$file" | grep -v "#[0-9]")
  fi

  if grep -n "-- FIXME:" "$file" | grep -v "#[0-9]" > /dev/null 2>&1; then
    while IFS=: read -r line_num line_content; do
      issues+=("Line $line_num: FIXME without issue reference (add #123)")
    done < <(grep -n "-- FIXME:" "$file" | grep -v "#[0-9]")
  fi

  # Check for XXX markers
  if grep -n "-- XXX" "$file" > /dev/null 2>&1; then
    while IFS=: read -r line_num line_content; do
      issues+=("Line $line_num: XXX marker found (remove or convert to TODO #123)")
    done < <(grep -n "-- XXX" "$file")
  fi

  # Report issues
  if [ ${#issues[@]} -gt 0 ]; then
    echo "⚠️  $file: ${#issues[@]} debug code issue(s)"
    for issue in "${issues[@]}"; do
      echo "   ❌ $issue"
    done
    exit_code=1
  fi
done

exit $exit_code
```

**What It Catches**:

- ❌ `print()` statements (debug output)
- ❌ `vim.notify` with DEBUG level
- ❌ `-- TODO:` without issue reference (should be `-- TODO #123`)
- ❌ `-- FIXME:` without issue reference
- ❌ `-- XXX` markers (incomplete code)

______________________________________________________________________

## Usage Guide

### Daily Workflow

**Normal commits** (hooks run automatically):

```bash
git add lua/plugins/my-plugin.lua
git commit -m "feat: add my awesome plugin"

# Hooks run automatically:
# ✅ Secret scanner: No secrets detected
# ✅ Lua syntax: Valid
# ✅ Luacheck: No issues
# ⚠️  StyLua: Formatting issues (run 'stylua .')
# ✅ Plugin spec: Valid lazy.nvim structure
```

**Fix formatting issues**:

```bash
# Auto-fix StyLua formatting
stylua .

# Re-stage and commit
git add -u
git commit -m "feat: add my awesome plugin"
```

**Emergency bypass** (use sparingly):

```bash
# Skip ALL hooks (not recommended)
git commit --no-verify -m "emergency fix"

# Skip specific hook
SKIP=stylua-check git commit -m "fix: urgent patch"
```

### Hook Management

**Run hooks manually** (without committing):

```bash
# Check all staged files
uvx --from pre-commit-uv pre-commit run

# Check all files in repository
uvx --from pre-commit-uv pre-commit run --all-files

# Check specific hook
uvx --from pre-commit-uv pre-commit run luacheck

# Check specific files
uvx --from pre-commit-uv pre-commit run --files lua/plugins/my-plugin.lua
```

**Update hook versions**:

```bash
# Update to latest hook versions
uvx --from pre-commit-uv pre-commit autoupdate

# Review changes in .pre-commit-config.yaml
git diff .pre-commit-config.yaml

# Test updated hooks
uvx --from pre-commit-uv pre-commit run --all-files
```

**Disable hooks temporarily**:

```bash
# Uninstall hooks (still in config, just not active)
uvx --from pre-commit-uv pre-commit uninstall

# Re-enable later
uvx --from pre-commit-uv pre-commit install
```

### Managing Secrets Baseline

**Add false positive to baseline**:

```bash
# Scan and update baseline with new whitelisted items
uvx --from detect-secrets detect-secrets scan --baseline .secrets.baseline

# Audit baseline interactively
uvx --from detect-secrets detect-secrets audit .secrets.baseline

# Commit updated baseline
git add .secrets.baseline
git commit -m "chore: update secrets baseline"
```

**Review whitelisted secrets**:

```bash
# Audit all entries in baseline
uvx --from detect-secrets detect-secrets audit .secrets.baseline

# Mark each secret as:
# - [s] to skip (keep whitelisted)
# - [r] to remove from baseline (start blocking)
# - [q] to quit
```

______________________________________________________________________

## Hook Reference

### Security Hooks

| Hook                      | Severity | What It Does                          | How to Fix                                         |
| ------------------------- | -------- | ------------------------------------- | -------------------------------------------------- |
| `detect-secrets`          | ERROR    | Scans for API keys, tokens, passwords | Remove secrets or whitelist in `.secrets.baseline` |
| `check-added-large-files` | ERROR    | Blocks files >500KB                   | Use Git LFS or reduce file size                    |

### Quality Hooks

| Hook               | Severity | What It Does                                     | How to Fix                            |
| ------------------ | -------- | ------------------------------------------------ | ------------------------------------- |
| `lua-syntax-check` | ERROR    | Validates Lua syntax with `luac -p`              | Fix syntax errors shown in output     |
| `luacheck`         | ERROR    | Static analysis (undefined globals, unused vars) | Fix issues or configure `.luacheckrc` |

### Formatting Hooks

| Hook                  | Severity | What It Does                  | How to Fix                 |
| --------------------- | -------- | ----------------------------- | -------------------------- |
| `stylua-check`        | WARNING  | Checks Lua code formatting    | Run `stylua .` to auto-fix |
| `trailing-whitespace` | WARNING  | Removes trailing whitespace   | Auto-fixed by hook         |
| `end-of-file-fixer`   | WARNING  | Ensures newline at EOF        | Auto-fixed by hook         |
| `mixed-line-ending`   | WARNING  | Normalizes to LF line endings | Auto-fixed by hook         |

### PercyBrain Hooks

| Hook                       | Severity | What It Does                         | How to Fix                              |
| -------------------------- | -------- | ------------------------------------ | --------------------------------------- |
| `plugin-spec-validator`    | ERROR    | Validates lazy.nvim plugin structure | Ensure `return { ... }` with valid spec |
| `test-standards-validator` | WARNING  | Checks 6/6 test standards            | Follow test refactoring patterns        |
| `debug-code-detector`      | WARNING  | Catches print(), TODO without #issue | Remove debug code or add issue refs     |

______________________________________________________________________

## Troubleshooting

### Common Issues

**1. Hook fails with "command not found"**

```bash
# Ensure tool is installed
which luac stylua luacheck

# Install missing tools
cargo install stylua
# or
brew install stylua
```

**2. Secrets scanner false positives**

```bash
# Add to baseline (one-time whitelist)
uvx --from detect-secrets detect-secrets scan --baseline .secrets.baseline

# Or exclude specific file patterns in .pre-commit-config.yaml
```

**3. StyLua formatting conflicts**

```bash
# Check your .stylua.toml configuration
# Run stylua with --check to see what would change
stylua --check .

# Apply formatting
stylua .
```

**4. Luacheck reports undefined vim global**

```bash
# Add to .luacheckrc:
globals = { "vim" }

# Or use inline comment:
-- luacheck: globals vim
```

**5. Hooks are slow**

```bash
# pre-commit caches results, but first run is slow
# Speed up by:
# - Only checking staged files (default)
# - Running specific hooks: pre-commit run luacheck
# - Updating hook versions: pre-commit autoupdate
```

### Performance Optimization

**Reduce hook execution time**:

```yaml
# In .pre-commit-config.yaml, add 'stages' to expensive hooks:
- repo: https://github.com/JohnnyMorganz/StyLua
  rev: v0.19.1
  hooks:
    - id: stylua-check
      stages: [commit, push]  # Run on commit and push, not manual runs
```

**Skip hooks in CI/CD**:

```bash
# In CI, you might want to skip some hooks
SKIP=stylua-check,debug-code-detector git commit -m "ci: automated update"
```

______________________________________________________________________

## Migration Guide

### For Existing PercyBrain Contributors

**If you already have git hooks**:

```bash
# 1. Backup existing hooks
cp .git/hooks/pre-commit .git/hooks/pre-commit.backup

# 2. Install pre-commit
uvx --from pre-commit-uv pre-commit install

# 3. Test new hooks
uvx --from pre-commit-uv pre-commit run --all-files

# 4. If all good, remove backup
rm .git/hooks/pre-commit.backup
```

**If you use different formatting tools**:

```bash
# Disable StyLua check if you prefer lua-format
# In .pre-commit-config.yaml, comment out or remove:
# - id: stylua-check

# Keep other hooks active
```

### For New Contributors

**First-time setup** (included in contribution guide):

```bash
# 1. Clone repo
git clone https://github.com/percyBrainIWE/PercyBrain.git
cd PercyBrain

# 2. Install dependencies (if not done)
# [Follow main README.md setup]

# 3. Install pre-commit hooks
uvx --from pre-commit-uv pre-commit install

# 4. Initialize secrets baseline
uvx --from detect-secrets detect-secrets scan > .secrets.baseline

# 5. Test hooks
uvx --from pre-commit-uv pre-commit run --all-files

# 6. Start contributing!
```

______________________________________________________________________

## Design Rationale

### Why pre-commit Framework?

**Advantages**:

- ✅ Industry standard (used by 10,000+ projects)
- ✅ Auto-updates hook versions
- ✅ Caches results (fast re-runs)
- ✅ Large ecosystem of existing hooks
- ✅ Language-agnostic (supports Lua, Python, Go, Rust, etc.)
- ✅ Easy to configure (YAML file)

**Alternatives Considered**:

- ❌ Manual `.git/hooks/pre-commit` script: Hard to maintain, no caching
- ❌ Husky (Node.js): Requires Node, less mature for Lua projects
- ❌ Lefthook (Go): Good alternative, but smaller ecosystem

### Why detect-secrets Over gitleaks?

**detect-secrets (Yelp)**:

- ✅ Low false positive rate (uses multiple detection methods)
- ✅ Interactive audit workflow
- ✅ Baseline system for whitelisting
- ✅ Python-based (matches pre-commit ecosystem)

**gitleaks**:

- Fast (Go-based)
- Good for large-scale scanning
- Higher false positive rate
- Less interactive workflow

**Decision**: detect-secrets is better for developer workflow (fewer interruptions, better UX)

### Why StyLua Over lua-format?

**StyLua**:

- ✅ Official Lua formatter (JohnnyMorganz/StyLua)
- ✅ 1,000+ GitHub stars, actively maintained
- ✅ Fast (Rust-based)
- ✅ Opinionated (less configuration needed)

**lua-format**:

- Python-based (slower)
- Highly configurable (complexity)
- Less active maintenance

**Decision**: StyLua is the community standard for Lua formatting

### Custom vs. Existing Hooks

**Existing Tools Used** (8 hooks):

1. detect-secrets (secret scanning)
2. stylua (Lua formatting)
3. luacheck (Lua linting)
4. luac (Lua syntax)
5. trailing-whitespace (file hygiene)
6. end-of-file-fixer (file hygiene)
7. mixed-line-ending (file hygiene)
8. check-added-large-files (file hygiene)

**Custom Hooks Created** (3 hooks):

1. plugin-spec-validator (PercyBrain lazy.nvim patterns)
2. test-standards-validator (PercyBrain 6/6 test standards)
3. debug-code-detector (PercyBrain-specific debug patterns)

**Ratio**: 8 existing : 3 custom (73% reuse, 27% custom) **Principle**: Only write custom code for PercyBrain-specific logic

______________________________________________________________________

## Future Enhancements

### Planned Improvements

**Phase 2 - Additional Hooks**:

- LSP diagnostics check (markdown-oxide, ltex-ls)
- Spell check on markdown/documentation
- Screenshot size optimization (compress images)
- Dependency version pinning check

**Phase 3 - CI/CD Integration**:

- GitHub Actions workflow using same hooks
- Pre-push hooks for slow checks (full test suite)
- Commit message linting (conventional commits)

**Phase 4 - Developer Experience**:

- Visual Studio Code pre-commit extension
- Neovim integration (run hooks from editor)
- Dashboard for hook statistics

### Hook Ideas (Not Yet Implemented)

```yaml
# Future hooks to consider:

# Markdown linting
- repo: https://github.com/igorshubovych/markdownlint-cli
  hooks:
    - id: markdownlint
      files: \.md$

# Spell checking
- repo: https://github.com/codespell-project/codespell
  hooks:
    - id: codespell
      args: ['--ignore-words=.codespell-ignore']

# Conventional commits
- repo: https://github.com/compilerla/conventional-pre-commit
  hooks:
    - id: conventional-pre-commit
      stages: [commit-msg]
```

______________________________________________________________________

## Summary

**Architecture**:

- ✅ pre-commit framework for hook management
- ✅ Industry-standard tools (detect-secrets, stylua, luacheck)
- ✅ 3 custom validators for PercyBrain-specific patterns
- ✅ Fast, cached, parallel execution

**Hook Categories**:

- 🔒 Security: Secret scanner, large file detector
- 🐛 Quality: Lua syntax, luacheck static analysis
- 🎨 Formatting: StyLua, whitespace, line endings
- 🧩 PercyBrain: Plugin specs, test standards, debug code

**Installation**:

```bash
uvx --from pre-commit-uv pre-commit install
uvx --from detect-secrets detect-secrets scan > .secrets.baseline
uvx --from pre-commit-uv pre-commit run --all-files
```

**Key Files**:

- `.pre-commit-config.yaml` - Hook configuration
- `.secrets.baseline` - Whitelisted secrets
- `.stylua.toml` - Formatting rules
- `.luacheckrc` - Linting rules
- `hooks/` - Custom validators (3 files)

This design provides a robust, maintainable, helpful pre-commit hook suite that catches problems early while respecting developer workflow! 🎯
