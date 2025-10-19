# PercyBrain Testing & Validation Guide

**Philosophy**: Help, Don't Block | **Speed**: \<5s local, \<3min CI | **Status**: 14/14 hooks passing, 44/44 tests

## Quick Start

```bash
# First-time setup (installs hooks)
./scripts/setup-dev-env.sh

# Before commit (auto-runs via git hook)
./scripts/validate.sh

# Before push (full validation)
./scripts/validate.sh --full

# Skip when needed (WIP, experiments)
SKIP_VALIDATION=1 git commit -m "WIP: exploring"
```

______________________________________________________________________

## Philosophy: Help, Don't Block

**Core Principle**: Testing catches errors and helps developers, not frustrates work or creates roadblocks.

### Design Principles

**1. Warnings vs Errors**

| Type                   | Examples                                                          | Behavior      |
| ---------------------- | ----------------------------------------------------------------- | ------------- |
| **Error** (blocking)   | Syntax errors, duplicate plugins, deprecated APIs, missing README | Blocks commit |
| **Warning** (advisory) | Trailing whitespace, bare URLs, documentation drift               | Doesn't block |

**Guideline**: If code works but isn't perfect → warning

**2. Easy Skip Mechanism**

```bash
SKIP_VALIDATION=1 git commit  # Trust developers to make the call
```

**When to skip**: Experiments, WIP commits, emergency hotfixes, you know what you're doing

**3. Helpful Error Messages**

Every error includes:

- What's wrong (clear description)
- Why it matters (impact)
- How to fix (auto-fix command with 💡)
- How to skip (quick escape)

**Example**:

```
❌ lua/plugins/nvim-orgmode.lua: Uses deprecated API vim.highlight.on_yank
   💡 Fix: sed -i 's/vim.highlight/vim.hl/g' lua/plugins/nvim-orgmode.lua
   Or skip: SKIP_VALIDATION=1 git commit
```

**4. Fast Feedback**

- Pre-commit (Layer 1-2): **\<5s**
- Pre-push (Layer 1-3): **~60s**
- Full validation: **~3 min**

**Why**: Slow tests get disabled. Fast tests get used.

**5. Layered Validation**

Run only what's needed:

```bash
./scripts/validate.sh               # Quick (Layer 1-2)
./scripts/validate.sh --full        # Comprehensive (Layer 1-4)
./scripts/validate.sh --check duplicates  # Specific check
```

**6. Clear Success States**

✅ Good: `✅ ALL VALIDATIONS PASSED | 💡 Tip: Run with --full before pushing` ❌ Bad: `Tests passed`

**Why**: Give context, not just pass/fail

______________________________________________________________________

## Four-Layer Validation Architecture

```
Layer 4: Documentation Sync          [CI + Manual] (~30s)
         ├─ Plugin list accuracy
         └─ Keymap documentation

Layer 3: Dynamic Validation          [CI Only] (~60s)
         ├─ Neovim startup test
         ├─ :checkhealth automation
         └─ Plugin load testing

Layer 2: Structural Validation       [Local + CI] (~10s)
         ├─ Plugin spec validation
         ├─ Dependency graph check
         └─ Keymap conflict detection

Layer 1: Static Validation           [Local + CI] (<5s)
         ├─ Lua syntax check
         ├─ Duplicate file detection
         ├─ Deprecated API scanning
         └─ File organization rules
```

**Principle**: Fast feedback locally (Layer 1-2), comprehensive coverage in CI (all layers)

### Validation Scope Matrix

| Layer | Runs On             | Speed | Exit Code    | Prevents                                                      |
| ----- | ------------------- | ----- | ------------ | ------------------------------------------------------------- |
| **1** | Every commit (hook) | \<5s  | Blocks       | Syntax errors, duplicates, deprecated APIs, file misplacement |
| **2** | Every commit + CI   | \<10s | Blocks       | Invalid plugin specs, circular deps, keymap conflicts         |
| **3** | CI only (push/PR)   | ~60s  | Blocks merge | Startup failures, plugin load errors, health failures         |
| **4** | CI + manual         | ~30s  | Warning      | Documentation drift, stale shortcuts, missing plugins         |

