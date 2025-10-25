# PercyBrain Test Helpers - Usage Guide

**Purpose**: Centralized documentation for all test helper modules **Philosophy**: Kent Beck's "Make tests easy to write, easy to read, easy to maintain" **Last Updated**: 2025-10-21 (Phase 2 Helper Consolidation)

## Helper Module Overview

| Helper Module               | Purpose                   | Primary Use Cases                           |
| --------------------------- | ------------------------- | ------------------------------------------- |
| **init.lua**                | Basic test utilities      | Buffer creation, temp dirs, general helpers |
| **async_helpers.lua**       | Async operations          | wait_for, retry patterns, async assertions  |
| **environment_setup.lua**   | Zettelkasten environments | Vault creation, integration test setup      |
| **gtd_test_helpers.lua**    | GTD-specific fixtures     | GTD task lists, context testing             |
| **keymap_test_helpers.lua** | Keymap validation         | Keymap testing and verification             |
| **workflow_builders.lua**   | Integration workflows     | Workflow construction for integration tests |
| **mocks.lua**               | Service mocking           | LSP, Ollama, notifications, vaults          |
| **assertions.lua**          | Custom assertions         | PercyBrain-specific behavior validation     |

## When to Use Each Helper

### init.lua - General Purpose Utilities

**Use when**: You need basic test setup, buffers, or temp directories

**Common Functions**:

```lua
local helpers = require('tests.helpers.init')

-- Create test buffer
local buf = helpers.create_test_buffer({
  content = {"Line 1", "Line 2"},
  filetype = "markdown",
  name = "test.md"
})

-- Create temporary directory
local tmpdir = helpers.create_temp_dir()
-- ... use tmpdir ...
helpers.cleanup_temp_dir(tmpdir)

-- Load fixtures
local fixture = helpers.load_fixture("sample_note.md")

-- Ensure plugin loaded
helpers.ensure_plugin("telescope.nvim")
```

