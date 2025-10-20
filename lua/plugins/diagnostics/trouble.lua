-- Trouble.nvim: Unified error aggregation for ADHD/autism
-- ONE place for ALL errors - no hunting through multiple systems
-- Repository: https://github.com/folke/trouble.nvim
-- Version: v3.7.1 (API updated for Trouble v3)

return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = "Trouble",
  keys = {
    -- Main trouble interface (x = diagnostics/errors)
    -- V3 API: Use "Trouble diagnostics" instead of "TroubleToggle"
    { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "🚨 Toggle diagnostics" },
    { "<leader>xw", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "📄 Buffer diagnostics" },
    { "<leader>xd", "<cmd>Trouble diagnostics toggle<cr>", desc = "📁 Workspace diagnostics" },
    { "<leader>xq", "<cmd>Trouble quickfix toggle<cr>", desc = "⚡ Quickfix list" },
    { "<leader>xl", "<cmd>Trouble loclist toggle<cr>", desc = "📍 Location list" },
    { "<leader>xr", "<cmd>Trouble lsp toggle<cr>", desc = "🔍 LSP references" },
    { "<leader>xs", "<cmd>Trouble symbols toggle<cr>", desc = "🔤 Document symbols" },

    -- Navigation (consistent with vim motions)
    {
      "[t",
      function()
        require("trouble").prev({ skip_groups = true, jump = true })
      end,
      desc = "⬆️ Previous trouble",
    },
    {
      "]t",
      function()
        require("trouble").next({ skip_groups = true, jump = true })
      end,
      desc = "⬇️ Next trouble",
    },
  },

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
