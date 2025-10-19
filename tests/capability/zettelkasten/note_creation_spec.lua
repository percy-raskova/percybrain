-- Capability Tests: Zettelkasten Note Creation
-- Tests what users CAN DO, not how it's configured
-- Kent Beck: "Test behavior, not implementation"

local helpers = require("tests.helpers.test_framework")

describe("Zettelkasten Note Creation Capabilities", function()
  local state_manager
  local test_dir = "/tmp/test_zettelkasten"

  before_each(function()
    -- Arrange: Set up test environment
    state_manager = helpers.StateManager:new()
    state_manager:save()

    -- Create test directory
    vim.fn.mkdir(test_dir, "p")
    vim.g.percybrain_zettelkasten_dir = test_dir
  end)

  after_each(function()
    -- Cleanup: Restore state and remove test files
    state_manager:restore()
    vim.fn.delete(test_dir, "rf")
  end)

  describe("User CAN create notes", function()
    it("CAN create a new timestamped note", function()
      -- Arrange: Load Zettelkasten module
      local zk = require("config.zettelkasten")

      -- Act: User creates a new note
      local note_created = false
      local note_path = nil

      helpers.assert_can("create timestamped note", function()
        note_path = zk.new_note("Test Note Title")
        note_created = vim.fn.filereadable(note_path) == 1
        return note_created
      end, "User should be able to create timestamped notes")

      -- Assert: Note should exist with correct format
      assert.is_true(note_created)
      assert.is_not_nil(note_path)
      assert.matches("%d%d%d%d%d%d%d%d%d%d%d%d%d%d%.md$", note_path, "Note should have timestamp format")
    end)

    it("CAN add content to a new note", function()
      -- Arrange: Create a note
      local zk = require("config.zettelkasten")
      local note_path = zk.new_note("Content Test")

      -- Act: User adds content
      local content = "# Content Test\n\nThis is my note content."
      helpers.assert_can("add content to note", function()
        local file = io.open(note_path, "w")
        if not file then
          return false
        end
        file:write(content)
        file:close()
        return true
      end, "User should be able to add content to notes")

      -- Assert: Content should be saved
      local file = io.open(note_path, "r")
      local saved_content = file:read("*all")
      file:close()
      assert.equals(content, saved_content)
    end)

    it("CAN create daily notes", function()
      -- Arrange: Load Zettelkasten module
      local zk = require("config.zettelkasten")

      -- Act: User creates a daily note
      local daily_note = nil
      helpers.assert_can("create daily note", function()
        daily_note = zk.daily_note()
        return daily_note ~= nil and vim.fn.filereadable(daily_note) == 1
      end, "User should be able to create daily notes")

      -- Assert: Daily note should have date format
      assert.is_not_nil(daily_note)
      assert.matches("daily/", daily_note, "Daily notes should be in daily/ directory")
      assert.matches("%d%d%d%d%-%d%d%-%d%d%.md$", daily_note, "Daily note should have YYYY-MM-DD format")
    end)

    it("CAN capture quick notes to inbox", function()
      -- Arrange: Set up inbox
      local zk = require("config.zettelkasten")
      local inbox_path = test_dir .. "/inbox.md"

      -- Act: User captures a quick note
      helpers.assert_can("capture to inbox", function()
        return zk.add_to_inbox("Quick thought: test the inbox")
      end, "User should be able to capture quick notes")

      -- Assert: Inbox should contain the note
      if vim.fn.filereadable(inbox_path) == 1 then
        local content = vim.fn.readfile(inbox_path)
        local found = false
        for _, line in ipairs(content) do
          if line:match("Quick thought: test the inbox") then
            found = true
            break
          end
        end
        assert.is_true(found, "Inbox should contain captured note")
      end
    end)
  end)

  describe("Note creation WORKS correctly", function()
    it("WORKS with unique timestamps", function()
      -- Arrange: Load Zettelkasten module
      local zk = require("config.zettelkasten")

      -- Act: Create multiple notes quickly
      local notes = {}
      helpers.assert_works("unique timestamp generation", function()
        for i = 1, 3 do
          local note = zk.new_note("Note " .. i)
          table.insert(notes, note)
          vim.wait(10) -- Small delay to ensure different timestamps
        end
        -- Check all notes are unique
        local seen = {}
        for _, note in ipairs(notes) do
          if seen[note] then
            return false
          end
          seen[note] = true
        end
        return true
      end, "Timestamp generation should produce unique IDs")

      -- Assert: All notes should be different
      assert.equals(3, #notes)
      assert.is_not.equals(notes[1], notes[2])
      assert.is_not.equals(notes[2], notes[3])
    end)

    it("WORKS with proper file structure", function()
      -- Arrange: Load Zettelkasten module
      local zk = require("config.zettelkasten")

      -- Act: Create a note with title
      local note_path = zk.new_note("Structured Note")

      helpers.assert_works("note structure creation", function()
        -- Check file was created
        if vim.fn.filereadable(note_path) ~= 1 then
          return false
        end

        -- Read the content
        local content = table.concat(vim.fn.readfile(note_path), "\n")

        -- Note should have basic structure
        return content:match("# Structured Note") ~= nil
      end, "Notes should be created with proper structure")

      -- Assert: Additional structure checks
      local content = table.concat(vim.fn.readfile(note_path), "\n")
      assert.matches("# Structured Note", content, "Should have title")
      -- Could check for more structure like tags, date, etc.
    end)

    it("WORKS with concurrent note creation", function()
      -- Arrange: Load Zettelkasten module
      local zk = require("config.zettelkasten")

      -- Act: Simulate concurrent note creation
      local notes_created = {}
      helpers.assert_works("concurrent note creation", function()
        -- Create notes without delays
        for i = 1, 5 do
          local note = zk.new_note("Concurrent " .. i)
          if vim.fn.filereadable(note) == 1 then
            table.insert(notes_created, note)
          end
        end
        return #notes_created == 5
      end, "Should handle concurrent note creation")

      -- Assert: All notes should be created
      assert.equals(5, #notes_created, "All concurrent notes should be created")
    end)
  end)

  describe("Note creation performance", function()
    it("creates notes within performance budget", function()
      -- Arrange: Load Zettelkasten module
      local zk = require("config.zettelkasten")

      -- Act & Assert: Measure note creation time
      local result, elapsed = helpers.run_timed(function()
        return zk.new_note("Performance Test")
      end, 200) -- 200ms budget for note creation

      -- Assert: Note creation should be fast
      assert.is_not_nil(result)
      assert.is_true(elapsed < 200, string.format("Note creation took %.2fms (budget: 200ms)", elapsed))
    end)
  end)
end)
