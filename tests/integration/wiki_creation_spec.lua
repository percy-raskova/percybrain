-- Integration Test: Wiki Note Creation Workflow
-- Kent Beck: "This test tells the complete story of creating a wiki note"
--
-- Workflow Tested:
-- 1. User creates new note with template
-- 2. Content is edited and saved
-- 3. AI processing happens in background
-- 4. Hugo validation confirms publishability
-- 5. User receives completion notification

describe("Wiki Note Creation Workflow [INTEGRATION]", function()
  -- Load test helpers
  local env_setup = require("tests.helpers.environment_setup")
  local async_helpers = require("tests.helpers.async_helpers")
  local mock_services = require("tests.helpers.mock_services")
  local workflow_builders = require("tests.helpers.workflow_builders")

  -- Test state
  local test_vault
  local original_env
  local services

  before_each(function()
    -- =========================================================================
    -- ARRANGE: Set up clean test environment
    -- =========================================================================

    -- Create isolated test vault
    test_vault = env_setup.create_test_vault("wiki_creation_test")

    -- Save and override environment
    original_env = env_setup.setup_env(test_vault)

    -- Create mock services
    services = mock_services.create_test_services({
      ollama = {
        delay_ms = 50, -- Fast for testing
        model = "llama3.2:latest",
      },
      hugo = {
        content_path = test_vault,
      },
    })
    services:setup()

    -- Load PercyBrain components with test configuration
    env_setup.load_component("template-system", {
      vault_path = test_vault,
      templates_dir = test_vault .. "/templates",
    })

    env_setup.load_component("write-quit-pipeline", {
      ai_processor = services.ollama,
      auto_process = true,
    })

    env_setup.load_component("hugo-menu", {
      content_path = test_vault,
      validator = services.hugo,
    })

    env_setup.load_component("ai-model-selector", {
      default_model = "llama3.2:latest",
    })
  end)

  after_each(function()
    -- =========================================================================
    -- CLEANUP: Restore original state
    -- =========================================================================

    -- Clear any open buffers
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(buf) then
        pcall(vim.api.nvim_buf_delete, buf, { force = true })
      end
    end

    -- Clear autocmds
    env_setup.clear_autocmds()

    -- Teardown services
    services:teardown()

    -- Restore environment
    env_setup.restore_env(original_env)

    -- Clean up test vault
    env_setup.cleanup_test_vault(test_vault)

    -- Verify clean state
    local is_clean, issues = env_setup.verify_clean_state()
    if not is_clean then
      print("Warning: Test cleanup issues detected:")
      for _, issue in ipairs(issues) do
        print("  - " .. issue)
      end
    end
  end)

  describe("Happy Path: Complete Wiki Creation", function()
    it("creates wiki note from template through to AI processing", function()
      -- =====================================================================
      -- PHASE 1: Template Selection and File Creation
      -- =====================================================================

      -- Arrange
      local template_system = require("lib.template-system")
      local note_title = "Integration Test Wiki Note"

      -- Act: Create note from wiki template
      local file_path = template_system.create_from_template("wiki", note_title)

      -- Assert: File created in correct location
      assert.is_not_nil(file_path, "File path should be returned")
      assert.is_true(vim.fn.filereadable(file_path) == 1, "File should exist")
      assert.is_false(file_path:match("/inbox/") ~= nil, "Wiki notes should not be in inbox")

      -- Assert: Template applied correctly
      local content = table.concat(vim.fn.readfile(file_path), "\n")
      assert.is_true(content:match("title: " .. note_title) ~= nil, "Title should be set")
      assert.is_true(content:match("draft: false") ~= nil, "Draft should be false")
      assert.is_true(content:match("date: %d%d%d%d%-%d%d%-%d%d") ~= nil, "Date should be set")

      -- =====================================================================
      -- PHASE 2: Content Editing
      -- =====================================================================

      -- Arrange: Open file in buffer
      vim.cmd("edit " .. file_path)
      local buf = vim.api.nvim_get_current_buf()
      assert.is_true(vim.api.nvim_buf_is_valid(buf), "Buffer should be valid")

      -- Act: Add content to the note
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      table.insert(lines, "")
      table.insert(lines, "## Introduction")
      table.insert(lines, "This is my wiki note about important topics.")
      table.insert(lines, "")
      table.insert(lines, "## Key Points")
      table.insert(lines, "- First important point")
      table.insert(lines, "- Second important point")

      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

      -- Assert: Content added to buffer
      local updated_content = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
      assert.is_true(updated_content:match("This is my wiki note") ~= nil, "Content should be in buffer")

      -- =====================================================================
      -- PHASE 3: Save and Trigger Pipeline
      -- =====================================================================

      -- Arrange: Track pipeline state
      local pipeline = require("lib.write-quit-pipeline")
      local processing_started = false
      local processing_completed = false
      local processing_result = nil

      -- Set up callbacks to track processing
      pipeline.set_processing_callback(function()
        processing_started = true
      end)

      pipeline.set_completion_callback(function(result)
        processing_completed = true
        processing_result = result
      end)

      -- Act: Save the buffer (triggers BufWritePost autocmd)
      vim.cmd("write")

      -- Assert: File saved to disk
      local saved_content = table.concat(vim.fn.readfile(file_path), "\n")
      assert.is_true(saved_content:match("This is my wiki note") ~= nil, "Content should be saved to file")

      -- Assert: Pipeline started processing
      assert.is_true(processing_started, "Pipeline should start on save")

      -- Assert: Editor remains responsive
      assert.is_false(pipeline.is_processing_blocking(), "Processing should be non-blocking")

      -- =====================================================================
      -- PHASE 4: AI Processing Completion
      -- =====================================================================

      -- Act: Wait for AI processing to complete
      local success, error_msg = async_helpers.wait_for_pipeline_completion(
        pipeline,
        2000 -- 2 second timeout
      )

      -- Assert: Processing completed successfully
      assert.is_true(success, "Processing should complete: " .. (error_msg or ""))
      assert.is_true(processing_completed, "Completion callback should fire")
      assert.is_not_nil(processing_result, "Should have processing result")

      -- Assert: Correct processing status
      local status = pipeline.get_processing_status()
      assert.equals("completed", status.state, "Status should be completed")
      assert.is_nil(status.error, "Should have no errors")

      -- Assert: AI model was used correctly
      assert.equals("llama3.2:latest", status.model_used, "Should use configured model")

      -- Assert: Mock AI was called
      assert.equals(1, services.ollama.call_count, "AI should be called once")
      assert.is_not_nil(services.ollama.last_prompt, "AI should receive prompt")

      -- =====================================================================
      -- PHASE 5: Hugo Validation
      -- =====================================================================

      -- Arrange
      local hugo_menu = require("lib.hugo-menu")

      -- Act: Validate the note for publishing
      local is_valid, validation_errors = hugo_menu.validate_file_for_publishing(file_path)

      -- Assert: Note passes Hugo validation
      assert.is_true(is_valid, "Wiki note should be valid for Hugo")
      assert.is_nil(validation_errors, "Should have no validation errors")

      -- Act: Check publishing eligibility
      local should_publish, reason = hugo_menu.should_publish_file(file_path)

      -- Assert: Note is publishable
      assert.is_true(should_publish, "Wiki note should be publishable")
      assert.is_nil(reason, "Should have no reason preventing publishing")

      -- =====================================================================
      -- PHASE 6: User Notifications
      -- =====================================================================

      -- Assert: User received appropriate notifications
      assert.is_true(services.notifier:has_message("completed"), "User should be notified of completion")

      -- Check notification details
      local has_ai_notification = services.notifier:has_message("AI") or services.notifier:has_message("processing")

      assert.is_true(has_ai_notification, "Notification should mention AI processing")

      -- Assert: No error notifications
      local error_messages = services.notifier:get_messages_by_level(vim.log.levels.ERROR)
      assert.equals(0, #error_messages, "Should have no error notifications")
    end)

    it("handles multiple wiki notes in sequence", function()
      -- Test that creating multiple notes doesn't cause conflicts

      local template_system = require("lib.template-system")

      -- Create first note
      local file1 = template_system.create_from_template("wiki", "First Note")
      vim.cmd("edit " .. file1)
      vim.cmd("write")

      -- Create second note while first is processing
      local file2 = template_system.create_from_template("wiki", "Second Note")
      vim.cmd("edit " .. file2)
      vim.cmd("write")

      -- Wait for both to complete
      vim.wait(500)

      -- Both files should exist and be valid
      assert.is_true(vim.fn.filereadable(file1) == 1)
      assert.is_true(vim.fn.filereadable(file2) == 1)

      -- Both should have been processed
      assert.equals(2, services.ollama.call_count, "Both notes should be processed")
    end)
  end)

  describe("Error Scenarios", function()
    it("handles AI service failure gracefully", function()
      -- Configure AI to fail
      services.ollama.fail_rate = 1.0

      -- Create and save wiki note
      local template_system = require("lib.template-system")
      local file_path = template_system.create_from_template("wiki", "Error Test")

      vim.cmd("edit " .. file_path)
      vim.cmd("write")

      -- Wait for processing attempt
      vim.wait(200)

      -- Check pipeline status
      local pipeline = require("lib.write-quit-pipeline")
      local status = pipeline.get_processing_status()

      -- Should handle error gracefully
      assert.equals("error", status.state, "Should be in error state")
      assert.is_not_nil(status.error_message, "Should have error message")

      -- File should still be valid and saved
      assert.is_true(vim.fn.filereadable(file_path) == 1, "File should still exist")

      -- User should be notified of error
      assert.is_true(
        services.notifier:has_message("error") or services.notifier:has_message("failed"),
        "User should be notified of failure"
      )
    end)

    it("rejects invalid Hugo frontmatter", function()
      -- Create note with missing required fields
      local invalid_file = test_vault .. "/invalid-note.md"
      vim.fn.writefile({
        "---",
        "title: Missing Date and Draft",
        "---",
        "",
        "Content here",
      }, invalid_file)

      -- Try to validate
      local hugo_menu = require("lib.hugo-menu")
      local is_valid, errors = hugo_menu.validate_file_for_publishing(invalid_file)

      -- Should fail validation
      assert.is_false(is_valid, "Should fail validation")
      assert.is_not_nil(errors, "Should have error details")
      assert.is_true(#errors > 0, "Should have specific errors")

      -- Check for specific missing fields
      local error_text = table.concat(errors, " ")
      assert.is_true(error_text:match("date") ~= nil, "Should mention missing date")
      assert.is_true(error_text:match("draft") ~= nil, "Should mention missing draft")
    end)

    it("prevents publishing of draft notes", function()
      -- Create draft note
      local draft_file = test_vault .. "/draft-note.md"
      vim.fn.writefile({
        "---",
        "title: Draft Note",
        "date: 2025-10-20",
        "draft: true",
        "---",
        "",
        "Draft content",
      }, draft_file)

      -- Check publishing status
      local hugo_menu = require("lib.hugo-menu")
      local should_publish, reason = hugo_menu.should_publish_file(draft_file)

      -- Should not publish drafts
      assert.is_false(should_publish, "Should not publish draft")
      assert.is_not_nil(reason, "Should have reason")
      assert.is_true(reason:match("draft") ~= nil, "Reason should mention draft status")
    end)
  end)

  describe("Component Integration Points", function()
    it("correctly distinguishes wiki from fleeting notes", function()
      local template_system = require("lib.template-system")
      local pipeline = require("lib.write-quit-pipeline")

      -- Create wiki note
      local wiki_file = template_system.create_from_template("wiki", "Wiki Test")
      assert.is_false(wiki_file:match("/inbox/") ~= nil, "Wiki not in inbox")

      -- Create fleeting note
      local fleeting_file = template_system.create_from_template("fleeting", "Fleeting Test")
      assert.is_true(fleeting_file:match("/inbox/") ~= nil, "Fleeting in inbox")

      -- Check pipeline detection
      assert.equals("wiki", pipeline.detect_note_type(wiki_file))
      assert.equals("fleeting", pipeline.detect_note_type(fleeting_file))
    end)

    it("respects AI model selection", function()
      -- Select different model
      local model_selector = require("lib.ai-model-selector")
      model_selector.set_model("codellama")

      -- Create and process note
      local template_system = require("lib.template-system")
      local file_path = template_system.create_from_template("wiki", "Model Test")

      vim.cmd("edit " .. file_path)
      vim.cmd("write")

      -- Wait for processing
      vim.wait(200)

      -- Check that selected model was used
      local pipeline = require("lib.write-quit-pipeline")
      local status = pipeline.get_processing_status()

      assert.equals("codellama", status.model_used, "Should use selected model")
    end)

    it("excludes inbox notes from Hugo publishing", function()
      -- Create fleeting note in inbox
      local template_system = require("lib.template-system")
      local inbox_file = template_system.create_from_template("fleeting", "Inbox Note")

      -- Check publishing status
      local hugo_menu = require("lib.hugo-menu")
      local should_publish, reason = hugo_menu.should_publish_file(inbox_file)

      -- Should not publish inbox notes
      assert.is_false(should_publish, "Should not publish inbox notes")
      assert.is_not_nil(reason, "Should have reason")
      assert.is_true(reason:lower():match("inbox") ~= nil, "Reason should mention inbox")
    end)
  end)

  -- =========================================================================
  -- BUILDER PATTERN EXAMPLES
  -- =========================================================================
  describe("Happy Path with Builder Pattern", function()
    it("creates wiki note using fluent builder", function()
      -- Arrange & Act: Use builder for setup
      local context = workflow_builders
        .wiki_creation_builder()
        :with_template("wiki")
        :with_title("Builder Pattern Test")
        :with_content({ "This is test content", "Multiple lines supported" })
        :with_ai_model("llama3.2")
        :execute()

      -- Assert: File created successfully
      assert.is_not_nil(context.file_path)
      assert.is_true(vim.fn.filereadable(context.file_path) == 1)

      -- Assert: Content is in file
      local file_content = vim.fn.readfile(context.file_path)
      local content_string = table.concat(file_content, "\n")
      assert.is_truthy(content_string:match("This is test content"))

      -- Cleanup
      context:cleanup()
    end)

    it("handles AI unavailable scenario with builder", function()
      -- Arrange & Act: Configure AI as unavailable
      local context = workflow_builders.wiki_creation_builder():with_template("wiki"):ai_unavailable():execute()

      -- Assert: Note created despite AI unavailability
      assert.is_not_nil(context.file_path)

      -- Assert: User notified about AI unavailability
      local pipeline = require("lib.write-quit-pipeline")
      local status = pipeline.get_processing_status()
      assert.equals("skipped", status.state)

      -- Cleanup
      context:cleanup()
    end)

    it("tests slow AI response with builder", function()
      -- Arrange: Configure slow AI
      local context = workflow_builders
        .wiki_creation_builder()
        :with_template("wiki")
        :with_title("Slow AI Test")
        :ai_slow(4500) -- 4.5 seconds
        :execute()

      -- Act: Save to trigger processing
      vim.cmd("edit " .. context.file_path)
      vim.cmd("write")

      -- Assert: Processing eventually completes
      local success = workflow_builders.wait_for_condition(function()
        local pipeline = require("lib.write-quit-pipeline")
        return pipeline.get_processing_status().state == "completed"
      end, 5000, "AI processing with slow response")

      assert.is_true(success, "Should complete even with slow AI")

      -- Assert: Performance warning issued
      local pipeline = require("lib.write-quit-pipeline")
      local notifications = pipeline.get_notifications()
      local has_warning = false
      for _, notif in ipairs(notifications) do
        if notif:match("slow") or notif:match("performance") then
          has_warning = true
          break
        end
      end
      assert.is_true(has_warning, "Should warn about slow performance")

      -- Cleanup
      context:cleanup()
    end)

    it("validates Hugo frontmatter with builder", function()
      -- Arrange: Create note with invalid Hugo frontmatter
      local context = workflow_builders
        .wiki_creation_builder()
        :with_template("wiki")
        :with_title("Invalid Hugo Test")
        :hugo_invalid()
        :execute()

      -- Act: Request Hugo validation
      local hugo = require("lib.hugo-menu")
      local is_valid, errors = hugo.validate_file_for_publishing(context.file_path)

      -- Assert: Validation fails with clear errors
      assert.is_false(is_valid, "Should fail validation")
      assert.is_not_nil(errors, "Should have error messages")

      -- Cleanup
      context:cleanup()
    end)
  end)

  describe("Error Scenarios with Builder Pattern", function()
    it("handles multiple concurrent operations gracefully", function()
      -- Arrange: Create multiple notes rapidly
      local contexts = {}

      for i = 1, 3 do
        local ctx =
          workflow_builders.wiki_creation_builder():with_template("wiki"):with_title("Concurrent Note " .. i):execute()
        table.insert(contexts, ctx)

        -- Rapidly save all notes
        vim.cmd("edit " .. ctx.file_path)
        vim.cmd("write")
      end

      -- Act: Wait for all processing to complete
      vim.wait(1000)

      -- Assert: All notes processed without errors
      local pipeline = require("lib.write-quit-pipeline")
      local queue_status = pipeline.get_queue_status()

      assert.equals(0, queue_status.pending, "Should have no pending operations")
      assert.is_true(queue_status.errors == nil or #queue_status.errors == 0, "Should have no processing errors")

      -- Cleanup
      for _, ctx in ipairs(contexts) do
        ctx:cleanup()
      end
    end)

    it("demonstrates error scenario builder", function()
      -- Arrange: Set up error scenario
      local error_context = workflow_builders.error_scenario_builder():with_ollama_timeout():execute()

      -- Act: Attempt to create and process a note
      local wiki_context =
        workflow_builders.wiki_creation_builder():with_template("wiki"):with_title("Error Test"):execute()

      vim.cmd("edit " .. wiki_context.file_path)
      vim.cmd("write")

      -- Wait for timeout to occur
      vim.wait(6000) -- Wait longer than 5s timeout

      -- Assert: Error handled gracefully
      local pipeline = require("lib.write-quit-pipeline")
      local status = pipeline.get_processing_status()

      assert.equals("error", status.state)
      assert.is_not_nil(status.error_message)
      assert.is_true(status.error_message:match("timeout") ~= nil, "Error should indicate timeout")

      -- Cleanup
      wiki_context:cleanup()
      error_context:cleanup()
    end)
  end)

  describe("Publishing Workflow with Builder", function()
    it("validates multiple notes for publishing", function()
      -- Arrange: Create mixed valid/invalid notes
      local pub_context = workflow_builders
        .publishing_builder()
        :with_valid_wiki_note("Valid Note 1")
        :with_valid_wiki_note("Valid Note 2")
        :with_invalid_wiki_note("Invalid Note", { "date" })
        :with_inbox_note("Inbox Note")
        :execute()

      -- Act: Validate all notes
      local validation_results = {}
      for _, file in ipairs(pub_context.files) do
        local is_valid = pub_context.hugo.validate_file_for_publishing(file)
        table.insert(validation_results, {
          file = file,
          valid = is_valid,
        })
      end

      -- Assert: Correct validation results
      local valid_count = 0
      local invalid_count = 0

      for _, result in ipairs(validation_results) do
        if result.valid then
          valid_count = valid_count + 1
        else
          invalid_count = invalid_count + 1
        end
      end

      assert.equals(2, valid_count, "Should have 2 valid notes")
      assert.equals(2, invalid_count, "Should have 2 invalid notes")

      -- Cleanup
      pub_context:cleanup()
    end)
  end)

  describe("Batch Operations with Builder", function()
    it("creates batch of test notes efficiently", function()
      -- Arrange & Act: Create batch of notes
      local notes = workflow_builders.create_test_notes_batch(env_setup.create_test_vault("batch_test"), 5, "wiki")

      -- Assert: All notes created
      assert.equals(5, #notes)

      for i, note_ctx in ipairs(notes) do
        assert.is_not_nil(note_ctx.file_path)
        assert.is_true(vim.fn.filereadable(note_ctx.file_path) == 1)

        -- Check content
        workflow_builders.assert_file_contains(
          note_ctx.file_path,
          "Content for note " .. i,
          "Note " .. i .. " should have correct content"
        )
      end

      -- Cleanup
      for _, note_ctx in ipairs(notes) do
        note_ctx:cleanup()
      end
    end)
  end)
end)
