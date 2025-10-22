--- Ollama Manager - Auto-start and configuration for local AI
--- @module percybrain.ollama-manager
---
--- Provides automatic Ollama server management for Neovim:
--- - Auto-start Ollama server on Neovim launch
--- - Model configuration with user preferences
--- - Health checks and status monitoring
--- - OpenAI-compatible API endpoint management
---
--- Configuration via vim.g.ollama_config:
--- {
---   enabled = true,              -- Enable/disable auto-start
---   model = "llama3.2",          -- Default model
---   auto_pull = false,           -- Auto-download model if missing
---   openai_port = 11434,         -- OpenAI-compatible API port
---   timeout = 30,                -- Startup timeout in seconds
--- }

local M = {}

--- Default configuration
M.config = {
  enabled = true,
  model = "llama3.2",
  auto_pull = false,
  openai_port = 11434,
  timeout = 30,
  base_url = "http://localhost:11434",
  openai_url = "http://localhost:11434/v1",
}

--- Ollama server status
M.status = {
  running = false,
  model_loaded = false,
  startup_time = nil,
}

--- Check if Ollama is installed
--- @return boolean installed True if ollama binary exists
local function is_installed()
  return vim.fn.executable("ollama") == 1
end

--- Check if Ollama server is running
--- @return boolean running True if server responds
local function is_running()
  local handle = io.popen(string.format("curl -s --max-time 2 %s/api/tags 2>/dev/null", M.config.base_url))

  if not handle then
    return false
  end

  local result = handle:read("*a")
  handle:close()

  return result and result:match('"models"') ~= nil
end

--- Check if specific model is available
--- @param model string Model name to check
--- @return boolean available True if model exists
local function is_model_available(model)
  local handle = io.popen(string.format("ollama list | grep -q '%s'", model))

  if not handle then
    return false
  end

  local exit_code = handle:close()
  return exit_code
end

--- Pull model if not available
--- @param model string Model name to pull
--- @param callback function|nil Optional callback(success, error)
local function pull_model(model, callback)
  callback = callback or function() end

  vim.notify(string.format("Pulling Ollama model: %s (this may take a while)", model), vim.log.levels.INFO)

  vim.fn.jobstart(string.format("ollama pull %s", model), {
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        vim.notify(string.format("Successfully pulled model: %s", model), vim.log.levels.INFO)
        callback(true, nil)
      else
        local err = string.format("Failed to pull model: %s", model)
        vim.notify(err, vim.log.levels.ERROR)
        callback(false, err)
      end
    end,
    stdout_buffered = true,
    stderr_buffered = true,
  })
end

--- Start Ollama server in background
--- @param callback function|nil Optional callback(success, error)
function M.start_server(callback)
  callback = callback or function() end

  if not is_installed() then
    local err = "Ollama not installed. Install from: https://ollama.ai"
    vim.notify(err, vim.log.levels.ERROR)
    callback(false, err)
    return
  end

  if is_running() then
    vim.notify("Ollama server already running", vim.log.levels.INFO)
    M.status.running = true
    callback(true, nil)
    return
  end

  vim.notify("Starting Ollama server...", vim.log.levels.INFO)

  -- Start Ollama in background
  vim.fn.jobstart("ollama serve", {
    detach = true,
    on_exit = function(_, exit_code)
      if exit_code ~= 0 then
        vim.notify("Ollama server exited unexpectedly", vim.log.levels.WARN)
      end
    end,
  })

  -- Wait for server to be ready
  local start_time = os.time()
  local check_ready
  check_ready = function()
    if is_running() then
      M.status.running = true
      M.status.startup_time = os.time() - start_time
      vim.notify(string.format("Ollama server ready (took %ds)", M.status.startup_time), vim.log.levels.INFO)
      callback(true, nil)
    elseif os.time() - start_time > M.config.timeout then
      local err = string.format("Ollama server failed to start within %ds", M.config.timeout)
      vim.notify(err, vim.log.levels.ERROR)
      callback(false, err)
    else
      vim.defer_fn(check_ready, 1000)
    end
  end

  vim.defer_fn(check_ready, 1000)
end

