--- GTD Capture Module
---
--- Implements David Allen's GTD Capture workflow - the first step in GTD methodology.
--- "Capture everything that has your attention. Anything incomplete must be
--- captured in a trusted system outside your mind." - David Allen
---
--- Features:
--- - Quick one-line capture with minimal friction
--- - Multi-line capture buffer for detailed items
--- - Automatic timestamp tracking for accountability
--- - Checkbox format compatible with mkdnflow.nvim todo system
---
--- GTD Capture Principles:
--- 1. Ubiquitous Capture: Get it out of your head immediately
--- 2. Minimal Friction: Don't think, don't organize - just capture
--- 3. Trust the System: Everything gets reviewed later in Clarify workflow
--- 4. No Evaluation: Capture now, decide later
---
--- @module lib.gtd.capture
--- @author PercyBrain
--- @license MIT

local M = {}

-- ============================================================================
-- Public API Functions
-- ============================================================================

--- Get current timestamp in GTD format (YYYY-MM-DD HH:MM)
---
--- Used for tracking when items were captured. This creates accountability
--- and helps identify aging items during weekly reviews.
---
--- @return string Timestamp in "YYYY-MM-DD HH:MM" format
--- @usage local timestamp = require("lib.gtd.capture").get_timestamp()
function M.get_timestamp()
  return os.date("%Y-%m-%d %H:%M")
end

--- Format a task item with checkbox and timestamp
---
--- Creates a markdown checkbox item in the format:
--- - [ ] Task description (captured: YYYY-MM-DD HH:MM)
---
--- This format is compatible with mkdnflow.nvim's hierarchical todo system,
--- allowing state cycling: [ ] → [-] → [x]
---
--- @param text string The task description to format
--- @return string Formatted task item with checkbox and timestamp
--- @usage local formatted = capture.format_task_item("Buy groceries")
--- -- Returns: "- [ ] Buy groceries (captured: 2025-10-21 14:30)"
function M.format_task_item(text)
  local timestamp = M.get_timestamp()
  return string.format("- [ ] %s (captured: %s)", text, timestamp)
end

--- Get inbox file path from GTD core module
---
--- @return string Absolute path to inbox.md
--- @private
local function _get_inbox_path()
  local gtd = require("lib.gtd")
  return gtd.get_inbox_path()
end

--- Append lines to inbox file (internal helper)
---
--- This is a private helper function for atomic file operations.
--- It reads the existing inbox, appends new lines, and writes back atomically.
---
--- @param lines table Array of lines to append
--- @private
local function _append_to_inbox(lines)
  local inbox_path = _get_inbox_path()

  -- Read existing content
  local file = io.open(inbox_path, "r")
  local existing_content = {}
  if file then
    for line in file:lines() do
      table.insert(existing_content, line)
    end
    file:close()
  end

  -- Append new lines
  for _, line in ipairs(lines) do
    table.insert(existing_content, line)
  end

  -- Write back to file (atomic replacement)
  file = io.open(inbox_path, "w")
  if file then
    for _, line in ipairs(existing_content) do
      file:write(line .. "\n")
    end
    file:close()
  end
end

--- Quick capture - append single item to inbox with minimal friction
---
--- This is the primary GTD capture method. Use it for:
--- - Quick thoughts that pop into your mind
--- - Tasks you need to remember
--- - Ideas worth exploring later
--- - Commitments you make to others
---
--- Design: Optimized for ADHD/neurodivergent workflows - no prompts, no decisions,
--- just immediate capture. The item goes straight to inbox for later processing.
---
--- @param text string|nil The text to capture (empty/nil input is ignored)
--- @usage
--- -- From command line
--- :lua require("lib.gtd.capture").quick_capture("Call dentist")
---
--- -- From keybinding
--- vim.keymap.set("n", "<leader>gc", function()
---   local text = vim.fn.input("Quick capture: ")
---   require("lib.gtd.capture").quick_capture(text)
--- end)
function M.quick_capture(text)
  -- Validate input: empty captures are ignored (fail silently)
  if not text or text == "" then
    return
  end

  -- Format with checkbox and timestamp
  local formatted = M.format_task_item(text)

  -- Append to inbox file
  _append_to_inbox({ formatted })
end

--- Create a capture buffer for detailed multi-line capture
---
--- Use this when you need to capture:
--- - Meeting notes with multiple points
--- - Complex ideas requiring elaboration
--- - Project outlines or brainstorms
--- - Anything that doesn't fit in a single line
---
--- Workflow:
--- 1. Create buffer with this function
--- 2. Display in window (floating or split)
--- 3. User writes content
--- 4. Commit with M.commit_capture_buffer(bufnr)
---
--- @return number Buffer number of the created scratch buffer
--- @usage
--- local capture = require("lib.gtd.capture")
--- local bufnr = capture.create_capture_buffer()
---
--- -- Display in floating window
--- vim.api.nvim_open_win(bufnr, true, {
---   relative = "editor",
---   width = 80,
---   height = 20,
---   row = 5,
---   col = 10,
--- })
function M.create_capture_buffer()
  -- Create scratch buffer (not listed, no file backing)
  local bufnr = vim.api.nvim_create_buf(false, true)

  -- Configure as markdown for syntax highlighting
  vim.api.nvim_buf_set_option(bufnr, "filetype", "markdown")

  -- Set as nofile buffer (scratch, not saved to disk directly)
  vim.api.nvim_buf_set_option(bufnr, "buftype", "nofile")

  return bufnr
end

--- Commit capture buffer content to inbox and delete the buffer
---
--- Final step in multi-line capture workflow. This:
--- 1. Reads all content from the buffer
--- 2. Appends to inbox.md
--- 3. Deletes the capture buffer
---
--- Design: Atomic operation - either all content is saved or none.
--- Buffer is always deleted after commit to prevent stale capture windows.
---
--- @param bufnr number Buffer number to commit (from create_capture_buffer)
--- @usage
--- local capture = require("lib.gtd.capture")
--- local bufnr = capture.create_capture_buffer()
--- -- ... user writes content ...
--- capture.commit_capture_buffer(bufnr)  -- Saves and closes
function M.commit_capture_buffer(bufnr)
  -- Get all lines from buffer
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  -- Append to inbox (only if buffer has content)
  if #lines > 0 then
    _append_to_inbox(lines)
  end

  -- Delete buffer (force to avoid "unsaved changes" prompts)
  if vim.api.nvim_buf_is_valid(bufnr) then
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end
end

return M
