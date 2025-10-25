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
  opts = {
    delay = 500, -- Time in ms to wait before showing the popup (500ms = half second)
    icons = {
      separator = "→", -- symbol between key and command
    },
    spec = {
      -- NORMAL MODE namespace labels
      { "<leader>n", group = "📝 Notes" },
      { "<leader>f", group = "🔍 Find/File" },
      { "<leader>z", group = "📓 Zettelkasten (IWE)" },
      { "<leader>zr", group = "🔧 Refactor" },
      { "<leader>za", group = "🤖 AI Transform" },
      { "<leader>i", group = "📥 Inbox" },
      { "<leader>o", group = "🎯 Organize/GTD" },
      { "<leader>h", group = "🚀 Publish" },
      { "<leader>a", group = "🤖 AI" },
      { "<leader>p", group = "✏️ Prose" },
      { "<leader>e", group = "🌳 Explorer" },
      { "<leader>x", group = "📂 eXplore" },
      { "<leader>y", group = "📁 Yazi" },
      { "<leader>g", group = "📦 Git" },
      { "<leader>t", group = "🌐 Terminal/Translate" },
      { "<leader>l", group = "🔗 Lynx" },
      { "<leader>m", group = "🔌 MCP" },
      { "<leader>d", group = "🏠 Dashboard" },
      { "<leader>w", group = "🪟 Windows" },
      { "<leader>v", group = "⚡ View/Split" },
      { "<leader>c", group = "❌ Close" },
      { "<leader>s", group = "💾 Session" },
      { "<leader>q", group = "🚪 Quit" },
      { "<leader>u", group = "🕰️ Undo Tree" },

      -- VISUAL MODE namespace labels
      { "<leader>z", group = "📓 Zettelkasten Selection", mode = "v" },
      { "<leader>a", group = "🤖 AI Selection", mode = "v" },
      { "<leader>c", group = "⚡ Code Actions", mode = "v" },
    },
  },
}
