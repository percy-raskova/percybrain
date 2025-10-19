-- Unit Tests: Window Manager Module
-- Tests for PercyBrain's custom window management system

local helpers = require('tests.helpers')
local mocks = require('tests.helpers.mocks')

-- Helper function for table contains check
local function contains(tbl, value)
  for _, v in ipairs(tbl) do
    if v == value then
      return true
    end
  end
  return false
end

describe("Window Manager", function()
  local wm
  local wm_mock
  local original_vim
  local original_notify

  before_each(function()
    -- Arrange: Load window manager module
    package.loaded['config.window-manager'] = nil
    wm = require('config.window-manager')

    -- Setup window manager mock
    wm_mock = mocks.window_manager()
    original_notify = vim.notify
    vim.notify = function() end
  end)

  after_each(function()
    -- Cleanup: Restore original notify
    vim.notify = original_notify
  end)

  describe("Module Structure", function()
    it("exports expected functions", function()
      -- Arrange
      local expected_functions = {
        -- Navigation
        "navigate",
        -- Splitting
        "split_horizontal", "split_vertical",
        -- Moving
        "move_window",
        -- Closing
        "close_window", "close_other_windows", "quit_window",
        -- Resizing
        "equalize_windows", "maximize_width", "maximize_height",
        -- Buffer management
        "list_buffers", "next_buffer", "prev_buffer", "delete_buffer",
        -- Layout presets
        "layout_wiki", "layout_focus", "layout_reset", "layout_research",
        -- Info and setup
        "window_info", "setup"
      }

      -- Act & Assert
      assert.is_table(wm)
      for _, fn_name in ipairs(expected_functions) do
        assert.is_function(wm[fn_name], fn_name .. " should be a function")
      end
    end)
  end)

  describe("Navigation Functions", function()
    it("navigates to windows in all directions", function()
      -- Arrange
      local commands = {}
      local original_cmd = vim.cmd
      vim.cmd = function(cmd)
        table.insert(commands, cmd)
      end

      -- Act
      wm.navigate("h")
      wm.navigate("j")
      wm.navigate("k")
      wm.navigate("l")

      -- Assert
      assert.equals("wincmd h", commands[1])
      assert.equals("wincmd j", commands[2])
      assert.equals("wincmd k", commands[3])
      assert.equals("wincmd l", commands[4])

      vim.cmd = original_cmd
    end)
  end)

  describe("Splitting Functions", function()
    it("creates horizontal split", function()
      -- Arrange
      local cmd_called = false
      local original_cmd = vim.cmd
      vim.cmd = function(cmd)
        if cmd == "split" then
          cmd_called = true
        end
      end

      -- Act
      wm.split_horizontal()

      -- Assert
      assert.is_true(cmd_called)

      vim.cmd = original_cmd
    end)

    it("creates vertical split", function()
      -- Arrange
      local cmd_called = false
      local original_cmd = vim.cmd
      vim.cmd = function(cmd)
        if cmd == "vsplit" then
          cmd_called = true
        end
      end

      -- Act
      wm.split_vertical()

      -- Assert
      assert.is_true(cmd_called)

      vim.cmd = original_cmd
    end)
  end)

  describe("Window Moving", function()
    it("moves windows in all directions", function()
      -- Arrange
      local commands = {}
      local original_cmd = vim.cmd
      vim.cmd = function(cmd)
        table.insert(commands, cmd)
      end

      -- Act
      wm.move_window("H")
      wm.move_window("J")
      wm.move_window("K")
      wm.move_window("L")

      -- Assert
      assert.equals("wincmd H", commands[1])
      assert.equals("wincmd J", commands[2])
      assert.equals("wincmd K", commands[3])
      assert.equals("wincmd L", commands[4])

      vim.cmd = original_cmd
    end)
  end)

  describe("Window Closing", function()
    it("closes current window safely", function()
      -- Arrange
      local commands = {}
      local original_cmd = vim.cmd
      local original_winnr = vim.fn.winnr

      vim.cmd = function(cmd)
        table.insert(commands, cmd)
      end

      vim.fn.winnr = function(arg)
        if arg == "$" then
          return 2  -- Simulate 2 windows
        end
        return 1
      end

      -- Act
      wm.close_window()

      -- Assert
      assert.equals("close", commands[1])

      vim.cmd = original_cmd
      vim.fn.winnr = original_winnr
    end)

    it("prevents closing last window", function()
      -- Arrange
      local close_called = false
      local original_cmd = vim.cmd
      local original_winnr = vim.fn.winnr

      vim.cmd = function(cmd)
        if cmd == "close" then
          close_called = true
        end
      end

      vim.fn.winnr = function(arg)
        if arg == "$" then
          return 1  -- Only 1 window
        end
        return 1
      end

      -- Act
      wm.close_window()

      -- Assert
      assert.is_false(close_called, "Should not close last window")

      vim.cmd = original_cmd
      vim.fn.winnr = original_winnr
    end)

    it("closes other windows", function()
      -- Arrange
      local cmd_called = false
      local original_cmd = vim.cmd
      vim.cmd = function(cmd)
        if cmd == "only" then
          cmd_called = true
        end
      end

      -- Act
      wm.close_other_windows()

      -- Assert
      assert.is_true(cmd_called)

      vim.cmd = original_cmd
    end)
  end)

  describe("Window Resizing", function()
    it("equalizes windows", function()
      -- Arrange
      local cmd_called = false
      local original_cmd = vim.cmd
      vim.cmd = function(cmd)
        if cmd == "wincmd =" then
          cmd_called = true
        end
      end

      -- Act
      wm.equalize_windows()

      -- Assert
      assert.is_true(cmd_called)

      vim.cmd = original_cmd
    end)

    it("maximizes width", function()
      -- Arrange
      local cmd_called = false
      local original_cmd = vim.cmd
      vim.cmd = function(cmd)
        if cmd == "vertical resize | wincmd |" then
          cmd_called = true
        end
      end

      -- Act
      wm.maximize_width()

      -- Assert
      assert.is_true(cmd_called)

      vim.cmd = original_cmd
    end)

    it("maximizes height", function()
      -- Arrange
      local cmd_called = false
      local original_cmd = vim.cmd
      vim.cmd = function(cmd)
        if cmd == "resize | wincmd _" then
          cmd_called = true
        end
      end

      -- Act
      wm.maximize_height()

      -- Assert
      assert.is_true(cmd_called)

      vim.cmd = original_cmd
    end)
  end)

  describe("Buffer Management", function()
    it("navigates buffers", function()
      -- Arrange
      local commands = {}
      local original_cmd = vim.cmd
      vim.cmd = function(cmd)
        table.insert(commands, cmd)
      end

      -- Act
      wm.next_buffer()
      wm.prev_buffer()

      -- Assert
      assert.is_true(contains(commands, "bnext"))
      assert.is_true(contains(commands, "bprevious"))

      vim.cmd = original_cmd
    end)

    it("handles buffer deletion safely", function()
      -- Arrange
      local commands = {}
      local original_cmd = vim.cmd
      local original_get_buf = vim.api.nvim_get_current_buf
      local original_buf_name = vim.api.nvim_buf_get_name
      local original_buf_opt = vim.api.nvim_buf_get_option

      vim.cmd = function(cmd)
        table.insert(commands, cmd)
      end

      vim.api.nvim_get_current_buf = function()
        return 1
      end

      vim.api.nvim_buf_get_name = function()
        return "/test/file.txt"
      end

      vim.api.nvim_buf_get_option = function(bufnr, option)
        if option == "modified" then
          return false
        end
      end

      -- Act
      wm.delete_buffer()

      -- Assert
      assert.is_true(contains(commands, "bdelete"))

      vim.cmd = original_cmd
      vim.api.nvim_get_current_buf = original_get_buf
      vim.api.nvim_buf_get_name = original_buf_name
      vim.api.nvim_buf_get_option = original_buf_opt
    end)
  end)

  describe("Layout Presets", function()
    it("activates wiki layout", function()
      -- Arrange
      local commands = {}
      local original_cmd = vim.cmd
      local original_defer = vim.defer_fn

      vim.cmd = function(cmd)
        table.insert(commands, cmd)
      end

      vim.defer_fn = function(fn, delay)
        -- Don't execute deferred function in tests
      end

      -- Act
      wm.layout_wiki()

      -- Assert
      assert.is_true(contains(commands, "only"))
      assert.is_true(vim.tbl_contains(commands, "NvimTreeOpen") or
                     vim.tbl_contains(commands, "vsplit"))

      vim.cmd = original_cmd
      vim.defer_fn = original_defer
    end)

    it("activates focus layout", function()
      -- Arrange
      local commands = {}
      local original_cmd = vim.cmd
      vim.cmd = function(cmd)
        table.insert(commands, cmd)
      end

      -- Act
      wm.layout_focus()

      -- Assert
      assert.is_true(contains(commands, "only"))
      assert.is_true(contains(commands, "NvimTreeClose"))

      vim.cmd = original_cmd
    end)

    it("resets layout", function()
      -- Arrange
      local commands = {}
      local original_cmd = vim.cmd
      vim.cmd = function(cmd)
        table.insert(commands, cmd)
      end

      -- Act
      wm.layout_reset()

      -- Assert
      assert.is_true(contains(commands, "only"))
      assert.is_true(contains(commands, "NvimTreeClose"))
      assert.is_true(contains(commands, "enew"))

      vim.cmd = original_cmd
    end)

    it("activates research layout", function()
      -- Arrange
      local commands = {}
      local original_cmd = vim.cmd
      local original_defer = vim.defer_fn

      vim.cmd = function(cmd)
        table.insert(commands, cmd)
      end

      vim.defer_fn = function(fn, delay)
        -- Don't execute in tests
      end

      -- Act
      wm.layout_research()

      -- Assert
      assert.is_true(contains(commands, "only"))
      assert.is_true(contains(commands, "vsplit"))

      vim.cmd = original_cmd
      vim.defer_fn = original_defer
    end)
  end)

  describe("Window Info", function()
    it("provides window information", function()
      -- Arrange
      local original_list_wins = vim.api.nvim_list_wins
      local original_get_win = vim.api.nvim_get_current_win
      local original_winnr = vim.fn.winnr

      vim.api.nvim_list_wins = function()
        return {1001, 1002, 1003}
      end

      vim.api.nvim_get_current_win = function()
        return 1002
      end

      vim.fn.winnr = function()
        return 2
      end

      -- Act
      local ok = pcall(wm.window_info)

      -- Assert
      assert.is_true(ok)

      vim.api.nvim_list_wins = original_list_wins
      vim.api.nvim_get_current_win = original_get_win
      vim.fn.winnr = original_winnr
    end)
  end)

  describe("Keymap Setup", function()
    it("sets up keymaps without errors", function()
      -- Arrange
      local keymaps = {}
      local original_set = vim.keymap.set
      vim.keymap.set = function(mode, lhs, rhs, opts)
        table.insert(keymaps, {
          mode = mode,
          lhs = lhs,
          desc = opts and opts.desc or nil
        })
      end

      -- Act
      wm.setup()

      -- Assert: Essential keymaps
      local keymap_lhs = {}
      for _, km in ipairs(keymaps) do
        table.insert(keymap_lhs, km.lhs)
      end

      -- Navigation
      assert.is_true(contains(keymap_lhs, "<leader>wh"))
      assert.is_true(contains(keymap_lhs, "<leader>wj"))
      assert.is_true(contains(keymap_lhs, "<leader>wk"))
      assert.is_true(contains(keymap_lhs, "<leader>wl"))

      -- Moving
      assert.is_true(contains(keymap_lhs, "<leader>wH"))
      assert.is_true(contains(keymap_lhs, "<leader>wJ"))
      assert.is_true(contains(keymap_lhs, "<leader>wK"))
      assert.is_true(contains(keymap_lhs, "<leader>wL"))

      -- Splitting
      assert.is_true(contains(keymap_lhs, "<leader>ws"))
      assert.is_true(contains(keymap_lhs, "<leader>wv"))

      vim.keymap.set = original_set
    end)

    it("uses consistent keymap pattern", function()
      -- Arrange
      local keymaps = {}
      local original_set = vim.keymap.set
      vim.keymap.set = function(mode, lhs, rhs, opts)
        table.insert(keymaps, {
          mode = mode,
          lhs = lhs,
          desc = opts and opts.desc or nil
        })
      end

      -- Act
      wm.setup()

      -- Assert: All keymaps in normal mode with <leader>w prefix and descriptions
      for _, km in ipairs(keymaps) do
        assert.equals("n", km.mode, "All window keymaps should be normal mode")
        assert.is_true(km.lhs:match("^<leader>w") ~= nil,
          "Keymap " .. km.lhs .. " should start with <leader>w")
        assert.is_string(km.desc, "Keymap " .. km.lhs .. " should have description")
        assert.is_true(#km.desc > 0, "Description should not be empty")
      end

      vim.keymap.set = original_set
    end)
  end)

  describe("Performance", function()
    it("loads quickly", function()
      -- Arrange
      local start = vim.fn.reltime()

      -- Act
      package.loaded['config.window-manager'] = nil
      require('config.window-manager')

      local elapsed = vim.fn.reltimefloat(vim.fn.reltime(start))

      -- Assert
      assert.is_true(elapsed < 0.05,
        string.format("Window manager loading too slow: %.3fs", elapsed))
    end)
  end)

  describe("ADHD Optimizations", function()
    it("provides quick window toggle", function()
      -- Arrange
      local keymaps = {}
      local original_set = vim.keymap.set
      vim.keymap.set = function(mode, lhs, rhs, opts)
        if lhs == "<leader>ww" then
          table.insert(keymaps, {
            mode = mode,
            lhs = lhs,
            desc = opts and opts.desc or nil
          })
        end
      end

      -- Act
      wm.setup()

      -- Assert
      assert.equals(1, #keymaps, "Should have quick toggle keymap")
      assert.equals("<leader>ww", keymaps[1].lhs)
      assert.is_true(keymaps[1].desc:lower():match("quick") ~= nil or
                     keymaps[1].desc:lower():match("toggle") ~= nil,
                     "Should indicate quick toggle functionality")

      vim.keymap.set = original_set
    end)

    it("uses visual feedback", function()
      -- Arrange
      local notify_count = 0
      local original_cmd = vim.cmd

      vim.notify = function(msg, level)
        notify_count = notify_count + 1
      end

      vim.cmd = function() end

      -- Act
      wm.split_horizontal()
      wm.split_vertical()
      wm.move_window("H")
      wm.equalize_windows()

      -- Assert
      assert.is_true(notify_count >= 4,
        "Functions should provide visual feedback via notifications")

      vim.cmd = original_cmd
    end)
  end)
end)
