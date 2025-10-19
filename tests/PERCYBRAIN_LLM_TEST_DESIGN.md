# PercyBrain Local LLM Unit Testing Framework Design

## Overview

Comprehensive unit testing design for the PercyBrain Local LLM integration (`lua/plugins/ai-sembr/`) using the Plenary testing framework. Tests ensure Ollama integration works correctly for AI-assisted knowledge management.

## Architecture

### Test Structure

```
tests/plenary/unit/ai-sembr/
├── ollama_spec.lua         # Core Ollama integration tests
├── ai_draft_spec.lua        # AI Draft Generator tests
├── chat_interface_spec.lua  # Interactive chat functionality
└── model_selection_spec.lua # Model selection and switching
```

## Component 1: Core Ollama Integration Tests

### File: `tests/plenary/unit/ai-sembr/ollama_spec.lua`

```lua
-- Unit Tests: Ollama Integration
describe("Ollama Integration", function()
  local ollama

  before_each(function()
    -- Load ollama module
    package.loaded['plugins.ai-sembr.ollama'] = nil
    -- Mock the configuration
    ollama = {
      config = {
        model = "llama3.2:latest",
        ollama_url = "http://localhost:11434",
        temperature = 0.7,
        timeout = 30000,
      }
    }
  end)

  describe("Service Management", function()
    it("detects if Ollama is running", function()
      -- Test check_ollama() function
      -- Mock popen to simulate running/not running states
    end)

    it("starts Ollama service when not running", function()
      -- Test start_ollama() function
      -- Mock jobstart and verify service startup
    end)

    it("handles timeout when starting service", function()
      -- Test timeout behavior
    end)
  end)

  describe("API Communication", function()
    it("constructs correct API request", function()
      -- Test call_ollama() request formatting
      -- Verify JSON structure, escaping, headers
    end)

    it("handles successful API response", function()
      -- Mock successful response
      -- Verify callback execution with response text
    end)

    it("handles API errors gracefully", function()
      -- Mock error responses (404, 500, timeout)
      -- Verify error notifications
    end)

    it("escapes special characters in prompts", function()
      -- Test with prompts containing quotes, newlines, etc.
    end)
  end)

  describe("Model Selection", function()
    it("lists available models", function()
      -- Mock API call to list models
      -- Verify model list parsing
    end)

    it("switches between models", function()
      -- Test changing M.config.model
      -- Verify subsequent API calls use new model
    end)

    it("validates model availability", function()
      -- Test with invalid model names
      -- Verify fallback behavior
    end)
  end)
end)
```

## Component 2: AI Commands Tests

### File: `tests/plenary/unit/ai-sembr/ai_commands_spec.lua`

```lua
describe("AI Commands", function()
  local M -- Module under test

  before_each(function()
    -- Setup mocks for vim.api functions
    _G.vim = {
      api = {
        nvim_get_current_buf = function() return 1 end,
        nvim_buf_get_lines = function()
          return {"Line 1", "Line 2", "Line 3"}
        end,
        nvim_create_buf = function() return 2 end,
        nvim_open_win = function() return 1001 end,
      },
      fn = {
        mode = function() return "n" end,
        jobstart = function() return 1 end,
      },
      notify = function() end,
    }
  end)

  describe("Context Extraction", function()
    it("gets buffer context around cursor", function()
      -- Test get_buffer_context()
      -- Verify correct line range extraction
    end)

    it("gets visual selection correctly", function()
      -- Test get_visual_selection()
      -- Mock visual mode positions
    end)

    it("handles edge cases (empty buffer, single line)", function()
      -- Test with minimal content
    end)
  end)

  describe("AI Features", function()
    it("explains selected text", function()
      -- Test M.explain()
      -- Verify prompt construction
      -- Check result display
    end)

    it("summarizes content", function()
      -- Test M.summarize()
      -- Verify summarization prompt
    end)

    it("suggests related links", function()
      -- Test M.suggest_links()
      -- Verify Zettelkasten-specific prompts
    end)

    it("improves writing quality", function()
      -- Test M.improve()
      -- Verify improvement suggestions
    end)

    it("answers questions about content", function()
      -- Test M.answer_question()
      -- Mock user input
      -- Verify Q&A flow
    end)

    it("generates creative ideas", function()
      -- Test M.generate_ideas()
      -- Verify brainstorming prompts
    end)
  end)

  describe("Result Display", function()
    it("creates floating window with correct dimensions", function()
      -- Test M.show_result()
      -- Verify window creation parameters
    end)

    it("formats markdown content properly", function()
      -- Test with various markdown elements
    end)

    it("handles keymaps for closing window", function()
      -- Test q and Escape bindings
    end)
  end)
end)
```

