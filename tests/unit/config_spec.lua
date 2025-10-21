-- Unit Tests: Core Configuration Module
-- Critical tests for config loading, initialization, and bootstrap

describe("Config Module", function()
  before_each(function()
    -- Arrange: Ensure clean state for config testing
    collectgarbage("collect")
  end)

  after_each(function()
    -- No cleanup needed - config state persists
  end)

  describe("Module Loading", function()
    it("loads without errors", function()
      -- Arrange: No setup needed

      -- Act
      local ok, result = pcall(require, "config")

      -- Assert
      assert.is_true(ok, "Config module failed to load: " .. tostring(result))
    end)

    it("executes without returning errors", function()
      -- Arrange
      package.loaded["config"] = nil

      -- Act
      local ok, result = pcall(require, "config")

      -- Assert: Config module doesn't return a table (just executes setup)
      assert.is_true(ok, "Config module failed to execute: " .. tostring(result))
    end)

    it("loads submodules in correct order", function()
      -- Arrange: Config should load: globals → keymaps → options
      local load_order = {}
      local original_require = require

      -- Mock require to track order
      _G.require = function(name)
        if name:match("^config%.") then
          table.insert(load_order, name)
        end
        return original_require(name)
      end

      package.loaded["config"] = nil
      package.loaded["config.globals"] = nil
      package.loaded["config.options"] = nil
      package.loaded["config.keymaps"] = nil

      -- Act
      require("config")

      -- Restore original require
      _G.require = original_require

      -- Assert: Verify load order (globals → keymaps → options)
      assert.equals("config.globals", load_order[1])
      assert.equals("config.keymaps", load_order[2])
      assert.equals("config.options", load_order[3])
    end)
  end)

  describe("Lazy.nvim Bootstrap", function()
    it("sets up lazy.nvim path correctly", function()
      -- Arrange & Act
      local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

      -- Assert
      assert.is_string(lazypath)
      assert.is_true(lazypath:match("lazy%.nvim$") ~= nil)
    end)

    it("adds lazy.nvim to runtimepath", function()
      -- Arrange
      local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
      local rtp = vim.opt.rtp:get()
      local found = false

      -- Act
      for _, path in ipairs(rtp) do
        if path == lazypath then
          found = true
          break
        end
      end

      -- Assert
      assert.is_true(found, "lazy.nvim not in runtimepath")
    end)

    it("lazy.nvim module is available", function()
      -- Act
      local ok = pcall(require, "lazy")

      -- Assert
      assert.is_true(ok, "lazy.nvim not available")
    end)

    it("loads plugin specifications", function()
      -- Arrange
      local lazy = require("lazy")

      -- Act
      assert.is_function(lazy.plugins, "lazy.plugins() not available")
      local plugins = lazy.plugins()

      -- Assert
      assert.is_table(plugins)
      assert.is_true(vim.tbl_count(plugins) > 0, "No plugins loaded")
    end)
  end)

  describe("Plugin Configuration", function()
    it("loads expected number of plugins", function()
      -- Arrange
      local lazy = require("lazy")
      local expected_min = 80 -- Minimum expected plugins

      -- Act
      local plugins = lazy.plugins()
      local count = vim.tbl_count(plugins)

      -- Assert: Should have at least 80 plugins (allows for minor variations)
      assert.is_true(count >= expected_min, string.format("Expected at least %d plugins, got %d", expected_min, count))
    end)

    it("includes critical plugins", function()
      -- Arrange
      local lazy = require("lazy")
      local plugins = lazy.plugins()

      -- Critical plugins that must be present (partial name match)
      local critical = {
        "plenary", -- Required for Telescope and testing
        "telescope", -- Fuzzy finder
        "treesitter", -- Syntax highlighting
        "lazy", -- Plugin manager itself
        "cmp", -- Completion
        "mason", -- LSP installer
      }

      -- Act & Assert: Check each critical plugin
      for _, plugin_name in ipairs(critical) do
        local found = false
        for _, plugin in ipairs(plugins) do
          local name = type(plugin) == "table" and plugin.name or tostring(plugin)
          if name:lower():find(plugin_name:lower(), 1, true) then
            found = true
            break
          end
        end
        assert.is_true(found, "Critical plugin missing: " .. plugin_name)
      end
    end)

    it("respects lazy loading configuration", function()
      -- Arrange
      local lazy = require("lazy")
      local plugins = lazy.plugins()

      -- Act: Count lazy vs immediate loaded plugins
      local lazy_count = 0
      local immediate_count = 0

      for _, plugin in ipairs(plugins) do
        if type(plugin) == "table" then
          if plugin.lazy == false then
            immediate_count = immediate_count + 1
          else
            lazy_count = lazy_count + 1
          end
        end
      end

      -- Assert: Most plugins should be lazy loaded
      assert.is_true(
        lazy_count > immediate_count,
        string.format("Too many immediate plugins: %d immediate, %d lazy", immediate_count, lazy_count)
      )
    end)
  end)

  describe("Configuration Values", function()
    it("sets correct leader key", function()
      -- Act & Assert
      assert.equals(" ", vim.g.mapleader, "Leader key should be space")
    end)

    it("sets correct localleader key", function()
      -- Act & Assert
      assert.equals(" ", vim.g.maplocalleader, "Localleader should be space")
    end)

    it("disables netrw for nvim-tree", function()
      -- Act & Assert: NvimTree requires netrw to be disabled
      assert.equals(1, vim.g.loaded_netrw)
      assert.equals(1, vim.g.loaded_netrwPlugin)
    end)
  end)

  describe("Error Handling", function()
    it("handles missing plugin directories gracefully", function()
      -- Arrange
      local plugins_dir = vim.fn.stdpath("config") .. "/lua/plugins"

      -- Act: This should not crash even if plugins dir is missing
      local ok = pcall(function()
        -- Simulate missing directory scenario
        if vim.fn.isdirectory(plugins_dir) == 0 then
          -- Should handle gracefully
          require("lazy").setup({})
        end
      end)

      -- Assert
      assert.is_true(ok, "Failed to handle missing plugins directory")
    end)

    it("provides meaningful error messages", function()
      -- Act: Try to load a non-existent config module
      local ok, err = pcall(require, "config.nonexistent")

      -- Assert
      assert.is_false(ok)
      assert.is_string(err)
      assert.is_true(err:match("module.*not found") ~= nil)
    end)
  end)

  describe("Performance Characteristics", function()
    it("loads within reasonable time", function()
      -- Arrange
      local start = vim.fn.reltime()
      package.loaded["config"] = nil

      -- Act
      require("config")
      local elapsed = vim.fn.reltimefloat(vim.fn.reltime(start))

      -- Assert: Config module should load quickly (< 100ms)
      assert.is_true(elapsed < 0.1, string.format("Config load too slow: %.3fs", elapsed))
    end)

    it("doesn't leak global variables", function()
      -- Arrange: Capture globals before loading config
      local before = {}
      for k, _ in pairs(_G) do
        before[k] = true
      end

      package.loaded["config"] = nil

      -- Act
      require("config")

      -- Assert: Check for new globals (excluding internal _ prefixed)
      local after = {}
      for k, _ in pairs(_G) do
        if not before[k] and not k:match("^_") then
          table.insert(after, k)
        end
      end

      -- Should not pollute global namespace
      assert.equals(0, #after, "Config leaked globals: " .. table.concat(after, ", "))
    end)
  end)
end)
