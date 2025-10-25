-- PercyBrain AI Model Selector
-- Purpose: Interactive AI model selection and management for Ollama integration
-- Why: Allow users to choose optimal models for different tasks (fast vs accurate, code vs prose)

local M = {}

-- Configuration
M.config = {
  current_model = "llama3.2:latest", -- Default model
  default_fallback = "llama3.2:latest",
}

-- Model metadata for user guidance
M.model_metadata = {
  ["llama3.2:latest"] = {
    description = "General-purpose model (2GB) - Fast, good for explanations and summaries",
    speed = "fast",
    size = "2GB",
    tasks = { "explanation", "summarization", "general" },
  },
  ["nous-hermes2:latest"] = {
    description = "Advanced reasoning model (6GB) - Slower but more accurate",
    speed = "medium",
    size = "6GB",
    tasks = { "complex_reasoning", "creative_writing" },
  },
  ["dolphin3:latest"] = {
    description = "Balanced model (5GB) - Good all-rounder",
    speed = "medium",
    size = "5GB",
    tasks = { "general", "creative_writing", "explanation" },
  },
  ["qwen2.5-coder:1.5b"] = {
    description = "Code-specialized model (1GB) - Fast code generation",
    speed = "very_fast",
    size = "1GB",
    tasks = { "code_generation", "code_explanation" },
  },
  ["gemma3:1b"] = {
    description = "Tiny model (815MB) - Very fast, basic tasks only",
    speed = "very_fast",
    size = "815MB",
    tasks = { "simple_tasks", "quick_responses" },
  },
}

-- Task-to-model recommendations
M.task_recommendations = {
  code_generation = "qwen2.5-coder:1.5b",
  code_explanation = "qwen2.5-coder:1.5b",
  summarization = "llama3.2:latest",
  explanation = "llama3.2:latest",
  creative_writing = "nous-hermes2:latest",
  complex_reasoning = "nous-hermes2:latest",
  quick_response = "gemma3:1b",
  general = "llama3.2:latest",
}

-- Parse ollama list output to extract model names
-- Returns: table of model names
M.parse_ollama_list = function(output)
  local models = {}

  -- Skip header line, extract model names from each line
  for line in output:gmatch("[^\r\n]+") do
    -- Match model name (first column, ends with :latest or similar tag)
    local model_name = line:match("^([%w%-%.]+:%w+)")
    if model_name then
      table.insert(models, model_name)
    end
  end

  return models
end

-- List available Ollama models from system
-- Returns: table of model names
M.list_available_models = function()
  -- Run ollama list command
  local handle = io.popen("ollama list 2>&1")
  if not handle then
    return {}
  end

  local output = handle:read("*all")
  handle:close()

  return M.parse_ollama_list(output)
end

-- Check if Ollama is installed
-- Returns: boolean, error_message
M.check_ollama_installed = function()
  local handle = io.popen("which ollama 2>/dev/null")
  if not handle then
    return false, "Could not execute 'which ollama' command"
  end

  local result = handle:read("*all")
  handle:close()

  if result == "" or result == nil then
    return false, "Ollama is not installed. Install from https://ollama.ai"
  end

  return true, nil
end

-- Get current selected model
-- Returns: string (model name)
M.get_current_model = function()
  return M.config.current_model
end

-- Get current model with fallback if invalid
-- Returns: string (valid model name)
M.get_current_model_with_fallback = function()
  local current = M.config.current_model
  local available = M.list_available_models()

  -- Check if current model is available
  for _, model in ipairs(available) do
    if model == current then
      return current
    end
  end

  -- Fallback to default if current not available
  for _, model in ipairs(available) do
    if model == M.config.default_fallback then
      return M.config.default_fallback
    end
  end

  -- Fallback to first available model
  if #available > 0 then
    return available[1]
  end

  -- No models available
  return M.config.default_fallback
end

