-- SemBr Git Integration Layer
-- Extends vim-fugitive and gitsigns for semantic line breaks
-- Philosophy: Configure and extend, don't reinvent

local M = {}

-- Configure Git for semantic line breaks
M.setup_git_config = function()
  -- Configure Git's word-diff for markdown files
  -- This makes diffs more readable with SemBr
  local git_configs = {
    -- Better word-level diff for markdown
    'git config diff.markdown.wordRegex "([^[:space:]]|([[:alnum:]]|/)+)"',

    -- Use patience algorithm for better semantic diffs
    "git config diff.algorithm patience",

    -- Show word-level changes in diffs
    "git config diff.wordDiff true",

    -- Better merge strategy for markdown with SemBr
    "git config merge.tool vimdiff",
    "git config merge.conflictstyle diff3",

    -- Configure .gitattributes for markdown
    -- This is done via a file, not git config
  }

  for _, cmd in ipairs(git_configs) do
    vim.fn.system(cmd)
  end

  -- Create/update .gitattributes in Zettelkasten
  M.setup_gitattributes()
end

-- Setup .gitattributes for better markdown handling
M.setup_gitattributes = function()
  local zettelkasten = vim.fn.expand("~/Zettelkasten")
  local gitattributes_path = zettelkasten .. "/.gitattributes"

  local content = {
    "# Semantic Line Breaks configuration for markdown",
    "*.md diff=markdown",
    "*.md merge=union",
    "*.markdown diff=markdown",
    "*.markdown merge=union",
    "",
    "# Treat markdown as text for stats",
    "*.md linguist-detectable=true",
    "*.md linguist-documentation=false",
    "",
    "# LFS for images in vault",
    "*.png filter=lfs diff=lfs merge=lfs -text",
    "*.jpg filter=lfs diff=lfs merge=lfs -text",
    "*.jpeg filter=lfs diff=lfs merge=lfs -text",
    "*.gif filter=lfs diff=lfs merge=lfs -text",
  }

  -- Only create if it doesn't exist (don't overwrite user customizations)
  if vim.fn.filereadable(gitattributes_path) == 0 then
    vim.fn.writefile(content, gitattributes_path)
    vim.notify("📝 Created .gitattributes for SemBr in Zettelkasten", vim.log.levels.INFO)
  end
end

-- Enhanced diff command that works better with SemBr
M.sembr_diff = function()
  -- Use fugitive's diff but with SemBr-friendly settings
  vim.cmd("Gdiffsplit")

  -- Set options for both diff windows
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].diff then
      -- Enable word wrap for better SemBr visualization
      vim.wo[win].wrap = true
      vim.wo[win].linebreak = true
      vim.wo[win].breakindent = true

      -- Show inline word diff
      vim.wo[win].diffopt = vim.wo[win].diffopt .. ",iwhite,algorithm:patience"
    end
  end
end

-- Show SemBr-aware blame
M.sembr_blame = function()
  -- Use fugitive's blame
  vim.cmd("Git blame")

  -- Configure the blame buffer for SemBr
  vim.wo.wrap = true
  vim.wo.linebreak = true
end

-- Stage hunks with SemBr awareness
M.stage_sembr_hunk = function()
  -- Use gitsigns to stage, but show preview with wrap
  local gs = require("gitsigns")

  -- Preview first with SemBr formatting
  gs.preview_hunk()
  vim.defer_fn(function()
    local preview_win = vim.api.nvim_get_current_win()
    vim.wo[preview_win].wrap = true
    vim.wo[preview_win].linebreak = true
  end, 10)

  -- Ask for confirmation
  vim.ui.input({
    prompt = "Stage this hunk? (y/n): ",
  }, function(input)
    if input and input:lower() == "y" then
      gs.stage_hunk()
      vim.notify("✅ Hunk staged", vim.log.levels.INFO)
    end
  end)
end

