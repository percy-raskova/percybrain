--- GTD Initialization Tests
--- Test suite for GTD system setup and base file creation
--- @module tests.unit.gtd.gtd_init_spec

local helpers = require("tests.helpers.gtd_test_helpers")

describe("GTD Initialization", function()
  before_each(function()
    -- Arrange: Clean state before each test
    helpers.cleanup_gtd_test_data()
    helpers.clear_gtd_cache()
  end)

  after_each(function()
    -- Cleanup: Remove test data after each test
    helpers.cleanup_gtd_test_data()
    helpers.clear_gtd_cache()
  end)

  describe("GTD Directory Structure", function()
    it("should create GTD root directory when setup is called", function()
      -- Arrange
      local gtd_root = helpers.gtd_root()
      assert.is_false(helpers.dir_exists(gtd_root), "GTD root should not exist before setup")

      -- Act
      local gtd = require("percybrain.gtd")
      gtd.setup()

      -- Assert
      assert.is_true(helpers.dir_exists(gtd_root), "GTD root directory should be created")
    end)

    it("should create all required GTD subdirectories", function()
      -- Arrange
      local expected_dirs = helpers.get_gtd_directories()

      -- Act
      local gtd = require("percybrain.gtd")
      gtd.setup()

      -- Assert
      for _, dir in ipairs(expected_dirs) do
        local dir_path = helpers.gtd_path(dir)
        assert.is_true(helpers.dir_exists(dir_path), string.format("Directory '%s' should be created", dir))
      end
    end)

    it("should not fail if GTD directories already exist", function()
      -- Arrange: Create directories manually
      vim.fn.mkdir(helpers.gtd_root(), "p")

      -- Act & Assert: Should not error on re-setup
      local gtd = require("percybrain.gtd")
      assert.has_no.errors(function()
        gtd.setup()
      end)
    end)
  end)

  describe("GTD Base Files", function()
    it("should create all GTD base files with headers", function()
      -- Arrange
      local expected_files = helpers.get_base_files()

      -- Act
      local gtd = require("percybrain.gtd")
      gtd.setup()

      -- Assert
      for _, file in ipairs(expected_files) do
        local file_path = helpers.gtd_path(file)
        assert.is_true(helpers.file_exists(file_path), string.format("File '%s' should be created", file))

        -- Verify file has proper markdown header
        local content = helpers.read_file_content(file_path)
        assert.is_true(content:len() > 0, string.format("File '%s' should not be empty", file))
        assert.is_not_nil(content:match("^#"), string.format("File '%s' should start with markdown header", file))
      end
    end)

    it("should create inbox.md with GTD inbox header", function()
      -- Arrange
      local inbox_path = helpers.gtd_path("inbox.md")

      -- Act
      local gtd = require("percybrain.gtd")
      gtd.setup()

      -- Assert
      assert.is_true(helpers.file_exists(inbox_path), "inbox.md should be created")
      assert.is_true(helpers.file_contains_pattern(inbox_path, "# 📥 Inbox"), "inbox.md should have GTD inbox header")
    end)

    it("should create next-actions.md with proper structure", function()
      -- Arrange
      local next_actions_path = helpers.gtd_path("next-actions.md")

      -- Act
      local gtd = require("percybrain.gtd")
      gtd.setup()

      -- Assert
      assert.is_true(helpers.file_exists(next_actions_path), "next-actions.md should be created")
      assert.is_true(
        helpers.file_contains_pattern(next_actions_path, "# ⚡ Next Actions"),
        "next-actions.md should have proper header"
      )
    end)

    it("should not overwrite existing base files", function()
      -- Arrange: Create GTD structure and add custom content
      local gtd = require("percybrain.gtd")
      gtd.setup()

      local inbox_path = helpers.gtd_path("inbox.md")
      local custom_content = "# 📥 Inbox\n\n- Custom task\n"
      local lines = vim.split(custom_content, "\n", { plain = true })
      vim.fn.writefile(lines, inbox_path)

      -- Act: Re-run setup
      gtd.setup()

      -- Assert: Custom content should be preserved
      local content = helpers.read_file_content(inbox_path)
      assert.is_not_nil(content:match("Custom task"), "Existing content should be preserved")
    end)
  end)

  describe("GTD Context Files", function()
    it("should create all context files", function()
      -- Arrange
      local expected_contexts = helpers.get_context_files()

      -- Act
      local gtd = require("percybrain.gtd")
      gtd.setup()

      -- Assert
      for _, context_file in ipairs(expected_contexts) do
        local context_path = helpers.gtd_path(context_file)
        assert.is_true(
          helpers.file_exists(context_path),
          string.format("Context file '%s' should be created", context_file)
        )
      end
    end)

    it("should create home context with proper header", function()
      -- Arrange
      local home_context_path = helpers.gtd_path("contexts/home.md")

      -- Act
      local gtd = require("percybrain.gtd")
      gtd.setup()

      -- Assert
      assert.is_true(helpers.file_exists(home_context_path), "home context should be created")
      assert.is_true(
        helpers.file_contains_pattern(home_context_path, "# 🏠 @home"),
        "home context should have proper header"
      )
    end)
  end)

  describe("GTD Module API", function()
    it("should expose setup function", function()
      -- Arrange & Act
      local gtd = require("percybrain.gtd")

      -- Assert
      assert.is_function(gtd.setup, "GTD module should expose setup function")
    end)

    it("should expose get_inbox_path function", function()
      -- Arrange & Act
      local gtd = require("percybrain.gtd")

      -- Assert
      assert.is_function(gtd.get_inbox_path, "GTD module should expose get_inbox_path function")
    end)

    it("should return correct inbox path", function()
      -- Arrange
      local gtd = require("percybrain.gtd")
      local expected_path = helpers.gtd_path("inbox.md")

      -- Act
      local inbox_path = gtd.get_inbox_path()

      -- Assert
      assert.equals(expected_path, inbox_path, "get_inbox_path should return correct path")
    end)
  end)
end)
