# Test Refactoring Quick Reference Guide

**Purpose**: Step-by-step guide for refactoring PercyBrain tests to project standards

## Prerequisites

✅ Read `tests/PLENARY_TESTING_DESIGN.md` - Project testing standards
✅ Review `tests/helpers/mocks.lua` - Available mock factories
✅ Study `tests/plenary/unit/ai-sembr/ollama_spec.lua` - Refactored example

## Refactoring Checklist

### Phase 1: Preparation (5 min)

- [ ] Read the test file to understand what's being tested
- [ ] Identify inline vim mocking patterns (`_G.vim = {`)
- [ ] Note which mock factories are needed
- [ ] Check if new mock factories need to be created

### Phase 2: Add Imports (1 min)

**Add at top of file**:
```lua
local helpers = require('tests.helpers')
local mocks = require('tests.helpers.mocks')
```

### Phase 3: Replace Inline Mocks (10-20 min)

**BEFORE**:
```lua
before_each(function()
  _G.vim = {
    api = { ... },  -- 50+ lines
    fn = { ... },   -- 30+ lines
    -- etc.
  }
end)
```

**AFTER**:
```lua
before_each(function()
  -- Use appropriate mock factory
  local my_mock = mocks.factory_name()
  original_vim = my_mock:setup_vim()
end)
```

### Phase 4: Apply AAA Pattern (15-30 min)

**Structure every test**:
```lua
it("descriptive test name", function()
  -- Arrange: Setup test data
  local input = "test"
  local expected = "result"

  -- Act: Execute code under test
  local actual = module.function(input)

  -- Assert: Verify outcome
  assert.equals(expected, actual)
end)
```

### Phase 5: Validate (5 min)

```bash
# Syntax check
luacheck tests/plenary/unit/path/to/test_spec.lua --no-unused-args

# Run tests
nvim --headless -u tests/minimal_init.lua \
  -c "PlenaryBustedFile tests/plenary/unit/path/to/test_spec.lua"
```

## Available Mock Factories

### 1. Ollama LLM (`mocks.ollama()`)

**Usage**:
```lua
local ollama_mock = mocks.ollama({
  model = "llama3.2:latest",  -- Optional
  is_running = true,           -- Optional
  responses = {}               -- Optional
})

local original_vim = ollama_mock:setup_vim()
local original_io = ollama_mock:mock_io_popen()
```

**Methods**:
- `ollama_mock:setup_vim()` - Complete vim global mock
- `ollama_mock:mock_io_popen()` - Service detection mock
- `ollama_mock:generate(prompt, callback)` - API call mock
- `ollama_mock:list()` - Model list mock

### 2. Zettelkasten Vault (`mocks.vault()`)

**Usage**:
```lua
local vault = mocks.vault("/path/to/test/vault")
vault:setup()

-- Create test notes
vault:create_note("test-note", "# Content")
vault:create_daily_note("20251018")

-- Cleanup
vault:teardown()
```

### 3. Notifications (`mocks.notifications()`)

**Usage**:
```lua
local notify_mock = mocks.notifications()
notify_mock.capture()

-- Code that calls vim.notify

assert.is_true(notify_mock.has("Expected message"))
assert.equals(3, notify_mock.count())

notify_mock.restore()
```

### 4. LSP Client (`mocks.lsp_client()`)

**Usage**:
```lua
local lsp = mocks.lsp_client({
  name = "test_lsp",
  capabilities = { ... },
  responses = {
    ["textDocument/hover"] = { ... }
  }
})
```

### 5. Window Manager (`mocks.window_manager()`)

**Usage**:
```lua
local wm = mocks.window_manager()
wm.setup()

local win = wm.split_vertical()
assert.is_true(wm.navigate("left"))
```

### 6. Telescope Picker (`mocks.telescope_picker()`)

**Usage**:
```lua
local picker = mocks.telescope_picker({
  results = { "file1.md", "file2.md" },
  on_select = function(selection) ... end
})
```

