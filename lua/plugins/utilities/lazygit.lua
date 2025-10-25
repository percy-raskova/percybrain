-- Plugin: LazyGit
-- Purpose: Interactive Git interface inside Neovim with visual commit history and staging
-- Workflow: utilities
-- Why: Visual Git interface reduces complexity for users uncomfortable with command-line Git.
--      Interactive staging, visual commit history, and branch management lower barriers to
--      version control. Critical for preserving Zettelkasten history and enabling experimentation
--      with branches. Floating window keeps Git operations contextual without leaving editor.
-- Config: minimal (uses LazyGit's default keybindings)
--
-- Usage:
--   <leader>gg - Open LazyGit in floating window
--   Within LazyGit:
--     Tab - Switch between panels
--     Space - Stage/unstage files
--     c - Commit
--     P - Push
--     p - Pull
--     b - Create/switch branches
--     ? - Help menu (shows all keybindings)
--
-- Dependencies:
--   External: lazygit (install with package manager or from jesseduffield/lazygit)
--
-- Configuration Notes:
--   - Opens in floating window centered in editor
--   - Full LazyGit functionality available (commit, push, pull, branch, stash, etc.)
--   - Preserves Neovim session while managing Git operations
--   - Works with any Git repository, optimized for Zettelkasten version control
--   - Exit LazyGit with 'q' to return to editing

return {
  "kdheepak/lazygit.nvim",
  -- optional for floating window border decoration
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
}
