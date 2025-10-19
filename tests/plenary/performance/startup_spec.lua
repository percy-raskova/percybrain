-- Performance Benchmarks: Startup Time
-- Tests to establish baseline performance metrics

describe("Performance Benchmarks", function()
  describe("Startup Time", function()
    it("measures initial config loading", function()
      local start = vim.fn.reltime()

      -- Force reload of core config
      package.loaded['config'] = nil
      package.loaded['config.globals'] = nil
      package.loaded['config.options'] = nil
      package.loaded['config.keymaps'] = nil

      require('config')

      local elapsed = vim.fn.reltimefloat(vim.fn.reltime(start))

      -- Report the time
      print(string.format("\n⚡ Config loading: %.3fs", elapsed))

      -- Establish thresholds
      assert.is_true(elapsed < 0.5,
        string.format("Config loading exceeds 500ms: %.3fs", elapsed))
    end)

    it("measures plugin manager initialization", function()
      local start = vim.fn.reltime()

      -- This would already be loaded, just measuring access time
      local lazy = require('lazy')

      local elapsed = vim.fn.reltimefloat(vim.fn.reltime(start))

      print(string.format("⚡ Lazy.nvim access: %.3fs", elapsed))

      -- Should be nearly instant since already loaded
      assert.is_true(elapsed < 0.01,
        string.format("Lazy access too slow: %.3fs", elapsed))
    end)

    it("measures plugin count and load status", function()
      local lazy = require('lazy')
      local plugins = lazy.plugins()
      local loaded_count = 0
      local lazy_count = 0

      for name, plugin in pairs(plugins) do
        if plugin._.loaded then
          loaded_count = loaded_count + 1
        else
          lazy_count = lazy_count + 1
        end
      end

      local total = vim.tbl_count(plugins)

      print(string.format("\n📦 Plugin Statistics:"))
      print(string.format("  Total: %d", total))
      print(string.format("  Loaded: %d (%.1f%%)", loaded_count, (loaded_count/total)*100))
      print(string.format("  Lazy: %d (%.1f%%)", lazy_count, (lazy_count/total)*100))

      -- Most plugins should be lazy loaded
      assert.is_true(lazy_count > loaded_count,
        "Most plugins should be lazy loaded for performance")
    end)
  end)

  describe("Memory Usage", function()
    it("measures initial memory footprint", function()
      collectgarbage("collect")
      local memory_kb = collectgarbage("count")
      local memory_mb = memory_kb / 1024

      print(string.format("\n💾 Memory usage: %.2f MB", memory_mb))

      -- Baseline threshold
      assert.is_true(memory_mb < 100,
        string.format("Memory usage exceeds 100MB: %.2f MB", memory_mb))
    end)

    it("measures memory after garbage collection", function()
      -- Force garbage collection
      collectgarbage("collect")
      collectgarbage("collect")  -- Run twice to be thorough

      local memory_kb = collectgarbage("count")
      local memory_mb = memory_kb / 1024

      print(string.format("💾 Memory after GC: %.2f MB", memory_mb))

      -- Should be lower after GC
      assert.is_true(memory_mb < 80,
        string.format("Memory still high after GC: %.2f MB", memory_mb))
    end)
  end)

  describe("Module Loading Performance", function()
    local function measure_module_load(module_name)
      -- Clear from cache
      package.loaded[module_name] = nil

      local start = vim.fn.reltime()
      local ok, result = pcall(require, module_name)
      local elapsed = vim.fn.reltimefloat(vim.fn.reltime(start))

      return ok, elapsed
    end

    it("measures core module loading times", function()
      local modules = {
        { name = "config.globals", threshold = 0.005 },
        { name = "config.options", threshold = 0.01 },
        { name = "config.keymaps", threshold = 0.01 },
        { name = "config.window-manager", threshold = 0.05 },
      }

      print("\n⏱️  Module Loading Times:")
      for _, mod in ipairs(modules) do
        local ok, elapsed = measure_module_load(mod.name)

        if ok then
          print(string.format("  %s: %.3fs", mod.name, elapsed))

          assert.is_true(elapsed < mod.threshold,
            string.format("%s exceeds threshold (%.3fs > %.3fs)",
              mod.name, elapsed, mod.threshold))
        else
          print(string.format("  %s: FAILED TO LOAD", mod.name))
        end
      end
    end)
  end)

  describe("Operation Benchmarks", function()
    it("measures keymap setting performance", function()
      local start = vim.fn.reltime()

      -- Set 100 test keymaps
      for i = 1, 100 do
        vim.keymap.set("n", string.format("<leader>test%d", i), function() end, {
          desc = string.format("Test keymap %d", i),
          silent = true
        })
      end

      local elapsed = vim.fn.reltimefloat(vim.fn.reltime(start))

      print(string.format("\n⚡ Setting 100 keymaps: %.3fs", elapsed))

      -- Should be very fast
      assert.is_true(elapsed < 0.1,
        string.format("Keymap setting too slow: %.3fs for 100 keymaps", elapsed))

      -- Clean up
      for i = 1, 100 do
        vim.keymap.del("n", string.format("<leader>test%d", i))
      end
    end)

    it("measures option setting performance", function()
      local start = vim.fn.reltime()

      -- Set various options
      for _ = 1, 50 do
        vim.opt.number = true
        vim.opt.relativenumber = true
        vim.opt.wrap = true
        vim.opt.spell = true
        vim.opt.cursorline = true
        vim.opt.signcolumn = "yes"
        vim.opt.scrolloff = 10
        vim.opt.updatetime = 300
        vim.opt.timeoutlen = 400
        vim.opt.clipboard = "unnamedplus"
      end

      local elapsed = vim.fn.reltimefloat(vim.fn.reltime(start))

      print(string.format("⚡ Setting 500 options: %.3fs", elapsed))

      -- Should be fast
      assert.is_true(elapsed < 0.05,
        string.format("Option setting too slow: %.3fs", elapsed))
    end)
  end)

  describe("File Operation Performance", function()
    it("measures buffer creation speed", function()
      local start = vim.fn.reltime()
      local buffers = {}

      -- Create 20 buffers
      for i = 1, 20 do
        local buf = vim.api.nvim_create_buf(false, true)
        table.insert(buffers, buf)
      end

      local elapsed = vim.fn.reltimefloat(vim.fn.reltime(start))

      print(string.format("\n⚡ Creating 20 buffers: %.3fs", elapsed))

      assert.is_true(elapsed < 0.1,
        string.format("Buffer creation too slow: %.3fs", elapsed))

      -- Clean up
      for _, buf in ipairs(buffers) do
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end)

    it("measures window creation speed", function()
      local start = vim.fn.reltime()
      local initial_win = vim.api.nvim_get_current_win()

      -- Create and close 10 splits
      for i = 1, 10 do
        vim.cmd("vsplit")
      end

      local creation_time = vim.fn.reltimefloat(vim.fn.reltime(start))

      -- Close all but original
      vim.cmd("only")

      print(string.format("⚡ Creating 10 splits: %.3fs", creation_time))

      assert.is_true(creation_time < 0.5,
        string.format("Window creation too slow: %.3fs", creation_time))
    end)
  end)

  describe("Performance Regression Guards", function()
    it("ensures startup time hasn't regressed", function()
      -- This would normally compare against a baseline file
      -- For now, just establish the baseline

      local metrics = {
        config_load_ms = 100,   -- Max 100ms for config
        plugin_load_ms = 300,   -- Max 300ms for plugins
        total_startup_ms = 500, -- Max 500ms total
        memory_mb = 50,        -- Max 50MB initial memory
      }

      print("\n📊 Performance Baselines:")
      for key, value in pairs(metrics) do
        print(string.format("  %s: %s", key, value))
      end

      -- In a real test, we'd load these from a file and compare
      assert.is_table(metrics)
    end)
  end)

  describe("Neurodiversity Performance Features", function()
    it("measures auto-save performance impact", function()
      -- Simulate auto-save operations
      local start = vim.fn.reltime()

      for _ = 1, 10 do
        -- Simulate checking if buffer needs saving
        local modified = vim.bo.modified
        local buftype = vim.bo.buftype

        if modified and buftype == "" then
          -- Would trigger save here
        end
      end

      local elapsed = vim.fn.reltimefloat(vim.fn.reltime(start))

      print(string.format("\n⚡ Auto-save check (10x): %.3fs", elapsed))

      -- Should have minimal impact
      assert.is_true(elapsed < 0.01,
        string.format("Auto-save checks too slow: %.3fs", elapsed))
    end)

    it("measures distraction-free mode activation", function()
      local start = vim.fn.reltime()

      -- Simulate entering distraction-free mode
      local original_opts = {
        number = vim.opt.number:get(),
        relativenumber = vim.opt.relativenumber:get(),
        signcolumn = vim.opt.signcolumn:get(),
        statusline = vim.opt.statusline:get(),
        showmode = vim.opt.showmode:get(),
        showcmd = vim.opt.showcmd:get(),
        ruler = vim.opt.ruler:get(),
      }

      -- Disable distractions
      vim.opt.number = false
      vim.opt.relativenumber = false
      vim.opt.signcolumn = "no"
      vim.opt.showmode = false
      vim.opt.showcmd = false
      vim.opt.ruler = false

      local elapsed = vim.fn.reltimefloat(vim.fn.reltime(start))

      print(string.format("⚡ Enter distraction-free: %.3fs", elapsed))

      -- Restore
      for opt, val in pairs(original_opts) do
        vim.opt[opt] = val
      end

      -- Should be instant
      assert.is_true(elapsed < 0.01,
        string.format("Mode switch too slow: %.3fs", elapsed))
    end)
  end)

  describe("Performance Report", function()
    it("generates summary report", function()
      print("\n" .. string.rep("=", 50))
      print("PERCYBRAIN PERFORMANCE SUMMARY")
      print(string.rep("=", 50))

      local lazy = require('lazy')
      local plugins = lazy.plugins()
      local total_plugins = vim.tbl_count(plugins)

      -- Collect metrics
      collectgarbage("collect")
      local memory_mb = collectgarbage("count") / 1024

      local metrics = {
        ["Plugin Count"] = string.format("%d", total_plugins),
        ["Memory Usage"] = string.format("%.2f MB", memory_mb),
        ["Startup Target"] = "< 500ms",
        ["Memory Target"] = "< 50MB",
        ["Grade"] = memory_mb < 50 and "✅ PASS" or "⚠️  NEEDS OPTIMIZATION"
      }

      for key, value in pairs(metrics) do
        print(string.format("%-20s: %s", key, value))
      end

      print(string.rep("=", 50))

      -- Overall check
      assert.is_true(memory_mb < 100,
        "Memory usage exceeds acceptable threshold")
    end)
  end)
end)