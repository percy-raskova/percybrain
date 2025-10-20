-- Floating Quick Capture Module
-- Ultra-fast note capture with minimal friction
-- Kent Beck TDD: "Make the tests pass, then make it right"

local M = {}

-- Module state
local state = {
  config = {
    inbox_dir = vim.fn.expand("~/Zettelkasten/inbox"),
    keybinding = "<leader>qc",
    auto_notify = true,
    save_delay_ms = 100,
    on_save_success = nil,
    on_save_error = nil,
  },
  current_window = nil,
  current_buffer = nil,
  previous_buffer = nil,
  save_in_progress = false,
}

-- ============================================================================
-- CONFIGURATION
-- ============================================================================

function M.setup(opts)
  -- Merge user config with defaults
  state.config = vim.tbl_deep_extend("force", state.config, opts or {})

  -- Register keybinding
  vim.keymap.set("n", state.config.keybinding, M.open_capture_window, {
    desc = "Open floating quick capture",
    silent = true,
  })

  return M
end

function M.get_default_keybinding()
  return state.config.keybinding
end

-- ============================================================================
-- WINDOW MANAGEMENT
-- ============================================================================

function M.get_window_config()
  -- Calculate centered window dimensions
  local width = math.floor(vim.o.columns * 0.6)
  local height = math.floor(vim.o.lines * 0.4)

  -- Ensure minimum dimensions
  width = math.max(width, 50)
  height = math.max(height, 5)

  -- Calculate centered position
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  return {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    border = "rounded",
    style = "minimal",
    focusable = true,
  }
end

-- Helper: Configure buffer options for scratch buffer
local function configure_buffer_options(buffer)
  local options = {
    buftype = "nofile", -- Scratch buffer (not associated with a file)
    bufhidden = "wipe", -- Delete buffer when hidden
    modifiable = true, -- Allow text editing
    filetype = "markdown", -- Enable markdown syntax highlighting
  }

  for option, value in pairs(options) do
    vim.api.nvim_buf_set_option(buffer, option, value)
  end
end

-- Helper: Register buffer-local keymaps
local function register_buffer_keymaps(buffer, keymaps)
  -- Save and close keymap
  vim.api.nvim_buf_set_keymap(buffer, "n", keymaps.save.key, "", {
    callback = M.save_and_close,
    desc = keymaps.save.desc,
    noremap = true,
    silent = true,
  })

  -- Cancel without saving keymap
  vim.api.nvim_buf_set_keymap(buffer, "n", keymaps.cancel.key, "", {
    callback = M.cancel_capture,
    desc = keymaps.cancel.desc,
    noremap = true,
    silent = true,
  })
end

-- Helper: Close floating window if valid
local function close_window_if_valid(window)
  if window and vim.api.nvim_win_is_valid(window) then
    vim.api.nvim_win_close(window, true)
  end
end

function M.create_capture_buffer()
  -- Create scratch buffer for capture
  local buffer = vim.api.nvim_create_buf(false, true)

  -- Configure buffer options
  configure_buffer_options(buffer)

  -- Register buffer-local keymaps
  local keymaps = M.get_buffer_keymaps()
  register_buffer_keymaps(buffer, keymaps)

  return buffer
end

function M.get_buffer_keymaps()
  return {
    save = {
      key = "<C-s>",
      desc = "Save and close quick capture",
    },
    cancel = {
      key = "<Esc>",
      desc = "Cancel quick capture",
    },
  }
end

function M.open_capture_window()
  -- Save current buffer for restoration
  state.previous_buffer = vim.api.nvim_get_current_buf()

  -- Create capture buffer
  state.current_buffer = M.create_capture_buffer()

  -- Get window configuration
  local win_config = M.get_window_config()

  -- Open floating window
  state.current_window = vim.api.nvim_open_win(state.current_buffer, true, win_config)

  -- Start insert mode for immediate typing
  vim.cmd("startinsert")

  return state.current_buffer
end

function M.cancel_capture()
  -- Close window without saving
  close_window_if_valid(state.current_window)

  -- Restore previous buffer
  M.restore_previous_buffer()

  -- Clear state
  state.current_window = nil
  state.current_buffer = nil
end

function M.restore_previous_buffer()
  if state.previous_buffer and vim.api.nvim_buf_is_valid(state.previous_buffer) then
    vim.api.nvim_set_current_buf(state.previous_buffer)
  end
end

-- ============================================================================
-- FILE MANAGEMENT
-- ============================================================================

