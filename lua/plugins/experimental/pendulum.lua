-- Plugin: Pendulum
-- Purpose: Time tracking and task management
-- Workflow: experimental
-- Config: full

-- Import keymaps from central registry (time-tracking moved to organization/)

return {
  "ptdewey/pendulum-nvim",
  cmd = { "PendulumStart", "PendulumStop", "PendulumStatus", "PendulumReport" },
  -- keys = {}, -- TODO: Add keybindings here -- All toggle keymaps managed in lua/config/keymaps/toggle.lua
  config = function()
    require("pendulum").setup({
      -- Time tracking log location
      log_file = vim.fn.expand("~/Zettelkasten/.pendulum.log"),

      -- Timer settings
      timer_interval = 60, -- Update interval in seconds

      -- Display settings
      show_seconds = true,

      -- Auto-save
      auto_save = true,

      -- Integration with status line
      status_line = true,
    })

    vim.notify("⏱️  Pendulum loaded - Time tracking ready", vim.log.levels.INFO)
  end,
}
