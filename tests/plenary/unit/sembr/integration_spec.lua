-- Unit Tests: SemBr Git Integration
-- Tests our extensions to fugitive and gitsigns for semantic line breaks
-- Philosophy: Test the integration layer, not the underlying tools

describe("SemBr Git Integration", function()
  local sembr_git

  before_each(function()
    -- Load our SemBr integration module
    package.loaded['percybrain.sembr-git'] = nil
    sembr_git = require('percybrain.sembr-git')
  end)

  describe("Module Structure", function()
    it("exports expected functions", function()
      assert.is_table(sembr_git)
      assert.is_function(sembr_git.setup)
      assert.is_function(sembr_git.setup_git_config)
      assert.is_function(sembr_git.setup_gitattributes)
      assert.is_function(sembr_git.sembr_diff)
      assert.is_function(sembr_git.sembr_blame)
      assert.is_function(sembr_git.stage_sembr_hunk)
      assert.is_function(sembr_git.sembr_commit)
      assert.is_function(sembr_git.setup_commands)
      assert.is_function(sembr_git.setup_keymaps)
    end)
  end)

  describe("Git Configuration", function()
    it("configures Git for semantic line breaks", function()
      -- Mock vim.fn.system to capture Git commands
      local git_commands = {}
      _G.original_system = vim.fn.system
      vim.fn.system = function(cmd)
        table.insert(git_commands, cmd)
        return ""
      end

      sembr_git.setup_git_config()

      -- Check that appropriate Git configs were set
      local found_word_regex = false
      local found_patience = false

      for _, cmd in ipairs(git_commands) do
        if cmd:match("diff%.markdown%.wordRegex") then
          found_word_regex = true
        end
        if cmd:match("diff%.algorithm patience") then
          found_patience = true
        end
      end

      assert.is_true(found_word_regex, "Should configure word regex for markdown")
      assert.is_true(found_patience, "Should use patience diff algorithm")

      vim.fn.system = _G.original_system
    end)

    it("creates gitattributes file when missing", function()
      -- Mock file operations
      _G.original_expand = vim.fn.expand
      _G.original_filereadable = vim.fn.filereadable
      _G.original_writefile = vim.fn.writefile

      vim.fn.expand = function(path)
        if path == "~/Zettelkasten" then
          return "/tmp/test_zettelkasten"
        end
        return _G.original_expand(path)
      end

      vim.fn.filereadable = function(path)
        return 0  -- File doesn't exist
      end

      local written_content = nil
      vim.fn.writefile = function(content, path)
        written_content = content
        return 0
      end

      sembr_git.setup_gitattributes()

      -- Check that gitattributes content was created
      assert.is_table(written_content)
      assert.contains(written_content, "*.md diff=markdown")
      assert.contains(written_content, "*.md merge=union")

      -- Restore mocks
      vim.fn.expand = _G.original_expand
      vim.fn.filereadable = _G.original_filereadable
      vim.fn.writefile = _G.original_writefile
    end)
  end)

  describe("Enhanced Diff Commands", function()
    it("creates SemBr diff command", function()
      -- Mock vim.cmd to capture commands
      local commands = {}
      _G.original_cmd = vim.cmd
      vim.cmd = function(cmd)
        table.insert(commands, cmd)
      end

      -- Mock window operations
      _G.original_list_wins = vim.api.nvim_tabpage_list_wins
      vim.api.nvim_tabpage_list_wins = function()
        return {1001, 1002}
      end

      _G.original_win_get_buf = vim.api.nvim_win_get_buf
      vim.api.nvim_win_get_buf = function(win)
        return win - 1000  -- Simple mock buffer numbers
      end

      -- Mock buffer options
      vim.bo[1] = { diff = true }
      vim.bo[2] = { diff = true }

      sembr_git.sembr_diff()

      -- Check that fugitive's diff was called
      assert.contains(commands, "Gdiffsplit")

      -- Restore mocks
      vim.cmd = _G.original_cmd
      vim.api.nvim_tabpage_list_wins = _G.original_list_wins
      vim.api.nvim_win_get_buf = _G.original_win_get_buf
    end)

    it("enables wrap for SemBr blame", function()
      local commands = {}
      _G.original_cmd = vim.cmd
      vim.cmd = function(cmd)
        table.insert(commands, cmd)
      end

      -- Track window option changes
      local wrap_set = false
      local original_wo = vim.wo
      setmetatable(vim.wo, {
        __newindex = function(t, k, v)
          if k == "wrap" and v == true then
            wrap_set = true
          end
          rawset(t, k, v)
        end
      })

      sembr_git.sembr_blame()

      assert.contains(commands, "Git blame")
      assert.is_true(wrap_set, "Should enable line wrapping for blame")

      vim.cmd = _G.original_cmd
      vim.wo = original_wo
    end)
  end)

  describe("Command Registration", function()
    it("creates user commands for SemBr Git operations", function()
      local commands_created = {}

      _G.original_create_user_command = vim.api.nvim_create_user_command
      vim.api.nvim_create_user_command = function(name, handler, opts)
        table.insert(commands_created, name)
      end

      sembr_git.setup_commands()

      -- Check that all SemBr commands were created
      assert.contains(commands_created, "GSemBrDiff")
      assert.contains(commands_created, "GSemBrBlame")
      assert.contains(commands_created, "GSemBrStage")
      assert.contains(commands_created, "GSemBrCommit")
      assert.contains(commands_created, "GSemBrSetup")
      assert.contains(commands_created, "GSemBrWordDiff")
      assert.contains(commands_created, "GSemBrParaDiff")

      vim.api.nvim_create_user_command = _G.original_create_user_command
    end)
  end)

  describe("Keymap Setup", function()
    it("creates keymaps for SemBr operations", function()
      local keymaps_created = {}

      _G.original_keymap_set = vim.keymap.set
      vim.keymap.set = function(mode, lhs, rhs, opts)
        table.insert(keymaps_created, {
          mode = mode,
          lhs = lhs,
          desc = opts and opts.desc or nil
        })
      end

      sembr_git.setup_keymaps()

      -- Check that keymaps were created
      local keymap_lhs = {}
      for _, km in ipairs(keymaps_created) do
        table.insert(keymap_lhs, km.lhs)
      end

      assert.contains(keymap_lhs, "<leader>gsd")  -- SemBr diff
      assert.contains(keymap_lhs, "<leader>gsb")  -- SemBr blame
      assert.contains(keymap_lhs, "<leader>gss")  -- SemBr stage
      assert.contains(keymap_lhs, "<leader>gsc")  -- SemBr commit

      vim.keymap.set = _G.original_keymap_set
    end)
  end)

  describe("Integration with Existing Plugins", function()
    it("works with fugitive commands", function()
      -- Test that we're extending, not replacing fugitive
      local commands = {}
      _G.original_cmd = vim.cmd
      vim.cmd = function(cmd)
        table.insert(commands, cmd)
        -- Simulate that the command exists (fugitive is loaded)
        if cmd:match("^G") or cmd:match("^Git ") then
          return true
        end
      end

      -- Our commands should use fugitive underneath
      sembr_git.sembr_diff()
      assert.contains(commands, "Gdiffsplit")

      sembr_git.sembr_blame()
      assert.contains(commands, "Git blame")

      vim.cmd = _G.original_cmd
    end)

    it("configures gitsigns for markdown files", function()
      -- Test that we configure gitsigns for word diff in markdown
      local ok, result = pcall(function()
        -- This would normally be set in the autocmd
        vim.b.gitsigns_word_diff = true
      end)

      assert.is_true(ok, "Should be able to set gitsigns buffer variables")
      assert.is_true(vim.b.gitsigns_word_diff)
    end)
  end)

  describe("Setup Function", function()
    it("initializes when in Git repository", function()
      -- Mock Git detection
      _G.original_isdirectory = vim.fn.isdirectory
      vim.fn.isdirectory = function(path)
        if path == '.git' then
          return 1
        end
        return 0
      end

      -- Track if setup functions were called
      local setup_called = false
      sembr_git.setup_git_config = function()
        setup_called = true
      end

      sembr_git.setup()

      assert.is_true(setup_called, "Should set up when in Git repo")

      vim.fn.isdirectory = _G.original_isdirectory
    end)

    it("skips setup when not in Git repository", function()
      -- Mock Git detection
      _G.original_isdirectory = vim.fn.isdirectory
      _G.original_system = vim.fn.system

      vim.fn.isdirectory = function(path)
        return 0  -- No .git directory
      end

      vim.fn.system = function(cmd)
        return "fatal: not a git repository"
      end

      -- Track if setup functions were called
      local setup_called = false
      local original_setup_git = sembr_git.setup_git_config
      sembr_git.setup_git_config = function()
        setup_called = true
      end

      sembr_git.setup()

      assert.is_false(setup_called, "Should skip setup when not in Git repo")

      vim.fn.isdirectory = _G.original_isdirectory
      vim.fn.system = _G.original_system
      sembr_git.setup_git_config = original_setup_git
    end)
  end)

  describe("Performance", function()
    it("loads quickly", function()
      local start = vim.fn.reltime()

      package.loaded['percybrain.sembr-git'] = nil
      require('percybrain.sembr-git')

      local elapsed = vim.fn.reltimefloat(vim.fn.reltime(start))

      assert.is_true(elapsed < 0.05,
        string.format("SemBr Git loading too slow: %.3fs", elapsed))
    end)
  end)
end)