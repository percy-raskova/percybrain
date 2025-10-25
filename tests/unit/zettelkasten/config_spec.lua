-- Zettelkasten Configuration Unit Tests
-- Tests for core configuration, setup, and template system

-- Local helper function for directory validation
local function directory_exists(path)
  return vim.fn.isdirectory(path) == 1
end

describe("Zettelkasten Configuration", function()
  local zettelkasten
  local test_home
  local original_expand

  before_each(function()
    -- Arrange: Mock vim.fn.expand to use test directory
    test_home = vim.fn.tempname()
    original_expand = vim.fn.expand

    vim.fn.expand = function(path)
      if path:match("^~/Zettelkasten") then
        return test_home .. path:gsub("^~/Zettelkasten", "")
      end
      return original_expand(path)
    end

    -- Load module fresh each time
    package.loaded["config.zettelkasten"] = nil
    zettelkasten = require("config.zettelkasten")
  end)

  after_each(function()
    -- Clean up test directory
    if vim.fn.isdirectory(test_home) == 1 then
      vim.fn.delete(test_home, "rf")
    end

    -- Restore original vim.fn.expand
    vim.fn.expand = original_expand
  end)

  describe("Configuration Defaults", function()
    it("has correct default paths", function()
      -- Arrange: Configuration loaded in before_each

      -- Act: Read config values
      local config = zettelkasten.config

      -- Assert: Paths are set correctly
      assert.is_not_nil(config.home)
      assert.is_not_nil(config.inbox)
      assert.is_not_nil(config.daily)
      assert.is_not_nil(config.templates)
      assert.is_not_nil(config.export_path)
    end)

    it("inbox is subdirectory of home", function()
      -- Arrange: Config already loaded

      -- Act: Get paths
      local home = zettelkasten.config.home
      local inbox = zettelkasten.config.inbox

      -- Assert: Inbox is under home directory
      assert.is_true(inbox:match("^" .. vim.pesc(home)) ~= nil)
    end)

    it("daily is subdirectory of home", function()
      -- Arrange: Config already loaded

      -- Act: Get paths
      local home = zettelkasten.config.home
      local daily = zettelkasten.config.daily

      -- Assert: Daily is under home directory
      assert.is_true(daily:match("^" .. vim.pesc(home)) ~= nil)
    end)

    it("templates is subdirectory of home", function()
      -- Arrange: Config already loaded

      -- Act: Get paths
      local home = zettelkasten.config.home
      local templates = zettelkasten.config.templates

      -- Assert: Templates is under home directory
      assert.is_true(templates:match("^" .. vim.pesc(home)) ~= nil)
    end)
  end)

  describe("Setup Function", function()
    it("creates required directories", function()
      -- Arrange: Clean test environment
      local dirs = {
        zettelkasten.config.home,
        zettelkasten.config.inbox,
        zettelkasten.config.daily,
        zettelkasten.config.templates,
      }

      -- Act: Run setup
      zettelkasten.setup()

      -- Assert: All directories exist
      for _, dir in ipairs(dirs) do
        assert.is_true(directory_exists(dir))
      end
    end)

    it("does not fail if directories already exist", function()
      -- Arrange: Create directories manually
      zettelkasten.setup() -- First setup

      -- Act: Run setup again
      local success = pcall(zettelkasten.setup)

      -- Assert: No error thrown
      assert.is_true(success)
    end)

    it("sets up user commands", function()
      -- Arrange: Setup not yet run

      -- Act: Run setup
      zettelkasten.setup()

      -- Assert: Commands exist
      local commands = vim.api.nvim_get_commands({})
      assert.is_not_nil(commands.PercyNew)
      assert.is_not_nil(commands.PercyDaily)
      assert.is_not_nil(commands.PercyInbox)
      assert.is_not_nil(commands.PercyPublish)
      assert.is_not_nil(commands.PercyOrphans)
      assert.is_not_nil(commands.PercyHubs)
    end)
  end)

  describe("Template System", function()
    local template_path

    before_each(function()
      -- Arrange: Create template directory and sample template
      zettelkasten.setup()
      template_path = zettelkasten.config.templates .. "/note.md"
      local template_content = {
        "---",
        "title: {{title}}",
        "date: {{date}}",
        "tags: []",
        "---",
        "",
        "# {{title}}",
        "",
        "Content goes here.",
      }
      vim.fn.writefile(template_content, template_path)
    end)

    it("loads existing template", function()
      -- Arrange: Template created in before_each

      -- Act: Load template
      local content = zettelkasten.load_template("note")

      -- Assert: Content loaded correctly
      assert.is_not_nil(content)
      assert.is_true(content:match("{{title}}") ~= nil)
      assert.is_true(content:match("{{date}}") ~= nil)
    end)

    it("returns nil for non-existent template", function()
      -- Arrange: No template named "nonexistent"

      -- Act: Try to load non-existent template
      local content = zettelkasten.load_template("nonexistent")

      -- Assert: Returns nil
      assert.is_nil(content)
    end)

    it("applies template variables correctly", function()
      -- Arrange: Template content with variables
      local template = "# {{title}}\n\nDate: {{date}}\n\nTimestamp: {{timestamp}}"
      local title = "Test Note"

      -- Act: Apply template
      local result = zettelkasten.apply_template(template, title)

      -- Assert: Variables replaced
      assert.is_true(result:match(title) ~= nil)
      assert.is_true(result:match("%d%d%d%d%-%d%d%-%d%d") ~= nil) -- Date pattern
      assert.is_true(result:match("%d%d%d%d%d%d%d%d%d%d%d%d") ~= nil) -- Timestamp pattern
    end)
  end)
end)
