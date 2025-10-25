-- Plugin: Bufferline
-- Purpose: Beautiful tab/buffer navigation with Blood Moon theme integration
-- Workflow: ui
-- Config: full
-- Features: Tab-style buffers, mouse support, Git integration, close buttons

return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = {
    "nvim-tree/nvim-web-devicons", -- File icons
  },
  event = "VeryLazy",

  config = function()
    -- Blood Moon color palette (matching percybrain-theme.lua)
    local colors = {
      bg = "#1a0000", -- Deep blood red/black
      bg_dark = "#0d0000", -- Darker variant
      bg_highlight = "#2a0a0a", -- Subtle highlight
      fg = "#e8e8e8", -- Light gray text
      fg_dark = "#b0b0b0", -- Dimmed text
      gold = "#ffd700", -- Primary accent (active tab)
      crimson = "#dc143c", -- Secondary accent (border)
      border = "#dc143c", -- Window borders
      blue = "#4488ff", -- Modified indicator
      red = "#ff4444", -- Close button
      green = "#44ff88", -- Diagnostic OK
      orange = "#ff8844", -- Diagnostic warning
    }

    require("bufferline").setup({
      options = {
        -- Navigation and behavior
        mode = "buffers", -- "tabs" or "buffers"
        numbers = "none", -- "none" | "ordinal" | "buffer_id" | "both"
        close_command = "bdelete! %d",
        right_mouse_command = "bdelete! %d",
        left_mouse_command = "buffer %d",
        middle_mouse_command = nil,

        -- Visual appearance
        indicator = {
          icon = "▎", -- Left indicator for active buffer
          style = "icon", -- 'icon' | 'underline' | 'none'
        },

        buffer_close_icon = "󰅖",
        modified_icon = "●",
        close_icon = "",
        left_trunc_marker = "",
        right_trunc_marker = "",

        -- Tab sizing
        max_name_length = 25,
        max_prefix_length = 15,
        truncate_names = true,
        tab_size = 22,

        -- Diagnostics integration
        diagnostics = "nvim_lsp",
        diagnostics_update_in_insert = false,
        diagnostics_indicator = function(count, level, diagnostics_dict, context)
          local icon = level:match("error") and " " or " "
          return " " .. icon .. count
        end,

        -- Icons and separators
        show_buffer_icons = true,
        show_buffer_close_icons = true,
        show_close_icon = false, -- Global close icon
        show_tab_indicators = true,
        separator_style = "thin", -- "slant" | "slope" | "thick" | "thin" | { 'any', 'any' }
        always_show_bufferline = true,

        -- Git integration
        show_duplicate_prefix = true,
        persist_buffer_sort = true,

        -- Mouse hover (Neovim 0.8+)
        hover = {
          enabled = true,
          delay = 200,
          reveal = { "close" },
        },

        -- Mouse support
        offsets = {
          {
            filetype = "NvimTree",
            text = "File Explorer",
            text_align = "center",
            separator = true,
          },
          {
            filetype = "neo-tree",
            text = "File Explorer",
            text_align = "center",
            separator = true,
          },
        },

        -- Grouping
        groups = {
          options = {
            toggle_hidden_on_enter = true,
          },
          items = {
            {
              name = "Tests",
              highlight = { underline = true, sp = colors.blue },
              priority = 2,
              icon = "",
              matcher = function(buf)
                if not buf or not buf.path then
                  return false
                end
                return buf.path:match("_test") or buf.path:match("_spec")
              end,
            },
            {
              name = "Docs",
              highlight = { underline = true, sp = colors.green },
              auto_close = false,
              matcher = function(buf)
                if not buf or not buf.path then
                  return false
                end
                return buf.path:match("%.md") or buf.path:match("%.txt")
              end,
            },
          },
        },
      },

      -- Blood Moon theme integration
      highlights = {
        -- Background (when not selected)
        fill = {
          bg = colors.bg_dark,
        },
        background = {
          fg = colors.fg_dark,
          bg = colors.bg_dark,
        },

        -- Active buffer (gold accent matching Blood Moon)
        buffer_selected = {
          fg = colors.bg,
          bg = colors.gold,
          bold = true,
          italic = false,
        },

        -- Visible but not selected
        buffer_visible = {
          fg = colors.fg,
          bg = colors.bg_highlight,
        },

        -- Tab close buttons
        close_button = {
          fg = colors.fg_dark,
          bg = colors.bg_dark,
        },
        close_button_visible = {
          fg = colors.fg,
          bg = colors.bg_highlight,
        },
        close_button_selected = {
          fg = colors.bg,
          bg = colors.gold,
        },

        -- Modified indicator (unsaved changes)
        modified = {
          fg = colors.blue,
          bg = colors.bg_dark,
        },
        modified_visible = {
          fg = colors.blue,
          bg = colors.bg_highlight,
        },
        modified_selected = {
          fg = colors.bg,
          bg = colors.gold,
        },

        -- Separators (crimson borders matching Blood Moon)
        separator = {
          fg = colors.crimson,
          bg = colors.bg_dark,
        },
        separator_visible = {
          fg = colors.crimson,
          bg = colors.bg_highlight,
        },
        separator_selected = {
          fg = colors.crimson,
          bg = colors.gold,
        },

        -- Indicator (left edge of active buffer)
        indicator_selected = {
          fg = colors.crimson,
          bg = colors.gold,
        },
        indicator_visible = {
          fg = colors.crimson,
          bg = colors.bg_highlight,
        },

        -- Duplicate filenames
        duplicate = {
          fg = colors.fg_dark,
          bg = colors.bg_dark,
          italic = true,
        },
        duplicate_selected = {
          fg = colors.bg,
          bg = colors.gold,
          italic = true,
        },
        duplicate_visible = {
          fg = colors.fg,
          bg = colors.bg_highlight,
          italic = true,
        },

        -- Tab indicators
        tab = {
          fg = colors.fg_dark,
          bg = colors.bg_dark,
        },
        tab_selected = {
          fg = colors.bg,
          bg = colors.gold,
          bold = true,
        },
        tab_close = {
          fg = colors.red,
          bg = colors.bg_dark,
        },

        -- Diagnostics
        error = {
          fg = colors.red,
          bg = colors.bg_dark,
        },
        error_selected = {
          fg = colors.bg,
          bg = colors.gold,
        },
        error_diagnostic = {
          fg = colors.red,
          bg = colors.bg_dark,
        },
        error_diagnostic_selected = {
          fg = colors.bg,
          bg = colors.gold,
        },

        warning = {
          fg = colors.orange,
          bg = colors.bg_dark,
        },
        warning_selected = {
          fg = colors.bg,
          bg = colors.gold,
        },
        warning_diagnostic = {
          fg = colors.orange,
          bg = colors.bg_dark,
        },
        warning_diagnostic_selected = {
          fg = colors.bg,
          bg = colors.gold,
        },

        info = {
          fg = colors.blue,
          bg = colors.bg_dark,
        },
        info_selected = {
          fg = colors.bg,
          bg = colors.gold,
        },
        info_diagnostic = {
          fg = colors.blue,
          bg = colors.bg_dark,
        },
        info_diagnostic_selected = {
          fg = colors.bg,
          bg = colors.gold,
        },

        hint = {
          fg = colors.green,
          bg = colors.bg_dark,
        },
        hint_selected = {
          fg = colors.bg,
          bg = colors.gold,
        },
        hint_diagnostic = {
          fg = colors.green,
          bg = colors.bg_dark,
        },
        hint_diagnostic_selected = {
          fg = colors.bg,
          bg = colors.gold,
        },

        -- Offsets (for file explorer)
        offset_separator = {
          fg = colors.crimson,
          bg = colors.bg_dark,
        },
      },
    })

    vim.notify("📑 Bufferline loaded with Blood Moon theme", vim.log.levels.INFO)
  end,

  -- Keybindings for buffer navigation
  keys = {
    -- Cycle through buffers
    { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
    { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Previous buffer" },

    -- Move buffers
    { "<leader>bl", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer right" },
    { "<leader>bh", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer left" },

    -- Pick buffer (interactive)
    { "<leader>bp", "<cmd>BufferLinePick<cr>", desc = "Pick buffer" },
    { "<leader>bc", "<cmd>BufferLinePickClose<cr>", desc = "Pick buffer to close" },

    -- Close buffers
    { "<leader>bx", "<cmd>BufferLineCloseRight<cr>", desc = "Close all buffers to right" },
    { "<leader>bX", "<cmd>BufferLineCloseLeft<cr>", desc = "Close all buffers to left" },
    { "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "Close other buffers" },

    -- Jump to buffer by position
    { "<leader>b1", "<cmd>BufferLineGoToBuffer 1<cr>", desc = "Go to buffer 1" },
    { "<leader>b2", "<cmd>BufferLineGoToBuffer 2<cr>", desc = "Go to buffer 2" },
    { "<leader>b3", "<cmd>BufferLineGoToBuffer 3<cr>", desc = "Go to buffer 3" },
    { "<leader>b4", "<cmd>BufferLineGoToBuffer 4<cr>", desc = "Go to buffer 4" },
    { "<leader>b5", "<cmd>BufferLineGoToBuffer 5<cr>", desc = "Go to buffer 5" },

    -- Sort buffers
    { "<leader>bs", "<cmd>BufferLineSortByDirectory<cr>", desc = "Sort by directory" },
    { "<leader>be", "<cmd>BufferLineSortByExtension<cr>", desc = "Sort by extension" },
  },
}
