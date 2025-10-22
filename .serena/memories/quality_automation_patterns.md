# Quality Automation Patterns - PercyBrain

**Purpose**: Consolidated patterns for pre-commit hooks, health checks, semantic versioning, and CI/CD validation **Sources**: pre_commit_hook_patterns, health_check_analysis, semver_automation_implementation (2025-10-19/17)

## Pre-commit Hooks Architecture

### Core Configuration (.pre-commit-config.yaml)

```yaml
repos:
  - repo: https://github.com/JohnnyMorganz/StyLua
    hooks:
      - id: stylua          # Auto-format Lua code

  - repo: local
    hooks:
      - id: luacheck        # Static analysis (0 warnings required)
      - id: test-standards  # 6/6 test file standards
      - id: debug-detector  # Block debug artifacts
```

### Critical Validator Patterns

#### Pattern 1: Quote Style Flexibility

```lua
-- DON'T: Hard-code quote styles
content:match("require%('tests%.helpers'%)")

-- DO: Support both single and double quotes
content:match('require%(["\']tests%.helpers["\']%)')
```

**Rationale**: Formatters like stylua may change quote styles, breaking validators

#### Pattern 2: Context-Aware Exemptions

```lua
-- DON'T: Blanket ban patterns
if content:match("_G") then
  fail("No _G usage")
end

-- DO: Check for explanatory context
local is_testing_globals = content:match("global pollution")
                        or content:match("inspect _G")
                        or content:match("doesn't leak global")
if content:match("_G") and not is_testing_globals then
  fail("Global pollution detected")
end
```

**Rationale**: Legitimate test patterns need exemptions with context validation

#### Pattern 3: Proper Scoping Logic

```lua
-- DON'T: Check for presence of good patterns
if not content:match("local function") then
  fail("No local helper functions")
end

-- DO: Check for absence of bad patterns
local has_nonlocal_functions = content:match("^function ")
                             or content:match("\nfunction ")
if has_nonlocal_functions and not_exempted then
  fail("Non-local function definitions detected")
end
```

**Rationale**: Files without helper functions should pass, not fail

### Luacheck Configuration Patterns

#### File-Specific Exemptions (.luacheckrc)

```lua
files["tests/helpers/assertions.lua"] = {
  globals = { "assert" },  -- Allow extending assert global (test framework)
}

files["tests/helpers/mocks.lua"] = {
  ignore = { "M" },  -- Ignore unused module exports
}

files["tests/plenary/unit/config_spec.lua"] = {
  globals = { "_G" },  -- Allow _G for global pollution testing
}
```

#### Common Warning Fix Patterns

**W211/W213 (Unused Variables)**:

```lua
-- Before (warning):
for i = 1, 10 do
  vim.cmd("split")
end

-- After (no warning):
for _ = 1, 10 do  -- '_' signals intentionally unused
  vim.cmd("split")
end
```

**W314 (Duplicate Fields)**:

```lua
-- Before (warning):
config = {
  pre_save_cmds = { "cmd1" },   -- Line 34
  post_restore_cmds = {},
  pre_save_cmds = { "cmd2" },   -- Line 59 overwrites
}

-- After (no warning):
config = {
  pre_save_cmds = { "cmd1", "cmd2" },  -- Merged
  post_restore_cmds = {},
}
```

**W631 (Line Length)**:

```lua
-- Before (139 chars):
keymap.set("n", "<leader>W", ":WhichKey<CR>", { noremap = true, silent = true }) -- Changed from <leader>w to avoid window manager conflict

-- After (99 chars):
keymap.set("n", "<leader>W", ":WhichKey<CR>", { noremap = true, silent = true }) -- Avoid win mgr conflict
```

### Hook Workflow Patterns

#### Stylua Integration (Post-Hook File Modification)

```bash
# PROBLEM: Stylua modifies files after 'git add', causing commit to fail
# SOLUTION: Run stylua manually before staging

stylua .           # Apply all formatting changes
git add -A         # Stage all changes (including stylua mods)
git commit -m "x"  # Commit (stylua hook passes, no new mods)
```

#### Systematic Quality Fix Workflow

1. **Discovery**: Run hooks to identify all violations
2. **Analysis**: Group violations by type and file
3. **Fix Systematically**: One violation type at a time across all files
4. **Validate Incrementally**: Re-run hooks after each batch
5. **Final Validation**: All hooks pass before commit

**DON'T**: Use `SKIP=hook-name git commit` to bypass failures **DO**: Fix issues properly to maintain quality standards

## Health Check Patterns

### Native Integration (vim.health API)

