-- diffview.nvim: Advanced diff and file history viewer
-- Provides side-by-side diffs, merge tool, file history
-- Excellent complement to fugitive for visual diff operations

return {
  "sindrets/diffview.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- optional
  },
  cmd = {
    "DiffviewOpen",
    "DiffviewClose",
    "DiffviewToggleFiles",
    "DiffviewFocusFiles",
    "DiffviewRefresh",
    "DiffviewFileHistory",
    "DiffviewLog",
  },
  keys = {
    { "<leader>gdo", "<cmd>DiffviewOpen<cr>", desc = "Open diff view" },
    { "<leader>gdc", "<cmd>DiffviewClose<cr>", desc = "Close diff view" },
    { "<leader>gdh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
    { "<leader>gdH", "<cmd>DiffviewFileHistory<cr>", desc = "Branch history" },
    { "<leader>gdt", "<cmd>DiffviewToggleFiles<cr>", desc = "Toggle diff files" },
    { "<leader>gdr", "<cmd>DiffviewRefresh<cr>", desc = "Refresh diff view" },
  },
  config = function()
    local actions = require("diffview.actions")

    require("diffview").setup({
      diff_binaries = false, -- Show diffs for binary files
      enhanced_diff_hl = false, -- See ':h diffview-config-enhanced_diff_hl'
      git_cmd = { "git" }, -- The git executable followed by default args.
      hg_cmd = { "hg" }, -- The hg executable followed by default args.
      use_icons = true, -- Requires nvim-web-devicons
      show_help_hints = true, -- Show hints for how to open the help panel
      watch_index = true, -- Update views and index buffers when the git index changes.
      icons = { -- Only applies when use_icons is true.
        folder_closed = "",
        folder_open = "",
      },
      signs = {
        fold_closed = "",
        fold_open = "",
        done = "✓",
      },
      view = {
        -- Configure the layout and behavior
        default = {
          -- Config for changed files, staged files panel
          layout = "diff2_horizontal",
          winbar_info = false,
        },
        merge_tool = {
          -- Config for conflicted files in diff views during a merge or rebase
          layout = "diff3_horizontal",
          disable_diagnostics = true,
          winbar_info = true,
        },
        file_history = {
          -- Config for file history views
          layout = "diff2_horizontal",
          winbar_info = false,
        },
      },
      file_panel = {
        listing_style = "tree", -- One of 'list' or 'tree'
        tree_options = {
          flatten_dirs = true, -- Flatten dirs that only contain a single dir
          folder_statuses = "only_folded", -- One of 'never', 'only_folded' or 'always'.
        },
        win_config = {
          position = "left",
          width = 35,
          win_opts = {},
        },
      },
      file_history_panel = {
        log_options = {
          git = {
            single_file = {
              diff_merges = "combined",
              follow = true,
            },
            multi_file = {
              diff_merges = "first-parent",
            },
          },
          hg = {
            single_file = {},
            multi_file = {},
          },
        },
        win_config = {
          position = "bottom",
          height = 16,
          win_opts = {},
        },
      },
      commit_log_panel = {
        win_config = {
          win_opts = {},
        },
      },
      default_args = {
        DiffviewOpen = {},
        DiffviewFileHistory = {},
      },
      hooks = {
        -- SemBr-specific hooks for markdown files
        diff_buf_read = function(bufnr)
          -- Enable word wrapping for markdown files with SemBr
          if vim.bo[bufnr].filetype == "markdown" then
            vim.bo[bufnr].wrap = true
            vim.bo[bufnr].linebreak = true
          end
        end,
        diff_buf_win_enter = function(bufnr, winid, ctx)
          -- Configure window for SemBr viewing
          if vim.bo[bufnr].filetype == "markdown" then
            vim.wo[winid].wrap = true
            vim.wo[winid].linebreak = true
            vim.wo[winid].breakindent = true
          end
        end,
      },
      keymaps = {
        disable_defaults = false,
        view = {
          -- The `view` bindings are active in the diff buffers
          { "n", "<tab>", actions.select_next_entry, { desc = "Open diff for next file" } },
          { "n", "<s-tab>", actions.select_prev_entry, { desc = "Open diff for previous file" } },
          { "n", "gf", actions.goto_file_edit, { desc = "Open file in previous tabpage" } },
          { "n", "<C-w><C-f>", actions.goto_file_split, { desc = "Open file in new split" } },
          { "n", "<C-w>gf", actions.goto_file_tab, { desc = "Open file in new tabpage" } },
          { "n", "<leader>e", actions.focus_files, { desc = "Bring focus to file panel" } },
          { "n", "<leader>b", actions.toggle_files, { desc = "Toggle file panel" } },
          { "n", "g<C-x>", actions.cycle_layout, { desc = "Cycle through layouts" } },
          { "n", "[x", actions.prev_conflict, { desc = "Go to previous conflict" } },
          { "n", "]x", actions.next_conflict, { desc = "Go to next conflict" } },
          { "n", "<leader>co", actions.conflict_choose("ours"), { desc = "Choose OURS version" } },
          { "n", "<leader>ct", actions.conflict_choose("theirs"), { desc = "Choose THEIRS version" } },
          { "n", "<leader>cb", actions.conflict_choose("base"), { desc = "Choose BASE version" } },
          { "n", "<leader>ca", actions.conflict_choose("all"), { desc = "Choose all versions" } },
          { "n", "dx", actions.conflict_choose("none"), { desc = "Delete conflict region" } },
          { "n", "<leader>cO", actions.conflict_choose_all("ours"), { desc = "Choose OURS for all" } },
          { "n", "<leader>cT", actions.conflict_choose_all("theirs"), { desc = "Choose THEIRS for all" } },
          { "n", "<leader>cB", actions.conflict_choose_all("base"), { desc = "Choose BASE for all" } },
          { "n", "<leader>cA", actions.conflict_choose_all("all"), { desc = "Choose all for all" } },
          { "n", "dX", actions.conflict_choose_all("none"), { desc = "Delete all conflicts" } },
        },
        diff1 = {
          -- Mappings in single-file diff layouts
          { "n", "g?", actions.help({ "view", "diff1" }), { desc = "Open the help panel" } },
        },
        diff2 = {
          -- Mappings in 2-way diff layouts
          { "n", "g?", actions.help({ "view", "diff2" }), { desc = "Open the help panel" } },
        },
        diff3 = {
          -- Mappings in 3-way diff layouts
          { "n", "2do", actions.diffget("ours"), { desc = "Obtain hunk from OURS" } },
          { "n", "3do", actions.diffget("theirs"), { desc = "Obtain hunk from THEIRS" } },
        },
        diff4 = {
          -- Mappings in 4-way diff layouts
          { "n", "1do", actions.diffget("base"), { desc = "Obtain hunk from BASE" } },
          { "n", "2do", actions.diffget("ours"), { desc = "Obtain hunk from OURS" } },
          { "n", "3do", actions.diffget("theirs"), { desc = "Obtain hunk from THEIRS" } },
        },
        file_panel = {
          { "n", "j", actions.next_entry, { desc = "Next file entry" } },
          { "n", "<down>", actions.next_entry, { desc = "Next file entry" } },
          { "n", "k", actions.prev_entry, { desc = "Previous file entry" } },
          { "n", "<up>", actions.prev_entry, { desc = "Previous file entry" } },
          { "n", "<cr>", actions.select_entry, { desc = "Open diff for entry" } },
          { "n", "o", actions.select_entry, { desc = "Open diff for entry" } },
          { "n", "l", actions.select_entry, { desc = "Open diff for entry" } },
          { "n", "<2-LeftMouse>", actions.select_entry, { desc = "Open diff for entry" } },
          { "n", "-", actions.toggle_stage_entry, { desc = "Stage/unstage entry" } },
          { "n", "s", actions.toggle_stage_entry, { desc = "Stage/unstage entry" } },
          { "n", "S", actions.stage_all, { desc = "Stage all" } },
          { "n", "U", actions.unstage_all, { desc = "Unstage all" } },
          { "n", "X", actions.restore_entry, { desc = "Restore to left side state" } },
          { "n", "L", actions.open_commit_log, { desc = "Open commit log" } },
          { "n", "zo", actions.open_fold, { desc = "Expand fold" } },
          { "n", "h", actions.close_fold, { desc = "Collapse fold" } },
          { "n", "zc", actions.close_fold, { desc = "Collapse fold" } },
          { "n", "za", actions.toggle_fold, { desc = "Toggle fold" } },
          { "n", "zR", actions.open_all_folds, { desc = "Expand all folds" } },
          { "n", "zM", actions.close_all_folds, { desc = "Collapse all folds" } },
          { "n", "<c-b>", actions.scroll_view(-0.25), { desc = "Scroll view up" } },
          { "n", "<c-f>", actions.scroll_view(0.25), { desc = "Scroll view down" } },
          { "n", "<tab>", actions.select_next_entry, { desc = "Open diff for next" } },
          { "n", "<s-tab>", actions.select_prev_entry, { desc = "Open diff for previous" } },
          { "n", "gf", actions.goto_file_edit, { desc = "Open file in prev tabpage" } },
          { "n", "<C-w><C-f>", actions.goto_file_split, { desc = "Open file in split" } },
          { "n", "<C-w>gf", actions.goto_file_tab, { desc = "Open file in tabpage" } },
          { "n", "i", actions.listing_style, { desc = "Toggle list/tree view" } },
          { "n", "f", actions.toggle_flatten_dirs, { desc = "Flatten empty subdirs" } },
          { "n", "R", actions.refresh_files, { desc = "Update file list" } },
          { "n", "<leader>e", actions.focus_files, { desc = "Focus file panel" } },
          { "n", "<leader>b", actions.toggle_files, { desc = "Toggle file panel" } },
          { "n", "g<C-x>", actions.cycle_layout, { desc = "Cycle layouts" } },
          { "n", "[x", actions.prev_conflict, { desc = "Previous conflict" } },
          { "n", "]x", actions.next_conflict, { desc = "Next conflict" } },
          { "n", "g?", actions.help("file_panel"), { desc = "Open help" } },
        },
        file_history_panel = {
          { "n", "g!", actions.options, { desc = "Open option panel" } },
          { "n", "<C-A-d>", actions.open_in_diffview, { desc = "Open entry in diffview" } },
          { "n", "y", actions.copy_hash, { desc = "Copy commit hash" } },
          { "n", "L", actions.open_commit_log, { desc = "Show commit details" } },
          { "n", "zR", actions.open_all_folds, { desc = "Expand all folds" } },
          { "n", "zM", actions.close_all_folds, { desc = "Collapse all folds" } },
          { "n", "j", actions.next_entry, { desc = "Next file entry" } },
          { "n", "<down>", actions.next_entry, { desc = "Next file entry" } },
          { "n", "k", actions.prev_entry, { desc = "Previous file entry" } },
          { "n", "<up>", actions.prev_entry, { desc = "Previous file entry" } },
          { "n", "<cr>", actions.select_entry, { desc = "Open diff for entry" } },
          { "n", "o", actions.select_entry, { desc = "Open diff for entry" } },
          { "n", "l", actions.select_entry, { desc = "Open diff for entry" } },
          { "n", "<2-LeftMouse>", actions.select_entry, { desc = "Open diff for entry" } },
          { "n", "<c-b>", actions.scroll_view(-0.25), { desc = "Scroll view up" } },
          { "n", "<c-f>", actions.scroll_view(0.25), { desc = "Scroll view down" } },
          { "n", "<tab>", actions.select_next_entry, { desc = "Open diff for next" } },
          { "n", "<s-tab>", actions.select_prev_entry, { desc = "Open diff for previous" } },
          { "n", "gf", actions.goto_file_edit, { desc = "Open file in prev tabpage" } },
          { "n", "<C-w><C-f>", actions.goto_file_split, { desc = "Open file in split" } },
          { "n", "<C-w>gf", actions.goto_file_tab, { desc = "Open file in tabpage" } },
          { "n", "<leader>e", actions.focus_files, { desc = "Focus file panel" } },
          { "n", "<leader>b", actions.toggle_files, { desc = "Toggle file panel" } },
          { "n", "g<C-x>", actions.cycle_layout, { desc = "Cycle layouts" } },
          { "n", "g?", actions.help("file_history_panel"), { desc = "Open help" } },
        },
        option_panel = {
          { "n", "<tab>", actions.select_entry, { desc = "Change current option" } },
          { "n", "q", actions.close, { desc = "Close panel" } },
          { "n", "g?", actions.help("option_panel"), { desc = "Open help" } },
        },
        help_panel = {
          { "n", "q", actions.close, { desc = "Close help" } },
          { "n", "<esc>", actions.close, { desc = "Close help" } },
        },
      },
    })

    -- Custom commands for SemBr workflows
    vim.api.nvim_create_user_command("DSemBrDiff", function()
      vim.cmd("DiffviewOpen")
      -- Auto-enable word wrap for markdown files
      vim.defer_fn(function()
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].filetype == "markdown" then
            vim.wo[win].wrap = true
            vim.wo[win].linebreak = true
          end
        end
      end, 100)
    end, { desc = "Open diffview with SemBr formatting" })

    vim.notify("🔍 diffview.nvim loaded", vim.log.levels.INFO)
  end,
}
