-- Plugin: Kitty Scrollback
-- Purpose: Open Kitty scrollback buffer inside Neovim for searching and copying
-- Workflow: utilities
-- Why: ADHD optimization - unified interface for all text interaction.
--      Search through terminal output with Telescope/grep instead of scrolling.
--      Copy commands and output without leaving Neovim.
--      Review long command output in familiar editing environment.
-- Config: full - Telescope integration enabled
--
-- Usage:
--   Kitty keybinding (set in kitty.conf):
--     Ctrl+Shift+H - Open scrollback in Neovim
--
--   Inside scrollback buffer:
--     / or ? - Search with Neovim
--     <leader>fg - Live grep through scrollback (Telescope)
--     y - Yank/copy text
--     q - Close scrollback
--
-- Dependencies: Kitty terminal, Telescope (optional but recommended)
--
-- Kitty Configuration Required (~/.config/kitty/kitty.conf):
--   # Open scrollback in Neovim
--   map ctrl+shift+h kitty_scrollback_nvim
--
--   # Or for pager mode (less-like experience)
--   map ctrl+shift+g kitty_scrollback_nvim --config ksb_builtin_last_cmd_output

return {
  "mikesmithgh/kitty-scrollback.nvim",
  enabled = true,
  lazy = true,
  cmd = { "KittyScrollbackGenerateKittens", "KittyScrollbackCheckHealth" },
  event = { "User KittyScrollbackLaunch" },

  config = function()
    require("kitty-scrollback").setup({
      -- Behavior
      restore_options = true, -- Restore Neovim options after closing scrollback
      highlight_overrides = {
        -- Blood Moon theme integration (optional - matches percybrain-theme.lua)
        KittyScrollbackNvimVisual = { bg = "#2a0a0a", fg = "#ffd700" },
        KittyScrollbackNvimStatusline = { bg = "#1a0000", fg = "#e8e8e8" },
      },

      -- Keybindings inside scrollback
      keymaps_enabled = true,

      -- Paste window configuration
      paste_window = {
        -- Minimal paste window (ADHD-friendly: focused, predictable)
        winopts_overrides = function(paste_winopts)
          paste_winopts.border = "rounded"
          paste_winopts.title = " 📋 Paste "
          paste_winopts.title_pos = "center"
          return paste_winopts
        end,
      },

      -- Status window configuration
      status_window = {
        enabled = true,
        style_simple = false, -- Show detailed status
        autoclose = true, -- Auto-close after success
        show_timer = true, -- Show operation duration
        icons = {
          kitty = "😸",
          heart = "❤️",
          nvim = "🌙",
        },
      },

      -- Kitty integration
      kitty_get_text = {
        -- Extent: 'screen' | 'all' | 'selection'
        extent = "all", -- Get full scrollback by default
        ansi = true, -- Preserve ANSI colors
      },
    })

    vim.notify("😽 Kitty Scrollback loaded! Use Ctrl+Shift+H in Kitty", vim.log.levels.INFO)
  end,
}
