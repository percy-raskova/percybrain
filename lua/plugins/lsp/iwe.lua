-- IWE LSP: Integrated Writing Environment
-- Purpose: LSP for knowledge management with graph-based refactoring
-- Repository: https://github.com/iwe-org/iwe
--
-- Integration Strategy:
-- - IWE: Primary LSP for navigation, refactoring, link maintenance
-- - Custom implementations: Calendar, tags (Telescope + ripgrep)

return {
  "iwe-org/iwe.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim",
  },
  cmd = "IWE", -- Load when :IWE command is used
  ft = "markdown", -- Also load for markdown files
  config = function()
    local home = vim.fn.expand("~/Zettelkasten")

    require("iwe").setup({
      -- LSP server configuration (official docs)
      lsp = {
        cmd = { "iwes" },
        name = "iwes",
        debounce_text_changes = 500,
        auto_format_on_save = true,
        enable_inlay_hints = true, -- Added from official docs
      },

      -- Keybindings (IWE-first approach - 2025-10-23)
      -- IWE is central to navigation workflow, use built-in keybindings
      mappings = {
        enable_markdown_mappings = true, -- -, <C-n>, <C-p>, /d, /w
        enable_telescope_keybindings = true, -- gf, gs, ga, g/, gb, go (IWE navigation)
        enable_lsp_keybindings = true, -- <leader>h, <leader>l (IWE refactoring)
        enable_preview_keybindings = true, -- IWE preview operations
        leader = "<leader>",
        localleader = "<localleader>",
      },

      -- Telescope integration (official docs)
      telescope = {
        enabled = true,
        setup_config = true,
        load_extensions = { "ui-select", "emoji" },
      },

      -- Preview settings (official docs)
      preview = {
        output_dir = vim.fn.expand("~/Zettelkasten/preview"),
        temp_dir = "/tmp",
        auto_open = false,
      },
    })

    -- Auto-insert frontmatter template for new notes created via gd
    vim.api.nvim_create_autocmd("BufNewFile", {
      pattern = home .. "/**/*.md",
      callback = function()
        local filename = vim.fn.expand("%:t:r") -- Get filename without extension
        local title = filename:gsub("-", " "):gsub("^%l", string.upper) -- Convert to Title Case
        local date = os.date("%Y-%m-%d")

        -- Insert frontmatter template
        local lines = {
          "---",
          "title: " .. title,
          "date: " .. date,
          "tags:",
          "  - ",
          "---",
          "",
          "# " .. title,
          "",
          "",
        }

        vim.api.nvim_buf_set_lines(0, 0, 0, false, lines)

        -- Position cursor after "tags:" for immediate input
        vim.api.nvim_win_set_cursor(0, { 4, 4 })
        vim.cmd("startinsert!")
      end,
    })

    vim.notify("🔗 IWE LSP configured for ~/Zettelkasten", vim.log.levels.INFO)
  end,
}