## Component 3: Interactive Chat Tests

### File: `tests/plenary/unit/ai-sembr/chat_interface_spec.lua`

```lua
describe("Interactive Chat Interface", function()
  local chat

  before_each(function()
    -- Initialize chat module
    chat = require('percybrain.chat') -- hypothetical chat module
  end)

  describe("Chat Session Management", function()
    it("initiates new chat session", function()
      -- Test session creation
      -- Verify initial state
    end)

    it("maintains conversation context", function()
      -- Test multiple exchanges
      -- Verify context preservation
    end)

    it("handles session persistence", function()
      -- Test save/restore chat history
    end)
  end)

  describe("Chat Commands", function()
    it("executes test generation commands", function()
      -- Test "/test generate" command
      -- Verify test code output
    end)

    it("executes code explanation commands", function()
      -- Test "/explain" command with code selection
    end)

    it("executes debugging assistance commands", function()
      -- Test "/debug" command with error context
    end)

    it("handles custom prompts", function()
      -- Test arbitrary user prompts
    end)
  end)

  describe("Streaming Responses", function()
    it("handles streaming API responses", function()
      -- Test with stream: true
      -- Verify progressive display
    end)

    it("allows interruption of streaming", function()
      -- Test Ctrl-C during streaming
    end)
  end)
end)
```

## Component 4: Model Management Tests

### File: `tests/plenary/unit/ai-sembr/model_selection_spec.lua`

```lua
describe("Model Selection and Management", function()
  local models

  before_each(function()
    -- Setup model management mocks
  end)

  describe("Model Discovery", function()
    it("lists locally installed models", function()
      -- Mock ollama list command
      -- Expected models: llama3.2, codellama, mistral, etc.
    end)

    it("shows model details (size, parameters)", function()
      -- Mock ollama show command
      -- Verify model metadata display
    end)
  end)

  describe("Model Selection UI", function()
    it("provides Telescope picker for models", function()
      -- Test model selection interface
      -- Verify Telescope integration
    end)

    it("remembers last selected model", function()
      -- Test persistence of model choice
    end)

    it("validates model before selection", function()
      -- Test with non-existent model
    end)
  end)

  describe("Model-Specific Behavior", function()
    it("uses code models for programming tasks", function()
      -- Test automatic selection of codellama for code
    end)

    it("uses general models for prose", function()
      -- Test selection of llama3.2 for general text
    end)

    it("applies model-specific parameters", function()
      -- Test different temperature settings per model
    end)
  end)
end)
```

## Component 5: AI Draft Generator Tests

### File: `tests/plenary/unit/ai-sembr/ai_draft_spec.lua`

```lua
describe("AI Draft Generator", function()
  local ai_draft

  before_each(function()
    package.loaded['plugins.ai-sembr.ai-draft'] = nil
    -- Mock Zettelkasten note collection
  end)

  describe("Note Collection", function()
    it("collects notes on specified topic", function()
      -- Test note gathering logic
      -- Mock file system with test notes
    end)

    it("filters relevant notes by tags", function()
      -- Test tag-based filtering
    end)

    it("limits context to token budget", function()
      -- Test context window management
    end)
  end)

  describe("Draft Generation", function()
    it("synthesizes coherent draft from notes", function()
      -- Test draft generation with mock notes
      -- Verify prompt construction
    end)

    it("maintains note references", function()
      -- Test that draft includes [[wiki-links]]
    end)

    it("respects output format preferences", function()
      -- Test markdown, org-mode outputs
    end)
  end)
end)
```

## Test Helpers and Mocks

### File: `tests/helpers/ollama_mocks.lua`

