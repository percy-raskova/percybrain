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
      require("percybrain.dashboard").setup()

      -- Setup dashboard menu under <leader>d
      require("percybrain.dashboard-menu").setup()

      -- Setup Hugo menu under <leader>h
      require("percybrain.hugo-menu").setup()

      vim.notify("🤖 PercyBrain Dashboard + Hugo menus loaded", vim.log.levels.INFO)
    end,
  },
}
