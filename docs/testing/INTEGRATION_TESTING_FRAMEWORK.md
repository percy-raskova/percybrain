# Integration Testing Framework for PercyBrain Workflows

**Author**: Kent Beck Testing Persona **Date**: October 20, 2025 **Status**: Initial Design **Philosophy**: "Integration tests prove the parts work together. They're the safety net that lets you refactor with confidence."

## Executive Summary

This framework tests **complete user workflows** across the PercyBrain Zettelkasten system, validating that our individually tested components work correctly when integrated. We focus on **behavior over configuration**, **fast feedback over exhaustive coverage**, and **clarity over complexity**.

## Core Principles

### 1. Test at the Right Level

- **Unit Tests**: Single functions, isolated logic (✅ Complete)
- **Contract Tests**: API boundaries, interfaces (✅ Complete)
- **Capability Tests**: What users can do with features (✅ Complete)
- **Integration Tests**: Complete workflows, component interactions (🎯 This Framework)
- **E2E Tests**: Full system with external services (Future, if needed)

### 2. Balance Reality vs Isolation

```
┌─────────────────────────────────────────────────┐
│         INTEGRATION TEST SPECTRUM               │
├─────────────────────────────────────────────────┤
│ Isolated ←─────────────────────────→ Real       │
│                                                 │
│ • Mocked filesystem      • Real filesystem      │
│ • Fake Ollama            • Test Ollama instance │
│ • Mock Hugo              • Hugo in Docker       │
│ • Simulated buffers      • Real Neovim buffers  │
└─────────────────────────────────────────────────┘

Our Strategy: "Real Enough"
- Real Neovim buffers and autocmds
- Real filesystem with temp directories
- Mocked external services (Ollama, Hugo)
- Real component interactions
```

### 3. Fast Feedback Mandate

- **Target**: \< 5 seconds per workflow test
- **Total Suite**: \< 30 seconds for all integration tests
- **Parallel Execution**: Where possible
- **Fail Fast**: Stop on first failure in workflow

## Quality Metrics and Success Criteria

| Quality Attribute   | Measurement Method          | Target                | Validation              |
| ------------------- | --------------------------- | --------------------- | ----------------------- |
| **Performance**     | Total suite execution time  | \< 30 seconds         | CI/CD enforcement       |
| **Reliability**     | Flaky test detection rate   | \< 2% false positives | Weekly automated scan   |
| **Maintainability** | Time to add workflow test   | \< 30 minutes         | Developer survey        |
| **Extensibility**   | Time to add mock service    | \< 15 minutes         | Framework analysis      |
| **Coverage**        | Workflow coverage           | 100% of user journeys | Manual review           |
| **Clarity**         | Test failure diagnosis time | \< 5 minutes          | Failure message quality |

## Directory Structure

```
tests/
├── integration/              # RECOMMENDED: Clear intent
│   ├── workflows/           # Complete user journeys
│   │   ├── quick_capture_spec.lua
│   │   ├── wiki_creation_spec.lua
│   │   └── publishing_spec.lua
│   │
│   ├── interactions/        # Component integration points
│   │   ├── template_to_pipeline_spec.lua
│   │   ├── ai_model_to_pipeline_spec.lua
│   │   └── hugo_validation_to_pipeline_spec.lua
│   │
│   ├── fixtures/           # Test data and environments
│   │   ├── test_zettelkasten/
│   │   ├── mock_responses/
│   │   └── config_templates/
│   │
│   └── helpers/            # Integration-specific utilities
│       ├── workflow_runner.lua
│       ├── environment_setup.lua
│       └── async_helpers.lua
```

**Answer to Q1**: Use `tests/integration/` - it's clearer than `tests/workflows/` and follows industry conventions.

## When to Write Integration Tests - Decision Tree

Feature added or changed? │ ├─ Q1: Is it a new standalone component? │ └─ NO → Continue to Q2 │ └─ YES → Write contract + capability tests ONLY │ (Integration tests not needed yet) │ ├─ Q2: Does it interact with 2+ existing components? │ └─ NO → Continue to Q3 │ └─ YES → ✅ Write integration test │ Focus: Component interaction contracts │ ├─ Q3: Does it cross system boundaries? │ └─ NO → Continue to Q4 │ └─ YES → Consider E2E test (minimize, keep rare) │ Integration test may suffice with mocks │ └─ Q4: Is it internal logic only? └─ YES → Write unit test ONLY

### Examples:

- ✅ **Integration test needed**: Template system + Write-Quit pipeline + Hugo validator
- ❌ **NOT integration test**: New Hugo frontmatter field (covered by contract tests)
- ✅ **Integration test needed**: AI model selection affecting pipeline behavior
- ❌ **NOT integration test**: Helper function for timestamp generation (unit test)

