-- Plugin: Limelight
-- Purpose: Dim paragraphs except current one for focus
-- Workflow: prose-writing/distraction-free
-- Config: full

return {
  "junegunn/limelight.vim",
  cmd = "Limelight", -- Lazy load on command
  keys = {
    { "<leader>ll", "<cmd>Limelight!!<cr>", desc = "Toggle Limelight" },
  },
  config = function()
    -- Color settings
    vim.g.limelight_conceal_ctermfg = "gray" -- Terminal color for dimmed text
    vim.g.limelight_conceal_ctermfg = 240 -- Terminal color code (gray)
    vim.g.limelight_conceal_guifg = "#777777" -- GUI color for dimmed text

    -- Highlighting priority (default: 10)
    -- Set lower priority to prevent Limelight from overriding syntax highlighting
    vim.g.limelight_priority = -1

    -- Paragraph range
    vim.g.limelight_paragraph_span = 1 -- Number of paragraphs to highlight (0 = current paragraph only)

    -- Beginning/end of paragraph patterns
    vim.g.limelight_bop = "^\\s" -- Paragraph begins with whitespace
    vim.g.limelight_eop = "\\n\\s*\\n" -- Paragraph ends with blank line

    vim.notify("💡 Limelight loaded - Focus mode ready", vim.log.levels.INFO)
  end,
}
