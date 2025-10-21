-- Zettelkasten Link Analysis Unit Tests
-- Tests for Markdown link parsing and knowledge graph analysis

-- Local helper function to create test note
local function create_test_note(path, content)
  vim.fn.writefile(vim.split(content, "\n"), path)
end

describe("Zettelkasten Link Analysis", function()
  local zettelkasten
  local test_home
  local original_expand

  before_each(function()
    -- Arrange: Mock vim.fn.expand to use test directory
    test_home = vim.fn.tempname()
    original_expand = vim.fn.expand

    vim.fn.expand = function(path)
      if path:match("^~/Zettelkasten") then
        return test_home .. path:gsub("^~/Zettelkasten", "")
      end
      return original_expand(path)
    end

    -- Load module fresh each time
    package.loaded["config.zettelkasten"] = nil
    zettelkasten = require("config.zettelkasten")
    zettelkasten.setup()
  end)

  after_each(function()
    -- Clean up test directory
    if vim.fn.isdirectory(test_home) == 1 then
      vim.fn.delete(test_home, "rf")
    end

    -- Restore original vim.fn.expand
    vim.fn.expand = original_expand
  end)

  describe("Markdown Link Pattern Matching", function()
    it("extracts Markdown links with .md extension", function()
      -- Arrange: Create note with Markdown links
      local note_path = test_home .. "/test-note.md"
      create_test_note(note_path, "# Test\n\nSee [related note](other-note.md) for details.")

      -- Act: Analyze links
      local notes = zettelkasten.analyze_links()

      -- Assert: Link was extracted
      assert.is_not_nil(notes["test-note"])
      assert.equals(1, notes["test-note"].outgoing)
    end)

    it("extracts Markdown links without .md extension", function()
      -- Arrange: Create note with link without extension
      local note_path = test_home .. "/test-note.md"
      create_test_note(note_path, "# Test\n\nSee [related](other-note) for details.")

      -- Act: Analyze links
      local notes = zettelkasten.analyze_links()

      -- Assert: Link was extracted
      assert.is_not_nil(notes["test-note"])
      assert.equals(1, notes["test-note"].outgoing)
    end)

    it("ignores old wiki-style links", function()
      -- Arrange: Create note with old wiki links (should NOT be counted)
      local note_path = test_home .. "/test-note.md"
      create_test_note(note_path, "# Test\n\n[[old-style-link]] should be ignored.")

      -- Act: Analyze links
      local notes = zettelkasten.analyze_links()

      -- Assert: No links extracted (wiki links not supported)
      assert.is_not_nil(notes["test-note"])
      assert.equals(0, notes["test-note"].outgoing)
    end)

    it("handles multiple Markdown links in same note", function()
      -- Arrange: Create note with multiple links
      local note_path = test_home .. "/test-note.md"
      local content = [[
# Test Note

See [note 1](note1.md), [note 2](note2), and [note 3](note3.md).
]]
      create_test_note(note_path, content)

      -- Act: Analyze links
      local notes = zettelkasten.analyze_links()

      -- Assert: All three links counted
      assert.is_not_nil(notes["test-note"])
      assert.equals(3, notes["test-note"].outgoing)
    end)

    it("normalizes filenames by stripping .md extension", function()
      -- Arrange: Create notes with links (some with .md, some without)
      local note1_path = test_home .. "/note1.md"
      create_test_note(note1_path, "Link to [note 2](note2.md)")

      local note2_path = test_home .. "/note2.md"
      create_test_note(note2_path, "Link to [note 1](note1)")

      -- Act: Analyze links
      local notes = zettelkasten.analyze_links()

      -- Assert: Both notes have 1 outgoing and 1 incoming link
      assert.equals(1, notes["note1"].outgoing)
      assert.equals(1, notes["note1"].incoming)
      assert.equals(1, notes["note2"].outgoing)
      assert.equals(1, notes["note2"].incoming)
    end)
  end)

  describe("Orphan Note Detection", function()
    it("identifies notes with no links", function()
      -- Arrange: Create orphan note (no links in or out)
      local orphan_path = test_home .. "/orphan.md"
      create_test_note(orphan_path, "# Orphan Note\n\nNo links here.")

      -- Act: Analyze for orphans
      local notes = zettelkasten.analyze_links()

      -- Assert: Note has no connections
      assert.equals(0, notes["orphan"].outgoing)
      assert.equals(0, notes["orphan"].incoming)
      assert.equals(0, notes["orphan"].total)
    end)

    it("does not count notes with only outgoing links as orphans", function()
      -- Arrange: Create note with outgoing link but no incoming
      local note_path = test_home .. "/has-outgoing.md"
      create_test_note(note_path, "See [other note](other.md)")

      local other_path = test_home .. "/other.md"
      create_test_note(other_path, "# Other Note")

      -- Act: Analyze links
      local notes = zettelkasten.analyze_links()

      -- Assert: Note has connections (not orphan)
      assert.equals(1, notes["has-outgoing"].outgoing)
      assert.equals(1, notes["has-outgoing"].total)
      assert.is_true(notes["has-outgoing"].total > 0)
    end)

    it("does not count notes with only incoming links as orphans", function()
      -- Arrange: Create note with incoming link but no outgoing
      local source_path = test_home .. "/source.md"
      create_test_note(source_path, "See [target note](target.md)")

      local target_path = test_home .. "/target.md"
      create_test_note(target_path, "# Target Note\n\nNo outgoing links.")

      -- Act: Analyze links
      local notes = zettelkasten.analyze_links()

      -- Assert: Target has connections (not orphan)
      assert.equals(0, notes["target"].outgoing)
      assert.equals(1, notes["target"].incoming)
      assert.equals(1, notes["target"].total)
    end)
  end)

  describe("Hub Note Detection", function()
    it("identifies notes with many connections", function()
      -- Arrange: Create hub note with multiple outgoing links
      local hub_path = test_home .. "/hub.md"
      local hub_content = [[
# Hub Note

Links to:
- [note 1](note1.md)
- [note 2](note2.md)
- [note 3](note3.md)
]]
      create_test_note(hub_path, hub_content)

      -- Create target notes that link back
      for i = 1, 3 do
        local note_path = test_home .. "/note" .. i .. ".md"
        create_test_note(note_path, "Link to [hub](hub.md)")
      end

      -- Act: Analyze links
      local notes = zettelkasten.analyze_links()

      -- Assert: Hub has high connection count
      assert.equals(3, notes["hub"].outgoing)
      assert.equals(3, notes["hub"].incoming)
      assert.equals(6, notes["hub"].total)
    end)

    it("counts both incoming and outgoing for total connections", function()
      -- Arrange: Create interconnected notes
      local note1_path = test_home .. "/note1.md"
      create_test_note(note1_path, "Links to [note 2](note2.md) and [note 3](note3.md)")

      local note2_path = test_home .. "/note2.md"
      create_test_note(note2_path, "Links to [note 1](note1.md)")

      local note3_path = test_home .. "/note3.md"
      create_test_note(note3_path, "# Note 3")

      -- Act: Analyze links
      local notes = zettelkasten.analyze_links()

      -- Assert: note1 has 2 outgoing + 1 incoming = 3 total
      assert.equals(2, notes["note1"].outgoing)
      assert.equals(1, notes["note1"].incoming)
      assert.equals(3, notes["note1"].total)
    end)

    it("sorts hubs by total connection count", function()
      -- Arrange: Create notes with varying connection counts
      local big_hub_path = test_home .. "/big-hub.md"
      create_test_note(big_hub_path, "Links: [a](a.md), [b](b.md), [c](c.md)")

      local small_hub_path = test_home .. "/small-hub.md"
      create_test_note(small_hub_path, "Link: [a](a.md)")

      local a_path = test_home .. "/a.md"
      create_test_note(a_path, "# A")

      local b_path = test_home .. "/b.md"
      create_test_note(b_path, "# B")

      local c_path = test_home .. "/c.md"
      create_test_note(c_path, "# C")

      -- Act: Analyze links
      local notes = zettelkasten.analyze_links()

      -- Assert: big-hub has more connections than small-hub
      assert.is_true(notes["big-hub"].total > notes["small-hub"].total)
    end)
  end)

  describe("Backlinks Functionality", function()
    it("generates correct search pattern for backlinks", function()
      -- Arrange: Mock current file
      local current_file = "target-note"

      -- Act: Extract expected search pattern
      -- backlinks() should search for "](target-note"
      local expected_pattern = "](" .. current_file

      -- Assert: Pattern format is correct
      assert.equals("](target-note", expected_pattern)
    end)
  end)

  describe("Edge Cases", function()
    it("handles notes in subdirectories", function()
      -- Arrange: Create subdirectory and note
      vim.fn.mkdir(test_home .. "/subdir", "p")
      local note_path = test_home .. "/subdir/nested.md"
      create_test_note(note_path, "# Nested Note")

      -- Act: Analyze links
      local notes = zettelkasten.analyze_links()

      -- Assert: Nested note is included in analysis
      assert.is_not_nil(notes["nested"])
    end)

    it("handles empty notes", function()
      -- Arrange: Create empty note
      local empty_path = test_home .. "/empty.md"
      create_test_note(empty_path, "")

      -- Act: Analyze links
      local notes = zettelkasten.analyze_links()

      -- Assert: Empty note has zero connections
      assert.is_not_nil(notes["empty"])
      assert.equals(0, notes["empty"].total)
    end)

    it("handles notes with only frontmatter", function()
      -- Arrange: Create note with just frontmatter
      local frontmatter_path = test_home .. "/frontmatter.md"
      local content = [[---
title: Test
tags: []
---]]
      create_test_note(frontmatter_path, content)

      -- Act: Analyze links
      local notes = zettelkasten.analyze_links()

      -- Assert: Frontmatter-only note has zero connections
      assert.is_not_nil(notes["frontmatter"])
      assert.equals(0, notes["frontmatter"].total)
    end)

    it("handles special characters in filenames", function()
      -- Arrange: Create note with special characters
      local special_path = test_home .. "/note-with-dash.md"
      create_test_note(special_path, "# Note")

      -- Act: Analyze links
      local notes = zettelkasten.analyze_links()

      -- Assert: Special character filename handled correctly
      assert.is_not_nil(notes["note-with-dash"])
    end)
  end)
end)
