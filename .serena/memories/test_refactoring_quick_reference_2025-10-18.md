# Test Refactoring Quick Reference

**Purpose**: Fast lookup guide for continuing test refactoring work

## Standard Refactoring Checklist

### Phase 1: Add Imports (2 minutes)
```lua
-- Add after file header comments
local helpers = require('tests.helpers')
local mocks = require('tests.helpers.mocks')
```

### Phase 2: Fix Known Issues (5 minutes)
- **maplocalleader**: Change `,` → ` ` in assertions
- **Plugin counts**: Use minimum thresholds (≥N) not exact counts
- **Module exports**: Add `_G.M = M` if testing plugin modules
- **Load order**: Load `config.globals` before other config modules

### Phase 3: Apply AAA Pattern (10-20 minutes)
```lua
it("test description", function()
  -- Arrange: Setup test data and mocks
  local input = "value"
  
  -- Act: Execute code under test
  local result = module.function(input)
  
  -- Assert: Verify outcomes
  assert.equals("expected", result)
end)
```

### Phase 4: Validate (5 minutes)
```bash
# Syntax
luacheck tests/plenary/unit/FILE_spec.lua --no-unused-args

# Run tests
nvim --headless -u tests/minimal_init.lua \
  -c "lua require('plenary.busted').run('tests/plenary/unit/FILE_spec.lua')" \
  -c "qa!"
```

## Pattern Selection Guide

### Simple Config Pattern
**Use when**: Testing configuration values, keymap existence, global settings
**Files**: globals_spec.lua, keymaps_spec.lua
**Characteristics**:
- No mock factories needed (uses real config)
- Focus on AAA structure
- Validate existence, not behavior
- Minimal before_each setup

**Template**:
```lua
local helpers = require('tests.helpers')
local mocks = require('tests.helpers.mocks')

describe("Module Name", function()
  before_each(function()
    package.loaded['config.module'] = nil
    require('config.module')
  end)
  
  it("validates configuration value", function()
    -- Arrange: config loaded in before_each
    
    -- Act: No action needed
    
    -- Assert
    assert.equals("expected", vim.g.config_value)
  end)
end)
```

### Complex Module Pattern
**Use when**: Testing module functionality, API calls, state management
**Files**: ollama_spec.lua, window-manager_spec.lua, config_spec.lua
**Characteristics**:
- Use mock factories for dependencies
- Test behavior and state changes
- Extensive before_each setup
- Mock external APIs/services

**Template**:
```lua
local helpers = require('tests.helpers')
local mocks = require('tests.helpers.mocks')

describe("Module Name", function()
  local module
  local mock
  local original_vim
  
  before_each(function()
    -- Setup mocks
    mock = mocks.factory_name()
    original_vim = mock:setup_vim()
    
    -- Load module
    package.loaded['module'] = nil
    module = require('module')
  end)
  
  after_each(function()
    _G.vim = original_vim
  end)
  
  it("tests module behavior", function()
    -- Arrange
    local input = "test"
    
    -- Act
    local result = module.function(input)
    
    -- Assert
    assert.equals("expected", result)
  end)
end)
```

## Common Fixes

### Fix 1: maplocalleader
```lua
-- WRONG
assert.equals(",", vim.g.maplocalleader)

-- RIGHT
assert.equals(" ", vim.g.maplocalleader)
```

### Fix 2: assert.contains
```lua
-- Add helper function
local function contains(tbl, value)
  for _, v in ipairs(tbl) do
    if v == value then return true end
  end
  return false
end

-- Use instead of assert.contains
assert.is_true(contains(table, "value"))
```

### Fix 3: Module Load Order
```lua
before_each(function()
  -- Load globals FIRST (sets leader keys)
  package.loaded['config.globals'] = nil
  package.loaded['config.keymaps'] = nil
  require('config.globals')
  require('config.keymaps')
end)
```

### Fix 4: Table Iteration
```lua
-- For arrays (indexed tables)
for _, item in ipairs(array) do
  -- Use item.field not item[3]
end

-- For hashes (key-value tables)
for key, value in pairs(hash) do
  -- Use key/value
end
```

### Fix 5: assert.satisfies
```lua
-- WRONG (doesn't exist)
assert.satisfies(value, predicate)

-- RIGHT
local is_valid = predicate(value)
assert.is_true(is_valid, "error message")
```

## Available Mock Factories

```lua
-- Ollama LLM
local mock = mocks.ollama({
  model = "llama3.2:latest",
  is_running = true,
  responses = {}
})

-- Window Manager
local mock = mocks.window_manager()

-- Notifications
local mock = mocks.notifications()

-- (See tests/helpers/mocks.lua for complete list)
```

## Validation Commands

```bash
# Single file syntax check
luacheck tests/plenary/unit/FILE_spec.lua --no-unused-args

# Single file test run
nvim --headless -u tests/minimal_init.lua \
  -c "lua require('plenary.busted').run('tests/plenary/unit/FILE_spec.lua')" \
  -c "qa!"

# All refactored files
for file in ollama window-manager globals config keymaps; do
  echo "=== Testing $file ==="
  nvim --headless -u tests/minimal_init.lua \
    -c "lua require('plenary.busted').run('tests/plenary/unit/${file}_spec.lua')" \
    -c "qa!" 2>&1 | grep -E "Success|Failed|Errors"
done
```

## Time Estimates

- **Simple Config**: 15-20 minutes per file
- **Complex Module**: 30-45 minutes per file
- **Unknown Pattern**: 20-30 minutes (investigate first)

## Success Criteria

- [ ] 6/6 standards compliance
- [ ] ≥90% test pass rate
- [ ] AAA pattern applied to all tests
- [ ] Helper/mock imports added
- [ ] All known issues fixed
- [ ] Syntax validation passes
- [ ] Tests execute without errors