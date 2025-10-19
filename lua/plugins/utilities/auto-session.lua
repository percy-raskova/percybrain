-- Auto-session.nvim: State persistence for ADHD/autism
-- Resume EXACTLY where you left off - no context loss
-- Repository: https://github.com/rmagatti/auto-session

return {
  "rmagatti/auto-session",
  lazy = false, -- Load immediately for session restoration
  config = function()
    require("auto-session").setup({
      -- Session management
      auto_session_enabled = true,
      auto_save_enabled = true,
      auto_restore_enabled = true,

      -- Where to save sessions
      auto_session_root_dir = vim.fn.stdpath("data") .. "/sessions/",

      -- Don't restore for these
      auto_session_suppress_dirs = {
        "/",
        "~/",
        "~/Downloads",
        "/tmp",
      },

      -- ADHD/Autism optimizations
      auto_session_create_enabled = true, -- Always create session (no lost state)
      auto_session_enable_last_session = false, -- Don't auto-load last (predictable)

      -- What to save in session
      sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions",

      -- Pre/post hooks
      pre_save_cmds = {
        -- Close trouble before saving (cleaner restore)
        "TroubleClose",
        -- Close any floating windows
        function()
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local config = vim.api.nvim_win_get_config(win)
            if config.relative ~= "" then
              vim.api.nvim_win_close(win, false)
            end
          end
        end,
        -- Remember if NvimTree was open
        function()
          vim.g.nvim_tree_was_open = require("nvim-tree.view").is_visible()
        end,
      },

      post_restore_cmds = {
        -- Restore NvimTree if it was open
        function()
          local nvim_tree_api = require("nvim-tree.api")
          if vim.g.nvim_tree_was_open then
            nvim_tree_api.tree.open()
          end
        end,
      },

      -- Session lens integration (visual session picker)
      session_lens = {
        load_on_setup = false, -- Don't auto-show (reduces decisions)
        theme_conf = { border = true },
        previewer = false, -- No preview (simpler)
      },
    })

    -- Keybindings for manual control
    vim.keymap.set("n", "<leader>ss", "<cmd>SessionSave<CR>", { desc = "💾 Save session" })
    vim.keymap.set("n", "<leader>sr", "<cmd>SessionRestore<CR>", { desc = "📂 Restore session" })
    vim.keymap.set("n", "<leader>sd", "<cmd>SessionDelete<CR>", { desc = "🗑️ Delete session" })
    vim.keymap.set("n", "<leader>sf", "<cmd>Autosession search<CR>", { desc = "🔍 Find session" })

    -- Auto-save notification (subtle)
    vim.api.nvim_create_autocmd("VimLeavePre", {
      callback = function()
        vim.notify("📂 Session saved!", vim.log.levels.INFO)
      end,
    })

    -- Restore notification (using User autocmd pattern)
    vim.api.nvim_create_autocmd("User", {
      pattern = "SessionRestored",
      callback = function()
        vim.notify("✨ Session restored! Welcome back.", vim.log.levels.INFO)
      end,
    })

    -- Initial notification
    vim.notify("📂 Auto-session enabled! State persists across restarts.", vim.log.levels.INFO)
  end,
}
