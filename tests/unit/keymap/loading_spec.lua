--- Keymap Centralization - Module Loading Tests
--- Validates that all keymap modules are properly loaded and files exist
--- @module tests.unit.keymap.loading_spec

local helpers = require("tests.helpers.keymap_test_helpers")

describe("Centralized Keymap Loading", function()
  before_each(function()
    -- Arrange: Clear any cached modules
    helpers.clear_keymap_cache()
  end)

  after_each(function()
    -- Cleanup: Clear cached modules
    helpers.clear_keymap_cache()
  end)

  it("should load all keymap modules in lua/config/init.lua", function()
    -- Arrange: Path to init.lua and list of required modules
    local init_file = helpers.config_path("lua/config/init.lua")
    local required_modules = helpers.get_all_keymap_module_names()

    -- Assert: All modules should be required
    for _, module in ipairs(required_modules) do
      local is_loaded = helpers.file_requires_module(init_file, module)
      assert.is_true(is_loaded, module .. " should be loaded in init.lua")
    end
  end)

  it("should have all keymap module files present", function()
    -- Arrange: List of expected module file paths
    local module_files = helpers.get_all_keymap_module_paths()

    -- Act & Assert: Check each file exists
    for _, full_path in ipairs(module_files) do
      local exists = helpers.file_exists(full_path)
      local file_name = full_path:match("lua/config/keymaps/(.+)%.lua") or full_path
      assert.is_true(exists, file_name .. " should exist")
    end
  end)
end)
