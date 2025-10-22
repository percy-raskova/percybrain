# Testing Best Practices - PercyBrain Framework

**Purpose**: Consolidated testing patterns, principles, and templates for consistent, maintainable test development **Philosophy**: Kent Beck TDD - "Tests are specifications that define contracts between components"

## Core Philosophy

### Kent Beck Principles

**Test Behavior, Not Implementation**

- Verify observable outcomes (buffer changes, API calls, notifications)
- Don't test internal state unless part of the contract
- Allows refactoring without breaking tests

**Tests as Specifications**

- Contract tests define MUST/MUST NOT/MAY behavior
- Each test name clearly states expected behavior
- Tests serve as executable documentation

**One Assertion Per Concept**

- Each test verifies one logical concept
- Multiple assertions only when testing same concept from different angles
- Clear failure messages explain what went wrong

**Fast Feedback Loop**

- All tests use mocks for fast execution (\<15 seconds total)
- No network calls, no real AI, no external processes
- Enables TDD workflow: RED → GREEN → REFACTOR

**Isolation and Independence**

- Each test can run independently
- No hidden dependencies between tests
- Fresh state for every test via before_each

### Active Testing Philosophy

**Validate Through Usage**: Test capabilities, not configuration

- ❌ Bad: `assert.is_true(vim.opt.spell:get())`
- ✅ Good: Test spell checking actually catches typos

**Configuration vs Application**

- Configurations are declarations, not behaviors
- Test workflows over options (can users create notes?)
- Test integrations (does LSP work with your config?)
- Test performance (does startup stay under 100ms?)

### TDD Cycle

**RED Phase**: Write failing test defining desired behavior **GREEN Phase**: Implement minimum code to pass **REFACTOR Phase**: Clean up while keeping tests green

**GREEN-on-First-Run Validation**: If all tests pass immediately after writing them, architecture was already correct. Tests become documentation and regression protection.

## Framework: Contract-Capability-Regression

### Contract Tests (`tests/contract/`)

**Purpose**: Define what system MUST, MUST NOT, and MAY do

**Pattern**:

```lua
describe("Module Contracts", function()
  it("MUST provide required API", function()
    -- Arrange
    local module = require("module")

    -- Act & Assert
    assert.is_function(module.required_function)
  end)

  it("MUST NOT auto-enable dangerous behavior", function()
    -- Arrange
    local config = require("config")

    -- Act
    local result = config.auto_enable

    -- Assert
    assert.is_false(result)
  end)

  it("MAY provide optional feature", function()
    -- Arrange
    local module = require("module")

    -- Act & Assert
    -- Test existence without requiring implementation
    if module.optional_feature then
      assert.is_function(module.optional_feature)
    end
  end)
end)
```

**Use For**:

- API guarantees (function existence, signatures)
- Configuration requirements (required vs optional settings)
- Behavioral contracts (MUST fail gracefully, MUST NOT auto-start)
- Template validation (frontmatter structure, file format)

**Validation Example - Template Contract**:

```lua
it("MUST have ultra-simple frontmatter (title + created only)", function()
  -- Arrange
  local template_path = vim.fn.expand("~/Zettelkasten/templates/fleeting.md")
  local file = io.open(template_path, "r")
  local content = file:read("*all")
  file:close()

  -- Act & Assert
  assert.matches("title:", content)
  assert.matches("created:", content)
  assert.not_matches("draft:", content)  -- FORBIDDEN
  assert.not_matches("tags:", content)   -- FORBIDDEN
end)
```

### Capability Tests (`tests/capability/`)

**Purpose**: Verify features actually work end-to-end in real-world scenarios

**Pattern**:

```lua
describe("User Workflow Capabilities", function()
  it("CAN create note with minimal friction", function()
    -- Arrange: User wants quick capture
    local title = "Quick idea about AI"
    local template_name = "fleeting"

    -- Act: Load and apply template
    local zettel = require("config.zettelkasten")
    local template_content = zettel.load_template(template_name)
    local content = zettel.apply_template(template_content, title)

    -- Assert: Simple frontmatter, no Hugo overhead
    assert.matches("title: " .. title, content)
    assert.matches("created:", content)
    assert.not_matches("draft:", content)
  end)
end)
```

**Use For**:

- User-facing workflows (note creation, linking, publishing)
- Feature combinations (AI + Zettelkasten integration)
- End-to-end scenarios (IWE extract → GTD decomposition)
- User experience validation (minimal friction, clear feedback)

