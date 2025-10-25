--- GTD Clarify UI Module Tests
--- Test suite for GTD clarify UI and interactive workflow
--- @module tests.unit.gtd.gtd_clarify_ui_spec

local helpers = require("tests.helpers.gtd_test_helpers")

describe("GTD Clarify UI Module", function()
  before_each(function()
    -- Arrange: Clean state before each test
    helpers.cleanup_gtd_test_data()
    helpers.clear_gtd_cache()

    -- Setup GTD structure for UI tests
    local gtd = require("lib.gtd")
    gtd.setup()
  end)

  after_each(function()
    -- Cleanup: Remove test data after each test
    helpers.cleanup_gtd_test_data()
    helpers.clear_gtd_cache()
  end)

  describe("Decision Building", function()
    it("should build next action decision without context", function()
      -- Arrange
      local clarify_ui = require("lib.gtd.clarify_ui")
      local prompts = {
        actionable = "y",
        action_type = "1", -- next_action
        context = "", -- no context
      }

      -- Act
      local decision = clarify_ui._build_decision_from_prompts(prompts)

      -- Assert
      assert.is_true(decision.actionable, "Should be actionable")
      assert.equals("next_action", decision.action_type, "Should be next_action")
      assert.is_nil(decision.context, "Should have no context")
    end)

    it("should build next action decision with context", function()
      -- Arrange
      local clarify_ui = require("lib.gtd.clarify_ui")
      local prompts = {
        actionable = "y",
        action_type = "1", -- next_action
        context = "home",
      }

      -- Act
      local decision = clarify_ui._build_decision_from_prompts(prompts)

      -- Assert
      assert.is_true(decision.actionable, "Should be actionable")
      assert.equals("next_action", decision.action_type, "Should be next_action")
      assert.equals("home", decision.context, "Should have home context")
    end)

    it("should build project decision with outcome", function()
      -- Arrange
      local clarify_ui = require("lib.gtd.clarify_ui")
      local prompts = {
        actionable = "y",
        action_type = "2", -- project
        project_outcome = "Launch new website with improved UX",
      }

      -- Act
      local decision = clarify_ui._build_decision_from_prompts(prompts)

      -- Assert
      assert.is_true(decision.actionable, "Should be actionable")
      assert.equals("project", decision.action_type, "Should be project")
      assert.equals("Launch new website with improved UX", decision.project_outcome, "Should have outcome")
    end)

    it("should build waiting-for decision with person", function()
      -- Arrange
      local clarify_ui = require("lib.gtd.clarify_ui")
      local prompts = {
        actionable = "y",
        action_type = "3", -- waiting_for
        waiting_for_who = "Sarah",
      }

      -- Act
      local decision = clarify_ui._build_decision_from_prompts(prompts)

      -- Assert
      assert.is_true(decision.actionable, "Should be actionable")
      assert.equals("waiting_for", decision.action_type, "Should be waiting_for")
      assert.equals("Sarah", decision.waiting_for_who, "Should have person")
    end)

    it("should build reference decision for non-actionable", function()
      -- Arrange
      local clarify_ui = require("lib.gtd.clarify_ui")
      local prompts = {
        actionable = "n",
        route = "1", -- reference
      }

      -- Act
      local decision = clarify_ui._build_decision_from_prompts(prompts)

      -- Assert
      assert.is_false(decision.actionable, "Should not be actionable")
      assert.equals("reference", decision.route, "Should be reference")
    end)

    it("should build someday/maybe decision for non-actionable", function()
      -- Arrange
      local clarify_ui = require("lib.gtd.clarify_ui")
      local prompts = {
        actionable = "n",
        route = "2", -- someday_maybe
      }

      -- Act
      local decision = clarify_ui._build_decision_from_prompts(prompts)

      -- Assert
      assert.is_false(decision.actionable, "Should not be actionable")
      assert.equals("someday_maybe", decision.route, "Should be someday_maybe")
    end)

    it("should build trash decision for non-actionable", function()
      -- Arrange
      local clarify_ui = require("lib.gtd.clarify_ui")
      local prompts = {
        actionable = "n",
        route = "3", -- trash
      }

      -- Act
      local decision = clarify_ui._build_decision_from_prompts(prompts)

      -- Assert
      assert.is_false(decision.actionable, "Should not be actionable")
      assert.equals("trash", decision.route, "Should be trash")
    end)
  end)

  describe("Inbox Processing", function()
    it("should get next unprocessed item from inbox", function()
      -- Arrange
      local clarify_ui = require("lib.gtd.clarify_ui")
      helpers.add_inbox_item("First task")
      helpers.add_inbox_item("Second task")

      -- Act
      local item = clarify_ui._get_next_item()

      -- Assert
      assert.is_not_nil(item, "Should return an item")
      assert.is_true(item:match("First task") ~= nil, "Should return first item")
    end)

    it("should return nil when inbox is empty", function()
      -- Arrange
      local clarify_ui = require("lib.gtd.clarify_ui")

      -- Act
      local item = clarify_ui._get_next_item()

      -- Assert
      assert.is_nil(item, "Should return nil for empty inbox")
    end)

    it("should extract clean text from inbox item", function()
      -- Arrange
      local clarify_ui = require("lib.gtd.clarify_ui")
      local raw_item = "- [ ] Buy groceries (captured: 2025-10-21 14:30)"

      -- Act
      local clean_text = clarify_ui._extract_item_text(raw_item)

      -- Assert
      assert.equals("Buy groceries", clean_text, "Should extract clean text")
    end)
  end)
end)