## Integration Testing Strategy

**Note**: For a comprehensive list of failure modes to test, see [FAILURE_MODE_CATALOG.md](./FAILURE_MODE_CATALOG.md)

### Workflow Test Granularity

**Answer to Q3**: Use **Phase-Based Testing** - multiple tests per workflow, organized by user journey phases:

```lua
describe("Wiki Note Creation Workflow", function()
  describe("Phase 1: Template Selection", function()
    it("presents template options when creating new note")
    it("applies correct template based on selection")
    it("sets appropriate file location based on template type")
  end)

  describe("Phase 2: Content Creation", function()
    it("creates buffer with template content")
    it("preserves user edits during save")
    it("triggers autocmds on buffer write")
  end)

  describe("Phase 3: AI Processing", function()
    it("detects wiki note type correctly")
    it("selects appropriate AI model")
    it("processes in background without blocking")
  end)

  describe("Phase 4: Validation & Notification", function()
    it("validates Hugo frontmatter for wiki notes")
    it("notifies user on completion")
    it("handles errors gracefully")
  end)
end)
```

## Workflow Example Matrix

### Wiki Note Creation Workflow

| Example # | Template | AI Available   | Hugo Valid        | Expected Outcome                                                |
| --------- | -------- | -------------- | ----------------- | --------------------------------------------------------------- |
| 1         | wiki     | ✅ Yes         | ✅ Yes            | Success: Note created, AI processed, publishable                |
| 2         | wiki     | ❌ No          | ✅ Yes            | Partial success: Note created, AI skipped, publishable          |
| 3         | wiki     | ✅ Yes         | ❌ No             | Validation failure: Note created, AI processed, not publishable |
| 4         | fleeting | ✅ Yes         | N/A               | Success: Note in inbox, light AI processing, not publishable    |
| 5         | wiki     | ⏱️ Slow (4.5s) | ✅ Yes            | Success with warning: All complete, user warned about slowness  |
| 6         | wiki     | ✅ Yes         | ⚠️ Missing fields | Validation error: Clear message, note editable                  |

### Quick Capture Workflow

| Example # | Trigger                | Content     | Save Location | Expected Outcome                                |
| --------- | ---------------------- | ----------- | ------------- | ----------------------------------------------- |
| 1         | `<leader>qc`           | Single line | inbox/        | Success: Timestamp filename, simple frontmatter |
| 2         | `<leader>qc`           | Empty       | N/A           | Cancelled: Window closes, no file created       |
| 3         | `<leader>qc`           | Multi-line  | inbox/        | Success: All lines preserved, auto-formatted    |
| 4         | `<leader>qc` during AI | Single line | inbox/        | Success: Non-blocking, AI continues separately  |

### Publishing Workflow

| Example # | Source         | Hugo Valid      | Action   | Expected Outcome                              |
| --------- | -------------- | --------------- | -------- | --------------------------------------------- |
| 1         | wiki/ notes    | ✅ All valid    | Validate | Success: Report shows all publishable         |
| 2         | wiki/ + inbox/ | ✅ Wiki valid   | Validate | Success: Inbox excluded, wiki publishable     |
| 3         | wiki/ notes    | ❌ Some invalid | Validate | Partial: Report shows valid/invalid breakdown |
| 4         | Empty vault    | N/A             | Validate | Info: No notes found to publish               |

### Async Operation Handling

**Answer to Q4**: Use **Polling with Timeouts** pattern:

```lua
-- helpers/async_helpers.lua
local M = {}

-- Wait for condition with timeout
function M.wait_for(condition_fn, timeout_ms, poll_interval_ms)
  timeout_ms = timeout_ms or 5000
  poll_interval_ms = poll_interval_ms or 100

  local elapsed = 0
  while elapsed < timeout_ms do
    if condition_fn() then
      return true
    end
    vim.wait(poll_interval_ms)
    elapsed = elapsed + poll_interval_ms
  end

  return false, "Timeout waiting for condition"
end

-- Example usage in test
it("processes AI in background", function()
  -- Act
  pipeline.on_save(wiki_path)

  -- Assert: Wait for processing to complete
  local success = async_helpers.wait_for(function()
    return pipeline.get_processing_status().state == "completed"
  end, 3000)  -- 3 second timeout

  assert.is_true(success, "AI processing should complete within 3 seconds")
end)
```

## Mocking Strategy for External Dependencies

**Answer to Q2**: Use **"Real Enough" Mocking** - minimize mocks while maintaining speed:

