--- Keymap Centralization - Registry System Tests
--- Validates the keymap registry and conflict detection functionality
--- @module tests.unit.keymap.registry_spec

local helpers = require("tests.helpers.keymap_test_helpers")

describe("Keymap Registry System", function()
  before_each(function()
    -- Arrange: Clear any cached modules
    helpers.clear_keymap_cache()
  end)

  after_each(function()
    -- Cleanup: Clear cached modules
    helpers.clear_keymap_cache()
  end)

  it("should have functional registry with conflict detection", function()
    -- Arrange: Load the registry module
    local registry = require("config.keymaps")

    -- Act: Check registry has required functions
    local has_register_module = type(registry.register_module) == "function"
    local has_print_registry = type(registry.print_registry) == "function"

    -- Assert: Registry should have core functions
    assert.is_true(has_register_module, "Registry should have register_module function")
    assert.is_true(has_print_registry, "Registry should have print_registry function")
  end)

  it("should detect duplicate keymap registrations", function()
    -- Arrange: Load registry and create test keymaps
    local registry = require("config.keymaps")
    local test_keymaps = {
      { "<leader>test1", "<cmd>Test1<cr>", desc = "Test 1" },
      { "<leader>test1", "<cmd>Duplicate<cr>", desc = "Duplicate" }, -- Duplicate key
    }

    -- Act: Register keymaps and capture notifications
    local notifications = {}
    local original_notify = vim.notify
    vim.notify = function(msg, level)
      table.insert(notifications, { msg = msg, level = level })
    end

    registry.register_module("test_module", test_keymaps)

    -- Restore original notify
    vim.notify = original_notify

    -- Assert: Should have warning about conflict
    local has_conflict_warning = false
    for _, notif in ipairs(notifications) do
      if notif.msg:match("Keymap conflict") and notif.level == vim.log.levels.WARN then
        has_conflict_warning = true
        break
      end
    end

    assert.is_true(has_conflict_warning, "Should warn about duplicate keymap")
  end)
end)
