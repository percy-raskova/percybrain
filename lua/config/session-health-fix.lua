-- lua/config/session-health-fix.lua
-- Fix for auto-session missing 'localoptions' in sessionoptions
-- Ensures filetype and highlighting are preserved across session restore

local M = {}

-- Check if sessionoptions contains required options
local function validate_sessionoptions()
  local current_options = vim.o.sessionoptions
  local required_options = {
    "blank",
    "buffers",
    "curdir",
    "folds",
    "help",
    "tabpages",
    "winsize",
    "winpos",
    "terminal",
    "localoptions", -- Critical for preserving filetype/highlighting
  }

  local missing_options = {}
  for _, option in ipairs(required_options) do
    if not current_options:match(option) then
      table.insert(missing_options, option)
    end
  end

  return missing_options
end

-- Set correct sessionoptions
function M.fix_sessionoptions()
  local missing = validate_sessionoptions()

  if #missing == 0 then
    return true -- Already configured correctly
  end

  vim.notify(
    string.format("Fixing sessionoptions - adding missing: %s", table.concat(missing, ", ")),
    vim.log.levels.INFO,
    { title = "Session Health Fix" }
  )

  -- Set the complete recommended sessionoptions
  vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

  return true
end

-- Configure auto-session with proper settings
function M.configure_auto_session()
  -- Check if auto-session is loaded
  local has_auto_session, auto_session = pcall(require, "auto-session")
  if not has_auto_session then
    return false -- Auto-session not installed
  end

  -- Ensure sessionoptions is set before any session operations
  M.fix_sessionoptions()

  -- Add validation to auto-session hooks
  local original_save = auto_session.SaveSession
  local original_restore = auto_session.RestoreSession

  -- Wrap SaveSession to validate options
  auto_session.SaveSession = function(...)
    M.fix_sessionoptions() -- Ensure options are correct before save
    return original_save(...)
  end

  -- Wrap RestoreSession to validate options
  auto_session.RestoreSession = function(...)
    M.fix_sessionoptions() -- Ensure options are correct before restore
    return original_restore(...)
  end

  vim.notify(
    "Auto-session configured with proper sessionoptions",
    vim.log.levels.INFO,
    { title = "Session Health Fix" }
  )

  return true
end

-- Setup function to be called from init
function M.setup()
  -- Fix sessionoptions immediately
  M.fix_sessionoptions()

  -- Configure auto-session if available
  vim.defer_fn(function()
    M.configure_auto_session()
  end, 50)
end

return M