**Naming**: Use "CAN DO" language

- "CAN create fleeting note with minimal friction"
- "CAN save wiki page to root Zettelkasten"
- "CAN decompose task into context-aware subtasks"

### Regression Tests (`tests/regression/`)

**Purpose**: Protect critical optimizations from accidental removal

**Pattern**:

```lua
describe("ADHD Visual Noise Reduction", function()
  it("MUST disable search highlighting", function()
    -- Arrange
    require("config.options")

    -- Act
    local hlsearch = vim.opt.hlsearch:get()

    -- Assert: Intentionally false for focus
    assert.is_false(hlsearch)
  end)

  it("MUST hide mode indicator (shown in statusline)", function()
    -- Arrange
    require("config.options")

    -- Act
    local showmode = vim.opt.showmode:get()

    -- Assert: Reduces visual clutter
    assert.is_false(showmode)
  end)
end)
```

**Use For**:

- ADHD/autism optimizations (visual noise, focus, anchors)
- Performance protections (startup time \< 500ms)
- Critical UX patterns (write-quit pipeline, minimal friction)
- Behavioral safeguards (no auto-enable, fail gracefully)

**Categories**:

- Visual noise reduction (hlsearch=false, showmode=false)
- Spatial anchors (cursorline, number, relativenumber)
- Writing support (spell=true, wrap=true, linebreak=true)
- Behavioral protections (fast startup, minimal prompts)

## Test Structure Standards (6/6)

### 1. Helper/Mock Imports ✅

```lua
-- At top of test file
local helpers = require("tests.helpers")
local mocks = require("tests.helpers.mocks")
local async = require("tests.helpers.async_helpers")
```

### 2. State Management (before_each/after_each) ✅

```lua
describe("Module Tests", function()
  local original_vim

  before_each(function()
    -- Reset module state
    package.loaded["module"] = nil

    -- Setup mocks
    local mock = mocks.factory_name()
    original_vim = mock:setup_vim()
    _G.vim = original_vim
  end)

  after_each(function()
    -- Restore original state
    _G.vim = original_vim
    package.loaded["module"] = nil
  end)
end)
```

### 3. AAA Pattern Comments ✅

```lua
it("test description", function()
  -- Arrange: Set up test preconditions
  local test_data = prepare_test_state()

  -- Act: Execute behavior being tested
  local result = function_under_test(test_data)

  -- Assert: Verify expected outcomes
  assert.equals(expected, result)
end)
```

### 4. No Global Pollution ✅

```lua
-- ❌ Bad: Pollutes global namespace
_G.my_test_helper = function() end

-- ✅ Good: Local helper functions
local function create_test_buffer()
  return vim.api.nvim_create_buf(false, true)
end
```

### 5. Local Helper Functions ✅

```lua
-- Define helpers at describe block scope
describe("Tests", function()
  local function setup_test_environment()
    -- Setup logic
  end

  it("uses local helper", function()
    setup_test_environment()
    -- Test logic
  end)
end)
```

### 6. No Raw assert.contains ✅

```lua
-- ❌ Bad: Raw assert.contains (unreliable)
assert.contains(expected, actual)

-- ✅ Good: Use plenary's assert extensions
assert.is_true(vim.tbl_contains(actual, expected))

-- ✅ Good: Use string matching
assert.matches("expected pattern", actual_string)
```

## Mock Patterns

### Mock Factory Selection

| Test Type          | Mock Factory               | Rationale                          |
| ------------------ | -------------------------- | ---------------------------------- |
| Ollama AI features | `mocks.ollama()`           | Complete vim API + io.popen + HTTP |
| Zettelkasten notes | `mocks.vault()`            | File system operations             |
| Window operations  | `mocks.window_manager()`   | Window API mocking                 |
| LSP integration    | `mocks.lsp_client()`       | LSP protocol simulation            |
| Notifications      | `mocks.notifications()`    | vim.notify tracking                |
| Telescope pickers  | `mocks.telescope_picker()` | Picker simulation                  |
| Hugo publishing    | `mocks.hugo_site()`        | Site operations                    |
| Async timing       | `mocks.timer()`            | Time control                       |

### Ollama Mock Pattern

**Purpose**: Simulate AI responses without network calls

**Implementation** (`tests/helpers/mock_ollama.lua`):

