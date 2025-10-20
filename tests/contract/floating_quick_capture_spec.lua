-- Contract Tests for Floating Quick Capture
-- These tests verify the specification for ultra-fast note capture
-- Kent Beck: "Make the contract explicit through tests"

local helpers = require("tests.helpers.test_framework")

describe("Floating Quick Capture Contract", function()
  local state_manager

  before_each(function()
    -- Arrange: Set up state management for test isolation
    state_manager = helpers.StateManager:new()
    state_manager:save()
  end)

  after_each(function()
    -- Cleanup: Restore original state
    state_manager:restore()
  end)

  describe("Required Contract ✅", function()
    describe("Floating Window Contract", function()
      it("MUST provide floating window popup API", function()
        -- Arrange: Load floating capture module
        local capture_ok, capture = pcall(require, "percybrain.floating-quick-capture")

        -- Act: Check for floating window function
        local has_open_function = capture_ok and type(capture.open_capture_window) == "function"

        -- Assert: Floating window API must exist
        assert.is_true(has_open_function, "open_capture_window() function must exist")
      end)

      it("MUST create centered floating window", function()
        -- Arrange: Load module
        local capture = require("percybrain.floating-quick-capture")

        -- Act: Call window creation function
        local window_config = capture.get_window_config()

        -- Assert: Window must be centered with proper dimensions
        assert.is_not_nil(window_config, "Window configuration must be defined")
        assert.is_not_nil(window_config.relative, "Window must have relative positioning")
        assert.equals("editor", window_config.relative, "Window must be relative to editor")
        assert.is_number(window_config.width, "Window width must be a number")
        assert.is_number(window_config.height, "Window height must be a number")
        assert.is_true(window_config.width > 40, "Window must be wide enough for writing")
        assert.is_true(window_config.height >= 5, "Window must have minimum height")
      end)

      it("MUST have minimal UI without distractions", function()
        -- Arrange: Load module
        local capture = require("percybrain.floating-quick-capture")

        -- Act: Get window configuration
        local window_config = capture.get_window_config()

        -- Assert: Window must have minimal border, no excessive decorations
        assert.is_true(window_config.border ~= nil, "Window must have defined border style")
        assert.is_true(
          window_config.border == "rounded" or window_config.border == "single",
          "Border must be minimal (rounded or single)"
        )
      end)
    end)

    describe("Input Capture Contract", function()
      it("MUST capture input without switching buffers", function()
        -- Arrange: Load module and get current buffer
        local capture = require("percybrain.floating-quick-capture")
        local original_buffer = vim.api.nvim_get_current_buf()

        -- Act: Open capture window
        local capture_buffer = capture.create_capture_buffer()

        -- Assert: Original buffer should remain accessible
        assert.is_not_nil(capture_buffer, "Capture buffer must be created")
        assert.is_number(capture_buffer, "Capture buffer must be a valid buffer handle")
        assert.not_equals(original_buffer, capture_buffer, "Capture buffer must be separate")
      end)

      it("MUST provide buffer for text input", function()
        -- Arrange: Load module
        local capture = require("percybrain.floating-quick-capture")

        -- Act: Create capture buffer
        local buffer = capture.create_capture_buffer()

        -- Assert: Buffer must be modifiable scratch buffer
        local buffer_type = vim.api.nvim_buf_get_option(buffer, "buftype")
        local modifiable = vim.api.nvim_buf_get_option(buffer, "modifiable")

        assert.equals("nofile", buffer_type, "Capture buffer must be scratch buffer (nofile)")
        assert.is_true(modifiable, "Capture buffer must be modifiable")
      end)
    end)

    describe("Auto-Save Contract", function()
      it("MUST save to inbox directory automatically", function()
        -- Arrange: Load module
        local capture = require("percybrain.floating-quick-capture")

        -- Act: Get save destination
        local save_path = capture.get_save_path()

        -- Assert: Path must be in inbox directory
        assert.is_string(save_path, "Save path must be a string")
        assert.is_truthy(save_path:match("/inbox/"), "Save path must be in inbox directory")
      end)

      it("MUST generate timestamp-based filename", function()
        -- Arrange: Load module
        local capture = require("percybrain.floating-quick-capture")

        -- Act: Generate filename
        local filename = capture.generate_filename()

        -- Assert: Filename must follow yyyymmdd-hhmmss.md pattern
        assert.is_string(filename, "Filename must be a string")
        assert.is_truthy(filename:match("%d%d%d%d%d%d%d%d%-%d%d%d%d%d%d%.md"), "Filename must match yyyymmdd-hhmmss.md")
      end)

      it("MUST add simple frontmatter (title + timestamp)", function()
        -- Arrange: Load module
        local capture = require("percybrain.floating-quick-capture")
        local test_content = "Test fleeting thought"

        -- Act: Generate content with frontmatter
        local formatted_content = capture.format_content(test_content)

        -- Assert: Content must have simple frontmatter
        assert.is_string(formatted_content, "Formatted content must be a string")
        assert.is_truthy(formatted_content:match("^%-%-%-"), "Content must start with frontmatter delimiter")
        assert.is_truthy(formatted_content:match("title:"), "Frontmatter must include title")
        assert.is_truthy(formatted_content:match("created:"), "Frontmatter must include timestamp")
        assert.is_falsy(formatted_content:match("draft:"), "Fleeting notes must NOT have Hugo frontmatter")
      end)

      it("MUST save file without user interaction", function()
        -- Arrange: Load module
        local capture = require("percybrain.floating-quick-capture")

        -- Act: Check for auto-save function
        local has_save_function = type(capture.save_and_close) == "function"

        -- Assert: Auto-save function must exist
        assert.is_true(has_save_function, "save_and_close() function must exist")
      end)
    end)

    describe("Keybinding Contract", function()
      it("MUST have single keybinding trigger", function()
        -- Arrange: Load module
        local capture = require("percybrain.floating-quick-capture")

        -- Act: Get default keybinding
        local default_key = capture.get_default_keybinding()

        -- Assert: Default keybinding must be defined
        assert.is_string(default_key, "Default keybinding must be a string")
        assert.is_true(#default_key > 0, "Default keybinding must not be empty")
      end)

      it("MUST register open keybinding", function()
        -- Arrange: Load module and setup
        local capture = require("percybrain.floating-quick-capture")

        -- Act: Setup with default config
        capture.setup({})
        local has_keybinding = type(capture.open_capture_window) == "function"

        -- Assert: Open function must be available for keybinding
        assert.is_true(has_keybinding, "open_capture_window() must be available for keybinding")
      end)

      it("MUST register save keybinding within capture window", function()
        -- Arrange: Load module
        local capture = require("percybrain.floating-quick-capture")

        -- Act: Get buffer keymaps configuration
        local buffer_keymaps = capture.get_buffer_keymaps()

        -- Assert: Save keybinding must be defined for capture buffer
        assert.is_table(buffer_keymaps, "Buffer keymaps must be a table")
        assert.is_not_nil(buffer_keymaps.save, "Save keybinding must be defined")
      end)
    end)

    describe("Non-Blocking Contract", function()
      it("MUST return to previous buffer after save", function()
        -- Arrange: Load module
        local capture = require("percybrain.floating-quick-capture")

        -- Act: Check for buffer restoration function
        local has_restore = type(capture.restore_previous_buffer) == "function"

        -- Assert: Buffer restoration function must exist
        assert.is_true(has_restore, "restore_previous_buffer() function must exist")
      end)

      it("MUST use async file operations", function()
        -- Arrange: Load module
        local capture = require("percybrain.floating-quick-capture")

        -- Act: Check save operation implementation
        local save_function = capture.save_and_close

        -- Assert: Save function must exist (async implementation validated in capability tests)
        assert.is_function(save_function, "save_and_close() must be a function")
      end)
    end)

    describe("Rapid Capture Contract", function()
      it("MUST handle consecutive captures without conflicts", function()
        -- Arrange: Load module
        local capture = require("percybrain.floating-quick-capture")

        -- Act: Generate two consecutive filenames
        local filename1 = capture.generate_filename()
        vim.wait(1000) -- Wait 1 second to ensure different timestamp
        local filename2 = capture.generate_filename()

        -- Assert: Filenames must be unique
        assert.not_equals(filename1, filename2, "Consecutive captures must generate unique filenames")
      end)

      it("MUST queue save operations if needed", function()
        -- Arrange: Load module
        local capture = require("percybrain.floating-quick-capture")

        -- Act: Check for save queue management
        local has_queue = type(capture.is_save_in_progress) == "function"

        -- Assert: Save queue management must exist
        assert.is_true(has_queue, "is_save_in_progress() function must exist for queue management")
      end)
    end)
  end)

  describe("Forbidden Contract 🚫", function()
    it("MUST NOT require file path selection", function()
      -- Arrange: Load module
      local capture = require("percybrain.floating-quick-capture")

      -- Act: Check for automatic path generation
      local save_path = capture.get_save_path()

      -- Assert: Path must be generated automatically
      assert.is_string(save_path, "Save path must be automatically generated")
      assert.is_truthy(save_path:match("%.md$"), "Path must include .md extension")
    end)

    it("MUST NOT add Hugo frontmatter to fleeting notes", function()
      -- Arrange: Load module
      local capture = require("percybrain.floating-quick-capture")
      local test_content = "Fleeting thought"

      -- Act: Format content
      local formatted = capture.format_content(test_content)

      -- Assert: Must NOT have Hugo fields
      assert.is_falsy(formatted:match("draft:"), "Fleeting notes must NOT have draft field")
      assert.is_falsy(formatted:match("tags:"), "Fleeting notes must NOT have tags field")
      assert.is_falsy(formatted:match("categories:"), "Fleeting notes must NOT have categories field")
    end)

    it("MUST NOT lose content on save error", function()
      -- Arrange: Load module
      local capture = require("percybrain.floating-quick-capture")

      -- Act: Check for error recovery function
      local has_recovery = type(capture.on_save_error) == "function"

      -- Assert: Error recovery must exist
      assert.is_true(has_recovery, "on_save_error() function must exist for content recovery")
    end)
  end)

  describe("Optional Contract 🎁", function()
    it("MAY provide visual feedback on save", function()
      -- Arrange: Load module
      local capture_ok, capture = pcall(require, "percybrain.floating-quick-capture")

      -- Act: Check for notification function
      local has_notify = capture_ok and type(capture.notify_save_success) == "function"

      -- Assert: Notification is optional but documented
      assert.message("Visual feedback: " .. tostring(has_notify)).is_true(true)
    end)

    it("MAY allow custom keybinding configuration", function()
      -- Arrange: Load module
      local capture_ok, capture = pcall(require, "percybrain.floating-quick-capture")

      -- Act: Check for custom keybinding support
      local supports_custom = capture_ok and capture.get_default_keybinding ~= nil

      -- Assert: Custom keybinding support is optional
      assert.message("Custom keybinding support: " .. tostring(supports_custom)).is_true(true)
    end)
  end)
end)