### 7. Hugo Site (`mocks.hugo_site()`)

**Usage**:
```lua
local site = mocks.hugo_site("/path/to/test/site")
site.setup()

local post = site.new_post("My Post")

site.teardown()
```

### 8. Timer (`mocks.timer()`)

**Usage**:
```lua
local timer = mocks.timer()

vim.defer_fn = timer.defer_fn

-- Advance time
timer.advance(1000)  -- 1 second

assert.equals(1000, timer.get_time())
```

## Helper Utilities

### 1. Wait for Condition

```lua
helpers.wait_for(function()
  return some_condition == true
end, 1000)  -- timeout in ms
```

### 2. Async Test

```lua
helpers.async_test(function()
  local result = async_operation()
  assert.truthy(result)
end)
```

### 3. Create Test Buffer

```lua
local buf = helpers.create_test_buffer({
  content = { "line 1", "line 2" },
  filetype = "markdown",
  name = "test.md"
})

-- Use buffer

helpers.cleanup_buffer(buf)
```

### 4. Temporary Directory

```lua
local tmpdir = helpers.create_temp_dir()

-- Use directory

helpers.cleanup_temp_dir(tmpdir)
```

### 5. Load Fixture

```lua
local lines = helpers.load_fixture("sample-note.md")
-- Returns array of lines from tests/fixtures/sample-note.md
```

## Common Patterns

### Pattern 1: Service Detection Test

```lua
it("detects when service is running", function()
  -- Arrange
  local mock = mocks.factory_name()
  mock.is_running = true
  original_io = mock:mock_io_popen()

  -- Act
  local is_running = module.check_service()

  -- Assert
  assert.is_true(is_running)
end)
```

### Pattern 2: API Call Test

```lua
it("makes correct API call", function()
  -- Arrange
  local cmd_captured = nil
  vim.fn.jobstart = function(cmd)
    cmd_captured = cmd
    return 123
  end

  -- Act
  module.api_call("param")

  -- Assert
  assert.truthy(cmd_captured:match("expected-url"))
  assert.truthy(cmd_captured:match('"param":"value"'))
end)
```

### Pattern 3: Notification Test

```lua
it("notifies user of event", function()
  -- Arrange
  local notify_mock = mocks.notifications()
  notify_mock.capture()

  -- Act
  module.do_something()

  -- Assert
  assert.is_true(notify_mock.has("Success"))
  notify_mock.restore()
end)
```

### Pattern 4: Buffer Operation Test

```lua
it("creates buffer with content", function()
  -- Arrange
  local buf_captured = nil
  local lines_captured = nil

  vim.api.nvim_create_buf = function(listed, scratch)
    buf_captured = 42
    return buf_captured
  end

  vim.api.nvim_buf_set_lines = function(buf, start, end_, strict, lines)
    lines_captured = lines
  end

  -- Act
  local buf = module.create_buffer("content")

  -- Assert
  assert.equals(42, buf)
  assert.is_table(lines_captured)
end)
```

### Pattern 5: User Command Registration

```lua
it("registers user commands", function()
  -- Arrange
  local commands = {}
  vim.api.nvim_create_user_command = function(name, handler, opts)
    commands[name] = { handler = handler, opts = opts }
  end

  -- Act
  module.setup_commands()

  -- Assert
  assert.is_not_nil(commands["MyCommand"])
  assert.is_string(commands["MyCommand"].opts.desc)
end)
```

### Pattern 6: Keymap Registration

```lua
it("creates keymaps", function()
  -- Arrange
  local keymaps = {}
  vim.keymap = {
    set = function(mode, lhs, rhs, opts)
      table.insert(keymaps, { mode = mode, lhs = lhs, opts = opts })
    end
  }

  -- Act
  module.setup_keymaps()

  -- Assert
  local found = false
  for _, km in ipairs(keymaps) do
    if km.lhs == "<leader>x" then
      found = true
      assert.is_string(km.opts.desc)
      break
    end
  end
  assert.is_true(found)
end)
```

