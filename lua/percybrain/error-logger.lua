-- Simple error viewing using Neovim's built-in capabilities
local M = {}

-- Use Neovim's built-in error tracking
function M.show_errors()
  -- Open a new split with messages
  vim.cmd("new")
  vim.cmd("setlocal buftype=nofile bufhidden=wipe noswapfile")
  vim.cmd("file PercyBrain-Errors")

  -- Capture all messages (including errors)
  vim.cmd("redir => messages")
  vim.cmd("silent messages")
  vim.cmd("redir END")

  -- Put them in the buffer
  local lines = vim.split(vim.api.nvim_eval("messages"), "\n")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)

  -- Go to the end to see latest
  vim.cmd("normal G")

  -- Make it easy to close
  vim.keymap.set("n", "q", ":close<CR>", { buffer = true, silent = true })
  vim.keymap.set("n", "<Esc>", ":close<CR>", { buffer = true, silent = true })
end

-- Run checkhealth and capture output
function M.check_health()
  vim.cmd("checkhealth")
end

-- Show startup log (if running with verbose)
function M.show_startup_log()
  local log_file = vim.fn.stdpath("data") .. "/percybrain-startup.log"
  if vim.fn.filereadable(log_file) == 1 then
    vim.cmd("split " .. log_file)
  else
    vim.notify("No startup log found. Run nvim with -V10" .. log_file .. " to create one", vim.log.levels.INFO)
  end
end

-- Quick commands to access these
vim.api.nvim_create_user_command("PercyErrors", M.show_errors, { desc = "Show all Neovim errors/messages" })
vim.api.nvim_create_user_command("PercyHealth", M.check_health, { desc = "Run checkhealth" })
vim.api.nvim_create_user_command("PercyStartupLog", M.show_startup_log, { desc = "Show verbose startup log" })

-- Add keybindings
vim.keymap.set("n", "<leader>pe", M.show_errors, { desc = "PercyBrain errors" })
vim.keymap.set("n", "<leader>ph", M.check_health, { desc = "PercyBrain health check" })

-- Use vim.notify to capture errors in real-time
local original_notify = vim.notify
vim.notify = function(msg, level, opts)
  -- Store errors in a global table for easy access
  if level == vim.log.levels.ERROR or level == vim.log.levels.WARN then
    vim.g.percybrain_errors = vim.g.percybrain_errors or {}
    table.insert(vim.g.percybrain_errors, {
      time = os.date("%H:%M:%S"),
      level = level == vim.log.levels.ERROR and "ERROR" or "WARN",
      msg = msg,
    })
  end
  -- Call original notify
  original_notify(msg, level, opts)
end

-- Function to show just today's errors
function M.show_recent_errors()
  local errors = vim.g.percybrain_errors or {}
  if #errors == 0 then
    vim.notify("No errors logged in this session", vim.log.levels.INFO)
    return
  end

  vim.cmd("new")
  vim.cmd("setlocal buftype=nofile bufhidden=wipe noswapfile")
  vim.cmd("file Recent-PercyBrain-Errors")

  local lines = { "=== Recent PercyBrain Errors ===" }
  for _, err in ipairs(errors) do
    table.insert(lines, string.format("[%s] %s: %s", err.time, err.level, err.msg))
  end

  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.keymap.set("n", "q", ":close<CR>", { buffer = true, silent = true })
end

vim.api.nvim_create_user_command("PercyRecent", M.show_recent_errors, { desc = "Show recent errors" })

return M
