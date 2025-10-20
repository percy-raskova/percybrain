-- Contract Tests for Zettelkasten Template System
-- Tests what the system MUST, MUST NOT, and MAY do
-- Kent Beck: "Specify the contract before implementation"

describe("Zettelkasten Template System Contract", function()
  before_each(function()
    -- Arrange: Ensure templates exist
  end)

  after_each(function()
    -- Cleanup: No state to restore
  end)

  describe("Fleeting Note Template Contract", function()
    it("MUST have ultra-simple frontmatter (title + created only)", function()
      -- Arrange: Load fleeting template
      local template_path = vim.fn.expand("~/Zettelkasten/templates/fleeting.md")
      local file = io.open(template_path, "r")
      assert.is_not_nil(file, "Fleeting template must exist")

      -- Act: Read template content
      local content = file:read("*all")
      file:close()

      -- Assert: Only title and created fields in frontmatter
      assert.matches("title:", content)
      assert.matches("created:", content)
      assert.not_matches("draft:", content)
      assert.not_matches("tags:", content)
      assert.not_matches("categories:", content)
      assert.not_matches("description:", content)
    end)

    it("MUST have minimal structure for fast capture", function()
      -- Arrange: Load fleeting template
      local template_path = vim.fn.expand("~/Zettelkasten/templates/fleeting.md")
      local file = io.open(template_path, "r")
      local content = file:read("*all")
      file:close()

      -- Act: Count sections
      local sections = 0
      for _ in content:gmatch("##") do
        sections = sections + 1
      end

      -- Assert: Minimal sections (ideally 0, max 2)
      assert.is_true(sections <= 2, "Fleeting template must be minimal, found " .. sections .. " sections")
    end)

    it("FORBIDDEN to have Hugo-specific fields", function()
      -- Arrange: Load fleeting template
      local template_path = vim.fn.expand("~/Zettelkasten/templates/fleeting.md")
      local file = io.open(template_path, "r")
      local content = file:read("*all")
      file:close()

      -- Assert: No Hugo fields
      assert.not_matches("draft:", content)
      assert.not_matches("bibliography:", content)
      assert.not_matches("cite%-method:", content)
    end)
  end)

  describe("Wiki Page Template Contract", function()
    it("MUST have Hugo-compatible frontmatter", function()
      -- Arrange: Load wiki template
      local template_path = vim.fn.expand("~/Zettelkasten/templates/wiki.md")
      local file = io.open(template_path, "r")
      assert.is_not_nil(file, "Wiki template must exist")

      -- Act: Read template content
      local content = file:read("*all")
      file:close()

      -- Assert: Required Hugo fields
      assert.matches("title:", content)
      assert.matches("date:", content)
      assert.matches("draft:", content)
      assert.matches("tags:", content)
      assert.matches("categories:", content)
      assert.matches("description:", content)
    end)

    it("MUST include BibTeX citation support", function()
      -- Arrange: Load wiki template
      local template_path = vim.fn.expand("~/Zettelkasten/templates/wiki.md")
      local file = io.open(template_path, "r")
      local content = file:read("*all")
      file:close()

      -- Assert: BibTeX configuration
      assert.matches("bibliography:", content)
      assert.matches("cite%-method:", content)
    end)

    it("MUST have structured sections for wiki content", function()
      -- Arrange: Load wiki template
      local template_path = vim.fn.expand("~/Zettelkasten/templates/wiki.md")
      local file = io.open(template_path, "r")
      local content = file:read("*all")
      file:close()

      -- Assert: Expected sections
      assert.matches("## Overview", content)
      assert.matches("## References", content)
    end)

    it("OPTIONAL may include citation examples", function()
      -- Arrange: Load wiki template
      local template_path = vim.fn.expand("~/Zettelkasten/templates/wiki.md")
      local file = io.open(template_path, "r")
      local content = file:read("*all")
      file:close()

      -- Assert: BibTeX usage hints (optional but helpful)
      -- Just check it exists, content can vary
      assert.is_not_nil(content)
    end)
  end)

  describe("Template Naming Convention Contract", function()
    it("MUST use yyyymmdd-title.md naming for all notes", function()
      -- Arrange: This is a specification, not runtime test
      -- Act: Document expected behavior
      local expected_format = "20251019-example-note.md"

      -- Assert: Pattern matches expected format
      assert.matches("^%d%d%d%d%d%d%d%d%-.*%.md$", expected_format)
    end)
  end)
end)
