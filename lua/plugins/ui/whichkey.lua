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
    -- NORMAL MODE groups
    wk.add({
      -- Core workflows (high-frequency operations)
      { "<leader>n", group = "📝 Notes" }, -- Note creation/templates
      { "<leader>f", group = "🔍 Find/File" },
      { "<leader>z", group = "📓 Zettelkasten (IWE)" }, -- IWE LSP navigation
      { "<leader>zr", group = "🔧 Refactor" }, -- Zettelkasten refactoring subgroup
      { "<leader>za", group = "🤖 AI Transform" }, -- AI text transformations
      { "<leader>i", group = "📥 Inbox" },
      { "<leader>o", group = "🎯 Organize/GTD" }, -- Getting Things Done workflow
      { "<leader>h", group = "🚀 Publish" }, -- Hugo/mkdocs publishing

      -- AI and writing
      { "<leader>a", group = "🤖 AI" },
      { "<leader>p", group = "✏️ Prose" },

      -- Navigation and file management
      { "<leader>e", group = "🌳 Explorer" }, -- File tree (NvimTree)
      { "<leader>x", group = "📂 eXplore" }, -- File operations/focus
      { "<leader>y", group = "📁 Yazi" }, -- Yazi file manager

      -- Git and version control
      { "<leader>g", group = "📦 Git" },

      -- Tools and utilities
      { "<leader>t", group = "🌐 Terminal/Translate" },
      { "<leader>l", group = "🔗 Lynx" }, -- Browser
      { "<leader>m", group = "🔌 MCP" }, -- Model Context Protocol
      { "<leader>d", group = "🏠 Dashboard" },

      -- Window management
      { "<leader>w", group = "🪟 Windows" },
      { "<leader>v", group = "⚡ View/Split" },
      { "<leader>c", group = "❌ Close" },

      -- System operations
      { "<leader>s", group = "💾 Save/SemBr" }, -- Save and semantic line breaks
      { "<leader>q", group = "🚪 Quit" },
      { "<leader>u", group = "🕰️ Undo Tree" },
    })

    -- VISUAL MODE groups (text selection operations)
    -- Transform selected text into knowledge management primitives
    wk.add({
      -- Zettelkasten: Selection → Links/Notes/Quotes
      { "<leader>z", group = "📓 Zettelkasten Selection", mode = "v" },

      -- AI: Transform selected text with AI
      { "<leader>a", group = "🤖 AI Selection", mode = "v" },

      -- LSP: Code actions on selection
      { "<leader>c", group = "⚡ Code Actions", mode = "v" },
    })
  end,
}
