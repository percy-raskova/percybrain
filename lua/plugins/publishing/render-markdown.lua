-- Plugin: render-markdown.nvim
-- Purpose: Enhanced in-buffer markdown rendering with treesitter
-- Workflow: prose-writing
-- Config: minimal (IWE official recommendation)
-- Repository: https://github.com/MeanderingProgrammer/render-markdown.nvim
--
-- Recommended by IWE official docs for improved markdown visualization
-- Renders directly in Neovim buffer (no browser needed)

return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter", -- Required for parsing
    "nvim-tree/nvim-web-devicons", -- Icons for checkboxes, lists
  },
  ft = "markdown", -- Load only for markdown files

  opts = {
    -- Rendering behavior
    render_modes = { "n", "c", "i" }, -- Render in normal, command, insert modes

    -- Headings
    headings = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " }, -- H1-H6 icons

    -- Code blocks
    code = {
      enabled = true,
      sign = true,
      style = "full", -- Full width background
      position = "left",
      width = "block",
      min_width = 79,
      border = "thin",
      above = "▄",
      below = "▀",
      highlight = "RenderMarkdownCode",
      highlight_inline = "RenderMarkdownCodeInline",
    },

    -- Bullet lists
    bullet = {
      enabled = true,
      icons = { "●", "○", "◆", "◇" }, -- Nested levels
      highlight = "RenderMarkdownBullet",
    },

    -- Checkboxes
    checkbox = {
      enabled = true,
      unchecked = { icon = "󰄱 ", highlight = "RenderMarkdownUnchecked" },
      checked = { icon = "󰱒 ", highlight = "RenderMarkdownChecked" },
    },

    -- Links
    link = {
      enabled = true,
      image = "󰥶 ",
      hyperlink = "󰌹 ",
      highlight = "RenderMarkdownLink",
    },

    -- Quotes
    quote = {
      enabled = true,
      icon = "▋",
      highlight = "RenderMarkdownQuote",
    },

    -- Tables
    pipe_table = {
      enabled = true,
      style = "full",
      cell = "padded",
      border = {
        "┌",
        "┬",
        "┐",
        "├",
        "┼",
        "┤",
        "└",
        "┴",
        "┘",
        "│",
        "─",
      },
      head = "RenderMarkdownTableHead",
      row = "RenderMarkdownTableRow",
    },

    -- Callouts (GitHub-style alerts)
    callout = {
      note = { raw = "[!NOTE]", rendered = "󰋽 Note", highlight = "RenderMarkdownInfo" },
      tip = { raw = "[!TIP]", rendered = "󰌶 Tip", highlight = "RenderMarkdownSuccess" },
      important = { raw = "[!IMPORTANT]", rendered = "󰅾 Important", highlight = "RenderMarkdownHint" },
      warning = { raw = "[!WARNING]", rendered = "󰀪 Warning", highlight = "RenderMarkdownWarn" },
      caution = { raw = "[!CAUTION]", rendered = "󰳦 Caution", highlight = "RenderMarkdownError" },
    },
  },

  config = function(_, opts)
    require("render-markdown").setup(opts)

    vim.notify("📝 Render-Markdown loaded (IWE recommended)", vim.log.levels.INFO)
  end,
}
