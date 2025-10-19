---
title: Mise Task Runner Usage Guide
category: how-to
tags:
  - mise
  - task-runner
  - development
  - workflow
last_reviewed: '2025-10-19'
---

# Mise Task Runner Usage Guide

**Quick Start**: `mise run setup` → 3-minute development environment | **Daily**: `mise t` (test), `mise f` (format), `mise q` (quick check)

For understanding Mise concepts, architecture, and rationale, see [MISE_RATIONALE.md](../explanation/MISE_RATIONALE.md).

______________________________________________________________________

## First-Time Setup

### 1. Install Mise

```bash
# Install mise binary
curl https://mise.run | sh

# Verify installation
~/.local/bin/mise --version
```

### 2. Activate in Shell

Choose your shell:

```bash
# Bash
echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc

# Zsh
echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc

# Fish
echo '~/.local/bin/mise activate fish | source' >> ~/.config/fish/config.fish
```

### 3. Restart Shell

```bash
exec $SHELL
```

### 4. Run PercyBrain Setup

```bash
cd ~/.config/nvim
mise run setup
```

**Expected Output**:

```
📦 Installing tools from mise.toml...
mise lua@5.1 ✓ installed
mise node@22.17.1 ✓ installed
mise python@3.12 ✓ installed
mise stylua@latest ✓ installed

🪝 Installing pre-commit hooks...
✅ Setup complete!
```

**Time**: ~3 minutes (depends on network speed)

______________________________________________________________________

## Daily Development Workflow

### Quick Commands (Aliased)

| Alias     | Full Command          | Purpose             | Time  |
| --------- | --------------------- | ------------------- | ----- |
| `mise t`  | `mise run test`       | Run all tests       | 5-10s |
| `mise l`  | `mise run lint`       | Luacheck analysis   | 2-3s  |
| `mise f`  | `mise run format`     | Auto-format code    | 1-2s  |
| `mise q`  | `mise run quick`      | Lint + format check | 2-5s  |
| `mise gs` | `mise run git:status` | Enhanced git status | 1s    |
| `mise gb` | `mise run git:branch` | Branch details      | 1s    |

### Before Making Changes

```bash
# Check repository status
mise gs

# Quick validation (no changes made)
mise q
```

### During Development

```bash
# Auto-format code
mise f

# Run tests continuously (requires inotify-tools)
mise run test:watch

# Or run tests manually
mise t
```

### Before Committing

```bash
# Full quality check
mise run check
# → Runs: lint + format:check + test + hooks

# Or auto-fix issues
mise run fix
# → Runs: format + hooks
```

### Commit Workflow

```bash
git add .
git commit -m "feat: add new feature"
# Pre-commit hooks run automatically via mise
```

______________________________________________________________________

## Available Tasks

### Testing (4 tasks)

```bash
mise run test         # All unit tests (plenary + custom)
mise run test:ollama  # AI integration tests (requires Ollama)
mise run test:plenary # Plenary test suite only
mise run test:watch   # Continuous testing (requires inotify-tools)
```

**Alias**: `mise t` = `mise run test`

**When to Use**:

- `test`: Before commits, after changes
- `test:ollama`: When testing AI features
- `test:plenary`: When debugging plenary-specific issues
- `test:watch`: During active development

### Code Quality (3 tasks)

```bash
mise run lint          # Luacheck static analysis
mise run format        # Auto-format with stylua
mise run format:check  # Verify formatting (no changes)
```

**Aliases**: `mise l` = lint, `mise f` = format

**When to Use**:

- `lint`: Before commits, continuous
- `format`: Before commits, after writing
- `format:check`: CI/validation, pre-commit

### Pre-commit Hooks (3 tasks)

```bash
mise run hooks:install  # Install git hooks
mise run hooks:run      # Run all hooks manually
mise run hooks:update   # Update hook versions
```

**When to Use**:

- `hooks:install`: After cloning, first setup
- `hooks:run`: Test hooks before committing
- `hooks:update`: Monthly maintenance

### Git Operations (2 tasks)

```bash
mise run git:status  # Enhanced status with branch info
mise run git:branch  # List branches with commits
```

**Aliases**: `mise gs`, `mise gb`

**When to Use**:

- `git:status`: Instead of `git status` (more info)
- `git:branch`: Branch management, cleanup

