-- Plugin: Quartz Publishing
-- Purpose: Static site publishing workflow for Zettelkasten knowledge base
-- Workflow: publishing
-- Why: ADHD optimization - quick keybindings reduce friction for publishing notes.
--      Local preview provides immediate feedback before publishing.
--      Mise integration ensures consistent, reproducible builds.
-- Config: Virtual plugin for keybindings (requires Mise tasks from Issue #15)
--
-- Usage:
--   <leader>pqp - Preview locally (port 8080)
--   <leader>pqb - Build static site
--   <leader>pqs - Publish to GitHub Pages
--   <leader>pqo - Open preview in browser
--
--   Commands: :QuartzPreview, :QuartzPublish
--
-- Dependencies: Mise tasks (Issue #15), Quartz v4 installed in ~/projects/quartz
-- Requirements: Zettelkasten in ~/Zettelkasten, Quartz configured

return {
  dir = vim.fn.stdpath("config") .. "/lua",
  name = "quartz-publishing",
  lazy = false,
  priority = 40,

  keys = {
    {
      "<leader>pqp",
      "<cmd>!mise quartz-preview &<cr>",
      desc = "Quartz: Preview locally (port 8080)",
    },
    {
      "<leader>pqb",
      "<cmd>!mise quartz-build<cr>",
      desc = "Quartz: Build static site",
    },
    {
      "<leader>pqs",
      "<cmd>!mise quartz-publish<cr>",
      desc = "Quartz: Publish to GitHub Pages",
    },
    {
      "<leader>pqo",
      "<cmd>!xdg-open http://localhost:8080<cr>",
      desc = "Quartz: Open preview in browser",
    },
  },

  config = function()
    -- User commands for convenience
    vim.api.nvim_create_user_command("QuartzPreview", function()
      vim.cmd("!mise quartz-preview &")
      vim.notify("🌐 Quartz preview starting at http://localhost:8080", vim.log.levels.INFO)
    end, { desc = "Start Quartz preview server" })

    vim.api.nvim_create_user_command("QuartzPublish", function()
      vim.cmd("!mise quartz-publish")
      vim.notify("📤 Publishing to GitHub Pages...", vim.log.levels.INFO)
    end, { desc = "Publish Zettelkasten to GitHub Pages" })

    vim.notify("📚 Quartz publishing keybindings loaded", vim.log.levels.INFO)
  end,
}
