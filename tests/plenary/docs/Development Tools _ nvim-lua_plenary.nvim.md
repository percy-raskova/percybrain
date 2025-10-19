---
title: " Development Tools  Development Tools | nvim-lua/plenary.nvim"
author:
published:    Development Tools | nvim-lua/plenary.nvim | DeepWiki
description: "   nvim-lua/plenary.nvim"
source: "https://deepwiki.com/nvim-lua/plenary.nvim/10-development-tools"
created: 2025-10-18
category: "category:   [\"nvim-lua\",\"plenary.nvim\",\"10-development-tools\"]"
tags:
  - "tags:"
image: "image:    "
cover: "cover: "
---
Menu

## Development Tools

Relevant source files
- [.styluaignore](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/.styluaignore)
- [lua/plenary/\_meta/\_luassert.lua](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/_meta/_luassert.lua)
- [lua/plenary/busted.lua](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/busted.lua)
- [lua/plenary/log.lua](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/log.lua)
- [lua/plenary/profile.lua](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/profile.lua)
- [lua/plenary/profile/p.lua](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/profile/p.lua)
- [scripts/generate\_luassert\_types.lua](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/scripts/generate_luassert_types.lua)
- [tests/manual/large\_job\_spec.lua](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/tests/manual/large_job_spec.lua)
- [tests/plenary/simple\_busted\_spec.lua](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/tests/plenary/simple_busted_spec.lua)
- [tests/plenary/uses\_nvim\_spec.lua](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/tests/plenary/uses_nvim_spec.lua)

This page documents the development tools provided by plenary.nvim that help plugin developers create, test, debug, and optimize their Neovim plugins. These tools include a comprehensive logging system, a testing framework compatible with Busted, and profiling utilities for performance optimization.

