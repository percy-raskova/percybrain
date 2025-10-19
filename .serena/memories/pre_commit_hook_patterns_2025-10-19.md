# Pre-commit Hook Patterns and Validator Design

**Context**: Session 2025-10-19 - Phase 1 quality baseline implementation **Outcome**: 14/14 pre-commit hooks passing, 19→0 luacheck warnings, 13/13 test files meeting 6/6 standards

## Critical Validator Bugs Fixed

### Bug 1: Quote Style Inflexibility (test-standards-validator)

**Problem**: Pattern matching only handled single quotes, broke after stylua reformatting to double quotes **Location**: `hooks/validate-test-standards.lua:13-14` **Fix**: Use flexible pattern: `content:match('require%(["\']tests%.helpers["\']%)')` **Impact**: 3 files falsely failing "Helper/Mock Imports" rule after stylua formatting

### Bug 2: "Local Helper Functions" False Positive

**Problem**: Validator checked for presence of `local function` keyword instead of absence of non-local functions **Location**: `hooks/validate-test-standards.lua:62-85` **Fix**: Proper scoping check - only fail if non-local function definitions exist (excluding describe/it/before_each/after_each) **Impact**: Files without helper functions were falsely flagging as violations

### Bug 3: "No Global Pollution" False Positive

**Problem**: Blanket ban on `_G` usage prevented legitimate global pollution testing **Location**: `hooks/validate-test-standards.lua:43-61` **Fix**: Allow `_G` references when context indicates intentional testing (keywords: "global pollution", "inspect \_G", "doesn't leak global") **Impact**: Test files validating for global namespace pollution were incorrectly failing

## Luacheck Configuration Patterns

### Per-File Exemptions Strategy

**Pattern**: Use `.luacheckrc` file-specific configurations for intentional test patterns

```lua
files["tests/helpers/assertions.lua"] = {
  globals = { "assert" }, -- Allow extending assert global (test framework pattern)
}

files["tests/helpers/mocks.lua"] = {
  ignore = { "M" }, -- Ignore unused module table assignments (export pattern)
}

files["tests/plenary/unit/config_spec.lua"] = {
  globals = { "_G" }, -- Allow _G for global pollution detection tests
}
```

### Common Luacheck Warning Patterns

- **W211 (unused variable)**: Remove if genuinely unused, use `_` for intentional loop variables
- **W213 (unused loop variable)**: Replace with `_` to signal intentionality
- **W231 (variable never accessed)**: Remove variable or use if needed for side effects
- **W314 (duplicate field assignment)**: Merge duplicate configurations, keep final value
- **W542 (empty if branch)**: Replace with assignment or comment explaining intent
- **W631 (line too long)**: Split lines, shorten comments, use abbreviations

## Test Standards Validator Design Principles

### 1. Context-Aware Validation

**Don't**: Blanket pattern bans without context **Do**: Check for explanatory keywords/comments indicating intentional patterns **Example**: Allow `_G` when comment contains "global pollution" or "testing for"

### 2. Quote Style Flexibility

**Don't**: Hard-code quote styles in pattern matching **Do**: Use flexible patterns: `["\']` for both single and double quotes **Rationale**: Formatters like stylua may change quote styles, breaking validators

### 3. Proper Scoping Logic

**Don't**: Check for presence of good patterns (local keyword) **Do**: Check for absence of bad patterns (non-local function definitions) **Rationale**: Files without helper functions should pass, not fail

### 4. False Positive Minimization

**Priority**: 100% accuracy > coverage - wrong validation breaks trust **Strategy**: Conservative matching with explicit exemptions **Validation**: Test validator against 13 diverse test files before deployment

## Stylua Integration Workflow

### Post-Hook File Modification Pattern

**Challenge**: Stylua auto-fixes files after `git add`, causing commit to fail **Solution**: Run `stylua .` manually before commit to apply all changes upfront **Workflow**:

```bash
# Fix code issues
# Run stylua manually to apply ALL formatting
stylua .
# Stage all changes (including stylua modifications)
git add -A
# Commit (stylua hook will pass, no new modifications)
git commit -m "message"
```

## Systematic Quality Fix Workflow

### Phase Pattern (used in this session)

1. **Discovery**: Run hooks to identify all violations (luacheck, test-standards)
2. **Analysis**: Group violations by type and file for systematic fixing
3. **Fix Systematically**: Address one violation type at a time across all files
4. **Validate Incrementally**: Re-run hooks after each fix batch to catch regressions
5. **Final Validation**: All hooks pass before commit

### Avoiding Hook Bypass Trap

**DON'T**: Use `SKIP=hook-name git commit` to bypass failing hooks **DO**: Fix issues properly before committing **Rationale**: Hooks enforce quality standards - bypassing defeats purpose and accumulates technical debt

## Luacheck Warning Fix Patterns

### Unused Variables (W211, W213)

```lua
-- BEFORE (warning):
for i = 1, 10 do
  vim.cmd("split")
end

-- AFTER (no warning):
for _ = 1, 10 do  -- '_' signals intentionally unused
  vim.cmd("split")
end
```

### Duplicate Field Assignments (W314)

```lua
-- BEFORE (warning):
config = {
  pre_save_cmds = { "cmd1" },  -- Line 34
  post_restore_cmds = {},
  pre_save_cmds = { "cmd2" },  -- Line 59 OVERWRITES
}

-- AFTER (no warning):
config = {
  pre_save_cmds = { "cmd1", "cmd2" },  -- Merged
  post_restore_cmds = {},
}
```

### Line Length (W631)

```lua
-- BEFORE (139 chars - warning):
keymap.set("n", "<leader>W", ":WhichKey<CR>", { noremap = true, silent = true }) -- Changed from <leader>w to avoid window manager conflict

-- AFTER (99 chars - no warning):
keymap.set("n", "<leader>W", ":WhichKey<CR>", { noremap = true, silent = true }) -- Avoid window mgr conflict
```

## Token Efficiency Documentation Pattern (CLAUDE.md)

### Compression Techniques Applied

1. **Symbol Shortcuts**: `→ ✅ ❌ ≥` for relationships and status
2. **Grouping**: `{zettelkasten(6)|ai-sembr(3)|prose-writing(14)}` instead of 14 separate lines
3. **Reference Model**: Point to docs instead of duplicating content
4. **Compressed Syntax**: Eliminate unnecessary whitespace and verbosity

**Result**: 621→124 lines (80% reduction) while preserving 100% of critical information

## Cross-Session Learnings

### Validator Development Lessons

1. **Test validators against diverse real files before deployment** - catches edge cases
2. **Handle formatter interactions** - quote styles, whitespace changes
3. **Conservative false positive tolerance** - accuracy > coverage for validation tools
4. **Context-aware exemptions** - don't blanket ban patterns, check for explanatory context

### Quality Enforcement Workflow

1. **Fix issues properly, never bypass hooks** - maintains quality standards and team trust
2. **Run formatters manually before commit** - prevents post-hook file modification loops
3. **Systematic fixes over piecemeal** - group by violation type for efficiency
4. **Incremental validation** - catch regressions early with re-runs after each fix batch

### Documentation Token Optimization

1. **Symbols replace verbose text** - `→` instead of "leads to"
2. **Grouping reduces redundancy** - list items with `|` separator
3. **Reference model over duplication** - point to source docs
4. **Compression maintains clarity** - verify 100% information preservation
