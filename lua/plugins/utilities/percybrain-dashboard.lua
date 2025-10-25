-- PercyBrain Dashboard and Network Visualization
-- Loads AI dashboard and Hugo publishing menus

return {
  {
    "percybrain-dashboard",
    dir = vim.fn.stdpath("config"),
    lazy = false,
    priority = 100,
    config = function()
      -- Setup dashboard with auto-analyze on save
      require("lib.dashboard").setup()

      -- Setup dashboard menu under <leader>d
      require("lib.dashboard-menu").setup()

      -- Setup Hugo menu under <leader>h
      require("lib.hugo-menu").setup()

      vim.notify("🤖 PercyBrain Dashboard + Hugo menus loaded", vim.log.levels.INFO)
    end,
  },
}
