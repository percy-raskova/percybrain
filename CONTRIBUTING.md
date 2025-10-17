# Contributing to OVIWrite

Thank you for your interest in contributing to OVIWrite! This document provides guidelines and workflows for contributors.

## Table of Contents

- [Quick Start](#quick-start)
- [Development Workflow](#development-workflow)
- [Validation System](#validation-system)
- [Common Tasks](#common-tasks)
- [Troubleshooting](#troubleshooting)
- [Coding Standards](#coding-standards)
- [Pull Request Process](#pull-request-process)

## Quick Start

### Prerequisites

- **Neovim >= 0.8.0** (0.9+ recommended)
- **Git >= 2.19.0**
- **Basic familiarity with Lua and Vim motions**

### First-Time Setup

1. **Clone the repository**
```bash
git clone https://github.com/MiragianCycle/OVIWrite.git
cd OVIWrite
```

2. **Run development environment setup**
```bash
./scripts/setup-dev-env.sh
```

This script will:
- Check dependencies (Neovim, Git)
- Install git hooks (pre-commit, pre-push)
- Make validation scripts executable
- Create isolated test directory (`.nvim-test/`)
- Test validation scripts

3. **Verify installation**
```bash
./scripts/validate.sh
```

Should show: ✅ **Layer 1-2 validation passed**

## Development Workflow

### Branching Strategy

- **main/master**: Stable release branch
- **feature/feature-name**: New features and enhancements
- **fix/bug-description**: Bug fixes
- **docs/topic**: Documentation improvements

### Basic Workflow

```bash
# 1. Create feature branch
git checkout -b feature/my-new-plugin

# 2. Make changes
nvim lua/plugins/my-plugin.lua

# 3. Test locally (runs automatically via pre-commit hook)
./scripts/validate.sh

# 4. Commit (git hook runs Layer 1-2 validation)
git add lua/plugins/my-plugin.lua
git commit -m "feat: add my-plugin for improved writing flow"

# 5. Run full validation before push
./scripts/validate.sh --full

# 6. Push (git hook runs Layer 1-3 validation)
git push origin feature/my-new-plugin

# 7. Create pull request on GitHub
```

## Validation System

OVIWrite uses a **4-layer validation pyramid** to ensure code quality.

**📖 For detailed documentation**: See [`scripts/README.md`](scripts/README.md) for complete reference including troubleshooting, extending the system, and script internals.

### Layer 1: Static Validation (~5 seconds)

**What it checks**:
- Lua syntax errors
- Duplicate plugin files (e.g., `nvim-tree.lua` + `nvimtree.lua`)
- Deprecated API usage (e.g., `vim.highlight.on_yank`)
- File organization rules (no `init.lua` in wrong places)

**When it runs**: Pre-commit hook, CI

**Run manually**:
```bash
./scripts/validate.sh  # Layer 1-2 only
./scripts/validate.sh --check duplicates
./scripts/validate.sh --check deprecated-apis
```

### Layer 2: Structural Validation (~10 seconds)

**What it checks**:
- Plugin spec structure (must return `{ "author/repo", config = ... }`)
- lazy.nvim field validation (correct use of `opts`, `event`, etc.)
- Keymap conflicts (duplicate key bindings)
- Circular dependencies

**When it runs**: Pre-commit hook, CI

**Run manually**:
```bash
./scripts/validate.sh
```

### Layer 3: Dynamic Validation (~60 seconds)

**What it checks**:
- Neovim startup without errors
- `:checkhealth` passes
- Individual plugin loading

**When it runs**: Pre-push hook, CI (on PR to main)

**Run manually**:
```bash
./scripts/validate.sh --full
./scripts/validate.sh --check startup
./scripts/validate.sh --check health
```

### Layer 4: Documentation Sync (~30 seconds)

**What it checks**:
- CLAUDE.md plugin list matches actual plugins
- Keyboard shortcuts documentation is current

**When it runs**: CI (warnings only, doesn't block)

**Run manually**:
```bash
./scripts/validate.sh --check docs
./scripts/extract-keymaps.lua  # Generate keymap table
```

### Skip Validation (Use Sparingly)

For experimental work or work-in-progress commits:

```bash
# Skip pre-commit hook
SKIP_VALIDATION=1 git commit -m "WIP: experimental feature"

# Skip pre-push hook
SKIP_VALIDATION=1 git push

# Or use git's built-in skip
git push --no-verify
```

**Note**: CI will still run validation. Use skip only for local experimentation.

## Common Tasks

### Adding a New Plugin

1. **Create plugin configuration file**

```bash
nvim lua/plugins/my-plugin.lua
```

2. **Use the lazy.nvim plugin spec format**

```lua
return {
  "author/plugin-repo",  -- [1] MUST be plugin URL
  lazy = true,           -- Lazy load (recommended)
  event = "VeryLazy",    -- Load trigger
  opts = {               -- Plugin options (preferred over config = {})
    -- Plugin configuration here
  },
  keys = {               -- Optional: keymap triggers
    { "<leader>mp", "<cmd>MyPlugin<cr>", desc = "My Plugin" },
  },
}
```

3. **Test the plugin**

```bash
# Validate structure
./scripts/validate.sh

# Test in Neovim
nvim
:Lazy load my-plugin  # Load the plugin
:MyPlugin            # Test functionality
```

4. **Document the plugin**

Add to `CLAUDE.md` under **Key Writing-Focused Plugins** section:

```markdown
- **my-plugin.lua**: Description of what the plugin does
```

### Updating Existing Plugin

1. **Edit plugin file**

```bash
nvim lua/plugins/existing-plugin.lua
```

2. **Test changes**

```bash
# Full validation (includes startup test)
./scripts/validate.sh --full

# Or test in isolated environment
./scripts/validate.sh --check startup
```

3. **Update documentation if needed**

If adding new keymaps:

```bash
# Generate updated keymap table
./scripts/extract-keymaps.lua

# Copy output to CLAUDE.md
```

### Fixing Validation Errors

**Error**: `Duplicate plugin files detected`

```bash
# Find duplicates
./scripts/validate.sh --check duplicates

# Fix: Remove one of the duplicate files
# Example: Keep nvim-tree.lua, remove nvimtree.lua
rm lua/plugins/nvimtree.lua
```

**Error**: `Deprecated API: vim.highlight.on_yank`

```bash
# Find usage
./scripts/validate.sh --check deprecated-apis

# Fix: Replace with new API
# Old: vim.highlight.on_yank
# New: vim.hl.on_yank
```

**Error**: `Plugin spec must return table with [1] = string`

```lua
-- ❌ Wrong (module structure)
local M = {}
M.setup = function() ... end
return M

-- ✅ Right (plugin spec)
return {
  "author/repo",  -- [1] must be string
  opts = {},
}
```

**Error**: `File organization: init.lua not allowed`

```bash
# Only these init.lua files are allowed:
# - lua/plugins/init.lua
# - lua/config/init.lua

# Fix: Rename or move to lua/utils/
mv lua/plugins/writer_templates/init.lua lua/utils/writer_templates.lua
```

### Running Specific Validation Checks

```bash
# Check for duplicate plugins only
./scripts/validate.sh --check duplicates

# Check for deprecated APIs only
./scripts/validate.sh --check deprecated-apis

# Test Neovim startup
./scripts/validate.sh --check startup

# Run health check
./scripts/validate.sh --check health

# Validate documentation sync
./scripts/validate.sh --check docs

# Extract keymaps to markdown table
./scripts/extract-keymaps.lua
```

## Troubleshooting

### Validation Passes Locally But Fails in CI

**Possible causes**:

1. **Different Neovim version**: CI tests on stable + nightly
2. **Platform-specific issues**: CI tests Linux, macOS, Windows
3. **Cache issues**: CI may have different plugin states

**Solutions**:

```bash
# Test with startup (same as CI Layer 3)
./scripts/validate.sh --full

# Check Neovim version
nvim --version

# Clear local cache and retest
rm -rf ~/.local/share/nvim/lazy
./scripts/validate.sh --full
```

### Pre-commit Hook Doesn't Run

```bash
# Check if hook is installed
ls -la .git/hooks/pre-commit

# Reinstall hooks
./scripts/setup-dev-env.sh

# Make hook executable
chmod +x .git/hooks/pre-commit
```

### "luafile" Errors During Validation

**Error**: `E5113: Error while calling lua chunk`

**Cause**: Syntax error in Lua file

**Solution**:

```bash
# Test specific file
nvim --headless -c "luafile lua/plugins/my-plugin.lua" -c "quit"

# Check Lua syntax manually
nvim lua/plugins/my-plugin.lua
:luafile %  # Run in Neovim
```

### Plugin Loading Fails

```bash
# Test plugin loading individually
nvim
:Lazy load plugin-name

# Check lazy.nvim logs
:Lazy log

# Run plugin loading validation
./scripts/validate.sh --check plugins
```

## Coding Standards

### Lua Style Guide

- **Indentation**: 2 spaces (no tabs)
- **Line length**: ~100 characters (flexible for plugin specs)
- **Naming**:
  - Variables: `snake_case`
  - Functions: `snake_case`
  - Constants: `UPPER_CASE`

### Plugin Configuration Standards

```lua
return {
  "author/repo",             -- Required: [1] = plugin URL
  lazy = true,               -- Recommended: lazy load by default
  event = "VeryLazy",        -- Trigger: event, cmd, keys, ft, or lazy=false
  dependencies = {           -- Optional: dependencies (array)
    "other/plugin",
  },
  opts = {                   -- Preferred: use opts instead of config = {}
    option = value,
  },
  keys = {                   -- Optional: keymap triggers
    { "key", "command", desc = "description" },
  },
  config = function()        -- Use when setup() needs custom logic
    require("plugin").setup({
      -- ...
    })
  end,
}
```

### File Organization

```
lua/
├── config/             # Core configuration
│   ├── init.lua       # Loads globals, keymaps, options (ALLOWED)
│   ├── globals.lua
│   ├── keymaps.lua
│   └── options.lua
├── plugins/            # Plugin specifications (lazy.nvim auto-loads all .lua)
│   ├── init.lua       # Minimal plugin loader (ALLOWED)
│   ├── plugin1.lua    # Each plugin in separate file
│   ├── plugin2.lua
│   └── lsp/           # LSP configurations
└── utils/              # Utility modules (NOT auto-loaded by lazy.nvim)
    └── helpers.lua
```

**Rules**:
- One plugin per file in `lua/plugins/*.lua`
- Plugin files must return lazy.nvim spec: `{ "author/repo", ... }`
- Utility modules go in `lua/utils/`, not `lua/plugins/`
- Only `lua/plugins/init.lua` and `lua/config/init.lua` allowed as init.lua

### Keymap Standards

```lua
-- In lua/config/keymaps.lua
vim.keymap.set("n", "<leader>x", "<cmd>Command<cr>", {
  desc = "Clear description of action",  -- Always include desc
  silent = true,                         -- Optional: don't show command
  noremap = true,                        -- Optional: non-recursive (default)
})
```

### Commit Message Convention

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add new writing plugin
fix: resolve duplicate plugin loading
docs: update CLAUDE.md with new keymaps
refactor: simplify plugin configuration
test: add validation for deprecated APIs
chore: update dependencies
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `refactor`: Code refactoring (no behavior change)
- `test`: Adding or fixing tests/validation
- `chore`: Maintenance tasks

## Pull Request Process

### Before Submitting

1. **Run full validation**
```bash
./scripts/validate.sh --full
```

2. **Update documentation** (if needed)
```bash
# Add plugin to CLAUDE.md
# Update keyboard shortcuts if added new keymaps
./scripts/extract-keymaps.lua  # Generate keymap table
```

3. **Test manually in Neovim**
```bash
nvim
# Test your changes work as expected
```

### PR Checklist

- [ ] All validation passes locally (`./scripts/validate.sh --full`)
- [ ] Plugin documented in CLAUDE.md (if adding new plugin)
- [ ] Keyboard shortcuts documented (if adding new keymaps)
- [ ] Tested manually in Neovim
- [ ] Commit messages follow conventional commits format
- [ ] No unrelated changes included

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] New plugin
- [ ] Bug fix
- [ ] Enhancement to existing plugin
- [ ] Documentation update
- [ ] Refactoring

## Testing
How was this tested?

## Checklist
- [ ] Full validation passes (`./scripts/validate.sh --full`)
- [ ] Documentation updated (CLAUDE.md)
- [ ] Tested in Neovim
```

### Review Process

1. **Automated CI runs**: Quick validation → Full validation (matrix)
2. **Maintainer review**: Code quality, plugin fit, documentation
3. **Approval and merge**: Squash and merge to main

### After Merge

- Your contribution will be included in the next release
- Thank you for improving OVIWrite!

## Getting Help

- **Issues**: [GitHub Issues](https://github.com/MiragianCycle/OVIWrite/issues)
- **Discussions**: [GitHub Discussions](https://github.com/MiragianCycle/OVIWrite/discussions)
- **Documentation**: See [CLAUDE.md](CLAUDE.md) and [README.md](README.md)

## Project Seeking Maintainers

OVIWrite is actively seeking new maintainers! If you're interested in taking on a larger role:

1. Start by contributing several PRs
2. Demonstrate understanding of the architecture and validation system
3. Reach out via GitHub Issues expressing interest

---

**Thank you for contributing to OVIWrite and supporting writers everywhere!** 🎉
