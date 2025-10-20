-- Plugin: which-key
-- Purpose: Interactive keybinding popup showing available commands after leader key
-- Workflow: ui
-- Why: Critical for ADHD users - eliminates need to memorize keybindings. Shows available options
--      contextually after <leader> or other prefix keys. Reduces decision paralysis by presenting
--      organized choices. Learning aid for new users. Categorized groups (Find/File, Zettelkasten,
--      AI, etc.) provide mental scaffolding. 500ms delay balances discoverability with not
--      interrupting flow for experienced users.
-- Config: minimal - delay timing and leader key group labels
--
-- Usage:
--   Automatic: Press <leader> and wait 500ms - popup shows available commands
--   Navigate: Use displayed keys to complete command
--   Organized groups:
--     <leader>f - Find/File operations (Telescope)
--     <leader>z - Zettelkasten workflows (notes, links, AI)
--     <leader>a - AI assistant commands
--     <leader>t - Translate/Terminal
--     <leader>w - Window management
--
-- Dependencies: none (pure Neovim plugin)
--
-- Configuration Notes:
--   - delay = 500: Half-second wait before popup (balance discoverability vs interruption)
--   - Groups defined via wk.add() for organized categorization
--   - Separator "→" shows relationship between key and command
--   - VeryLazy loading: Doesn't slow down startup

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
