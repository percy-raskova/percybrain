--- Keymap Centralization - Namespace Organization Tests
--- Validates that no conflicting keymaps exist across all modules
--- @module tests.unit.keymap.namespace_spec

local helpers = require("tests.helpers.keymap_test_helpers")

describe("Namespace Organization", function()
	before_each(function()
		-- Arrange: Clear any cached modules
		helpers.clear_keymap_cache()
	end)

	after_each(function()
		-- Cleanup: Clear cached modules
		helpers.clear_keymap_cache()
	end)

	it("should have no conflicting keymaps across all modules", function()
		-- Arrange: Load all keymap modules
		local all_keys = {}
		local conflicts = {}
		local modules = helpers.get_all_keymap_module_names()

		-- Act: Collect all keymaps and check for duplicates
		for _, module_name in ipairs(modules) do
			local success, keymaps = pcall(require, module_name)
			if success and type(keymaps) == "table" then
				for _, keymap in ipairs(keymaps) do
					local key = keymap[1] or keymap.key
					if key then
						if all_keys[key] then
							table.insert(conflicts, {
								key = key,
								module1 = all_keys[key],
								module2 = module_name,
							})
						else
							all_keys[key] = module_name
						end
					end
				end
			end
		end

		-- Assert: No conflicts should exist
		local conflict_messages = {}
		for _, conflict in ipairs(conflicts) do
			table.insert(
				conflict_messages,
				string.format("Key '%s' defined in both %s and %s", conflict.key, conflict.module1, conflict.module2)
			)
		end

		assert.equals(
			0,
			#conflicts,
			"Should have no keymap conflicts. Found: " .. table.concat(conflict_messages, ", ")
		)
	end)
end)
