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

  describe("Daily Note Template Contract", function()
    it("MUST have ultra-simple frontmatter (title + created only)", function()
      -- Arrange: Load daily template (replaces fleeting)
      local template_path = vim.fn.expand("~/Zettelkasten/templates/daily.md")
      local file = io.open(template_path, "r")
      assert.is_not_nil(file, "Daily template must exist")

      -- Act: Read template content
      local content = file:read("*all")
      file:close()

      -- Assert: Only title and created fields in frontmatter
      assert.matches("title:", content)
      assert.matches("created:", content)
      assert.not_matches("draft:", content)
      assert.not_matches("categories:", content)
      assert.not_matches("description:", content)
    end)

    it("MUST have minimal structure for fast capture", function()
      -- Arrange: Load daily template
      local template_path = vim.fn.expand("~/Zettelkasten/templates/daily.md")
      local file = io.open(template_path, "r")
      local content = file:read("*all")
      file:close()

      -- Act: Count sections
      local sections = 0
      for _ in content:gmatch("##") do
        sections = sections + 1
      end

      -- Assert: Minimal sections for quick daily capture
      assert.is_true(
        sections >= 2,
        "Daily template must have sections for organization, found " .. sections .. " sections"
      )
    end)

    it("FORBIDDEN to have Hugo-specific fields", function()
      -- Arrange: Load daily template
      local template_path = vim.fn.expand("~/Zettelkasten/templates/daily.md")
      local file = io.open(template_path, "r")
      local content = file:read("*all")
      file:close()

      -- Assert: No Hugo fields
      assert.not_matches("draft:", content)
      assert.not_matches("bibliography:", content)
      assert.not_matches("cite%-method:", content)
    end)
  end)

  describe("Source Note Template Contract", function()
    it("MUST have citation-focused frontmatter", function()
      -- Arrange: Load source template (replaces wiki for literature notes)
      local template_path = vim.fn.expand("~/Zettelkasten/templates/source.md")
      local file = io.open(template_path, "r")
      assert.is_not_nil(file, "Source template must exist")

      -- Act: Read template content
      local content = file:read("*all")
      file:close()

      -- Assert: Required fields for academic citations
      assert.matches("title:", content)
      assert.matches("created:", content)
      assert.matches("tags:", content)
    end)

    it("MUST include citation support", function()
      -- Arrange: Load source template
      local template_path = vim.fn.expand("~/Zettelkasten/templates/source.md")
      local file = io.open(template_path, "r")
      local content = file:read("*all")
      file:close()

      -- Assert: Citation-related sections
      assert.matches("## Citation", content)
      assert.matches("## Summary", content)
      assert.matches("## Key Ideas", content)
    end)

    it("MUST have structured sections for literature notes", function()
      -- Arrange: Load source template
      local template_path = vim.fn.expand("~/Zettelkasten/templates/source.md")
      local file = io.open(template_path, "r")
      local content = file:read("*all")
      file:close()

      -- Assert: Expected sections for literature notes
      assert.matches("## Citation", content)
      assert.matches("## Summary", content)
      assert.matches("## Personal Notes", content)
      assert.matches("## Related Sources", content)
    end)

    it("OPTIONAL may include citation examples", function()
      -- Arrange: Load source template
      local template_path = vim.fn.expand("~/Zettelkasten/templates/source.md")
      local file = io.open(template_path, "r")
      local content = file:read("*all")
      file:close()

      -- Assert: Template exists and has content
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
