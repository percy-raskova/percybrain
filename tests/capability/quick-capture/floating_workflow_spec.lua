-- Capability Tests for Floating Quick Capture Workflow
-- These tests verify that users CAN DO the quick capture workflow
-- Kent Beck: "Test what the user can accomplish, not how it works internally"

local helpers = require("tests.helpers.test_framework")

describe("Floating Quick Capture Workflow Capabilities", function()
  local state_manager
  local capture
  local test_inbox_dir = "/tmp/test-zettelkasten-inbox"

  before_each(function()
    -- Arrange: Set up isolated test environment
    state_manager = helpers.StateManager:new()
    state_manager:save()

    -- Create test inbox directory
    vim.fn.mkdir(test_inbox_dir, "p")

    -- Load module with test configuration
    capture = require("percybrain.floating-quick-capture")
    capture.setup({
      inbox_dir = test_inbox_dir,
      auto_notify = false, -- Disable notifications in tests
    })
  end)

  after_each(function()
    -- Cleanup: Restore state and remove test directory
    state_manager:restore()
    vim.fn.delete(test_inbox_dir, "rf")

    -- Reset module state
    if capture and capture.reset_state then
      capture.reset_state()
    end
  end)

  describe("Minimal Friction Capture", function()
    it("CAN open quick capture with single keybinding", function()
      -- Arrange: User is editing a file
      local original_buffer = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_current_buf(original_buffer)

      -- Act: User presses quick capture keybinding
      capture.open_capture_window()

      -- Assert: Floating window appears, user can start typing immediately
      local current_buffer = vim.api.nvim_get_current_buf()
      assert.not_equals(original_buffer, current_buffer, "User should be in capture buffer")

      local buffer_type = vim.api.nvim_buf_get_option(current_buffer, "buftype")
      assert.equals("nofile", buffer_type, "Capture buffer should be ready for input")
    end)

    it("CAN capture thought without leaving current file", function()
      -- Arrange: User is editing important file
      local important_file_buffer = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_current_buf(important_file_buffer)
      vim.api.nvim_buf_set_lines(important_file_buffer, 0, -1, false, { "Important work in progress" })

      -- Act: User opens capture, types thought, saves
      capture.open_capture_window()
      local capture_buffer = vim.api.nvim_get_current_buf()
      vim.api.nvim_buf_set_lines(capture_buffer, 0, -1, false, { "Quick fleeting thought" })

      -- Simulate save action
      local _ = capture.get_save_path() -- Intentionally unused: just verify function exists
      capture.save_and_close()

      -- Assert: User returns to original file
      local current_buffer = vim.api.nvim_get_current_buf()
      assert.equals(important_file_buffer, current_buffer, "User should return to original buffer after capture")

      -- Original file content preserved
      local lines = vim.api.nvim_buf_get_lines(important_file_buffer, 0, -1, false)
      assert.equals("Important work in progress", lines[1], "Original content should be preserved")
    end)

    it("CAN save fleeting thought with zero manual steps", function()
      -- Arrange: User has a thought to capture
      local thought_content = "Random idea about project architecture"

      -- Act: User opens capture, types, presses save keybinding
      capture.open_capture_window()
      local capture_buffer = vim.api.nvim_get_current_buf()
      vim.api.nvim_buf_set_lines(capture_buffer, 0, -1, false, { thought_content })

      local save_path = capture.get_save_path()
      capture.save_and_close()

      -- Wait for async save to complete
      vim.wait(500)

      -- Assert: File exists in inbox with correct content
      assert.equals(1, vim.fn.filereadable(save_path), "Fleeting note file should exist")

      local file_content = vim.fn.readfile(save_path)
      local content_string = table.concat(file_content, "\n")
      assert.is_truthy(content_string:match(thought_content), "File should contain the thought")
    end)
  end)

  describe("Automatic File Management", function()
    it("CAN capture multiple thoughts without filename conflicts", function()
      -- Arrange: User has several quick thoughts in succession
      local thoughts = {
        "First thought",
        "Second thought",
        "Third thought",
      }
      local saved_files = {}

      -- Act: User captures each thought
      for _, thought in ipairs(thoughts) do
        capture.open_capture_window()
        local capture_buffer = vim.api.nvim_get_current_buf()
        vim.api.nvim_buf_set_lines(capture_buffer, 0, -1, false, { thought })

        local save_path = capture.get_save_path()
        table.insert(saved_files, save_path)

        capture.save_and_close()
        vim.wait(1100) -- Ensure unique timestamps (1 second resolution)
      end

      -- Assert: All files created with unique names
      assert.equals(3, #saved_files, "Should have 3 saved files")
      assert.not_equals(saved_files[1], saved_files[2], "Files should have unique names")
      assert.not_equals(saved_files[2], saved_files[3], "Files should have unique names")
    end)

    it("CAN see automatic timestamp-based filename", function()
      -- Arrange: User captures a thought at known time
      local capture_time = os.date("%Y%m%d")

      -- Act: User opens capture and saves
      capture.open_capture_window()
      local save_path = capture.get_save_path()
      capture.save_and_close()

      -- Assert: Filename contains timestamp
      local filename = vim.fn.fnamemodify(save_path, ":t")
      assert.is_truthy(filename:match("^" .. capture_time), "Filename should start with today's date")
      assert.is_truthy(filename:match("%.md$"), "Filename should have .md extension")
    end)

    it("CAN capture to inbox directory automatically", function()
      -- Arrange: User doesn't specify save location

      -- Act: User opens capture and saves
      capture.open_capture_window()
      local capture_buffer = vim.api.nvim_get_current_buf()
      vim.api.nvim_buf_set_lines(capture_buffer, 0, -1, false, { "Auto-saved thought" })

      local save_path = capture.get_save_path()
      capture.save_and_close()

      vim.wait(500)

      -- Assert: File saved to inbox directory
      assert.is_truthy(save_path:match("test%-zettelkasten%-inbox"), "File should be in inbox directory")
      assert.equals(1, vim.fn.filereadable(save_path), "File should exist in inbox")
    end)
  end)

  describe("Frontmatter Handling", function()
    it("CAN see simple frontmatter added automatically", function()
      -- Arrange: User types plain content
      local plain_content = "This is just a thought"

      -- Act: User captures with plain text
      capture.open_capture_window()
      local capture_buffer = vim.api.nvim_get_current_buf()
      vim.api.nvim_buf_set_lines(capture_buffer, 0, -1, false, { plain_content })

      local save_path = capture.get_save_path()
      capture.save_and_close()

      vim.wait(500)

      -- Assert: Saved file has frontmatter
      local file_content = vim.fn.readfile(save_path)
      local content_string = table.concat(file_content, "\n")

      assert.is_truthy(content_string:match("^%-%-%-"), "File should start with frontmatter")
      assert.is_truthy(content_string:match("title:"), "Frontmatter should have title")
      assert.is_truthy(content_string:match("created:"), "Frontmatter should have timestamp")
    end)

    it("CAN capture fleeting notes without Hugo publishing fields", function()
      -- Arrange: User captures quick thought (not for publishing)
      local thought = "Not ready for publication"

      -- Act: User captures thought
      capture.open_capture_window()
      local capture_buffer = vim.api.nvim_get_current_buf()
      vim.api.nvim_buf_set_lines(capture_buffer, 0, -1, false, { thought })

      local save_path = capture.get_save_path()
      capture.save_and_close()

      vim.wait(500)

      -- Assert: File has NO Hugo fields (draft, tags, categories)
      local file_content = vim.fn.readfile(save_path)
      local content_string = table.concat(file_content, "\n")

      assert.is_falsy(content_string:match("draft:"), "Fleeting notes should not have draft field")
      assert.is_falsy(content_string:match("tags:"), "Fleeting notes should not have tags field")
      assert.is_falsy(content_string:match("categories:"), "Fleeting notes should not have categories field")
    end)
  end)

  describe("User Experience", function()
    it("CAN use centered floating window with minimal distractions", function()
      -- Arrange: User wants focused capture experience

      -- Act: User opens capture window
      capture.open_capture_window()

      -- Assert: Window is centered and properly sized
      local win_config = capture.get_window_config()
      assert.equals("editor", win_config.relative, "Window should be centered in editor")
      assert.is_true(win_config.width >= 50, "Window should be wide enough for comfortable writing")
      assert.is_true(win_config.height >= 5, "Window should have enough height")
      assert.is_not_nil(win_config.border, "Window should have a border")
    end)

    it("CAN close capture window with Escape key", function()
      -- Arrange: User opens capture but decides not to save

      -- Act: User opens window, then presses Escape
      capture.open_capture_window()
      local _buf = vim.api.nvim_get_current_buf() -- Intentionally unused: just verify window opens

      -- Get buffer keymaps to verify Escape is mapped
      local buffer_keymaps = capture.get_buffer_keymaps()

      -- Assert: Escape keybinding exists for closing
      assert.is_not_nil(buffer_keymaps.cancel, "Cancel keybinding should exist")
    end)

    it("CAN receive visual feedback on successful save", function()
      -- Arrange: User captures a thought
      local notification_received = false
      capture.setup({
        inbox_dir = test_inbox_dir,
        on_save_success = function()
          notification_received = true
        end,
      })

      -- Act: User saves capture
      capture.open_capture_window()
      local capture_buffer = vim.api.nvim_get_current_buf()
      vim.api.nvim_buf_set_lines(capture_buffer, 0, -1, false, { "Test thought" })

      capture.save_and_close()
      vim.wait(500)

      -- Assert: User receives success notification
      assert.is_true(notification_received, "User should receive save confirmation")
    end)
  end)

  describe("Error Handling", function()
    it("CAN recover from save errors without losing content", function()
      -- Arrange: User captures thought, but save fails (invalid path)
      local content_preserved = false
      capture.setup({
        inbox_dir = "/invalid/path/that/does/not/exist",
        on_save_error = function(error_msg, preserved_content)
          content_preserved = preserved_content ~= nil and #preserved_content > 0
        end,
      })

      -- Act: User tries to save to invalid location
      capture.open_capture_window()
      local capture_buffer = vim.api.nvim_get_current_buf()
      vim.api.nvim_buf_set_lines(capture_buffer, 0, -1, false, { "Important thought" })

      capture.save_and_close()
      vim.wait(500)

      -- Assert: Content is preserved for recovery
      assert.is_true(content_preserved, "Content should be preserved on error")
    end)

    it("CAN see helpful error message when inbox directory missing", function()
      -- Arrange: User has misconfigured inbox path
      local error_message = nil
      capture.setup({
        inbox_dir = "/nonexistent/inbox",
        on_save_error = function(error_msg)
          error_message = error_msg
        end,
      })

      -- Act: User tries to capture
      capture.open_capture_window()
      local _buf = vim.api.nvim_get_current_buf() -- Intentionally unused: just verify window opens
      vim.api.nvim_buf_set_lines(_buf, 0, -1, false, { "Test" })

      capture.save_and_close()
      vim.wait(500)

      -- Assert: Error message is helpful
      assert.is_not_nil(error_message, "Error message should be provided")
      assert.is_truthy(
        error_message:match("inbox") or error_message:match("directory"),
        "Error should mention inbox/directory"
      )
    end)
  end)

  describe("Integration", function()
    it("CAN use custom keybinding for quick capture", function()
      -- Arrange: User configures custom keybinding
      local custom_key = "<leader>qc"
      capture.setup({
        inbox_dir = test_inbox_dir,
        keybinding = custom_key,
      })

      -- Act: Get configured keybinding
      local configured_key = capture.get_default_keybinding()

      -- Assert: Custom keybinding is respected
      assert.equals(custom_key, configured_key, "Custom keybinding should be used")
    end)

    it("CAN capture while other buffers remain unaffected", function()
      -- Arrange: User has multiple buffers open
      local buffer1 = vim.api.nvim_create_buf(false, true)
      local buffer2 = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(buffer1, 0, -1, false, { "Buffer 1 content" })
      vim.api.nvim_buf_set_lines(buffer2, 0, -1, false, { "Buffer 2 content" })

      vim.api.nvim_set_current_buf(buffer1)

      -- Act: User opens capture, saves, returns
      capture.open_capture_window()
      local capture_buffer = vim.api.nvim_get_current_buf()
      vim.api.nvim_buf_set_lines(capture_buffer, 0, -1, false, { "Quick note" })
      capture.save_and_close()

      -- Assert: Other buffers unchanged
      local buffer1_lines = vim.api.nvim_buf_get_lines(buffer1, 0, -1, false)
      local buffer2_lines = vim.api.nvim_buf_get_lines(buffer2, 0, -1, false)

      assert.equals("Buffer 1 content", buffer1_lines[1], "Buffer 1 should be unchanged")
      assert.equals("Buffer 2 content", buffer2_lines[1], "Buffer 2 should be unchanged")
    end)
  end)

  describe("Performance and Responsiveness", function()
    it("CAN open capture window instantly (< 100ms)", function()
      -- Arrange: User expects immediate response

      -- Act: Measure window open time
      local start_time = vim.loop.hrtime()
      capture.open_capture_window()
      local elapsed_ms = (vim.loop.hrtime() - start_time) / 1000000

      -- Assert: Window opens quickly
      assert.is_true(elapsed_ms < 100, string.format("Window should open in < 100ms (took %.2fms)", elapsed_ms))
    end)

    it("CAN save asynchronously without blocking editor", function()
      -- Arrange: User captures thought while editor is busy

      -- Act: Trigger save and immediately check if editor is responsive
      capture.open_capture_window()
      local capture_buffer = vim.api.nvim_get_current_buf()
      vim.api.nvim_buf_set_lines(capture_buffer, 0, -1, false, { "Async test" })

      local save_started = capture.save_and_close()

      -- Assert: Save returns immediately (async)
      assert.is_not_nil(save_started, "Save should initiate immediately")
    end)
  end)
end)
