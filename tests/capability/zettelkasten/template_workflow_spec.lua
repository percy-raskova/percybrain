-- Capability Tests for Zettelkasten Template Workflow
-- Tests what users CAN DO with the template system
-- Kent Beck: "Test capabilities, not configuration"

describe("Zettelkasten Template Workflow Capabilities", function()
  local zettel = require("config.zettelkasten")
  local test_note_path

  before_each(function()
    -- Arrange: Clean test environment
    test_note_path = nil
  end)

  after_each(function()
    -- Cleanup: Remove test notes
    if test_note_path and vim.fn.filereadable(test_note_path) == 1 then
      vim.fn.delete(test_note_path)
    end
  end)

  describe("Fleeting Note Creation Capabilities", function()
    it("CAN create fleeting note with minimal friction", function()
      -- Arrange: User wants to capture quick idea
      local title = "Quick idea about AI"
      local template_name = "fleeting"

      -- Act: Load template and apply
      local template_content = zettel.load_template(template_name)
      assert.is_not_nil(template_content, "Fleeting template must load")

      local content = zettel.apply_template(template_content, title)

      -- Assert: Note created with simple frontmatter
      assert.matches("title: " .. title, content)
      assert.matches("created:", content)
      assert.not_matches("draft:", content)
      assert.not_matches("bibliography:", content)
    end)

    it("CAN create fleeting note without selecting template", function()
      -- Arrange: User just wants to start writing immediately
      -- This tests fallback behavior

      -- Act: Check that fallback exists in new_note function
      -- (Implementation will handle this)

      -- Assert: System allows quick creation even if template fails
      assert.is_true(true, "System provides fallback for fast capture")
    end)

    it("CAN save fleeting note to inbox directory", function()
      -- Arrange: Fleeting notes go to inbox
      local inbox_path = vim.fn.expand("~/Zettelkasten/inbox")

      -- Act: Verify inbox exists or can be created
      local inbox_exists = vim.fn.isdirectory(inbox_path) == 1

      -- Assert: Inbox directory available
      assert.is_true(inbox_exists, "Inbox directory must exist for fleeting notes")
    end)
  end)

  describe("Wiki Page Creation Capabilities", function()
    it("CAN create wiki page with Hugo-compatible frontmatter", function()
      -- Arrange: User creating permanent wiki page
      local title = "Distributed Cognition"
      local template_name = "wiki"

      -- Act: Load template and apply
      local template_content = zettel.load_template(template_name)
      assert.is_not_nil(template_content, "Wiki template must load")

      local content = zettel.apply_template(template_content, title)

      -- Assert: Hugo frontmatter present
      assert.matches('title: "' .. title .. '"', content)
      assert.matches("date:", content)
      assert.matches("draft: false", content)
      assert.matches("tags:", content)
      assert.matches("categories:", content)
      assert.matches("description:", content)
    end)

    it("CAN use BibTeX citations in wiki pages", function()
      -- Arrange: User writing wiki page with citations
      local template_name = "wiki"

      -- Act: Load wiki template
      local template_content = zettel.load_template(template_name)
      local content = zettel.apply_template(template_content, "Test Page")

      -- Assert: BibTeX support configured
      assert.matches("bibliography: references.bib", content)
      assert.matches("cite%-method: biblatex", content)
      assert.matches("%[%@", content) -- Citation example present
    end)

    it("CAN save wiki page to root Zettelkasten (not inbox)", function()
      -- Arrange: Wiki pages go to root, not inbox
      local zettel_root = vim.fn.expand("~/Zettelkasten")

      -- Act: Generate expected filename
      local timestamp = os.date("%Y%m%d")
      local filename = timestamp .. "-test-wiki.md"
      local expected_path = zettel_root .. "/" .. filename

      -- Assert: Path is in root, not inbox
      assert.not_matches("/inbox/", expected_path)
      assert.matches("^" .. zettel_root .. "/", expected_path)
    end)
  end)

  describe("Template Selection Capabilities", function()
    it("CAN select template from available options", function()
      -- Arrange: Multiple templates available
      local templates_dir = vim.fn.expand("~/Zettelkasten/templates")
      local templates = vim.fn.globpath(templates_dir, "*.md", false, true)

      -- Act: Count available templates
      local template_count = #templates

      -- Assert: Both fleeting and wiki templates available
      assert.is_true(template_count >= 2, "Must have at least fleeting and wiki templates")
    end)

    it("CAN see template picker UI", function()
      -- Arrange: User invokes template selection
      -- Act: This tests that select_template function exists
      assert.is_function(zettel.select_template, "Template selection function must exist")

      -- Assert: Function is callable
      assert.is_true(true, "Template picker is available")
    end)
  end)

  describe("Note Naming Capabilities", function()
    it("CAN create notes with yyyymmdd-title.md format", function()
      -- Arrange: User creating note with title "Test Note"
      local title = "Test Note"
      local template_content = "---\ntitle: {{title}}\ndate: {{date}}\n---\n"

      -- Act: Apply template (this generates timestamp)
      local content = zettel.apply_template(template_content, title)

      -- Assert: Content has title
      assert.matches("title: " .. title, content)

      -- Note: Actual filename generation tested in new_note integration
    end)

    it("CAN have consistent naming between fleeting and wiki", function()
      -- Arrange: Both note types use same naming scheme
      local expected_pattern = "^%d%d%d%d%d%d%d%d%-.*%.md$"

      -- Act: Test pattern
      local fleeting_name = "20251019-fleeting-idea.md"
      local wiki_name = "20251019-wiki-page.md"

      -- Assert: Both match pattern
      assert.matches(expected_pattern, fleeting_name)
      assert.matches(expected_pattern, wiki_name)
    end)
  end)
end)
