-- IWE LSP: Integrated Writing Environment
-- Purpose: LSP for knowledge management with graph-based refactoring
-- Repository: https://github.com/iwe-org/iwe
--
-- Integration with Telekasten:
-- - Telekasten: Navigation, creation, calendar, templates
-- - IWE: Refactoring (extract/inline), LSP navigation, link maintenance

return {
  "iwe-org/iwe.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim",
  },
  ft = "markdown", -- Load for markdown files
  config = function()
    local home = vim.fn.expand("~/Zettelkasten")

    require("iwe").setup({
      -- Directory configuration (matches Telekasten)
      library_path = home,

      -- Link format (MUST match Telekasten's link_notation = "wiki")
      link_type = "WikiLink", -- [[note]] syntax

      -- LSP server configuration
      lsp = {
        cmd = { "iwes" },
        name = "iwes",
        debounce_text_changes = 500,
        auto_format_on_save = true,
      },

      -- Link actions for different note types
      link_actions = {
        -- Default: Permanent zettels
        {
          name = "default",
          key_template = "{{slug}}",
          path_template = "zettel/{{slug}}.md",
        },

        -- Literature notes
        {
          name = "source",
          key_template = "{{author}}-{{year}}-{{slug}}",
          path_template = "sources/{{key}}.md",
        },

        -- Maps of Content
        {
          name = "moc",
          key_template = "MOC-{{slug}}",
          path_template = "mocs/{{key}}.md",
        },

        -- Daily notes (Telekasten handles creation)
        {
          name = "daily",
          key_template = "{{date}}",
          path_template = "daily/{{key}}.md",
        },

        -- Drafts for synthesis
        {
          name = "draft",
          key_template = "Draft-{{slug}}",
          path_template = "drafts/{{key}}.md",
        },
      },

      -- Extract configuration (section → new note)
      extract = {
        key_template = "{{slug}}",
        path_template = "zettel/{{key}}.md",
      },

      -- Keybindings (managed by registry)
      mappings = {
        enable_markdown_mappings = true, -- -, <C-n>, <C-p>, /d, /w
        enable_telescope_keybindings = false, -- Registry: <leader>z*
        enable_lsp_keybindings = false, -- Registry: <leader>zr*
        enable_preview_keybindings = false, -- Registry: <leader>ip*
        leader = "<leader>",
        localleader = "<localleader>",
      },

      -- Telescope integration
      telescope = {
        enabled = true,
        setup_config = true,
        load_extensions = { "ui-select", "emoji" },
      },
    })

    vim.notify("🔗 IWE LSP configured for ~/Zettelkasten", vim.log.levels.INFO)
  end,
}
