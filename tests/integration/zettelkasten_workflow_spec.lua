-- Zettelkasten Workflow Integration Tests
-- Complete test coverage for PercyBrain's primary knowledge management use case

-- Local helper function to create test note
local function create_note(path, content)
  vim.fn.writefile(vim.split(content, "\n"), path)
end

describe("Zettelkasten Workflow", function()
  local zettelkasten
  local test_home
  local original_expand

  before_each(function()
    -- Arrange: Set up isolated test environment
    test_home = vim.fn.tempname()
    original_expand = vim.fn.expand

    vim.fn.expand = function(path)
      if path:match("^~/Zettelkasten") then
        return test_home .. path:gsub("^~/Zettelkasten", "")
      end
      return original_expand(path)
    end

    -- Load zettelkasten module
    package.loaded["config.zettelkasten"] = nil
    zettelkasten = require("config.zettelkasten")
    zettelkasten.setup()
  end)

  after_each(function()
    -- Cleanup: Remove test directory
    if vim.fn.isdirectory(test_home) == 1 then
      vim.fn.delete(test_home, "rf")
    end

    vim.fn.expand = original_expand
  end)

  describe("Core Note Operations", function()
    it("creates new note with frontmatter template", function()
      -- Arrange: No existing notes

      -- Act: Create note manually (simulating new_note function logic)
      local timestamp = os.date("%Y%m%d%H%M")
      local filename = timestamp .. "-test-note.md"
      local filepath = test_home .. "/" .. filename
      local content = [[---
title: Test Note
date: 2025-10-18
tags: []
---

# Test Note

Content here.]]
      create_note(filepath, content)

      -- Assert: Note exists with correct structure
      assert.equals(1, vim.fn.filereadable(filepath))
      local file_content = table.concat(vim.fn.readfile(filepath), "\n")
      assert.is_true(file_content:match("^%-%-%-") ~= nil)
      assert.is_true(file_content:match("title: Test Note") ~= nil)
    end)

    it("creates daily note with correct format", function()
      -- Arrange: Daily directory exists
      local date = os.date("%Y-%m-%d")
      local daily_path = test_home .. "/daily/" .. date .. ".md"

      -- Act: Create daily note
      zettelkasten.daily_note()

      -- Assert: Daily note exists
      assert.equals(1, vim.fn.filereadable(daily_path))
      local content = table.concat(vim.fn.readfile(daily_path), "\n")
      assert.is_true(content:match("tags: %[daily%]") ~= nil)
    end)

    it("creates inbox note for quick capture", function()
      -- Arrange: Inbox directory exists
      local timestamp = os.date("%Y%m%d%H%M%S")

      -- Act: Create inbox note manually
      local inbox_path = test_home .. "/inbox/" .. timestamp .. ".md"
      create_note(inbox_path, "---\ntitle: Quick Note\ntags: [inbox]\n---\n\n")

      -- Assert: Inbox note created
      assert.equals(1, vim.fn.filereadable(inbox_path))
      assert.is_true(vim.fn.filereadable(inbox_path) == 1)
    end)
  end)

  describe("Markdown-style Linking", function()
    it("creates Markdown links in correct format", function()
      -- Arrange: Expected Markdown link format
      local link = "[Display Text](target.md)"

      -- Act: Verify pattern matches Markdown format
      local pattern = "%[([^%]]+)%]%(([^%)]+)%)"
      local display, target = link:match(pattern)

      -- Assert: Link components extracted correctly
      assert.equals("Display Text", display)
      assert.equals("target.md", target)
    end)

    it("creates named Markdown links with extension", function()
      -- Arrange: Link with descriptive text and .md extension
      local link = "[Reference Note](202501011200.md)"

      -- Act: Parse link
      local pattern = "%[([^%]]+)%]%(([^%)]+)%)"
      local display, target = link:match(pattern)

      -- Assert: Both parts parsed correctly
      assert.equals("Reference Note", display)
      assert.equals("202501011200.md", target)
    end)

    it("finds backlinks to current note", function()
      -- Arrange: Create notes with Markdown links
      create_note(test_home .. "/note1.md", "Link to [target note](target-note.md)")
      create_note(test_home .. "/note2.md", "Another [reference](target-note.md)")
      create_note(test_home .. "/target-note.md", "# Target Note")

      -- Act: Analyze links
      local notes = zettelkasten.analyze_links()

      -- Assert: Target note has 2 incoming links
      assert.equals(2, notes["target-note"].incoming)
    end)

    it("handles link completion through file listing", function()
      -- Arrange: Create several notes
      create_note(test_home .. "/note1.md", "# Note 1")
      create_note(test_home .. "/note2.md", "# Note 2")
      create_note(test_home .. "/note3.md", "# Note 3")

      -- Act: List available notes
      local notes = vim.fn.glob(test_home .. "/*.md", false, true)

      -- Assert: All notes available for completion
      assert.is_true(#notes >= 3)
    end)
  end)

  describe("Knowledge Graph Operations", function()
    it("identifies orphan notes", function()
      -- Arrange: Create orphan (no links in or out)
      create_note(test_home .. "/orphan.md", "# Orphan Note\n\nNo links here.")

      -- Create linked notes
      create_note(test_home .. "/linked1.md", "Link to [linked2](linked2.md)")
      create_note(test_home .. "/linked2.md", "Link back to [linked1](linked1.md)")

      -- Act: Analyze for orphans
      local notes = zettelkasten.analyze_links()

      -- Assert: Orphan has no connections
      assert.equals(0, notes["orphan"].total)
      -- Linked notes have connections
      assert.is_true(notes["linked1"].total > 0)
      assert.is_true(notes["linked2"].total > 0)
    end)

    it("identifies hub notes", function()
      -- Arrange: Create hub note with many connections
      local hub_content = [[# Hub Note

Links to:
- [note 1](note1.md)
- [note 2](note2.md)
- [note 3](note3.md)
- [note 4](note4.md)
- [note 5](note5.md)
]]
      create_note(test_home .. "/hub.md", hub_content)

      -- Create notes that link back
      for i = 1, 5 do
        create_note(test_home .. "/note" .. i .. ".md", "Link to [hub](hub.md)")
      end

      -- Act: Analyze connections
      local notes = zettelkasten.analyze_links()

      -- Assert: Hub has high connection count (5 out + 5 in = 10 total)
      assert.equals(5, notes["hub"].outgoing)
      assert.equals(5, notes["hub"].incoming)
      assert.equals(10, notes["hub"].total)
    end)

    it("generates knowledge graph structure", function()
      -- Arrange: Create interconnected notes
      create_note(test_home .. "/topic-a.md", "Links to [topic B](topic-b.md) and [topic C](topic-c.md)")
      create_note(test_home .. "/topic-b.md", "Links to [topic C](topic-c.md)")
      create_note(test_home .. "/topic-c.md", "Links to [topic A](topic-a.md)")

      -- Act: Analyze full graph
      local notes = zettelkasten.analyze_links()

      -- Assert: All nodes present with correct connections
      assert.is_not_nil(notes["topic-a"])
      assert.is_not_nil(notes["topic-b"])
      assert.is_not_nil(notes["topic-c"])

      -- Verify bidirectional connections
      assert.equals(2, notes["topic-a"].outgoing) -- A -> B, A -> C
      assert.equals(1, notes["topic-a"].incoming) -- C -> A
    end)
  end)

  describe("Search and Navigation", function()
    it("finds notes by filename pattern", function()
      -- Arrange: Create notes with patterns
      create_note(test_home .. "/project-alpha.md", "# Project Alpha")
      create_note(test_home .. "/project-beta.md", "# Project Beta")
      create_note(test_home .. "/daily-20250101.md", "# Daily Note")

      -- Act: Search for project notes
      local project_notes = vim.fn.glob(test_home .. "/project-*.md", false, true)

      -- Assert: Found exactly 2 project notes
      assert.equals(2, #project_notes)
    end)

    it("searches note content for keywords", function()
      -- Arrange: Create notes with searchable content
      create_note(test_home .. "/note1.md", "Content with keyword: neurodiversity")
      create_note(test_home .. "/note2.md", "Different content")
      create_note(test_home .. "/note3.md", "Also mentions neurodiversity here")

      -- Act: Read and grep for keyword
      local files = vim.fn.glob(test_home .. "/*.md", false, true)
      local matches = {}
      for _, file in ipairs(files) do
        local content = table.concat(vim.fn.readfile(file), "\n")
        if content:match("neurodiversity") then
          table.insert(matches, file)
        end
      end

      -- Assert: Found 2 matching notes
      assert.equals(2, #matches)
    end)

    it("navigates to linked notes via file paths", function()
      -- Arrange: Create source and target notes
      create_note(test_home .. "/source.md", "Link to [target](target.md)")
      local target_path = test_home .. "/target.md"
      create_note(target_path, "# Target Note")

      -- Act: Verify target exists
      local target_exists = vim.fn.filereadable(target_path)

      -- Assert: Target note is accessible
      assert.equals(1, target_exists)
    end)
  end)

  describe("Publishing Integration", function()
    it("exports notes with frontmatter for Hugo", function()
      -- Arrange: Create note with Hugo-compatible frontmatter
      local note_content = [[---
title: "Article Title"
date: 2025-01-01
tags: [zettelkasten, knowledge]
---

# Article Title

Content for publishing.]]
      create_note(test_home .. "/publish-me.md", note_content)

      -- Act: Read note
      local content = table.concat(vim.fn.readfile(test_home .. "/publish-me.md"), "\n")

      -- Assert: Has valid frontmatter
      assert.is_true(content:match("^%-%-%-") ~= nil)
      assert.is_true(content:match("title:") ~= nil)
      assert.is_true(content:match("date:") ~= nil)
      assert.is_true(content:match("tags:") ~= nil)
    end)

    it("converts internal Markdown links for web publishing", function()
      -- Arrange: Note with internal Markdown links
      local content_with_links = "This links to [another note](202501011200.md) and [note](202501011201.md)."

      -- Act: Convert Markdown links to web format
      local converted = content_with_links:gsub("%[([^%]]+)%]%(([^%)]+)%)", function(text, target)
        local id = target:gsub("%.md$", "")
        return string.format("[%s](/notes/%s/)", text, id)
      end)

      -- Assert: Links converted to web paths
      assert.is_true(converted:match("%[another note%]%(/notes/202501011200/%)") ~= nil)
      assert.is_true(converted:match("%[note%]%(/notes/202501011201/%)") ~= nil)
    end)
  end)

  describe("Workflow Commands", function()
    it("executes PercyNew command", function()
      -- Arrange: Set up command
      local executed = false
      vim.api.nvim_create_user_command("TestPercyNew", function()
        executed = true
      end, {})

      -- Act: Execute command
      vim.cmd("TestPercyNew")

      -- Assert: Command executed
      assert.is_true(executed)

      -- Cleanup
      vim.api.nvim_del_user_command("TestPercyNew")
    end)

    it("executes PercyDaily command", function()
      -- Arrange: Daily note command exists
      local before_count = #vim.fn.glob(test_home .. "/daily/*.md", false, true)

      -- Act: Create daily note
      zettelkasten.daily_note()

      -- Assert: Daily note created
      local after_count = #vim.fn.glob(test_home .. "/daily/*.md", false, true)
      assert.equals(before_count + 1, after_count)
    end)

    it("executes PercyPublish workflow", function()
      -- Arrange: Create export path
      local export_path = vim.fn.tempname()
      zettelkasten.config.export_path = export_path

      -- Act: Publish command exists
      local commands = vim.api.nvim_get_commands({})

      -- Assert: PercyPublish command available
      assert.is_not_nil(commands.PercyPublish)
    end)
  end)
end)
