-- Plugin: PercyBrain Blood Moon Theme
-- Purpose: Custom dark theme inspired by Kitty "Blood Moon" aesthetic
-- Workflow: ui
-- Config: full
-- Colors: Deep blood red/black background, gold accents, crimson highlights

return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    -- PercyBrain Blood Moon color palette
    -- Inspired by Kitty theme but refined for optimal Neovim readability
    local colors = {
      -- Base colors
      bg = "#1a0000", -- Deep blood red/black (from Kitty)
      bg_dark = "#0d0000", -- Darker variant for borders/status
      bg_highlight = "#2a0a0a", -- Subtle highlight (refined from Kitty)

      fg = "#e8e8e8", -- Light gray text (from Kitty)
      fg_dark = "#b0b0b0", -- Dimmed text
      fg_gutter = "#5a2020", -- Line numbers (refined)

      -- Accent colors
      gold = "#ffd700", -- Primary accent (from Kitty)
      gold_dim = "#ccaa00", -- Dimmed gold
      crimson = "#dc143c", -- Secondary accent (from Kitty)
      crimson_dim = "#a01028", -- Dimmed crimson

      -- Semantic colors (refined for better contrast)
      red = "#ff4444", -- Errors, deletions
      orange = "#ff8844", -- Warnings
      yellow = "#ffcc44", -- Modified, hints
      green = "#44ff88", -- Success, additions
      cyan = "#44ccff", -- Info, special
      blue = "#4488ff", -- Functions, keywords
      purple = "#cc88ff", -- Constants, strings
      magenta = "#ff44cc", -- Types, properties

      -- UI elements
      border = "#dc143c", -- Window borders (crimson from Kitty)
      border_inactive = "#404040", -- Inactive borders (from Kitty)
      selection = "#ffd700", -- Visual mode (gold from Kitty)
      search = "#ff8844", -- Search highlights
      cursor = "#dc143c", -- Cursor color (crimson from Kitty)

      -- Git colors
      git_add = "#44ff88",
      git_change = "#ffcc44",
      git_delete = "#ff4444",

      -- Diagnostic colors
      error = "#ff4444",
      warning = "#ff8844",
      info = "#44ccff",
      hint = "#44ff88",
    }

    require("tokyonight").setup({
      style = "night",
      transparent = false,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { bold = true },
        functions = { bold = true },
        variables = {},
        sidebars = "dark",
        floats = "dark",
      },

      -- Override tokyonight colors with Blood Moon palette
      on_colors = function(c)
        c.bg = colors.bg
        c.bg_dark = colors.bg_dark
        c.bg_highlight = colors.bg_highlight
        c.fg = colors.fg
        c.fg_dark = colors.fg_dark
        c.fg_gutter = colors.fg_gutter

        c.red = colors.red
        c.orange = colors.orange
        c.yellow = colors.yellow
        c.green = colors.green
        c.cyan = colors.cyan
        c.blue = colors.blue
        c.purple = colors.purple
        c.magenta = colors.magenta

        c.border = colors.border
        c.border_highlight = colors.crimson

        c.git = {
          add = colors.git_add,
          change = colors.git_change,
          delete = colors.git_delete,
        }

        c.error = colors.error
        c.warning = colors.warning
        c.info = colors.info
        c.hint = colors.hint
      end,

      on_highlights = function(hl, c)
        -- Editor UI
        hl.Normal = { fg = colors.fg, bg = colors.bg }
        hl.NormalFloat = { fg = colors.fg, bg = colors.bg_dark }
        hl.FloatBorder = { fg = colors.border, bg = colors.bg_dark }
        hl.FloatTitle = { fg = colors.gold, bg = colors.bg_dark, bold = true }

        -- Cursor and selection
        hl.Cursor = { fg = colors.bg, bg = colors.cursor }
        hl.CursorLine = { bg = colors.bg_highlight }
        hl.CursorLineNr = { fg = colors.gold, bold = true }
        hl.LineNr = { fg = colors.fg_gutter }
        hl.Visual = { bg = colors.bg_highlight, fg = colors.selection }
        hl.VisualNOS = { bg = colors.bg_highlight }

        -- Search
        hl.Search = { bg = colors.search, fg = colors.bg, bold = true }
        hl.IncSearch = { bg = colors.gold, fg = colors.bg, bold = true }
        hl.CurSearch = { bg = colors.crimson, fg = colors.fg, bold = true }

        -- Window splits and borders
        hl.WinSeparator = { fg = colors.border }
        hl.VertSplit = { fg = colors.border }

        -- Statusline (gold accent on active, dimmed on inactive)
        hl.StatusLine = { fg = colors.gold, bg = colors.bg_dark, bold = true }
        hl.StatusLineNC = { fg = colors.fg_dark, bg = colors.bg_dark }

        -- Tabline
        hl.TabLine = { fg = colors.fg_dark, bg = colors.bg_dark }
        hl.TabLineSel = { fg = colors.bg, bg = colors.gold, bold = true }
        hl.TabLineFill = { bg = colors.bg_dark }

        -- Popup menu
        hl.Pmenu = { fg = colors.fg, bg = colors.bg_dark }
        hl.PmenuSel = { fg = colors.bg, bg = colors.gold, bold = true }
        hl.PmenuSbar = { bg = colors.bg_highlight }
        hl.PmenuThumb = { bg = colors.crimson }

        -- Syntax highlighting (refined for Blood Moon aesthetic)
        hl.Comment = { fg = colors.fg_dark, italic = true }
        hl.String = { fg = colors.purple }
        hl.Number = { fg = colors.gold }
        hl.Boolean = { fg = colors.gold, bold = true }
        hl.Function = { fg = colors.blue, bold = true }
        hl.Keyword = { fg = colors.crimson, bold = true }
        hl.Conditional = { fg = colors.crimson, bold = true }
        hl.Repeat = { fg = colors.crimson, bold = true }
        hl.Operator = { fg = colors.orange }
        hl.Type = { fg = colors.magenta }
        hl.Identifier = { fg = colors.cyan }
        hl.Constant = { fg = colors.gold }
        hl.Special = { fg = colors.orange }

        -- Markdown (prose writing focus)
        hl.markdownH1 = { fg = colors.gold, bold = true }
        hl.markdownH2 = { fg = colors.crimson, bold = true }
        hl.markdownH3 = { fg = colors.orange, bold = true }
        hl.markdownH4 = { fg = colors.yellow }
        hl.markdownH5 = { fg = colors.cyan }
        hl.markdownH6 = { fg = colors.purple }
        hl.markdownCode = { fg = colors.green, bg = colors.bg_highlight }
        hl.markdownCodeBlock = { fg = colors.green, bg = colors.bg_highlight }
        hl.markdownLinkText = { fg = colors.blue, underline = true }
        hl.markdownUrl = { fg = colors.cyan, underline = true }
        hl.markdownBold = { fg = colors.gold, bold = true }
        hl.markdownItalic = { fg = colors.purple, italic = true }

        -- LaTeX (academic writing)
        hl.texStatement = { fg = colors.crimson, bold = true }
        hl.texSection = { fg = colors.gold, bold = true }
        hl.texMath = { fg = colors.blue }
        hl.texDelimiter = { fg = colors.orange }

        -- Diagnostics
        hl.DiagnosticError = { fg = colors.error }
        hl.DiagnosticWarn = { fg = colors.warning }
        hl.DiagnosticInfo = { fg = colors.info }
        hl.DiagnosticHint = { fg = colors.hint }
        hl.DiagnosticUnderlineError = { sp = colors.error, undercurl = true }
        hl.DiagnosticUnderlineWarn = { sp = colors.warning, undercurl = true }
        hl.DiagnosticUnderlineInfo = { sp = colors.info, undercurl = true }
        hl.DiagnosticUnderlineHint = { sp = colors.hint, undercurl = true }

        -- Git signs
        hl.GitSignsAdd = { fg = colors.git_add }
        hl.GitSignsChange = { fg = colors.git_change }
        hl.GitSignsDelete = { fg = colors.git_delete }

        -- Telescope (fuzzy finder)
        hl.TelescopeBorder = { fg = colors.border, bg = colors.bg_dark }
        hl.TelescopeTitle = { fg = colors.gold, bg = colors.bg_dark, bold = true }
        hl.TelescopeSelection = { fg = colors.gold, bg = colors.bg_highlight, bold = true }
        hl.TelescopeMatching = { fg = colors.crimson, bold = true }

        -- NvimTree (file explorer)
        hl.NvimTreeNormal = { fg = colors.fg, bg = colors.bg_dark }
        hl.NvimTreeFolderName = { fg = colors.cyan }
        hl.NvimTreeFolderIcon = { fg = colors.gold }
        hl.NvimTreeOpenedFolderName = { fg = colors.gold, bold = true }
        hl.NvimTreeRootFolder = { fg = colors.crimson, bold = true }
        hl.NvimTreeGitDirty = { fg = colors.git_change }
        hl.NvimTreeGitNew = { fg = colors.git_add }
        hl.NvimTreeGitDeleted = { fg = colors.git_delete }
        hl.NvimTreeSpecialFile = { fg = colors.magenta }
        hl.NvimTreeExecFile = { fg = colors.green }

        -- WhichKey (keyboard shortcut discovery)
        hl.WhichKey = { fg = colors.gold }
        hl.WhichKeyGroup = { fg = colors.crimson }
        hl.WhichKeyDesc = { fg = colors.cyan }
        hl.WhichKeySeparator = { fg = colors.fg_dark }
        hl.WhichKeyFloat = { bg = colors.bg_dark }
        hl.WhichKeyBorder = { fg = colors.border, bg = colors.bg_dark }

        -- Alpha (dashboard)
        hl.AlphaHeader = { fg = colors.crimson, bold = true }
        hl.AlphaButtons = { fg = colors.gold }
        hl.AlphaShortcut = { fg = colors.crimson, bold = true }
        hl.AlphaFooter = { fg = colors.fg_dark, italic = true }

        -- Lualine (statusline) - if using lualine
        hl.lualine_a_normal = { fg = colors.bg, bg = colors.gold, bold = true }
        hl.lualine_a_insert = { fg = colors.bg, bg = colors.green, bold = true }
        hl.lualine_a_visual = { fg = colors.bg, bg = colors.crimson, bold = true }
        hl.lualine_a_replace = { fg = colors.bg, bg = colors.red, bold = true }
        hl.lualine_a_command = { fg = colors.bg, bg = colors.blue, bold = true }

        -- Zen-mode / Goyo (distraction-free writing)
        hl.ZenBg = { bg = colors.bg }
      end,
    })

    -- Apply the colorscheme
    vim.cmd([[colorscheme tokyonight]])

    vim.notify("🌙 PercyBrain Blood Moon theme loaded", vim.log.levels.INFO)
  end,
}
