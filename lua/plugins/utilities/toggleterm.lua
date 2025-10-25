-- Plugin: toggleterm
-- Purpose: Persistent terminal windows with toggle/multi-terminal support
-- Workflow: utilities
-- Why: Seamless terminal integration - provides persistent terminal buffers that
--      toggle on/off without losing state, reducing context switching overhead.
--      ADHD-optimized through quick toggle keybinding (instant access), state
--      persistence (don't lose running processes), and multiple terminal support
--      (separate contexts for different tasks). Critical for running Quartz preview,
--      Git operations, and shell commands without leaving editor.
-- Config: full - ADHD-optimized with persistent state and quick toggle
--
-- Usage:
--   Terminal modes:
--     <leader>tt - Toggle terminal (last used layout)
--     <leader>tf - Floating terminal
--     <leader>th - Horizontal split terminal
--     <leader>tv - Vertical split terminal
--
--   Time utilities (writer convenience):
--     <leader>td - Insert date (YYYY-MM-DD)
--     <leader>ts - Insert timestamp (YYYYMMDDHHmmss)
--     <leader>tn - Insert datetime (YYYY-MM-DD HH:MM)
--
--   Quick access:
--     <leader>tm - Mise runner terminal
--     <leader>tg - LazyGit terminal
--
--   Global:
--     <C-\> - Toggle terminal from any mode
--
-- Dependencies: none

return {
  "akinsho/toggleterm.nvim",
  version = "*",

  keys = {
    -- Terminal modes
    { "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
    { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Terminal: Float" },
    { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Terminal: Horizontal" },
    { "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", desc = "Terminal: Vertical" },

    -- Time utilities (writer convenience)
    { "<leader>td", "<cmd>put =strftime('%Y-%m-%d')<cr>", desc = "Insert date" },
    { "<leader>ts", "<cmd>put =strftime('%Y%m%d%H%M%S')<cr>", desc = "Insert timestamp" },
    { "<leader>tn", "<cmd>put =strftime('%Y-%m-%d %H:%M')<cr>", desc = "Insert datetime" },

    -- Quick access to common terminals
    { "<leader>tm", "<cmd>ToggleTerm direction=float<cr>mise<cr>", desc = "Terminal: Mise runner" },
    { "<leader>tg", "<cmd>ToggleTerm direction=float<cr>lazygit<cr>", desc = "Terminal: LazyGit" },
  },

  config = function()
    require("toggleterm").setup({
      -- ADHD optimizations
      size = 20, -- Predictable size
      open_mapping = [[<c-\>]], -- Quick toggle from any mode
      hide_numbers = true, -- Reduce visual clutter
      shade_terminals = true, -- Visual distinction from editor
      start_in_insert = true, -- Ready to type immediately
      insert_mappings = true, -- <C-\> works in insert mode
      terminal_mappings = true, -- <C-\> works in terminal mode
      persist_size = true, -- Remember size across toggles
      persist_mode = true, -- Remember insert/normal mode
      direction = "float", -- Default to floating (less disruptive)
      close_on_exit = true, -- Clean up finished processes
      shell = vim.o.shell, -- Use system shell

      -- Floating terminal config (ADHD-friendly: focused, centered)
      float_opts = {
        border = "curved", -- Aesthetic + clear boundaries
        winblend = 0, -- No transparency (clearer text)
      },
    })

    vim.notify("💻 ToggleTerm loaded (Ctrl+\\ to toggle)", vim.log.levels.INFO)
  end,
}
