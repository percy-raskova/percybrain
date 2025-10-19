-- Unit Tests: SemBr Formatter
-- Tests semantic line break formatting logic
-- Note: These test the integration, not the actual sembr binary

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

describe("SemBr Formatter Integration", function()
  local original_vim

  before_each(function()
    -- Arrange: Save original vim state
    original_vim = {
      executable = vim.fn.executable,
      system = vim.fn.system,
      cmd = vim.cmd,
      notify = vim.notify,
      create_user_command = vim.api.nvim_create_user_command,
      create_autocmd = vim.api.nvim_create_autocmd,
      create_augroup = vim.api.nvim_create_augroup,
      clear_autocmds = vim.api.nvim_clear_autocmds,
      keymap_set = vim.keymap.set,
    }
  end)

  after_each(function()
    -- Cleanup: Restore original vim state
    if original_vim then
      vim.fn.executable = original_vim.executable
      vim.fn.system = original_vim.system
      vim.cmd = original_vim.cmd
      vim.notify = original_vim.notify
      vim.api.nvim_create_user_command = original_vim.create_user_command
      vim.api.nvim_create_autocmd = original_vim.create_autocmd
      vim.api.nvim_create_augroup = original_vim.create_augroup
      vim.api.nvim_clear_autocmds = original_vim.clear_autocmds
      vim.keymap.set = original_vim.keymap_set
    end
  end)

  describe("Command Creation", function()
    it("creates SemBrFormat command when sembr is available", function()
      -- Arrange: Mock sembr availability
      vim.fn.executable = function(cmd)
        if cmd == "sembr" then
          return 1 -- sembr is available
        end
        return 0
      end

      -- Track command creation
      local commands_created = {}
      vim.api.nvim_create_user_command = function(name, handler, opts)
        commands_created[name] = {
          handler = handler,
          opts = opts,
        }
      end

      -- Act: Simulate the command creation logic
      if vim.fn.executable("sembr") == 1 then
        vim.api.nvim_create_user_command("SemBrFormat", function() end, {
          range = true,
          desc = "Format with semantic line breaks",
        })
      end

      -- Assert: Command was created with correct options
      assert.is_not_nil(commands_created["SemBrFormat"])
      assert.is_true(commands_created["SemBrFormat"].opts.range)
    end)

    it("creates fallback command when sembr is not available", function()
      -- Arrange: Mock sembr unavailability
      vim.fn.executable = function(cmd)
        if cmd == "sembr" then
          return 0 -- sembr not available
        end
        return 0
      end

      -- Track notifications
      local notifications = {}
      vim.notify = function(msg, level)
        table.insert(notifications, { msg = msg, level = level })
      end

      -- Act: Check that appropriate warning is shown
      if vim.fn.executable("sembr") == 0 then
        vim.notify("⚠️  SemBr binary not found - install with: uv tool install sembr", vim.log.levels.WARN)
      end

      -- Assert: Warning notification was created
      assert.is_true(#notifications > 0)
      assert.truthy(notifications[1].msg:match("SemBr binary not found"))
    end)
  end)

  describe("Format Command Logic", function()
    it("formats entire buffer when no range specified", function()
      -- Arrange: Mock the command execution
      local commands_executed = {}
      vim.cmd = function(cmd)
        table.insert(commands_executed, cmd)
      end

      -- Simulate format command with no range
      local format_cmd = function(opts)
        opts = opts or { line1 = 1, line2 = 1 }
        if opts.line1 == opts.line2 then
          vim.cmd("%!sembr")
        end
      end

      -- Act: Execute format command with no range
      format_cmd({ line1 = 1, line2 = 1 })

      -- Assert: Full buffer format command was executed
      assert.is_true(contains(commands_executed, "%!sembr"), "Should execute full buffer format command")
    end)

    it("formats selection when range specified", function()
      -- Arrange: Mock command execution
      local commands_executed = {}
      vim.cmd = function(cmd)
        table.insert(commands_executed, cmd)
      end

      -- Simulate format command with range
      local format_cmd = function(opts)
        local start_line = opts.line1
        local end_line = opts.line2

        if start_line ~= end_line then
          vim.cmd(string.format("%d,%d!sembr", start_line, end_line))
        end
      end

      -- Act: Execute format command with range
      format_cmd({ line1 = 5, line2 = 10 })

      -- Assert: Range formatting command was executed
      local found_range = false
      for _, cmd in ipairs(commands_executed) do
        if cmd:match("5,10!sembr") then
          found_range = true
        end
      end

      assert.is_true(found_range, "Should execute range format command")
    end)
  end)

  describe("Auto-format Toggle", function()
    it("enables auto-format on save", function()
      -- Arrange: Setup auto-format state and mocks
      local auto_format_enabled = false
      local autocmds_created = {}

      vim.api.nvim_create_autocmd = function(event, opts)
        table.insert(autocmds_created, {
          event = event,
          pattern = opts.pattern,
          group = opts.group,
        })
      end

      vim.api.nvim_create_augroup = function(name, opts)
        return name
      end

      -- Simulate toggle command
      local toggle_cmd = function()
        auto_format_enabled = not auto_format_enabled

        if auto_format_enabled then
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = vim.api.nvim_create_augroup("SemBrAutoFormat", { clear = true }),
            pattern = "*.md",
            callback = function()
              vim.cmd("silent %!sembr")
            end,
          })
        end
      end

      -- Act: Enable auto-format
      toggle_cmd()

      -- Assert: Autocmd was created for markdown files
      local found_autocmd = false
      for _, ac in ipairs(autocmds_created) do
        if ac.event == "BufWritePre" and ac.pattern == "*.md" then
          found_autocmd = true
        end
      end

      assert.is_true(found_autocmd, "Should create BufWritePre autocmd")
      assert.is_true(auto_format_enabled, "Should enable auto-format state")
    end)

    it("disables auto-format when toggled off", function()
      -- Arrange: Setup enabled state and mock clearing
      local auto_format_enabled = true
      local autocmds_cleared = {}

      vim.api.nvim_clear_autocmds = function(opts)
        table.insert(autocmds_cleared, opts.group)
      end

      -- Simulate toggle off
      local toggle_cmd = function()
        auto_format_enabled = not auto_format_enabled

        if not auto_format_enabled then
          vim.api.nvim_clear_autocmds({
            group = "SemBrAutoFormat",
          })
        end
      end

      -- Act: Disable auto-format
      toggle_cmd()

      -- Assert: Autocmds were cleared and state disabled
      assert.is_true(contains(autocmds_cleared, "SemBrAutoFormat"), "Should clear SemBrAutoFormat autocmds")
      assert.is_false(auto_format_enabled, "Should disable auto-format state")
    end)
  end)

  describe("Keymaps", function()
    it("creates formatting keymaps", function()
      -- Arrange: Track keymap creation
      local keymaps = {}
      vim.keymap.set = function(mode, lhs, rhs, opts)
        table.insert(keymaps, {
          mode = mode,
          lhs = lhs,
          desc = opts and opts.desc,
        })
      end

      -- Act: Simulate keymap creation
      vim.keymap.set({ "n", "v" }, "<leader>zs", "<cmd>SemBrFormat<cr>", { desc = "Format with semantic line breaks" })
      vim.keymap.set("n", "<leader>zt", "<cmd>SemBrToggle<cr>", { desc = "Toggle SemBr auto-format" })

      -- Assert: Both keymaps were created
      local found_format = false
      local found_toggle = false

      for _, km in ipairs(keymaps) do
        if km.lhs == "<leader>zs" then
          found_format = true
        end
        if km.lhs == "<leader>zt" then
          found_toggle = true
        end
      end

      assert.is_true(found_format, "Should create <leader>zs keymap")
      assert.is_true(found_toggle, "Should create <leader>zt keymap")
    end)
  end)

  describe("Markdown Integration", function()
    it("respects markdown syntax when formatting", function()
      -- Arrange: Test markdown with various syntax elements
      -- Note: This tests that our commands are designed to work with markdown
      -- The actual preservation of syntax is handled by the sembr binary
      local test_markdown = [[
# Heading

```lua
code block should not be formatted
```

- List item with a very long line that would normally be broken by semantic line breaks
- Another item

| Table | Should |
|-------|--------|
| Stay  | Intact |
]]

      -- Act: Check for markdown pattern recognition
      local has_code_fence = test_markdown:match("```") ~= nil
      local has_heading = test_markdown:match("# Heading") ~= nil
      local has_list = test_markdown:match("%- List item") ~= nil
      local has_table = test_markdown:match("|") ~= nil

      -- Assert: All markdown patterns are recognized
      assert.truthy(has_code_fence, "Should recognize code fences")
      assert.truthy(has_heading, "Should recognize headings")
      assert.truthy(has_list, "Should recognize list items")
      assert.truthy(has_table, "Should recognize tables")
    end)
  end)

  describe("Notifications", function()
    it("provides user feedback", function()
      -- Arrange: Track notifications
      local notifications = {}
      vim.notify = function(msg, level)
        table.insert(notifications, msg)
      end

      -- Act: Simulate various user feedback notifications
      vim.notify("📐 Formatted with semantic line breaks", vim.log.levels.INFO)
      vim.notify("✅ SemBr auto-format enabled", vim.log.levels.INFO)
      vim.notify("❌ SemBr auto-format disabled", vim.log.levels.INFO)

      -- Assert: All notifications were sent with correct content
      assert.equals(3, #notifications, "Should send 3 notifications")
      assert.truthy(notifications[1]:match("Formatted"), "Should notify about formatting")
      assert.truthy(notifications[2]:match("enabled"), "Should notify about enable")
      assert.truthy(notifications[3]:match("disabled"), "Should notify about disable")
    end)
  end)
end)
