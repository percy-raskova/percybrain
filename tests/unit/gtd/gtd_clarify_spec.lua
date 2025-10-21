--- GTD Clarify Module Tests
--- Test suite for GTD clarify workflow and inbox processing
--- @module tests.unit.gtd.gtd_clarify_spec

local helpers = require("tests.helpers.gtd_test_helpers")

describe("GTD Clarify Module", function()
  before_each(function()
    -- Arrange: Clean state before each test
    helpers.cleanup_gtd_test_data()
    helpers.clear_gtd_cache()

    -- Setup GTD structure for clarify tests
    local gtd = require("percybrain.gtd")
    gtd.setup()
  end)

  after_each(function()
    -- Cleanup: Remove test data after each test
    helpers.cleanup_gtd_test_data()
    helpers.clear_gtd_cache()
  end)

  describe("Next Actions", function()
    it("should route actionable item to next-actions.md without context", function()
      -- Arrange
      local clarify = require("percybrain.gtd.clarify")
      helpers.add_inbox_item("Buy groceries")

      local decision = {
        actionable = true,
        action_type = "next_action",
        context = nil,
      }

      -- Act
      clarify.clarify_item("Buy groceries", decision)

      -- Assert
      local next_actions_path = helpers.gtd_path("next-actions.md")
      assert.is_true(helpers.file_exists(next_actions_path), "next-actions.md should exist")
      assert.is_true(
        helpers.file_contains_pattern(next_actions_path, "Buy groceries"),
        "next-actions.md should contain item"
      )

      -- Verify item removed from inbox
      local inbox_path = helpers.gtd_path("inbox.md")
      local inbox_content = helpers.read_file_content(inbox_path)
      assert.is_nil(inbox_content:match("Buy groceries"), "Item should be removed from inbox")
    end)

    it("should route actionable item with context to contexts/home.md", function()
      -- Arrange
      local clarify = require("percybrain.gtd.clarify")
      helpers.add_inbox_item("Fix leaky faucet")

      local decision = {
        actionable = true,
        action_type = "next_action",
        context = "home",
      }

      -- Act
      clarify.clarify_item("Fix leaky faucet", decision)

      -- Assert
      local home_context_path = helpers.gtd_path("contexts/home.md")
      assert.is_true(helpers.file_exists(home_context_path), "contexts/home.md should exist")
      assert.is_true(
        helpers.file_contains_pattern(home_context_path, "Fix leaky faucet"),
        "contexts/home.md should contain item"
      )

      -- Verify item removed from inbox
      local inbox_path = helpers.gtd_path("inbox.md")
      local inbox_content = helpers.read_file_content(inbox_path)
      assert.is_nil(inbox_content:match("Fix leaky faucet"), "Item should be removed from inbox")
    end)

    it("should remove item from inbox after routing to next-actions", function()
      -- Arrange
      local clarify = require("percybrain.gtd.clarify")
      helpers.add_inbox_item("Call dentist")

      local decision = {
        actionable = true,
        action_type = "next_action",
      }

      -- Act
      clarify.clarify_item("Call dentist", decision)

      -- Assert
      local inbox_path = helpers.gtd_path("inbox.md")
      local inbox_content = helpers.read_file_content(inbox_path)
      assert.is_nil(inbox_content:match("Call dentist"), "Item should be removed from inbox")
    end)
  end)

  describe("Projects", function()
    it("should route multi-step item to projects.md with outcome", function()
      -- Arrange
      local clarify = require("percybrain.gtd.clarify")
      helpers.add_inbox_item("Website redesign")

      local decision = {
        actionable = true,
        action_type = "project",
        project_outcome = "Launch new company website with improved UX",
      }

      -- Act
      clarify.clarify_item("Website redesign", decision)

      -- Assert
      local projects_path = helpers.gtd_path("projects.md")
      assert.is_true(helpers.file_exists(projects_path), "projects.md should exist")
      assert.is_true(
        helpers.file_contains_pattern(projects_path, "Website redesign"),
        "projects.md should contain project title"
      )
      assert.is_true(
        helpers.file_contains_pattern(projects_path, "Launch new company website"),
        "projects.md should contain outcome"
      )

      -- Verify item removed from inbox
      local inbox_path = helpers.gtd_path("inbox.md")
      local inbox_content = helpers.read_file_content(inbox_path)
      assert.is_nil(inbox_content:match("Website redesign"), "Item should be removed from inbox")
    end)
  end)

  describe("Waiting For", function()
    it("should route delegated item to waiting-for.md with person", function()
      -- Arrange
      local clarify = require("percybrain.gtd.clarify")
      helpers.add_inbox_item("Feedback on proposal")

      local decision = {
        actionable = true,
        action_type = "waiting_for",
        waiting_for_who = "Sarah",
      }

      -- Act
      clarify.clarify_item("Feedback on proposal", decision)

      -- Assert
      local waiting_path = helpers.gtd_path("waiting-for.md")
      assert.is_true(helpers.file_exists(waiting_path), "waiting-for.md should exist")
      assert.is_true(helpers.file_contains_pattern(waiting_path, "Sarah"), "waiting-for.md should contain person")
      assert.is_true(
        helpers.file_contains_pattern(waiting_path, "Feedback on proposal"),
        "waiting-for.md should contain item"
      )

      -- Verify item removed from inbox
      local inbox_path = helpers.gtd_path("inbox.md")
      local inbox_content = helpers.read_file_content(inbox_path)
      assert.is_nil(inbox_content:match("Feedback on proposal"), "Item should be removed from inbox")
    end)
  end)

  describe("Non-Actionable Items", function()
    it("should route reference material to reference.md", function()
      -- Arrange
      local clarify = require("percybrain.gtd.clarify")
      helpers.add_inbox_item("Interesting article on productivity")

      local decision = {
        actionable = false,
        route = "reference",
      }

      -- Act
      clarify.clarify_item("Interesting article on productivity", decision)

      -- Assert
      local reference_path = helpers.gtd_path("reference.md")
      assert.is_true(helpers.file_exists(reference_path), "reference.md should exist")
      assert.is_true(
        helpers.file_contains_pattern(reference_path, "Interesting article on productivity"),
        "reference.md should contain item"
      )

      -- Verify item removed from inbox
      local inbox_path = helpers.gtd_path("inbox.md")
      local inbox_content = helpers.read_file_content(inbox_path)
      assert.is_nil(inbox_content:match("Interesting article on productivity"), "Item should be removed from inbox")
    end)

    it("should route future idea to someday-maybe.md", function()
      -- Arrange
      local clarify = require("percybrain.gtd.clarify")
      helpers.add_inbox_item("Learn Spanish")

      local decision = {
        actionable = false,
        route = "someday_maybe",
      }

      -- Act
      clarify.clarify_item("Learn Spanish", decision)

      -- Assert
      local someday_path = helpers.gtd_path("someday-maybe.md")
      assert.is_true(helpers.file_exists(someday_path), "someday-maybe.md should exist")
      assert.is_true(
        helpers.file_contains_pattern(someday_path, "Learn Spanish"),
        "someday-maybe.md should contain item"
      )

      -- Verify item removed from inbox
      local inbox_path = helpers.gtd_path("inbox.md")
      local inbox_content = helpers.read_file_content(inbox_path)
      assert.is_nil(inbox_content:match("Learn Spanish"), "Item should be removed from inbox")
    end)

    it("should delete trash items without routing to any file", function()
      -- Arrange
      local clarify = require("percybrain.gtd.clarify")
      helpers.add_inbox_item("Spam email")

      local decision = {
        actionable = false,
        route = "trash",
      }

      -- Act
      clarify.clarify_item("Spam email", decision)

      -- Assert: Item should not appear in any GTD file
      local files_to_check = {
        "next-actions.md",
        "projects.md",
        "waiting-for.md",
        "reference.md",
        "someday-maybe.md",
      }

      for _, file in ipairs(files_to_check) do
        local file_path = helpers.gtd_path(file)
        if helpers.file_exists(file_path) then
          local content = helpers.read_file_content(file_path)
          assert.is_nil(content:match("Spam email"), file .. " should not contain trash item")
        end
      end

      -- Verify item removed from inbox
      local inbox_path = helpers.gtd_path("inbox.md")
      local inbox_content = helpers.read_file_content(inbox_path)
      assert.is_nil(inbox_content:match("Spam email"), "Item should be removed from inbox")
    end)
  end)

  describe("Inbox Management", function()
    it("should get all inbox items as array", function()
      -- Arrange
      local clarify = require("percybrain.gtd.clarify")
      helpers.add_inbox_item("First task")
      helpers.add_inbox_item("Second task")
      helpers.add_inbox_item("Third task")

      -- Act
      local items = clarify.get_inbox_items()

      -- Assert
      assert.is_not_nil(items, "Should return items array")
      assert.equals(3, #items, "Should return 3 items")

      -- Check if any item contains "First task"
      local found_first_task = false
      for _, item in ipairs(items) do
        if item:match("First task") then
          found_first_task = true
          break
        end
      end
      assert.is_true(found_first_task, "Should contain first task")
    end)

    it("should remove specific item from inbox", function()
      -- Arrange
      local clarify = require("percybrain.gtd.clarify")
      helpers.add_inbox_item("Keep this")
      helpers.add_inbox_item("Remove this")
      helpers.add_inbox_item("Keep that")

      -- Act
      clarify.remove_inbox_item("Remove this")

      -- Assert
      local inbox_path = helpers.gtd_path("inbox.md")
      local inbox_content = helpers.read_file_content(inbox_path)
      assert.is_nil(inbox_content:match("Remove this"), "Specific item should be removed")
      assert.is_not_nil(inbox_content:match("Keep this"), "Other items should remain")
      assert.is_not_nil(inbox_content:match("Keep that"), "Other items should remain")
    end)

    it("should count remaining inbox items", function()
      -- Arrange
      local clarify = require("percybrain.gtd.clarify")
      helpers.add_inbox_item("First task")
      helpers.add_inbox_item("Second task")

      -- Act
      local count = clarify.inbox_count()

      -- Assert
      assert.equals(2, count, "Should return correct count")
    end)
  end)
end)
