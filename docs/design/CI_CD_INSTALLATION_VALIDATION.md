# CI/CD Installation Validation Design

**Purpose**: Validate that PercyBrain can be successfully installed and run on a clean machine, not just that code passes quality gates.

**Philosophy**: "Can someone else install and run this?" > "Does code pass linters?"

## Problem Statement

Current CI approach bundles quality checks (lint + format + test) but doesn't validate the actual user experience:

- ✅ Code is formatted correctly
- ✅ Tests pass
- ❌ Can users actually install it?
- ❌ Do dependencies install correctly?
- ❌ Does Neovim launch with the config?
- ❌ Do all 68 plugins install successfully?

## Design Principles

### 1. Installation-First Validation

CI should simulate the complete installation process a new user would experience:

- Clean environment setup
- Dependency installation
- Configuration deployment
- Plugin ecosystem installation
- First launch validation

### 2. Deployment Readiness

Tests should validate "ready to ship" criteria:

- All dependencies installable on target platforms
- Configuration loads without errors
- Critical workflows functional (Zettelkasten, AI, writing)
- Performance meets baseline requirements

### 3. Real-World Simulation

Use actual installation paths, not test shortcuts:

- Fresh Neovim instance
- Clean plugin directories
- Real dependency resolution
- Actual network requests for plugins

## Architecture

### Phase 1: Clean Environment Simulation

**Goal**: Verify installation from scratch

```bash
# 1. Environment Preparation
- Create isolated test directory
- Backup existing config (if any)
- Simulate fresh $XDG_CONFIG_HOME

# 2. Installation Execution
- Run setup script (or manual install steps)
- Verify all files copied correctly
- Check directory permissions

# 3. Validation
- Confirm expected files exist
- Verify directory structure matches spec
```

### Phase 2: Dependency Installation

**Goal**: Ensure all dependencies can be installed

```bash
# 1. Tool Manager Installation (Mise)
- Verify Mise installs correctly
- Check tool version specifications work

# 2. Language Toolchains
- Install Lua 5.1
- Install Node.js 22.17.1
- Install Python 3.12
- Install StyLua

# 3. External Dependencies
- Check cargo (Rust) for IWE LSP
- Check uv (Python) for SemBr
- Check ollama availability

# 4. Validation
- All tools report correct versions
- No installation errors
- Tool binaries executable
```

### Phase 3: Neovim Launch Validation

**Goal**: Verify Neovim starts with PercyBrain config

```bash
# 1. Headless Launch Test
nvim --headless -c "lua print('PercyBrain loaded')" -c "qa!"

# 2. Configuration Loading
- Verify init.lua loads
- Check lua/config/ modules load
- Confirm no Lua errors

# 3. Critical Options Validation
- Test ADHD optimizations applied
- Verify writing environment settings
- Check leader keys configured

# 4. Exit Clean
- No errors in startup
- Clean shutdown
```

### Phase 4: Plugin Ecosystem Installation

**Goal**: Validate all 68 plugins install correctly

```bash
# 1. Lazy.nvim Bootstrap
- Verify lazy.nvim clones correctly
- Check plugin manager initializes

# 2. Plugin Installation
nvim --headless -c "Lazy sync" -c "qa!"

# 3. Validation
- Count installed plugins (should be 68)
- Check for installation errors
- Verify critical plugins loaded:
  - telescope.nvim (navigation)
  - nvim-treesitter (syntax)
  - nvim-lspconfig (LSP)
  - zen-mode.nvim (writing focus)

# 4. Plugin Health Check
nvim --headless -c "checkhealth" -c "qa!"
- Parse output for errors
- Flag critical health issues
```

### Phase 5: Integration Testing in Deployed State

**Goal**: Run tests against actual deployed configuration

```bash
# 1. Test Suite Execution
mise test:comprehensive

# 2. Workflow Validation
- Test Zettelkasten note creation
- Test AI integration (if ollama available)
- Test LSP functionality
- Test writing mode activation

# 3. Performance Validation
- Startup time < 500ms
- Plugin load time acceptable
- No memory leaks

# 4. Exit Validation
- Clean shutdown
- No orphaned processes
```

### Phase 6: Platform-Specific Validation

**Goal**: Verify installation works on target platforms

```bash
# Linux (primary)
- Test on Debian/Ubuntu
- Test on Arch Linux
- Verify system package dependencies

# macOS
- Test on macOS 13+
- Verify Homebrew dependencies
- Check Apple Silicon compatibility

# Android (Termux)
- Test Termux environment
- Verify limited dependency set works
```

## Implementation

### Directory Structure

```
tests/
├── ci/
│   ├── test-clean-install.sh          # Phase 1: Clean environment
│   ├── test-dependency-installation.sh # Phase 2: Dependencies
│   ├── test-neovim-launch.sh          # Phase 3: Neovim validation
│   ├── test-plugin-installation.sh     # Phase 4: Plugins
│   ├── test-integration.sh             # Phase 5: Integration
│   └── platforms/
│       ├── test-linux.sh
│       ├── test-macos.sh
│       └── test-android.sh
└── helpers/
    └── ci_helpers.lua                  # CI-specific test utilities
```

### Mise Task Definitions

