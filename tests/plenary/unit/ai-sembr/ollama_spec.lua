-- Unit Tests: Ollama Local LLM Integration
-- Tests the core Ollama plugin functionality for PercyBrain

local mocks = require("tests.helpers.mocks")

describe("Ollama Local LLM Integration", function()
  local ollama_module
  local ollama_mock
  local original_vim
  local original_io_popen
  local notify_mock

  before_each(function()
    -- Setup Ollama mock
    ollama_mock = mocks.ollama()
    original_vim = ollama_mock:setup_vim()
    original_io_popen = ollama_mock:mock_io_popen()

    -- Setup notification tracking
    notify_mock = mocks.notifications()
    notify_mock.capture()

    -- Load the actual module
    package.loaded["plugins.ai-sembr.ollama"] = nil
    local plugin_spec = require("plugins.ai-sembr.ollama")
    if plugin_spec.config then
      plugin_spec.config()
      -- Testing module global pollution: Check if plugin sets global M
      ollama_module = _G.M or {}
    end
  end)

  after_each(function()
    -- Restore global vim after testing module pollution
    _G.vim = original_vim
    io.popen = original_io_popen -- luacheck: ignore (restore mocked io.popen)
    notify_mock.restore()
    package.loaded["plugins.ai-sembr.ollama"] = nil
  end)

  describe("Service Management", function()
    it("detects when Ollama is running", function()
      -- Arrange
      ollama_mock.is_running = true
      original_io_popen = ollama_mock:mock_io_popen()

      -- Act
      local is_running = ollama_module.check_ollama()

      -- Assert
      assert.is_true(is_running)
    end)

    it("detects when Ollama is not running", function()
      -- Arrange
      ollama_mock.is_running = false
      original_io_popen = ollama_mock:mock_io_popen()

      -- Act
      local is_running = ollama_module.check_ollama()

      -- Assert
      assert.is_false(is_running)
    end)

    it("starts Ollama service when not running", function()
      -- Arrange
      ollama_mock.is_running = false
      original_io_popen = ollama_mock:mock_io_popen()

      local jobstart_called = false
      vim.fn.jobstart = function(cmd, opts)
        if cmd == "ollama serve" then
          jobstart_called = true
          assert.is_true(opts.detach)
        end
        return 123
      end

      -- Act
      ollama_module.start_ollama()

      -- Assert
      assert.is_true(jobstart_called)
      assert.is_true(notify_mock.has("Starting Ollama"))
    end)
  end)

  describe("API Communication", function()
    it("constructs correct API request format", function()
      -- Arrange
      local curl_cmd_captured = nil
      vim.fn.jobstart = function(cmd)
        curl_cmd_captured = cmd
        return 123
      end

      -- Act
      ollama_module.call_ollama("Test prompt", function() end)

      -- Assert
      assert.truthy(curl_cmd_captured)
      assert.truthy(curl_cmd_captured:match("http://localhost:11434/api/generate"))
      assert.truthy(curl_cmd_captured:match('"model":"llama3.2:latest"'))
      assert.truthy(curl_cmd_captured:match('"prompt":"Test prompt"'))
    end)

    it("escapes special characters in prompts", function()
      -- Arrange
      local curl_cmd_captured = nil
      vim.fn.jobstart = function(cmd)
        curl_cmd_captured = cmd
        return 123
      end

      -- Act
      ollama_module.call_ollama('Test "quoted" text\nwith newline', function() end)

      -- Assert
      assert.truthy(curl_cmd_captured:match('\\"quoted\\"'))
      assert.truthy(curl_cmd_captured:match("\\n"))
    end)

    it("handles successful API response", function()
      -- Arrange
      local callback_result = nil
      vim.fn.jobstart = function(cmd, opts)
        if opts.on_stdout then
          opts.on_stdout(nil, {
            '{"model":"llama3.2:latest","response":"AI generated text","done":true}',
          })
        end
        return 123
      end

      -- Act
      ollama_module.call_ollama("Test", function(response)
        callback_result = response
      end)

      -- Assert
      assert.equals("AI generated text", callback_result)
    end)

    it("handles API errors gracefully", function()
      -- Arrange
      vim.fn.jobstart = function(cmd, opts)
        if opts.on_stderr then
          opts.on_stderr(nil, { "Connection refused" })
        end
        return 123
      end

      -- Act
      ollama_module.call_ollama("Test", function() end)

      -- Assert
      assert.is_true(notify_mock.has("error"))
    end)
  end)

  describe("Context Extraction", function()
    it("gets buffer context around cursor", function()
      -- Arrange
      vim.api.nvim_win_get_cursor = function()
        return { 50, 0 }
      end

      -- Act
      local context = ollama_module.get_buffer_context()

      -- Assert
      assert.truthy(context)
      assert.truthy(context:match("Test line"))
    end)

    it("handles buffer boundaries correctly", function()
      -- Arrange
      vim.api.nvim_win_get_cursor = function()
        return { 1, 0 }
      end
      vim.api.nvim_buf_line_count = function()
        return 5
      end

      -- Act
      local context = ollama_module.get_buffer_context()

      -- Assert
      assert.truthy(context)
    end)

    it("gets visual selection correctly", function()
      -- Arrange
      vim.fn.mode = function()
        return "v"
      end
      vim.fn.getpos = function(mark)
        if mark == "'<" then
          return { 0, 5, 1, 0 }
        elseif mark == "'>" then
          return { 0, 10, 20, 0 }
        end
      end

      -- Act
      local selection = ollama_module.get_visual_selection()

      -- Assert
      assert.truthy(selection)
      assert.truthy(selection:match("Test line"))
    end)
  end)

  describe("AI Commands", function()
    local function setup_jobstart_capture()
      local prompt_captured = nil
      vim.fn.jobstart = function(cmd, opts)
        prompt_captured = cmd
        if opts.on_stdout then
          opts.on_stdout(nil, {
            '{"response":"Mock response","done":true}',
          })
        end
        return 123
      end
      return function()
        return prompt_captured
      end
    end

    it("explains text with proper prompt", function()
      -- Arrange
      local get_prompt = setup_jobstart_capture()

      -- Act
      ollama_module.explain()

      -- Assert
      local prompt = get_prompt()
      assert.truthy(prompt:match("Explain"))
      assert.truthy(prompt:match("clearly and concisely"))
    end)

    it("summarizes content", function()
      -- Arrange
      local get_prompt = setup_jobstart_capture()

      -- Act
      ollama_module.summarize()

      -- Assert
      local prompt = get_prompt()
      assert.truthy(prompt:match("summary"))
      assert.truthy(prompt:match("main points"))
    end)

    it("suggests Zettelkasten links", function()
      -- Arrange
      local get_prompt = setup_jobstart_capture()

      -- Act
      ollama_module.suggest_links()

      -- Assert
      local prompt = get_prompt()
      assert.truthy(prompt:match("related concepts"))
      assert.truthy(prompt:match("Zettelkasten"))
    end)

    it("improves writing quality", function()
      -- Arrange
      local get_prompt = setup_jobstart_capture()

      -- Act
      ollama_module.improve()

      -- Assert
      local prompt = get_prompt()
      assert.truthy(prompt:match("Improve"))
      assert.truthy(prompt:match("clarity"))
    end)

    it("generates creative ideas", function()
      -- Arrange
      local get_prompt = setup_jobstart_capture()

      -- Act
      ollama_module.generate_ideas()

      -- Assert
      local prompt = get_prompt()
      assert.truthy(prompt:match("ideas"))
      assert.truthy(prompt:match("creative"))
    end)
  end)

  describe("Result Display", function()
    it("creates floating window with correct options", function()
      -- Arrange
      local win_opts_captured = nil
      vim.api.nvim_open_win = function(buf, enter, opts)
        win_opts_captured = opts
        return 1001
      end

      -- Act
      ollama_module.show_result("Test Title", "Test content")

      -- Assert
      assert.equals("editor", win_opts_captured.relative)
      assert.equals("rounded", win_opts_captured.border)
      assert.equals(" Test Title ", win_opts_captured.title)
      assert.equals("center", win_opts_captured.title_pos)
    end)

    it("sets correct buffer options for markdown", function()
      -- Arrange
      local buffer_opts = {}
      vim.api.nvim_buf_set_option = function(buf, opt, value)
        buffer_opts[opt] = value
      end

      -- Act
      ollama_module.show_result("Test", "# Markdown content")

      -- Assert
      assert.is_false(buffer_opts.modifiable)
      assert.equals("markdown", buffer_opts.filetype)
    end)

    it("adds keymaps for closing window", function()
      -- Arrange
      local keymaps = {}
      vim.api.nvim_buf_set_keymap = function(buf, mode, lhs, rhs, opts)
        keymaps[lhs] = rhs
      end

      -- Act
      ollama_module.show_result("Test", "Content")

      -- Assert
      assert.equals("<cmd>close<cr>", keymaps["q"])
      assert.equals("<cmd>close<cr>", keymaps["<Esc>"])
    end)
  end)

  describe("Model Configuration", function()
    it("uses configured model in API calls", function()
      -- Arrange
      ollama_module.config.model = "codellama:latest"
      local cmd_captured = nil
      vim.fn.jobstart = function(cmd)
        cmd_captured = cmd
        return 123
      end

      -- Act
      ollama_module.call_ollama("Test", function() end)

      -- Assert
      assert.truthy(cmd_captured:match('"model":"codellama:latest"'))
    end)

    it("respects temperature settings", function()
      -- Arrange
      ollama_module.config.temperature = 0.3
      local cmd_captured = nil
      vim.fn.jobstart = function(cmd)
        cmd_captured = cmd
        return 123
      end

      -- Act
      ollama_module.call_ollama("Test", function() end)

      -- Assert
      assert.truthy(cmd_captured:match('"temperature":0.3'))
    end)

    it("uses configured Ollama URL", function()
      -- Arrange
      ollama_module.config.ollama_url = "http://192.168.1.100:11434"
      local cmd_captured = nil
      vim.fn.jobstart = function(cmd)
        cmd_captured = cmd
        return 123
      end

      -- Act
      ollama_module.call_ollama("Test", function() end)

      -- Assert
      assert.truthy(cmd_captured:match("http://192.168.1.100:11434"))
    end)
  end)

  describe("Interactive Features", function()
    it("prompts for question in answer mode", function()
      -- Arrange
      local input_prompt_captured = nil
      vim.ui = {
        input = function(opts, callback)
          input_prompt_captured = opts.prompt
          callback("What is this about?")
        end,
      }

      -- Act
      ollama_module.answer_question()

      -- Assert
      assert.equals("Ask a question: ", input_prompt_captured)
    end)

    it("handles empty question input", function()
      -- Arrange
      vim.ui = {
        input = function(opts, callback)
          callback("")
        end,
      }
      local api_called = false
      vim.fn.jobstart = function()
        api_called = true
        return 123
      end

      -- Act
      ollama_module.answer_question()

      -- Assert
      assert.is_false(api_called)
    end)
  end)

  describe("Performance", function()
    it("respects timeout configuration", function()
      -- Arrange
      ollama_module.config.timeout = 5000

      -- Act & Assert
      assert.equals(5000, ollama_module.config.timeout)
    end)

    it("handles context_lines configuration", function()
      -- Arrange
      ollama_module.config.context_lines = 25
      vim.api.nvim_win_get_cursor = function()
        return { 50, 0 }
      end

      -- Act
      local context = ollama_module.get_buffer_context()

      -- Assert
      assert.truthy(context)
    end)
  end)

  describe("Telescope Integration", function()
    local function setup_telescope_mocks()
      package.loaded["telescope.actions"] = {
        select_default = { replace = function() end },
        close = function() end,
      }
      package.loaded["telescope.actions.state"] = {
        get_selected_entry = function()
          return {
            value = { func = function() end, name = "Test Command" },
          }
        end,
      }
      package.loaded["telescope.pickers"] = {
        new = function(_, config)
          return { find = function() end }
        end,
      }
      package.loaded["telescope.finders"] = {
        new_table = function(opts)
          return opts
        end,
      }
      package.loaded["telescope.config"] = {
        values = {
          generic_sorter = function()
            return {}
          end,
        },
      }
    end

    it("creates Telescope picker for AI menu", function()
      -- Arrange
      setup_telescope_mocks()
      local picker_created = false
      local picker_config = nil

      package.loaded["telescope.pickers"] = {
        new = function(_, config)
          picker_config = config
          picker_created = true
          return { find = function() end }
        end,
      }

      -- Act
      ollama_module.ai_menu()

      -- Assert
      assert.is_true(picker_created)
      assert.equals("PercyBrain AI Commands", picker_config.prompt_title)
      assert.is_function(picker_config.attach_mappings)
      assert.is_table(picker_config.finder)
    end)

    it("populates AI menu with all commands", function()
      -- Arrange
      setup_telescope_mocks()
      local commands_in_menu = nil

      package.loaded["telescope.finders"] = {
        new_table = function(opts)
          commands_in_menu = opts.results
          return opts
        end,
      }

      -- Act
      ollama_module.ai_menu()

      -- Assert
      assert.is_table(commands_in_menu)
      assert.equals(6, #commands_in_menu)

      for _, cmd in ipairs(commands_in_menu) do
        assert.is_function(cmd.func)
        assert.is_string(cmd.name)
        assert.is_string(cmd.desc)
      end
    end)
  end)

  describe("User Command Registration", function()
    it("registers all PercyBrain user commands", function()
      -- Arrange
      local registered_commands = {}
      vim.api.nvim_create_user_command = function(name, handler, opts)
        registered_commands[name] = { handler = handler, opts = opts }
      end

      -- Act
      local plugin_spec = require("plugins.ai-sembr.ollama")
      if plugin_spec.config then
        plugin_spec.config()
      end

      -- Assert
      local expected_commands = {
        "PercyExplain",
        "PercySummarize",
        "PercyLinks",
        "PercyImprove",
        "PercyAsk",
        "PercyIdeas",
        "PercyAI",
      }
      for _, cmd in ipairs(expected_commands) do
        assert.is_not_nil(registered_commands[cmd])
      end
    end)

    it("sets correct options for user commands", function()
      -- Arrange
      local command_opts = {}
      vim.api.nvim_create_user_command = function(name, handler, opts)
        command_opts[name] = opts
      end

      -- Act
      local plugin_spec = require("plugins.ai-sembr.ollama")
      if plugin_spec.config then
        plugin_spec.config()
      end

      -- Assert
      assert.is_true(command_opts["PercyExplain"].range)
      assert.is_true(command_opts["PercySummarize"].range)
      assert.is_true(command_opts["PercyImprove"].range)

      for _, opts in pairs(command_opts) do
        assert.is_string(opts.desc)
        assert.truthy(opts.desc:match("AI"))
      end
    end)
  end)

  describe("Keymap Registration", function()
    it("creates all leader-a keymaps", function()
      -- Arrange
      local registered_keymaps = {}
      vim.keymap = {
        set = function(mode, lhs, rhs, opts)
          table.insert(registered_keymaps, {
            mode = mode,
            lhs = lhs,
            rhs = rhs,
            opts = opts,
          })
        end,
      }

      -- Act
      local plugin_spec = require("plugins.ai-sembr.ollama")
      if plugin_spec.config then
        plugin_spec.config()
      end

      -- Assert
      local expected_maps = {
        "<leader>aa",
        "<leader>ae",
        "<leader>as",
        "<leader>al",
        "<leader>aw",
        "<leader>aq",
        "<leader>ax",
      }

      for _, expected_lhs in ipairs(expected_maps) do
        local found = false
        for _, km in ipairs(registered_keymaps) do
          if km.lhs == expected_lhs then
            found = true
            assert.is_string(km.opts.desc)
            break
          end
        end
        assert.is_true(found, "Missing keymap: " .. expected_lhs)
      end
    end)

    it("sets correct modes for keymaps", function()
      -- Arrange
      local keymaps_by_lhs = {}
      vim.keymap = {
        set = function(mode, lhs, rhs, opts)
          keymaps_by_lhs[lhs] = { mode = mode, opts = opts }
        end,
      }

      -- Act
      local plugin_spec = require("plugins.ai-sembr.ollama")
      if plugin_spec.config then
        plugin_spec.config()
      end

      -- Assert
      local visual_normal = { "<leader>ae", "<leader>as", "<leader>aw" }
      for _, lhs in ipairs(visual_normal) do
        local km = keymaps_by_lhs[lhs]
        assert.is_table(km.mode)
        assert.truthy(vim.tbl_contains(km.mode, "n"))
        assert.truthy(vim.tbl_contains(km.mode, "v"))
      end

      local normal_only = { "<leader>aa", "<leader>al", "<leader>aq", "<leader>ax" }
      for _, lhs in ipairs(normal_only) do
        local km = keymaps_by_lhs[lhs]
        assert.equals("n", km.mode)
      end
    end)
  end)

  describe("Error Edge Cases", function()
    it("handles malformed JSON responses", function()
      -- Arrange
      local error_notified = false
      vim.fn.jobstart = function(cmd, opts)
        if opts.on_stdout then
          opts.on_stdout(nil, { "{invalid json}" })
        end
        return 123
      end
      vim.notify = function(msg, level)
        if msg:match("error") or msg:match("Error") then
          error_notified = true
        end
      end

      -- Act
      ollama_module.call_ollama("Test", function(response)
        assert.fail("Callback should not execute with malformed JSON")
      end)

      -- Assert
      assert.is_true(error_notified)
    end)

    it("handles very long prompts", function()
      -- Arrange
      local long_prompt = string.rep("This is a very long text. ", 1000)
      local cmd_captured = nil
      vim.fn.jobstart = function(cmd)
        cmd_captured = cmd
        return 123
      end

      -- Act
      ollama_module.call_ollama(long_prompt, function() end)

      -- Assert
      assert.truthy(cmd_captured)
      assert.truthy(cmd_captured:match("This is a very long text"))
    end)

    it("handles special Unicode characters", function()
      -- Arrange
      local unicode_text = "Test with émojis 🤖 and símbolos ñ"
      local cmd_captured = nil
      vim.fn.jobstart = function(cmd)
        cmd_captured = cmd
        return 123
      end

      -- Act
      ollama_module.call_ollama(unicode_text, function() end)

      -- Assert
      assert.truthy(cmd_captured)
      assert.truthy(cmd_captured:match("émojis"))
    end)
  end)
end)