```lua
local M = {}

-- Context-aware subtask generation
local function generate_subtasks(task_text)
  if task_text:match("website") then
    return {
      "  - [ ] Design frontend interface",
      "  - [ ] Implement backend API",
      "  - [ ] Set up database schema"
    }
  elseif task_text:match("documentation") then
    return {
      "  - [ ] Create outline",
      "  - [ ] Write first draft",
      "  - [ ] Review and edit"
    }
  end
  return { "  - [ ] Subtask 1", "  - [ ] Subtask 2" }
end

-- Smart context suggestion
local function suggest_context(task_text)
  local keywords = {
    call = "@phone",
    code = "@computer",
    clean = "@home",
    meeting = "@office"
  }

  for keyword, context in pairs(keywords) do
    if task_text:lower():match(keyword) then
      return context
    end
  end
  return "@computer"
end

-- Priority inference
local function infer_priority(task_text)
  if task_text:match("urgent") or task_text:match("asap") then
    return "HIGH"
  elseif task_text:match("someday") or task_text:match("maybe") then
    return "LOW"
  end
  return "MEDIUM"
end

function M.create_mock_job()
  return {
    new = function(opts)
      local mock_job = {
        start = function() end,
        shutdown = function() end
      }

      -- Simulate async response
      vim.schedule(function()
        local response = {
          result = vim.json.encode({
            choices = {
              {
                message = {
                  content = vim.json.encode({
                    subtasks = generate_subtasks(opts.task_text),
                    context = suggest_context(opts.task_text),
                    priority = infer_priority(opts.task_text)
                  })
                }
              }
            }
          })
        }

        if opts.on_exit then
          opts.on_exit(mock_job, 0)
        end
      end)

      return mock_job
    end
  }
end

return M
```

**Usage**:

```lua
local mock_ollama = require("tests.helpers.mock_ollama")

before_each(function()
  -- Replace plenary.job with mock
  Job = mock_ollama.create_mock_job()
end)

it("decomposes task with AI", function()
  -- Arrange
  local task = "- [ ] Build website"

  -- Act
  gtd.decompose_task()

  -- Assert: Mock returns context-aware subtasks
  vim.wait(1000, function() return callback_called end)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  assert.matches("frontend", vim.inspect(lines))
end)
```

### Vault Mock Pattern

**Purpose**: Simulate file system operations without creating real files

**Implementation** (`tests/helpers/mocks.lua`):

```lua
function M.vault()
  return {
    setup_vault = function()
      local temp_dir = vim.fn.tempname()
      vim.fn.mkdir(temp_dir, "p")
      vim.fn.mkdir(temp_dir .. "/inbox", "p")
      vim.fn.mkdir(temp_dir .. "/templates", "p")

      -- Create mock templates
      local fleeting_template = temp_dir .. "/templates/fleeting.md"
      local file = io.open(fleeting_template, "w")
      file:write("---\ntitle: {{title}}\ncreated: {{date}}\n---\n\n# {{title}}\n")
      file:close()

      return temp_dir
    end,

    cleanup_vault = function(temp_dir)
      vim.fn.delete(temp_dir, "rf")
    end
  }
end
```

**Usage**:

```lua
local vault_mock = mocks.vault()
local temp_dir

before_each(function()
  temp_dir = vault_mock.setup_vault()
  vim.g.zettelkasten_path = temp_dir
end)

after_each(function()
  vault_mock.cleanup_vault(temp_dir)
end)
```

### Notification Mock Pattern

**Purpose**: Track vim.notify calls for validation

**Implementation**:

```lua
function M.notifications()
  local captured = {}
  local original_notify = vim.notify

  return {
    capture = function()
      vim.notify = function(msg, level, opts)
        table.insert(captured, {
          message = msg,
          level = level,
          opts = opts
        })
      end
    end,

    restore = function()
      vim.notify = original_notify
    end,

    clear = function()
      captured = {}
    end,

    has = function(pattern)
      for _, notif in ipairs(captured) do
        if notif.message:match(pattern) then
          return true
        end
      end
      return false
    end,

    get_all = function()
      return captured
    end
  }
end
```

**Usage**:

```lua
local notifications = mocks.notifications()

before_each(function()
  notifications.capture()
end)

after_each(function()
  notifications.restore()
  notifications.clear()
end)

it("notifies user of completion", function()
  -- Arrange
  local task = "test task"

  -- Act
  module.complete_task(task)

  -- Assert
  assert.is_true(notifications.has("Task complete"))
end)
```

## Test Templates

### Template 1: Simple Configuration Test

**Use For**: globals_spec, keymaps_spec, options_spec