```toml
# .mise.toml

[tasks.ci]
description = "🚀 CI Pipeline: Installation & Deployment Validation"
run = """
#!/bin/bash
set -e

echo "🚀 PercyBrain CI Pipeline: Installation Validation"
echo "===================================================="
echo ""

# Phase 1: Clean Environment
echo "📦 Phase 1: Clean Environment Installation"
./tests/ci/test-clean-install.sh

# Phase 2: Dependencies
echo "🔧 Phase 2: Dependency Installation"
./tests/ci/test-dependency-installation.sh

# Phase 3: Neovim Launch
echo "🎯 Phase 3: Neovim Launch Validation"
./tests/ci/test-neovim-launch.sh

# Phase 4: Plugin Ecosystem
echo "🔌 Phase 4: Plugin Installation"
./tests/ci/test-plugin-installation.sh

# Phase 5: Integration Testing
echo "🧪 Phase 5: Integration Testing"
./tests/ci/test-integration.sh

# Summary
echo ""
echo "✅ CI Pipeline Complete"
echo "========================"
echo "All installation and deployment validation checks passed"
echo "Ready for release"
"""
depends = []  # No dependencies on lint/format/test

[tasks."ci:quick"]
description = "⚡ Quick CI: Core installation validation only"
run = """
#!/bin/bash
set -e

echo "⚡ Quick CI: Core Validation"
echo "============================"

# Critical path only
./tests/ci/test-dependency-installation.sh
./tests/ci/test-neovim-launch.sh
./tests/ci/test-plugin-installation.sh

echo "✅ Core validation passed"
"""

[tasks."ci:platform"]
description = "🖥️  Platform-specific CI validation"
run = """
#!/bin/bash
PLATFORM="${PLATFORM:-linux}"

echo "🖥️  Platform CI: $PLATFORM"
echo "=========================="

./tests/ci/platforms/test-$PLATFORM.sh

echo "✅ Platform validation passed for $PLATFORM"
"""

# Separate quality task (not part of CI)
[tasks.quality]
description = "✨ Code Quality Checks (separate from CI)"
depends = ["lint", "format:check", "test:quick"]
```

### CI Helper Functions

```lua
-- tests/helpers/ci_helpers.lua
local M = {}

-- Verify PercyBrain is installed
M.verify_installation = function()
  local required_paths = {
    "init.lua",
    "lua/config/init.lua",
    "lua/plugins/init.lua",
    ".mise.toml",
  }

  for _, path in ipairs(required_paths) do
    if vim.fn.filereadable(path) ~= 1 then
      return false, "Missing required file: " .. path
    end
  end

  return true
end

-- Count installed plugins
M.count_plugins = function()
  local ok, lazy = pcall(require, "lazy")
  if not ok then return 0 end

  local plugins = lazy.plugins()
  return #plugins
end

-- Verify critical plugins loaded
M.verify_critical_plugins = function()
  local critical = {
    "telescope.nvim",
    "nvim-treesitter",
    "nvim-lspconfig",
    "zen-mode.nvim",
  }

  local ok, lazy = pcall(require, "lazy")
  if not ok then return false, "Lazy.nvim not loaded" end

  for _, plugin_name in ipairs(critical) do
    local plugin = lazy.plugins()[plugin_name]
    if not plugin then
      return false, "Critical plugin missing: " .. plugin_name
    end
  end

  return true
end

-- Check startup time
M.measure_startup_time = function()
  -- Parse --startuptime output
  local startuptime_file = vim.fn.tempname()
  vim.fn.system(string.format(
    "nvim --headless --startuptime %s -c 'qa!'",
    startuptime_file
  ))

  local content = vim.fn.readfile(startuptime_file)
  local last_line = content[#content]
  local time_ms = tonumber(last_line:match("(%d+%.%d+)"))

  vim.fn.delete(startuptime_file)
  return time_ms
end

return M
```

## Success Criteria

### Installation Validation

- ✅ Clean install completes without errors
- ✅ All dependencies install correctly
- ✅ Neovim launches with PercyBrain config
- ✅ All 68 plugins install successfully
- ✅ Critical workflows functional

### Performance Validation

- ✅ Startup time \< 500ms
- ✅ Plugin load time acceptable
- ✅ No memory leaks detected

### Platform Validation

- ✅ Works on Linux (Debian, Arch)
- ✅ Works on macOS 13+
- ✅ Works on Android (Termux)

## Quality Gates vs CI Gates

### Quality Gates (Developer Workflow)

Run before commit, ensure code quality:

```bash
mise quality  # lint + format + test:quick
```

### CI Gates (Release Validation)

Run before release, ensure user experience:

```bash
mise ci       # installation + deployment + integration
```

They serve different purposes and should not be conflated.

## Migration Path

### Phase 1: Create CI Scripts

1. Write test-clean-install.sh
2. Write test-dependency-installation.sh
3. Write test-neovim-launch.sh
4. Write test-plugin-installation.sh
5. Write test-integration.sh

### Phase 2: Update Mise Tasks

1. Create new `ci` task with installation focus
2. Create `quality` task for code quality
3. Separate concerns clearly in documentation

### Phase 3: GitHub Actions Integration

1. Update .github/workflows/ci.yml
2. Use mise ci for deployment validation
3. Use mise quality for PR checks

## Benefits

### For Users

- ✅ Confidence that installation will work on their machine
- ✅ Clear validation of deployment readiness
- ✅ Platform-specific testing

### For Developers

- ✅ Catch installation issues before release
- ✅ Validate complete user experience
- ✅ Separate quality checks from deployment validation

### For Maintainers

- ✅ Clear release criteria
- ✅ Automated deployment validation
- ✅ Platform-specific issue detection

## References

- Kent Beck Testing Philosophy (TESTING_PHILOSOPHY_KENT_BECK.md)
- Mise Rationale (docs/explanation/MISE_RATIONALE.md)
- PercyBrain Setup Guide (PERCYBRAIN_SETUP.md)
