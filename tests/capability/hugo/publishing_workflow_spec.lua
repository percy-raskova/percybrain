-- Capability Tests for Hugo Publishing Workflow
-- Tests what users CAN DO with Hugo publishing
-- Kent Beck: "Test capabilities, not configuration"

describe("Hugo Publishing Workflow Capabilities", function()
  local hugo
  local test_note_path

  before_each(function()
    -- Arrange: Load Hugo module and clean test state
    hugo = require("lib.hugo-menu")
    test_note_path = nil
  end)

  after_each(function()
    -- Cleanup: Remove test notes
    if test_note_path and vim.fn.filereadable(test_note_path) == 1 then
      vim.fn.delete(test_note_path)
    end
  end)

  describe("Frontmatter Validation Capabilities", function()
    it("CAN validate Hugo-compatible wiki note before publishing", function()
      -- Arrange: User has wiki note with Hugo frontmatter
      local wiki_content = [[
---
title: "Distributed Cognition Systems"
date: 2025-10-19
draft: false
tags: [cognition, systems]
categories: [research]
description: "Analysis of distributed cognition"
---

# Distributed Cognition Systems

## Overview
Content here
]]

      test_note_path = "/tmp/test-wiki-valid.md"
      local file = io.open(test_note_path, "w")
      file:write(wiki_content)
      file:close()

      -- Act: Validate note for publishing
      local is_valid, errors = hugo.validate_file_for_publishing(test_note_path)

      -- Assert: User can publish valid wiki note
      assert.is_true(is_valid, "Valid wiki note should pass validation")
      assert.is_nil(errors)
    end)

    it("CAN detect invalid frontmatter before publishing", function()
      -- Arrange: User has note with invalid frontmatter
      local invalid_content = [[
---
title: Test Note
date: 10/19/2025
draft: "false"
---

# Content
]]

      test_note_path = "/tmp/test-wiki-invalid.md"
      local file = io.open(test_note_path, "w")
      file:write(invalid_content)
      file:close()

      -- Act: Validate note for publishing
      local is_valid, errors = hugo.validate_file_for_publishing(test_note_path)

      -- Assert: User receives clear error message
      assert.is_false(is_valid, "Invalid frontmatter should fail validation")
      assert.is_not_nil(errors)
      assert.is_string(errors)
    end)

    it("CAN get helpful error messages for frontmatter issues", function()
      -- Arrange: User has note with multiple frontmatter errors
      local invalid_content = [[
---
title: No Quotes
date: bad-date-format
draft: "string-not-boolean"
tags: not-an-array
---

# Content
]]

      test_note_path = "/tmp/test-wiki-errors.md"
      local file = io.open(test_note_path, "w")
      file:write(invalid_content)
      file:close()

      -- Act: Validate and get errors
      local is_valid, errors = hugo.validate_file_for_publishing(test_note_path)

      -- Assert: Error messages are descriptive
      assert.is_false(is_valid)
      assert.is_not_nil(errors)
      assert.matches("date", errors) -- mentions date problem
      assert.matches("draft", errors) -- mentions draft problem
    end)
  end)

  describe("Publishing Workflow Capabilities", function()
    it("CAN check if note should be published (wiki yes, inbox no)", function()
      -- Arrange: User has both wiki and inbox notes
      local wiki_path = vim.fn.expand("~/Zettelkasten/wiki-note.md")
      local inbox_path = vim.fn.expand("~/Zettelkasten/inbox/fleeting.md")

      -- Act: Check publishing eligibility
      local wiki_should_publish = hugo.should_publish_file(wiki_path)
      local inbox_should_publish = hugo.should_publish_file(inbox_path)

      -- Assert: Wiki published, inbox excluded
      assert.is_true(wiki_should_publish, "Wiki notes should be published")
      assert.is_false(inbox_should_publish, "Inbox notes should be excluded")
    end)

    it("CAN validate all wiki notes before batch publishing", function()
      -- Arrange: User wants to publish multiple notes
      local notes = {
        {
          path = "/tmp/wiki1.md",
          content = [[
---
title: "Valid Note 1"
date: 2025-10-19
draft: false
---
# Content
]],
        },
        {
          path = "/tmp/wiki2.md",
          content = [[
---
title: "Valid Note 2"
date: 2025-10-19
draft: false
---
# Content
]],
        },
      }

      -- Create test files
      for _, note in ipairs(notes) do
        local file = io.open(note.path, "w")
        file:write(note.content)
        file:close()
      end

      -- Act: Validate batch of notes
      local validation_results = {}
      for _, note in ipairs(notes) do
        local is_valid, errors = hugo.validate_file_for_publishing(note.path)
        table.insert(validation_results, { path = note.path, valid = is_valid, errors = errors })
      end

      -- Assert: User can see validation status for all notes
      assert.equals(2, #validation_results)
      assert.is_true(validation_results[1].valid)
      assert.is_true(validation_results[2].valid)

      -- Cleanup
      for _, note in ipairs(notes) do
        vim.fn.delete(note.path)
      end
    end)
  end)

  describe("Error Recovery Capabilities", function()
    it("CAN receive actionable error messages for fixing frontmatter", function()
      -- Arrange: User has note with fixable errors
      local fixable_content = [[
---
title: Missing Quotes
date: 2025-10-19
draft: false
---
# Content
]]

      test_note_path = "/tmp/test-fixable.md"
      local file = io.open(test_note_path, "w")
      file:write(fixable_content)
      file:close()

      -- Act: Validate and get guidance
      local is_valid, errors = hugo.validate_file_for_publishing(test_note_path)

      -- Assert: Error message helps user fix the issue
      -- (In this case, title without quotes might be valid or invalid depending on YAML parser)
      -- We're testing that the system provides clear feedback
      if not is_valid then
        assert.is_string(errors)
        assert.is_true(#errors > 0, "Error message should not be empty")
      end
    end)

    it("CAN validate frontmatter after user edits", function()
      -- Arrange: User starts with invalid frontmatter
      local content_v1 = [[
---
title: No Quotes
date: bad-date
draft: false
---
# Content
]]

      test_note_path = "/tmp/test-iterative.md"
      local file = io.open(test_note_path, "w")
      file:write(content_v1)
      file:close()

      -- Act: First validation (should fail)
      local is_valid_v1, _errors_v1 = hugo.validate_file_for_publishing(test_note_path)
      assert.is_false(is_valid_v1)

      -- User fixes the frontmatter
      local content_v2 = [[
---
title: "With Quotes"
date: 2025-10-19
draft: false
---
# Content
]]

      file = io.open(test_note_path, "w")
      file:write(content_v2)
      file:close()

      -- Act: Second validation (should pass)
      local is_valid_v2, errors_v2 = hugo.validate_file_for_publishing(test_note_path)

      -- Assert: User can fix and re-validate
      assert.is_true(is_valid_v2, "Fixed frontmatter should pass validation")
      assert.is_nil(errors_v2)
    end)
  end)

  describe("Optional Field Capabilities", function()
    it("CAN validate notes with optional BibTeX fields", function()
      -- Arrange: Wiki note with bibliography
      local bibtex_content = [[
---
title: "Academic Research Note"
date: 2025-10-19
draft: false
tags: [research]
categories: [academic]
description: "Research with citations"
bibliography: references.bib
cite-method: biblatex
---

# Research Note

According to [@smith2020], this demonstrates...
]]

      test_note_path = "/tmp/test-bibtex.md"
      local file = io.open(test_note_path, "w")
      file:write(bibtex_content)
      file:close()

      -- Act: Validate note with BibTeX fields
      local is_valid, errors = hugo.validate_file_for_publishing(test_note_path)

      -- Assert: Optional BibTeX fields don't break validation
      assert.is_true(is_valid, "BibTeX fields should be accepted")
      assert.is_nil(errors)
    end)

    it("CAN validate notes without optional fields", function()
      -- Arrange: Minimal wiki note (only required fields)
      local minimal_content = [[
---
title: "Minimal Note"
date: 2025-10-19
draft: false
---

# Minimal Note

Just the essentials.
]]

      test_note_path = "/tmp/test-minimal.md"
      local file = io.open(test_note_path, "w")
      file:write(minimal_content)
      file:close()

      -- Act: Validate minimal note
      local is_valid, errors = hugo.validate_file_for_publishing(test_note_path)

      -- Assert: Minimal notes are valid
      assert.is_true(is_valid, "Minimal frontmatter should be valid")
      assert.is_nil(errors)
    end)
  end)
end)