### 1. Filesystem: Real with Cleanup

```lua
-- helpers/environment_setup.lua
local M = {}

function M.create_test_vault()
  local test_dir = vim.fn.tempname() .. "/test_zettelkasten"

  -- Create structure
  vim.fn.mkdir(test_dir, "p")
  vim.fn.mkdir(test_dir .. "/inbox", "p")
  vim.fn.mkdir(test_dir .. "/templates", "p")
  vim.fn.mkdir(test_dir .. "/.iwe", "p")

  -- Copy template fixtures
  vim.fn.system(string.format(
    "cp -r %s %s",
    "tests/integration/fixtures/templates/*",
    test_dir .. "/templates/"
  ))

  return test_dir
end

function M.cleanup_test_vault(path)
  vim.fn.delete(path, "rf")
end

return M
```

**Answer to Q5**: Use **ephemeral test directories** created per test suite, not fixtures:

- Pros: Clean state, no cross-test pollution, parallel execution
- Cons: Slightly slower (negligible with tmpfs)

### 2. Ollama: Smart Mock with Response Fixtures

```lua
-- helpers/mock_ollama.lua
local M = {}

function M.create_integration_mock()
  local responses = {
    fleeting = "Quick thought captured and processed",
    wiki = "Comprehensive analysis with Hugo metadata",
    error = nil  -- Simulate failures
  }

  return {
    process = function(content, note_type)
      -- Simulate processing delay
      vim.wait(100)

      if note_type == "error" then
        return nil, "Connection failed"
      end

      return responses[note_type] or responses.wiki
    end,

    is_available = function()
      return true  -- Can be toggled for error testing
    end
  }
end

return M
```

### 3. Hugo: Validation-Only Mock

```lua
-- helpers/mock_hugo.lua
local M = {}

function M.create_validator()
  return {
    validate_frontmatter = function(frontmatter)
      -- Real validation logic, no external Hugo needed
      local required = {"title", "date", "draft"}
      for _, field in ipairs(required) do
        if not frontmatter[field] then
          return false, "Missing required field: " .. field
        end
      end
      return true
    end,

    would_publish = function(file_path)
      -- Check path and frontmatter
      if file_path:match("/inbox/") then
        return false, "Inbox notes excluded"
      end
      return true
    end
  }
end

return M
```

## Example Integration Test (Annotated)

