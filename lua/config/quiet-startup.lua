-- Quiet Startup: Suppress verbose plugin notifications
-- Problem: Each plugin shows "Plugin X loaded" notification
-- Solution: Replace vim.notify with silent version during startup

local M = {}

local original_notify = vim.notify
local startup_notifications = {}
local startup_complete = false

-- Silent notify function that collects messages during startup
local function quiet_notify(msg, level, opts)
  if startup_complete then
    -- After startup, use normal notifications
    original_notify(msg, level, opts)
  else
    -- During startup, collect but don't show
    table.insert(startup_notifications, {
      msg = msg,
      level = level or vim.log.levels.INFO,
    })
  end
end

-- Setup quiet startup mode
function M.setup()
  -- Replace vim.notify during startup
  vim.notify = quiet_notify

  -- After all plugins loaded, restore notifications and show summary
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    once = true,
    callback = function()
      -- Restore original notify
      vim.notify = original_notify
      startup_complete = true

      -- Show single consolidated notification
      local plugin_count = 0
      local important_messages = {}

      for _, notif in ipairs(startup_notifications) do
        if notif.msg:match("loaded") then
          plugin_count = plugin_count + 1
        elseif notif.level >= vim.log.levels.WARN then
          table.insert(important_messages, notif.msg)
        end
      end

      -- Single startup summary (doesn't require Enter press)
      if plugin_count > 0 then
        vim.notify(
          string.format("🧠 PercyBrain ready (%d plugins loaded)", plugin_count),
          vim.log.levels.INFO,
          { timeout = 2000 }
        )
      end

      -- Show important messages if any
      for _, msg in ipairs(important_messages) do
        vim.notify(msg, vim.log.levels.WARN)
      end
    end,
  })
end

return M
