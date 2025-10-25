-- Plugin Test Initialization
-- Loads minimal_init.lua + actual plugins for plugin behavior testing

-- Load minimal test environment first
dofile("tests/minimal_init.lua")

-- Bootstrap lazy.nvim and load required plugins for testing
require("lazy").setup({
  -- Required: Plenary for testing
  { "nvim-lua/plenary.nvim", lazy = false },

  -- Required: Trouble plugin (what we're testing)
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
    config = function()
      -- Load the actual PercyBrain Trouble configuration
      local trouble_config = dofile("lua/plugins/diagnostics/trouble.lua")
      if trouble_config and trouble_config.config then
        trouble_config.config()
      end
    end,
  },

  -- Required: Web devicons dependency
  { "nvim-tree/nvim-web-devicons", lazy = false },
}, {
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-- Wait for plugins to load
vim.wait(1000, function()
  return package.loaded["trouble"] ~= nil
end)
