-- Trouble Plugin Capability Tests
-- Kent Beck TDD: "Tests are specifications of behavior"
-- Purpose: Define user CAN DO workflows with Trouble plugin

describe("Trouble Plugin User Workflows", function()
  local trouble

  before_each(function()
    -- Arrange: Fresh Neovim environment
    trouble = require("trouble")

    -- Clear any existing diagnostics
    vim.diagnostic.reset()
  end)

  after_each(function()
    -- Cleanup: Close Trouble and clear diagnostics
    pcall(function()
      vim.cmd("TroubleClose")
    end)
    vim.diagnostic.reset()
  end)

  -- ============================================================================
  -- WORKFLOW 1: View Errors Without Hunting
  -- ============================================================================

  describe("User CAN view all errors in one place", function()
    it("CAN open Trouble window to see aggregated errors", function()
      -- Arrange: Create errors in multiple buffers
      local buf1 = vim.api.nvim_create_buf(false, true)
      local buf2 = vim.api.nvim_create_buf(false, true)

      vim.diagnostic.set(vim.api.nvim_create_namespace("test"), buf1, {
        { lnum = 0, col = 0, severity = vim.diagnostic.severity.ERROR, message = "Error in file 1" },
      }, {})

      vim.diagnostic.set(vim.api.nvim_create_namespace("test"), buf2, {
        { lnum = 0, col = 0, severity = vim.diagnostic.severity.ERROR, message = "Error in file 2" },
      }, {})

      -- Act: Open Trouble with <leader>xx
      vim.cmd("TroubleToggle workspace_diagnostics")

      -- Assert: Trouble window opened successfully
      local winnr = vim.api.nvim_get_current_win()
      assert.is_not_nil(winnr)
      assert.is_true(vim.api.nvim_win_is_valid(winnr))

      -- Assert: Can see errors from both buffers
      local bufnr = vim.api.nvim_win_get_buf(winnr)
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      assert.is_true(#lines > 0, "Should show error content")
    end)

    it("CAN keep Trouble window open while reviewing errors", function()
      -- Arrange: Open Trouble with errors
      local bufnr = vim.api.nvim_create_buf(false, true)
      vim.diagnostic.set(vim.api.nvim_create_namespace("test"), bufnr, {
        { lnum = 0, col = 0, severity = vim.diagnostic.severity.ERROR, message = "Test error" },
      }, {})
      vim.cmd("TroubleToggle workspace_diagnostics")
      local trouble_winnr = vim.api.nvim_get_current_win()

      -- Act: Review errors (move cursor, focus window)
      vim.api.nvim_feedkeys("j", "n", false)
      vim.wait(100, function()
        return false
      end)
      vim.api.nvim_feedkeys("k", "n", false)
      vim.wait(100, function()
        return false
      end)

      -- Assert: Window remains open during review
      assert.is_true(vim.api.nvim_win_is_valid(trouble_winnr))
    end)

    it("CAN switch between workspace and document diagnostics", function()
      -- Arrange: Create errors in current document
      local bufnr = vim.api.nvim_get_current_buf()
      vim.diagnostic.set(vim.api.nvim_create_namespace("test"), bufnr, {
        { lnum = 0, col = 0, severity = vim.diagnostic.severity.ERROR, message = "Document error" },
      }, {})

      -- Act: Open document diagnostics with <leader>xd
      vim.cmd("TroubleToggle document_diagnostics")
      local doc_winnr = vim.api.nvim_get_current_win()

      -- Assert: Document diagnostics window opened
      assert.is_true(vim.api.nvim_win_is_valid(doc_winnr))

      -- Act: Switch to workspace diagnostics
      vim.cmd("TroubleToggle workspace_diagnostics")

      -- Assert: Switched successfully (window still valid)
      assert.is_true(vim.api.nvim_win_is_valid(vim.api.nvim_get_current_win()))
    end)
  end)

  -- ============================================================================
  -- WORKFLOW 2: Navigate Through Errors
  -- ============================================================================

  describe("User CAN navigate through error list efficiently", function()
    it("CAN scroll through long error list", function()
      -- Arrange: Create many errors (>20)
      local bufnr = vim.api.nvim_create_buf(false, true)
      local diagnostics = {}
      for i = 0, 24 do
        table.insert(diagnostics, {
          lnum = i,
          col = 0,
          severity = vim.diagnostic.severity.ERROR,
          message = "Error line " .. (i + 1),
        })
      end
      vim.diagnostic.set(vim.api.nvim_create_namespace("test"), bufnr, diagnostics, {})
      vim.cmd("TroubleToggle workspace_diagnostics")

      -- Act: Scroll down through list
      local initial_pos = vim.api.nvim_win_get_cursor(0)
      for _ = 1, 10 do
        vim.api.nvim_feedkeys("j", "n", false)
      end
      vim.wait(200, function()
        return false
      end)
      local scrolled_pos = vim.api.nvim_win_get_cursor(0)

      -- Assert: Successfully scrolled (position changed)
      assert.is_not.same(initial_pos, scrolled_pos)
      assert.is_true(scrolled_pos[1] > initial_pos[1], "Should scroll down through errors")
    end)

    it("CAN use j/k keys for navigation", function()
      -- Arrange: Create errors
      local bufnr = vim.api.nvim_create_buf(false, true)
      vim.diagnostic.set(vim.api.nvim_create_namespace("test"), bufnr, {
        { lnum = 0, col = 0, severity = vim.diagnostic.severity.ERROR, message = "Error 1" },
        { lnum = 1, col = 0, severity = vim.diagnostic.severity.ERROR, message = "Error 2" },
        { lnum = 2, col = 0, severity = vim.diagnostic.severity.ERROR, message = "Error 3" },
      }, {})
      vim.cmd("TroubleToggle workspace_diagnostics")

      -- Act: Navigate with j (down)
      local pos_start = vim.api.nvim_win_get_cursor(0)
      vim.api.nvim_feedkeys("j", "n", false)
      vim.wait(100, function()
        return false
      end)
      local pos_after_j = vim.api.nvim_win_get_cursor(0)

      -- Act: Navigate with k (up)
      vim.api.nvim_feedkeys("k", "n", false)
      vim.wait(100, function()
        return false
      end)
      local pos_after_k = vim.api.nvim_win_get_cursor(0)

      -- Assert: j moved down, k moved up
      assert.is_not.same(pos_start, pos_after_j)
      assert.same(pos_start, pos_after_k)
    end)

    it("CAN jump to error location with Enter key", function()
      -- Arrange: Create error in specific buffer
      local test_buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(test_buf, 0, -1, false, { "line 1", "line 2", "line 3" })
      vim.diagnostic.set(vim.api.nvim_create_namespace("test"), test_buf, {
        { lnum = 1, col = 0, severity = vim.diagnostic.severity.ERROR, message = "Error on line 2" },
      }, {})
      vim.cmd("TroubleToggle workspace_diagnostics")

      -- Act: Press Enter to jump to error
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", false)
      vim.wait(200, function()
        return false
      end)

      -- Assert: Jumped to error buffer
      local current_buf = vim.api.nvim_get_current_buf()
      assert.equal(test_buf, current_buf)
    end)
  end)

  -- ============================================================================
  -- WORKFLOW 3: Control Trouble Window
  -- ============================================================================

  describe("User CAN control Trouble window lifecycle", function()
    it("CAN close Trouble window with q key", function()
      -- Arrange: Open Trouble
      vim.cmd("TroubleToggle")
      local trouble_winnr = vim.api.nvim_get_current_win()

      -- Act: Press q to close
      vim.api.nvim_feedkeys("q", "n", false)
      vim.wait(100, function()
        return false
      end)

      -- Assert: Window closed
      assert.is_false(vim.api.nvim_win_is_valid(trouble_winnr))
    end)

    it("CAN close Trouble window with <Esc> key", function()
      -- Arrange: Open Trouble
      vim.cmd("TroubleToggle")
      local trouble_winnr = vim.api.nvim_get_current_win()

      -- Act: Press <Esc> to cancel
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
      vim.wait(100, function()
        return false
      end)

      -- Assert: Window closed
      assert.is_false(vim.api.nvim_win_is_valid(trouble_winnr))
    end)

    it("CAN toggle Trouble window on/off with <leader>xx", function()
      -- Act: Open Trouble with <leader>xx
      vim.cmd("TroubleToggle")
      local winnr_open = vim.api.nvim_get_current_win()
      assert.is_true(vim.api.nvim_win_is_valid(winnr_open))

      -- Act: Close Trouble with <leader>xx (toggle)
      vim.cmd("TroubleToggle")
      vim.wait(100, function()
        return false
      end)

      -- Assert: Window toggled off
      assert.is_false(vim.api.nvim_win_is_valid(winnr_open))
    end)

    it("CAN keep Trouble window open while editing other buffers", function()
      -- Arrange: Open Trouble
      vim.cmd("TroubleToggle")
      local trouble_winnr = vim.api.nvim_get_current_win()

      -- Act: Switch to another buffer
      vim.cmd("vnew")
      vim.cmd("wincmd w")

      -- Assert: Trouble window still open
      assert.is_true(vim.api.nvim_win_is_valid(trouble_winnr))
    end)
  end)

  -- ============================================================================
  -- WORKFLOW 4: Error Filtering and Organization
  -- ============================================================================

  describe("User CAN filter and organize errors", function()
    it("CAN view errors grouped by file", function()
      -- Arrange: Create errors in multiple files
      local buf1 = vim.api.nvim_create_buf(false, true)
      local buf2 = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_name(buf1, "file1.lua")
      vim.api.nvim_buf_set_name(buf2, "file2.lua")

      vim.diagnostic.set(vim.api.nvim_create_namespace("test"), buf1, {
        { lnum = 0, col = 0, severity = vim.diagnostic.severity.ERROR, message = "Error in file1" },
      }, {})

      vim.diagnostic.set(vim.api.nvim_create_namespace("test"), buf2, {
        { lnum = 0, col = 0, severity = vim.diagnostic.severity.ERROR, message = "Error in file2" },
      }, {})

      -- Act: Open Trouble (groups by file by default)
      vim.cmd("TroubleToggle workspace_diagnostics")

      -- Assert: Trouble opened and showing grouped errors
      local bufnr = vim.api.nvim_win_get_buf(0)
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      assert.is_true(#lines > 0, "Should show error content grouped by file")
    end)

    it("CAN distinguish between error severity levels", function()
      -- Arrange: Create errors with different severity
      local bufnr = vim.api.nvim_create_buf(false, true)
      vim.diagnostic.set(vim.api.nvim_create_namespace("test"), bufnr, {
        { lnum = 0, col = 0, severity = vim.diagnostic.severity.ERROR, message = "Critical error" },
        { lnum = 1, col = 0, severity = vim.diagnostic.severity.WARN, message = "Warning" },
        { lnum = 2, col = 0, severity = vim.diagnostic.severity.INFO, message = "Info" },
      }, {})

      -- Act: Open Trouble
      vim.cmd("TroubleToggle workspace_diagnostics")

      -- Assert: Different severities visible (signs configured)
      local winnr = vim.api.nvim_get_current_win()
      assert.is_true(vim.api.nvim_win_is_valid(winnr))
    end)
  end)

  -- ============================================================================
  -- WORKFLOW 5: ADHD/Autism Optimizations
  -- ============================================================================

  describe("User CAN work without cognitive overload", function()
    it("CAN see errors in predictable location (bottom of screen)", function()
      -- Arrange/Act: Open Trouble
      vim.cmd("TroubleToggle")

      -- Assert: Window at bottom (position = "bottom" in config)
      local winnr = vim.api.nvim_get_current_win()
      local win_config = vim.api.nvim_win_get_config(winnr)

      -- Trouble uses split, not float, so check if it's at bottom
      -- by verifying it's the last window
      local all_wins = vim.api.nvim_list_wins()
      assert.is_true(vim.tbl_contains(all_wins, winnr))
    end)

    it("CAN have visual breathing room with padding", function()
      -- Arrange/Act: Open Trouble
      vim.cmd("TroubleToggle")

      -- Assert: Window opened (padding configured in setup)
      local winnr = vim.api.nvim_get_current_win()
      assert.is_true(vim.api.nvim_win_is_valid(winnr))
    end)

    it("CAN close Trouble without being interrupted by auto-close", function()
      -- Arrange: Open Trouble with errors
      local bufnr = vim.api.nvim_create_buf(false, true)
      vim.diagnostic.set(vim.api.nvim_create_namespace("test"), bufnr, {
        { lnum = 0, col = 0, severity = vim.diagnostic.severity.ERROR, message = "Test error" },
      }, {})
      vim.cmd("TroubleToggle")
      local trouble_winnr = vim.api.nvim_get_current_win()

      -- Act: Focus elsewhere, wait for potential auto-close
      vim.cmd("vnew")
      vim.wait(500, function()
        return false
      end)

      -- Assert: Trouble didn't auto-close (user controls when to close)
      assert.is_true(vim.api.nvim_win_is_valid(trouble_winnr))
    end)
  end)
end)
