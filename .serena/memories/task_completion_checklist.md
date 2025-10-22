# Task Completion Checklist for PercyBrain

When completing any development task in PercyBrain, follow this checklist:

## Pre-Implementation Checks

- [ ] Understand the writer-centric purpose (not programmer-centric) *(see project_overview for philosophy)*
- [ ] Check if similar plugin/functionality already exists *(see codebase_structure for existing capabilities)*
- [ ] Identify correct file location (`lua/plugins/`, `lua/config/`, or `lua/utils/`) *(see percy_development_patterns for organization rules)*
- [ ] Plan lazy loading strategy (event, cmd, keys, ft triggers) *(see percybrain_lazy_nvim_pattern for details)*

## During Implementation

### For Plugin Development

- [ ] Create single file in `lua/plugins/plugin-name.lua` *(see percybrain_lazy_nvim_pattern for spec structure)*
- [ ] Return lazy.nvim spec: `{ "author/repo", ... }`
- [ ] Use `opts = {}` instead of `config = {}` when possible
- [ ] Set `lazy = true` for lazy loading
- [ ] Define appropriate trigger (event, cmd, keys, ft)
- [ ] Add descriptive comments for writer-specific features
- [ ] Follow lazy loading patterns *(see percybrain_lazy_nvim_pattern for best practices)*
- [ ] Check for keymap conflicts *(see keymap_architecture_patterns for namespace organization)*

### For Configuration Changes

- [ ] Edit appropriate config file (globals.lua, keymaps.lua, options.lua) *(see configuration_patterns for guidelines)*
- [ ] Follow Lua style guide (2 spaces, snake_case) *(see style_and_conventions for standards)*
- [ ] Add `desc` field to all keymaps *(see keymap_architecture_patterns for documentation requirements)*
- [ ] Maintain writer-centric defaults (spell=true, wrap=true) *(see project_overview for core principles)*

### For Utility Modules

- [ ] Place in `lua/utils/` directory (NOT `lua/plugins/`) *(see percy_development_patterns for module organization)*
- [ ] Return module table: `local M = {} ... return M`
- [ ] Document usage in comments *(see documentation_strategy for patterns)*

### For Workflow Integration

- [ ] Consider cross-workflow interactions *(see workflow_integration_patterns for coordination strategies)*
- [ ] Verify GTD/Zettelkasten compatibility *(see gtd_system_architecture_2025-10-21 and iwe_telekasten_integration_patterns)*
- [ ] Test IWE LSP integration if applicable *(see iwe_telekasten_integration_patterns)*

## Testing Phase

### Layer 1: Static Validation (~5 seconds)

```bash
mise test:quick  # or ./scripts/validate.sh
```

Checks *(see testing_best_practices for comprehensive testing strategy)*:

- [ ] Lua syntax errors
- [ ] Duplicate plugin files
- [ ] Deprecated API usage
- [ ] File organization rules

### Layer 2: Structural Validation (~10 seconds)

```bash
mise test:quick  # Includes structural checks
```

Checks:

- [ ] Plugin spec structure correctness
- [ ] lazy.nvim field validation
- [ ] Keymap conflicts *(see keymap_architecture_patterns)*
- [ ] Circular dependencies

### Layer 3: Dynamic Validation (~60 seconds)

```bash
mise test  # Full test suite
# or ./scripts/validate.sh --full
```

Checks *(see testing_best_practices for test philosophy)*:

- [ ] Neovim starts without errors
- [ ] `:checkhealth` passes
- [ ] Plugin loads correctly
- [ ] LLM integration tests *(see llm_testing_framework if AI features involved)*

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
- [ ] Keybindings work correctly *(test with workflow context)*
- [ ] UI/UX follows design patterns *(see ui_design_patterns for consistency)*

## Documentation Updates

### CLAUDE.md Updates

- [ ] Add plugin to appropriate category section *(see documentation_strategy for organization)*
- [ ] Document plugin purpose (writer-focused)
- [ ] Add keyboard shortcuts if new keymaps *(see keymap_architecture_patterns for documentation format)*
- [ ] Update troubleshooting section if needed

### Keymap Documentation

If keymaps were added/changed:

```bash
./scripts/extract-keymaps.lua  # Generate updated keymap table
# Copy output to CLAUDE.md
```

- [ ] Verify keymap namespace consistency *(see keymap_architecture_patterns)*
- [ ] Document workflow integration *(see workflow_integration_patterns)*

### README.md Updates (if major feature)

