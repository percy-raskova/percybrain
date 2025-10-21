--- Keymap Centralization - Module Syntax Tests
--- Validates that all keymap modules load without syntax errors
--- @module tests.unit.keymap.syntax_spec

local helpers = require("tests.helpers.keymap_test_helpers")

describe("Keymap Module Syntax", function()
  before_each(function()
    -- Arrange: Clear any cached modules
    helpers.clear_keymap_cache()
  end)

  after_each(function()
    -- Cleanup: Clear cached modules
    helpers.clear_keymap_cache()
  end)

  local modules_to_check = helpers.get_all_keymap_module_names()

  for _, module_name in ipairs(modules_to_check) do
    it("should load " .. module_name .. " without errors", function()
      -- Arrange: (module name provided by loop)

      -- Act: Attempt to require module
      local success, result = pcall(require, module_name)

      -- Assert: Module should load successfully
      assert.is_true(success, module_name .. " should load without errors: " .. tostring(result))
      assert.is_not_nil(result, module_name .. " should return a value")
    end)
  end
end)
