-- Plugin: Hologram
-- Purpose: Display images inline in Neovim using Kitty's graphics protocol
-- Workflow: utilities
-- Why: ADHD/visual thinkers benefit from seeing images directly in notes/documentation.
--      Reduces context switching (no need to open external viewer).
--      Academic writing: preview figures in LaTeX documents.
--      Zettelkasten: view diagrams and screenshots inline.
-- Config: minimal - auto-display for supported file types
--
-- Usage:
--   Automatic: Images display inline when cursor is near markdown image syntax
--   Manual: :Hologram to toggle image display
--
-- Supported formats: PNG, JPG, JPEG, GIF (via Kitty graphics protocol)
--
-- Dependencies: Kitty terminal with graphics protocol support
--
-- Limitations:
--   - Only works in Kitty terminal (not tmux, screen, or other terminals)
--   - Images don't persist across scrolling (Kitty protocol limitation)
--   - Some performance impact with many large images
--
-- Configuration Notes:
--   auto_display = true: Images show automatically (can be toggled)
--   Markdown image syntax: ![alt](path/to/image.png)
--   LaTeX syntax: \includegraphics{path/to/image.png}

return {
  "edluffy/hologram.nvim",
  enabled = true,
  lazy = true,
  ft = { "markdown", "tex", "org", "norg" }, -- Load for document types with images
  cmd = { "Hologram" },

  config = function()
    require("hologram").setup({
      -- Automatically display images
      auto_display = true,
    })

    vim.notify("🖼️  Hologram loaded (inline image preview via Kitty)", vim.log.levels.INFO)
  end,

  keys = {
    -- Toggle image display
    { "<leader>ti", "<cmd>Hologram<cr>", desc = "Toggle inline images" },
  },
}
