-- IWE Zettelkasten Integration Capability Tests
-- Tests what users CAN DO with the IWE-based system

describe("IWE Zettelkasten Integration Capabilities", function()
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
  -- WORKFLOW 1: Create and Organize Notes (IWE CLI + Templates)
  -- ========================================================================

  describe("User CAN create notes with IWE CLI", function()
    it("CAN create new zettel using IWE CLI", function()
      -- Arrange: Verify IWE CLI is available
      local has_iwe = vim.fn.executable("iwe") == 1

      -- Assert: IWE CLI must be installed
      assert.is_true(
        has_iwe,
        "IWE CLI must be installed for note creation workflow\n" .. "How to fix: cargo install iwe"
      )
    end)

    it("CAN create notes with template variables", function()
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
  -- WORKFLOW 2: Markdown Link Navigation (IWE LSP)
  -- ========================================================================

  describe("User CAN navigate with markdown links", function()
    it("WORKS with markdown notation [note](note.md)", function()
      -- Arrange: Check contract specification
      local contract = require("specs.iwe_zettelkasten_contract")

      -- Assert: Link format must be markdown
      assert.equals(
        "markdown",
        contract.link_format.notation,
        "System must use markdown link [note](note.md) format for IWE LSP compatibility"
      )
    end)

    it("IWE LSP server is configured for markdown links", function()
      -- Arrange: Read IWE LSP config
      local config_path = vim.fn.expand("~/.config/nvim/lua/plugins/lsp/iwe.lua")
      local content = table.concat(vim.fn.readfile(config_path), "\n")

      -- Act: Check link_type configuration
      local has_markdown = content:match('link_type%s*=%s*"markdown"') ~= nil

      -- Assert: Must be configured for markdown links
      assert.is_true(
        has_markdown,
        "IWE LSP must be configured with link_type = 'markdown'\n"
          .. "How to fix: Update lua/plugins/lsp/iwe.lua line ~24"
      )
    end)

    it("does NOT use WikiLink notation (Telekasten legacy)", function()
      -- Arrange: Read IWE LSP config
      local config_path = vim.fn.expand("~/.config/nvim/lua/plugins/lsp/iwe.lua")
      local content = table.concat(vim.fn.readfile(config_path), "\n")

      -- Act: Verify WikiLink is NOT used
      local has_wikilink = content:match('link_type%s*=%s*"WikiLink"') ~= nil

      -- Assert: Must NOT use old WikiLink format
      assert.is_false(
        has_wikilink,
        "IWE LSP must NOT use WikiLink [[note]] format\n"
          .. "How to fix: Change link_type from 'WikiLink' to 'markdown' in lua/plugins/lsp/iwe.lua"
      )
    end)
  end)

  -- ========================================================================
  -- WORKFLOW 3: Extract and Inline (IWE Core Features)
  -- ========================================================================

  describe("User CAN extract sections to new notes", function()
    it("IWE LSP server is available for extract operations", function()
      -- Arrange: Check for iwes binary
      local has_iwes = vim.fn.executable("iwes") == 1

      -- Assert: LSP server must be installed
      assert.is_true(
        has_iwes,
        "IWE LSP server must be installed for extract workflow\n"
          .. "How to fix: cargo install iwe (installs both iwe and iwes)"
      )
    end)

    it("PREPARES extract destination directory", function()
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

    it("extract creates markdown links (not WikiLinks)", function()
      -- Arrange: Check contract specification
      local contract = require("specs.iwe_zettelkasten_contract")

      -- Assert: Extract must create markdown links
      assert.has_match(
        "markdown_link",
        contract.capabilities[6], -- "markdown_link_navigation"
        "Extract operation must create markdown links [note](note.md)"
      )
    end)
  end)

  describe("User CAN inline notes for synthesis", function()
    it("IWE LSP server supports inline operations", function()
      -- Arrange: Verify LSP server is available
      local has_iwes = vim.fn.executable("iwes") == 1

      -- Assert: LSP server required for inline
      assert.is_true(
        has_iwes,
        "IWE LSP server must be installed for inline workflow\n" .. "How to fix: cargo install iwe"
      )
    end)

    it("PREPARES synthesis workspace (drafts directory)", function()
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
      assert.is_true(content:match("{{title}}") ~= nil, "Template must use {{title}} for variable substitution")
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
      assert.is_true(content:match("{{date}}") ~= nil, "Template must use {{date}} for variable substitution")
    end)
  end)

  -- ========================================================================
  -- WORKFLOW 5: LSP Navigation and Workspace Symbols
  -- ========================================================================

  describe("User CAN use LSP navigation features", function()
    it("IWE LSP provides go-to-definition support", function()
      -- Arrange: Check contract capabilities
      local contract = require("specs.iwe_zettelkasten_contract")

      -- Assert: Must support navigate_to_definition
      assert.has_match(
        "navigate_to_definition",
        table.concat(contract.capabilities, ","),
        "IWE LSP must provide go-to-definition for markdown links"
      )
    end)

    it("IWE LSP provides workspace symbols search", function()
      -- Arrange: Check contract capabilities
      local contract = require("specs.iwe_zettelkasten_contract")

      -- Assert: Must support workspace_symbols_search
      assert.has_match(
        "workspace_symbols_search",
        table.concat(contract.capabilities, ","),
        "IWE LSP must provide workspace symbols for finding notes"
      )
    end)

    it("IWE LSP provides safe rename with link updates", function()
      -- Arrange: Check contract capabilities
      local contract = require("specs.iwe_zettelkasten_contract")

      -- Assert: Must support safe_rename_with_links
      assert.has_match(
        "safe_rename_with_links",
        table.concat(contract.capabilities, ","),
        "IWE LSP must provide safe rename that updates all links"
      )
    end)
  end)
end)
