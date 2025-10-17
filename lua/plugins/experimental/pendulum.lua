-- Plugin: Pendulum
-- Purpose: Time tracking and task management
-- Workflow: experimental
-- Config: full

return {
  "ptdewey/pendulum-nvim",
  cmd = { "PendulumStart", "PendulumStop", "PendulumStatus", "PendulumReport" },
  keys = {
    { "<leader>ts", "<cmd>PendulumStart<cr>", desc = "Start time tracking" },
    { "<leader>te", "<cmd>PendulumStop<cr>", desc = "Stop time tracking" },
    { "<leader>tt", "<cmd>PendulumStatus<cr>", desc = "Time tracking status" },
    { "<leader>tr", "<cmd>PendulumReport<cr>", desc = "Time tracking report" },
  },
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
