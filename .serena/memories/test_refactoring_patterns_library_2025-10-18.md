# Test Refactoring Patterns Library
**Purpose**: Reusable patterns for PercyBrain test refactoring
**Date**: 2025-10-18

## Pattern 1: Simple Configuration Tests

**Use for**: globals_spec, keymaps_spec, options_spec

**Template**:
```lua
local helpers = require('tests.helpers')
local mocks = require('tests.helpers.mocks')

describe("Module Name", function()
  before_each(function()
    -- Reset module state
    package.loaded['module'] = nil
  end)

  describe("feature group", function()
    it("validates specific behavior", function()
      -- Arrange
      local input = "test"
      
      -- Act
      local result = module.function(input)
      
      -- Assert
      assert.equals("expected", result)
    end)
  end)
end)
```

**Characteristics**:
- Minimal mocking needed
- Focus on vim options/keymaps/globals
- Direct validation without complex setup
- Fast execution (<100ms per test)

## Pattern 2: Complex Module Tests

**Use for**: ollama_spec, window-manager_spec, config_spec

**Template**:
```lua
local helpers = require('tests.helpers')
local mocks = require('tests.helpers.mocks')

describe("Complex Module", function()
  local module_instance
  local mock_dependency
  local original_vim
  
  before_each(function()
    -- Setup mock
    mock_dependency = mocks.factory_name()
    original_vim = mock_dependency:setup_vim()
    _G.vim = original_vim
    
    -- Load module
    package.loaded['module'] = nil
    local plugin_spec = require('module')
    if plugin_spec.config then
      plugin_spec.config()
      module_instance = _G.M or {}
    end
  end)
  
  after_each(function()
    _G.vim = original_vim
    package.loaded['module'] = nil
  end)
  
  describe("feature group", function()
    it("performs complex operation", function()
      -- Arrange
      local input_data = { key = "value" }
      
      -- Act
      local result = module_instance.complex_function(input_data)
      
      -- Assert
      assert.is_table(result)
      assert.equals("expected", result.key)
    end)
  end)
end)
```

**Characteristics**:
- Comprehensive vim mock needed
- Module loading and initialization
- Complex state management
- Multiple test groups (describe blocks)

## Pattern 3: Integration Tests

**Use for**: sembr/formatter_spec, sembr/integration_spec

**Template**:
```lua
local helpers = require('tests.helpers')
local mocks = require('tests.helpers.mocks')

describe("Integration: Module A + Module B", function()
  local module_a, module_b
  local mock_a, mock_b
  local notifications
  
  before_each(function()
    -- Setup multiple mocks
    mock_a = mocks.factory_a()
    mock_b = mocks.factory_b()
    
    -- Notification tracking
    notifications = mocks.notifications()
    notifications.capture()
    
    -- Load modules
    package.loaded['module_a'] = nil
    package.loaded['module_b'] = nil
    module_a = require('module_a')
    module_b = require('module_b')
  end)
  
  after_each(function()
    notifications.restore()
    notifications.clear()
    package.loaded['module_a'] = nil
    package.loaded['module_b'] = nil
  end)
  
  describe("cross-module interaction", function()
    it("coordinates between modules", function()
      -- Arrange
      local data = "test"
      
      -- Act
      module_a.process(data)
      local result = module_b.get_result()
      
      -- Assert
      assert.is_not_nil(result)
      assert.is_true(notifications.has("Success"))
    end)
  end)
end)
```

**Characteristics**:
- Multiple mock coordination
- Cross-module communication testing
- Notification/event tracking
- Async operation handling with helpers.wait_for()

## Mock Factory Selection Guide

| Test Type | Mock Factory | Rationale |
|-----------|--------------|-----------|
| Ollama AI features | `mocks.ollama()` | Complete vim API + io.popen |
| Zettelkasten notes | `mocks.vault()` | File system operations |
| Window operations | `mocks.window_manager()` | Window API mocking |
| LSP integration | `mocks.lsp_client()` | LSP protocol simulation |
| Notifications | `mocks.notifications()` | vim.notify tracking |
| Telescope pickers | `mocks.telescope_picker()` | Picker simulation |
| Hugo publishing | `mocks.hugo_site()` | Site operations |
| Async timing | `mocks.timer()` | Time control |

## AAA Pattern Examples

### Simple Assertion
```lua
it("sets leader key to space", function()
  -- Arrange
  local expected = " "
  
  -- Act
  local actual = vim.g.mapleader
  
  -- Assert
  assert.equals(expected, actual)
end)
```

### Function Call
```lua
it("generates AI response", function()
  -- Arrange
  local prompt = "test prompt"
  local callback_called = false
  
  -- Act
  ollama.generate(prompt, function(response)
    callback_called = true
  end)
  
  -- Assert
  assert.is_true(callback_called)
end)
```

### Table Validation
```lua
it("creates buffer with options", function()
  -- Arrange
  local buf_id = nil
  vim.api.nvim_create_buf = function(listed, scratch)
    buf_id = 42
    return buf_id
  end
  
  -- Act
  local result = module.create_buffer()
  
  -- Assert
  assert.equals(42, result)
  assert.is_not_nil(buf_id)
end)
```

### Notification Tracking
```lua
it("notifies user of completion", function()
  -- Arrange
  local notifications = mocks.notifications()
  notifications.capture()
  
  -- Act
  module.complete_task()
  
  -- Assert
  assert.is_true(notifications.has("Task complete"))
  notifications.restore()
end)
```

## Common Refactoring Steps

### Step 1: Add Imports
```lua
-- Add at top of file
local helpers = require('tests.helpers')
local mocks = require('tests.helpers.mocks')
```

### Step 2: Identify Inline Mocks
```lua
-- BEFORE (find this pattern)
before_each(function()
  _G.vim = {
    api = { ... },  -- inline mock
    fn = { ... },
  }
end)
```

### Step 3: Replace with Factory
```lua
-- AFTER (replace with this)
before_each(function()
  local mock = mocks.factory_name()
  original_vim = mock:setup_vim()
  _G.vim = original_vim
end)
```

### Step 4: Apply AAA to Tests
```lua
-- BEFORE
it("does something", function()
  local result = func("input")
  assert.equals("expected", result)
end)

-- AFTER
it("does something", function()
  -- Arrange
  local input = "input"
  
  -- Act
  local result = func(input)
  
  -- Assert
  assert.equals("expected", result)
end)
```

## Validation Commands

### Syntax Check
```bash
luacheck tests/plenary/unit/path/to/test_spec.lua --no-unused-args
```

### Run Single Test
```bash
nvim --headless -u tests/minimal_init.lua \
  -c "lua require('plenary.busted').run('tests/plenary/unit/path/to/test_spec.lua')" \
  -c "qa!" 2>&1
```

### Run Test Directory
```bash
nvim --headless -u tests/minimal_init.lua \
  -c "PlenaryBustedDirectory tests/plenary/unit/" \
  -c "qa!" 2>&1
```

## Success Criteria

✅ Helper imports at top
✅ Mock factory usage (no inline _G.vim)
✅ AAA pattern in all tests
✅ Descriptive test names
✅ Clean before_each/after_each
✅ No vim.inspect manual handling

## Reference Examples

**Best Example**: `tests/plenary/unit/ai-sembr/ollama_spec.lua`
- 699 lines, 100% standards compliance
- Complex module pattern
- 50+ test cases with AAA structure
- 91% pass rate validated

**Simple Example**: `tests/plenary/unit/globals_spec.lua`
- 315 lines, 100% standards compliance
- Simple configuration pattern
- 17 test cases with AAA structure
- Pending validation