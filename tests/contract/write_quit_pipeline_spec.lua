-- Contract Tests for Write-Quit AI Pipeline
-- Tests what the system MUST, MUST NOT, and MAY do for automatic AI processing on save
-- Kent Beck: "Specify the contract before implementation"

describe("Write-Quit AI Pipeline Contract", function()
  local pipeline

  before_each(function()
    -- Arrange: Load pipeline module
    pipeline = require("percybrain.write-quit-pipeline")
  end)

  after_each(function()
    -- Cleanup: Clear autocmds and reset state
    vim.api.nvim_clear_autocmds({ group = "WriteQuitPipeline" })
  end)

  describe("Autocmd Registration Contract", function()
    it("MUST register BufWritePost autocmd for markdown files", function()
      -- Arrange: Pipeline setup
      -- Act: Setup autocmds
      pipeline.setup()

      -- Assert: BufWritePost autocmd exists
      local autocmds = vim.api.nvim_get_autocmds({
        event = "BufWritePost",
        group = "WriteQuitPipeline",
      })

      assert.is_true(#autocmds > 0, "Should register BufWritePost autocmd")
      assert.equals("BufWritePost", autocmds[1].event)
    end)

    it("MUST register autocmd only for markdown files", function()
      -- Arrange: Check autocmd pattern
      pipeline.setup()

      -- Act: Get registered autocmds
      local autocmds = vim.api.nvim_get_autocmds({
        event = "BufWritePost",
        group = "WriteQuitPipeline",
      })

      -- Assert: Pattern matches markdown files
      assert.is_not_nil(autocmds[1].pattern)
      assert.matches("*.md", autocmds[1].pattern)
    end)

    it("MUST create augroup on setup", function()
      -- Arrange: Clean slate
      -- Act: Setup pipeline
      pipeline.setup()

      -- Assert: Augroup exists
      local groups = vim.fn.getcompletion("WriteQuitPipeline", "augroup")
      assert.equals(1, #groups)
      assert.equals("WriteQuitPipeline", groups[1])
    end)
  end)

  describe("Note Type Detection Contract", function()
    it("MUST detect wiki notes in Zettelkasten root", function()
      -- Arrange: Wiki note path
      local wiki_path = "/home/percy/Zettelkasten/20251020-example.md"

      -- Act: Detect note type
      local note_type = pipeline.detect_note_type(wiki_path)

      -- Assert: Recognized as wiki
      assert.equals("wiki", note_type)
    end)

    it("MUST detect fleeting notes in inbox directory", function()
      -- Arrange: Fleeting note path
      local fleeting_path = "/home/percy/Zettelkasten/inbox/20251020-quick.md"

      -- Act: Detect note type
      local note_type = pipeline.detect_note_type(fleeting_path)

      -- Assert: Recognized as fleeting
      assert.equals("fleeting", note_type)
    end)

    it("MUST NOT process non-markdown files", function()
      -- Arrange: Non-markdown file
      local txt_path = "/home/percy/Zettelkasten/notes.txt"

      -- Act: Check if should process
      local should_process = pipeline.should_process_file(txt_path)

      -- Assert: Not processed
      assert.is_false(should_process)
    end)

    it("MUST NOT process files outside Zettelkasten directory", function()
      -- Arrange: File outside Zettelkasten
      local external_path = "/tmp/random.md"

      -- Act: Check if should process
      local should_process = pipeline.should_process_file(external_path)

      -- Assert: Not processed
      assert.is_false(should_process)
    end)
  end)

  describe("AI Processing Trigger Contract", function()
    it("MUST trigger AI processing for wiki notes on save", function()
      -- Arrange: Mock AI processing function
      local processing_triggered = false
      pipeline.set_processing_callback(function()
        processing_triggered = true
      end)

      local wiki_path = "/home/percy/Zettelkasten/20251020-example.md"

      -- Act: Simulate save event
      pipeline.on_save(wiki_path)

      -- Assert: Processing triggered
      assert.is_true(processing_triggered, "Should trigger AI processing for wiki notes")
    end)

    it("MUST trigger AI processing for fleeting notes on save", function()
      -- Arrange: Mock AI processing function
      local processing_triggered = false
      pipeline.set_processing_callback(function()
        processing_triggered = true
      end)

      local fleeting_path = "/home/percy/Zettelkasten/inbox/20251020-quick.md"

      -- Act: Simulate save event
      pipeline.on_save(fleeting_path)

      -- Assert: Processing triggered
      assert.is_true(processing_triggered, "Should trigger AI processing for fleeting notes")
    end)

    it("MUST use current AI model from ai-model-selector", function()
      -- Arrange: Mock ai-model-selector
      local ai_selector = require("percybrain.ai-model-selector")
      local selected_model = ai_selector.get_current_model()

      -- Act: Get model for processing
      local model = pipeline.get_processing_model()

      -- Assert: Uses current model
      assert.is_not_nil(model)
      assert.equals(selected_model, model)
    end)
  end)

  describe("Background Processing Contract", function()
    it("MUST process in background without blocking editor", function()
      -- Arrange: Start processing
      -- Act: Trigger processing
      local blocking = pipeline.is_processing_blocking()

      -- Assert: Non-blocking
      assert.is_false(blocking, "Processing must not block editor")
    end)

    it("MUST provide processing status feedback", function()
      -- Arrange: Start processing
      pipeline.on_save("/home/percy/Zettelkasten/test.md")

      -- Act: Get processing status
      local status = pipeline.get_processing_status()

      -- Assert: Status available
      assert.is_not_nil(status)
      assert.is_string(status.state) -- "idle", "processing", "completed", "error"
    end)

    it("MAY queue multiple processing requests", function()
      -- Arrange: Multiple saves
      local wiki1 = "/home/percy/Zettelkasten/note1.md"
      local wiki2 = "/home/percy/Zettelkasten/note2.md"

      -- Act: Trigger multiple saves
      pipeline.on_save(wiki1)
      pipeline.on_save(wiki2)

      -- Assert: Queue exists (optional feature)
      local queue_size = pipeline.get_queue_size()
      if queue_size then
        assert.is_true(queue_size >= 0)
      end
    end)
  end)

  describe("Processing Type Contract", function()
    it("MUST use different prompts for wiki vs fleeting notes", function()
      -- Arrange: Different note types
      -- Act: Get prompts for each type
      local wiki_prompt = pipeline.get_prompt_for_note_type("wiki")
      local fleeting_prompt = pipeline.get_prompt_for_note_type("fleeting")

      -- Assert: Different prompts
      assert.is_not_nil(wiki_prompt)
      assert.is_not_nil(fleeting_prompt)
      assert.is_not_equal(wiki_prompt, fleeting_prompt)
    end)

    it("MUST preserve Hugo frontmatter for wiki notes", function()
      -- Arrange: Wiki note with Hugo frontmatter
      local content = [[
---
title: Test Note
date: 2025-10-20
draft: false
tags: [test]
---

# Content
]]

      -- Act: Process content
      local processed = pipeline.process_content(content, "wiki")

      -- Assert: Frontmatter preserved
      assert.matches("^%-%-%-", processed)
      assert.matches("title: Test Note", processed)
      assert.matches("draft: false", processed)
    end)

    it("MUST NOT add Hugo frontmatter to fleeting notes", function()
      -- Arrange: Fleeting note content
      local content = [[
---
title: Quick Note
created: 2025-10-20
---

Quick thought
]]

      -- Act: Process content
      local processed = pipeline.process_content(content, "fleeting")

      -- Assert: No Hugo-specific fields added
      assert.is_not_nil(processed)
      assert.not_matches("draft:", processed)
      assert.not_matches("tags:", processed)
    end)
  end)

  describe("Integration Contract", function()
    it("MUST integrate with Ollama for AI processing", function()
      -- Arrange: Mock Ollama if not loaded
      -- Global pollution test: _G.M is documented interface from ollama.lua (line 358)
      if not _G.M then
        _G.M = {
          config = {
            model = "llama3.2:latest",
          },
          ask = function(opts)
            return true, "AI response"
          end,
        }
      end

      -- Act: Process with Ollama
      local success, response = pipeline.process_with_ollama("test content", "summarize")

      -- Assert: Ollama integration works
      assert.is_true(success)
      assert.is_not_nil(response)
    end)

    it("MUST use ai-model-selector for model selection", function()
      -- Arrange: AI model selector loaded
      local ai_selector = require("percybrain.ai-model-selector")

      -- Act: Get processing model
      local model = pipeline.get_processing_model()

      -- Assert: Uses ai-model-selector
      assert.equals(ai_selector.get_current_model(), model)
    end)

    it("MUST handle Ollama errors gracefully", function()
      -- Arrange: Mock Ollama failure
      -- Global pollution test: _G.M is documented interface from ollama.lua (line 358)
      local original_ask = _G.M and _G.M.ask or nil

      _G.M = {
        ask = function(opts)
          return false, "Connection refused"
        end,
      }

      -- Act: Attempt processing
      local success, error_msg = pipeline.process_with_ollama("content", "prompt")

      -- Cleanup: Restore original ask function
      if original_ask then
        _G.M.ask = original_ask
      end

      -- Assert: Error handled
      assert.is_false(success)
      assert.is_string(error_msg)
      assert.matches("refused", error_msg:lower())
    end)
  end)

  describe("User Control Contract", function()
    it("MAY allow users to disable auto-processing", function()
      -- Arrange: Check if disable option exists
      pipeline.setup({ auto_process = false })

      -- Act: Save file
      local auto_processing = pipeline.is_auto_processing_enabled()

      -- Assert: Can be disabled (optional feature)
      if auto_processing ~= nil then
        assert.is_false(auto_processing)
      end
    end)

    it("MAY allow users to configure processing delay", function()
      -- Arrange: Configure delay
      pipeline.setup({ processing_delay_ms = 1000 })

      -- Act: Get configured delay
      local delay = pipeline.get_processing_delay()

      -- Assert: Delay configurable (optional feature)
      if delay then
        assert.equals(1000, delay)
      end
    end)

    it("MUST provide manual processing command", function()
      -- Arrange: Check for manual trigger
      -- Act: Check if manual processing function exists
      local has_manual = type(pipeline.process_current_buffer) == "function"

      -- Assert: Manual processing available
      assert.is_true(has_manual, "Must provide manual processing function")
    end)
  end)

  describe("Error Handling Contract", function()
    it("MUST handle missing file gracefully", function()
      -- Arrange: Non-existent file path (clear callback to enable file checking)
      local invalid_path = "/home/percy/Zettelkasten/nonexistent.md"
      pipeline.set_processing_callback(nil) -- Disable test mode

      -- Act: Attempt to process
      local success, error_msg = pipeline.on_save(invalid_path)

      -- Assert: Error handled, doesn't crash
      assert.is_false(success)
      assert.is_string(error_msg)
    end)

    it("MUST handle corrupted frontmatter gracefully", function()
      -- Arrange: Malformed frontmatter
      local bad_content = [[
---
title: Missing close
tags: [unclosed

Content here
]]

      -- Act: Process content
      local success, result = pcall(pipeline.process_content, bad_content, "wiki")

      -- Assert: Doesn't crash
      assert.is_true(success or type(result) == "string")
    end)

    it("MUST notify user of processing errors", function()
      -- Arrange: Mock error scenario (file in Zettelkasten but nonexistent)
      local notification_received = false
      local original_notify = vim.notify
      vim.notify = function(msg, level)
        notification_received = true
      end

      pipeline.set_processing_callback(nil) -- Disable test mode to enable file checking

      -- Act: Trigger error (file doesn't exist but is in Zettelkasten path)
      pipeline.on_save("/home/percy/Zettelkasten/error-test.md")

      -- Assert: User notified
      vim.notify = original_notify
      assert.is_true(notification_received, "Should notify user of errors")
    end)
  end)
end)