```lua
-- tests/integration/workflows/wiki_creation_spec.lua
-- Kent Beck: "This test tells the story of a user creating a wiki note"

describe("Wiki Note Creation Workflow [INTEGRATION]", function()
  local env_setup = require("tests.integration.helpers.environment_setup")
  local async_helpers = require("tests.integration.helpers.async_helpers")
  local mock_ollama = require("tests.integration.helpers.mock_ollama")

  local test_vault
  local original_home

  before_each(function()
    -- PATTERN: Fresh environment per test suite
    -- WHY: Ensures test isolation without sacrificing speed
    test_vault = env_setup.create_test_vault()

    -- PATTERN: Temporarily override HOME for Zettelkasten path resolution
    -- WHY: Components use ~/Zettelkasten, we redirect to test directory
    original_home = vim.env.HOME
    vim.env.HOME = test_vault:gsub("/test_zettelkasten$", "")

    -- PATTERN: Load real components with test configuration
    -- WHY: We test real interactions, not mocks talking to mocks
    require("percybrain.template-system").setup({
      vault_path = test_vault
    })

    require("percybrain.write-quit-pipeline").setup({
      ai_processor = mock_ollama.create_integration_mock()
    })

    require("percybrain.hugo-menu").setup({
      content_path = test_vault
    })
  end)

  after_each(function()
    -- PATTERN: Comprehensive cleanup
    -- WHY: Prevent test pollution and resource leaks
    vim.env.HOME = original_home
    env_setup.cleanup_test_vault(test_vault)

    -- Clear all autocmds created during test
    vim.api.nvim_clear_autocmds({ group = "WriteQuitPipeline" })
    vim.api.nvim_clear_autocmds({ group = "TemplateSystem" })
  end)

  describe("Happy Path: Create, Edit, Save, Process", function()
    it("completes full wiki note creation workflow", function()
      -- ============================================================
      -- PHASE 1: Template Selection
      -- ============================================================
      -- Arrange: User initiates new note creation
      local template_system = require("percybrain.template-system")

      -- Act: Select wiki template
      local file_path = template_system.create_from_template("wiki", "My Test Article")

      -- Assert: File created in correct location with correct template
      assert.is_not_nil(file_path)
      assert.is_true(file_path:match("/test_zettelkasten/.*%.md$") ~= nil)
      assert.is_false(file_path:match("/inbox/") ~= nil, "Wiki notes should not be in inbox")

      -- ============================================================
      -- PHASE 2: Content Editing
      -- ============================================================
      -- Arrange: Open file in buffer
      vim.cmd("edit " .. file_path)
      local buf = vim.api.nvim_get_current_buf()

      -- Act: Add content to the note
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      table.insert(lines, "")
      table.insert(lines, "This is my test content.")
      table.insert(lines, "It has multiple lines.")
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

      -- Assert: Content is in buffer
      local content = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
      assert.is_true(content:match("This is my test content") ~= nil)

      -- ============================================================
      -- PHASE 3: Save and Trigger Pipeline
      -- ============================================================
      -- Arrange: Set up pipeline state tracking
      local pipeline = require("percybrain.write-quit-pipeline")
      local processing_started = false
      local processing_completed = false

      pipeline.set_processing_callback(function()
        processing_started = true
      end)

      pipeline.set_completion_callback(function()
        processing_completed = true
      end)

      -- Act: Save the buffer (triggers BufWritePost autocmd)
      vim.cmd("write")

      -- Assert: Pipeline detected save and started processing
      assert.is_true(processing_started, "Pipeline should start on save")

      -- Assert: Editor remains responsive (non-blocking)
      assert.is_false(pipeline.is_processing_blocking())

      -- ============================================================
      -- PHASE 4: AI Processing
      -- ============================================================
      -- Act: Wait for AI processing to complete
      local success = async_helpers.wait_for(function()
        return processing_completed
      end, 2000)  -- 2 second timeout

      -- Assert: Processing completed successfully
      assert.is_true(success, "AI processing should complete within 2 seconds")
      assert.equals("completed", pipeline.get_processing_status().state)

      -- ============================================================
      -- PHASE 5: Hugo Validation
      -- ============================================================
      -- Arrange: Get Hugo validation module
      local hugo = require("percybrain.hugo-menu")

      -- Act: Validate the processed note
      local is_valid, validation_errors = hugo.validate_file_for_publishing(file_path)

      -- Assert: Wiki note passes Hugo validation
      assert.is_true(is_valid, "Wiki note should be valid for Hugo")
      assert.is_nil(validation_errors)

      -- Assert: File is marked as publishable
      local should_publish = hugo.should_publish_file(file_path)
      assert.is_true(should_publish, "Wiki notes should be publishable")

      -- ============================================================
      -- PHASE 6: User Notification
      -- ============================================================
      -- Assert: User received completion notification
      -- (Notification was mocked in pipeline setup)
      local notifications = pipeline.get_notifications()
      assert.is_true(#notifications > 0, "User should receive notifications")
      assert.is_true(
        notifications[#notifications]:match("completed") ~= nil,
        "Notification should indicate completion"
      )
    end)
  end)

  describe("Error Scenarios", function()
    it("handles AI processing failure gracefully", function()
      -- PATTERN: Test error paths explicitly
      -- WHY: Error handling is often where integration breaks

      -- Arrange: Configure Ollama mock to fail
      local pipeline = require("percybrain.write-quit-pipeline")
      pipeline.setup({
        ai_processor = {
          process = function()
            error("Connection timeout")
          end
        }
      })

      -- Act: Create and save a wiki note
      local template_system = require("percybrain.template-system")
      local file_path = template_system.create_from_template("wiki", "Error Test")
      vim.cmd("edit " .. file_path)
      vim.cmd("write")

      -- Assert: Pipeline handles error without crashing
      vim.wait(500)  -- Give time for error to propagate

      local status = pipeline.get_processing_status()
      assert.equals("error", status.state)
      assert.is_not_nil(status.error_message)

      -- Assert: User is notified of the error
      local notifications = pipeline.get_notifications()
      local error_notified = false
      for _, notif in ipairs(notifications) do
        if notif:match("error") or notif:match("failed") then
          error_notified = true
          break
        end
      end
      assert.is_true(error_notified, "User should be notified of errors")

      -- Assert: Note still exists and is editable despite AI failure
      assert.is_true(vim.fn.filereadable(file_path) == 1)
    end)

    it("handles invalid Hugo frontmatter appropriately", function()
      -- Arrange: Create note with invalid frontmatter
      local test_file = test_vault .. "/invalid-frontmatter.md"
      vim.fn.writefile({
        "---",
        "title: Missing Required Fields",
        "---",
        "",
        "Content here"
      }, test_file)

      -- Act: Validate for publishing
      local hugo = require("percybrain.hugo-menu")
      local is_valid, errors = hugo.validate_file_for_publishing(test_file)

      -- Assert: Validation fails with clear errors
      assert.is_false(is_valid)
      assert.is_not_nil(errors)
      assert.is_true(errors:match("date") ~= nil, "Should report missing date")
      assert.is_true(errors:match("draft") ~= nil, "Should report missing draft status")
    end)
  end)

  describe("Interaction Points", function()
    it("correctly routes fleeting notes to inbox", function()
      -- PATTERN: Test integration points explicitly
      -- WHY: This is where components must agree on contracts

      -- Act: Create fleeting note via template
      local template_system = require("percybrain.template-system")
      local file_path = template_system.create_from_template("fleeting", "Quick thought")

      -- Assert: File is in inbox
      assert.is_true(file_path:match("/inbox/") ~= nil, "Fleeting notes go to inbox")

      -- Act: Save and check publishing status
      vim.cmd("edit " .. file_path)
      vim.cmd("write")

      local hugo = require("percybrain.hugo-menu")
      local should_publish = hugo.should_publish_file(file_path)

      -- Assert: Inbox notes are excluded from publishing
      assert.is_false(should_publish, "Inbox notes should not be published")
    end)

    it("maintains correct AI model selection across workflow", function()
      -- Arrange: Set a specific AI model preference
      local model_selector = require("percybrain.ai-model-selector")
      model_selector.set_model("codellama")

      -- Act: Create and save a wiki note
      local template_system = require("percybrain.template-system")
      local file_path = template_system.create_from_template("wiki", "Code Documentation")
      vim.cmd("edit " .. file_path)
      vim.cmd("write")

      -- Assert: Pipeline uses selected model
      local pipeline = require("percybrain.write-quit-pipeline")
      vim.wait(200)  -- Let processing start

      local status = pipeline.get_processing_status()
      assert.equals("codellama", status.model_used, "Should use selected AI model")
    end)
  end)
end)
```

