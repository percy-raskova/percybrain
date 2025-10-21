-- Plugin: mkdnflow.nvim
-- Purpose: Fluent markdown navigation and task management for GTD system
-- Workflow: zettelkasten, gtd
-- Config: full

return {
  "jakewvincent/mkdnflow.nvim",
  ft = { "markdown" }, -- Load only for markdown files
  dependencies = {
    "nvim-lua/plenary.nvim", -- Required for async operations
  },
  config = function()
    require("mkdnflow").setup({
      -- File and link management
      modules = {
        bib = false, -- Not using bibliography
        buffers = true, -- Buffer management
        conceal = true, -- Conceal markdown syntax
        cursor = true, -- Cursor movement enhancements
        folds = true, -- Folding support
        foldtext = true, -- Custom fold text
        links = true, -- Link navigation
        lists = true, -- List management
        maps = true, -- Keymaps
        paths = true, -- Path utilities
        tables = true, -- Table formatting
        yaml = false, -- YAML frontmatter (handled by other plugins)
        cmp = false, -- nvim-cmp integration (we use our own cmp config)
      },

      -- Filetypes to enable mkdnflow
      filetypes = { md = true, rmd = true, markdown = true },

      -- Create missing directories when following links
      create_dirs = true,

      -- Perspective settings
      perspective = {
        priority = "root", -- Prioritize wiki root over current file
        fallback = "current", -- Fall back to current file if no root
        root_tell = "index.md", -- File that indicates wiki root
        nvim_wd_heel = true, -- Change nvim working directory
        update = true, -- Update perspective on buffer changes
      },

      -- Wrap cursor movement
      wrap = false,

      -- New file settings
      new_file_template = {
        use_template = true,
        placeholders = {
          before = {
            title = "link_title", -- Use link title
            date = function()
              return os.date("%Y-%m-%d")
            end,
          },
          after = {},
        },
        template = [[
# {{ title }}

Created: {{ date }}

---

## Overview


## Notes


## References

]],
      },

      -- Todo list settings (GTD integration)
      to_do = {
        symbols = { " ", "x", "-" }, -- [ ], [x], [-] for todo states
        update_parents = true, -- Update parent checkbox state
        not_started = " ", -- Symbol for not started
        in_progress = "-", -- Symbol for in progress
        complete = "x", -- Symbol for complete
      },

      -- Link management
      links = {
        style = "markdown", -- Use standard markdown links
        name_is_source = false, -- Don't use filename as link text
        conceal = true, -- Conceal link markup
        context = 0, -- No additional context in link previews
        implicit_extension = nil, -- No implicit extension
        transform_implicit = false, -- Don't transform implicit links
        transform_explicit = function(text)
          -- Convert spaces to hyphens and lowercase for file names
          text = text:gsub(" ", "-")
          text = text:lower()
          return text
        end,
      },

      -- Table settings
      tables = {
        trim_whitespace = true,
        format_on_move = true,
        auto_extend_rows = false,
        auto_extend_cols = false,
        style = {
          cell_padding = 1,
          separator_padding = 1,
          outer_pipes = true,
          mimic_alignment = true,
        },
      },

      -- Yaml settings (disabled, handled by other plugins)
      yaml = {
        bib = { override = false },
      },

      -- Mappings (minimal - we use custom GTD keymaps in lua/config/keymaps/organization/gtd.lua)
      mappings = {
        MkdnEnter = { { "n", "v" }, "<CR>" }, -- Follow link or create new
        MkdnTab = false, -- Disabled (use custom GTD workflow)
        MkdnSTab = false, -- Disabled
        MkdnNextLink = { "n", "<Tab>" }, -- Navigate to next link
        MkdnPrevLink = { "n", "<S-Tab>" }, -- Navigate to previous link
        MkdnNextHeading = { "n", "]]" }, -- Next heading
        MkdnPrevHeading = { "n", "[[" }, -- Previous heading
        MkdnGoBack = { "n", "<BS>" }, -- Go back to previous file
        MkdnGoForward = { "n", "<Del>" }, -- Go forward
        MkdnCreateLink = false, -- Disabled (use custom GTD workflow)
        MkdnCreateLinkFromClipboard = false, -- Disabled
        MkdnFollowLink = false, -- Using <CR> instead
        MkdnDestroyLink = false, -- Disabled
        MkdnTagSpan = false, -- Disabled
        MkdnMoveSource = false, -- Disabled
        MkdnYankAnchorLink = false, -- Disabled
        MkdnYankFileAnchorLink = false, -- Disabled
        MkdnIncreaseHeading = { "n", "+" }, -- Increase heading level
        MkdnDecreaseHeading = { "n", "-" }, -- Decrease heading level
        MkdnToggleToDo = { { "n", "v" }, "<C-Space>" }, -- Toggle todo state
        MkdnNewListItem = false, -- Disabled (use custom GTD workflow)
        MkdnNewListItemBelowInsert = false, -- Disabled
        MkdnNewListItemAboveInsert = false, -- Disabled
        MkdnExtendList = false, -- Disabled
        MkdnUpdateNumbering = { "n", "<leader>nn" }, -- Update list numbering
        MkdnTableNextCell = { "i", "<Tab>" }, -- Next table cell
        MkdnTablePrevCell = { "i", "<S-Tab>" }, -- Previous table cell
        MkdnTableNextRow = false, -- Disabled
        MkdnTablePrevRow = false, -- Disabled
        MkdnTableNewRowBelow = { "n", "<leader>ir" }, -- Insert row below
        MkdnTableNewRowAbove = { "n", "<leader>iR" }, -- Insert row above
        MkdnTableNewColAfter = { "n", "<leader>ic" }, -- Insert column after
        MkdnTableNewColBefore = { "n", "<leader>iC" }, -- Insert column before
        MkdnFoldSection = { "n", "<leader>f" }, -- Fold section
        MkdnUnfoldSection = { "n", "<leader>F" }, -- Unfold section
      },
    })

    vim.notify("📝 mkdnflow loaded - GTD task management ready", vim.log.levels.INFO)
  end,
}
