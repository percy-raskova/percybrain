# Mock Ollama for Fast Testing

**Purpose**: Provides deterministic, fast AI responses for GTD test suite without network calls.

## Performance Impact

- **Before**: 20.4 seconds (real Ollama API calls)
- **After**: 0.386 seconds (mock responses)
- **Speedup**: **53x faster** ⚡

## Usage

### Default Behavior (Mock Mode)

Tests automatically use mock Ollama by default:

```bash
./tests/run-unit-tests.sh gtd_ai_spec.lua  # Uses mock (0.4s)
```

### Integration Testing (Real Ollama)

To test with real Ollama API:

```bash
GTD_TEST_REAL_OLLAMA=1 ./tests/run-unit-tests.sh gtd_ai_spec.lua  # Uses real Ollama (20s+)
```

## Architecture

### Mock Responses

The mock provides intelligent, context-aware responses:

**Task Decomposition**:

- "Build a website" → 7 web development subtasks
- "Plan vacation" → 5 travel planning subtasks
- Generic tasks → 5 general planning subtasks

**Context Suggestion**:

- "Fix kitchen sink" → `@home`
- "Call doctor" → `@phone`
- "Write code" → `@computer`
- "Meeting" → `@work`
- "Buy groceries" → `@errands`

**Priority Inference**:

- "Emergency" / "NOW" / "Tax" → `HIGH`
- "Someday" / "Maybe" / "Groceries" → `LOW`
- Everything else → `MEDIUM`

### Mock API

```lua
local mock_ollama = require("tests.helpers.mock_ollama")

-- Enable mock mode
mock_ollama.enable()

-- Setup default GTD responses
mock_ollama.setup_gtd_defaults()

-- Patch AI module to use mock
local ai = require("percybrain.gtd.ai")
mock_ollama.patch_ai_module(ai)

-- Run tests (instant responses)
ai.decompose_task()
ai.suggest_context()
ai.infer_priority()

-- Restore original AI module
mock_ollama.unpatch_ai_module(ai)
mock_ollama.disable()
```

### Custom Responses

For custom test scenarios:

```lua
-- Custom pattern-based response
mock_ollama.set_response("specific task pattern", "- [ ] Custom subtask 1\n- [ ] Custom subtask 2")

-- Dynamic response function
mock_ollama.set_response("pattern", function(prompt)
  local task = prompt:match('Task: "([^"]+)"')
  return "- [ ] Dynamic subtask for: " .. task
end)
```

## Implementation Details

**File**: `tests/helpers/mock_ollama.lua` (182 lines)

**Key Features**:

- Pattern-based response matching
- Function-based dynamic responses
- Runtime module patching/unpatching
- Async callback simulation via `vim.schedule()`
- No network calls, no external dependencies

**Test Integration**:

- Before each test: Enable mock, setup defaults, patch ai module
- After each test: Unpatch ai module, disable mock
- Environment variable override: `GTD_TEST_REAL_OLLAMA=1`

## Benefits

1. **Development Speed**: Instant feedback during TDD cycles
2. **Determinism**: Consistent, predictable test behavior
3. **CI/CD Ready**: No Ollama dependency for test runs
4. **Debugging**: Easier to debug with known responses
5. **Coverage**: Test edge cases without AI variability

## Trade-offs

**Mock Mode (Default)**:

- ✅ Fast (0.4s)
- ✅ Deterministic
- ✅ No external dependencies
- ❌ Doesn't validate real Ollama integration
- ❌ Responses may not match actual AI behavior

**Real Ollama Mode** (`GTD_TEST_REAL_OLLAMA=1`):

- ✅ Validates real API integration
- ✅ Tests actual AI responses
- ❌ Slow (20s+)
- ❌ Non-deterministic
- ❌ Requires Ollama running

## Recommendation

- **Development**: Use mock mode (default) for rapid iteration
- **CI/CD**: Use mock mode for fast pipeline execution
- **Integration Testing**: Periodically run with real Ollama to validate API integration
- **Pre-release**: Run with real Ollama to catch API changes

## Example Workflow

```bash
# Rapid TDD development (mock mode)
while true; do
  nvim lua/percybrain/gtd/ai.lua
  ./tests/run-unit-tests.sh gtd_ai_spec.lua  # 0.4s
done

# Pre-commit validation (real Ollama)
GTD_TEST_REAL_OLLAMA=1 ./tests/run-unit-tests.sh gtd_ai_spec.lua  # 20s+
git commit -m "feat(gtd): add AI task decomposition"
```
