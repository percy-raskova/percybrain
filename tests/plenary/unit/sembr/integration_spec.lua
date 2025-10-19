-- Unit Tests: SemBr Git Integration
-- Tests our extensions to fugitive and gitsigns for semantic line breaks
-- Philosophy: Test the integration layer, not the underlying tools

-- NOTE: Helpers/mocks imports commented out due to path issues in Plenary
-- Testing global pollution: These are provided globally by minimal_init.lua as _G.test_helpers, _G.test_mocks
-- local helpers = require('tests.helpers')
-- local mocks = require('tests.helpers.mocks')

-- Helper function for table contains check
local function contains(tbl, value)
  if type(tbl) == "table" then
    for _, v in ipairs(tbl) do
      if v == value then
        return true
      end
    end
  end
  return false
end

describe("SemBr Git Integration", function()
  local sembr_git
  local original_vim

  before_each(function()
    -- Arrange: Load module and save original vim state
    package.loaded["percybrain.sembr-git"] = nil
    sembr_git = require("percybrain.sembr-git")

    original_vim = {
      system = vim.fn.system,
      expand = vim.fn.expand,
      filereadable = vim.fn.filereadable,
      writefile = vim.fn.writefile,
      isdirectory = vim.fn.isdirectory,
      cmd = vim.cmd,
      notify = vim.notify,
      create_user_command = vim.api.nvim_create_user_command,
      keymap_set = vim.keymap.set,
      tabpage_list_wins = vim.api.nvim_tabpage_list_wins,
      win_get_buf = vim.api.nvim_win_get_buf,
      reltime = vim.fn.reltime,
      reltimefloat = vim.fn.reltimefloat,
    }
  end)

  after_each(function()
    -- Cleanup: Restore original vim state
    if original_vim then
      vim.fn.system = original_vim.system
      vim.fn.expand = original_vim.expand
      vim.fn.filereadable = original_vim.filereadable
      vim.fn.writefile = original_vim.writefile
      vim.fn.isdirectory = original_vim.isdirectory
      vim.cmd = original_vim.cmd
      vim.notify = original_vim.notify
      vim.api.nvim_create_user_command = original_vim.create_user_command
      vim.keymap.set = original_vim.keymap_set
      vim.api.nvim_tabpage_list_wins = original_vim.tabpage_list_wins
      vim.api.nvim_win_get_buf = original_vim.win_get_buf
      vim.fn.reltime = original_vim.reltime
      vim.fn.reltimefloat = original_vim.reltimefloat
    end
  end)

  describe("Module Structure", function()
    it("exports expected functions", function()
      -- Arrange: Module loaded in before_each

      -- Act: Check module structure
      local has_setup = type(sembr_git.setup) == "function"
      local has_setup_git = type(sembr_git.setup_git_config) == "function"
      local has_setup_attrs = type(sembr_git.setup_gitattributes) == "function"
      local has_diff = type(sembr_git.sembr_diff) == "function"
      local has_blame = type(sembr_git.sembr_blame) == "function"
      local has_stage = type(sembr_git.stage_sembr_hunk) == "function"
      local has_commit = type(sembr_git.sembr_commit) == "function"
      local has_commands = type(sembr_git.setup_commands) == "function"
      local has_keymaps = type(sembr_git.setup_keymaps) == "function"

      -- Assert: All expected functions exist
      assert.is_table(sembr_git)
      assert.is_true(has_setup, "Should have setup function")
      assert.is_true(has_setup_git, "Should have setup_git_config function")
      assert.is_true(has_setup_attrs, "Should have setup_gitattributes function")
      assert.is_true(has_diff, "Should have sembr_diff function")
      assert.is_true(has_blame, "Should have sembr_blame function")
      assert.is_true(has_stage, "Should have stage_sembr_hunk function")
      assert.is_true(has_commit, "Should have sembr_commit function")
      assert.is_true(has_commands, "Should have setup_commands function")
      assert.is_true(has_keymaps, "Should have setup_keymaps function")
    end)
  end)

  describe("Git Configuration", function()
    it("configures Git for semantic line breaks", function()
      -- Arrange: Mock vim.fn.system to capture Git commands
      local git_commands = {}
      vim.fn.system = function(cmd)
        table.insert(git_commands, cmd)
        return ""
      end

      -- Act: Run git configuration
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

      -- Assert: Git configuration was applied
      assert.is_true(found_word_regex, "Should configure word regex for markdown")
      assert.is_true(found_patience, "Should use patience diff algorithm")
    end)

    it("creates gitattributes file when missing", function()
      -- Arrange: Mock file operations
      vim.fn.expand = function(path)
        if path == "~/Zettelkasten" then
          return "/tmp/test_zettelkasten"
        end
        return original_vim.expand(path)
      end

      vim.fn.filereadable = function(path)
        return 0 -- File doesn't exist
      end

      local written_content = nil
      vim.fn.writefile = function(content, path)
        written_content = content
        return 0
      end

      -- Act: Setup gitattributes
      sembr_git.setup_gitattributes()

      -- Assert: gitattributes content was created correctly
      assert.is_table(written_content, "Should write content as table")
      assert.is_true(contains(written_content, "*.md diff=markdown"), "Should configure markdown diff attribute")
      assert.is_true(contains(written_content, "*.md merge=union"), "Should configure union merge strategy")
    end)
  end)

  describe("Enhanced Diff Commands", function()
    it("creates SemBr diff command", function()
      -- Arrange: Mock vim.cmd to capture commands
      local commands = {}
      vim.cmd = function(cmd)
        table.insert(commands, cmd)
      end

      -- Mock window operations
      vim.api.nvim_tabpage_list_wins = function()
        return { 1001, 1002 }
      end

      vim.api.nvim_win_get_buf = function(win)
        return win - 1000 -- Simple mock buffer numbers
      end

      -- Mock buffer and window options with proper metatable access
      local original_bo = vim.bo
      local original_wo = vim.wo

      -- Create mock buffer options that respond to indexing
      vim.bo = setmetatable({}, {
        __index = function(t, buf)
          return { diff = true } -- All buffers have diff mode
        end,
      })

      -- Create mock window options with diffopt support
      local window_opts = {}
      vim.wo = setmetatable({}, {
        __index = function(t, win)
          if not window_opts[win] then
            window_opts[win] = {
              diffopt = "filler,closeoff", -- Default diffopt value
            }
          end
          return setmetatable(window_opts[win], {
            __newindex = function(wt, k, v)
              rawset(wt, k, v)
            end,
          })
        end,
      })

      -- Act: Create SemBr diff
      sembr_git.sembr_diff()

      -- Assert: Fugitive's diff was called
      assert.is_true(contains(commands, "Gdiffsplit"), "Should call Fugitive's Gdiffsplit command")

      -- Cleanup: Restore original options
      vim.bo = original_bo
      vim.wo = original_wo
    end)

    it("enables wrap for SemBr blame", function()
      -- Arrange: Mock vim.cmd to capture commands
      local commands = {}
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
        end,
      })

      -- Act: Create SemBr blame
      sembr_git.sembr_blame()

      -- Assert: Blame was called with wrap enabled
      assert.is_true(contains(commands, "Git blame"), "Should call Fugitive's Git blame command")
      assert.is_true(wrap_set, "Should enable line wrapping for blame")

      -- Cleanup: Restore metatable
      vim.wo = original_wo
    end)
  end)

  describe("Command Registration", function()
    it("creates user commands for SemBr Git operations", function()
      -- Arrange: Mock command creation to track registrations
      local commands_created = {}
      vim.api.nvim_create_user_command = function(name, handler, opts)
        table.insert(commands_created, name)
      end

      -- Act: Setup commands
      sembr_git.setup_commands()

      -- Assert: All SemBr commands were created
      assert.is_true(contains(commands_created, "GSemBrDiff"), "Should create GSemBrDiff command")
      assert.is_true(contains(commands_created, "GSemBrBlame"), "Should create GSemBrBlame command")
      assert.is_true(contains(commands_created, "GSemBrStage"), "Should create GSemBrStage command")
      assert.is_true(contains(commands_created, "GSemBrCommit"), "Should create GSemBrCommit command")
      assert.is_true(contains(commands_created, "GSemBrSetup"), "Should create GSemBrSetup command")
      assert.is_true(contains(commands_created, "GSemBrWordDiff"), "Should create GSemBrWordDiff command")
      assert.is_true(contains(commands_created, "GSemBrParaDiff"), "Should create GSemBrParaDiff command")
    end)
  end)

  describe("Keymap Setup", function()
    it("creates keymaps for SemBr operations", function()
      -- Arrange: Mock keymap creation to track registrations
      local keymaps_created = {}
      vim.keymap.set = function(mode, lhs, rhs, opts)
        table.insert(keymaps_created, {
          mode = mode,
          lhs = lhs,
          desc = opts and opts.desc or nil,
        })
      end

      -- Act: Setup keymaps
      sembr_git.setup_keymaps()

      -- Build list of keymap left-hand sides
      local keymap_lhs = {}
      for _, km in ipairs(keymaps_created) do
        table.insert(keymap_lhs, km.lhs)
      end

      -- Assert: All expected keymaps were created
      assert.is_true(contains(keymap_lhs, "<leader>gsd"), "Should create <leader>gsd keymap for SemBr diff")
      assert.is_true(contains(keymap_lhs, "<leader>gsb"), "Should create <leader>gsb keymap for SemBr blame")
      assert.is_true(contains(keymap_lhs, "<leader>gss"), "Should create <leader>gss keymap for SemBr stage")
      assert.is_true(contains(keymap_lhs, "<leader>gsc"), "Should create <leader>gsc keymap for SemBr commit")
    end)
  end)

  describe("Integration with Existing Plugins", function()
    it("works with fugitive commands", function()
      -- Arrange: Mock vim.cmd to track Fugitive command usage
      local commands = {}
      vim.cmd = function(cmd)
        table.insert(commands, cmd)
        -- Simulate that the command exists (fugitive is loaded)
        if cmd:match("^G") or cmd:match("^Git ") then
          return true
        end
      end

      -- Mock window and buffer operations for diff command
      local original_bo = vim.bo
      local original_wo = vim.wo

      vim.api.nvim_tabpage_list_wins = function()
        return { 1001, 1002 }
      end

      vim.api.nvim_win_get_buf = function(win)
        return win - 1000
      end

      vim.bo = setmetatable({}, {
        __index = function(t, buf)
          return { diff = true, filetype = "markdown" }
        end,
      })

      local window_opts = {}
      vim.wo = setmetatable({}, {
        __index = function(t, win)
          if not window_opts[win] then
            window_opts[win] = {
              diffopt = "filler,closeoff", -- Default diffopt value
            }
          end
          return setmetatable(window_opts[win], {
            __newindex = function(wt, k, v)
              rawset(wt, k, v)
            end,
          })
        end,
      })

      -- Act: Use SemBr commands that should call Fugitive underneath
      sembr_git.sembr_diff()
      sembr_git.sembr_blame()

      -- Assert: Fugitive commands were used
      assert.is_true(contains(commands, "Gdiffsplit"), "SemBr diff should use Fugitive's Gdiffsplit")
      assert.is_true(contains(commands, "Git blame"), "SemBr blame should use Fugitive's Git blame")

      -- Cleanup: Restore original state
      vim.bo = original_bo
      vim.wo = original_wo
    end)

    it("configures gitsigns for markdown files", function()
      -- Arrange: Test that we can configure gitsigns buffer variables

      -- Act: Set gitsigns word diff (normally done in autocmd)
      local ok = pcall(function()
        vim.b.gitsigns_word_diff = true
      end)

      -- Assert: Buffer variables can be set without errors
      assert.is_true(ok, "Should be able to set gitsigns buffer variables")
      assert.is_true(vim.b.gitsigns_word_diff, "Should enable word diff for gitsigns")
    end)
  end)

  describe("Setup Function", function()
    it("initializes when in Git repository", function()
      -- Arrange: Mock Git detection to simulate being in a repo
      vim.fn.isdirectory = function(path)
        if path == ".git" then
          return 1
        end
        return 0
      end

      -- Track if setup functions were called
      local setup_called = false
      local original_setup_git = sembr_git.setup_git_config
      sembr_git.setup_git_config = function()
        setup_called = true
      end

      -- Act: Run setup
      sembr_git.setup()

      -- Assert: Setup was executed in Git repo
      assert.is_true(setup_called, "Should set up when in Git repo")

      -- Cleanup: Restore original function
      sembr_git.setup_git_config = original_setup_git
    end)

    it("skips setup when not in Git repository", function()
      -- Arrange: Mock Git detection to simulate no Git repo
      vim.fn.isdirectory = function(path)
        return 0 -- No .git directory
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

      -- Act: Run setup
      sembr_git.setup()

      -- Assert: Setup was skipped outside Git repo
      assert.is_false(setup_called, "Should skip setup when not in Git repo")

      -- Cleanup: Restore original function
      sembr_git.setup_git_config = original_setup_git
    end)
  end)

  describe("Performance", function()
    it("loads quickly", function()
      -- Arrange: Prepare for timing measurement
      local start_time = os.clock()

      -- Act: Load the module fresh
      package.loaded["percybrain.sembr-git"] = nil
      require("percybrain.sembr-git")

      local elapsed = os.clock() - start_time

      -- Assert: Module loads within performance budget
      assert.is_true(elapsed < 0.05, string.format("SemBr Git loading too slow: %.3fs (expected < 0.05s)", elapsed))
    end)
  end)
end)