```lua
-- lua/percybrain/health.lua (discovered by :checkhealth)
local M = {}

function M.check()
  vim.health.start("PercyBrain Core")

  -- Success check
  local treesitter_ok = require("config.treesitter-health-fix").verify()
  if treesitter_ok then
    vim.health.ok("Python Treesitter parser functioning correctly")
  else
    vim.health.error("Python parser except* syntax issue", {
      "Run :PercyBrainHealthFix to apply automatic fix",
      "Or manually update: :TSUpdate python"
    })
  end

  -- Warning check
  local session_ok = require("config.session-health-fix").verify()
  if session_ok then
    vim.health.ok("Session options configured correctly")
  else
    vim.health.warn("Missing localoptions in sessionoptions", {
      "Run :PercyBrainHealthFix to add required options"
    })
  end

  -- Info context
  vim.health.info("Additional diagnostic information")
end

return M
```

### Fix Module Pattern with Verification

```lua
-- lua/config/[component]-health-fix.lua
local M = {}

function M.verify()
  -- Check if fix is needed
  local current_state = vim.opt.sessionoptions:get()
  return vim.list_contains(current_state, "localoptions")
end

function M.apply()
  if not M.verify() then
    vim.opt.sessionoptions:append("localoptions")
    return true  -- Fix applied
  end
  return false  -- No fix needed
end

return M
```

### Dual Validation Strategy

**TDD Tests (CI/CD)**:

- Automated validation in CI/CD pipeline
- Fast feedback during development
- Regression prevention

**vim.health Integration (Interactive)**:

- User-facing validation and guidance
- Actionable advice for repairs
- Standard :checkhealth workflow

**Pattern**: Both systems validate same fixes, different audiences

### Plugin Health Check Ecosystem

**Standard Pattern**: Every plugin provides `lua/[plugin-name]/health.lua`

Examples:

- `lazy.nvim` → `lua/lazy/health.lua` (plugin manager)
- `mason.nvim` → `lua/mason/health.lua` (LSP/DAP/linter)
- `nvim-treesitter` → `lua/nvim-treesitter/health.lua` (parser status)

## Semantic Versioning Automation

### Release Workflow (Manual Control)

```bash
# 1. Solo dev creates tag (controls release timing)
git tag v1.2.3 -m "Release 1.2.3: Summary"

# 2. Push tag triggers automation
git push origin v1.2.3

# 3. GitHub Actions automation (~3-5 min):
#    - Validates version format (MAJOR.MINOR.PATCH)
#    - Runs test suite (must pass)
#    - Generates lua/oviwrite/version.lua
#    - Generates CHANGELOG from git log
#    - Creates GitHub Release with artifacts
```

### Version Decision Tree

**MAJOR** (Breaking changes):

- API changes requiring user code updates
- Removed features or deprecated functionality
- Configuration format changes

**MINOR** (New features):

- New features (backward compatible)
- Enhanced functionality preserving existing APIs
- New commands or keybindings

**PATCH** (Bug fixes):

- Bug fixes (non-breaking)
- Documentation improvements
- Performance optimizations

### Version.lua API Pattern

```lua
-- Auto-generated: lua/oviwrite/version.lua (gitignored)
return {
  version = "1.2.3",
  major = 1,
  minor = 2,
  patch = 3,
  tag = "v1.2.3",
  release_date = "2025-10-17",

  is_at_least = function(self, required_version)
    -- Version comparison logic
  end,

  get_info = function(self)
    return string.format("PercyBrain %s (released %s)",
                         self.tag, self.release_date)
  end
}
```

**Usage**:

```lua
local version = require('oviwrite.version')
if version:is_at_least("1.2.0") then
  -- Use feature introduced in 1.2.0
end
```

### GitHub Actions Release Workflow

```yaml
# .github/workflows/release.yml
name: Release
on:
  push:
    tags: ['v*']

jobs:
  release:
    steps:
      - name: Validate version format
        run: echo "${{ github.ref_name }}" | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$'

      - name: Run test suite
        run: ./tests/simple-test.sh

      - name: Generate version.lua
        run: ./scripts/generate-version.sh "$VERSION"

      - name: Generate changelog
        run: ./scripts/generate-changelog.sh "$TAG"

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v1
        with:
          body_path: CHANGELOG-release.md
```

### Script Patterns

**Version Generator** (scripts/generate-version.sh):

```bash
VERSION=$1  # e.g., "1.2.3"
TAG="v${VERSION}"
DATE=$(date +%Y-%m-%d)

cat > lua/oviwrite/version.lua <<EOF
-- Auto-generated by release workflow
return {
  version = "${VERSION}",
  major = ${MAJOR},
  minor = ${MINOR},
  patch = ${PATCH},
  tag = "${TAG}",
  release_date = "${DATE}",
  is_at_least = function(self, required) ... end,
  get_info = function(self) ... end
}
EOF
```

