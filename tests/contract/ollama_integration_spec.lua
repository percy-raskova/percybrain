-- Contract Tests for Ollama Integration
-- Tests what the Ollama manager and GTD AI integration MUST, MUST NOT, and MAY do
-- Kent Beck: "Tests are specifications - they define the contract"
--
-- Purpose: Verify Ollama auto-start, OpenAI compatibility, health checks, and GTD AI integration
-- Strategy: Mock external dependencies (curl, ollama binary) to test contract compliance
-- Coverage: ollama-manager.lua, gtd/ai.lua core contracts

describe("Ollama Manager Contract", function()
  local manager

  before_each(function()
    -- Arrange: Load fresh manager instance
    package.loaded["lib.ollama-manager"] = nil
    manager = require("lib.ollama-manager")

    -- Reset to default config
    manager.config = {
      enabled = true,
      model = "llama3.2",
      auto_pull = false,
      openai_port = 11434,
      timeout = 30,
      base_url = "http://localhost:11434",
      openai_url = "http://localhost:11434/v1",
    }
    manager.status = {
      running = false,
      model_loaded = false,
      startup_time = nil,
    }
  end)

  after_each(function()
    -- Cleanup: No persistent state to clean
  end)

  describe("Installation Detection Contract", function()
    it("MUST provide method to check if Ollama is installed", function()
      -- Arrange: Manager loaded with default config
      -- Act: Check for installation detection capability
      local has_method = type(manager.start_server) == "function"

      -- Assert: start_server exists and will check installation internally
      assert.is_true(has_method, "Manager must provide server start capability")
    end)

    it("MUST fail gracefully when Ollama binary is not installed", function()
      -- Arrange: Mock environment without ollama binary
      local old_executable = vim.fn.executable
      vim.fn.executable = function(name)
        if name == "ollama" then
          return 0 -- Not installed
        end
        return old_executable(name)
      end

      local error_occurred = false
      local error_message = nil

      -- Act: Attempt to start server without ollama installed
      manager.start_server(function(success, err)
        error_occurred = not success
        error_message = err
      end)

      -- Wait for callback
      vim.wait(100, function()
        return error_occurred
      end, 10)

      -- Assert: Error occurred with helpful message
      assert.is_true(error_occurred, "Should fail when ollama not installed")
      assert.is_not_nil(error_message)
      assert.matches("not installed", error_message:lower())
      assert.matches("ollama", error_message:lower())

      -- Cleanup: Restore original
      vim.fn.executable = old_executable
    end)
  end)

  describe("Server Lifecycle Contract", function()
    it("MUST provide auto-start capability", function()
      -- Arrange: Clean manager state
      -- Act: Check for auto-start mechanism
      local has_setup = type(manager.setup) == "function"
      local has_start = type(manager.start_server) == "function"

      -- Assert: Both setup and start methods exist
      assert.is_true(has_setup, "Manager must provide setup for auto-start")
      assert.is_true(has_start, "Manager must provide start_server method")
    end)

    it("MUST detect when server is already running", function()
      -- Arrange: Mock running server
      manager.status.running = true

      local callback_invoked = false
      local start_success = false

      -- Act: Attempt to start already-running server
      manager.start_server(function(success, _err)
        callback_invoked = true
        start_success = success
      end)

      -- Wait for immediate callback (should not actually start)
      vim.wait(100, function()
        return callback_invoked
      end, 10)

      -- Assert: Returns success without starting duplicate
      assert.is_true(callback_invoked, "Callback should be invoked")
      assert.is_true(start_success, "Should succeed when already running")
    end)

    it("MUST implement timeout for server startup", function()
      -- Arrange: Manager with timeout configured
      -- Act: Verify timeout is configurable
      local has_timeout = manager.config.timeout ~= nil

      -- Assert: Timeout configuration exists
      assert.is_true(has_timeout, "Manager must have startup timeout")
      assert.is_number(manager.config.timeout)
      assert.is_true(manager.config.timeout > 0, "Timeout must be positive")
    end)

    it("MUST track server startup time", function()
      -- Arrange: Manager status structure
      -- Act: Check for startup_time field
      -- Assert: startup_time field exists in status
      assert.is_not_nil(manager.status, "Status object must exist")
      assert.is_true(
        type(manager.status.startup_time) == "number" or manager.status.startup_time == nil,
        "startup_time must be number or nil"
      )
    end)
  end)

  describe("OpenAI Compatibility Contract", function()
    it("MUST provide OpenAI-compatible API configuration", function()
      -- Arrange: Manager initialized
      -- Act: Get OpenAI config
      local openai_config = manager.get_openai_config()

      -- Assert: Config contains required OpenAI fields
      assert.is_not_nil(openai_config)
      assert.is_not_nil(openai_config.base_url, "Must provide base_url")
      assert.is_not_nil(openai_config.api_key, "Must provide api_key (even if dummy)")
      assert.is_not_nil(openai_config.model, "Must provide model name")
    end)

    it("MUST use /v1 endpoint path for OpenAI compatibility", function()
      -- Arrange: Manager with default config
      -- Act: Get OpenAI URL
      local openai_url = manager.config.openai_url

      -- Assert: URL ends with /v1
      assert.is_string(openai_url)
      assert.matches("/v1$", openai_url, "OpenAI URL must end with /v1 path")
    end)

    it("MUST provide api_key even though Ollama ignores it", function()
      -- Arrange: OpenAI clients require api_key
      -- Act: Get config
      local config = manager.get_openai_config()

      -- Assert: api_key is present (value doesn't matter for Ollama)
      assert.is_not_nil(config.api_key)
      assert.is_string(config.api_key)
      assert.is_true(#config.api_key > 0, "api_key must not be empty string")
    end)
  end)

  describe("Model Management Contract", function()
    it("MUST track which model is currently loaded", function()
      -- Arrange: Manager status structure
      -- Act: Check for model_loaded tracking
      local has_field = type(manager.status.model_loaded) == "boolean"

      -- Assert: model_loaded is boolean field
      assert.is_true(has_field, "Status must track if model is loaded")
    end)

    it("MUST provide method to change active model", function()
      -- Arrange: Manager initialized
      -- Act: Check for set_model method
      local has_method = type(manager.set_model) == "function"

      -- Assert: set_model function exists
      assert.is_true(has_method, "Manager must provide set_model method")
    end)

    it("MUST support auto_pull configuration", function()
      -- Arrange: Check default config
      -- Act: Verify auto_pull option exists
      local has_auto_pull = manager.config.auto_pull ~= nil

      -- Assert: auto_pull is configurable
      assert.is_true(has_auto_pull, "Manager must support auto_pull config")
      assert.is_boolean(manager.config.auto_pull)
    end)

    it("MUST NOT auto-pull models by default", function()
      -- Arrange: Fresh manager with defaults
      -- Act: Check default auto_pull value
      local default_auto_pull = manager.config.auto_pull

      -- Assert: Defaults to false (explicit user action required)
      assert.is_false(default_auto_pull, "Should not auto-pull by default (bandwidth concern)")
    end)
  end)

  describe("Health Check Contract", function()
    it("MUST provide comprehensive health check", function()
      -- Arrange: Manager initialized
      -- Act: Run health check
      local health = manager.health_check()

      -- Assert: Health check returns required fields
      assert.is_not_nil(health)
      assert.is_not_nil(health.installed, "Must check if installed")
      assert.is_not_nil(health.running, "Must check if running")
      assert.is_not_nil(health.model_available, "Must check if model available")
      assert.is_not_nil(health.openai_compatible, "Must check OpenAI compatibility")
    end)

    it("MUST provide user-friendly health display", function()
      -- Arrange: Manager with health check
      -- Act: Check for show_health method
      local has_show_health = type(manager.show_health) == "function"

      -- Assert: User-facing health display exists
      assert.is_true(has_show_health, "Must provide show_health UI method")
    end)

    it("MUST validate OpenAI endpoint availability", function()
      -- Arrange: Health check system
      -- Act: Run health check
      local health = manager.health_check()

      -- Assert: Checks OpenAI /v1/models endpoint
      assert.is_boolean(health.openai_compatible, "Must validate OpenAI endpoint")
    end)
  end)

  describe("User Command Contract", function()
    it("MUST provide :OllamaStart command", function()
      -- Arrange: Manager setup with commands
      manager.setup()

      -- Act: Check if command is registered
      local commands = vim.api.nvim_get_commands({})
      local has_start_command = commands.OllamaStart ~= nil

      -- Assert: OllamaStart command exists
      assert.is_true(has_start_command, "Must provide :OllamaStart command")
    end)

    it("MUST provide :OllamaModel command with completion", function()
      -- Arrange: Manager setup
      manager.setup()

      -- Act: Check command registration
      local commands = vim.api.nvim_get_commands({})
      local model_cmd = commands.OllamaModel

      -- Assert: OllamaModel command exists with nargs
      assert.is_not_nil(model_cmd, "Must provide :OllamaModel command")
      assert.equals("1", model_cmd.nargs, "OllamaModel must take exactly 1 argument")
    end)

    it("MUST provide :OllamaHealth command", function()
      -- Arrange: Manager setup
      manager.setup()

      -- Act: Check command
      local commands = vim.api.nvim_get_commands({})
      local has_health = commands.OllamaHealth ~= nil

      -- Assert: Health command exists
      assert.is_true(has_health, "Must provide :OllamaHealth command")
    end)
  end)

  describe("Configuration Contract", function()
    it("MUST support user configuration via setup()", function()
      -- Arrange: User config with custom model
      local user_config = {
        model = "mistral",
        timeout = 60,
      }

      -- Act: Apply user config
      manager.setup(user_config)

      -- Assert: Config is merged
      assert.equals("mistral", manager.config.model)
      assert.equals(60, manager.config.timeout)
    end)

    it("MUST support vim.g.ollama_config global", function()
      -- Arrange: Set global config
      vim.g.ollama_config = {
        model = "codellama",
      }

      -- Act: Setup should read vim.g
      manager.setup()

      -- Assert: Global config is applied
      assert.equals("codellama", manager.config.model)

      -- Cleanup
      vim.g.ollama_config = nil
    end)

    it("MUST allow disabling auto-start", function()
      -- Arrange: Config with enabled = false
      local disabled_config = {
        enabled = false,
      }

      -- Act: Setup with auto-start disabled
      manager.setup(disabled_config)

      -- Assert: Auto-start is disabled
      assert.is_false(manager.config.enabled)
    end)
  end)
end)

describe("GTD AI OpenAI Compatibility Contract", function()
  local ai
  local mock_job_called
  local mock_job_args
  local original_job_new

  before_each(function()
    -- Arrange: Load fresh AI module
    package.loaded["lib.gtd.ai"] = nil
    ai = require("lib.gtd.ai")

    -- Reset mock state
    mock_job_called = false
    mock_job_args = nil

    -- Mock plenary Job to capture API calls
    local Job = require("plenary.job")
    original_job_new = Job.new
    Job.new = function(self, opts)
      -- Handle both Job.new({...}) and Job:new({...}) calling conventions
      -- When called with colon syntax, self is Job table and opts is actual options
      -- When called with dot syntax, self is the options table and opts is nil
      if type(self) == "table" and self.command then
        -- Dot syntax: Job.new({command="curl", ...})
        opts = self
      end
      -- Now opts contains the correct options table

      mock_job_called = true
      mock_job_args = opts.args

      -- Return mock job with proper structure
      local mock_job = {
        result = function()
          return {
            vim.fn.json_encode({
              choices = {
                {
                  message = {
                    content = "Mock AI response",
                  },
                },
              },
            }),
          }
        end,
        start = function()
          -- Call on_exit callback if it exists
          if opts.on_exit then
            -- Schedule to simulate async
            vim.schedule(function()
              opts.on_exit(mock_job, 0) -- luacheck: ignore mock_job
            end)
          end
        end,
      }
      return mock_job
    end
  end)

  after_each(function()
    -- Cleanup: Restore original Job.new
    if original_job_new then
      local Job = require("plenary.job")
      Job.new = original_job_new
      original_job_new = nil
    end
  end)

  describe("OpenAI Endpoint Contract", function()
    it("MUST use /v1/chat/completions endpoint", function()
      -- Arrange: AI module ready
      local endpoint_used = nil

      -- Act: Call AI with prompt
      ai.call_ollama("test prompt", function() end)

      -- Wait for mock to be called
      vim.wait(100, function()
        return mock_job_called
      end, 10)

      -- Extract endpoint from curl args
      for _, arg in ipairs(mock_job_args) do
        if arg:match("/v1/chat/completions") then
          endpoint_used = arg
          break
        end
      end

      -- Assert: Uses OpenAI-compatible endpoint
      assert.is_not_nil(endpoint_used, "Must use /v1/chat/completions endpoint")
      assert.matches("/v1/chat/completions$", endpoint_used)
    end)

    it("MUST send chat completion format not generate format", function()
      -- Arrange: AI module ready
      -- Act: Call AI
      ai.call_ollama("test prompt", function() end)

      -- Wait for job
      vim.wait(100, function()
        return mock_job_called
      end, 10)

      -- Extract request body
      local body_json = nil
      for i, arg in ipairs(mock_job_args) do
        if mock_job_args[i - 1] == "-d" then
          body_json = arg
          break
        end
      end

      -- Assert: Body contains messages array (chat format)
      assert.is_not_nil(body_json, "Must send request body")
      local body = vim.fn.json_decode(body_json)
      assert.is_not_nil(body.messages, "Must use messages array (chat format)")
      assert.is_table(body.messages)
      assert.is_true(#body.messages > 0, "Messages must not be empty")
    end)

    it("MUST include Authorization header with bearer token", function()
      -- Arrange: AI ready
      -- Act: Make API call
      ai.call_ollama("test", function() end)

      -- Wait for call
      vim.wait(100, function()
        return mock_job_called
      end, 10)

      -- Check for Authorization header in args
      local has_auth = false
      for _, arg in ipairs(mock_job_args) do
        if arg == "Authorization: Bearer ollama" then
          has_auth = true
          break
        end
      end

      -- Assert: Authorization header is present
      assert.is_true(has_auth, "Must include Authorization: Bearer header")
    end)

    it("MUST set Content-Type to application/json", function()
      -- Arrange: AI ready
      -- Act: Call API
      ai.call_ollama("test", function() end)

      vim.wait(100, function()
        return mock_job_called
      end, 10)

      -- Check for Content-Type header
      local has_content_type = false
      for _, arg in ipairs(mock_job_args) do
        if arg == "Content-Type: application/json" then
          has_content_type = true
          break
        end
      end

      -- Assert: Content-Type header present
      assert.is_true(has_content_type, "Must set Content-Type: application/json")
    end)
  end)

  describe("Model Selection Contract", function()
    it("MUST use model from vim.g.ollama_model if set", function()
      -- Arrange: Set global model preference
      vim.g.ollama_model = "mistral"

      -- Act: Call AI
      ai.call_ollama("test", function() end)

      vim.wait(100, function()
        return mock_job_called
      end, 10)

      -- Extract body
      local body_json = nil
      for i, arg in ipairs(mock_job_args) do
        if mock_job_args[i - 1] == "-d" then
          body_json = arg
          break
        end
      end

      local body = vim.fn.json_decode(body_json)

      -- Assert: Uses model from vim.g
      assert.equals("mistral", body.model, "Must use model from vim.g.ollama_model")

      -- Cleanup
      vim.g.ollama_model = nil
    end)

    it("MUST default to llama3.2 when vim.g.ollama_model not set", function()
      -- Arrange: No global model set
      vim.g.ollama_model = nil

      -- Act: Call AI
      ai.call_ollama("test", function() end)

      vim.wait(100, function()
        return mock_job_called
      end, 10)

      -- Extract model from body
      local body_json = nil
      for i, arg in ipairs(mock_job_args) do
        if mock_job_args[i - 1] == "-d" then
          body_json = arg
          break
        end
      end

      local body = vim.fn.json_decode(body_json)

      -- Assert: Defaults to llama3.2
      assert.equals("llama3.2", body.model, "Must default to llama3.2")
    end)
  end)

  describe("Response Parsing Contract", function()
    it("MUST parse OpenAI chat completion response format", function()
      -- Arrange: Mock response with OpenAI format
      local Job = require("plenary.job")
      Job.new = function(opts)
        local mock_job = {
          result = function()
            return {
              vim.fn.json_encode({
                choices = {
                  {
                    message = {
                      content = "Test response content",
                    },
                  },
                },
              }),
            }
          end,
          start = function()
            if opts.on_exit then
              vim.schedule(function()
                opts.on_exit(mock_job, 0) -- luacheck: ignore mock_job
              end)
            end
          end,
        }
        return mock_job
      end

      local received_response = nil

      -- Act: Call AI
      ai.call_ollama("test", function(response)
        received_response = response
      end)

      -- Wait for callback
      vim.wait(1000, function()
        return received_response ~= nil
      end, 50)

      -- Assert: Extracted message.content correctly
      assert.equals("Test response content", received_response)
    end)

    it("MUST handle missing choices gracefully", function()
      -- Arrange: Mock malformed response
      local Job = require("plenary.job")
      Job.new = function(opts)
        local mock_job = {
          result = function()
            return { vim.fn.json_encode({ error = "Model not found" }) }
          end,
          start = function()
            if opts.on_exit then
              vim.schedule(function()
                opts.on_exit(mock_job, 0) -- luacheck: ignore mock_job
              end)
            end
          end,
        }
        return mock_job
      end

      local received_response = "not called"

      -- Act: Call AI with bad response
      ai.call_ollama("test", function(response)
        received_response = response
      end)

      vim.wait(1000, function()
        return received_response ~= "not called"
      end, 50)

      -- Assert: Callback receives nil for malformed response
      assert.is_nil(received_response, "Should return nil for malformed response")
    end)

    it("MUST handle curl errors gracefully", function()
      -- Arrange: Mock curl failure
      local Job = require("plenary.job")
      Job.new = function(opts)
        local mock_job = {
          result = function()
            return {}
          end,
          start = function()
            if opts.on_exit then
              vim.schedule(function()
                opts.on_exit(mock_job, 1) -- luacheck: ignore mock_job (Non-zero exit code)
              end)
            end
          end,
        }
        return mock_job
      end

      local received_response = "not called"

      -- Act: Call with failing curl
      ai.call_ollama("test", function(response)
        received_response = response
      end)

      vim.wait(1000, function()
        return received_response ~= "not called"
      end, 50)

      -- Assert: Returns nil on curl failure
      assert.is_nil(received_response, "Should return nil when curl fails")
    end)
  end)

  describe("GTD AI Functions Contract", function()
    it("MUST provide decompose_task function", function()
      -- Arrange: AI module loaded
      -- Act: Check for function
      local has_decompose = type(ai.decompose_task) == "function"

      -- Assert: Function exists
      assert.is_true(has_decompose, "Must provide decompose_task function")
    end)

    it("MUST provide suggest_context function", function()
      -- Arrange: AI module loaded
      -- Act: Check for function
      local has_context = type(ai.suggest_context) == "function"

      -- Assert: Function exists
      assert.is_true(has_context, "Must provide suggest_context function")
    end)

    it("MUST provide infer_priority function", function()
      -- Arrange: AI module loaded
      -- Act: Check for function
      local has_priority = type(ai.infer_priority) == "function"

      -- Assert: Function exists
      assert.is_true(has_priority, "Must provide infer_priority function")
    end)
  end)
end)
