---
title: ' Testing Framework  Testing Framework | nvim-lua/plenary.nvim'
author:
published: Testing Framework | nvim-lua/plenary.nvim | DeepWiki
description: '   nvim-lua/plenary.nvim'
source: https://deepwiki.com/nvim-lua/plenary.nvim/10.1-testing-framework
created: 2025-10-18
category: 'category:   ["nvim-lua","plenary.nvim","10.1-testing-framework"]'
tags:
  - 'tags:'
image: 'image:    '
cover: 'cover: '
---

Menu

## Testing Framework

Relevant source files

- [.styluaignore](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/.styluaignore)
- [TESTS_README.md](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/TESTS_README.md)
- [lua/plenary/\_meta/\_luassert.lua](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/_meta/_luassert.lua)
- [lua/plenary/busted.lua](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/busted.lua)
- [lua/plenary/neorocks/init.lua](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/neorocks/init.lua)
- [lua/plenary/window/init.lua](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/window/init.lua)
- [plugin/plenary.vim](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/plugin/plenary.vim)
- [scripts/generate_luassert_types.lua](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/scripts/generate_luassert_types.lua)
- [tests/manual/large_job_spec.lua](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/tests/manual/large_job_spec.lua)
- [tests/plenary/async_testing_spec.lua](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/tests/plenary/async_testing_spec.lua)
- [tests/plenary/simple_busted_spec.lua](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/tests/plenary/simple_busted_spec.lua)
- [tests/plenary/uses_nvim_spec.lua](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/tests/plenary/uses_nvim_spec.lua)

This document provides comprehensive documentation of plenary.nvim's testing framework which offers a Busted-compatible interface for writing and running tests in Neovim plugins. The framework includes a test harness for executing tests and supports synchronous and asynchronous testing approaches. For information about logging in tests, see [Logging System](https://deepwiki.com/nvim-lua/plenary.nvim/10.2-logging-system).

## Overview

Plenary's testing framework enables Neovim plugin developers to write tests with a familiar BDD-style syntax (similar to Busted) while providing tight integration with Neovim's API. It supports test discovery, running individual test files or entire directories, and reporting test results.

```
AssertionsBusted FrameworkTest HarnessTest CommandsPlenaryBustedFile commandPlenaryBustedDirectory commandPlenaryTestFile mappingplenary.test_harnesstest_file() - Runs single filetest_directory() - Runs dirplenary.busteddescribe() - Test suiteit() - Individual testbefore_each() - Setupafter_each() - Teardownpending() - Skip testluassert libraryassert.equals()assert.same()assert.truthy()spy/stub/mock
```

