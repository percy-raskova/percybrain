# Failure Mode Catalog - Integration Testing

This catalog systematically enumerates failure modes that must be tested at the integration level.

## Category 1: External Service Failures

| Failure Mode            | Scenario                             | Expected Behavior                        | Test Location              |
| ----------------------- | ------------------------------------ | ---------------------------------------- | -------------------------- |
| **Connection timeout**  | Ollama unreachable after 5s          | Circuit breaker activates, user notified | `error_scenarios_spec.lua` |
| **Rate limiting**       | Ollama returns 429 Too Many Requests | Exponential backoff, retry after delay   | `resilience_spec.lua`      |
| **Partial response**    | AI returns incomplete JSON           | Parse error caught, user notified        | `error_scenarios_spec.lua` |
| **Service unavailable** | Ollama returns 503                   | Graceful degradation, user notified      | `error_scenarios_spec.lua` |

## Category 2: Degraded Performance

| Failure Mode        | Scenario                      | Expected Behavior                  | Test Location                      |
| ------------------- | ----------------------------- | ---------------------------------- | ---------------------------------- |
| **Slow processing** | AI takes 4.5s (\< 5s timeout) | Success with performance warning   | `performance_degradation_spec.lua` |
| **High CPU usage**  | System under load             | Queue management prevents overload | `load_handling_spec.lua`           |
| **Memory pressure** | Limited RAM available         | Graceful handling, no crashes      | `resource_constraints_spec.lua`    |

## Category 3: Data Validation Failures

| Failure Mode                 | Scenario                                     | Expected Behavior                            | Test Location              |
| ---------------------------- | -------------------------------------------- | -------------------------------------------- | -------------------------- |
| **Invalid Hugo frontmatter** | Missing required fields (date, draft, title) | Clear validation error with helpful guidance | `hugo_validation_spec.lua` |
| **Corrupted file**           | Non-UTF8 encoding                            | Graceful error, original file preserved      | `file_handling_spec.lua`   |
| **Malformed YAML**           | Frontmatter YAML syntax error                | Parse error with line number                 | `hugo_validation_spec.lua` |

## Category 4: State Management Issues

| Failure Mode         | Scenario                          | Expected Behavior                           | Test Location                |
| -------------------- | --------------------------------- | ------------------------------------------- | ---------------------------- |
| **Concurrent saves** | User saves multiple notes rapidly | Queue management, sequential processing     | `concurrency_spec.lua`       |
| **Resource leak**    | Test doesn't clean up temp files  | `verify_clean_state()` detects and reports  | All integration tests        |
| **State pollution**  | Previous test affects next test   | Test isolation prevents cross-contamination | `environment_setup_spec.lua` |

## Category 5: Integration Point Failures

| Failure Mode                          | Scenario                                 | Expected Behavior                        | Test Location                            |
| ------------------------------------- | ---------------------------------------- | ---------------------------------------- | ---------------------------------------- |
| **Template → Pipeline mismatch**      | Template type not recognized by pipeline | Fallback to default processing           | `template_pipeline_interaction_spec.lua` |
| **AI Model → Pipeline mismatch**      | Selected model not available             | Fallback to default model                | `ai_pipeline_interaction_spec.lua`       |
| **Hugo Validation → Pipeline timing** | Validation runs before AI completes      | Wait for AI completion before validation | `hugo_pipeline_interaction_spec.lua`     |

## Category 6: User Input Edge Cases

| Failure Mode                | Scenario                          | Expected Behavior                     | Test Location               |
| --------------------------- | --------------------------------- | ------------------------------------- | --------------------------- |
| **Empty input**             | User saves empty note             | Validation error, prevent empty save  | `input_validation_spec.lua` |
| **Extremely long content**  | 10MB+ note                        | Chunk processing, performance warning | `large_content_spec.lua`    |
| **Special characters**      | Unicode, emoji, control chars     | Proper encoding, no corruption        | `encoding_spec.lua`         |
| **Path traversal attempts** | "../../../etc/passwd" in filename | Security error, operation blocked     | `security_spec.lua`         |

