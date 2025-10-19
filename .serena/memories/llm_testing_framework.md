# PercyBrain Local LLM Testing Framework

## Overview
Designed and implemented comprehensive unit tests for the Ollama Local LLM integration in PercyBrain using the Plenary testing framework.

## Files Created
1. `/tests/PERCYBRAIN_LLM_TEST_DESIGN.md` - Complete design document
2. `/tests/plenary/unit/ai-sembr/ollama_spec.lua` - Full test implementation

## Test Coverage

### Service Management
- Ollama service detection (pgrep)
- Service startup when not running
- Timeout handling

### API Communication
- Request formatting with proper JSON
- Special character escaping (quotes, newlines)
- Response parsing and callback execution
- Error handling (connection refused, timeouts)

### Context Extraction
- Buffer context around cursor (configurable lines)
- Visual selection handling
- Boundary conditions (start/end of buffer)

### AI Commands Tested
1. **explain()** - Text explanation with context
2. **summarize()** - Content summarization
3. **suggest_links()** - Zettelkasten link suggestions
4. **improve()** - Writing quality improvements
5. **answer_question()** - Q&A with user input
6. **generate_ideas()** - Creative brainstorming

### Model Configuration
- Model selection (llama3.2:latest, codellama:latest)
- Temperature settings (0.0-1.0)
- Custom Ollama URLs
- Context window management

### UI Components
- Floating window creation
- Markdown rendering
- Keymap bindings (q, Escape to close)

## Mock Strategy

### Vim API Mocking
```lua
_G.vim = {
  api = { nvim_get_current_buf, nvim_buf_get_lines, ... },
  fn = { jobstart, json_decode, mode, ... },
  notify = function(msg, level) end
}
```

### Async Operation Mocking
- jobstart simulation with callbacks
- on_stdout/on_stderr handlers
- Deferred function execution

### Service Detection Mocking
```lua
io.popen = function(cmd)
  -- Mock pgrep results
end
```

## Running Tests

```bash
# All LLM tests
nvim --headless -u tests/minimal_init.lua \
  -c "PlenaryBustedDirectory tests/plenary/unit/ai-sembr/"

# Specific test
nvim --headless -u tests/minimal_init.lua \
  -c "PlenaryBustedFile tests/plenary/unit/ai-sembr/ollama_spec.lua"

# Interactive development
:PlenaryBustedFile %
```

## Key Insights

1. **Comprehensive mocking** - Full vim API mock allows headless testing
2. **Async handling** - Properly simulates jobstart and callbacks
3. **Real module loading** - Tests actual plugin code, not mocks
4. **Edge case coverage** - Boundary conditions, empty inputs, errors
5. **Prompt validation** - Ensures correct LLM prompt construction

## Test Results
- 10 test suites
- 30+ individual tests
- Covers all major functionality
- Ready for CI/CD integration