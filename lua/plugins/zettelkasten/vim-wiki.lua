-- Plugin: VimWiki
-- Purpose: Personal wiki system with Zettelkasten support
-- Workflow: zettelkasten (PRIMARY)
-- Config: full

return {
  "vimwiki/vimwiki",
  ft = { "vimwiki", "markdown" }, -- Load for wiki and markdown files
  keys = {
    { "<leader>ww", "<cmd>VimwikiIndex<cr>", desc = "Open wiki index" },
    { "<leader>wt", "<cmd>VimwikiTabIndex<cr>", desc = "Open wiki index in tab" },
    { "<leader>wd", "<cmd>VimwikiDiaryIndex<cr>", desc = "Open diary index" },
    { "<leader>wi", "<cmd>VimwikiDiaryGenerateLinks<cr>", desc = "Generate diary links" },
  },
  config = function()
    -- Wiki configuration
    vim.g.vimwiki_list = {
      {
        path = "~/Zettelkasten/",
        syntax = "markdown",
        ext = ".md",
        diary_rel_path = "daily/",
        diary_index = "index",
        diary_header = "Daily Notes",
        auto_diary_index = 1,
        auto_generate_links = 1,
        auto_generate_tags = 0,
        auto_tags = 0,
        nested_syntaxes = {
          python = "python",
          lua = "lua",
          bash = "sh",
        },
      },
    }

    -- Global settings
    vim.g.vimwiki_global_ext = 0 -- Don't treat all markdown files as wiki
    vim.g.vimwiki_markdown_link_ext = 1 -- Use .md extension in links
    vim.g.vimwiki_conceallevel = 2 -- Conceal wiki syntax
    vim.g.vimwiki_conceal_onechar_markers = 1 -- Conceal single-char markers
    vim.g.vimwiki_use_calendar = 1 -- Calendar integration
    vim.g.vimwiki_hl_headers = 1 -- Highlight headers
    vim.g.vimwiki_hl_cb_checked = 2 -- Highlight checked items

    -- Link handling
    vim.g.vimwiki_auto_chdir = 1 -- Change directory when opening wiki
    vim.g.vimwiki_folding = "expr" -- Enable expression-based folding
    vim.g.vimwiki_fold_lists = 1 -- Fold list items
    vim.g.vimwiki_create_link = 1 -- Create links automatically

    -- Disable table mappings (conflicts with other plugins)
    vim.g.vimwiki_table_mappings = 0

    -- Diary settings
    vim.g.vimwiki_diary_months = {
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    }

    vim.notify("📚 VimWiki loaded - Personal wiki ready", vim.log.levels.INFO)
  end,
}
