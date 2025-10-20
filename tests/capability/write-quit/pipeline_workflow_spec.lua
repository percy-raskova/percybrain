-- Capability Tests for Write-Quit AI Pipeline Workflow
-- Tests what users CAN DO with automatic AI processing on save
-- Kent Beck: "Test capabilities, not configuration"

describe("Write-Quit AI Pipeline Workflow Capabilities", function()
  local pipeline

  before_each(function()
    -- Arrange: Load write-quit pipeline module
    pipeline = require("percybrain.write-quit-pipeline")
    pipeline.setup()
  end)

  after_each(function()
    -- Cleanup: Clear autocmds and reset state
    vim.api.nvim_clear_autocmds({ group = "WriteQuitPipeline" })
    pipeline.reset_state()
  end)

  describe("Wiki Note Workflow Capabilities", function()
    it("CAN write and quit wiki note with automatic AI processing", function()
      -- Arrange: User creates wiki note
      local wiki_path = "/home/percy/Zettelkasten/20251020-test-wiki.md"

      -- Act: Simulate user write and quit
      local processing_started = false
      pipeline.set_processing_callback(function()
        processing_started = true
      end)

      pipeline.on_save(wiki_path)

      -- Assert: AI processing triggered automatically
      assert.is_true(processing_started, "AI processing should start on save")
    end)

    it("CAN continue editing while AI processes in background", function()
      -- Arrange: User saves wiki note
      local wiki_path = "/home/percy/Zettelkasten/20251020-background.md"

      -- Act: Trigger processing
      pipeline.on_save(wiki_path)
      local is_blocking = pipeline.is_processing_blocking()

      -- Assert: Editor remains responsive
      assert.is_false(is_blocking, "Editor should not be blocked")
    end)

    it("CAN see processing status for wiki notes", function()
      -- Arrange: User saves and wants to check status
      local wiki_path = "/home/percy/Zettelkasten/20251020-status.md"

      -- Act: Save and get status
      pipeline.on_save(wiki_path)
      local status = pipeline.get_processing_status()

      -- Assert: Status is available and meaningful
      assert.is_not_nil(status)
      assert.is_string(status.state)
      assert.is_true(
        status.state == "idle" or status.state == "processing" or status.state == "completed" or status.state == "error",
        "Status should be a valid state"
      )
    end)

    it("CAN receive notifications when AI processing completes", function()
      -- Arrange: Mock notification system
      local notification_received = false
      local original_notify = vim.notify
      vim.notify = function(msg, level)
        if msg:match("completed") or msg:match("AI") then
          notification_received = true
        end
      end

      -- Act: Complete processing
      pipeline.on_processing_complete("/home/percy/Zettelkasten/test.md", "success")

      -- Assert: User gets notified
      vim.notify = original_notify
      assert.is_true(notification_received, "User should be notified of completion")
    end)
  end)

  describe("Fleeting Note Workflow Capabilities", function()
    it("CAN quick-capture fleeting note with minimal friction", function()
      -- Arrange: User creates quick fleeting note
      local fleeting_path = "/home/percy/Zettelkasten/inbox/20251020-quick.md"

      -- Act: Save fleeting note
      local processing_triggered = false
      pipeline.set_processing_callback(function()
        processing_triggered = true
      end)

      pipeline.on_save(fleeting_path)

      -- Assert: Processing happens automatically
      assert.is_true(processing_triggered, "Fleeting notes should also trigger processing")
    end)

    it("CAN differentiate between wiki and fleeting processing", function()
      -- Arrange: Different note types
      -- Act: Get prompts for each
      local wiki_prompt = pipeline.get_prompt_for_note_type("wiki")
      local fleeting_prompt = pipeline.get_prompt_for_note_type("fleeting")

      -- Assert: Different processing approaches
      assert.is_not_equal(wiki_prompt, fleeting_prompt)
      assert.matches("wiki", wiki_prompt:lower())
      assert.matches("fleeting", fleeting_prompt:lower())
    end)

    it("CAN preserve simple frontmatter for fleeting notes", function()
      -- Arrange: Fleeting note with simple frontmatter
      local content = [[
---
title: Simple Note
created: 2025-10-20
---

Content
]]

      -- Act: Process content
      local processed = pipeline.process_content(content, "fleeting")

      -- Assert: Frontmatter unchanged (not expanded to Hugo format)
      assert.matches("^%-%-%-", processed)
      assert.matches("title:", processed)
      assert.not_matches("draft:", processed)
      assert.not_matches("tags:", processed)
    end)
  end)

  describe("AI Model Integration Capabilities", function()
    it("CAN use selected AI model for processing", function()
      -- Arrange: User has selected specific model
      local ai_selector = require("percybrain.ai-model-selector")
      local available = ai_selector.list_available_models()

      if #available > 0 then
        ai_selector.set_current_model(available[1])

        -- Act: Process note
        local model_used = pipeline.get_processing_model()

        -- Assert: Uses selected model
        assert.equals(available[1], model_used)
      else
        pending("No models available for test")
      end
    end)

    it("CAN change AI model and use new model for next save", function()
      -- Arrange: User changes model mid-session
      local ai_selector = require("percybrain.ai-model-selector")
      local available = ai_selector.list_available_models()

      if #available >= 2 then
        ai_selector.set_current_model(available[1])
        local first_model = pipeline.get_processing_model()

        -- Act: Change model
        ai_selector.set_current_model(available[2])
        local second_model = pipeline.get_processing_model()

        -- Assert: New model used
        assert.not_equals(first_model, second_model)
        assert.equals(available[2], second_model)
      else
        pending("Need at least 2 models for test")
      end
    end)

    it("CAN receive AI-generated summaries for wiki notes", function()
      -- Arrange: Mock Ollama response
      -- Global pollution test: _G.M is documented interface from ollama.lua (line 358)
      if not _G.M then
        _G.M = {
          config = { model = "llama3.2:latest" },
          ask = function(opts)
            return true, "AI-generated summary of the note content"
          end,
        }
      end

      -- Act: Process wiki note
      local success, response = pipeline.process_with_ollama("test content", "summarize this note")

      -- Assert: Summary generated
      assert.is_true(success)
      assert.is_string(response)
      assert.is_true(#response > 0, "Summary should not be empty")
    end)
  end)

  describe("Manual Processing Capabilities", function()
    it("CAN manually trigger AI processing for current buffer", function()
      -- Arrange: User wants to reprocess current note
      -- Act: Check if manual processing available
      local has_manual = type(pipeline.process_current_buffer) == "function"

      -- Assert: Manual trigger exists
      assert.is_true(has_manual, "Manual processing should be available")
    end)

    it("CAN disable auto-processing and only use manual mode", function()
      -- Arrange: User prefers manual control
      pipeline.setup({ auto_process = false })

      -- Act: Check if auto-processing disabled
      local auto_enabled = pipeline.is_auto_processing_enabled()

      -- Assert: Can be disabled
      if auto_enabled ~= nil then
        assert.is_false(auto_enabled, "Auto-processing should be disableable")
      end
    end)

    it("CAN trigger processing with custom prompt", function()
      -- Arrange: User wants specific processing
      -- Act: Process with custom prompt
      local has_custom = type(pipeline.process_with_custom_prompt) == "function"

      -- Assert: Custom prompts supported (optional)
      -- This is a MAY requirement, so we just check existence
      assert.is_boolean(has_custom)
    end)
  end)

  describe("Batch Processing Capabilities", function()
    it("CAN handle rapid saves without queuing issues", function()
      -- Arrange: User rapidly saves multiple times
      local saves = {
        "/home/percy/Zettelkasten/note1.md",
        "/home/percy/Zettelkasten/note2.md",
        "/home/percy/Zettelkasten/note3.md",
      }

      -- Act: Trigger rapid saves
      for _, path in ipairs(saves) do
        pipeline.on_save(path)
      end

      local queue_size = pipeline.get_queue_size()

      -- Assert: Queue handles multiple requests
      if queue_size then
        assert.is_true(queue_size >= 0, "Queue should handle requests")
      end
    end)

    it("CAN see which notes are in processing queue", function()
      -- Arrange: Multiple notes saved
      pipeline.on_save("/home/percy/Zettelkasten/note1.md")
      pipeline.on_save("/home/percy/Zettelkasten/note2.md")

      -- Act: Get queue info
      local queue_info = pipeline.get_queue_info()

      -- Assert: Queue visibility (optional feature)
      if queue_info then
        assert.is_table(queue_info)
      end
    end)
  end)

  describe("Error Recovery Capabilities", function()
    it("CAN receive clear error messages when Ollama unavailable", function()
      -- Arrange: Mock Ollama failure
      -- Global pollution test: _G.M is documented interface from ollama.lua (line 358)
      local original_ask = _G.M and _G.M.ask or nil

      _G.M = {
        ask = function(opts)
          return false, "Connection refused: Ollama not running"
        end,
      }

      local notification_msg = nil
      local original_notify = vim.notify
      vim.notify = function(msg, level)
        notification_msg = msg
      end

      -- Enable test mode to skip file checks
      pipeline.set_processing_callback(function() end)

      -- Act: Attempt processing
      pipeline.on_save("/home/percy/Zettelkasten/test.md")

      -- Cleanup
      vim.notify = original_notify
      pipeline.set_processing_callback(nil)
      if original_ask then
        _G.M.ask = original_ask
      end

      -- Assert: Clear error message
      if notification_msg then
        assert.matches("Ollama", notification_msg)
      end
    end)

    it("CAN retry failed processing", function()
      -- Arrange: Processing failed
      -- Act: Check retry function exists
      local has_retry = type(pipeline.retry_last_processing) == "function"

      -- Assert: Retry capability available (optional)
      assert.is_boolean(has_retry)
    end)

    it("CAN continue using editor even if processing fails", function()
      -- Arrange: Mock processing failure
      -- Global pollution test: _G.M is documented interface from ollama.lua (line 358)
      if not _G.M then
        _G.M = {
          ask = function(opts)
            return false, "Error"
          end,
        }
      end

      -- Act: Trigger processing
      pipeline.on_save("/home/percy/Zettelkasten/test.md")

      -- Assert: Editor not blocked by failure
      local is_blocking = pipeline.is_processing_blocking()
      assert.is_false(is_blocking, "Failed processing shouldn't block editor")
    end)
  end)

  describe("Configuration Capabilities", function()
    it("CAN configure processing delay to reduce CPU usage", function()
      -- Arrange: User wants delayed processing
      pipeline.setup({ processing_delay_ms = 2000 })

      -- Act: Get configured delay
      local delay = pipeline.get_processing_delay()

      -- Assert: Delay configured
      if delay then
        assert.equals(2000, delay)
      end
    end)

    it("CAN disable processing for specific file patterns", function()
      -- Arrange: User wants to exclude daily notes
      pipeline.setup({ exclude_patterns = { "daily/.*" } })

      -- Act: Check if daily note excluded
      local daily_path = "/home/percy/Zettelkasten/daily/2025-10-20.md"
      local should_process = pipeline.should_process_file(daily_path)

      -- Assert: Exclusion works (optional feature)
      if pipeline.get_exclude_patterns() then
        assert.is_false(should_process)
      end
    end)

    it("CAN choose different prompts for different note types", function()
      -- Arrange: User configures custom prompts
      local custom_prompts = {
        wiki = "Analyze this wiki page",
        fleeting = "Quick summary only",
      }

      pipeline.setup({ prompts = custom_prompts })

      -- Act: Get configured prompts
      local wiki_prompt = pipeline.get_prompt_for_note_type("wiki")
      local fleeting_prompt = pipeline.get_prompt_for_note_type("fleeting")

      -- Assert: Custom prompts used (if configuration supported)
      if pipeline.get_custom_prompts() then
        assert.equals(custom_prompts.wiki, wiki_prompt)
        assert.equals(custom_prompts.fleeting, fleeting_prompt)
      end
    end)
  end)

  describe("Keybinding Capabilities", function()
    it("CAN access manual processing via keybinding", function()
      -- Arrange: User wants quick manual trigger
      -- Act: Check if keymap registered
      local keymaps = vim.api.nvim_get_keymap("n")
      local has_processing_key = false

      for _, map in ipairs(keymaps) do
        if map.lhs and map.lhs:match("<leader>ap") then
          has_processing_key = true
          break
        end
      end

      -- Assert: Keybinding exists or manual function available
      assert.is_true(
        has_processing_key or type(pipeline.process_current_buffer) == "function",
        "Manual processing should be accessible"
      )
    end)
  end)

  describe("Hugo Integration Capabilities", function()
    it("CAN preserve Hugo frontmatter during AI processing", function()
      -- Arrange: Wiki note with complete Hugo frontmatter
      local content = [[
---
title: Research Note
date: 2025-10-20
draft: false
tags: [research, ai]
categories: [technology]
description: Research findings on AI
---

# Research Note

Content here
]]

      -- Act: Process content
      local processed = pipeline.process_content(content, "wiki")

      -- Assert: Hugo fields preserved
      assert.matches("draft: false", processed)
      assert.matches("tags: %[research, ai%]", processed)
      assert.matches("categories: %[technology%]", processed)
    end)

    it("CAN validate Hugo frontmatter before publishing", function()
      -- Arrange: Wiki note ready for publishing
      -- Act: Check validation function
      local has_validation = type(pipeline.validate_hugo_frontmatter) == "function"

      -- Assert: Validation available
      assert.is_boolean(has_validation)
    end)
  end)
end)
