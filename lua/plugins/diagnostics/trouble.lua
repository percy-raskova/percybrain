-- Trouble.nvim: Unified error aggregation for ADHD/autism
-- ONE place for ALL errors - no hunting through multiple systems
-- Repository: https://github.com/folke/trouble.nvim
-- Version: v3.7.1 (API updated for Trouble v3)

-- Import keymaps from central registry
local keymaps = require("config.keymaps.tools.diagnostics")

return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = "Trouble",
  keys = keymaps, -- All trouble keymaps managed in lua/config/keymaps/diagnostics.lua

  opts = {
    -- V3 API: Simplified configuration
    -- ADHD/Autism optimizations
    auto_close = false, -- Don't auto-close when buffer is solved
    auto_open = false, -- Don't auto-open on diagnostics
    auto_preview = true, -- Show preview of issue
    auto_refresh = true, -- Auto-refresh diagnostics
    focus = true, -- Focus trouble window when opened

    -- Window configuration
    position = "bottom", -- Predictable location
    height = 10, -- Consistent size
    width = 50, -- Width for side position

    -- Visual preferences (Blood Moon theme integration)
    modes = {
      diagnostics = {
        -- Default mode for <leader>xx
        mode = "diagnostics",
        preview = {
          type = "split",
          relative = "win",
          position = "right",
          size = 0.3,
        },
      },
    },

    -- Icons (consistent with PercyBrain aesthetic)
    icons = {
      indent = {
        fold_open = "▼",
        fold_closed = "▶",
      },
      folder_closed = "▶",
      folder_open = "▼",
    },

    -- Keys for navigation within Trouble window
    keys = {
      ["?"] = "help",
      q = "close",
      ["<esc>"] = "cancel",
      ["<cr>"] = "jump",
      ["<2-leftmouse>"] = "jump",
      o = "jump_close",
      ["<c-s>"] = "jump_split",
      ["<c-v>"] = "jump_vsplit",
      ["<c-t>"] = "jump_tab",
      j = "next",
      k = "prev",
      dd = "delete",
      d = { action = "delete", mode = "v" },
      r = "refresh",
      R = "toggle_refresh",
      gb = "toggle_fold",
      P = "toggle_preview",
      p = "preview",
      K = "hover",
    },
  },

  config = function(_, opts)
    require("trouble").setup(opts)

    -- Visual feedback
    vim.notify("🚨 Trouble.nvim v3 loaded! All errors in one place.", vim.log.levels.INFO)
  end,
}