## Category 7: Filesystem Failures

| Failure Mode            | Scenario                   | Expected Behavior                      | Test Location                 |
| ----------------------- | -------------------------- | -------------------------------------- | ----------------------------- |
| **Disk full**           | No space for new note      | Clear error message, no partial writes | `disk_space_spec.lua`         |
| **Permission denied**   | Cannot write to vault      | Permission error with helpful guidance | `permissions_spec.lua`        |
| **File already exists** | Duplicate note creation    | User prompted for rename/overwrite     | `duplicate_handling_spec.lua` |
| **Symlink loops**       | Circular symlinks in vault | Detection and error, no infinite loop  | `symlink_handling_spec.lua`   |

## Category 8: Configuration Failures

| Failure Mode             | Scenario                   | Expected Behavior                  | Test Location                    |
| ------------------------ | -------------------------- | ---------------------------------- | -------------------------------- |
| **Missing templates**    | Template directory empty   | Fallback to default template       | `template_fallback_spec.lua`     |
| **Invalid config**       | Malformed config file      | Use defaults, warn user            | `config_validation_spec.lua`     |
| **Missing dependencies** | Required LSP not installed | Feature degradation, clear message | `dependency_check_spec.lua`      |
| **Version mismatch**     | Plugin API incompatibility | Compatibility warning, safe mode   | `version_compatibility_spec.lua` |

## Testing Strategy for Failure Modes

### 1. Error Injection Framework

```lua
-- helpers/error_injector.lua
local M = {}

function M.inject_ollama_timeout()
  -- Override Ollama client with timeout behavior
end

function M.inject_filesystem_full()
  -- Mock filesystem to return ENOSPC
end

function M.inject_memory_pressure()
  -- Simulate low memory conditions
end

return M
```

### 2. Resilience Test Pattern

```lua
describe("Resilience: Service Failures", function()
  local error_injector = require("tests.integration.helpers.error_injector")

  it("handles Ollama timeout gracefully", function()
    -- Arrange: Inject timeout behavior
    error_injector.inject_ollama_timeout()

    -- Act: Perform operation that uses Ollama
    local result = perform_ai_operation()

    -- Assert: Graceful degradation occurred
    assert.equals("degraded", result.status)
    assert.is_not_nil(result.fallback_message)
    assert.is_false(result.crashed)
  end)
end)
```

### 3. Chaos Testing Approach

- **Random failure injection** during integration test runs
- **Stress testing** with concurrent operations
- **Resource exhaustion** scenarios
- **Network partition** simulation for external services

## Coverage Requirements

### Must Test (Critical Path)

- All Category 1 (External Service) failures
- All Category 3 (Data Validation) failures
- All Category 5 (Integration Point) failures

### Should Test (Important)

- Category 2 (Performance) under normal conditions
- Category 4 (State Management) basic scenarios
- Category 6 (User Input) common edge cases

### Nice to Have (Comprehensive)

- All Category 7 (Filesystem) edge cases
- All Category 8 (Configuration) scenarios
- Chaos testing with multiple simultaneous failures

## Failure Mode Discovery Process

1. **Code Review**: Identify all external dependencies and I/O operations
2. **User Reports**: Collect and categorize production failures
3. **Fuzz Testing**: Generate random inputs to discover edge cases
4. **Dependency Analysis**: Map all integration points between components
5. **Performance Profiling**: Identify bottlenecks and resource constraints

## Maintenance and Updates

This catalog should be updated when:

- New external dependencies are added
- New integration points are created
- Production failures are discovered
- Performance requirements change
- Security vulnerabilities are identified

______________________________________________________________________

**Last Updated**: October 20, 2025 **Maintainer**: Kent Beck Testing Persona **Review Schedule**: Monthly or after major feature additions
