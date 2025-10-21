-- Plugin: MCP Hub
-- Purpose: Browse and manage Model Context Protocol servers
-- Workflow: utilities
-- Config: minimal
-- Repository: https://github.com/ravitemer/mcphub.nvim

-- Import keymaps from central registry
local keymaps = require("config.keymaps.utilities")

return {
  "ravitemer/mcphub.nvim",
  lazy = true,
  cmd = { "MCPHub", "MCPHubOpen", "MCPHubInstall", "MCPHubList", "MCPHubUpdate" },
  keys = keymaps, -- All utility keymaps managed in lua/config/keymaps/utilities.lua
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    require("mcphub").setup({
      -- Auto-check for updates on startup
      auto_check_updates = true,

      -- Installation directory for MCP servers
      install_dir = vim.fn.stdpath("data") .. "/mcp-servers",

      -- Telescope picker configuration
      telescope = {
        theme = "dropdown",
        layout_config = {
          width = 0.8,
          height = 0.8,
        },
      },
    })

    vim.notify("🛍️  MCP Hub loaded", vim.log.levels.INFO)
  end,
}
