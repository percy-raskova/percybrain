-- Plugin: Gitsigns
-- Purpose: Visual Git integration - show changes, blame, hunk operations in editor
-- Workflow: utilities
-- Why: Context awareness and version control visibility - displays Git status inline
--      (sign column indicators for add/change/delete) reducing context switching to
--      terminal. ADHD-optimized through visual feedback (immediate change visibility),
--      hunk staging (granular commits without CLI), and inline blame (attribution
--      without git log). Critical for Zettelkasten versioning and collaborative note evolution.
-- Config: full
--
-- Usage:
--   ]c / [c - Navigate hunks (next/previous change)
--   <leader>hs - Stage hunk, <leader>hr - Reset hunk
--   <leader>hp - Preview hunk in floating window
--   <leader>hb - Show inline blame, <leader>hB - Toggle persistent blame
--   <leader>hd - Diff current file
--   ih (text object) - Select hunk for operations
--
-- Dependencies:
--   plenary.nvim (Lua utilities)
--
-- Configuration Notes:
--   Sign column glyphs: ┃ (add/change), ▁ (delete), ┆ (untracked)
--   SemBr integration: word_diff enabled for markdown files
--   Custom commands: GSemBrPreview, GSemBrDiffThis (wrap-aware diff viewing)
--   WhichKey integration: <leader>h group for hunk operations
--   Performance: max_file_length = 40000 (disable for large files)

return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  keys = {
    -- Navigation
    {
      "]c",
      function()
        require("gitsigns").next_hunk()
      end,
      desc = "Next Git hunk",
    },
    {
      "[c",
      function()
        require("gitsigns").prev_hunk()
      end,
      desc = "Previous Git hunk",
    },

    -- Actions
    {
      "<leader>hs",
      function()
        require("gitsigns").stage_hunk()
      end,
      desc = "Stage hunk",
    },
    {
      "<leader>hr",
      function()
        require("gitsigns").reset_hunk()
      end,
      desc = "Reset hunk",
    },
    {
      "<leader>hS",
      function()
        require("gitsigns").stage_buffer()
      end,
      desc = "Stage buffer",
    },
    {
      "<leader>hR",
      function()
        require("gitsigns").reset_buffer()
      end,
      desc = "Reset buffer",
    },
    {
      "<leader>hu",
      function()
        require("gitsigns").undo_stage_hunk()
      end,
      desc = "Undo stage hunk",
    },
    {
      "<leader>hp",
      function()
        require("gitsigns").preview_hunk()
      end,
      desc = "Preview hunk",
    },
    {
      "<leader>hb",
      function()
        require("gitsigns").blame_line({ full = true })
      end,
      desc = "Blame line",
    },
    {
      "<leader>hB",
      function()
        require("gitsigns").toggle_current_line_blame()
      end,
      desc = "Toggle line blame",
    },
    {
      "<leader>hd",
      function()
        require("gitsigns").diffthis()
      end,
      desc = "Diff this",
    },
    {
      "<leader>hD",
      function()
        require("gitsigns").diffthis("~")
      end,
      desc = "Diff this ~",
    },
    {
      "<leader>ht",
      function()
        require("gitsigns").toggle_deleted()
      end,
      desc = "Toggle deleted",
    },

    -- Visual mode
    {
      "<leader>hs",
      function()
        require("gitsigns").stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end,
      mode = "v",
      desc = "Stage selected",
    },
    {
      "<leader>hr",
      function()
        require("gitsigns").reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end,
      mode = "v",
      desc = "Reset selected",
    },

    -- Text object
    { "ih", ":<C-U>Gitsigns select_hunk<CR>", mode = { "o", "x" }, desc = "Select hunk" },
  },
  config = function()
    require("gitsigns").setup({
      signs = {
        add = { text = "┃" },
        change = { text = "┃" },
        delete = { text = "▁" },
        topdelete = { text = "▔" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
      },
      signs_staged = {
        add = { text = "┃" },
        change = { text = "┃" },
        delete = { text = "▁" },
        topdelete = { text = "▔" },
        changedelete = { text = "~" },
      },
      signs_staged_enable = true,
      signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
      numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
      linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
      word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
      watch_gitdir = {
        follow_files = true,
      },
      auto_attach = true,
      attach_to_untracked = false,
      current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
        delay = 1000,
        ignore_whitespace = false,
        virt_text_priority = 100,
      },
      current_line_blame_formatter = "<author>, <author_time:%R> - <summary>",
      sign_priority = 6,
      update_debounce = 100,
      status_formatter = nil, -- Use default
      max_file_length = 40000, -- Disable if file is longer than this
      preview_config = {
        -- Options passed to nvim_open_win
        border = "single",
        style = "minimal",
        relative = "cursor",
        row = 0,
        col = 1,
      },

      -- SemBr-specific configuration
      -- Optimize for markdown files with semantic line breaks
      on_attach = function(bufnr)
        -- Special handling for markdown files with SemBr
        if vim.bo[bufnr].filetype == "markdown" then
          -- Configure word diff for better SemBr visualization
          vim.b[bufnr].gitsigns_word_diff = true
        end

        -- WhichKey integration for better discovery
        local wk_ok, wk = pcall(require, "which-key")
        if wk_ok then
          wk.register({
            ["<leader>h"] = { name = "+hunks/git" },
          }, { buffer = bufnr })
        end
      end,

      -- Integration with other plugins
      -- REMOVED: yadm (deprecated/removed in gitsigns 0.7+)
      -- REMOVED: _extmark_signs, _threaded_diff, _refresh_staged_on_update
      --          (internal fields with underscore prefix - not for user config)

      -- Performance optimizations for ADHD/focus features handled by defaults
    })

    -- Custom commands for SemBr workflows
    vim.api.nvim_create_user_command("GSemBrPreview", function()
      require("gitsigns").preview_hunk()
      vim.cmd("set wrap")
      vim.cmd("set linebreak")
    end, { desc = "Preview hunk with SemBr formatting" })

    vim.api.nvim_create_user_command("GSemBrDiffThis", function()
      require("gitsigns").diffthis()
      vim.cmd("set wrap")
      vim.cmd("set linebreak")
    end, { desc = "Diff with SemBr formatting" })

    vim.notify("📊 gitsigns.nvim loaded - Visual Git integration active", vim.log.levels.INFO)
  end,
}