______________________________________________________________________

## Common Commands

### Validation

```bash
./scripts/validate.sh                     # Layer 1-2 (~5s)
./scripts/validate.sh --full              # Layer 1-4 (~2min)
./scripts/validate.sh --check duplicates  # Specific check
./scripts/validate.sh --check deprecated-apis
./scripts/validate.sh --check startup
./scripts/validate.sh --check docs
```

### Skip Mechanisms

```bash
SKIP_VALIDATION=1 git commit -m "WIP"     # Environment variable
git commit --no-verify                     # Git built-in
```

**Note**: CI still runs validation - skip is local development only

______________________________________________________________________

## Layer Details

### Layer 1: Static Validation (\<5s)

**Script**: `scripts/validate-layer1.sh` **Purpose**: Catch 80% of issues instantly

**Checks**:

1. **Lua Syntax**: `nvim --headless -c "luafile $file" -c "quit"`
2. **Duplicate Plugins**: Normalize names (nvim-tree.lua = nvimtree.lua = collision)
3. **Deprecated APIs**: Pattern file `scripts/deprecated-patterns.txt`
   ```
   vim\.highlight\.on_yank|vim.hl.on_yank|ERROR
   config\s*=\s*\{\}|opts = {}|WARNING
   ```
4. **File Organization**: No `init.lua` except `lua/plugins/init.lua`, `lua/config/init.lua`

### Layer 2: Structural Validation (\<10s)

**Script**: `scripts/validate-layer2.lua` **Purpose**: Validate plugin spec structure

**Checks**:

- `spec[1]` must be string (plugin repo URL)
- Use `opts = {}` not `config = {}`
- Lazy plugins need trigger: `event`/`cmd`/`keys`/`ft` or `lazy=false`

### Layer 3: Dynamic Validation (~60s, CI only)

**Scripts**:

- `scripts/validate-startup.sh` - Zero-error startup test
- `scripts/validate-health.sh` - `:checkhealth` automation
- `scripts/validate-plugin-loading.lua` - Individual plugin load test

**Purpose**: Ensure real-world functionality

### Layer 4: Documentation Sync (~30s, warnings only)

**Scripts**:

- `scripts/validate-documentation.lua` - Compare installed vs documented plugins
- `scripts/extract-keymaps.lua` - Auto-generate keymap tables

**Purpose**: Prevent documentation drift (non-blocking)

______________________________________________________________________

## Common Errors & Fixes

### Duplicate Plugin Files

```bash
# Error: nvim-tree.lua and nvimtree.lua detected
rm lua/plugins/nvimtree.lua  # Keep one
./scripts/validate.sh --check duplicates  # Verify
```

### Deprecated API

```bash
# Error: vim.highlight.on_yank detected
# Fix: Replace in code
vim.highlight.on_yank → vim.hl.on_yank
```

### Invalid Plugin Spec

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

### Startup Failure

```bash
nvim --headless -c "lua require('config')" -c "quit"  # Manual test
./scripts/validate.sh --check startup  # Automated
```

______________________________________________________________________

## Git Hooks

### Pre-commit Hook (Layer 1-2, \<5s)

```bash
# Runs automatically on `git commit`
# Validates: syntax, duplicates, deprecated APIs, plugin specs
# Skip: SKIP_VALIDATION=1 git commit
```

### Pre-push Hook (Layer 1-3, ~60s)

```bash
# Runs automatically on `git push`
# Adds: startup test (Layer 3)
# Skip: SKIP_VALIDATION=1 git push
```

______________________________________________________________________

## CI/CD Workflows

### Quick Validation (Every Push)

- **Runs**: Layer 1-2
- **Time**: ~30s
- **Triggers**: Every push, every PR

### Full Validation (PR to Main)

