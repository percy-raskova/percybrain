--- Keymap Centralization - Duplicate Cleanup Tests
--- Validates that duplicate keymap definitions were successfully removed
--- @module tests.unit.keymap.cleanup_spec

local helpers = require("tests.helpers.keymap_test_helpers")

describe("Keymap Duplicate Cleanup", function()
  before_each(function()
    -- Arrange: Clear any cached modules
    helpers.clear_keymap_cache()
  end)

  after_each(function()
    -- Cleanup: Clear cached modules
    helpers.clear_keymap_cache()
  end)

  it("should have deleted lua/config/keymaps.lua file", function()
    -- Arrange: Path to old keymap file
    local old_keymap_file = helpers.config_path("lua/config/keymaps.lua")

    -- Act: Check if file exists
    local file_exists = helpers.file_exists(old_keymap_file)

    -- Assert: File should NOT exist
    assert.is_false(file_exists, "lua/config/keymaps.lua should be deleted")
  end)

  it("should have removed M.setup_keymaps() from lua/config/zettelkasten.lua", function()
    -- Arrange: Path to zettelkasten config
    local zk_file = helpers.config_path("lua/config/zettelkasten.lua")

    -- Act: Check for setup_keymaps function
    local has_setup_keymaps = helpers.file_contains_pattern(zk_file, "function M%.setup_keymaps")

    -- Assert: Should NOT have setup_keymaps function
    assert.is_false(has_setup_keymaps, "M.setup_keymaps() should be removed from zettelkasten.lua")
  end)

  it("should have removed M.setup() keymaps from lua/config/window-manager.lua", function()
    -- Arrange: Path to window-manager config
    local wm_file = helpers.config_path("lua/config/window-manager.lua")

    -- Act: Check for keymap setup
    local has_setup = helpers.file_contains_pattern(wm_file, "M%.setup = function%(%)")
    local has_keymaps = helpers.file_contains_pattern(wm_file, 'keymap%(.-"<leader>w')

    -- Assert: Should NOT have both M.setup AND keymap definitions together
    local has_keymap_setup = has_setup and has_keymaps
    assert.is_false(has_keymap_setup, "M.setup() should not contain keymap definitions")
  end)

  it("should have removed inline keymaps from lua/percybrain/floating-quick-capture.lua", function()
    -- Arrange: Path to floating-quick-capture
    local fqc_file = helpers.config_path("lua/percybrain/floating-quick-capture.lua")

    -- Act: Check for inline vim.keymap.set
    local has_inline_keymap = helpers.file_contains_pattern(fqc_file, "vim%.keymap%.set.*state%.config%.keybinding")

    -- Assert: Should NOT have inline keymap registration
    assert.is_false(has_inline_keymap, "Inline vim.keymap.set should be removed")
  end)
end)
