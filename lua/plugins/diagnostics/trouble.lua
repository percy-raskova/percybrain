-- Trouble.nvim: Unified error aggregation for ADHD/autism
-- ONE place for ALL errors - no hunting through multiple systems
-- Repository: https://github.com/folke/trouble.nvim

return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = { "Trouble", "TroubleToggle" },
  keys = {
    -- Main trouble interface (x = diagnostics/errors)
    { "<leader>xx", "<cmd>TroubleToggle<cr>", desc = "🚨 Toggle trouble list" },
    { "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "📁 Workspace diagnostics" },
    { "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "📄 Document diagnostics" },
    { "<leader>xq", "<cmd>TroubleToggle quickfix<cr>", desc = "⚡ Quickfix list" },
    { "<leader>xl", "<cmd>TroubleToggle loclist<cr>", desc = "📍 Location list" },
    { "<leader>xr", "<cmd>TroubleToggle lsp_references<cr>", desc = "🔍 LSP references" },

    -- Navigation (consistent with vim motions)
    {
      "[t",
      function()
        require("trouble").previous({ skip_groups = true, jump = true })
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

  config = function()
    require("trouble").setup({
      -- ADHD optimizations
      auto_open = false, -- Don't auto-open (reduces interruptions)
      auto_close = true, -- Auto-close when solved (clean workspace)
      auto_preview = true, -- Preview errors (visual feedback)
      auto_fold = false, -- Show all errors (no hidden surprises)

      -- Autism optimizations
      use_diagnostic_signs = true, -- Consistent with LSP signs
      position = "bottom", -- Predictable location
      height = 10, -- Consistent size

      -- Visual preferences (Blood Moon theme integration)
      mode = "workspace_diagnostics", -- Default to show everything
      group = true, -- Group by file
      padding = true, -- Visual breathing room

      -- Icons (consistent with PercyBrain aesthetic)
      icons = true,
      fold_open = "▼",
      fold_closed = "▶",
      indent_lines = true,

      -- Signs (integrate with theme)
      signs = {
        error = "❌",
        warning = "⚠️",
        hint = "💡",
        information = "ℹ️",
        other = "❓",
      },

      -- Action keys (vim-consistent)
      action_keys = {
        close = "q", -- Quit
        cancel = "<esc>", -- Escape
        refresh = "r", -- Refresh
        jump = { "<cr>", "<tab>" }, -- Jump to location
        open_split = { "<c-s>" }, -- Split horizontal
        open_vsplit = { "<c-v>" }, -- Split vertical
        open_tab = { "<c-t>" }, -- New tab
        jump_close = { "o" }, -- Jump and close
        toggle_mode = "m", -- Toggle between modes
        toggle_preview = "P", -- Toggle preview
        hover = "K", -- Hover
        preview = "p", -- Preview
        close_folds = { "zM", "zm" }, -- Close folds
        open_folds = { "zR", "zr" }, -- Open folds
        toggle_fold = { "zA", "za" }, -- Toggle fold
        previous = "k", -- Previous item
        next = "j", -- Next item
      },
    })

    -- Visual feedback
    vim.notify("🚨 Trouble.nvim loaded! All errors in one place.", vim.log.levels.INFO)
  end,
}
