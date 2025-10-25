-- Plugin: vim-fugitive
-- Purpose: Comprehensive Git integration - industry-standard Git workflow in editor
-- Workflow: utilities
-- Why: Complete version control without context switching - provides full Git CLI
--      functionality inside Neovim, eliminating terminal jumping. ADHD-optimized
--      through consistent :G prefix commands (predictable muscle memory), visual diff
--      interfaces (side-by-side comparisons), and staging workflows (interactive hunks).
--      Critical for Zettelkasten versioning, note evolution tracking, and collaborative
--      knowledge management. Tim Pope's 10+ year standard for Git in Vim.
-- Config: minimal
--
-- Usage:
--   <leader>gs - Git status (interactive staging)
--   <leader>gd - Git diff split, <leader>gb - Git blame
--   <leader>gc - Git commit, <leader>gC - Git commit --amend
--   <leader>gp - Git push, <leader>gP - Git pull
--   <leader>gl - Git log (quickfix), <leader>gL - Git log (location)
--   <leader>ga - Stage current file, <leader>gr - Reset current file
--   :Gac - Add & commit current file, :Gacp - Add, commit, push
--
-- Dependencies:
--   none
--
-- Configuration Notes:
--   Diff algorithm: patience + indent-heuristic (better diff quality)
--   SemBr integration: word-diff regex for markdown semantic line breaks
--   Custom command: GSemBrDiff (wrap-aware diff for long lines)
--   Works with gitsigns.nvim (complementary - fugitive for operations, gitsigns for visuals)

return {
  "tpope/vim-fugitive",
  cmd = {
    "Git",
    "G",
    "Gstatus",
    "Gdiff",
    "Gdiffsplit",
    "Gvdiffsplit",
    "Ghdiffsplit",
    "Gblame",
    "Glog",
    "Gclog",
    "Gread",
    "Gwrite",
    "Ggrep",
    "GMove",
    "GDelete",
    "GBrowse",
    "GRemove",
    "GRename",
    "Glgrep",
    "Gedit",
    "Gsplit",
    "Gvsplit",
    "Gtabedit",
    "Gpedit",
    "Gcommit",
    "Gpush",
    "Gpull",
    "Gfetch",
    "Grebase",
    "Gmerge",
  },
  keys = {
    -- Essential Git operations
    { "<leader>gs", "<cmd>Git<cr>", desc = "Git status" },
    { "<leader>gd", "<cmd>Gdiffsplit<cr>", desc = "Git diff split" },
    { "<leader>gb", "<cmd>Git blame<cr>", desc = "Git blame" },
    { "<leader>gl", "<cmd>Gclog<cr>", desc = "Git log (quickfix)" },
    { "<leader>gL", "<cmd>Glog<cr>", desc = "Git log (location list)" },

    -- Commit operations
    { "<leader>gc", "<cmd>Git commit<cr>", desc = "Git commit" },
    { "<leader>gC", "<cmd>Git commit --amend<cr>", desc = "Git commit amend" },

    -- Push/Pull operations
    { "<leader>gp", "<cmd>Git push<cr>", desc = "Git push" },
    { "<leader>gP", "<cmd>Git pull<cr>", desc = "Git pull" },
    { "<leader>gf", "<cmd>Git fetch<cr>", desc = "Git fetch" },

    -- Stage/Unstage (works in Git status buffer)
    { "<leader>ga", "<cmd>Gwrite<cr>", desc = "Git add (stage) current file" },
    { "<leader>gr", "<cmd>Gread<cr>", desc = "Git checkout (reset) current file" },

    -- Branch operations
    { "<leader>gB", "<cmd>Git branch<cr>", desc = "Git branch list" },
    { "<leader>go", "<cmd>Git checkout<space>", desc = "Git checkout" },

    -- Merge/Rebase
    { "<leader>gm", "<cmd>Git merge<space>", desc = "Git merge" },
    { "<leader>gR", "<cmd>Git rebase<space>", desc = "Git rebase" },

    -- Browse (open in GitHub/GitLab)
    { "<leader>gO", "<cmd>GBrowse<cr>", desc = "Open in browser", mode = { "n", "v" } },
  },
  config = function()
    -- Fugitive configuration

    -- Use vertical splits for diffs by default
    vim.g.fugitive_git_command = "git"

    -- Better diff algorithm
    vim.opt.diffopt:append("algorithm:patience")
    vim.opt.diffopt:append("indent-heuristic")

    -- Custom commands for common workflows
    vim.api.nvim_create_user_command("Gac", "Git add % | Git commit", {})
    vim.api.nvim_create_user_command("Gacp", "Git add % | Git commit | Git push", {})

    -- SemBr-specific Git configuration for diff
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function()
        -- Configure Git to use word-diff for markdown files with SemBr
        vim.fn.system('git config diff.markdown.wordRegex "([^[:space:]]|([[:alnum:]]|/)+)"')
      end,
    })

    -- Integration with SemBr for semantic diffs
    vim.api.nvim_create_user_command("GSemBrDiff", function()
      -- Show diff with semantic line breaks highlighted
      vim.cmd("Gdiffsplit")
      vim.cmd("set wrap")
      vim.cmd("set linebreak")
    end, {})

    vim.notify("📦 vim-fugitive loaded - Industry standard Git integration", vim.log.levels.INFO)
  end,
}
