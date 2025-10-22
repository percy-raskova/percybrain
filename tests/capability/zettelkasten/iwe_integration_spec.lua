-- IWE + Telekasten Integration Capability Tests
-- Tests what users CAN DO with the integrated system

describe("IWE + Telekasten Integration Capabilities", function()
  local test_dir = "/tmp/test-zettelkasten"

  before_each(function()
    -- Arrange: Create test directory
    vim.fn.mkdir(test_dir, "p")
  end)

  after_each(function()
    -- Cleanup: Remove test directory
    vim.fn.delete(test_dir, "rf")
  end)

  -- ========================================================================
  -- WORKFLOW 1: Create and Organize Notes
  -- ========================================================================

  describe("User CAN create notes with templates", function()
    it("CAN create new zettel with template variables", function()
      -- Arrange: Verify template exists
      local template = vim.fn.expand("~/Zettelkasten/templates/note.md")
      local has_template = vim.fn.filereadable(template) == 1

      -- Assert: Template must be available
      assert.is_true(
        has_template,
        "Note template must exist for creation workflow\n"
          .. "How to fix: Template should be at ~/Zettelkasten/templates/note.md"
      )
    end)

    it("CAN create daily notes with date formatting", function()
      -- Arrange: Verify daily template exists
      local template = vim.fn.expand("~/Zettelkasten/templates/daily.md")
      local has_template = vim.fn.filereadable(template) == 1

      -- Assert: Daily template must be available
      assert.is_true(
        has_template,
        "Daily template must exist for daily workflow\n"
          .. "How to fix: Template should be at ~/Zettelkasten/templates/daily.md"
      )

      -- Act: Check template content
      if has_template then
        local content = table.concat(vim.fn.readfile(template), "\n")

        -- Assert: Must use date variables
        assert.is_true(content:match("{{date}}") ~= nil, "Daily template should use {{date}} variable")
      end
    end)

    it("CAN create literature notes with citation format", function()
      -- Arrange: Verify source template exists
      local template = vim.fn.expand("~/Zettelkasten/templates/source.md")
      local has_template = vim.fn.filereadable(template) == 1

      -- Assert: Source template must be available
      assert.is_true(
        has_template,
        "Source template must exist for literature notes\n"
          .. "How to fix: Template should be at ~/Zettelkasten/templates/source.md"
      )

      -- Act: Check template structure
      if has_template then
        local content = table.concat(vim.fn.readfile(template), "\n")

        -- Assert: Must have citation section
        assert.is_true(content:match("## Citation") ~= nil, "Source template should include Citation section")
      end
    end)

    it("CAN create Maps of Content for navigation", function()
      -- Arrange: Verify MOC template exists
      local template = vim.fn.expand("~/Zettelkasten/templates/moc.md")
      local has_template = vim.fn.filereadable(template) == 1

      -- Assert: MOC template must be available
      assert.is_true(
        has_template,
        "MOC template must exist for navigation structure\n"
          .. "How to fix: Template should be at ~/Zettelkasten/templates/moc.md"
      )

      -- Act: Check template structure
      if has_template then
        local content = table.concat(vim.fn.readfile(template), "\n")

        -- Assert: Must have overview and topics
        assert.is_true(content:match("## Overview") ~= nil, "MOC template should include Overview section")
        assert.is_true(content:match("## Core Concepts") ~= nil, "MOC template should include Core Concepts section")
      end
    end)
  end)

  -- ========================================================================
  -- WORKFLOW 2: WikiLink Navigation (Telekasten + IWE)
  -- ========================================================================

  describe("User CAN navigate with WikiLinks", function()
    it("WORKS with wiki notation [[note]]", function()
      -- This test verifies link format compatibility
      -- When IWE is fully configured, we'll test actual navigation

      -- Arrange: Check contract specification
      local contract = require("specs.iwe_telekasten_contract")

      -- Assert: Link format must be wiki
      assert.equals(
        "wiki",
        contract.link_format.notation,
        "System must use WikiLink [[note]] format for IWE compatibility"
      )
    end)
  end)

  -- ========================================================================
  -- WORKFLOW 3: Extract and Inline (IWE Core Features)
  -- ========================================================================

  describe("User CAN extract sections to new notes", function()
    it("PREPARES for IWE extract workflow", function()
      -- This test will validate IWE extract once configured
      -- For now, verify the workflow directory structure exists

      -- Arrange: Check zettel directory
      local zettel_dir = vim.fn.expand("~/Zettelkasten/zettel")
      local exists = vim.fn.isdirectory(zettel_dir) == 1

      -- Assert: Extract destination must exist
      assert.is_true(
        exists,
        "Zettel directory must exist for IWE extract workflow\n"
          .. "How to fix: Directory should be at ~/Zettelkasten/zettel/"
      )
    end)
  end)

  describe("User CAN inline notes for synthesis", function()
    it("PREPARES for IWE inline workflow", function()
      -- This test will validate IWE inline once configured
      -- For now, verify drafts directory exists for synthesis work

      -- Arrange: Check drafts directory
      local drafts_dir = vim.fn.expand("~/Zettelkasten/drafts")
      local exists = vim.fn.isdirectory(drafts_dir) == 1

      -- Assert: Synthesis destination must exist
      assert.is_true(
        exists,
        "Drafts directory must exist for synthesis workflow\n"
          .. "How to fix: Directory should be at ~/Zettelkasten/drafts/"
      )
    end)
  end)

  -- ========================================================================
  -- WORKFLOW 4: Template Variable Substitution
  -- ========================================================================

  describe("Templates WORK with variable substitution", function()
    it("WORKS with {{title}} variable", function()
      -- Arrange: Read note template
      local template = vim.fn.expand("~/Zettelkasten/templates/note.md")
      if vim.fn.filereadable(template) ~= 1 then
        pending("Note template not found")
        return
      end

      local content = table.concat(vim.fn.readfile(template), "\n")

      -- Assert: Template uses title variable correctly
      assert.is_true(content:match("{{title}}") ~= nil, "Template must use {{title}} for Telekasten substitution")
    end)

    it("WORKS with {{date}} variable", function()
      -- Arrange: Read note template
      local template = vim.fn.expand("~/Zettelkasten/templates/note.md")
      if vim.fn.filereadable(template) ~= 1 then
        pending("Note template not found")
        return
      end

      local content = table.concat(vim.fn.readfile(template), "\n")

      -- Assert: Template uses date variable correctly
      assert.is_true(content:match("{{date}}") ~= nil, "Template must use {{date}} for Telekasten substitution")
    end)
  end)
end)
