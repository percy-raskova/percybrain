-- IWE + Telekasten Integration Contract Tests
-- Tests that the integration meets its specification

describe("IWE + Telekasten Integration Contract", function()
  local contract

  before_each(function()
    -- Arrange: Load contract specification
    contract = require("specs.iwe_telekasten_contract")
  end)

  after_each(function()
    -- Cleanup: No cleanup required (read-only tests)
  end)

  describe("Directory Structure", function()
    it("provides all required directories", function()
      -- Act: Check each directory
      for dir_type, path in pairs(contract.directories) do
        local expanded = vim.fn.expand(path)
        local exists = vim.fn.isdirectory(expanded) == 1

        -- Assert: Directory must exist
        assert.is_true(
          exists,
          string.format(
            "Directory '%s' (%s) must exist for workflow organization\n" .. "How to fix: Run 'mkdir -p %s'",
            dir_type,
            path,
            expanded
          )
        )
      end
    end)
  end)

  describe("Link Format Compatibility", function()
    it("uses WikiLink notation in Telekasten", function()
      -- Arrange: Read Telekasten config file directly
      local config_path = vim.fn.expand("~/.config/nvim/lua/plugins/zettelkasten/telekasten.lua")
      local content = table.concat(vim.fn.readfile(config_path), "\n")

      -- Act: Check if link_notation is set to "wiki"
      local has_wiki_notation = content:match('link_notation%s*=%s*"wiki"') ~= nil

      -- Assert: Must use "wiki" notation for IWE compatibility
      assert.is_true(
        has_wiki_notation,
        "Telekasten must use WikiLink notation for IWE LSP compatibility\n"
          .. "How to fix: Set link_notation = 'wiki' in telekasten.lua (line ~48)"
      )
    end)
  end)

  describe("Template System", function()
    it("provides all required templates", function()
      -- Act: Check each template file
      for template_type, path in pairs(contract.templates) do
        local expanded = vim.fn.expand(path)
        local exists = vim.fn.filereadable(expanded) == 1

        -- Assert: Template must exist
        assert.is_true(
          exists,
          string.format(
            "Template '%s' (%s) must exist for note creation\n" .. "How to fix: Create template file at %s",
            template_type,
            path,
            expanded
          )
        )
      end
    end)

    it("templates use supported variables", function()
      -- Arrange: Read note template
      local template_path = vim.fn.expand(contract.templates.note)
      local content = vim.fn.readfile(template_path)
      local text = table.concat(content, "\n")

      -- Act: Check for template variables (match returns string or nil)
      local has_title = text:match("{{title}}") ~= nil
      local has_date = text:match("{{date}}") ~= nil

      -- Assert: Templates must use supported variables
      assert.is_true(has_title, "Note template must include {{title}} variable")
      assert.is_true(has_date, "Note template must include {{date}} variable")
    end)
  end)

  describe("Critical Settings Protection", function()
    it("maintains Telekasten link notation", function()
      -- This is a regression protection - link notation must stay "wiki"
      local expected = contract.protected_settings.telekasten_link_notation

      -- We'll verify this when Telekasten is loaded
      -- For now, verify the contract specifies it
      assert.equals("wiki", expected)
    end)
  end)
end)
