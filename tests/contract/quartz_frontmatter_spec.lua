-- Contract Tests for Quartz Frontmatter Validation
-- Tests what the system MUST, MUST NOT, and MAY do for Quartz publishing
-- Kent Beck: "Specify the contract before implementation"
-- Quartz v4 spec: https://quartz.jzhao.xyz/features/frontmatter

describe("Quartz Frontmatter Validation Contract", function()
  before_each(function()
    -- Arrange: Ensure clean test state
  end)

  after_each(function()
    -- Cleanup: No state to restore
  end)

  describe("Quartz Frontmatter Format Contract", function()
    it("MUST validate date field is YYYY-MM-DD format", function()
      -- Arrange: Wiki note with valid date
      local valid_frontmatter = [[
---
title: "Test Note"
date: 2025-10-24
---
]]

      -- Act: Parse frontmatter
      local quartz = require("lib.quartz-frontmatter")
      local frontmatter = quartz.parse_frontmatter(valid_frontmatter)

      -- Assert: date matches YYYY-MM-DD pattern
      assert.is_not_nil(frontmatter)
      assert.matches("^%d%d%d%d%-%d%d%-%d%d$", frontmatter.date)
    end)

    it("MUST validate tags field is array", function()
      -- Arrange: Wiki note with tags
      local valid_frontmatter = [[
---
title: "Test Note"
date: 2025-10-24
tags: [test, quartz]
---
]]

      -- Act: Parse frontmatter
      local quartz = require("lib.quartz-frontmatter")
      local frontmatter = quartz.parse_frontmatter(valid_frontmatter)

      -- Assert: tags is table (array)
      assert.is_not_nil(frontmatter)
      assert.equals("table", type(frontmatter.tags))
    end)

    it("MUST validate title field exists and is string", function()
      -- Arrange: Wiki note with title
      local valid_frontmatter = [[
---
title: "Test Note"
date: 2025-10-24
---
]]

      -- Act: Parse frontmatter
      local quartz = require("lib.quartz-frontmatter")
      local frontmatter = quartz.parse_frontmatter(valid_frontmatter)

      -- Assert: title is string
      assert.is_not_nil(frontmatter)
      assert.equals("string", type(frontmatter.title))
      assert.equals("Test Note", frontmatter.title)
    end)

    it("MAY include draft field as boolean (optional)", function()
      -- Arrange: Wiki note with optional draft field
      local frontmatter_with_draft = [[
---
title: "Draft Note"
date: 2025-10-24
draft: true
---
]]

      -- Act: Parse frontmatter
      local quartz = require("lib.quartz-frontmatter")
      local frontmatter = quartz.parse_frontmatter(frontmatter_with_draft)

      -- Assert: draft is boolean when present
      assert.is_not_nil(frontmatter)
      assert.equals("boolean", type(frontmatter.draft))
      assert.equals(true, frontmatter.draft)
    end)

    it("MAY include aliases field as array (Quartz-specific)", function()
      -- Arrange: Wiki note with aliases
      local frontmatter_with_aliases = [[
---
title: "Main Title"
date: 2025-10-24
aliases: [Alternative Name, Alt Title]
---
]]

      -- Act: Parse frontmatter
      local quartz = require("lib.quartz-frontmatter")
      local frontmatter = quartz.parse_frontmatter(frontmatter_with_aliases)

      -- Assert: aliases is table (array)
      assert.is_not_nil(frontmatter)
      assert.equals("table", type(frontmatter.aliases))
      assert.is_true(#frontmatter.aliases >= 2)
    end)

    it("MAY include description field as string (auto-generated if omitted)", function()
      -- Arrange: Wiki note with description
      local frontmatter_with_description = [[
---
title: "Test Note"
date: 2025-10-24
description: "This is a test note for Quartz publishing"
---
]]

      -- Act: Parse frontmatter
      local quartz = require("lib.quartz-frontmatter")
      local frontmatter = quartz.parse_frontmatter(frontmatter_with_description)

      -- Assert: description is string when present
      assert.is_not_nil(frontmatter)
      assert.equals("string", type(frontmatter.description))
    end)
  end)

  describe("Quartz Frontmatter Validation Contract", function()
    it("MUST detect invalid draft field (string instead of boolean)", function()
      -- Arrange: Invalid frontmatter with string draft
      local invalid_frontmatter = [[
---
title: "Test Note"
date: 2025-10-24
draft: "false"
---
]]

      -- Act: Validate frontmatter
      local quartz = require("lib.quartz-frontmatter")
      local is_valid, errors = quartz.validate_frontmatter(invalid_frontmatter)

      -- Assert: Validation fails with draft error
      assert.is_false(is_valid)
      assert.is_not_nil(errors)
      assert.matches("draft.*boolean", errors)
    end)

    it("MUST detect invalid date format", function()
      -- Arrange: Invalid frontmatter with wrong date format
      local invalid_frontmatter = [[
---
title: "Test Note"
date: 10/24/2025
---
]]

      -- Act: Validate frontmatter
      local quartz = require("lib.quartz-frontmatter")
      local is_valid, errors = quartz.validate_frontmatter(invalid_frontmatter)

      -- Assert: Validation fails with date error
      assert.is_false(is_valid)
      assert.is_not_nil(errors)
      assert.matches("date.*YYYY%-MM%-DD", errors)
    end)

    it("MUST detect missing required fields", function()
      -- Arrange: Incomplete frontmatter (missing date)
      local incomplete_frontmatter = [[
---
title: "Test Note"
---
]]

      -- Act: Validate frontmatter
      local quartz = require("lib.quartz-frontmatter")
      local is_valid, errors = quartz.validate_frontmatter(incomplete_frontmatter)

      -- Assert: Validation fails with missing field error
      assert.is_false(is_valid)
      assert.is_not_nil(errors)
      assert.matches("missing.*date", errors)
    end)

    it("MUST accept valid Quartz-compatible frontmatter without draft field", function()
      -- Arrange: Complete valid frontmatter (draft omitted - defaults to published)
      local valid_frontmatter = [[
---
title: "Distributed Cognition"
date: 2025-10-24
tags: [cognition, systems]
description: "Exploring distributed cognition systems"
---
]]

      -- Act: Validate frontmatter
      local quartz = require("lib.quartz-frontmatter")
      local is_valid, errors = quartz.validate_frontmatter(valid_frontmatter)

      -- Assert: Validation passes (draft is optional in Quartz)
      assert.is_true(is_valid)
      assert.is_nil(errors)
    end)

    it("MUST accept valid Quartz-compatible frontmatter with all fields", function()
      -- Arrange: Complete valid frontmatter with all Quartz fields
      local complete_frontmatter = [[
---
title: "Zettelkasten Method"
date: 2025-10-24
draft: false
tags: [zettelkasten, knowledge-management]
aliases: [Slip Box Method, Note-taking System]
description: "The Zettelkasten method for networked note-taking"
permalink: zettelkasten-method
---
]]

      -- Act: Validate frontmatter
      local quartz = require("lib.quartz-frontmatter")
      local is_valid, errors = quartz.validate_frontmatter(complete_frontmatter)

      -- Assert: Validation passes
      assert.is_true(is_valid)
      assert.is_nil(errors)
    end)

    it("MUST validate aliases field is array not string", function()
      -- Arrange: Invalid frontmatter with string aliases
      local invalid_aliases = [[
---
title: "Test Note"
date: 2025-10-24
aliases: "not an array"
---
]]

      -- Act: Validate frontmatter
      local quartz = require("lib.quartz-frontmatter")
      local is_valid, errors = quartz.validate_frontmatter(invalid_aliases)

      -- Assert: Validation fails with aliases error
      assert.is_false(is_valid)
      assert.is_not_nil(errors)
      assert.matches("aliases.*array", errors)
    end)
  end)

  describe("Quartz Publishing Safety Contract", function()
    it("FORBIDDEN to publish notes with invalid frontmatter", function()
      -- Arrange: Note with invalid frontmatter
      local test_note = "/tmp/test-invalid-quartz.md"
      local invalid_content = [[
---
title: "Invalid Note"
date: not-a-date
draft: "false"
---
# Content
]]

      -- Write test file
      local file = io.open(test_note, "w")
      file:write(invalid_content)
      file:close()

      -- Act: Attempt to validate for publishing
      local quartz = require("lib.quartz-frontmatter")
      local is_valid, errors = quartz.validate_file_for_publishing(test_note)

      -- Assert: Validation blocks publishing
      assert.is_false(is_valid)
      assert.is_not_nil(errors)

      -- Cleanup
      vim.fn.delete(test_note)
    end)

    it("MUST exclude inbox directory from publishing", function()
      -- Arrange: Inbox path pattern
      local inbox_note = vim.fn.expand("~/Zettelkasten/inbox/fleeting-note.md")

      -- Act: Check if should be published
      local quartz = require("lib.quartz-frontmatter")
      local should_publish = quartz.should_publish_file(inbox_note)

      -- Assert: Inbox notes not published
      assert.is_false(should_publish)
    end)

    it("MUST exclude private directory from publishing (Quartz-specific)", function()
      -- Arrange: Private directory path pattern
      local private_note = vim.fn.expand("~/Zettelkasten/private/personal-note.md")

      -- Act: Check if should be published
      local quartz = require("lib.quartz-frontmatter")
      local should_publish = quartz.should_publish_file(private_note)

      -- Assert: Private notes not published
      assert.is_false(should_publish)
    end)

    it("MUST include root zettelkasten notes for publishing", function()
      -- Arrange: Root zettelkasten path
      local wiki_note = vim.fn.expand("~/Zettelkasten/distributed-cognition.md")

      -- Act: Check if should be published
      local quartz = require("lib.quartz-frontmatter")
      local should_publish = quartz.should_publish_file(wiki_note)

      -- Assert: Wiki notes are published
      assert.is_true(should_publish)
    end)
  end)

  describe("Frontmatter Extraction Contract", function()
    it("MUST extract frontmatter from note content", function()
      -- Arrange: Note with frontmatter
      local note_content = [[
---
title: "Test Note"
date: 2025-10-24
tags: [test]
---

# Test Note

Content here
]]

      -- Act: Extract frontmatter
      local quartz = require("lib.quartz-frontmatter")
      local frontmatter = quartz.extract_frontmatter(note_content)

      -- Assert: Frontmatter extracted correctly
      assert.is_not_nil(frontmatter)
      assert.equals("Test Note", frontmatter.title)
      assert.equals("2025-10-24", frontmatter.date)
    end)

    it("MUST return nil for notes without frontmatter", function()
      -- Arrange: Note without frontmatter
      local note_content = [[
# Test Note

Content without frontmatter
]]

      -- Act: Extract frontmatter
      local quartz = require("lib.quartz-frontmatter")
      local frontmatter = quartz.extract_frontmatter(note_content)

      -- Assert: No frontmatter extracted
      assert.is_nil(frontmatter)
    end)
  end)
end)