For specific details about each component, see [Testing Framework](https://deepwiki.com/nvim-lua/plenary.nvim/10.1-testing-framework), [Logging System](https://deepwiki.com/nvim-lua/plenary.nvim/10.2-logging-system), and [Profiling](https://deepwiki.com/nvim-lua/plenary.nvim/10.3-profiling).

## Development Tools Overview

```
Core DependenciesDevelopment Toolsplenary.log
Logging system for pluginsplenary.busted
BDD testing frameworkplenary.path
Path manipulationplenary.job
Process management
```

Sources: [lua/plenary/log.lua 1-236](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/log.lua#L1-L236) [lua/plenary/busted.lua 1-272](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/busted.lua#L1-L272) [lua/plenary/profile.lua 1-32](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/profile.lua#L1-L32)

## Logging System

The logging system (`plenary.log`) provides plugin developers with a configurable way to debug and track their plugin's behavior. It supports multiple output destinations and customizable log levels.

### Configuration Options

The logging system can be configured with the following options:

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `plugin` | string | "plenary" | Name of plugin, prepended to log messages |
| `use_console` | string/boolean | "async" | Print to Neovim console: 'sync','async',false |
| `highlights` | boolean | true | Use syntax highlighting in console output |
| `use_file` | boolean | true | Write logs to a file |
| `outfile` | string | nil | Custom log file path (default: stdpath("log")/plugin.log) |
| `use_quickfix` | boolean | false | Write logs to the quickfix list |
| `level` | string | "info" | Minimum log level to record ("debug" if DEBUG\_PLENARY is set) |
| `float_precision` | number | 0.01 | Precision for floating point values in logs |

Sources: [lua/plenary/log.lua 18-71](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/log.lua#L18-L71)

### Logging API

```
plenary.logLogging MethodsDirect logging:
log.trace(...)
log.debug(...)
log.info(...)
log.warn(...)
log.error(...)
log.fatal(...)log.new(config)
Creates a new logger instanceFormatted logging:
log.fmt_info(format, ...)
log.fmt_debug(format, ...)
etc.Lazy evaluation:
log.lazy_info(function)
log.lazy_debug(function)
etc.File-only logging:
log.file_info(values, override)
log.file_debug(values, override)
etc.
```

Sources: [lua/plenary/log.lua 194-226](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/log.lua#L194-L226)

### Usage Example

```
-- Create a custom logger for your plugin
local log = require('plenary.log').new({
  plugin = "my_plugin",
  level = "debug",
})

-- Basic logging
log.info("Plugin initialized")
log.debug("Configuration:", config)
log.error("Failed to load file:", file_path)

-- Formatted logging (with automatic inspection)
log.fmt_warn("Failed to find %s in directory %s", filename, dir)

-- Lazy evaluation for expensive operations
log.lazy_debug(function()
  return expensive_calculation_for_debugging()
end)
```

Sources: [lua/plenary/log.lua 75-233](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/log.lua#L75-L233)

## Testing Framework

Plenary provides a Busted-compatible testing framework (`plenary.busted`) designed specifically for testing Neovim plugins in a way that integrates with Neovim's architecture.

### Test Structure and Lifecycle

```
PlenaryBustedFile commandParse test structureExecute testsFormat and display resultsLoadTestFileTest StructureTest caseSetupTeardownNested contextdescribeitbefore_eachafter_eachnested_describeRunTestsExecuteBeforeEachExecuteTestExecuteAfterEachReportResults
```

Sources: [lua/plenary/busted.lua 45-206](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/busted.lua#L45-L206)

### Test Framework API

| Function | Description |
| --- | --- |
| `describe(desc, func)` | Defines a test suite or context |
| `it(desc, func)` | Defines a test case |
| `pending(desc, func)` | Marks a test as pending (will not run) |
| `before_each(func)` | Runs before each test in the current scope |
| `after_each(func)` | Runs after each test in the current scope |
| `assert.*` | Assertions from luassert library (e.g., `assert.equals()`) |

Sources: [lua/plenary/busted.lua 119-205](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/busted.lua#L119-L205)

### Command Interface

| Command | Description |
| --- | --- |
| `:PlenaryBustedFile [file]` | Run tests in a single file |
| `:PlenaryBustedDirectory [dir]` | Run all tests in a directory |
| `<Plug>PlenaryTestFile` | Mapping to test the current file |

### Example Test File

Here's an example of how to structure tests with plenary.busted:

```
describe("feature name", function()
  local count = 0
  
  before_each(function()
    -- Setup code runs before each test
    count = 0
  end)
  
  after_each(function()
    -- Teardown code runs after each test
  end)
  
  it("should increment counter", function()
    count = count + 1
    assert.equals(1, count)
  end)
  
  describe("nested context", function()
    before_each(function()
      -- Additional setup for this context
      count = count + 10
    end)
    
    it("should have the right count", function()
      assert.equals(10, count)
    end)
  end)
  
  pending("test that's not implemented yet", function()
    -- This test will be skipped and marked as pending
  end)
end)
```

Sources: [tests/plenary/simple\_busted\_spec.lua 1-206](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/tests/plenary/simple_busted_spec.lua#L1-L206)

## Profiling Tools

Plenary provides profiling tools (`plenary.profile`) for measuring performance and identifying bottlenecks in Lua code.

```
profile.start(out, opts)
Start LuaJIT profilerprofile.stop()
Stop profilingprofile.benchmark(iterations, f, ...)
Measure execution timeReturns execution time in seconds
```

Sources: [lua/plenary/profile.lua 1-32](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/profile.lua#L1-L32) [lua/plenary/profile/p.lua 1-313](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/profile/p.lua#L1-L313)

### Profiling API

| Function | Description |
| --- | --- |
| `profile.start(out, opts)` | Start profiling, writing results to `out` file |
| `profile.stop()` | Stop profiling and save results |
| `profile.benchmark(iterations, f, ...)` | Run function `f` with arguments `...` for `iterations` times and return total execution time in seconds |

The profiler options include:

```
{
  flame = true/false  -- Whether to generate flamegraph output
}
```

Sources: [lua/plenary/profile.lua 7-28](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/profile.lua#L7-L28)

### Usage Examples

To profile a section of code:

```
local profile = require('plenary.profile')

-- Start profiling
profile.start("profile.log")

-- Run code to be profiled
some_function()

-- Stop profiling
profile.stop()
```

To benchmark a function:

```
local profile = require('plenary.profile')

local time = profile.benchmark(1000, function(arg1, arg2)
  return expensive_calculation(arg1, arg2)
end, "parameter1", "parameter2")

print("Total time for 1000 iterations:", time, "seconds")
print("Average time per call:", time/1000, "seconds")
```

For flame graphs (visualization of profiler output):

```
-- Generate flame graph compatible output
profile.start("flamegraph.log", { flame = true })
-- Code to profile
profile.stop()
-- Process output with tools like https://github.com/brendangregg/FlameGraph
```

Sources: [lua/plenary/profile.lua 8-29](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/profile.lua#L8-L29) [lua/plenary/profile/p.lua 275-306](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/profile/p.lua#L275-L306)

## Integration Between Components

The development tools are designed to work together while remaining independent modules:

```
Neovim Plugin Development WorkflowWrite Plugin CodeWrite Tests 
(plenary.busted)Debug Issues
(plenary.log)Optimize Performance
(plenary.profile)
```

Together, these tools provide a comprehensive toolkit for Neovim plugin development, enabling developers to create reliable, maintainable, and performant plugins.

<svg id="mermaid-o05b9awrxd" width="100%" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 2412 512" style="max-width: 512px;" role="graphics-document document" aria-roledescription="error"><g></g><g><path class="error-icon" d="m411.313,123.313c6.25-6.25 6.25-16.375 0-22.625s-16.375-6.25-22.625,0l-32,32-9.375,9.375-20.688-20.688c-12.484-12.5-32.766-12.5-45.25,0l-16,16c-1.261,1.261-2.304,2.648-3.31,4.051-21.739-8.561-45.324-13.426-70.065-13.426-105.867,0-192,86.133-192,192s86.133,192 192,192 192-86.133 192-192c0-24.741-4.864-48.327-13.426-70.065 1.402-1.007 2.79-2.049 4.051-3.31l16-16c12.5-12.492 12.5-32.758 0-45.25l-20.688-20.688 9.375-9.375 32.001-31.999zm-219.313,100.687c-52.938,0-96,43.063-96,96 0,8.836-7.164,16-16,16s-16-7.164-16-16c0-70.578 57.422-128 128-128 8.836,0 16,7.164 16,16s-7.164,16-16,16z"></path><path class="error-icon" d="m459.02,148.98c-6.25-6.25-16.375-6.25-22.625,0s-6.25,16.375 0,22.625l16,16c3.125,3.125 7.219,4.688 11.313,4.688 4.094,0 8.188-1.563 11.313-4.688 6.25-6.25 6.25-16.375 0-22.625l-16.001-16z"></path><path class="error-icon" d="m340.395,75.605c3.125,3.125 7.219,4.688 11.313,4.688 4.094,0 8.188-1.563 11.313-4.688 6.25-6.25 6.25-16.375 0-22.625l-16-16c-6.25-6.25-16.375-6.25-22.625,0s-6.25,16.375 0,22.625l15.999,16z"></path><path class="error-icon" d="m400,64c8.844,0 16-7.164 16-16v-32c0-8.836-7.156-16-16-16-8.844,0-16,7.164-16,16v32c0,8.836 7.156,16 16,16z"></path><path class="error-icon" d="m496,96.586h-32c-8.844,0-16,7.164-16,16 0,8.836 7.156,16 16,16h32c8.844,0 16-7.164 16-16 0-8.836-7.156-16-16-16z"></path><path class="error-icon" d="m436.98,75.605c3.125,3.125 7.219,4.688 11.313,4.688 4.094,0 8.188-1.563 11.313-4.688l32-32c6.25-6.25 6.25-16.375 0-22.625s-16.375-6.25-22.625,0l-32,32c-6.251,6.25-6.251,16.375-0.001,22.625z"></path><text class="error-text" x="1440" y="250" font-size="150px" style="text-anchor: middle;">Syntax error in text</text> <text class="error-text" x="1250" y="400" font-size="100px" style="text-anchor: middle;">mermaid version 11.6.0</text></g></svg>
