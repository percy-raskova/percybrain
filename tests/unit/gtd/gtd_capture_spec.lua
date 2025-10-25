--- GTD Capture Module Tests
--- Test suite for GTD quick capture and inbox management
--- @module tests.unit.gtd.gtd_capture_spec

local helpers = require("tests.helpers.gtd_test_helpers")

describe("GTD Capture Module", function()
  before_each(function()
    -- Arrange: Clean state before each test
    helpers.cleanup_gtd_test_data()
    helpers.clear_gtd_cache()

    -- Setup GTD structure for capture tests
    local gtd = require("lib.gtd")
    gtd.setup()
  end)

  after_each(function()
    -- Cleanup: Remove test data after each test
    helpers.cleanup_gtd_test_data()
    helpers.clear_gtd_cache()
  end)

  describe("Quick Capture", function()
    it("should append item to inbox with checkbox format", function()
      -- Arrange
      local capture = require("lib.gtd.capture")
      local inbox_path = helpers.gtd_path("inbox.md")
      local test_item = "Buy groceries"

      -- Act
      capture.quick_capture(test_item)

      -- Assert
      assert.is_true(helpers.file_exists(inbox_path), "Inbox file should exist")
      assert.is_true(
        helpers.file_contains_pattern(inbox_path, "%- %[ %] Buy groceries"),
        "Inbox should contain checkbox item"
      )
    end)

    it("should add timestamp to captured items", function()
      -- Arrange
      local capture = require("lib.gtd.capture")
      local inbox_path = helpers.gtd_path("inbox.md")
      local test_item = "Call dentist"

      -- Act
      capture.quick_capture(test_item)

      -- Assert
      local content = helpers.read_file_content(inbox_path)
      assert.is_not_nil(content:match("%(captured: %d%d%d%d%-%d%d%-%d%d"), "Should have timestamp pattern")
    end)

    it("should handle empty input gracefully", function()
      -- Arrange
      local capture = require("lib.gtd.capture")
      local inbox_path = helpers.gtd_path("inbox.md")
      local original_content = helpers.read_file_content(inbox_path)

      -- Act
      capture.quick_capture("")
      capture.quick_capture(nil)

      -- Assert
      local new_content = helpers.read_file_content(inbox_path)
      assert.equals(original_content, new_content, "Empty captures should not modify inbox")
    end)

    it("should append multiple captures sequentially", function()
      -- Arrange
      local capture = require("lib.gtd.capture")
      local inbox_path = helpers.gtd_path("inbox.md")

      -- Act
      capture.quick_capture("First task")
      capture.quick_capture("Second task")
      capture.quick_capture("Third task")

      -- Assert
      local content = helpers.read_file_content(inbox_path)
      assert.is_not_nil(content:match("First task"), "Should contain first task")
      assert.is_not_nil(content:match("Second task"), "Should contain second task")
      assert.is_not_nil(content:match("Third task"), "Should contain third task")
    end)
  end)

  describe("Capture Buffer", function()
    it("should create capture buffer with correct filetype", function()
      -- Arrange
      local capture = require("lib.gtd.capture")

      -- Act
      local bufnr = capture.create_capture_buffer()

      -- Assert
      assert.is_not_nil(bufnr, "Should return buffer number")
      assert.equals("markdown", vim.bo[bufnr].filetype, "Buffer should have markdown filetype")
    end)

    it("should save buffer content to inbox when committed", function()
      -- Arrange
      local capture = require("lib.gtd.capture")
      local inbox_path = helpers.gtd_path("inbox.md")
      local bufnr = capture.create_capture_buffer()

      -- Set buffer content
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
        "Meeting notes from client call",
        "Follow up on proposal",
      })

      -- Act
      capture.commit_capture_buffer(bufnr)

      -- Assert
      local content = helpers.read_file_content(inbox_path)
      assert.is_not_nil(content:match("Meeting notes from client call"), "Should contain first line")
      assert.is_not_nil(content:match("Follow up on proposal"), "Should contain second line")
    end)

    it("should delete capture buffer after commit", function()
      -- Arrange
      local capture = require("lib.gtd.capture")
      local bufnr = capture.create_capture_buffer()

      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "Test content" })

      -- Act
      capture.commit_capture_buffer(bufnr)

      -- Assert
      assert.is_false(vim.api.nvim_buf_is_valid(bufnr), "Buffer should be deleted after commit")
    end)
  end)

  describe("Timestamp Formatting", function()
    it("should generate timestamp in correct format", function()
      -- Arrange
      local capture = require("lib.gtd.capture")

      -- Act
      local timestamp = capture.get_timestamp()

      -- Assert
      assert.is_not_nil(timestamp:match("^%d%d%d%d%-%d%d%-%d%d %d%d:%d%d$"), "Should match YYYY-MM-DD HH:MM format")
    end)

    it("should format task items with timestamp", function()
      -- Arrange
      local capture = require("lib.gtd.capture")
      local test_item = "Review pull request"

      -- Act
      local formatted = capture.format_task_item(test_item)

      -- Assert
      assert.is_not_nil(formatted:match("^%- %[ %] Review pull request"), "Should start with checkbox")
      assert.is_not_nil(formatted:match("%(captured: %d%d%d%d%-%d%d%-%d%d %d%d:%d%d%)"), "Should end with timestamp")
    end)
  end)
end)