**Re-exported Functions** (use these, they're more robust):

```lua
-- wait_for - re-exported from async_helpers
local success, err = helpers.wait_for(function()
  return vim.fn.filereadable(path) == 1
end, 5000)  -- 5s timeout

-- mock_notify - re-exported from mocks
local notify_mock = helpers.mock_notify()
notify_mock.capture()  -- Start capturing
-- ... run test ...
assert.equals(1, notify_mock.count())
notify_mock.restore()
```

### async_helpers.lua - Async Operations

**Use when**: Dealing with async operations, timeouts, retries

**Core Pattern - wait_for()**:

```lua
local async = require('tests.helpers.async_helpers')

-- Wait for file to exist
local success, error_msg = async.wait_for(function()
  return vim.fn.filereadable(file_path) == 1
end, 5000)  -- timeout_ms

-- Wait with custom polling interval
local success, error_msg = async.wait_for(
  condition_fn,
  10000,  -- 10s timeout
  200     -- 200ms polling interval
)
```

**Specialized wait_for Variants**:

```lua
-- Wait for file
async.wait_for_file(path, 5000)

-- Wait for buffer content pattern
async.wait_for_buffer_content(buf, "pattern", 5000)

-- Wait for notification
async.wait_for_notification("Success", 3000)

-- Wait for pipeline completion
async.wait_for_pipeline_completion(pipeline, 10000)
```

**Retry with Backoff**:

```lua
local success, result = async.retry_with_backoff(
  function() return flaky_operation() end,
  3,      -- max attempts
  100     -- initial delay ms (doubles each retry)
)
```

**Deferred Assertions**:

```lua
-- Assert that condition becomes true within timeout
async.assert_eventually(function()
  return vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == "Expected"
end, 5000, "Buffer content did not update")
```

### environment_setup.lua - Zettelkasten Integration Tests

**Use when**: Creating complete test vaults for integration testing

**Create Test Vault**:

```lua
local env = require('tests.helpers.environment_setup')

-- Create complete Zettelkasten vault
local vault_path = env.create_test_vault("my_test_vault")
-- Includes: inbox/, templates/, daily/, .iwe/ directories
-- Includes: Default wiki and fleeting templates

-- Setup environment variables
local original = env.setup_env(vault_path)

-- Run integration tests...

-- Restore environment
env.restore_env(original)
env.cleanup_test_vault(vault_path)
```

**Create Test Files**:

```lua
-- Create file in vault
local note_path = env.create_test_file(
  vault_path,
  "my-note.md",
  "# My Note\n\nContent here"
)

-- Create custom template
local template = env.create_template(
  vault_path,
  "custom",
  "---\ntitle: {{title}}\n---\n\n# {{title}}"
)
```

**Component Loading**:

```lua
-- Load component with test config
local component = env.load_component("zettelkasten", {
  vault_path = vault_path,
  enable_ai = false
})
```

**Clean State Verification**:

```lua
local is_clean, issues = env.verify_clean_state()
if not is_clean then
  print("Test cleanup issues: " .. vim.inspect(issues))
end
```

### mocks.lua - Mock Factories

**Use when**: Need to mock external services, LSP, AI, vaults

**Mock Notifications**:

```lua
local mocks = require('tests.helpers.mocks')

local notify_mock = mocks.notifications()
notify_mock.capture()  -- Start capturing

-- Run code that calls vim.notify
vim.notify("Test message", vim.log.levels.INFO)

-- Assert on notifications
assert.equals(1, notify_mock.count())
assert.is_true(notify_mock.has("Test message"))

-- Inspect captured notifications
for _, msg in ipairs(notify_mock.messages) do
  print(msg.message, msg.level)
end

notify_mock.clear()    -- Clear messages
notify_mock.restore()  -- Restore original vim.notify
```

**Mock Zettelkasten Vault**:

```lua
local vault = mocks.vault("/path/to/test/vault")
vault:setup()  -- Create structure

-- Create notes
local note_path = vault:create_note("test-note", "# Test\n\nContent")
local daily_path = vault:create_daily_note("20251021")

-- Mock backlinks
local backlinks = vault:get_backlinks("note-id")

vault:teardown()  -- Cleanup
```

**Mock Ollama AI**:

```lua
local ollama = mocks.ollama({
  model = "llama3.2:latest",
  is_running = true,
  responses = {
    generate = "Mock AI response"
  }
})

-- Setup comprehensive vim mocking
local original_vim = ollama:setup_vim()
local original_popen = ollama:mock_io_popen()

-- Use mock
ollama:generate("Test prompt", function(response)
  assert.equals("Mock AI response to: Test prompt", response.response)
end)

-- Restore
_G.vim = original_vim
io.popen = original_popen
```

**Mock LSP Client**:

```lua
local client = mocks.lsp_client({
  name = "lua_ls",
  id = 1,
  responses = {
    ["textDocument/hover"] = { contents = "Hover info" }
  }
})

-- Use in tests
client.request("textDocument/hover", params, function(err, result)
  assert.is_nil(err)
  assert.equals("Hover info", result.contents)
end)
```

### gtd_test_helpers.lua - GTD Testing

**Use when**: Testing GTD (Getting Things Done) functionality

Refer to this helper for GTD-specific fixtures and assertions.

### keymap_test_helpers.lua - Keymap Testing

**Use when**: Testing keymap registration, namespaces, syntax

Refer to this helper for keymap validation utilities.

### workflow_builders.lua - Integration Workflows

**Use when**: Building complex integration test workflows

Refer to this helper for workflow construction patterns.

## Common Testing Patterns

### Pattern 1: Basic Unit Test with Buffer

```lua
describe("my feature", function()
  local helpers = require('tests.helpers.init')
  local buf

  before_each(function()
    -- Arrange
    buf = helpers.create_test_buffer({
      content = {"Line 1"},
      filetype = "markdown"
    })
  end)

  after_each(function()
    -- Cleanup
    helpers.cleanup_buffer(buf)
  end)

  it("should modify buffer", function()
    -- Act
    my_feature.modify(buf)

    -- Assert
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    assert.equals("Modified Line 1", lines[1])
  end)
end)
```

### Pattern 2: Async Test with wait_for

```lua
describe("async feature", function()
  local async = require('tests.helpers.async_helpers')
  local helpers = require('tests.helpers.init')

  it("should complete async operation", function()
    -- Arrange
    local buf = helpers.create_test_buffer()
    local completed = false

    -- Act
    my_async_feature.start(buf, function()
      completed = true
    end)

    -- Assert
    local success, err = async.wait_for(function()
      return completed
    end, 5000)

    assert.is_true(success, err)
    helpers.cleanup_buffer(buf)
  end)
end)
```

### Pattern 3: Integration Test with Vault

```lua
describe("zettelkasten workflow", function()
  local env = require('tests.helpers.environment_setup')
  local async = require('tests.helpers.async_helpers')

  local vault_path, original_env

  before_each(function()
    -- Arrange
    vault_path = env.create_test_vault()
    original_env = env.setup_env(vault_path)
  end)

  after_each(function()
    -- Cleanup
    env.restore_env(original_env)
    env.cleanup_test_vault(vault_path)
  end)

  it("should create linked notes", function()
    -- Act
    local note1 = env.create_test_file(vault_path, "note1.md",
      "# Note 1\n\n[[note2]]")
    local note2 = env.create_test_file(vault_path, "note2.md",
      "# Note 2")

    -- Assert
    local success = async.wait_for_file(note1, 1000)
    assert.is_true(success)

    local content = vim.fn.readfile(note1)
    assert.matches("%[%[note2%]%]", table.concat(content, "\n"))
  end)
end)
```

### Pattern 4: Mocked Service Test

```lua
describe("AI integration", function()
  local mocks = require('tests.helpers.mocks')
  local notify_mock, ollama_mock

  before_each(function()
    -- Arrange
    notify_mock = mocks.notifications()
    notify_mock.capture()

    ollama_mock = mocks.ollama({
      is_running = true,
      responses = { generate = "AI suggestion" }
    })
    ollama_mock:setup_vim()
  end)

  after_each(function()
    -- Cleanup
    notify_mock.restore()
  end)

  it("should show AI response", function()
    -- Act
    my_ai_feature.suggest("Test prompt")

    -- Assert
    assert.is_true(notify_mock.has("AI suggestion"))
  end)
end)
```

## Helper Testing Standards

All helpers follow these standards:

1. **AAA Pattern**: Arrange-Act-Assert structure
2. **Cleanup**: Always provide cleanup functions (teardown, restore, delete)
3. **Error Handling**: Return success/error tuples, don't throw unnecessarily
4. **Defaults**: Sensible defaults with optional parameters
5. **Documentation**: Clear docstrings explaining purpose and usage

## Adding New Helpers

When adding new helper functions:

1. **Choose the right module**:

   - General utilities → init.lua
   - Async operations → async_helpers.lua
   - Domain-specific → Create or use domain helper (gtd, keymap, etc.)

2. **Follow naming conventions**:

   - `create_*` for factory functions
   - `wait_for_*` for async waiting
   - `mock_*` for mock objects
   - `assert_*` for custom assertions

3. **Provide cleanup**:

   - Every `create_*` should have `cleanup_*`
   - Every `setup_*` should have `restore_*` or `teardown_*`

4. **Write tests for helpers**:

   - Helpers should have their own tests
   - Prevents "who tests the tests?" problem

5. **Document here**:

   - Update this README with usage examples
   - Add to appropriate section

## Troubleshooting

### Helper Import Errors

```bash
# Check helper imports
grep -r "require.*helpers" tests/ --include="*_spec.lua"
```

### Test Hanging (wait_for timeout)

- Check timeout values (default 5s in async_helpers)
- Add debug prints to condition function
- Verify async operation actually completes

### Mock Not Working

- Ensure `capture()` called before testing
- Check `restore()` called in after_each
- Verify you're testing the right notification pattern

### Environment Cleanup Issues

```lua
-- Use verify_clean_state for debugging
local env = require('tests.helpers.environment_setup')
local is_clean, issues = env.verify_clean_state()
print(vim.inspect(issues))
```

## Helper Module Dependencies

```
init.lua
├── async_helpers.lua (re-exports wait_for)
└── mocks.lua (re-exports mock_notify)

environment_setup.lua (standalone)

mocks.lua (standalone)

async_helpers.lua (standalone)

gtd_test_helpers.lua
└── init.lua

keymap_test_helpers.lua
└── init.lua

workflow_builders.lua
├── init.lua
├── async_helpers.lua
└── environment_setup.lua
```

## Phase 2 Consolidation Notes

**Date**: 2025-10-21 **Changes**:

- ✅ Consolidated `wait_for()` - removed duplicate from init.lua, re-export from async_helpers
- ✅ Consolidated `mock_notify()` - removed duplicate from init.lua, re-export from mocks
- ✅ Reviewed environment setup - confirmed good separation of concerns (no changes needed)

**Rationale**:

- init.lua: General-purpose basic utilities (buffers, temp dirs)
- environment_setup.lua: Zettelkasten-specific vault creation
- Proper separation maintained

**Benefits**:

- Single source of truth for wait_for (async_helpers.lua)
- Single source of truth for mock_notify (mocks.lua)
- Clear guidance on which helper to use when
- Reduced code duplication (~30 lines removed)

______________________________________________________________________

**Questions?** Check test specs for real-world usage examples, or refer to helper module source for implementation details.
