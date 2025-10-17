-- Plugin: vim-zettel
-- Purpose: Zettelkasten method implementation
-- Workflow: zettelkasten (PRIMARY)
-- Config: full

return {
  "michal-h21/vim-zettel",
  dependencies = { "vimwiki/vimwiki" },
  ft = { "vimwiki", "markdown" },
  keys = {
    { "<leader>zc", "<cmd>ZettelNew<cr>", desc = "Create new Zettel" },
    { "<leader>zs", "<cmd>ZettelSearch<cr>", desc = "Search Zettels" },
    { "<leader>zl", "<cmd>ZettelGenerateLinks<cr>", desc = "Generate Zettel links" },
    { "<leader>zt", "<cmd>ZettelGenerateTags<cr>", desc = "Generate Zettel tags" },
  },
  config = function()
    -- Zettel note format
    vim.g.zettel_format = "%Y%m%d-%H%M-%title" -- YYYYMMDD-HHMM-title format
    vim.g.zettel_date_format = "%Y-%m-%d %H:%M" -- Date format in note metadata
    vim.g.zettel_default_title = "untitled" -- Default title for new notes

    -- Directory structure
    vim.g.zettel_options = {
      {
        template = "~/Zettelkasten/templates/note.md", -- Template file
        disable_front_matter = 0, -- Enable front matter
        front_matter = {
          { "tags", "" }, -- Empty tags field
          { "date", "%date" }, -- Auto-filled date
        },
      },
    }

    -- Link format
    vim.g.zettel_link_format = "[[%title|%id]]" -- Wiki-style links with title and ID
    vim.g.zettel_backlinks_title = "== Backlinks ==" -- Section title for backlinks

    -- FZF integration
    vim.g.zettel_fzf_command = "rg --column --line-number --no-heading --color=always --smart-case" -- Use ripgrep for search
    vim.g.zettel_fzf_options = { "--preview-window", "right:50%", "--preview", "bat --color=always {}" } -- Preview with bat

    -- Tag handling
    vim.g.zettel_generated_tags_format = "#%s" -- Hashtag format for tags
    vim.g.zettel_tag_format = "#%s" -- Tag format in links

    -- Backlinks
    vim.g.zettel_backlinks_title = "## References" -- Backlinks section title
    vim.g.zettel_unlinked_notes = 1 -- Show unlinked notes in search

    vim.notify("🗒️  vim-zettel loaded - Zettelkasten method ready", vim.log.levels.INFO)
  end,
}