### Composite Workflows (3 tasks)

```bash
mise run check  # Full: lint + format:check + test + hooks
mise run quick  # Fast: lint + format:check
mise run fix    # Auto: format + hooks
```

**Alias**: `mise q` = quick

**When to Use**:

- `check`: Before commits, comprehensive validation
- `quick`: Frequent checks during development
- `fix`: Auto-fix formatting and hook issues

### Development Setup (1 task)

```bash
mise run setup  # First-time setup (run once)
```

**Installs**: Tools, pre-commit hooks, runs initial tests

### Cleanup (2 tasks)

```bash
mise run clean       # Remove temp files, caches
mise run clean:full  # Deep clean (mise cache + pre-commit)
```

**When to Use**:

- `clean`: Weekly maintenance
- `clean:full`: Troubleshooting, disk space issues

### Neovim-Specific (2 tasks)

```bash
mise run nvim        # Launch Neovim with PercyBrain
mise run nvim:check  # Run health checks
```

**When to Use**:

- `nvim`: Alternative launch method
- `nvim:check`: Troubleshooting, diagnostics

______________________________________________________________________

## Common Usage Patterns

### Pattern: Test Specific Component

```bash
# AI tests only
mise run test:ollama

# Plenary suite only
mise run test:plenary

# Specific test file (via native plenary)
nvim --headless -c "PlenaryBustedFile tests/my_test.lua"
```

### Pattern: Check Formatting Without Changes

```bash
# See what stylua would change
mise run format:check

# Apply if needed
mise f
```

### Pattern: Update Pre-commit Hooks

```bash
# Update to latest versions
mise run hooks:update

# Test updated hooks
mise run hooks:run

# If successful, commit
git add .pre-commit-config.yaml
git commit -m "chore: update pre-commit hooks"
```

### Pattern: Clean Workspace

```bash
# Remove temporary files
mise run clean

# Deep clean (includes mise cache)
mise run clean:full
```

### Pattern: Full Validation Before Push

```bash
mise run check  # Comprehensive validation
git push
```

______________________________________________________________________

## Troubleshooting

### Tools Not Installing

**Symptom**: Tasks fail with "command not found"

**Solution**:

```bash
# Diagnose
mise doctor

# Manually install
mise install

# Verify
mise ls
# Should show: lua@5.1, node@22.17.1, python@3.12, stylua@latest
```

### Luacheck Not Found

**Symptom**: `mise run lint` fails

**Solution**: Luacheck must be installed via system package manager:

```bash
# Debian/Ubuntu
sudo apt install luacheck

# macOS
brew install luacheck

# Or via Cargo
cargo install luacheck
```

### Task Hangs or Fails

**Solution**:

```bash
# Verbose output
mise run test --verbose

# Check task definition
mise tasks ls

# View task details
mise task test
```

### Cache Issues (Task Not Re-running)

**Symptom**: Task doesn't run after file changes

**Solution**:

```bash
# Clear cache
mise cache clear

# Force re-run
mise run test --force
```

### Node.js Package Issues

**Symptom**: Neovim Node.js integration fails

**Solution**:

```bash
# Reinstall Node.js with postinstall hook
mise use node@22.17.1 --force
# Triggers: npm install -g neovim
```

### Test Watch Not Working

**Symptom**: `mise run test:watch` fails

**Solution**:

```bash
# Linux: Install inotify-tools
sudo apt install inotify-tools

# macOS: Use fswatch (requires manual task modification)
brew install fswatch
```

### Wrong Tool Version Active

**Solution**:

```bash
# Check active versions
mise current

# Check configured versions
mise ls

# Force version
mise use lua@5.1 --pin
```

______________________________________________________________________

## Advanced Usage

### Adding Custom Tasks

Edit `.mise.toml`:

```toml
[tasks.my-task]
description = "My custom task"
alias = "mt"
run = "echo 'Hello from mise'"
sources = ["lua/**/*.lua"]  # Optional: cache invalidation
depends = ["lint", "test"]  # Optional: dependencies
```

Test:

```bash
mise run my-task
# Or use alias
mise mt
```

### Task with Multiple Commands

```toml
[tasks.deploy]
description = "Deploy workflow"
run = """
#!/bin/bash
set -e
echo "Building..."
npm run build
echo "Testing..."
mise run test
echo "Deploying..."
./scripts/deploy.sh
"""
```