Sources: [lua/plenary/busted.lua 1-271](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/busted.lua#L1-L271) [plugin/plenary.vim 1-9](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/plugin/plenary.vim#L1-L9)

## Architecture

The testing framework consists of two main components:

1. **Test Harness** - Responsible for discovering and running tests, configured through commands
2. **Busted Framework** - Provides the testing API and handles test execution, results, and reporting

```
invokesusesexposesTestHarnesstest_file(filepath)test_directory(directory, opts)test_directory_command(...)BustedFrameworkdescribe(desc, func)inner_describe(desc, func)it(desc, func)pending(desc, func)before_each(func)after_each(func)run(file)format_results(res)CommandsPlenaryBustedFilePlenaryBustedDirectoryPlenaryTestFileGlobalFunctionsdescribeitpendingbefore_eachafter_eachassert
```

Sources: [lua/plenary/busted.lua 44-271](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/busted.lua#L44-L271) [plugin/plenary.vim 2-9](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/plugin/plenary.vim#L2-L9)

## Testing API

The testing framework exposes several global functions for defining test suites and individual tests:

| Function               | Description                                                       |
| ---------------------- | ----------------------------------------------------------------- |
| `describe(desc, func)` | Defines a group of related tests with a description               |
| `it(desc, func)`       | Defines an individual test case with a description                |
| `pending(desc, func)`  | Marks a test as pending (skipped)                                 |
| `before_each(func)`    | Registers a function to run before each test in the current scope |
| `after_each(func)`     | Registers a function to run after each test in the current scope  |
| `assert`               | The assertion library (luassert) for making assertions in tests   |

The framework maintains a stack of descriptions and setup/teardown functions to handle nested test suites correctly.

Sources: [lua/plenary/busted.lua 119-214](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/busted.lua#L119-L214)

## Running Tests

The framework provides several commands and mappings for running tests:

### Commands

```
" Run tests in a specific file
:PlenaryBustedFile path/to/test_file.lua

" Run all tests in a directory
:PlenaryBustedDirectory path/to/test/dir/

" Run tests in the current file (mapping)
<Plug>PlenaryTestFile
```

You can also run tests in headless mode for CI/CD pipelines:

```
# Run all tests and exit with appropriate exit code
nvim --headless -c "PlenaryBustedDirectory tests/"
```

The test runner reports test results with detailed traces for any failures, and in headless mode, it will set the exit code based on test results (0 for success, 1 for test failures, 2 for errors).

Sources: [plugin/plenary.vim 2-9](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/plugin/plenary.vim#L2-L9) [lua/plenary/busted.lua 243-267](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/busted.lua#L243-L267)

## Writing Tests

### Basic Test Structure

Tests are organized in a hierarchical BDD-style structure using `describe` and `it` blocks:

```
describe("module name", function()
  describe("function name", function()
    it("should do something specific", function()
      -- Test code here
      local result = my_module.my_function()
      assert.equals(expected_value, result)
    end)

    it("should handle edge cases", function()
      -- Another test
      assert.truthy(my_module.validate())
    end)
  end)
end)
```

### Setup and Teardown

Use `before_each` and `after_each` to set up preconditions and clean up after tests:

```
describe("module with state", function()
  local state

  before_each(function()
    -- Runs before each test in this describe block
    state = { count = 0 }
  end)

  after_each(function()
    -- Runs after each test in this describe block
    state = nil
  end)

  it("should modify state", function()
    state.count = state.count + 1
    assert.equals(1, state.count)
  end)

  it("should have fresh state", function()
    -- state is reset by before_each
    assert.equals(0, state.count)
  end)
end)
```

Setup and teardown functions are scoped to their `describe` block and any nested blocks. They run in order from outermost to innermost scope.

Sources: [lua/plenary/busted.lua 142-171](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/busted.lua#L142-L171) [tests/plenary/simple_busted_spec.lua 27-68](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/tests/plenary/simple_busted_spec.lua#L27-L68)

### Asynchronous Testing

The testing framework supports asynchronous testing using coroutines, allowing you to test code that uses Neovim's asynchronous functionalities:

```
describe("async operation", function()
  it("can test async code", function()
    local co = coroutine.running()

    -- Set up an async operation
    vim.defer_fn(function()
      -- Resume test after operation completes
      coroutine.resume(co)
    end, 100)

    -- Pause test execution until resumed
    coroutine.yield()

    -- Test continues here after async operation
    assert(true)
  end)
end)
```

This pattern can be used to test any asynchronous code, including callbacks, timers, and job completions.

```
"Async Operation""Neovim Event Loop""Test Function""Async Operation""Neovim Event Loop""Test Function"Test pauses hereTest resumes hereStart testGet current coroutineStart async operationSchedule workcoroutine.yield()Complete workcoroutine.resume()Make assertions
```

Sources: [tests/plenary/async_testing_spec.lua 1-75](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/tests/plenary/async_testing_spec.lua#L1-L75)

### Mocking with Luassert

The framework includes the luassert library, which provides spy, stub, and mock capabilities for testing code that interacts with external dependencies:

```
-- Import luassert mock/stub functionality
local mock = require('luassert.mock')
local stub = require('luassert.stub')

describe("module using vim.api", function()
  it("calls api methods correctly", function()
    -- Create a mock of vim.api
    local api_mock = mock(vim.api, true)

    -- Set up expectations
    api_mock.nvim_get_current_buf.returns(5)

    -- Call code that uses vim.api
    my_module.function_under_test()

    -- Verify api was called correctly
    assert.stub(api_mock.nvim_get_current_buf).was_called(1)
    assert.stub(api_mock.nvim_buf_set_lines).was_called_with(5, 0, -1, false, {"test"})

    -- Restore original vim.api
    mock.revert(api_mock)
  end)
end)
```

The assertions available through luassert are extensive and type-hinted for better editor integration.

Sources: [lua/plenary/\_meta/\_luassert.lua 1-289](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/_meta/_luassert.lua#L1-L289) [TESTS_README.md 54-130](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/TESTS_README.md#L54-L130)

## Implementation Details

### Test Execution Flow

When a test file is executed through the test harness, the following process occurs:

1. The file is loaded and executed
2. `describe` blocks register test suites recursively
3. For each `it` block encountered:
   - All applicable `before_each` functions are run
   - The test function is executed
   - If the test passes, it's added to `results.pass`
   - If the test fails, it's added to `results.fail` with error details
   - All applicable `after_each` functions are run
4. Results are formatted and displayed
5. In headless mode, appropriate exit code is set

```
For Each TestYesNoRun Test FileLoad Test FileExecute Test FileProcess describe blocksRun before_each functionsExecute test functionTest passed?Add to passing resultsAdd to failing resultsRun after_each functionsFormat and display resultsSet exit code (headless mode)End
```

Sources: [lua/plenary/busted.lua 218-267](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/busted.lua#L218-L267)

## Common Patterns and Best Practices

### Organizing Test Files

Test files should be named with a `_spec.lua` suffix and organized to mirror the structure of the code being tested:

```
plugin/
  my_plugin.lua
tests/
  my_plugin/
    feature1_spec.lua
    feature2_spec.lua
```

### Testing Neovim API Integration

When testing code that interacts with the Neovim API, you can either:

1. Use mocks/stubs to isolate the code (unit testing)
2. Test against the actual Neovim instance (integration testing)

The choice depends on the specific testing goals and the complexity of the API interaction.

The framework captures errors and provides detailed stack traces. You can use `pcall` to test code that is expected to throw errors:

```
it("should throw an error for invalid input", function()
  local ok, err = pcall(function()
    my_module.function_that_throws("invalid")
  end)
  assert.is_false(ok)
  assert.matches("expected error message", err)
end)
```

Sources: [TESTS_README.md 1-153](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/TESTS_README.md#L1-L153) [lua/plenary/busted.lua 5-30](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/busted.lua#L5-L30)
