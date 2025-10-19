# OVIWrite Suggested Commands

## Development Workflow Commands

### Basic Neovim Operations

```bash
# Start Neovim
nvim

# Start with specific file
nvim lua/plugins/my-plugin.lua

# Check Neovim version
nvim --version
```

### Plugin Management (from within Neovim)

```vim
:Lazy                   " Open lazy.nvim UI
:Lazy sync              " Update all plugins
:Lazy load all          " Load all lazy plugins immediately
:Lazy clean             " Remove unused plugins
:Lazy restore           " Restore from lazy-lock.json
:Lazy log               " View lazy.nvim logs
:Lazy load plugin-name  " Load specific plugin
:Lazy reload plugin     " Reload plugin configuration
```

### Health and Diagnostics

```vim
:checkhealth            " Diagnose Neovim setup issues
:Lazy health            " Check lazy.nvim plugin health
```

### Configuration Reload

```vim
" After editing configs
:source ~/.config/nvim/init.lua
:source ~/.config/nvim/lua/config/init.lua
:luafile %              " Reload current Lua file
```

## Validation System

### Standard Validation (Layer 1-2, ~15 seconds)

```bash
# Run before committing
./scripts/validate.sh
```

### Full Validation (Layer 1-4, ~90 seconds)

```bash
# Run before pushing
./scripts/validate.sh --full
```

### Specific Validation Checks

```bash
# Check for duplicate plugins
./scripts/validate.sh --check duplicates

# Check for deprecated APIs
./scripts/validate.sh --check deprecated-apis

# Validate markdown formatting
./scripts/validate.sh --check markdown

# Test Neovim startup
./scripts/validate.sh --check startup

# Run health check
./scripts/validate.sh --check health

# Test plugin loading
./scripts/validate.sh --check plugins

# Validate documentation sync
./scripts/validate.sh --check docs
```

### Development Environment Setup

```bash
# First-time setup (install git hooks, test scripts)
./scripts/setup-dev-env.sh

# Extract keymaps to markdown table
./scripts/extract-keymaps.lua
```

## Git Workflow

### Standard Git Operations

```bash
# Check status and branch
git status
git branch

# Create feature branch
git checkout -b feature/my-new-plugin

# Stage and commit (runs pre-commit hook = Layer 1-2 validation)
git add lua/plugins/my-plugin.lua
git commit -m "feat: add my-plugin for improved writing flow"

# Push (runs pre-push hook = Layer 1-3 validation)
git push origin feature/my-new-plugin
```

### Skip Validation (Use Sparingly)

```bash
# Skip pre-commit hook
SKIP_VALIDATION=1 git commit -m "WIP: experimental feature"

# Skip pre-push hook
SKIP_VALIDATION=1 git push

# Or use git's built-in skip
git push --no-verify
```

### LazyGit (Visual Git Interface)

```vim
" From within Neovim
<leader>g               " Open LazyGit UI
```

## Testing and Debugging

### Test Plugin in Neovim

```bash
# Start Neovim
nvim

# Load plugin manually
:Lazy load my-plugin

# Test plugin command
:MyPluginCommand

# Check for errors
:messages
```

### Test Specific File

```bash
# Test Lua syntax
nvim --headless -c "luafile lua/plugins/my-plugin.lua" -c "quit"
```

### Clear Cache and Retest

```bash
# Remove lazy.nvim cache
rm -rf ~/.local/share/nvim/lazy

# Retest
./scripts/validate.sh --full
```

## Keyboard Shortcuts (from within Neovim)

### Core Operations

- `<leader>e` - Toggle file tree (NvimTree)
- `<leader>x` - Focus file tree
- `<leader>s` - Save file
- `<leader>q` - Quit (force)
- `<leader>l` - Lazy load all plugins
- `<leader>L` - Open Lazy menu
- `<leader>w` - WhichKey (show keybindings)
- `<leader>g` - LazyGit

### Writing Modes

- `<leader>z` - ZenMode (distraction-free)
- `<leader>o` - Goyo (minimalist writing)
- `<leader>sp` - SoftPencil (soft line wrapping)

### Search

- `<leader>fzl` - Find files (FzfLua)
- `<leader>fzg` - Live grep (search text)

## Common Development Tasks

### Add New Plugin

```bash
# 1. Create plugin file
nvim lua/plugins/my-plugin.lua

# 2. Validate structure
./scripts/validate.sh

# 3. Test in Neovim
nvim
:Lazy load my-plugin

# 4. Document plugin
# Add to CLAUDE.md under appropriate section
```

### Update Existing Plugin

```bash
# 1. Edit plugin file
nvim lua/plugins/existing-plugin.lua

# 2. Test changes
./scripts/validate.sh --full

# 3. Update docs if needed
./scripts/extract-keymaps.lua  # If keymaps changed
```

### Fix Validation Errors

```bash
# Find duplicates
./scripts/validate.sh --check duplicates

# Check deprecated APIs
./scripts/validate.sh --check deprecated-apis

# Test startup
./scripts/validate.sh --check startup
```

## System-Specific Commands (Linux)

Standard Linux utilities work as expected:

- `ls`, `cd`, `pwd`, `mkdir`, `rm`, `mv`, `cp`
- `grep`, `find`, `cat`, `less`, `head`, `tail`
- `git` - Version control
- `nvim` - Editor
