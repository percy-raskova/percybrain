-- Plugin: Goyo
-- Purpose: Distraction-free writing mode
-- Workflow: prose-writing/distraction-free
-- Config: full

return {
  "junegunn/goyo.vim",
  cmd = "Goyo", -- Lazy load on command
  keys = {
    { "<leader>o", "<cmd>Goyo<cr>", desc = "Toggle Goyo mode" },
  },
  config = function()
    -- Goyo dimensions
    vim.g.goyo_width = 100 -- Width of Goyo window (columns)
    vim.g.goyo_height = "85%" -- Height of Goyo window (percentage)
    vim.g.goyo_linenr = 0 -- Disable line numbers in Goyo mode

    -- Auto-commands for Goyo events
    vim.api.nvim_create_autocmd("User", {
      pattern = "GoyoEnter",
      callback = function()
        -- Enable Limelight when entering Goyo
        vim.cmd("Limelight")
        -- Disable vim-gitgutter signs
        if vim.fn.exists(":GitGutterDisable") then
          vim.cmd("GitGutterDisable")
        end
        -- Disable tmux status bar if in tmux
        if vim.env.TMUX then
          vim.fn.system("tmux set status off")
          vim.fn.system("tmux list-panes -F '\\#F' | grep -q Z || tmux resize-pane -Z")
        end
        vim.notify("📝 Goyo mode activated - Focus on writing", vim.log.levels.INFO)
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "GoyoLeave",
      callback = function()
        -- Disable Limelight when leaving Goyo
        vim.cmd("Limelight!")
        -- Re-enable vim-gitgutter
        if vim.fn.exists(":GitGutterEnable") then
          vim.cmd("GitGutterEnable")
        end
        -- Re-enable tmux status bar
        if vim.env.TMUX then
          vim.fn.system("tmux set status on")
          vim.fn.system("tmux list-panes -F '\\#F' | grep -q Z && tmux resize-pane -Z")
        end
        vim.notify("📝 Goyo mode deactivated", vim.log.levels.INFO)
      end,
    })
  end,
}
