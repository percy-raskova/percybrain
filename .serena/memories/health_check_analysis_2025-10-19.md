# Health Check Validation Analysis - PercyBrain

**Date**: 2025-10-19 **Context**: Investigating Neovim health check augmentation patterns and plugin ecosystem

## Key Findings

### 1. Plenary.nvim Does NOT Provide Health Check Utilities

**Investigation Result**: Plenary is a testing framework (plenary.busted) + async utility library. It does NOT have built-in health check functionality.

**Plenary Capabilities**:

- Testing framework (describe/it/before_each/after_each)
- Async utilities (coroutines, jobs, channels)
- File system utilities (scandir, path)
- Context managers
- Mocking/stubbing with luassert

**What Plenary Does NOT Do**: Health check augmentation or vim.health API integration

### 2. Neovim's Native Health Check System (vim.health API)

**Standard Pattern**: Neovim provides `vim.health` API for plugin health checks:

```lua
-- Plugin creates: lua/[plugin-name]/health.lua
local M = {}

function M.check()
  vim.health.start("Plugin Name")

  -- Success
  vim.health.ok("Feature working correctly")

  -- Warning with advice
  vim.health.warn("Optional feature missing", {
    "Install dependency X",
    "Run command Y"
  })

  -- Error with advice
  vim.health.error("Critical failure", {
    "Fix configuration in Z",
    "See docs at URL"
  })

  -- Info
  vim.health.info("Additional context")
end

return M
```

**Discovery**: `:checkhealth` automatically finds and invokes health.lua modules on runtimepath

### 3. PercyBrain's Current Health Check Implementation

**What We Have**:

- `lua/config/health-fixes.lua` - Fix coordinator applying automatic repairs
- `tests/health/health-validation.test.lua` - TDD tests for validation
- User commands: `:PercyBrainHealthFix`, `:PercyBrainHealthCheck`

**What We DON'T Have**:

- No `lua/percybrain/health.lua` module integrating with `:checkhealth`
- Health fixes run on startup but don't report to `:checkhealth`
- No vim.health.\* API usage for native integration

**Current Pattern** (error-logger.lua):

```lua
function M.check_health()
  vim.cmd("checkhealth")  -- Just runs checkhealth, doesn't augment it
end
```

### 4. Gap Analysis: TDD Tests vs Native Health Integration

**Agent-Generated Approach**:

- ✅ Created TDD tests for validation
- ✅ Created fix modules with automatic application
- ❌ Did NOT create health.lua module for `:checkhealth` integration
- ❌ Tests use plenary.busted but don't integrate with vim.health API

**Better Pattern**:

```lua
-- lua/percybrain/health.lua
local M = {}

function M.check()
  vim.health.start("PercyBrain Core")

  -- Check Treesitter Python parser
  local treesitter_ok = require("config.treesitter-health-fix").verify()
  if treesitter_ok then
    vim.health.ok("Python Treesitter parser functioning correctly")
  else
    vim.health.error("Python parser has except* syntax issue", {
      "Run :PercyBrainHealthFix to apply automatic fix",
      "Or manually update python parser: :TSUpdate python"
    })
  end

  -- Check session options
  local session_ok = require("config.session-health-fix").verify()
  if session_ok then
    vim.health.ok("Session options configured correctly")
  else
    vim.health.warn("Missing localoptions in sessionoptions", {
      "Run :PercyBrainHealthFix to add required options"
    })
  end

  -- Check LSP diagnostics
  local lsp_ok = require("config.lsp-diagnostic-fix").verify()
  if lsp_ok then
    vim.health.ok("Using modern LSP diagnostic API")
  else
    vim.health.warn("Deprecated diagnostic signs API detected", {
      "Run :PercyBrainHealthFix to migrate to modern API"
    })
  end
end

return M
```

### 5. Current Test Suite Errors

**Error 1**: `python-parser-contract.test.lua:248` - Syntax error (function arguments expected) **Error 2**: `health-validation.test.lua:5` - Missing `tests.helpers` module **Error 3**: `treesitter-health-fix.lua:163` - Invalid API call (`invalidate_query_cache`)

**Status**: Tests failing (0/2 passed), but fixes ARE working (checkhealth shows 0 critical errors)

### 6. Recommended Integration Strategy

**Phase 1**: Fix existing test suite

1. Fix syntax errors in test files
2. Create or identify tests.helpers module
3. Fix invalid treesitter API call

**Phase 2**: Create native health check integration

1. Create `lua/percybrain/health.lua` module
2. Add `.check()` function using vim.health API
3. Add `.verify()` functions to each fix module
4. Integrate with `:checkhealth` native workflow

**Phase 3**: Dual validation approach

1. Keep TDD tests for automated CI/CD validation
2. Add vim.health integration for interactive user validation
3. Both systems validate the same fixes, different audiences

### 7. Ecosystem Health Check Patterns

**Common Plugin Pattern**:

- lazy.nvim: `lua/lazy/health.lua` - checks plugin manager health
- mason.nvim: `lua/mason/health.lua` - checks LSP/DAP/linter installation
- nvim-treesitter: `lua/nvim-treesitter/health.lua` - checks parser installation

**Best Practice**: Every plugin should provide health.lua module for `:checkhealth` integration

### 8. Conclusions

**Plenary Role**: Testing framework only, NOT health check framework **Native Solution**: vim.health API is the standard for health check augmentation **Our Gap**: We have TDD tests and fixes, but no vim.health integration **Next Step**: Create lua/percybrain/health.lua for native integration

**Key Insight**: We built a comprehensive TDD testing system, but didn't leverage Neovim's native health check framework. Both are valuable for different purposes:

- TDD tests: Automated validation in CI/CD
- vim.health: Interactive user validation and guidance