function M.generate_filename()
  -- Generate timestamp-based filename: yyyymmdd-hhmmss.md
  local timestamp = os.date("%Y%m%d-%H%M%S")
  return timestamp .. ".md"
end

function M.get_save_path()
  local filename = M.generate_filename()
  local inbox_dir = state.config.inbox_dir

  -- Return path without creating directory
  -- Directory creation happens during save operation
  return inbox_dir .. "/" .. filename
end

-- ============================================================================
-- CONTENT FORMATTING
-- ============================================================================

function M.format_content(content)
  -- Add simple frontmatter (title + timestamp only)
  local timestamp = os.date("%Y-%m-%d %H:%M:%S")
  local title = content:match("^([^\n]+)") or "Fleeting thought"

  local frontmatter = string.format(
    [[---
title: "%s"
created: %s
---

%s]],
    title,
    timestamp,
    content
  )

  return frontmatter
end

-- ============================================================================
-- SAVE OPERATIONS
-- ============================================================================

function M.is_save_in_progress()
  return state.save_in_progress
end

function M.save_and_close()
  if state.save_in_progress then
    return false -- Already saving
  end

  -- Mark save in progress
  state.save_in_progress = true

  -- Get buffer content
  if not state.current_buffer or not vim.api.nvim_buf_is_valid(state.current_buffer) then
    state.save_in_progress = false
    return false
  end

  local lines = vim.api.nvim_buf_get_lines(state.current_buffer, 0, -1, false)
  local content = table.concat(lines, "\n")

  -- Skip empty captures
  if content:match("^%s*$") then
    M.cancel_capture()
    state.save_in_progress = false
    return false
  end

  -- Format content with frontmatter
  local formatted_content = M.format_content(content)

  -- Get save path
  local save_path = M.get_save_path()

  -- Close capture window and clear state
  close_window_if_valid(state.current_window)
  state.current_window = nil
  state.current_buffer = nil

  -- Async save to avoid blocking the editor
  -- Uses vim.schedule() to defer file I/O to the event loop
  -- This ensures the UI remains responsive during save operations
  vim.schedule(function()
    -- Wrap file operations in pcall to catch errors
    -- Errors are propagated to on_save_error callback for user handling
    local success, err = pcall(function()
      -- Create inbox directory if it doesn't exist
      -- Must be inside pcall to handle permission errors gracefully
      local dir = vim.fn.fnamemodify(save_path, ":h")
      if vim.fn.isdirectory(dir) == 0 then
        vim.fn.mkdir(dir, "p") -- Recursive creation with "p" flag
      end

      -- Write formatted content to file
      local file = io.open(save_path, "w")
      if not file then
        error("Could not open file for writing: " .. save_path)
      end

      file:write(formatted_content)
      file:close()
    end)

    -- Invoke appropriate callback based on save result
    -- Success: Notify user and trigger success callback
    -- Failure: Preserve content and trigger error callback
    if success then
      M.on_save_success(save_path)
    else
      M.on_save_error(err, formatted_content)
    end

    -- Clear save-in-progress flag to allow next capture
    state.save_in_progress = false
  end)

  -- Restore previous buffer immediately (non-blocking)
  M.restore_previous_buffer()

  return true
end

function M.on_save_success(save_path)
  -- Call user callback if provided
  if state.config.on_save_success then
    state.config.on_save_success(save_path)
  end

  -- Provide visual feedback if enabled
  if state.config.auto_notify then
    M.notify_save_success(save_path)
  end
end

function M.notify_save_success(save_path)
  local filename = vim.fn.fnamemodify(save_path, ":t")
  vim.notify("Captured: " .. filename, vim.log.levels.INFO)
end

function M.on_save_error(error_msg, preserved_content)
  -- Call user callback if provided
  if state.config.on_save_error then
    state.config.on_save_error(error_msg, preserved_content)
  end

  -- Provide error feedback
  if state.config.auto_notify then
    vim.notify("Save failed: " .. error_msg, vim.log.levels.ERROR)
  end

  -- Content recovery: preserved_content is passed to callback for user handling
end

-- ============================================================================
-- TEST UTILITIES
-- ============================================================================

function M.reset_state()
  -- Reset module state for testing
  state.current_window = nil
  state.current_buffer = nil
  state.previous_buffer = nil
  state.save_in_progress = false
end

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

-- Auto-setup with defaults if not explicitly configured
if not state.config.initialized then
  M.setup({})
  state.config.initialized = true
end

return M
