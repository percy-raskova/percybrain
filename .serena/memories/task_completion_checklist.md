# Task Completion Checklist for OVIWrite

When completing any development task in OVIWrite, follow this checklist:

## Pre-Implementation Checks

- [ ] Understand the writer-centric purpose (not programmer-centric)
- [ ] Check if similar plugin/functionality already exists
- [ ] Identify correct file location (`lua/plugins/`, `lua/config/`, or `lua/utils/`)
- [ ] Plan lazy loading strategy (event, cmd, keys, ft triggers)

## During Implementation

### For Plugin Development

- [ ] Create single file in `lua/plugins/plugin-name.lua`
- [ ] Return lazy.nvim spec: `{ "author/repo", ... }`
- [ ] Use `opts = {}` instead of `config = {}` when possible
- [ ] Set `lazy = true` for lazy loading
- [ ] Define appropriate trigger (event, cmd, keys, ft)
- [ ] Add descriptive comments for writer-specific features

### For Configuration Changes

- [ ] Edit appropriate config file (globals.lua, keymaps.lua, options.lua)
- [ ] Follow Lua style guide (2 spaces, snake_case)
- [ ] Add `desc` field to all keymaps
- [ ] Maintain writer-centric defaults (spell=true, wrap=true)

### For Utility Modules

- [ ] Place in `lua/utils/` directory (NOT `lua/plugins/`)
- [ ] Return module table: `local M = {} ... return M`
- [ ] Document usage in comments

## Testing Phase

### Layer 1: Static Validation (~5 seconds)

```bash
./scripts/validate.sh
```

Checks:

- [ ] Lua syntax errors
- [ ] Duplicate plugin files
- [ ] Deprecated API usage
- [ ] File organization rules

### Layer 2: Structural Validation (~10 seconds)

```bash
./scripts/validate.sh
```

Checks:

- [ ] Plugin spec structure correctness
- [ ] lazy.nvim field validation
- [ ] Keymap conflicts
- [ ] Circular dependencies

### Layer 3: Dynamic Validation (~60 seconds)

```bash
./scripts/validate.sh --full
```

Checks:

- [ ] Neovim starts without errors
- [ ] `:checkhealth` passes
- [ ] Plugin loads correctly

### Manual Testing

```vim
nvim
:Lazy load plugin-name
:PluginCommand
:messages  " Check for errors
```

Verify:

- [ ] Plugin functionality works as expected
- [ ] No error messages
- [ ] Writer-centric features work (spell check, wrapping, etc.)
- [ ] Keybindings work correctly

## Documentation Updates

### CLAUDE.md Updates

- [ ] Add plugin to appropriate category section
- [ ] Document plugin purpose (writer-focused)
- [ ] Add keyboard shortcuts if new keymaps
- [ ] Update troubleshooting section if needed

### Keymap Documentation

If keymaps were added/changed:

```bash
./scripts/extract-keymaps.lua  # Generate updated keymap table
# Copy output to CLAUDE.md
```

### README.md Updates (if major feature)

- [ ] Update feature list
- [ ] Add screenshots if UI-related
- [ ] Update installation requirements if needed

## Git Workflow

### Pre-Commit

```bash
git status
git add [changed-files]
git commit -m "type: description"
```

Automatic checks (pre-commit hook):

- [ ] Layer 1-2 validation passes

### Pre-Push

```bash
./scripts/validate.sh --full  # Manual full validation
git push origin branch-name
```

Automatic checks (pre-push hook):

- [ ] Layer 1-3 validation passes

### Commit Message

- [ ] Follows Conventional Commits format
- [ ] Type: feat/fix/docs/refactor/test/chore
- [ ] Clear, concise description

## Final Checklist

### Code Quality

- [ ] No duplicate code
- [ ] Follows Lua style guide
- [ ] Comments explain writer-specific features
- [ ] No deprecated APIs

### Functionality

- [ ] Works on Linux (primary platform)
- [ ] Doesn't break existing functionality
- [ ] Writer-centric features maintained
- [ ] Lazy loading works correctly

### Documentation

- [ ] CLAUDE.md updated
- [ ] Keyboard shortcuts documented
- [ ] Plugin purpose clearly explained

### Testing

- [ ] Layer 1-2 validation passes (standard)
- [ ] Layer 3 validation passes (full)
- [ ] Manual testing completed
- [ ] No errors in `:messages`

## Skip Validation Only If:

- Experimental/WIP work (use `SKIP_VALIDATION=1`)
- Quick documentation fix (minor typos)
- Deliberate temporary state

**Note**: CI will still run validation, so skipping locally only defers checks.

## Post-Merge (for maintainers)

- [ ] Update lazy-lock.json if dependencies changed
- [ ] Tag release if significant feature
- [ ] Announce in discussions/community channels
- [ ] Close related issues