-- Set current model (with validation)
-- Returns: success (boolean), error_message (string or nil)
M.set_current_model = function(model_name)
  -- Validate model exists
  local available = M.list_available_models()
  local found = false

  for _, model in ipairs(available) do
    if model == model_name then
      found = true
      break
    end
  end

  if not found then
    return false, string.format("Model '%s' is not available. Run 'ollama pull %s' to install.", model_name, model_name)
  end

  -- Set current model
  M.config.current_model = model_name
  return true, nil
end

-- Get models with metadata
-- Returns: table of {name, description, size, speed, tasks}
M.get_models_with_metadata = function()
  local available = M.list_available_models()
  local models_info = {}

  for _, model_name in ipairs(available) do
    local metadata = M.model_metadata[model_name]
      or {
        description = "No description available",
        speed = "unknown",
        size = "unknown",
        tasks = {},
      }

    table.insert(models_info, {
      name = model_name,
      description = metadata.description,
      size = metadata.size,
      speed = metadata.speed,
      tasks = metadata.tasks,
    })
  end

  return models_info
end

-- Suggest optimal model for specific task
-- Returns: string (model name) or nil
M.suggest_model_for_task = function(task_type)
  local suggested = M.task_recommendations[task_type]

  if not suggested then
    return nil
  end

  -- Verify suggested model is available
  local available = M.list_available_models()
  for _, model in ipairs(available) do
    if model == suggested then
      return suggested
    end
  end

  -- Fallback to current model if suggestion not available
  return nil
end

-- Apply current model to Ollama config
M.apply_to_ollama_config = function()
  local ollama = _G.M -- Global Ollama module from ollama.lua

  if not ollama or not ollama.config then
    vim.notify("⚠️  Ollama module not loaded", vim.log.levels.WARN)
    return
  end

  -- Update only the model field, preserve other config
  ollama.config.model = M.config.current_model

  vim.notify(string.format("✅ AI model changed to: %s", M.config.current_model), vim.log.levels.INFO)
end

-- Get picker display info
-- Returns: {current_model, available_models}
M.get_picker_display_info = function()
  return {
    current_model = M.config.current_model,
    available_models = M.list_available_models(),
  }
end

-- Show interactive model picker UI (vim.ui.select)
M.show_model_picker = function()
  local models_info = M.get_models_with_metadata()

  if #models_info == 0 then
    vim.notify(M.get_no_models_error_message(), vim.log.levels.ERROR)
    return
  end

  -- Format options with current model indicator
  local options = {}
  for _, model in ipairs(models_info) do
    local current_marker = (model.name == M.config.current_model) and "✓ " or "  "
    local display = string.format("%s%s - %s", current_marker, model.name, model.description)
    table.insert(options, {
      display = display,
      value = model.name,
    })
  end

  vim.ui.select(options, {
    prompt = "Select AI Model:",
    format_item = function(item)
      return item.display
    end,
  }, function(choice)
    if not choice then
      return
    end

    local success, error_msg = M.set_current_model(choice.value)
    if success then
      M.apply_to_ollama_config()
    else
      vim.notify("❌ " .. error_msg, vim.log.levels.ERROR)
    end
  end)
end

-- Get error message for no models scenario
M.get_no_models_error_message = function()
  return [[No Ollama models installed!

To install models, run one of:
  ollama pull llama3.2        # Fast general-purpose (2GB)
  ollama pull nous-hermes2    # Advanced reasoning (6GB)
  ollama pull qwen2.5-coder:1.5b  # Code generation (1GB)

Then restart Neovim and try again.]]
end

-- Reset to default model
M.reset_to_default = function()
  M.config.current_model = M.config.default_fallback
end

-- Get internal config (for testing)
M.get_config = function()
  return M.config
end

-- Setup keybindings
M.setup = function()
  vim.keymap.set("n", "<leader>am", M.show_model_picker, {
    desc = "AI: Select Model",
    noremap = true,
    silent = true,
  })

  vim.notify("🤖 AI Model Selector loaded - <leader>am to change model", vim.log.levels.INFO)
end

return M
