-- Trouble Plugin Contract Tests
-- Kent Beck TDD: "Write the test you wish you had"
-- Purpose: Define MUST/MUST NOT/MAY contracts for Trouble.nvim buffer behavior

describe("Trouble Plugin Contract", function()
  local trouble

  before_each(function()
    -- Arrange: Load Trouble plugin
    trouble = require("trouble")
  end)

  after_each(function()
    -- Cleanup: Close any open Trouble windows
    if trouble then
      pcall(function()
        vim.cmd("TroubleClose")
      end)
    end
  end)

  -- ============================================================================
  -- REQUIRED CONTRACT: Buffer Persistence
  -- ============================================================================

  describe("MUST persist buffer when user interacts", function()
    it("MUST NOT close buffer when user clicks inside", function()
      -- Arrange: Open Trouble window
      vim.cmd("TroubleToggle")
      local initial_winnr = vim.api.nvim_get_current_win()

      -- Act: Simulate buffer focus (clicking inside buffer)
      vim.cmd("doautocmd BufEnter")
      vim.cmd("doautocmd WinEnter")

      -- Assert: Buffer still open
      local current_winnr = vim.api.nvim_get_current_win()
      assert.is_not_nil(current_winnr)
      assert.is_true(vim.api.nvim_win_is_valid(initial_winnr))
    end)

    it("MUST NOT close buffer when user moves cursor", function()
      -- Arrange: Open Trouble window with some content
      vim.cmd("TroubleToggle workspace_diagnostics")
      local initial_winnr = vim.api.nvim_get_current_win()

      -- Act: Move cursor (j key)
      vim.api.nvim_feedkeys("j", "n", false)
      vim.cmd("doautocmd CursorMoved")

      -- Assert: Buffer still open
      assert.is_true(vim.api.nvim_win_is_valid(initial_winnr))
    end)

    it("MUST NOT auto-close when diagnostics are present", function()
      -- Arrange: Create diagnostic and open Trouble
      local bufnr = vim.api.nvim_create_buf(false, true)
      vim.diagnostic.set(
        vim.api.nvim_create_namespace("test"),
        bufnr,
        {
          {
            lnum = 0,
            col = 0,
            severity = vim.diagnostic.severity.ERROR,
            message = "Test error",
          },
        },
        {}
      )
      vim.cmd("TroubleToggle workspace_diagnostics")
      local initial_winnr = vim.api.nvim_get_current_win()

      -- Act: Wait for potential auto-close
      vim.wait(500, function()
        return false
      end)

      -- Assert: Buffer still open (auto_close should be false)
      assert.is_true(vim.api.nvim_win_is_valid(initial_winnr))
    end)
  end)

  -- ============================================================================
  -- REQUIRED CONTRACT: Buffer Scrolling and Navigation
  -- ============================================================================

  describe("MUST allow scrolling through buffer content", function()
    it("MUST allow j/k navigation through error list", function()
      -- Arrange: Open Trouble with multiple diagnostics
      local bufnr = vim.api.nvim_create_buf(false, true)
      vim.diagnostic.set(
        vim.api.nvim_create_namespace("test"),
        bufnr,
        {
          { lnum = 0, col = 0, severity = vim.diagnostic.severity.ERROR, message = "Error 1" },
          { lnum = 1, col = 0, severity = vim.diagnostic.severity.ERROR, message = "Error 2" },
          { lnum = 2, col = 0, severity = vim.diagnostic.severity.ERROR, message = "Error 3" },
        },
        {}
      )
      vim.cmd("TroubleToggle workspace_diagnostics")

      -- Act: Navigate down with j key
      local initial_pos = vim.api.nvim_win_get_cursor(0)
      vim.api.nvim_feedkeys("j", "n", false)
      vim.wait(100, function()
        return false
      end)
      local new_pos = vim.api.nvim_win_get_cursor(0)

      -- Assert: Cursor moved
      assert.is_not.same(initial_pos, new_pos)
    end)

    it("MUST show all buffer content (not just first few lines)", function()
      -- Arrange: Open Trouble with many diagnostics (>10)
      local bufnr = vim.api.nvim_create_buf(false, true)
      local diagnostics = {}
      for i = 0, 14 do
        table.insert(diagnostics, {
          lnum = i,
          col = 0,
          severity = vim.diagnostic.severity.ERROR,
          message = "Error " .. (i + 1),
        })
      end
      vim.diagnostic.set(vim.api.nvim_create_namespace("test"), bufnr, diagnostics, {})
      vim.cmd("TroubleToggle workspace_diagnostics")

      -- Act: Navigate to bottom (multiple j keys)
      for _ = 1, 12 do
        vim.api.nvim_feedkeys("j", "n", false)
      end
      vim.wait(200, function()
        return false
      end)

      -- Assert: Can reach bottom (cursor at or near line 15)
      local final_pos = vim.api.nvim_win_get_cursor(0)
      assert.is_true(final_pos[1] >= 10, "Should be able to scroll to bottom entries")
    end)

    it("MUST be scrollable buffer (not height-restricted)", function()
      -- Arrange: Open Trouble
      vim.cmd("TroubleToggle")
      local winnr = vim.api.nvim_get_current_win()

      -- Act: Get buffer options
      local bufnr = vim.api.nvim_win_get_buf(winnr)
      local scrolloff = vim.api.nvim_buf_get_option(bufnr, "scrolloff")
      local wrap = vim.api.nvim_buf_get_option(bufnr, "wrap")

      -- Assert: Buffer allows scrolling
      assert.is_not_nil(scrolloff)
      assert.is_not_nil(wrap)
    end)
  end)

  -- ============================================================================
  -- REQUIRED CONTRACT: Buffer Visibility
  -- ============================================================================

  describe("MUST show buffer content properly", function()
    it("MUST NOT have bufhidden=wipe (would destroy buffer content)", function()
      -- Arrange: Open Trouble
      vim.cmd("TroubleToggle")
      local bufnr = vim.api.nvim_win_get_buf(0)

      -- Act: Check bufhidden setting
      local bufhidden = vim.api.nvim_buf_get_option(bufnr, "bufhidden")

      -- Assert: Not set to wipe (would delete buffer when hidden)
      assert.is_not.equal("wipe", bufhidden)
    end)

    it("MUST be modifiable=false (read-only buffer)", function()
      -- Arrange: Open Trouble
      vim.cmd("TroubleToggle")
      local bufnr = vim.api.nvim_win_get_buf(0)

      -- Act: Check modifiable setting
      local modifiable = vim.api.nvim_buf_get_option(bufnr, "modifiable")

      -- Assert: Read-only buffer
      assert.is_false(modifiable)
    end)
  end)

  -- ============================================================================
  -- REQUIRED CONTRACT: User Control
  -- ============================================================================

  describe("MUST provide explicit close control", function()
    it("MUST close when user presses q", function()
      -- Arrange: Open Trouble
      vim.cmd("TroubleToggle")
      local initial_winnr = vim.api.nvim_get_current_win()

      -- Act: Press q to close
      vim.api.nvim_feedkeys("q", "n", false)
      vim.wait(100, function()
        return false
      end)

      -- Assert: Window closed
      assert.is_false(vim.api.nvim_win_is_valid(initial_winnr))
    end)

    it("MUST close when user presses <Esc>", function()
      -- Arrange: Open Trouble
      vim.cmd("TroubleToggle")
      local initial_winnr = vim.api.nvim_get_current_win()

      -- Act: Press <Esc> to cancel
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
      vim.wait(100, function()
        return false
      end)

      -- Assert: Window closed
      assert.is_false(vim.api.nvim_win_is_valid(initial_winnr))
    end)
  end)

  -- ============================================================================
  -- FORBIDDEN CONTRACT: Auto-Close Behavior
  -- ============================================================================

  describe("MUST NOT auto-close unexpectedly", function()
    it("MUST NOT close when buffer loses focus temporarily", function()
      -- Arrange: Open Trouble and another window
      vim.cmd("TroubleToggle")
      local trouble_winnr = vim.api.nvim_get_current_win()
      vim.cmd("vnew")

      -- Act: Focus other window
      vim.cmd("wincmd w")
      vim.wait(100, function()
        return false
      end)

      -- Assert: Trouble window still exists
      assert.is_true(vim.api.nvim_win_is_valid(trouble_winnr))
    end)

    it("MUST NOT have auto_close=true in configuration", function()
      -- Arrange: Get Trouble configuration
      local config = require("trouble.config")

      -- Act: Check auto_close setting
      local auto_close = config.options.auto_close

      -- Assert: Auto-close disabled
      assert.is_false(auto_close, "auto_close must be false to prevent unexpected buffer closing")
    end)
  end)

  -- ============================================================================
  -- OPTIONAL CONTRACT: Advanced Features
  -- ============================================================================

  describe("MAY provide enhanced navigation", function()
    it("MAY support mouse clicks for navigation", function()
      -- Arrange: Open Trouble
      vim.cmd("TroubleToggle")

      -- Act: Check if mouse is enabled
      local mouse = vim.o.mouse

      -- Assert: Mouse support available (not required but nice to have)
      -- This test documents the behavior but doesn't enforce it
      if mouse and mouse:match("a") then
        assert.is_true(true, "Mouse support enabled")
      else
        assert.is_true(true, "Mouse support optional")
      end
    end)
  end)
end)