```lua
local helpers = require("tests.helpers")

describe("Configuration Module", function()
  before_each(function()
    -- Reset module state
    package.loaded["config.module"] = nil
  end)

  describe("option setting", function()
    it("sets expected value", function()
      -- Arrange
      local expected = true

      -- Act
      require("config.module")
      local actual = vim.opt.option_name:get()

      -- Assert
      assert.equals(expected, actual)
    end)
  end)
end)
```

### Template 2: Complex Module Test

**Use For**: ollama_spec, window-manager_spec, config_spec

```lua
local helpers = require("tests.helpers")
local mocks = require("tests.helpers.mocks")

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
    package.loaded["module"] = nil
    local plugin_spec = require("module")
    if plugin_spec.config then
      plugin_spec.config()
      module_instance = _G.M or {}
    end
  end)

  after_each(function()
    _G.vim = original_vim
    package.loaded["module"] = nil
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

### Template 3: Integration Test

**Use For**: sembr/formatter_spec, sembr/integration_spec, workflows

```lua
local helpers = require("tests.helpers")
local mocks = require("tests.helpers.mocks")

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
    package.loaded["module_a"] = nil
    package.loaded["module_b"] = nil
    module_a = require("module_a")
    module_b = require("module_b")
  end)

  after_each(function()
    notifications.restore()
    notifications.clear()
    package.loaded["module_a"] = nil
    package.loaded["module_b"] = nil
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

### Template 4: Async Workflow Test

**Use For**: AI operations, HTTP requests, background jobs

```lua
local async = require("tests.helpers.async_helpers")
local mocks = require("tests.helpers.mocks")

describe("Async Workflow", function()
  local mock_job
  local callback_called

  before_each(function()
    callback_called = false
    mock_job = mocks.ollama().create_mock_job()
    Job = mock_job
  end)

  it("completes async operation", function()
    -- Arrange
    local task = "test task"

    -- Act
    module.async_operation(task, function(result)
      callback_called = true
    end)

    -- Assert: Wait for async callback
    local success = async.wait_for(
      function() return callback_called end,
      1000,  -- timeout_ms
      50     -- poll_interval_ms
    )
    assert.is_true(success, "Callback should be called")
  end)
end)
```

### Template 5: Contract Test (Dual-Tier Template System)

**Use For**: Template validation, configuration contracts, API guarantees

```lua
describe("Fleeting Template Contract", function()
  it("MUST have ultra-simple frontmatter", function()
    -- Arrange
    local template_path = vim.fn.expand("~/Zettelkasten/templates/fleeting.md")
    local file = io.open(template_path, "r")
    local content = file:read("*all")
    file:close()

    -- Act & Assert: Only title and created
    assert.matches("title:", content)
    assert.matches("created:", content)
    assert.not_matches("draft:", content)  -- FORBIDDEN
    assert.not_matches("tags:", content)   -- FORBIDDEN
  end)

  it("MUST be 7 lines total for minimal cognitive load", function()
    -- Arrange
    local template_path = vim.fn.expand("~/Zettelkasten/templates/fleeting.md")
    local file = io.open(template_path, "r")
    local lines = {}
    for line in file:lines() do
      table.insert(lines, line)
    end
    file:close()

    -- Act
    local line_count = #lines

    -- Assert: Ultra-simple template
    assert.equals(7, line_count)
  end)
end)

describe("Wiki Template Contract", function()
  it("MUST have complete Hugo frontmatter", function()
    -- Arrange
    local template_path = vim.fn.expand("~/Zettelkasten/templates/wiki.md")
    local file = io.open(template_path, "r")
    local content = file:read("*all")
    file:close()

    -- Act & Assert: Required Hugo fields
    assert.matches("title:", content)
    assert.matches("date:", content)
    assert.matches("draft:", content)
    assert.matches("tags:", content)
    assert.matches("categories:", content)
    assert.matches("description:", content)
    assert.matches("bibliography:", content)
  end)
end)
```

## Common Patterns

### Async Testing with wait_for()

**Robust Implementation** (`tests/helpers/async_helpers.lua`):

```lua
function M.wait_for(condition_fn, timeout_ms, poll_interval_ms)
  timeout_ms = timeout_ms or 5000
  poll_interval_ms = poll_interval_ms or 100

  local elapsed = 0
  local last_error = nil

  while elapsed < timeout_ms do
    local success, result = pcall(condition_fn)
    if success and result then
      return true
    end
    if not success then
      last_error = result
    end
    vim.wait(poll_interval_ms)
    elapsed = elapsed + poll_interval_ms
  end

  return false, last_error or ("Timeout after " .. timeout_ms .. "ms")
end
```

**Usage**:

```lua
it("completes async operation", function()
  -- Arrange
  local completed = false

  -- Act
  module.async_function(function()
    completed = true
  end)

  -- Assert: Wait for completion
  local success, err = async.wait_for(
    function() return completed end,
    1000,  -- 1 second timeout
    50     -- Poll every 50ms
  )
  assert.is_true(success, err or "Async operation failed")
end)
```

### Buffer Testing

```lua
it("modifies buffer content", function()
  -- Arrange: Create test buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(buf)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
    "- [ ] Original task"
  })

  -- Act: Modify buffer
  module.add_subtasks()

  -- Assert: Verify changes
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  assert.is_true(#lines > 1, "Subtasks should be added")
  assert.matches("- %[ %]", lines[2])  -- Checkbox format
end)
```

### Mock API Call Validation

```lua
it("calls OpenAI-compatible endpoint", function()
  -- Arrange: Capture HTTP request args
  local captured_args = nil
  Job.new = function(opts)
    captured_args = opts.args
    return mock_job
  end

  -- Act
  module.call_api()

  -- Assert: Verify correct endpoint
  assert.matches("/v1/chat/completions", captured_args[5])
  assert.matches("Bearer", captured_args[6])  -- Auth header
end)
```

### Notification Tracking

```lua
it("notifies user of success", function()
  -- Arrange
  local notifications = mocks.notifications()
  notifications.capture()

  -- Act
  module.complete_task()

  -- Assert
  assert.is_true(notifications.has("Task complete"))
  local all_notifs = notifications.get_all()
  assert.equals(vim.log.levels.INFO, all_notifs[1].level)

  -- Cleanup
  notifications.restore()
end)
```

## Refactoring Patterns

### Pattern: Consolidate Inline Mocks

**Before** (inline mock):

```lua
before_each(function()
  _G.vim = {
    api = {
      nvim_create_buf = function() return 1 end,
      nvim_buf_set_lines = function() end
    },
    fn = {
      executable = function() return 1 end
    }
  }
end)
```

**After** (factory mock):

```lua
before_each(function()
  local mock = mocks.factory_name()
  original_vim = mock:setup_vim()
  _G.vim = original_vim
end)
```

### Pattern: Add AAA Comments

**Before**:

```lua
it("creates note", function()
  local title = "Test"
  local result = zettel.create_note(title)
  assert.is_not_nil(result)
end)
```

**After**:

```lua
it("creates note", function()
  -- Arrange
  local title = "Test"

  -- Act
  local result = zettel.create_note(title)

  -- Assert
  assert.is_not_nil(result)
end)
```

### Pattern: Extract Local Helpers

**Before** (repeated setup):

```lua
it("test 1", function()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(buf)
  -- Test logic
end)

it("test 2", function()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(buf)
  -- Test logic
end)
```

**After** (local helper):

```lua
describe("Tests", function()
  local function create_test_buffer()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(buf)
    return buf
  end

  it("test 1", function()
    -- Arrange
    local buf = create_test_buffer()
    -- Test logic
  end)

  it("test 2", function()
    -- Arrange
    local buf = create_test_buffer()
    -- Test logic
  end)
end)
```

## Test Initialization (Single Source of Truth)

### Critical Pattern: Unified Initialization

**PROBLEM**: Multiple initialization configs create inconsistent test environments **SOLUTION**: Single authoritative `tests/minimal_init.lua` for all tests

**tests/minimal_init.lua** (comprehensive):

```lua
-- vim.inspect polyfill for Neovim 0.10+ compatibility
if not vim.inspect then
  vim.inspect = function(t)
    return vim.fn.json_encode(t)
  end
end

-- Unnecessary plugin disabling for performance
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- lazy.nvim bootstrapping
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plenary loading with fallback
local ok, plenary = pcall(require, "plenary")
if not ok then
  error("Plenary not found. Run :Lazy sync")
end

-- Test helper runtime/package path setup
local config_path = vim.fn.stdpath("config")
package.path = package.path .. ";" .. config_path .. "/lua/?.lua"
package.path = package.path .. ";" .. config_path .. "/tests/?.lua"

-- PercyBrain config loading
require("config.options")
require("config.keymaps")

-- Test helper globals
_G.test_helpers = require("tests.helpers")
_G.test_assertions = require("tests.helpers.assertions")
_G.test_mocks = require("tests.helpers.mocks")
```

**All runners MUST use**:

```bash
nvim --headless -u tests/minimal_init.lua \
  -c "PlenaryBustedFile $test_file" \
  -c "qa!"
```

**❌ NEVER create inline initialization configs** **❌ NEVER use multiple init variants** **✅ ALWAYS use tests/minimal_init.lua**

## Test Organization

### Directory Structure

```
tests/
├── capability/          # User-centric workflows ("CAN user X?")
│   ├── zettelkasten/
│   ├── ollama/
│   └── gtd/
├── contract/           # System specifications ("MUST/MAY system Y?")
├── unit/               # Isolated function tests
│   ├── ai/
│   ├── gtd/
│   ├── keymap/
│   └── zettelkasten/
├── integration/        # Cross-module interactions
├── regression/         # Bug/optimization protection
├── performance/        # Benchmarking, timing
└── helpers/            # Test utilities, mocks
    ├── init.lua
    ├── async_helpers.lua
    ├── mocks.lua
    ├── gtd_test_helpers.lua
    └── mock_ollama.lua
```

### When to Use Each Category

**Contract** (`tests/contract/`):

- API guarantees and contracts
- Configuration requirements
- Template validation
- System specifications (MUST/MUST NOT/MAY)

**Capability** (`tests/capability/`):

- User-facing workflows
- Feature combinations
- End-to-end scenarios
- UX validation

**Unit** (`tests/unit/`):

- Isolated functions
- Module behavior
- Single-responsibility testing
- Fast, deterministic tests

**Integration** (`tests/integration/`):

- Cross-module interactions
- Workflow orchestration
- Component coordination
- System-level behavior

**Regression** (`tests/regression/`):

- ADHD/autism optimizations
- Performance protections
- Critical UX patterns
- Bug prevention

## Debugging Tests

### Common Issues

**Async Timing**:

```lua
-- Problem: Callback not called in time
vim.wait(100, ...)  -- Too short

-- Solution: Increase timeout
vim.wait(1000, ...)  -- Give more time
```

**Mock Structure**:

```lua
-- Problem: Missing mock_job reference
opts.on_exit({ result = ... }, 0)  -- Wrong

-- Solution: Pass mock_job as first arg
opts.on_exit(mock_job, 0)  -- Correct
```

**Buffer State**:

```lua
-- Problem: Operating on wrong buffer
vim.api.nvim_buf_set_lines(0, ...)  -- Current buffer may change

-- Solution: Use explicit buffer handle
local buf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_buf_set_lines(buf, ...)
```

### Verbose Test Output

```bash
# Run single test with full output
nvim --headless -u tests/minimal_init.lua \
  -c "lua require('plenary.test_harness').test_directory('tests/unit', {minimal_init='tests/minimal_init.lua', sequential=true})" \
  -c "qa!"

# Or use mise for organized output
mise test:debug
```

## Success Metrics

**Test Quality**:

- [ ] 6/6 test standards compliance
- [ ] AAA pattern in all tests
- [ ] Descriptive test names (verb-driven)
- [ ] No global pollution
- [ ] Proper mock cleanup

**Coverage**:

- [ ] Contract tests define all MUST/MUST NOT/MAY behaviors
- [ ] Capability tests cover user workflows
- [ ] Regression tests protect critical optimizations
- [ ] Integration tests validate component interactions

**Performance**:

- [ ] Full suite \< 30 seconds
- [ ] Contract tests \< 5 seconds
- [ ] Capability tests \< 15 seconds
- [ ] No network calls, no real AI, no external processes

**Reliability**:

- [ ] Tests run in any order
- [ ] No flaky tests
- [ ] Clear failure messages
- [ ] Green-on-first-run for correct architecture

## Next TDD Targets

**Template**: Contract → Capability → Implementation → Validation

1. Hugo frontmatter validation
2. AI model selection (Ollama picker)
3. Write-quit pipeline (BufWritePost trigger)
4. Floating quick capture (minimal friction)
5. IWE-GTD bridge integration
6. Multi-note refactoring workflows

Each follows: Write contract tests → Write capability tests → Implement → Run all tests → Refactor

______________________________________________________________________

**Usage**: Reference this memory when writing new tests, refactoring existing tests, or validating test quality. **Maintenance**: Update when discovering new patterns, anti-patterns, or best practices. **Token Efficiency**: Dense, practical, reusable patterns optimized for copy-paste and quick reference.