### Task-Specific Tool Versions

```toml
[tasks.old-node-build]
description = "Build with Node 18"
tools.node = "18"
run = "npm run build"
```

### Environment Variables in Tasks

```toml
[tasks.test-production]
description = "Test with production config"
env = { NODE_ENV = "production", LOG_LEVEL = "error" }
run = "mise run test"
```

### Conditional Task Execution

```toml
[tasks.linux-only]
description = "Linux-specific task"
run = "echo 'Running on Linux'"
os = ["linux"]  # Only runs on Linux
```

______________________________________________________________________

## Quick Reference

### Essential Commands

```bash
# Setup
mise install          # Install all tools
mise run setup        # First-time dev setup

# Daily workflow
mise t                # Test
mise l                # Lint
mise f                # Format
mise q                # Quick check
mise run check        # Full validation

# Utilities
mise tasks ls         # List all tasks
mise ls               # Show installed tools
mise doctor           # Diagnose issues
mise cache clear      # Clear cache
```

### Task Execution Options

```bash
# Basic
mise run <task>       # Run by name
mise <alias>          # Run by alias

# Options
mise run <task> --force     # Ignore cache
mise run <task> --verbose   # Detailed output
mise run <task> --dry-run   # Preview only

# Multiple tasks
mise run task1 task2        # Sequential
```

### Tool Management

```bash
# List versions
mise ls               # Installed
mise ls-remote node   # Available

# Install/update
mise install          # All from config
mise install node@20  # Specific version
mise use node@20      # Set in mise.toml

# Check status
mise current          # Active versions
mise tool <name>      # Tool details
```

______________________________________________________________________

## Best Practices

### Task Naming

✅ **Right**: `mise run test`, `mise run format`, `mise run check`

❌ **Wrong**: `mise run do-the-thing`, `mise run step1`

### Alias Strategy

✅ **Right**: 1-2 char aliases for frequent tasks (`t`, `l`, `f`)

❌ **Wrong**: Obscure abbreviations (`rpt`, `flc`)

### Source Tracking

✅ **Right**: Specific file patterns

```toml
[tasks.test]
sources = ["tests/**/*.lua", "lua/**/*.lua"]
```

❌ **Wrong**: Overly broad patterns

```toml
[tasks.test]
sources = ["**/*"]  # Re-runs on ANY file change
```

### Composite Tasks

✅ **Right**: Build from reusable tasks

```toml
[tasks.check]
depends = ["lint", "format:check", "test"]
```

❌ **Wrong**: Duplicate logic

```toml
[tasks.check]
run = """
luacheck lua/
stylua --check .
bash tests/run-all-unit-tests.sh
"""
```

______________________________________________________________________

## Integration Notes

### Pre-commit Hook Workflow

Mise tasks mirror pre-commit hooks for local validation:

| Mise Task            | Pre-commit Hook | Purpose            |
| -------------------- | --------------- | ------------------ |
| `mise run lint`      | luacheck        | Static analysis    |
| `mise run format`    | stylua          | Code formatting    |
| `mise run test`      | test-standards  | Quality validation |
| `mise run hooks:run` | All hooks       | Full validation    |

**Workflow**: Run `mise run check` before committing → Fewer hook failures

### Task Caching

Tasks only re-run when source files change:

```toml
[tasks.test]
sources = ["tests/**/*.lua", "lua/**/*.lua"]
# Cached unless Lua code changes
```

**Performance**: 95% faster on repeat runs

### Environment Variables

Mise sets:

```toml
LUA_PATH     = "./lua/?.lua;./lua/?/init.lua;;"
NODE_ENV     = "development"
NPM_CONFIG_* = Suppress noise
```

______________________________________________________________________

## Further Reading

- **Concepts & Rationale**: [MISE_RATIONALE.md](../explanation/MISE_RATIONALE.md) - Why Mise, architecture, comparisons
- **Official Docs**: <https://mise.jdx.dev>
- **PercyBrain Config**: `.mise.toml` in project root
- **Pre-commit Integration**: [PRECOMMIT_HOOKS.md](PRECOMMIT_HOOKS.md)
- **Testing Guide**: `docs/testing/` directory

______________________________________________________________________

*Mise handles the boring parts (tool versions, caching, orchestration) so developers focus on writing code.*
