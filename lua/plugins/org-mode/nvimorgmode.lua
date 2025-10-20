-- Plugin: Org-mode
-- Purpose: Emacs org-mode compatibility for task management, agendas, and structured notes
-- Workflow: org-mode
-- Why: Provides powerful task management and agenda views for users familiar with Emacs org-mode.
--      Complements Zettelkasten with structured project management. Agenda views help ADHD users
--      visualize deadlines and priorities. Supports richer markup than markdown (tables, LaTeX,
--      code blocks, drawers). Enables migration from Emacs without losing org-mode workflows.
-- Config: minimal - sets agenda files and default notes location
--
-- Usage:
--   Org-mode syntax in .org files:
--     * TODO Task heading
--     SCHEDULED: <2025-10-20 Sun>
--     :PROPERTIES:...
--   Org-mode commands:
--     <leader>oa - Open agenda view
--     <leader>oc - Capture new task/note
--     <C-c><C-t> - Cycle TODO state
--     <C-c><C-s> - Schedule task
--     <C-c><C-d> - Set deadline
--
-- Dependencies:
--   Internal: nvim-treesitter for org file parsing
--
-- Configuration Notes:
--   - org_agenda_files: "~/orgfiles/**/*" searches all org files in orgfiles directory
--   - org_default_notes_file: "~/orgfiles/refile.org" for quick capture
--   - Handles its own treesitter grammar (no external setup needed)
--   - Compatible with Emacs org-mode files (bidirectional editing)

return {
  "nvim-orgmode/orgmode",
  dependencies = {
    { "nvim-treesitter/nvim-treesitter", lazy = true },
  },
  event = "VeryLazy",
  config = function()
    -- Setup orgmode (handles its own treesitter grammar)
    require("orgmode").setup({
      org_agenda_files = "~/orgfiles/**/*",
      org_default_notes_file = "~/orgfiles/refile.org",
    })
  end,
}
