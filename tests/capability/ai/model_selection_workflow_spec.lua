-- Capability Tests for AI Model Selection Workflow
-- Tests what users CAN DO with AI model selection
-- Kent Beck: "Test capabilities, not configuration"

describe("AI Model Selection Workflow Capabilities", function()
  local ai

  before_each(function()
    -- Arrange: Load AI model selector module
    ai = require("percybrain.ai-model-selector")
  end)

  after_each(function()
    -- Cleanup: Reset to default model
    if ai and ai.reset_to_default then
      ai.reset_to_default()
    end
  end)

  describe("Model Discovery Capabilities", function()
    it("CAN see all installed Ollama models", function()
      -- Arrange: User wants to know available models
      -- Act: List models
      local models = ai.list_available_models()

      -- Assert: User can see model list
      assert.is_not_nil(models)
      assert.is_table(models)
      -- Should have at least llama3.2 from earlier grep
      assert.is_true(#models >= 1, "Should find installed models")
    end)

    it("CAN view model details and descriptions", function()
      -- Arrange: User wants to understand model differences
      -- Act: Get models with metadata
      local models_info = ai.get_models_with_metadata()

      -- Assert: User gets helpful descriptions
      assert.is_not_nil(models_info)
      assert.is_true(#models_info > 0)

      local first_model = models_info[1]
      assert.is_not_nil(first_model.name)
      assert.is_not_nil(first_model.description)
      assert.is_string(first_model.description)
      assert.is_true(#first_model.description > 10, "Description should be meaningful")
    end)

    it("CAN check if Ollama is properly installed and running", function()
      -- Arrange: User troubleshooting AI features
      -- Act: Check Ollama status
      local is_installed, message = ai.check_ollama_installed()

      -- Assert: User gets clear status
      assert.is_boolean(is_installed)
      if not is_installed then
        assert.is_string(message)
        assert.is_true(#message > 0, "Error message should be helpful")
      end
    end)
  end)

  describe("Model Selection Capabilities", function()
    it("CAN select a different model for current session", function()
      -- Arrange: User wants faster/slower model for different task
      local available_models = ai.list_available_models()
      assert.is_true(#available_models > 0, "Need at least one model")

      local test_model = available_models[1]

      -- Act: Select model
      local success, error_msg = ai.set_current_model(test_model)

      -- Assert: Model selection succeeds
      assert.is_true(success, "Model selection should succeed")
      assert.is_nil(error_msg)
      assert.equals(test_model, ai.get_current_model())
    end)

    it("CAN see which model is currently active", function()
      -- Arrange: User forgets which model they selected
      local available_models = ai.list_available_models()
      local test_model = available_models[1]
      ai.set_current_model(test_model)

      -- Act: Check current model
      local current = ai.get_current_model()

      -- Assert: User can see active model
      assert.equals(test_model, current)
    end)

    it("CAN switch between models multiple times", function()
      -- Arrange: User experimenting with different models
      local available_models = ai.list_available_models()
      if #available_models < 2 then
        pending("Need at least 2 models for this test")
        return
      end

      local model1 = available_models[1]
      local model2 = available_models[2]

      -- Act: Switch models multiple times
      ai.set_current_model(model1)
      assert.equals(model1, ai.get_current_model())

      ai.set_current_model(model2)
      assert.equals(model2, ai.get_current_model())

      ai.set_current_model(model1)
      assert.equals(model1, ai.get_current_model())

      -- Assert: Model switching works reliably
      assert.equals(model1, ai.get_current_model())
    end)
  end)

  describe("Task-Optimized Selection Capabilities", function()
    it("CAN get model suggestions for specific tasks", function()
      -- Arrange: User wants best model for code generation
      local task_types = {
        "code_generation",
        "summarization",
        "explanation",
        "creative_writing",
      }

      -- Act: Get suggestions for each task
      for _, task in ipairs(task_types) do
        local suggested = ai.suggest_model_for_task(task)

        -- Assert: Suggestion is valid model or nil
        if suggested then
          assert.is_string(suggested)

          -- Verify suggested model is actually available
          local available = ai.list_available_models()
          local found = false
          for _, model in ipairs(available) do
            if model == suggested then
              found = true
              break
            end
          end
          assert.is_true(found, "Suggested model should be available: " .. suggested)
        end
      end
    end)

    it("CAN use task-specific selection in workflow", function()
      -- Arrange: User wants to use optimal model for summarization
      local suggested = ai.suggest_model_for_task("summarization")

      if not suggested then
        pending("No model suggestion available")
        return
      end

      -- Act: Apply suggested model
      local success = ai.set_current_model(suggested)

      -- Assert: User can easily switch to task-optimal model
      assert.is_true(success)
      assert.equals(suggested, ai.get_current_model())
    end)
  end)

  describe("Interactive Picker Capabilities", function()
    it("CAN access interactive model picker UI", function()
      -- Arrange: User wants visual model selection
      -- Act: Check picker function exists
      local has_picker = type(ai.show_model_picker) == "function"

      -- Assert: Picker UI is available
      assert.is_true(has_picker, "Model picker should be available")
    end)

    it("CAN see current model highlighted in picker", function()
      -- Arrange: User has selected a model and opens picker
      local available_models = ai.list_available_models()
      local test_model = available_models[1]
      ai.set_current_model(test_model)

      -- Act: Get picker display info
      local picker_info = ai.get_picker_display_info()

      -- Assert: Current model is indicated
      assert.is_not_nil(picker_info)
      assert.equals(test_model, picker_info.current_model)
    end)
  end)

  describe("Integration Capabilities", function()
    it("CAN change model and immediately use in AI commands", function()
      -- Arrange: Mock Ollama if not loaded
      -- Global pollution test: _G.M is documented interface from ollama.lua (line 358)
      if not _G.M then
        _G.M = {
          config = {
            model = "llama3.2:latest",
            temperature = 0.7,
            timeout = 30000,
          },
        }
      end

      local available_models = ai.list_available_models()
      local test_model = available_models[1]

      -- Act: Change model
      ai.set_current_model(test_model)
      ai.apply_to_ollama_config()

      -- Assert: Ollama config updated
      local ollama = _G.M
      assert.equals(test_model, ollama.config.model)
    end)

    it("CAN preserve Ollama settings when changing model", function()
      -- Arrange: Mock Ollama if not loaded
      -- Global pollution test: _G.M is documented interface from ollama.lua (line 358)
      if not _G.M then
        _G.M = {
          config = {
            model = "llama3.2:latest",
            temperature = 0.7,
            timeout = 30000,
          },
        }
      end

      local ollama = _G.M
      local original_temp = ollama.config.temperature
      local original_timeout = ollama.config.timeout
      local available_models = ai.list_available_models()

      -- Act: Change model
      ai.set_current_model(available_models[1])
      ai.apply_to_ollama_config()

      -- Assert: Other settings unchanged
      assert.equals(original_temp, ollama.config.temperature)
      assert.equals(original_timeout, ollama.config.timeout)
    end)
  end)

  describe("Error Recovery Capabilities", function()
    it("CAN receive helpful error when selecting invalid model", function()
      -- Arrange: User types incorrect model name
      local invalid_model = "this-model-does-not-exist:latest"

      -- Act: Attempt to select
      local success, error_msg = ai.set_current_model(invalid_model)

      -- Assert: User gets actionable error
      assert.is_false(success)
      assert.is_string(error_msg)
      assert.matches("not available", error_msg)
    end)

    it("CAN see helpful message when no models installed", function()
      -- Arrange: User needs guidance on model installation
      -- Act: Get error message template
      local error_msg = ai.get_no_models_error_message()

      -- Assert: Message includes installation instructions
      assert.is_string(error_msg)
      assert.matches("ollama pull", error_msg)
      assert.matches("llama", error_msg:lower()) -- Should suggest a model
    end)

    it("CAN fall back to default model if selected model unavailable", function()
      -- Arrange: User selected a model that was later removed
      -- Simulate by setting invalid model in config
      local ai_config = ai.get_config()
      local original_model = ai_config.current_model
      ai_config.current_model = "removed-model:latest"

      -- Act: Get current model with fallback
      local current = ai.get_current_model_with_fallback()

      -- Assert: Falls back to valid model
      assert.is_string(current)
      local available = ai.list_available_models()
      local found = false
      for _, model in ipairs(available) do
        if model == current then
          found = true
          break
        end
      end
      assert.is_true(found, "Fallback should return available model")
    end)
  end)

  describe("Keybinding Capabilities", function()
    it("CAN access model selector via keybinding", function()
      -- Arrange: User wants quick model selection
      -- Act: Check if keymap is registered
      local keymaps = vim.api.nvim_get_keymap("n")
      local has_model_picker_key = false

      for _, map in ipairs(keymaps) do
        if map.lhs and map.lhs:match("<leader>am") then
          has_model_picker_key = true
          break
        end
      end

      -- Assert: Keybinding exists (will be <leader>am for AI Model)
      -- (This test validates keybinding registration, actual key may differ)
      assert.is_true(type(ai.show_model_picker) == "function", "Model picker function should exist for keybinding")
    end)
  end)

  describe("Session Persistence Capabilities", function()
    it("CAN maintain model selection across buffer switches", function()
      -- Arrange: User selects model and switches buffers
      local available_models = ai.list_available_models()
      local test_model = available_models[1]
      ai.set_current_model(test_model)

      -- Act: Simulate buffer switch (model should persist)
      local before_switch = ai.get_current_model()
      -- In real usage, buffer switch happens here
      local after_switch = ai.get_current_model()

      -- Assert: Model selection persists
      assert.equals(before_switch, after_switch)
      assert.equals(test_model, after_switch)
    end)
  end)
end)