--- Load and prepare model
--- @param model string|nil Model name (uses config.model if nil)
--- @param callback function|nil Optional callback(success, error)
function M.load_model(model, callback)
  model = model or M.config.model
  callback = callback or function() end

  if not M.status.running then
    callback(false, "Ollama server not running")
    return
  end

  -- Check if model is available
  if not is_model_available(model) then
    if M.config.auto_pull then
      pull_model(model, function(success, err)
        if success then
          M.status.model_loaded = true
          callback(true, nil)
        else
          callback(false, err)
        end
      end)
    else
      local err = string.format("Model '%s' not found. Run: ollama pull %s", model, model)
      vim.notify(err, vim.log.levels.WARN)
      callback(false, err)
    end
    return
  end

  M.status.model_loaded = true
  callback(true, nil)
end

--- Get OpenAI-compatible API configuration
--- @return table config Configuration for OpenAI clients
function M.get_openai_config()
  return {
    base_url = M.config.openai_url,
    api_key = "ollama", -- Required by clients but ignored by Ollama -- pragma: allowlist secret
    model = M.config.model,
  }
end

--- Health check for Ollama integration
--- @return table health Health status information
function M.health_check()
  local health = {
    installed = is_installed(),
    running = is_running(),
    model_available = is_model_available(M.config.model),
    openai_compatible = false,
  }

  if health.running then
    -- Test OpenAI-compatible endpoint
    local handle = io.popen(string.format("curl -s --max-time 2 %s/models 2>/dev/null", M.config.openai_url))

    if handle then
      local result = handle:read("*a")
      handle:close()
      health.openai_compatible = result and result:match('"models"') ~= nil
    end
  end

  return health
end

--- Display health status
function M.show_health()
  local health = M.health_check()

  local lines = {
    "# Ollama Integration Health",
    "",
    string.format("✓ Ollama installed: %s", health.installed and "Yes" or "No"),
    string.format("✓ Server running: %s", health.running and "Yes" or "No"),
    string.format("✓ Model available: %s (%s)", health.model_available and "Yes" or "No", M.config.model),
    string.format("✓ OpenAI compatible: %s", health.openai_compatible and "Yes" or "No"),
    "",
    "## Configuration",
    string.format("- Enabled: %s", M.config.enabled),
    string.format("- Model: %s", M.config.model),
    string.format("- Base URL: %s", M.config.base_url), -- pragma: allowlist secret
    string.format("- OpenAI URL: %s", M.config.openai_url),
    "",
    "## Commands",
    ":OllamaStart - Start Ollama server",
    ":OllamaStop - Stop Ollama server (manual)",
    ":OllamaModel <name> - Change model",
    ":OllamaHealth - Show this health check",
  }

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
  vim.api.nvim_buf_set_option(buf, "modifiable", false)

  vim.cmd("split")
  vim.api.nvim_win_set_buf(0, buf)
end

--- Change active model
--- @param model string Model name
function M.set_model(model)
  M.config.model = model
  vim.g.ollama_model = model

  M.load_model(model, function(success, err)
    if success then
      vim.notify(string.format("Switched to model: %s", model), vim.log.levels.INFO)
    else
      vim.notify(string.format("Error loading model: %s", err or "unknown"), vim.log.levels.ERROR)
    end
  end)
end

--- Setup Ollama manager with user configuration
--- @param opts table|nil User configuration overrides
function M.setup(opts)
  -- Merge user config
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  -- Apply vim.g config if exists
  if vim.g.ollama_config then
    M.config = vim.tbl_deep_extend("force", M.config, vim.g.ollama_config)
  end

  -- Don't auto-start if disabled
  if not M.config.enabled then
    vim.notify("Ollama auto-start disabled", vim.log.levels.INFO)
    return
  end

  -- Auto-start on VimEnter
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      M.start_server(function(success)
        if success then
          M.load_model(M.config.model)
        end
      end)
    end,
    desc = "Auto-start Ollama server",
  })

  -- Commands
  vim.api.nvim_create_user_command("OllamaStart", function()
    M.start_server()
  end, { desc = "Start Ollama server" })

  vim.api.nvim_create_user_command("OllamaModel", function(args)
    M.set_model(args.args)
  end, {
    nargs = 1,
    complete = function()
      -- List available models
      local handle = io.popen("ollama list | tail -n +2 | awk '{print $1}'")
      if not handle then
        return {}
      end

      local models = {}
      for line in handle:lines() do
        table.insert(models, line)
      end
      handle:close()

      return models
    end,
    desc = "Change Ollama model",
  })

  vim.api.nvim_create_user_command("OllamaHealth", function()
    M.show_health()
  end, { desc = "Show Ollama health status" })
end

return M
