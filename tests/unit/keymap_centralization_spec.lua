-- Keymap Centralization Test Suite
-- Tests that duplicate keymaps are removed and centralized system works
-- Uses plenary.nvim testing framework

describe("Keymap Centralization", function()
	before_each(function()
		-- Arrange: Clear any cached modules
		package.loaded["config.keymaps"] = nil
	end)

	after_each(function()
		-- Cleanup: Clear cached modules
		package.loaded["config.keymaps"] = nil
	end)

	describe("Duplicate Cleanup", function()
		it("should have deleted lua/config/keymaps.lua file", function()
			-- Arrange: Path to old keymap file
			local old_keymap_file = vim.fn.stdpath("config") .. "/lua/config/keymaps.lua"

			-- Act: Check if file exists
			local file_exists = vim.fn.filereadable(old_keymap_file) == 1

			-- Assert: File should NOT exist
			assert.is_false(file_exists, "lua/config/keymaps.lua should be deleted")
		end)

		it("should have removed M.setup_keymaps() from lua/config/zettelkasten.lua", function()
			-- Arrange: Path to zettelkasten config
			local zk_file = vim.fn.stdpath("config") .. "/lua/config/zettelkasten.lua"

			-- Act: Read file and search for setup_keymaps
			local content = table.concat(vim.fn.readfile(zk_file), "\n")
			local has_setup_keymaps = content:match("function M%.setup_keymaps") ~= nil

			-- Assert: Should NOT have setup_keymaps function
			assert.is_false(has_setup_keymaps, "M.setup_keymaps() should be removed from zettelkasten.lua")
		end)

		it("should have removed M.setup() keymaps from lua/config/window-manager.lua", function()
			-- Arrange: Path to window-manager config
			local wm_file = vim.fn.stdpath("config") .. "/lua/config/window-manager.lua"

			-- Act: Read file and check for keymap setup
			local content = table.concat(vim.fn.readfile(wm_file), "\n")
			local has_setup = content:match("M%.setup = function%(%)") ~= nil
			local has_keymaps = content:match('keymap%(.-"<leader>w') ~= nil

			-- Assert: Should NOT have both M.setup AND keymap definitions together
			local has_keymap_setup = has_setup and has_keymaps
			assert.is_false(has_keymap_setup, "M.setup() should not contain keymap definitions")
		end)

		it("should have removed inline keymaps from lua/percybrain/floating-quick-capture.lua", function()
			-- Arrange: Path to floating-quick-capture
			local fqc_file = vim.fn.stdpath("config") .. "/lua/percybrain/floating-quick-capture.lua"

			-- Act: Read file and check for inline vim.keymap.set
			local content = table.concat(vim.fn.readfile(fqc_file), "\n")
			local has_inline_keymap = content:match("vim%.keymap%.set.*state%.config%.keybinding") ~= nil

			-- Assert: Should NOT have inline keymap registration
			assert.is_false(has_inline_keymap, "Inline vim.keymap.set should be removed")
		end)
	end)

	describe("Centralized Keymap Loading", function()
		local required_modules = {
			"config.keymaps.core",
			"config.keymaps.window",
			"config.keymaps.toggle",
			"config.keymaps.diagnostics",
			"config.keymaps.navigation",
			"config.keymaps.git",
			"config.keymaps.zettelkasten",
			"config.keymaps.ai",
			"config.keymaps.prose",
			"config.keymaps.utilities",
			"config.keymaps.lynx",
			"config.keymaps.dashboard",
			"config.keymaps.quick-capture",
			"config.keymaps.telescope",
		}

		it("should load all keymap modules in lua/config/init.lua", function()
			-- Arrange: Path to init.lua
			local init_file = vim.fn.stdpath("config") .. "/lua/config/init.lua"

			-- Act: Read file content
			local content = table.concat(vim.fn.readfile(init_file), "\n")

			-- Assert: All modules should be required
			for _, module in ipairs(required_modules) do
				local pattern = 'require%("' .. module:gsub("%.", "%%."):gsub("%-", "%%-") .. '"%)'
				local is_loaded = content:match(pattern) ~= nil
				assert.is_true(is_loaded, module .. " should be loaded in init.lua")
			end
		end)

		it("should have all keymap module files present", function()
			-- Arrange: List of expected module files
			local module_files = {
				"lua/config/keymaps/core.lua",
				"lua/config/keymaps/window.lua",
				"lua/config/keymaps/toggle.lua",
				"lua/config/keymaps/diagnostics.lua",
				"lua/config/keymaps/navigation.lua",
				"lua/config/keymaps/git.lua",
				"lua/config/keymaps/zettelkasten.lua",
				"lua/config/keymaps/ai.lua",
				"lua/config/keymaps/prose.lua",
				"lua/config/keymaps/utilities.lua",
				"lua/config/keymaps/lynx.lua",
				"lua/config/keymaps/dashboard.lua",
				"lua/config/keymaps/quick-capture.lua",
				"lua/config/keymaps/telescope.lua",
			}

			-- Act & Assert: Check each file exists
			for _, file in ipairs(module_files) do
				local full_path = vim.fn.stdpath("config") .. "/" .. file
				local exists = vim.fn.filereadable(full_path) == 1
				assert.is_true(exists, file .. " should exist")
			end
		end)
	end)

	describe("Keymap Registry System", function()
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

	describe("Keymap Module Syntax", function()
		local modules_to_check = {
			"config.keymaps.core",
			"config.keymaps.window",
			"config.keymaps.toggle",
			"config.keymaps.diagnostics",
			"config.keymaps.navigation",
			"config.keymaps.git",
			"config.keymaps.zettelkasten",
			"config.keymaps.ai",
			"config.keymaps.prose",
			"config.keymaps.utilities",
			"config.keymaps.lynx",
			"config.keymaps.dashboard",
			"config.keymaps.quick-capture",
			"config.keymaps.telescope",
		}

		for _, module_name in ipairs(modules_to_check) do
			it("should load " .. module_name .. " without errors", function()
				-- Arrange: Attempt to require module
				local success, result = pcall(require, module_name)

				-- Assert: Module should load successfully
				assert.is_true(success, module_name .. " should load without errors: " .. tostring(result))
				assert.is_not_nil(result, module_name .. " should return a value")
			end)
		end
	end)

	describe("Namespace Organization", function()
		it("should have no conflicting keymaps across all modules", function()
			-- Arrange: Load all keymap modules
			local all_keys = {}
			local conflicts = {}

			local modules = {
				"config.keymaps.core",
				"config.keymaps.window",
				"config.keymaps.toggle",
				"config.keymaps.diagnostics",
				"config.keymaps.navigation",
				"config.keymaps.git",
				"config.keymaps.zettelkasten",
				"config.keymaps.ai",
				"config.keymaps.prose",
				"config.keymaps.utilities",
				"config.keymaps.lynx",
				"config.keymaps.dashboard",
				"config.keymaps.quick-capture",
				"config.keymaps.telescope",
			}

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
end)