- **Runs**: Layer 1-4
- **Time**: ~3min per job
- **Matrix**: Linux/macOS/Windows × Neovim stable/nightly
- **Triggers**: PR to main, weekly schedule

______________________________________________________________________

## Troubleshooting

### CI Fails, Local Passes

```bash
./scripts/validate.sh --full  # Run same tests as CI
nvim --version  # Check version (CI tests stable + nightly)
```

### Hook Doesn't Run

```bash
ls -la .git/hooks/pre-commit  # Check if installed
./scripts/setup-dev-env.sh    # Reinstall
chmod +x .git/hooks/pre-commit  # Make executable
```

### False Positive (Validation Wrong)

1. Verify code is actually correct
2. File issue with details
3. Add exception to validation script if appropriate
4. Use `SKIP_VALIDATION=1` as temporary workaround

______________________________________________________________________

## What We Don't Do

### ❌ Block for Style Issues

- Trailing whitespace → Warning
- Missing final newline → Warning
- Line length → Not checked

### ❌ Require Perfect Documentation

- Documentation drift → Warning (Layer 4)
- Missing docstrings → Not checked
- TODOs in code → Allowed

### ❌ Enforce Subjective Choices

- Code formatting → Not enforced
- Variable naming → Not enforced
- Comment style → Not enforced

______________________________________________________________________

## Examples: Help vs Block

### Scenario 1: Developer Experiments

**Help Approach** ✅:

```
⚠️  lua/plugins/orgmode.lua: Configuration structure unusual
   💡 Verify this is intentional
✅ No blocking errors found
```

**Block Approach** ❌:

```
ERROR: orgmode configuration doesn't match template
Fix before committing
```

### Scenario 2: Documentation Out of Sync

**Help Approach** ✅:

```
⚠️  Documentation may be out of sync
   Added: lua/plugins/new-plugin.lua
   Not in: CLAUDE.md plugin list
   💡 Consider updating CLAUDE.md
✅ No blocking errors found
```

**Block Approach** ❌:

```
ERROR: CLAUDE.md out of date
Update documentation before committing
```

______________________________________________________________________

## Script Reference

| Script                        | Purpose                  | Runs On     | Speed  | Exit       |
| ----------------------------- | ------------------------ | ----------- | ------ | ---------- |
| `validate-layer1.sh`          | Static validation        | Local + CI  | \<5s   | 1 on error |
| `validate-layer2.lua`         | Plugin spec validation   | Local + CI  | \<10s  | 1 on error |
| `validate-startup.sh`         | Neovim startup test      | CI + manual | ~30s   | 1 on error |
| `validate-health.sh`          | Health check automation  | CI + manual | ~30s   | 1 on error |
| `validate-plugin-loading.lua` | Plugin load test         | CI          | ~30s   | 1 on error |
| `validate-documentation.lua`  | Doc sync check           | CI + manual | ~10s   | 0 (warns)  |
| `extract-keymaps.lua`         | Generate keymap docs     | Manual      | \<5s   | 0          |
| `validate.sh`                 | Master validation script | Local       | varies | 1 on error |
| `setup-dev-env.sh`            | Install hooks + setup    | Once        | ~10s   | 1 on error |

______________________________________________________________________

## Quick Reference Card

```
┌─────────────────────────────────────────────────────────────┐
│ PercyBrain Validation Quick Reference                      │
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

______________________________________________________________________

## Success Metrics

### Quantitative

- **Issue Prevention**: 100% of duplicates, deprecated APIs, file misplacement caught
- **Local Speed**: Layer 1-2 \<5s
- **CI Speed**: Full validation \<3min
- **False Positive Rate**: \<5%
- **Documentation Accuracy**: ≥90% sync

### Qualitative

- Validation feels helpful, not punishing
- Easy to skip when needed
- Fast enough to not disrupt flow
- Clear guidance on fixes
- Accessible to writer-contributors (non-programmers)

______________________________________________________________________

**Key Insight**: The best test is one that catches bugs without frustrating developers. **Help, don't block.**