- [ ] Update feature list *(see project_overview for positioning)*
- [ ] Add screenshots if UI-related *(see ui_design_patterns)*
- [ ] Update installation requirements if needed

## Git Workflow

### Pre-Commit

```bash
git status
git add [changed-files]
git commit -m "type: description"
```

Automatic checks (pre-commit hook) *(see quality_automation_patterns for hook details)*:

- [ ] Layer 1-2 validation passes
- [ ] Style guide enforcement *(see style_and_conventions)*

### Pre-Push

```bash
mise test  # Manual full validation
git push origin branch-name
```

Automatic checks (pre-push hook) *(see quality_automation_patterns)*:

- [ ] Layer 1-3 validation passes

### Commit Message

- [ ] Follows Conventional Commits format *(see percy_development_patterns)*
- [ ] Type: feat/fix/docs/refactor/test/chore
- [ ] Clear, concise description
- [ ] References issue if applicable

## Final Checklist

### Code Quality

- [ ] No duplicate code *(see percy_development_patterns for DRY principles)*
- [ ] Follows Lua style guide *(see style_and_conventions)*
- [ ] Comments explain writer-specific features
- [ ] No deprecated APIs *(validated by test suite)*

### Functionality

- [ ] Works on Linux (primary platform) *(see percybrain_workspace for environment details)*
- [ ] Doesn't break existing functionality *(regression tests via mise test)*
- [ ] Writer-centric features maintained *(see project_overview for core principles)*
- [ ] Lazy loading works correctly *(see percybrain_lazy_nvim_pattern)*

### Documentation

- [ ] CLAUDE.md updated *(see documentation_strategy for structure)*
- [ ] Keyboard shortcuts documented *(see keymap_architecture_patterns)*
- [ ] Plugin purpose clearly explained
- [ ] Cross-references added to relevant patterns

### Testing

- [ ] Layer 1-2 validation passes (standard) *(see testing_best_practices)*
- [ ] Layer 3 validation passes (full)
- [ ] Manual testing completed
- [ ] No errors in `:messages`
- [ ] LLM tests pass if AI features *(see llm_testing_framework)*

## Skip Validation Only If:

- Experimental/WIP work (use `SKIP_VALIDATION=1`)
- Quick documentation fix (minor typos)
- Deliberate temporary state

**Note**: CI will still run validation, so skipping locally only defers checks.

## Post-Merge (for maintainers)

- [ ] Update lazy-lock.json if dependencies changed *(see configuration_patterns)*
- [ ] Tag release if significant feature *(see semver_automation_implementation)*
- [ ] Announce in discussions/community channels
- [ ] Close related issues

______________________________________________________________________

## Reference Patterns

This checklist integrates knowledge from these strategic memory patterns:

### Architecture & Organization

- **project_overview**: Core philosophy, writer-centric principles, system purpose
- **codebase_structure**: Directory organization, module locations, existing capabilities
- **architecture**: High-level system design, component relationships
- **percy_development_patterns**: Development workflows, organizational rules, DRY principles

### Plugin & Configuration

- **percybrain_lazy_nvim_pattern**: Lazy loading strategies, plugin spec structure, best practices
- **configuration_patterns**: Config file guidelines, settings management, environment setup
- **keymap_architecture_patterns**: Keymap namespace organization, documentation requirements, conflict prevention
- **workflow_integration_patterns**: Cross-workflow coordination, integration strategies

### Testing & Quality

- **testing_best_practices**: Test philosophy, validation layers, capability-driven testing
- **quality_automation_patterns**: Pre-commit hooks, CI/CD, automated quality gates
- **llm_testing_framework**: AI feature testing, LLM integration validation
- **style_and_conventions**: Lua style guide, naming conventions, code standards

### Documentation & Communication

- **documentation_strategy**: Documentation organization, structure patterns, maintenance
- **ui_design_patterns**: UI/UX consistency, design principles, visual patterns
- **percy_as_cognitive_compiler**: System philosophy, cognitive architecture rationale

### Domain-Specific

- **gtd_system_architecture_2025-10-21**: GTD workflow implementation, task management
- **iwe_telekasten_integration_patterns**: IWE LSP integration, Zettelkasten workflows
- **semver_automation_implementation**: Versioning strategy, release automation

### Quick References

- **percybrain_quick_reference**: Fast lookup, common commands, troubleshooting
- **suggested_commands**: Development commands, testing shortcuts, workflow helpers
- **percybrain_workspace**: Environment details, platform specifics, tooling setup

**Usage**: When checking a box in this checklist, consult the referenced memory for detailed guidance on that specific aspect of the task.
