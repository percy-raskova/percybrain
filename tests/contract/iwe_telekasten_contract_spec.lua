-- IWE Zettelkasten Integration Contract Tests
-- Tests that the integration meets its specification

describe("IWE Zettelkasten Integration Contract", function()
  local contract

  before_each(function()
    -- Arrange: Load contract specification
    contract = require("specs.iwe_zettelkasten_contract")
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
    it("uses markdown link notation in IWE LSP config", function()
      -- Arrange: Read IWE LSP config file directly
      local config_path = vim.fn.expand("~/.config/nvim/lua/plugins/lsp/iwe.lua")
      local content = table.concat(vim.fn.readfile(config_path), "\n")

      -- Act: Check if link_type is set to "markdown"
      local has_markdown_links = content:match('link_type%s*=%s*"markdown"') ~= nil

      -- Assert: Must use "markdown" notation for IWE LSP
      assert.is_true(
        has_markdown_links,
        "IWE LSP must use markdown link notation [note](note.md)\n"
          .. "How to fix: Set link_type = 'markdown' in lua/plugins/lsp/iwe.lua (line ~24)"
      )
    end)

    it("does NOT use WikiLink notation", function()
      -- Arrange: Read IWE LSP config file
      local config_path = vim.fn.expand("~/.config/nvim/lua/plugins/lsp/iwe.lua")
      local content = table.concat(vim.fn.readfile(config_path), "\n")

      -- Act: Check that WikiLink is NOT configured
      local has_wikilink = content:match('link_type%s*=%s*"WikiLink"') ~= nil

      -- Assert: Must NOT use WikiLink notation (old Telekasten format)
      assert.is_false(
        has_wikilink,
        "IWE LSP must NOT use WikiLink notation [[note]]\n"
          .. "How to fix: Change link_type from 'WikiLink' to 'markdown' in lua/plugins/lsp/iwe.lua"
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
    it("maintains IWE link type as markdown", function()
      -- This is a regression protection - link type must stay "markdown"
      local expected = contract.protected_settings.iwe_link_type

      -- Verify the contract specifies markdown links
      assert.equals("markdown", expected, "IWE must use markdown link format [note](note.md)")
    end)

    it("specifies correct LSP server name", function()
      local expected = contract.protected_settings.lsp_server_name

      -- Verify LSP server name
      assert.equals("iwes", expected, "IWE LSP server must be named 'iwes'")
    end)

    it("specifies correct CLI command name", function()
      local expected = contract.protected_settings.cli_command_name

      -- Verify CLI command name
      assert.equals("iwe", expected, "IWE CLI command must be named 'iwe'")
    end)
  end)

  describe("Required Tools", function()
    it("IWE LSP server (iwes) is installed", function()
      -- Act: Check if iwes command exists
      local has_iwes = vim.fn.executable("iwes") == 1

      -- Assert: iwes must be available
      assert.is_true(
        has_iwes,
        "IWE LSP server 'iwes' must be installed\n"
          .. "How to fix: cargo install iwe (installs both iwe and iwes binaries)"
      )
    end)

    it("IWE CLI (iwe) is installed", function()
      -- Act: Check if iwe command exists
      local has_iwe = vim.fn.executable("iwe") == 1

      -- Assert: iwe must be available
      assert.is_true(
        has_iwe,
        "IWE CLI 'iwe' must be installed\n" .. "How to fix: cargo install iwe (installs both iwe and iwes binaries)"
      )
    end)
  end)
end)