```lua
local M = {}

-- Mock Ollama API responses
M.mock_responses = {
  generate = {
    model = "llama3.2:latest",
    created_at = "2025-01-01T00:00:00Z",
    response = "This is a mock response",
    done = true,
  },

  list = {
    models = {
      { name = "llama3.2:latest", size = 2000000000 },
      { name = "codellama:latest", size = 3000000000 },
      { name = "mistral:latest", size = 4000000000 },
    }
  },

  error = {
    error = "model not found"
  }
}

-- Mock HTTP client
function M.mock_curl(url, data)
  if url:match("/api/generate") then
    return vim.fn.json_encode(M.mock_responses.generate)
  elseif url:match("/api/tags") then
    return vim.fn.json_encode(M.mock_responses.list)
  else
    return vim.fn.json_encode(M.mock_responses.error)
  end
end

-- Mock jobstart for async operations
function M.mock_jobstart(cmd, opts)
  local response = M.mock_curl(cmd)
  if opts.on_stdout then
    opts.on_stdout(nil, {response})
  end
  return 1
end

return M
```

## Test Execution Strategy

### Running Tests

```bash
# Run all LLM tests
nvim --headless -u tests/minimal_init.lua \
  -c "PlenaryBustedDirectory tests/plenary/unit/ai-sembr/"

# Run specific test file
nvim --headless -u tests/minimal_init.lua \
  -c "PlenaryBustedFile tests/plenary/unit/ai-sembr/ollama_spec.lua"

# Interactive test development
nvim tests/plenary/unit/ai-sembr/ollama_spec.lua
:PlenaryBustedFile %
```

### Coverage Goals

| Component         | Target Coverage | Priority |
| ----------------- | --------------- | -------- |
| API Communication | 95%             | Critical |
| Model Selection   | 90%             | High     |
| Command Execution | 85%             | High     |
| Error Handling    | 100%            | Critical |
| UI Components     | 70%             | Medium   |

## Integration Test Scenarios

### Scenario 1: Complete AI Workflow

```lua
it("completes full AI-assisted writing workflow", function()
  -- 1. Start Ollama service
  -- 2. Select model (llama3.2)
  -- 3. Open a note
  -- 4. Request explanation
  -- 5. Generate improvements
  -- 6. Save results
end)
```

### Scenario 2: Model Switching

```lua
it("switches between models for different tasks", function()
  -- 1. Use llama3.2 for prose
  -- 2. Switch to codellama for code
  -- 3. Verify correct model usage
end)
```

### Scenario 3: Error Recovery

```lua
it("recovers from connection failures", function()
  -- 1. Simulate Ollama crash
  -- 2. Attempt API call
  -- 3. Verify restart attempt
  -- 4. Retry operation
end)
```

## Mock Data Requirements

### Test Notes for Zettelkasten

```markdown
# 202501181234 Test Note One
Tags: #testing #ai #knowledge

Content for testing AI features...

[[202501181235]] Related note link
```

### Test Prompts

```lua
local test_prompts = {
  simple = "Explain this concept",
  complex = "Explain this \"quoted\" text\nwith newlines",
  code = "function test() return true end",
  markdown = "# Heading\n- List item\n**Bold text**"
}
```

## Validation Criteria

### Functional Requirements

- ✅ Ollama service detection and startup
- ✅ API communication with proper escaping
- ✅ Model selection and switching
- ✅ All 6 AI commands working
- ✅ Interactive chat interface
- ✅ Error handling and recovery

### Non-Functional Requirements

- ⚡ Response time \< 5s for local models
- 🎯 >85% test coverage
- 🔄 Graceful degradation when Ollama unavailable
- 💾 Session persistence between Neovim restarts

## Implementation Timeline

1. **Phase 1**: Core Ollama tests (Week 1)

   - Service management
   - API communication
   - Basic mocking

2. **Phase 2**: AI Commands (Week 2)

   - All 6 command tests
   - UI components
   - Result display

3. **Phase 3**: Advanced Features (Week 3)

   - Model selection
   - Chat interface
   - Draft generator

4. **Phase 4**: Integration & Polish (Week 4)

   - End-to-end scenarios
   - Performance tests
   - Documentation
