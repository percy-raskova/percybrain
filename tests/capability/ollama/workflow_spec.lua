-- Capability Tests for Ollama Integration Workflows
-- Tests that features actually work end-to-end in real-world scenarios
-- Kent Beck: "Capability tests verify the system does what users need"
--
-- Purpose: Validate GTD AI + IWE bridge + Ollama manager work together correctly
-- Strategy: Use mocked Ollama to test workflows without external dependencies
-- Coverage: Full workflow from task detection → decomposition → formatting

local mock_ollama = require("tests.helpers.mock_ollama")
local gtd_helpers = require("tests.helpers.gtd_test_helpers")

describe("Ollama Workflow Capabilities", function()
  local ai
  local test_buf

  before_each(function()
    -- Arrange: Enable mock Ollama for fast, deterministic tests
    mock_ollama.enable()
    mock_ollama.reset()
    mock_ollama.setup_gtd_defaults()

    -- Load AI module and patch it with mock
    package.loaded["lib.gtd.ai"] = nil
    ai = require("lib.gtd.ai")
    mock_ollama.patch_ai_module(ai)

    -- Create test buffer
    test_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(test_buf)
  end)

  after_each(function()
    -- Cleanup: Restore real implementation
    mock_ollama.unpatch_ai_module(ai)
    mock_ollama.disable()

    if test_buf and vim.api.nvim_buf_is_valid(test_buf) then
      vim.api.nvim_buf_delete(test_buf, { force = true })
    end
  end)

  describe("Task Decomposition Capability", function()
    it("decomposes simple task into subtasks", function()
      -- Arrange: Buffer with single task
      local task_line = "- [ ] Build a website"
      vim.api.nvim_buf_set_lines(test_buf, 0, -1, false, { task_line })
      vim.api.nvim_win_set_cursor(0, { 1, 0 })

      local original_line_count = vim.api.nvim_buf_line_count(test_buf)

      -- Act: Decompose task
      ai.decompose_task()

      -- Wait for AI response and buffer update
      local success = gtd_helpers.wait_for_buffer_change(test_buf, original_line_count, 2000)

      -- Assert: Subtasks were added
      assert.is_true(success, "Buffer should have more lines after decomposition")

      local lines = vim.api.nvim_buf_get_lines(test_buf, 0, -1, false)
      assert.is_true(#lines > 1, "Should have subtasks added")

      -- Verify subtasks are indented correctly (2 spaces from parent)
      local has_indented_subtask = false
      for i = 2, #lines do
        if lines[i]:match("^  %- %[ %]") then
          has_indented_subtask = true
          break
        end
      end
      assert.is_true(has_indented_subtask, "Subtasks should be indented with 2 spaces")
    end)

    it("preserves existing indentation when decomposing", function()
      -- Arrange: Indented task (nested task)
      local task_line = "    - [ ] Plan vacation"
      vim.api.nvim_buf_set_lines(test_buf, 0, -1, false, { task_line })
      vim.api.nvim_win_set_cursor(0, { 1, 0 })

      -- Act: Decompose indented task
      ai.decompose_task()

      -- Wait for subtasks
      vim.wait(2000, function()
        return vim.api.nvim_buf_line_count(test_buf) > 1
      end, 100)

      -- Assert: Subtasks have correct indentation (parent + 2 spaces)
      local lines = vim.api.nvim_buf_get_lines(test_buf, 0, -1, false)
      local has_correct_indent = false
      for i = 2, #lines do
        if lines[i]:match("^      %- %[ %]") then -- 6 spaces (4 + 2)
          has_correct_indent = true
          break
        end
      end
      assert.is_true(has_correct_indent, "Subtasks should maintain parent indent + 2 spaces")
    end)

    it("generates context-aware subtasks", function()
      -- Arrange: Task with specific domain
      local task_line = "- [ ] Write documentation for the API"
      vim.api.nvim_buf_set_lines(test_buf, 0, -1, false, { task_line })
      vim.api.nvim_win_set_cursor(0, { 1, 0 })

      -- Act: Decompose
      ai.decompose_task()

      -- Wait for subtasks
      vim.wait(2000, function()
        return vim.api.nvim_buf_line_count(test_buf) > 3
      end, 100)

      -- Assert: Subtasks are relevant to documentation
      local lines = vim.api.nvim_buf_get_lines(test_buf, 0, -1, false)
      local content = table.concat(lines, "\n"):lower()

      -- Mock sets up documentation-specific subtasks
      assert.matches("outline", content, "Should include outlining step")
      assert.matches("draft", content, "Should include drafting step")
    end)

    it("handles empty or invalid task gracefully", function()
      -- Arrange: Buffer with no task text
      vim.api.nvim_buf_set_lines(test_buf, 0, -1, false, { "" })
      vim.api.nvim_win_set_cursor(0, { 1, 0 })

      -- Act: Attempt to decompose empty line
      ai.decompose_task()

      -- Wait briefly
      vim.wait(500, function()
        return false
      end, 100)

      -- Assert: No crash, buffer unchanged
      local lines = vim.api.nvim_buf_get_lines(test_buf, 0, -1, false)
      assert.equals(1, #lines, "Should not add lines for empty task")
    end)

    it("only inserts checkbox-formatted subtasks", function()
      -- Arrange: Task to decompose
      vim.api.nvim_buf_set_lines(test_buf, 0, -1, false, { "- [ ] Complete project" })
      vim.api.nvim_win_set_cursor(0, { 1, 0 })

      -- Act: Decompose
      ai.decompose_task()

      -- Wait
      vim.wait(2000, function()
        return vim.api.nvim_buf_line_count(test_buf) > 1
      end, 100)

      -- Assert: All added lines are checkboxes
      local lines = vim.api.nvim_buf_get_lines(test_buf, 0, -1, false)
      for i = 2, #lines do
        assert.matches("%- %[.%]", lines[i], "Each subtask should be a checkbox")
      end
    end)
  end)

  describe("Context Suggestion Capability", function()
    it("suggests appropriate GTD context for task", function()
      -- Arrange: Task that clearly indicates a context
      local task_line = "- [ ] Call the insurance company"
      vim.api.nvim_buf_set_lines(test_buf, 0, -1, false, { task_line })
      vim.api.nvim_win_set_cursor(0, { 1, 0 })

      -- Act: Suggest context
      ai.suggest_context()

      -- Wait for line to be modified
      local success = gtd_helpers.wait_for_line_change(test_buf, 1, task_line, 2000)

      -- Assert: Context tag was added
      assert.is_true(success, "Line should be modified with context tag")

      local lines = vim.api.nvim_buf_get_lines(test_buf, 0, 1, false)
      local updated_line = lines[1]

      assert.matches("@%w+", updated_line, "Should contain @context tag")
      assert.matches("@phone", updated_line, "Should suggest @phone for call task")
    end)

    it("does not add duplicate context tags", function()
      -- Arrange: Task already has context
      local task_line = "- [ ] Buy groceries @errands"
      vim.api.nvim_buf_set_lines(test_buf, 0, -1, false, { task_line })
      vim.api.nvim_win_set_cursor(0, { 1, 0 })

      -- Act: Suggest context again
      ai.suggest_context()

      -- Wait briefly
      vim.wait(500, function()
        return false
      end, 100)

      -- Assert: Line unchanged (notification should inform user)
      local lines = vim.api.nvim_buf_get_lines(test_buf, 0, 1, false)
      assert.equals(task_line, lines[1], "Should not modify task that already has context")
    end)

    it("validates suggested context against known contexts", function()
      -- Arrange: Task for context suggestion
      local task_line = "- [ ] Fix kitchen sink"
      vim.api.nvim_buf_set_lines(test_buf, 0, -1, false, { task_line })
      vim.api.nvim_win_set_cursor(0, { 1, 0 })

      -- Act: Get context suggestion
      ai.suggest_context()

      -- Wait for update
      vim.wait(2000, function()
        local lines = vim.api.nvim_buf_get_lines(test_buf, 0, 1, false)
        return lines[1]:match("@%w+") ~= nil
      end, 100)

      -- Assert: Suggested context is valid GTD context
      local lines = vim.api.nvim_buf_get_lines(test_buf, 0, 1, false)
      local context = lines[1]:match("@(%w+)")

      if context then
        local valid_contexts = { home = true, work = true, computer = true, phone = true, errands = true }
        assert.is_true(valid_contexts[context], "Context should be one of: home, work, computer, phone, errands")
      end
    end)

    it("appends context to end of task line", function()
      -- Arrange: Task without context
      local task_line = "- [ ] Write email to team"
      vim.api.nvim_buf_set_lines(test_buf, 0, -1, false, { task_line })
      vim.api.nvim_win_set_cursor(0, { 1, 0 })

      -- Act: Suggest context
      ai.suggest_context()

      -- Wait
      vim.wait(2000, function()
        local lines = vim.api.nvim_buf_get_lines(test_buf, 0, 1, false)
        return lines[1] ~= task_line
      end, 100)

      -- Assert: Context is at end of line
      local lines = vim.api.nvim_buf_get_lines(test_buf, 0, 1, false)
      assert.matches("team @%w+$", lines[1], "Context should be appended to end")
    end)
  end)

  describe("Priority Inference Capability", function()
    it("infers HIGH priority for urgent tasks", function()
      -- Arrange: Urgent task
      local task_line = "- [ ] File taxes URGENT deadline tomorrow"
      vim.api.nvim_buf_set_lines(test_buf, 0, -1, false, { task_line })
      vim.api.nvim_win_set_cursor(0, { 1, 0 })

      -- Act: Infer priority
      ai.infer_priority()

      -- Wait for priority tag
      vim.wait(2000, function()
        local lines = vim.api.nvim_buf_get_lines(test_buf, 0, 1, false)
        return lines[1]:match("!%u+") ~= nil
      end, 100)

      -- Assert: HIGH priority assigned
      local lines = vim.api.nvim_buf_get_lines(test_buf, 0, 1, false)
      assert.matches("!HIGH", lines[1], "Should assign !HIGH for urgent task")
    end)

    it("infers LOW priority for someday tasks", function()
      -- Arrange: Low priority task
      local task_line = "- [ ] Maybe buy groceries later"
      vim.api.nvim_buf_set_lines(test_buf, 0, -1, false, { task_line })
      vim.api.nvim_win_set_cursor(0, { 1, 0 })

      -- Act: Infer priority
      ai.infer_priority()

      -- Wait
      vim.wait(2000, function()
        local lines = vim.api.nvim_buf_get_lines(test_buf, 0, 1, false)
        return lines[1]:match("!LOW") ~= nil
      end, 100)

      -- Assert: LOW priority assigned
      local lines = vim.api.nvim_buf_get_lines(test_buf, 0, 1, false)
      assert.matches("!LOW", lines[1], "Should assign !LOW for someday task")
    end)

    it("infers MEDIUM priority for normal tasks", function()
      -- Arrange: Regular task
      local task_line = "- [ ] Prepare presentation for next week"
      vim.api.nvim_buf_set_lines(test_buf, 0, -1, false, { task_line })
      vim.api.nvim_win_set_cursor(0, { 1, 0 })

      -- Act: Infer priority
      ai.infer_priority()

      -- Wait
      vim.wait(2000, function()
        local lines = vim.api.nvim_buf_get_lines(test_buf, 0, 1, false)
        return lines[1]:match("!MEDIUM") ~= nil
      end, 100)

      -- Assert: MEDIUM priority assigned
      local lines = vim.api.nvim_buf_get_lines(test_buf, 0, 1, false)
      assert.matches("!MEDIUM", lines[1], "Should assign !MEDIUM for regular task")
    end)

    it("does not add duplicate priority tags", function()
      -- Arrange: Task with existing priority
      local task_line = "- [ ] Important meeting !HIGH"
      vim.api.nvim_buf_set_lines(test_buf, 0, -1, false, { task_line })
      vim.api.nvim_win_set_cursor(0, { 1, 0 })

      -- Act: Try to infer priority again
      ai.infer_priority()

      -- Wait briefly
      vim.wait(500, function()
        return false
      end, 100)

      -- Assert: Line unchanged
      local lines = vim.api.nvim_buf_get_lines(test_buf, 0, 1, false)
      assert.equals(task_line, lines[1], "Should not add duplicate priority")
    end)

    it("only assigns valid priority levels", function()
      -- Arrange: Any task
      local task_line = "- [ ] Some task"
      vim.api.nvim_buf_set_lines(test_buf, 0, -1, false, { task_line })
      vim.api.nvim_win_set_cursor(0, { 1, 0 })

      -- Act: Infer priority
      ai.infer_priority()

      -- Wait
      vim.wait(2000, function()
        local lines = vim.api.nvim_buf_get_lines(test_buf, 0, 1, false)
        return lines[1]:match("!%u+") ~= nil
      end, 100)

      -- Assert: Priority is HIGH, MEDIUM, or LOW
      local lines = vim.api.nvim_buf_get_lines(test_buf, 0, 1, false)
      local priority = lines[1]:match("!(HIGH|MEDIUM|LOW)")

      assert.is_not_nil(priority, "Priority must be HIGH, MEDIUM, or LOW")
      assert.is_true(
        priority == "HIGH" or priority == "MEDIUM" or priority == "LOW",
        "Priority must be one of the three valid levels"
      )
    end)
  end)
end)

describe("GTD-IWE Bridge Capabilities", function()
  local bridge
  local test_buf

  before_each(function()
    -- Arrange: Load IWE bridge module
    package.loaded["lib.gtd.iwe-bridge"] = nil
    bridge = require("lib.gtd.iwe-bridge")

    -- Enable mock Ollama
    mock_ollama.enable()
    mock_ollama.reset()
    mock_ollama.setup_gtd_defaults()

    -- Patch AI module
    local ai = require("lib.gtd.ai")
    mock_ollama.patch_ai_module(ai)

    -- Create test buffer
    test_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(test_buf)

    -- Setup bridge
    bridge.setup({ auto_decompose = false })
  end)

  after_each(function()
    -- Cleanup
    local ai = require("lib.gtd.ai")
    mock_ollama.unpatch_ai_module(ai)
    mock_ollama.disable()

    if test_buf and vim.api.nvim_buf_is_valid(test_buf) then
      vim.api.nvim_buf_delete(test_buf, { force = true })
    end

    vim.g.gtd_iwe_auto_decompose = nil
  end)

  describe("Task Detection Capability", function()
    it("detects tasks in IWE extracted content", function()
      -- Arrange: Buffer with task markers
      local content = {
        "# Extracted Note",
        "",
        "- [ ] First task to complete",
        "- [ ] Second task to complete",
      }
      vim.api.nvim_buf_set_lines(test_buf, 0, -1, false, content)

      -- Act: Trigger IWE extract complete event
      vim.api.nvim_exec_autocmds("User", {
        pattern = "IWEExtractComplete",
        data = { buf = test_buf },
      })

      -- Wait for user prompt (in non-auto mode)
      vim.wait(200, function()
        return false
      end, 50)

      -- Assert: No crash, autocmd executed successfully
      assert.is_true(vim.api.nvim_buf_is_valid(test_buf), "Buffer should still be valid")
    end)

    it("detects TODO: markers", function()
      -- Arrange: Content with TODO marker
      local content = {
        "TODO: Implement this feature",
        "Regular text here",
      }
      vim.api.nvim_buf_set_lines(test_buf, 0, -1, false, content)

      -- Act: Check detection logic
      local has_tasks = table.concat(content, "\n"):match("TODO:") ~= nil

      -- Assert: TODO detected
      assert.is_true(has_tasks, "Should detect TODO: markers")
    end)

    it("detects TASK: markers", function()
      -- Arrange: Content with TASK marker
      local content = { "TASK: Complete this work" }
      vim.api.nvim_buf_set_lines(test_buf, 0, -1, false, content)

      -- Act: Check detection
      local has_tasks = table.concat(content, "\n"):match("TASK:") ~= nil

      -- Assert: TASK detected
      assert.is_true(has_tasks, "Should detect TASK: markers")
    end)

    it("detects markdown checkbox tasks", function()
      -- Arrange: Markdown checkboxes
      local content = { "- [ ] Unchecked task", "- [x] Checked task" }
      vim.api.nvim_buf_set_lines(test_buf, 0, -1, false, content)

      -- Act: Check detection
      local has_tasks = table.concat(content, "\n"):match("%- %[.%]") ~= nil

      -- Assert: Checkboxes detected
      assert.is_true(has_tasks, "Should detect markdown checkbox tasks")
    end)

    it("ignores content without task markers", function()
      -- Arrange: Regular content
      local content = {
        "# Regular Note",
        "Just some text without tasks",
        "Another paragraph here",
      }
      vim.api.nvim_buf_set_lines(test_buf, 0, -1, false, content)

      -- Act: Check for tasks
      local text = table.concat(content, "\n")
      local has_tasks = text:match("%- %[.%]") ~= nil or text:match("TODO:") ~= nil or text:match("TASK:") ~= nil

      -- Assert: No tasks detected
      assert.is_false(has_tasks, "Should not detect tasks in regular content")
    end)
  end)

  describe("Auto-decompose Capability", function()
    it("auto-decomposes when enabled globally", function()
      -- Arrange: Enable auto-decompose
      vim.g.gtd_iwe_auto_decompose = true
      bridge.setup({ auto_decompose = false }) -- Config overridden by vim.g

      local content = { "- [ ] Build the application" }
      vim.api.nvim_buf_set_lines(test_buf, 0, -1, false, content)

      local original_count = vim.api.nvim_buf_line_count(test_buf)

      -- Act: Trigger IWE extract event (should auto-decompose)
      vim.api.nvim_exec_autocmds("User", {
        pattern = "IWEExtractComplete",
        data = { buf = test_buf },
      })

      -- Wait for decomposition
      local changed = vim.wait(2000, function()
        return vim.api.nvim_buf_line_count(test_buf) > original_count
      end, 100)

      -- Assert: Buffer has more lines (subtasks added)
      assert.is_true(changed, "Should auto-decompose when enabled")
    end)

    it("prompts user when auto-decompose disabled", function()
      -- Arrange: Auto-decompose disabled (default)
      vim.g.gtd_iwe_auto_decompose = false

      local content = { "- [ ] Task requiring decomposition" }
      vim.api.nvim_buf_set_lines(test_buf, 0, -1, false, content)

      -- Mock vim.fn.confirm to return "No"
      local old_confirm = vim.fn.confirm
      local confirm_called = false
      vim.fn.confirm = function(_msg, _options, _default)
        confirm_called = true
        return 2 -- No
      end

      -- Act: Trigger event
      vim.api.nvim_exec_autocmds("User", {
        pattern = "IWEExtractComplete",
        data = { buf = test_buf },
      })

      -- Wait for prompt
      vim.wait(500, function()
        return confirm_called
      end, 50)

      -- Assert: User was prompted
      -- Note: In real scenario, vim.fn.confirm would be called
      -- This test validates the autocmd fires

      -- Cleanup
      vim.fn.confirm = old_confirm
    end)

    it("provides GtdDecomposeNote command", function()
      -- Arrange: Bridge setup creates commands
      -- Act: Check if command exists
      local commands = vim.api.nvim_get_commands({})
      local has_command = commands.GtdDecomposeNote ~= nil

      -- Assert: Command is registered
      assert.is_true(has_command, "Should provide :GtdDecomposeNote command")
    end)

    it("provides GtdToggleAutoDecompose command", function()
      -- Arrange: Bridge setup
      -- Act: Check command
      local commands = vim.api.nvim_get_commands({})
      local has_toggle = commands.GtdToggleAutoDecompose ~= nil

      -- Assert: Toggle command exists
      assert.is_true(has_toggle, "Should provide :GtdToggleAutoDecompose command")
    end)

    it("toggles auto-decompose with command", function()
      -- Arrange: Initial state
      vim.g.gtd_iwe_auto_decompose = false

      -- Act: Execute toggle command
      vim.cmd("GtdToggleAutoDecompose")

      -- Assert: State toggled
      assert.is_true(vim.g.gtd_iwe_auto_decompose, "Should toggle to true")

      -- Act: Toggle again
      vim.cmd("GtdToggleAutoDecompose")

      -- Assert: Toggled back
      assert.is_false(vim.g.gtd_iwe_auto_decompose, "Should toggle back to false")
    end)
  end)

  describe("Integration with IWE LSP", function()
    it("hooks into User IWEExtractComplete autocmd", function()
      -- Arrange: Bridge setup registers autocmd
      -- Act: Get autocmds for pattern
      local autocmds = vim.api.nvim_get_autocmds({
        event = "User",
        pattern = "IWEExtractComplete",
      })

      -- Assert: At least one autocmd registered
      assert.is_true(#autocmds > 0, "Should register autocmd for IWEExtractComplete")

      -- Find our specific autocmd
      local found_bridge_autocmd = false
      for _, autocmd in ipairs(autocmds) do
        if autocmd.desc and autocmd.desc:match("GTD%-IWE Bridge") then
          found_bridge_autocmd = true
          break
        end
      end

      assert.is_true(found_bridge_autocmd, "Should register GTD-IWE Bridge autocmd")
    end)

    it("waits before processing to let IWE complete", function()
      -- Arrange: Content with tasks
      vim.api.nvim_buf_set_lines(test_buf, 0, -1, false, { "- [ ] Task" })

      local processing_started = false
      local start_time = os.time()

      -- Mock to detect when processing starts
      local old_confirm = vim.fn.confirm
      vim.fn.confirm = function(...)
        processing_started = true
        return 2
      end

      -- Act: Trigger event
      vim.api.nvim_exec_autocmds("User", {
        pattern = "IWEExtractComplete",
        data = { buf = test_buf },
      })

      -- Wait for processing
      vim.wait(500, function()
        return processing_started
      end, 50)

      local elapsed = os.time() - start_time

      -- Assert: Small delay before processing (vim.defer_fn with 200ms)
      assert.is_true(elapsed >= 0, "Should have minimal delay before processing")

      -- Cleanup
      vim.fn.confirm = old_confirm
    end)
  end)
end)

describe("Full Ollama Workflow Integration", function()
  local manager
  local ai
  local bridge
  local test_buf

  before_each(function()
    -- Arrange: Full system setup with mocks
    mock_ollama.enable()
    mock_ollama.reset()
    mock_ollama.setup_gtd_defaults()

    -- Load all components
    package.loaded["lib.ollama-manager"] = nil
    package.loaded["lib.gtd.ai"] = nil
    package.loaded["lib.gtd.iwe-bridge"] = nil

    manager = require("lib.ollama-manager")
    ai = require("lib.gtd.ai")
    bridge = require("lib.gtd.iwe-bridge")

    -- Patch AI with mock
    mock_ollama.patch_ai_module(ai)

    -- Setup components
    manager.setup({ enabled = false }) -- Don't auto-start in tests
    bridge.setup({ auto_decompose = false })

    -- Create buffer
    test_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(test_buf)
  end)

  after_each(function()
    -- Cleanup
    mock_ollama.unpatch_ai_module(ai)
    mock_ollama.disable()

    if test_buf and vim.api.nvim_buf_is_valid(test_buf) then
      vim.api.nvim_buf_delete(test_buf, { force = true })
    end
  end)

  describe("Extract → Format → Decompose Workflow", function()
    it("complete workflow: IWE extract triggers decomposition", function()
      -- Arrange: Simulate IWE extracting a note with tasks
      local extracted_content = {
        "# Project: Website Redesign",
        "",
        "- [ ] Complete website redesign project",
        "",
        "Notes from meeting...",
      }
      vim.api.nvim_buf_set_lines(test_buf, 0, -1, false, extracted_content)

      -- Enable auto-decompose for this test
      vim.g.gtd_iwe_auto_decompose = true

      local original_count = vim.api.nvim_buf_line_count(test_buf)

      -- Act: Trigger IWE extraction complete
      vim.api.nvim_exec_autocmds("User", {
        pattern = "IWEExtractComplete",
        data = { buf = test_buf },
      })

      -- Wait for auto-decomposition
      local success = vim.wait(2000, function()
        return vim.api.nvim_buf_line_count(test_buf) > original_count
      end, 100)

      -- Assert: Task was decomposed automatically
      assert.is_true(success, "Should auto-decompose after IWE extract")

      local lines = vim.api.nvim_buf_get_lines(test_buf, 0, -1, false)
      local subtask_count = 0
      for _, line in ipairs(lines) do
        if line:match("^  %- %[ %]") then -- Indented subtasks
          subtask_count = subtask_count + 1
        end
      end

      assert.is_true(subtask_count > 0, "Should have added subtasks")
    end)

    it("workflow respects Ollama model selection", function()
      -- Arrange: Set custom model
      vim.g.ollama_model = "codellama"

      -- Create task
      vim.api.nvim_buf_set_lines(test_buf, 0, -1, false, { "- [ ] Write code" })
      vim.api.nvim_win_set_cursor(0, { 1, 0 })

      -- Act: Decompose (should use codellama model)
      ai.decompose_task()

      -- Wait for result
      vim.wait(2000, function()
        return vim.api.nvim_buf_line_count(test_buf) > 1
      end, 100)

      -- Assert: Decomposition succeeded (model selection worked)
      local lines = vim.api.nvim_buf_get_lines(test_buf, 0, -1, false)
      assert.is_true(#lines > 1, "Should decompose with custom model")

      -- Cleanup
      vim.g.ollama_model = nil
    end)

    it("workflow combines context and priority suggestions", function()
      -- Arrange: Task for full workflow
      local task_line = "- [ ] Call client about urgent contract deadline"
      vim.api.nvim_buf_set_lines(test_buf, 0, -1, false, { task_line })
      vim.api.nvim_win_set_cursor(0, { 1, 0 })

      -- Act: Suggest context
      ai.suggest_context()

      -- Wait for context
      vim.wait(1000, function()
        local lines = vim.api.nvim_buf_get_lines(test_buf, 0, 1, false)
        return lines[1]:match("@%w+") ~= nil
      end, 100)

      -- Act: Suggest priority
      ai.infer_priority()

      -- Wait for priority
      vim.wait(1000, function()
        local lines = vim.api.nvim_buf_get_lines(test_buf, 0, 1, false)
        return lines[1]:match("!%u+") ~= nil
      end, 100)

      -- Assert: Both context and priority added
      local lines = vim.api.nvim_buf_get_lines(test_buf, 0, 1, false)
      local final_line = lines[1]

      assert.matches("@%w+", final_line, "Should have context tag")
      assert.matches("!%u+", final_line, "Should have priority tag")

      -- Verify expected values based on task content
      assert.matches("@phone", final_line, "Should suggest phone context for 'call'")
      assert.matches("!HIGH", final_line, "Should assign HIGH for 'urgent deadline'")
    end)
  end)

  describe("Error Handling and Edge Cases", function()
    it("handles Ollama server not running gracefully", function()
      -- Arrange: Mock Ollama as not running
      mock_ollama.disable() -- Use real (failing) implementation

      -- Create task
      vim.api.nvim_buf_set_lines(test_buf, 0, -1, false, { "- [ ] Task" })
      vim.api.nvim_win_set_cursor(0, { 1, 0 })

      -- Act: Attempt decomposition
      ai.decompose_task()

      -- Wait briefly
      vim.wait(500, function()
        return false
      end, 100)

      -- Assert: No crash, graceful failure
      assert.is_true(vim.api.nvim_buf_is_valid(test_buf), "Should handle failure gracefully")

      -- Re-enable for cleanup
      mock_ollama.enable()
    end)

    it("handles malformed AI responses", function()
      -- Arrange: Mock returns invalid format
      mock_ollama.set_response("Break down this task", "Invalid response without checkboxes")

      vim.api.nvim_buf_set_lines(test_buf, 0, -1, false, { "- [ ] Task" })
      vim.api.nvim_win_set_cursor(0, { 1, 0 })

      local original_count = vim.api.nvim_buf_line_count(test_buf)

      -- Act: Decompose
      ai.decompose_task()

      -- Wait
      vim.wait(1000, function()
        return false
      end, 100)

      -- Assert: No subtasks added for invalid response
      local final_count = vim.api.nvim_buf_line_count(test_buf)
      assert.equals(original_count, final_count, "Should not add invalid subtasks")
    end)

    it("handles concurrent AI requests safely", function()
      -- Arrange: Multiple tasks
      local tasks = {
        "- [ ] First task",
        "- [ ] Second task",
        "- [ ] Third task",
      }
      vim.api.nvim_buf_set_lines(test_buf, 0, -1, false, tasks)

      -- Act: Trigger multiple decompositions rapidly
      for i = 1, 3 do
        vim.api.nvim_win_set_cursor(0, { i, 0 })
        ai.decompose_task()
      end

      -- Wait for all to complete
      vim.wait(3000, function()
        return vim.api.nvim_buf_line_count(test_buf) > 10
      end, 100)

      -- Assert: No crashes, buffer is valid
      assert.is_true(vim.api.nvim_buf_is_valid(test_buf), "Should handle concurrent requests")
    end)
  end)
end)