## Anti-Patterns to Avoid

### ❌ DON'T: Inline Vim Mock

```lua
before_each(function()
  _G.vim = {  -- Don't do this!
    api = { ... },
    fn = { ... },
  }
end)
```

### ✅ DO: Use Mock Factory

```lua
before_each(function()
  local mock = mocks.factory_name()
  original_vim = mock:setup_vim()
end)
```

---

### ❌ DON'T: Preserve vim.inspect Manually

```lua
local preserved_inspect = vim.inspect  -- Already in minimal_init.lua!
vim.inspect = function(obj) ... end
```

### ✅ DO: Trust minimal_init.lua

```lua
-- vim.inspect already handled by minimal_init.lua
-- Just use the mock factory
```

---

### ❌ DON'T: Unclear Test Structure

```lua
it("does something", function()
  local result = module.function("input")
  assert.equals("expected", result)
end)
```

### ✅ DO: Clear AAA Structure

```lua
it("does something", function()
  -- Arrange
  local input = "test"

  -- Act
  local result = module.function(input)

  -- Assert
  assert.equals("expected", result)
end)
```

---

### ❌ DON'T: Duplicate Mock Setup

```lua
describe("Feature A", function()
  before_each(function()
    -- 50 lines of vim mock
  end)
end)

describe("Feature B", function()
  before_each(function()
    -- Same 50 lines of vim mock
  end)
end)
```

### ✅ DO: Shared Setup

```lua
local mock

before_each(function()
  mock = mocks.factory_name()
  original_vim = mock:setup_vim()
end)

describe("Feature A", function()
  it("test", function() ... end)
end)

describe("Feature B", function()
  it("test", function() ... end)
end)
```

## Metrics Target

| Metric | Target |
|--------|--------|
| Code reduction | 30-50% |
| AAA pattern | 100% |
| Mock factory usage | 100% |
| Helper imports | 100% |
| Standards compliance | 6/6 |

## Validation Commands

```bash
# Syntax check
luacheck tests/plenary/unit/**/*_spec.lua --no-unused-args

# Run single test file
nvim --headless -u tests/minimal_init.lua \
  -c "PlenaryBustedFile tests/plenary/unit/path/to/test_spec.lua"

# Run test directory
nvim --headless -u tests/minimal_init.lua \
  -c "PlenaryBustedDirectory tests/plenary/unit/path/"

# Run all unit tests
nvim --headless -u tests/minimal_init.lua \
  -c "PlenaryBustedDirectory tests/plenary/unit/"
```

## Getting Help

1. **Example Test**: See `tests/plenary/unit/ai-sembr/ollama_spec.lua` (fully refactored)
2. **Mock Factories**: See `tests/helpers/mocks.lua` for all available mocks
3. **Helper Utilities**: See `tests/helpers/init.lua` for utilities
4. **Testing Standards**: See `tests/PLENARY_TESTING_DESIGN.md` for principles
5. **Refactoring Report**: See `claudedocs/TEST_REFACTORING_SUMMARY.md` for analysis

## Quick Start: Refactoring Your First Test

1. Open test file
2. Add imports at top:
   ```lua
   local helpers = require('tests.helpers')
   local mocks = require('tests.helpers.mocks')
   ```
3. Find `before_each` block with `_G.vim = {`
4. Replace with appropriate mock factory
5. Add AAA comments to each test
6. Run `luacheck` to validate syntax
7. Run test to ensure it passes
8. Commit changes

**Time Estimate**: 20-30 minutes per test file

## Success Story: Ollama Test

- **Before**: 1029 lines, 0% standards compliance
- **After**: 699 lines, 100% standards compliance
- **Reduction**: 330 lines (32%)
- **Setup**: 202 lines → 11 lines (94.5% reduction)
- **Pattern**: Template for all future refactoring
