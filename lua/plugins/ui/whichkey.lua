return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  config = function()
    local wk = require("which-key")
    wk.setup({
      delay = 500, -- Time in ms to wait before showing the popup (500ms = half second)
      icons = {
        separator = "→", -- symbol between key and command
      },
    })

    -- Show helpful labels for your leader key groups
    wk.add({
      { "<leader>f", group = "Find/File" },
      { "<leader>t", group = "Translate/Terminal" },
      { "<leader>w", group = "Window Management" }, -- Updated: Now for window management
      { "<leader>z", group = "Zettelkasten" }, -- Added: For Zettelkasten/PercyBrain
      { "<leader>a", group = "AI/Assistant" }, -- Added: For AI features
    })
  end,
}