## Testing Execution and CI/CD Integration

### Running Integration Tests

```bash
# Run all integration tests
nvim --headless -u tests/minimal_init.lua -c "lua require('plenary.test_harness').test_directory('tests/integration/', { sequential = true })"

# Run specific workflow tests
nvim --headless -u tests/minimal_init.lua -c "lua require('plenary.test_harness').test_directory('tests/integration/workflows/', { sequential = true })"

# Run with coverage (requires luacov)
nvim --headless -u tests/minimal_init.lua -c "lua require('plenary.test_harness').test_directory('tests/integration/', { sequential = true, coverage = true })"
```

### CI/CD Pipeline Integration

```yaml
# .github/workflows/integration-tests.yml
name: Integration Tests
on: [push, pull_request]

jobs:
  integration:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install Neovim
        run: |
          sudo add-apt-repository ppa:neovim-ppa/unstable
          sudo apt-get update
          sudo apt-get install neovim

      - name: Install dependencies
        run: |
          # Install plenary for test harness
          git clone https://github.com/nvim-lua/plenary.nvim ~/.local/share/nvim/site/pack/vendor/start/plenary.nvim

      - name: Run Integration Tests
        run: |
          make test-integration
        timeout-minutes: 5  # Enforce fast feedback

      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: integration-test-results
          path: tests/results/
```

## Summary and Best Practices

### Key Takeaways

1. **Integration tests are about behavior, not configuration** - Test what users do, not how components are wired.

2. **"Real Enough" is the sweet spot** - Use real Neovim, real filesystem, mock external services.

3. **Phase-based testing provides clarity** - Break workflows into logical phases for better failure diagnosis.

4. **Fast feedback is non-negotiable** - If integration tests take >30 seconds, something is wrong.

5. **Test the integration points explicitly** - Where components meet is where bugs hide.

### Anti-Patterns to Avoid

❌ **Testing implementation details** - Don't test that specific functions are called ❌ **Over-mocking** - Don't mock Neovim APIs or filesystem unless absolutely necessary ❌ **Shared test state** - Each test should create its own environment ❌ **Ignoring async operations** - Use proper wait helpers, don't use arbitrary sleep ❌ **Missing error scenarios** - Happy paths are only half the story

### When to Add Integration Tests

✅ **New user-facing workflow** - Any new command or keybinding that spans components ✅ **Bug fixes at boundaries** - When fixing integration bugs, add regression tests ✅ **Complex state management** - When components share state across operations ✅ **External service integration** - When adding new AI models or publishing targets

______________________________________________________________________

**Next Steps**: Implement the integration test framework following this design, starting with the wiki creation workflow as the canonical example.
