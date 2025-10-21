-- Contract Tests for AI Model Selection
-- Tests what the system MUST, MUST NOT, and MAY do for AI model selection
-- Kent Beck: "Specify the contract before implementation"

describe("AI Model Selection Contract", function()
  before_each(function()
    -- Arrange: Ensure clean test state
  end)

  after_each(function()
    -- Cleanup: No state to restore
  end)

  describe("Model Discovery Contract", function()
    it("MUST detect available Ollama models from system", function()
      -- Arrange: System has ollama installed with models
      local ai = require("percybrain.ai-model-selector")

      -- Act: List available models
      local models = ai.list_available_models()

      -- Assert: Models list is returned
      assert.is_not_nil(models)
      assert.equals("table", type(models))
      assert.is_true(#models > 0, "Should find at least one model")
    end)

    it("MUST parse model names correctly from ollama list output", function()
      -- Arrange: Sample ollama list output
      local sample_output = [[
NAME                   ID              SIZE      MODIFIED
nous-hermes2:latest    d50977d0b36a    6.1 GB    2 days ago
llama3.2:latest        a80c4f17acd5    2.0 GB    3 days ago
]]
      local ai = require("percybrain.ai-model-selector")

      -- Act: Parse models from output
      local models = ai.parse_ollama_list(sample_output)

      -- Assert: Correctly parsed model names
      assert.is_not_nil(models)
      assert.equals(2, #models)
      assert.equals("nous-hermes2:latest", models[1])
      assert.equals("llama3.2:latest", models[2])
    end)

    it("MUST handle empty model list gracefully", function()
      -- Arrange: No models installed
      local empty_output = [[
NAME                   ID              SIZE      MODIFIED
]]
      local ai = require("percybrain.ai-model-selector")

      -- Act: Parse empty output
      local models = ai.parse_ollama_list(empty_output)

      -- Assert: Returns empty table, not nil
      assert.is_not_nil(models)
      assert.equals("table", type(models))
      assert.equals(0, #models)
    end)
  end)

  describe("Model Selection Contract", function()
    it("MUST store selected model for session", function()
      -- Arrange: User selects a model
      local ai = require("percybrain.ai-model-selector")
      local selected_model = "llama3.2:latest"

      -- Act: Set current model
      ai.set_current_model(selected_model)
      local current = ai.get_current_model()

      -- Assert: Model is stored and retrieved
      assert.equals(selected_model, current)
    end)

    it("MUST validate selected model exists in available models", function()
      -- Arrange: User attempts to select invalid model
      local ai = require("percybrain.ai-model-selector")
      local invalid_model = "nonexistent-model:latest"

      -- Act: Attempt to set invalid model
      local success, error_msg = ai.set_current_model(invalid_model)

      -- Assert: Validation fails with helpful error
      assert.is_false(success)
      assert.is_not_nil(error_msg)
      assert.matches("not available", error_msg)
    end)

    it("MUST have default model fallback", function()
      -- Arrange: New session with no model selected
      local ai = require("percybrain.ai-model-selector")

      -- Act: Get current model without setting one
      local current = ai.get_current_model()

      -- Assert: Default model is returned
      assert.is_not_nil(current)
      assert.is_string(current)
      -- Should be llama3.2:latest or first available model
    end)
  end)

  describe("Model Metadata Contract", function()
    it("MUST provide model descriptions for user guidance", function()
      -- Arrange: System has model metadata
      local ai = require("percybrain.ai-model-selector")

      -- Act: Get model with metadata
      local models_with_info = ai.get_models_with_metadata()

      -- Assert: Each model has description
      assert.is_not_nil(models_with_info)
      assert.is_true(#models_with_info > 0)
      for _, model in ipairs(models_with_info) do
        assert.is_not_nil(model.name)
        assert.is_not_nil(model.description)
        assert.is_string(model.description)
      end
    end)

    it("MAY provide model size and performance hints", function()
      -- Arrange: Model metadata includes optional info
      local ai = require("percybrain.ai-model-selector")
      local models_with_info = ai.get_models_with_metadata()

      -- Act: Check for optional metadata
      -- Assert: Size/performance info is optional but if present, should be string
      for _, model in ipairs(models_with_info) do
        if model.size then
          assert.is_string(model.size)
        end
        if model.speed then
          assert.is_string(model.speed)
        end
      end
    end)
  end)

  describe("Integration Contract", function()
    it("MUST integrate with existing Ollama plugin", function()
      -- Arrange: Mock Ollama plugin if not loaded (test environment)
      -- Global pollution test: _G.M is documented interface from ollama.lua (line 358)
      if not _G.M then
        _G.M = {
          config = {
            model = "llama3.2:latest",
            temperature = 0.7,
            timeout = 30000,
          }
        }
      end

      local ai = require("percybrain.ai-model-selector")
      local ollama = _G.M

      -- Act: Update Ollama config with selected model
      ai.set_current_model("llama3.2:latest")
      ai.apply_to_ollama_config()

      -- Assert: Ollama config is updated
      assert.equals("llama3.2:latest", ollama.config.model)
    end)

    it("MUST preserve other Ollama config options when changing model", function()
      -- Arrange: Mock Ollama if needed
      -- Global pollution test: _G.M is documented interface from ollama.lua (line 358)
      if not _G.M then
        _G.M = {
          config = {
            model = "llama3.2:latest",
            temperature = 0.7,
            timeout = 30000,
          }
        }
      end

      local ollama = _G.M
      local original_temp = ollama.config.temperature
      local original_timeout = ollama.config.timeout

      local ai = require("percybrain.ai-model-selector")

      -- Act: Change model
      local available = ai.list_available_models()
      if #available > 0 then
        ai.set_current_model(available[1])
        ai.apply_to_ollama_config()

        -- Assert: Other config preserved
        assert.equals(original_temp, ollama.config.temperature)
        assert.equals(original_timeout, ollama.config.timeout)
      else
        pending("No models available for this test")
      end
    end)
  end)

  describe("Task-Specific Model Selection Contract", function()
    it("MAY suggest optimal models for different tasks", function()
      -- Arrange: System knows task categories
      local ai = require("percybrain.ai-model-selector")

      -- Act: Get suggested model for task
      local suggested = ai.suggest_model_for_task("code_generation")

      -- Assert: Returns valid model name
      if suggested then
        assert.is_string(suggested)
        -- Should be one of available models
        local available = ai.list_available_models()
        local found = false
        for _, model in ipairs(available) do
          if model == suggested then
            found = true
            break
          end
        end
        assert.is_true(found, "Suggested model should be available")
      end
    end)

    it("MUST handle missing task category gracefully", function()
      -- Arrange: User requests unknown task category
      local ai = require("percybrain.ai-model-selector")

      -- Act: Request model for unknown task
      local suggested = ai.suggest_model_for_task("unknown_task_type")

      -- Assert: Returns default or nil (not error)
      -- Should not crash
      assert.is_true(suggested == nil or type(suggested) == "string")
    end)
  end)

  describe("Model Picker UI Contract", function()
    it("MUST provide interactive model selection UI", function()
      -- Arrange: User wants to change model
      local ai = require("percybrain.ai-model-selector")

      -- Act: Check if show_model_picker function exists
      local has_picker = type(ai.show_model_picker) == "function"

      -- Assert: Model picker UI is available
      assert.is_true(has_picker)
    end)

    it("MUST display current model in picker UI", function()
      -- Arrange: User has selected a model
      local ai = require("percybrain.ai-model-selector")
      ai.set_current_model("llama3.2:latest")

      -- Act: Get picker display info
      local picker_info = ai.get_picker_display_info()

      -- Assert: Current model is indicated
      assert.is_not_nil(picker_info)
      assert.is_not_nil(picker_info.current_model)
      assert.equals("llama3.2:latest", picker_info.current_model)
    end)
  end)

  describe("Error Handling Contract", function()
    it("MUST detect when Ollama is not installed", function()
      -- Arrange: Simulate missing ollama command
      local ai = require("percybrain.ai-model-selector")

      -- Act: Check Ollama availability
      local is_available, error_msg = ai.check_ollama_installed()

      -- Assert: Returns status (may be true if installed, false if not)
      assert.is_not_nil(is_available)
      assert.is_boolean(is_available)
      if not is_available then
        assert.is_string(error_msg)
        assert.matches("ollama", error_msg:lower())
      end
    end)

    it("MUST provide helpful error when no models available", function()
      -- Arrange: User has Ollama but no models pulled
      local ai = require("percybrain.ai-model-selector")

      -- Act: Attempt to list models when none exist
      -- (This test validates error messaging, not actual state)
      local error_message = ai.get_no_models_error_message()

      -- Assert: Error message is helpful
      assert.is_string(error_message)
      assert.matches("ollama pull", error_message)
    end)
  end)
end)
