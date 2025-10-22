-- Telekasten: The PERFECT Zettelkasten for ADHD/Autism
-- Visual previews, consistent UI, calendar structure
-- Repository: https://github.com/nvim-telekasten/telekasten.nvim

return {
  "nvim-telekasten/telekasten.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim",
    "renerocksai/calendar-vim", -- Visual calendar for daily notes
  },
  cmd = "Telekasten",
  keys = {
    -- Core note operations (z = Zettelkasten)
    { "<leader>zn", "<cmd>Telekasten new_note<cr>", desc = "📝 New note" },
    { "<leader>zf", "<cmd>Telekasten find_notes<cr>", desc = "🔍 Find notes" },
    { "<leader>zg", "<cmd>Telekasten search_notes<cr>", desc = "📖 Grep notes" },
    { "<leader>zb", "<cmd>Telekasten show_backlinks<cr>", desc = "🔗 Backlinks" },

    -- Daily notes with calendar
    { "<leader>zd", "<cmd>Telekasten goto_today<cr>", desc = "📅 Daily note" },
    { "<leader>zc", "<cmd>Telekasten show_calendar<cr>", desc = "📆 Calendar" },
    { "<leader>zw", "<cmd>Telekasten goto_thisweek<cr>", desc = "📊 Weekly note" },

    -- Visual features (ADHD support)
    { "<leader>zi", "<cmd>Telekasten insert_img_link<cr>", desc = "🖼️ Insert image" },
    { "<leader>zp", "<cmd>Telekasten preview_img<cr>", desc = "👁️ Preview image" },
    { "<leader>zm", "<cmd>Telekasten browse_media<cr>", desc = "📷 Browse media" },

    -- Organization
    { "<leader>zt", "<cmd>Telekasten show_tags<cr>", desc = "🏷️ Browse tags" },
    { "<leader>zl", "<cmd>Telekasten insert_link<cr>", desc = "🔗 Insert link" },
    { "<leader>zy", "<cmd>Telekasten yank_notelink<cr>", desc = "📋 Copy link" },
    { "<leader>zr", "<cmd>Telekasten rename_note<cr>", desc = "✏️ Rename note" },

    -- Navigation (consistent with vim motions)
    { "<leader>z[", "<cmd>Telekasten goto_prev_note<cr>", desc = "⬅️ Previous note" },
    { "<leader>z]", "<cmd>Telekasten goto_next_note<cr>", desc = "➡️ Next note" },
  },

  config = function()
    local home = vim.fn.expand("~/Zettelkasten")

    require("telekasten").setup({
      home = home,

      -- Use WikiLink notation for IWE LSP compatibility
      link_notation = "wiki", -- [[note]] format works with IWE

      -- Workflow-based directory organization
      dailies = home .. "/daily",
      weeklies = home .. "/weekly",
      templates = home .. "/templates",
      image_subdir = "assets",

      -- Additional directories (created separately):
      -- zettel/ - permanent atomic notes
      -- sources/ - literature notes with citations
      -- mocs/ - Maps of Content for navigation
      -- drafts/ - long-form work in progress

      -- File naming with YOUR timestamp format
      new_note_filename = "uuid-title",
      uuid_type = "%Y%m%d%H%M%S", -- Your YYYYMMDDHHMMSS format!
      filename_space_replacement = "-",

      -- Template system for consistency
      template_new_note = home .. "/templates/note.md",
      template_new_daily = home .. "/templates/daily.md",
      template_new_weekly = home .. "/templates/weekly.md",

      -- Work WITH IWE LSP, not against it
      install_syntax = false, -- Don't override IWE's syntax
      tag_notation = "yaml-bare", -- Compatible with YAML frontmatter

      -- Telescope configuration (consistent UI)
      command_palette_theme = "ivy",
      find_notes_theme = "ivy",
      find_command = "rg", -- You have ripgrep

      -- Visual feedback
      show_tags_theme = "dropdown",
      subdirs_in_links = false, -- Simpler links

      -- Integration with your existing tools
      plug_into_calendar = true,
      calendar_opts = {
        weeknm = 1, -- Week starts Monday (predictable)
        calendar_monday = 1,
        calendar_mark = "left-fit",
      },

      -- Journal settings
      journal_auto_open = false, -- Don't auto-open (reduce interruptions)

      -- Media handling (visual thinking support)
      image_link_style = "markdown",

      -- Following links (consistent with vim)
      follow_creates_nonexisting = true,
      dailies_create_nonexisting = true,
      weeklies_create_nonexisting = true,

      -- Colors (integrate with Blood Moon theme)
      -- These will use your theme's colors automatically

      -- Callback hooks for automation
      on_use_template = function(conf, template)
        -- Auto-fill date and time
        vim.api.nvim_buf_set_lines(0, 0, 0, false, {
          "---",
          "title: ",
          "date: " .. os.date("%Y-%m-%d %H:%M"),
          "tags: []",
          "---",
          "",
        })
      end,
    })

    -- Additional helper for ADHD quick capture
    vim.api.nvim_create_user_command("QuickNote", function()
      vim.cmd("Telekasten new_note")
      vim.defer_fn(function()
        vim.cmd("ZenMode") -- Auto-activate focus mode
      end, 100)
    end, { desc = "Quick note with auto-focus" })

    -- Visual notification on successful setup
    vim.notify("🚀 Telekasten loaded! Your Zettelkasten awaits.", vim.log.levels.INFO)
  end,
}