**Changelog Generator** (scripts/generate-changelog.sh):

```bash
TAG=$1
PREV_TAG=$(git describe --tags --abbrev=0 "${TAG}^" 2>/dev/null || echo "")

if [ -z "$PREV_TAG" ]; then
  # First release: all commits
  git log --pretty=format:"- %s (%h)" > CHANGELOG-release.md
else
  # Subsequent: commits since previous tag
  git log "${PREV_TAG}..${TAG}" --pretty=format:"- %s (%h)" > CHANGELOG-release.md
fi
```

## CI/CD Validation Patterns

### Test Suite Integration

**Pre-Release Validation**:

```yaml
# Test must pass before release creation
- name: Run test suite
  run: |
    ./tests/simple-test.sh
    mise test:quick
```

**Quality Gate Enforcement**:

- Luacheck: 0 warnings required
- Test standards: 6/6 compliance
- Startup tests: Clean boot required
- Integration tests: All passing

### Parallel Workflow Strategy

**Three Independent Workflows**:

1. `lua-quality.yml` - Static analysis on every push
2. `percybrain-tests.yml` - Test suite on PR/push to main
3. `release.yml` - Semantic versioning on tag push

**Pattern**: Each workflow has distinct trigger and purpose, no overlap

### Caching Strategy

```yaml
- name: Cache Lua tools
  uses: actions/cache@v3
  with:
    path: |
      ~/.luarocks
      ~/.cache/nvim
    key: ${{ runner.os }}-lua-${{ hashFiles('**/lazy-lock.json') }}
```

**Benefits**: Faster CI runs, reduced GitHub Actions minutes usage

## Testing Validation Standards (6/6)

1. **Helper/Mock Imports** (when used):

   - `require("tests.helpers")` or `require("tests.helpers.assertions")`
   - Flexible quote style matching

2. **before_each/after_each** (lifecycle management):

   - Setup and teardown for test isolation
   - Clean global state between tests

3. **AAA Comments** (readability):

   ```lua
   -- Arrange
   local input = "test"
   -- Act
   local result = process(input)
   -- Assert
   assert.are.equal("expected", result)
   ```

4. **No \_G Pollution** (namespace cleanliness):

   - Except when testing for global pollution (context-aware)

5. **Local Helper Functions** (scoping):

   - All helpers use `local function` keyword
   - No non-local function definitions

6. **No Raw assert.contains**:

   - Use custom assertions from helpers
   - Better error messages and debugging

## Design Philosophy

### Automation Principles

1. **Manual Control**: Solo dev decides when to release (git tags)
2. **Zero Maintenance**: Changelogs auto-generate from commits
3. **Fail-Safe**: Tests must pass before releases
4. **Extensible**: Room for conventional commits later

### Quality Gate Philosophy

1. **100% Accuracy > Coverage**: Wrong validation breaks trust
2. **Conservative Exemptions**: Context-aware, not blanket bans
3. **Incremental Validation**: Catch regressions early
4. **Never Bypass Hooks**: Fix issues properly, maintain standards

### Health Check Strategy

1. **Dual Validation**: TDD tests (CI/CD) + vim.health (interactive)
2. **Actionable Guidance**: Clear instructions for fixes
3. **Automatic Repairs**: One-command fixes when possible
4. **Standard Integration**: Use vim.health API for ecosystem compatibility

## Token Efficiency Patterns

### Documentation Compression

- **Symbols**: `✅ ❌ → ⇒` for status and relationships
- **Grouping**: `{component(n)|category(m)}` instead of lists
- **Reference Model**: Point to docs, don't duplicate
- **Result**: 621→124 lines (80% reduction) with 100% information preservation

### Code Comment Optimization

```lua
-- Before (139 chars):
-- Changed from <leader>w to avoid window manager conflict

-- After (99 chars):
-- Avoid win mgr conflict
```

**Balance**: Clarity preserved while meeting line length limits

## Cross-Session Learnings

### Validator Development

1. Test validators against diverse real files before deployment
2. Handle formatter interactions (quote styles, whitespace)
3. Conservative false positive tolerance (accuracy > coverage)
4. Context-aware exemptions (check for explanatory context)

### Quality Enforcement

1. Fix issues properly, never bypass hooks
2. Run formatters manually before commit
3. Systematic fixes over piecemeal (group by violation type)
4. Incremental validation (re-run after each batch)

### Release Management

1. Manual tags give solo devs release timing control
2. Auto-generated changelogs reduce maintenance
3. Version API enables feature gating
4. GitHub Actions handles distribution