-- Commit with SemBr-formatted message
M.sembr_commit = function()
  -- Use fugitive's commit but format the message buffer
  vim.cmd("Git commit")

  -- Wait for commit buffer to open
  vim.defer_fn(function()
    if vim.bo.filetype == "gitcommit" then
      -- Enable SemBr formatting in commit message
      vim.bo.textwidth = 72 -- Standard Git commit line length
      vim.wo.wrap = true
      vim.wo.linebreak = true

      -- Add helper text
      vim.api.nvim_buf_set_lines(0, 0, 0, false, {
        "# Semantic Line Breaks: Write one clause per line",
        "# Lines will be wrapped visually but stored as separate lines",
        "#",
      })
    end
  end, 100)
end

-- Create user commands
M.setup_commands = function()
  -- SemBr-specific Git commands that extend fugitive
  vim.api.nvim_create_user_command("GSemBrDiff", M.sembr_diff, {
    desc = "Git diff with SemBr formatting",
  })

  vim.api.nvim_create_user_command("GSemBrBlame", M.sembr_blame, {
    desc = "Git blame with SemBr formatting",
  })

  vim.api.nvim_create_user_command("GSemBrStage", M.stage_sembr_hunk, {
    desc = "Stage hunk with SemBr preview",
  })

  vim.api.nvim_create_user_command("GSemBrCommit", M.sembr_commit, {
    desc = "Git commit with SemBr message formatting",
  })

  vim.api.nvim_create_user_command("GSemBrSetup", M.setup_git_config, {
    desc = "Configure Git for semantic line breaks",
  })

  -- Word-level diff for current file
  vim.api.nvim_create_user_command("GSemBrWordDiff", function()
    vim.cmd("!git diff --word-diff=color %")
  end, {
    desc = "Show word-level diff in terminal",
  })

  -- Show paragraph-aware diff
  vim.api.nvim_create_user_command("GSemBrParaDiff", function()
    vim.cmd('!git diff --word-diff-regex="[^[:space:]]+" %')
  end, {
    desc = "Show paragraph-aware diff",
  })
end

-- Setup keymaps for SemBr Git operations
M.setup_keymaps = function()
  local opts = { noremap = true, silent = true }

  -- Override some default Git mappings with SemBr versions
  vim.keymap.set("n", "<leader>gsd", M.sembr_diff, vim.tbl_extend("force", opts, { desc = "SemBr Git diff" }))

  vim.keymap.set("n", "<leader>gsb", M.sembr_blame, vim.tbl_extend("force", opts, { desc = "SemBr Git blame" }))

  vim.keymap.set("n", "<leader>gss", M.stage_sembr_hunk, vim.tbl_extend("force", opts, { desc = "SemBr stage hunk" }))

  vim.keymap.set("n", "<leader>gsc", M.sembr_commit, vim.tbl_extend("force", opts, { desc = "SemBr Git commit" }))
end

-- Main setup function
M.setup = function()
  -- No configuration options needed currently

  -- Only set up if in a Git repository
  if vim.fn.isdirectory(".git") == 1 or vim.fn.system("git rev-parse --git-dir 2>/dev/null"):match("^/") then
    -- Configure Git for SemBr
    M.setup_git_config()

    -- Create commands
    M.setup_commands()

    -- Setup keymaps
    M.setup_keymaps()

    -- Auto-configure for markdown files
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "markdown", "vimwiki", "telekasten" },
      callback = function()
        -- Set buffer-local options for better SemBr viewing
        vim.wo.wrap = true
        vim.wo.linebreak = true
        vim.wo.breakindent = true

        -- Configure gitsigns for word diff in markdown
        local gs_ok = pcall(require, "gitsigns")
        if gs_ok then
          -- Enable word diff for current buffer
          vim.b.gitsigns_word_diff = true
        end
      end,
    })

    vim.notify("🔀 SemBr Git integration configured - extending fugitive & gitsigns", vim.log.levels.INFO)
  end
end

return M
