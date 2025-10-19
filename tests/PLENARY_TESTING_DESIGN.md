# Plenary-Based Unit Testing Workflow Design
*Architecture Document for PercyBrain Plugin Testing*
*Date: 2025-10-18*

## Executive Summary

This document defines a comprehensive testing architecture leveraging Plenary.nvim's built-in testing framework for the PercyBrain plugin ecosystem. The design provides unit, integration, and performance testing capabilities while maintaining the project's neurodiversity-focused philosophy.

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Test Execution Layer                      │
├─────────────────────────────────────────────────────────────┤
│  CI/CD Pipeline │ Manual Testing │ Watch Mode │ Coverage    │
├─────────────────────────────────────────────────────────────┤
│                    Test Runner Layer                         │
├─────────────────────────────────────────────────────────────┤
│  Plenary Harness │ Custom Runner │ Headless Mode │ Reports  │
├─────────────────────────────────────────────────────────────┤
│                    Test Suite Layer                          │
├─────────────────────────────────────────────────────────────┤
│  Unit Tests │ Integration Tests │ Performance │ E2E Tests   │
├─────────────────────────────────────────────────────────────┤
│                    Framework Layer                           │
├─────────────────────────────────────────────────────────────┤
│  Plenary.nvim │ Luassert │ Mocking │ Async Testing         │
└─────────────────────────────────────────────────────────────┘
```

## Directory Structure

```
tests/
├── plenary/                     # Plenary test suites
│   ├── unit/                    # Unit tests for individual components
│   │   ├── config_spec.lua      # Configuration tests
│   │   ├── keymaps_spec.lua     # Keymap binding tests
│   │   └── options_spec.lua     # Options validation tests
│   ├── integration/             # Integration tests
│   │   ├── plugin_loading_spec.lua
│   │   ├── lsp_integration_spec.lua
│   │   └── ai_workflow_spec.lua
│   ├── workflows/               # Workflow-specific tests
│   │   ├── zettelkasten_spec.lua
│   │   ├── ai_sembr_spec.lua
│   │   ├── prose_writing_spec.lua
│   │   └── [... 11 more workflow dirs]
│   ├── neurodiversity/          # Neurodiversity feature tests
│   │   ├── auto_save_spec.lua
│   │   ├── auto_session_spec.lua
│   │   ├── window_manager_spec.lua
│   │   └── trouble_integration_spec.lua
│   ├── performance/             # Performance benchmarks
│   │   ├── startup_spec.lua
│   │   ├── memory_spec.lua
│   │   └── plugin_loading_spec.lua
│   └── e2e/                     # End-to-end tests
│       ├── writing_workflow_spec.lua
│       ├── knowledge_management_spec.lua
│       └── publishing_workflow_spec.lua
├── fixtures/                     # Test data and mocks
│   ├── mock_vault/              # Mock Zettelkasten vault
│   ├── sample_documents/        # Test documents
│   └── plugin_stubs/            # Plugin mocks
├── helpers/                      # Test utilities
│   ├── init.lua                 # Common test helpers
│   ├── assertions.lua           # Custom assertions
│   ├── mocks.lua               # Mock factories
│   └── async.lua               # Async test utilities
├── minimal_init.lua             # Minimal Neovim config for testing
├── run-plenary.sh              # Test runner script
└── Makefile                    # Test automation
```

## Test Categories

### 1. Unit Tests (`tests/plenary/unit/`)

**Purpose**: Test individual components in isolation

```lua
-- tests/plenary/unit/config_spec.lua
describe("Config Module", function()
  local config

  before_each(function()
    -- Reset module state
    package.loaded['config'] = nil
    config = require('config')
  end)

  describe("initialization", function()
    it("loads without errors", function()
      assert.is_not_nil(config)
      assert.is_table(config)
    end)

    it("sets correct default values", function()
      assert.equals(vim.o.spell, true)
      assert.equals(vim.o.wrap, true)
      assert.equals(vim.g.mapleader, " ")
    end)
  end)

  describe("lazy.nvim bootstrap", function()
    it("installs lazy.nvim if missing", function()
      -- Mock vim.fn.stdpath
      local stub_stdpath = stub(vim.fn, "stdpath")
      stub_stdpath.returns("/test/path")

      config.bootstrap_lazy()

      assert.stub(stub_stdpath).was_called_with("data")
      stub_stdpath:revert()
    end)
  end)
end)
```

### 2. Integration Tests (`tests/plenary/integration/`)

**Purpose**: Test component interactions and plugin dependencies

```lua
-- tests/plenary/integration/plugin_loading_spec.lua
describe("Plugin Loading", function()
  local lazy

  before_each(function()
    lazy = require('lazy')
  end)

  it("loads exactly 81 plugins", function()
    local plugins = lazy.plugins()
    assert.equals(81, #plugins)
  end)

  it("respects dependency order", function()
    local telescope = lazy.plugins()['telescope.nvim']
    local plenary = lazy.plugins()['plenary.nvim']

    assert.is_not_nil(telescope)
    assert.is_not_nil(plenary)
    assert.contains(telescope.dependencies, 'plenary.nvim')
  end)

  it("lazy loads plugins correctly", function()
    local zen_mode = lazy.plugins()['zen-mode.nvim']
    assert.equals('VeryLazy', zen_mode.event)
    assert.is_false(zen_mode.loaded)
  end)
end)
```

### 3. Workflow Tests (`tests/plenary/workflows/`)

**Purpose**: Test complete workflow categories

```lua
-- tests/plenary/workflows/zettelkasten_spec.lua
describe("Zettelkasten Workflow", function()
  local telekasten
  local mock_vault

  before_each(function()
    -- Setup mock vault
    mock_vault = require('tests.fixtures.mock_vault')
    mock_vault.setup()

    telekasten = require('telekasten')
  end)

  after_each(function()
    mock_vault.teardown()
  end)

  describe("note creation", function()
    it("creates new note with timestamp ID", function()
      local note = telekasten.new_note()
      assert.matches("%d%d%d%d%d%d%d%d%d%d%d%d", note.id)
      assert.is_file(note.path)
    end)

    it("applies template correctly", function()
      local note = telekasten.new_note({ template = "research" })
      local content = vim.fn.readfile(note.path)
      assert.contains(content, "# Research Note")
    end)
  end)

  describe("linking", function()
    it("creates wiki-style links", function()
      local link = telekasten.create_link("Test Note")
      assert.equals("[[Test Note]]", link)
    end)

    it("finds backlinks", function()
      local backlinks = telekasten.find_backlinks("202301011200")
      assert.is_table(backlinks)
      assert.is_true(#backlinks > 0)
    end)
  end)
end)
```

### 4. Neurodiversity Tests (`tests/plenary/neurodiversity/`)

**Purpose**: Validate ADHD/autism optimizations

```lua
-- tests/plenary/neurodiversity/auto_save_spec.lua
describe("Auto-save Protection", function()
  local auto_save

  before_each(function()
    auto_save = require('auto-save')
  end)

  it("saves on focus loss", function()
    local spy_save = spy.on(vim.cmd, "write")

    -- Simulate focus loss
    vim.api.nvim_exec_autocmds("FocusLost", {})

    assert.spy(spy_save).was_called()
    spy_save:revert()
  end)

  it("saves after idle period", function()
    local co = coroutine.running()
    local spy_save = spy.on(vim.cmd, "write")

    -- Simulate idle
    vim.defer_fn(function()
      coroutine.resume(co)
    end, auto_save.config.idle_time + 100)

    coroutine.yield()

    assert.spy(spy_save).was_called()
    spy_save:revert()
  end)

  it("respects debounce settings", function()
    local spy_save = spy.on(vim.cmd, "write")

    -- Rapid changes
    for i = 1, 10 do
      vim.api.nvim_exec_autocmds("TextChanged", {})
    end

    -- Should only save once
    assert.spy(spy_save).was_called(1)
    spy_save:revert()
  end)
end)
```

### 5. Performance Tests (`tests/plenary/performance/`)

**Purpose**: Benchmark and validate performance targets

```lua
-- tests/plenary/performance/startup_spec.lua
describe("Startup Performance", function()
  it("loads in under 100ms", function()
    local start_time = vim.fn.reltime()

    -- Force reload all modules
    for name, _ in pairs(package.loaded) do
      if name:match("^config") or name:match("^plugins") then
        package.loaded[name] = nil
      end
    end

    require('config')

    local elapsed = vim.fn.reltimefloat(vim.fn.reltime(start_time)) * 1000
    assert.is_true(elapsed < 100, "Startup took " .. elapsed .. "ms")
  end)

  it("uses less than 50MB memory", function()
    collectgarbage('collect')
    local memory_kb = collectgarbage('count')
    local memory_mb = memory_kb / 1024

    assert.is_true(memory_mb < 50, "Memory usage: " .. memory_mb .. "MB")
  end)

  it("lazy loads 90% of plugins", function()
    local lazy = require('lazy')
    local plugins = lazy.plugins()
    local loaded = 0
    local total = 0

    for _, plugin in pairs(plugins) do
      total = total + 1
      if plugin.loaded then
        loaded = loaded + 1
      end
    end

    local lazy_ratio = 1 - (loaded / total)
    assert.is_true(lazy_ratio > 0.9, "Only " .. (lazy_ratio * 100) .. "% lazy loaded")
  end)
end)
```

## Test Helpers

### Common Assertions (`tests/helpers/assertions.lua`)

```lua
local M = {}

-- Custom assertion for file existence
function M.assert_file_exists(path)
  local stat = vim.loop.fs_stat(path)
  assert.is_not_nil(stat, "File does not exist: " .. path)
  assert.equals("file", stat.type, path .. " is not a file")
end

-- Assert plugin is loaded
function M.assert_plugin_loaded(name)
  local lazy = require('lazy')
  local plugin = lazy.plugins()[name]
  assert.is_not_nil(plugin, "Plugin not found: " .. name)
  assert.is_true(plugin.loaded, "Plugin not loaded: " .. name)
end

-- Assert keybinding exists
function M.assert_keymap_exists(mode, lhs)
  local keymaps = vim.api.nvim_get_keymap(mode)
  local found = false
  for _, keymap in ipairs(keymaps) do
    if keymap.lhs == lhs then
      found = true
      break
    end
  end
  assert.is_true(found, "Keymap not found: " .. mode .. " " .. lhs)
end

return M
```

### Mock Factories (`tests/helpers/mocks.lua`)

```lua
local M = {}

-- Mock LSP client
function M.mock_lsp_client()
  return {
    name = "test_lsp",
    id = 1,
    server_capabilities = {
      completionProvider = true,
      hoverProvider = true,
      definitionProvider = true,
    },
    request = function(method, params, callback)
      callback(nil, { result = "mock" })
    end,
  }
end

-- Mock vault for Zettelkasten tests
function M.mock_vault(path)
  path = path or "/tmp/test_vault"

  return {
    path = path,
    setup = function()
      vim.fn.mkdir(path, "p")
      vim.fn.mkdir(path .. "/daily", "p")
      vim.fn.mkdir(path .. "/templates", "p")
    end,
    teardown = function()
      vim.fn.delete(path, "rf")
    end,
    create_note = function(name, content)
      local note_path = path .. "/" .. name .. ".md"
      vim.fn.writefile(vim.split(content, "\n"), note_path)
      return note_path
    end,
  }
end

return M
```

## Test Runner Configuration

### Minimal Init (`tests/minimal_init.lua`)

```lua
-- Minimal configuration for test environment
vim.opt.rtp:append('.')
vim.opt.packpath:append('.')

-- Bootstrap lazy.nvim for tests
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if vim.fn.isdirectory(lazypath) == 0 then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load only essential plugins for testing
require("lazy").setup({
  { "nvim-lua/plenary.nvim" },
  -- Add other test dependencies here
}, {
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-- Add test helpers to path
vim.opt.rtp:append('tests')
```

### Makefile (`tests/Makefile`)

```makefile
# PercyBrain Plenary Testing Makefile

.PHONY: test test-unit test-integration test-workflows test-performance test-watch coverage clean

NVIM := nvim
TEST_DIR := tests/plenary
MINIMAL_INIT := tests/minimal_init.lua

# Run all tests
test:
	@echo "Running all tests..."
	@$(NVIM) --headless -u $(MINIMAL_INIT) \
		-c "PlenaryBustedDirectory $(TEST_DIR) { minimal_init = '$(MINIMAL_INIT)' }"

# Run unit tests only
test-unit:
	@echo "Running unit tests..."
	@$(NVIM) --headless -u $(MINIMAL_INIT) \
		-c "PlenaryBustedDirectory $(TEST_DIR)/unit { minimal_init = '$(MINIMAL_INIT)' }"

# Run integration tests
test-integration:
	@echo "Running integration tests..."
	@$(NVIM) --headless -u $(MINIMAL_INIT) \
		-c "PlenaryBustedDirectory $(TEST_DIR)/integration { minimal_init = '$(MINIMAL_INIT)' }"

# Run workflow tests
test-workflows:
	@echo "Running workflow tests..."
	@$(NVIM) --headless -u $(MINIMAL_INIT) \
		-c "PlenaryBustedDirectory $(TEST_DIR)/workflows { minimal_init = '$(MINIMAL_INIT)' }"

# Run performance benchmarks
test-performance:
	@echo "Running performance benchmarks..."
	@$(NVIM) --headless -u $(MINIMAL_INIT) \
		-c "PlenaryBustedDirectory $(TEST_DIR)/performance { minimal_init = '$(MINIMAL_INIT)' }"

# Run tests in watch mode
test-watch:
	@echo "Starting test watcher..."
	@while true; do \
		clear; \
		$(MAKE) test; \
		inotifywait -q -e modify -r $(TEST_DIR) ../lua/; \
	done

# Generate coverage report
coverage:
	@echo "Generating coverage report..."
	@$(NVIM) --headless -u $(MINIMAL_INIT) \
		-c "lua require('plenary.test_harness').test_directory('$(TEST_DIR)', { minimal_init = '$(MINIMAL_INIT)', coverage = true })"

# Clean test artifacts
clean:
	@echo "Cleaning test artifacts..."
	@rm -rf tests/fixtures/mock_vault/*
	@rm -f tests/*.log
```

## CI/CD Integration

### GitHub Actions Workflow (`.github/workflows/test.yml`)

```yaml
name: Tests

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        neovim_version: ['v0.8.0', 'v0.9.0', 'nightly']

    steps:
    - uses: actions/checkout@v3

    - name: Install Neovim
      uses: rhysd/action-setup-vim@v1
      with:
        neovim: true
        version: ${{ matrix.neovim_version }}

    - name: Install dependencies
      run: |
        # Install language servers
        cargo install iwe
        pip install sembr

        # Install Ollama
        curl -fsSL https://ollama.com/install.sh | sh
        ollama pull llama3.2

    - name: Run tests
      run: |
        cd tests
        make test

    - name: Run performance benchmarks
      run: |
        cd tests
        make test-performance

    - name: Upload coverage
      if: matrix.neovim_version == 'nightly'
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage/lcov.info
```

## Usage Examples

### Running Tests Locally

```bash
# Run all tests
./tests/run-plenary.sh

# Run specific test file
nvim --headless -c "PlenaryBustedFile tests/plenary/unit/config_spec.lua"

# Run tests with Makefile
cd tests && make test

# Run specific category
cd tests && make test-unit
cd tests && make test-performance

# Watch mode for development
cd tests && make test-watch
```

### Writing New Tests

```lua
-- tests/plenary/unit/new_feature_spec.lua
local helpers = require('tests.helpers')
local assertions = require('tests.helpers.assertions')

describe("New Feature", function()
  local feature

  -- Setup
  before_each(function()
    feature = require('new_feature')
  end)

  -- Teardown
  after_each(function()
    feature.cleanup()
  end)

  -- Test cases
  it("should initialize correctly", function()
    assert.is_not_nil(feature)
    assert.is_function(feature.setup)
  end)

  it("should handle edge cases", function()
    local result = feature.process(nil)
    assert.is_nil(result)
  end)

  -- Async test
  it("should work asynchronously", function()
    local co = coroutine.running()

    feature.async_operation(function(result)
      assert.equals("expected", result)
      coroutine.resume(co)
    end)

    coroutine.yield()
  end)
end)
```

## Quality Standards

### Test Coverage Requirements
- **Unit Tests**: 80% minimum coverage
- **Integration Tests**: Critical paths covered
- **Performance Tests**: All benchmarks passing
- **Neurodiversity Features**: 100% coverage

### Test Naming Conventions
- Files: `*_spec.lua` suffix
- Describe blocks: Module or feature name
- It blocks: "should" + specific behavior

### Assertion Best Practices
- Use specific assertions (`assert.equals` vs `assert.is_true`)
- Include meaningful error messages
- Test both success and failure cases
- Verify side effects explicitly

## Implementation Roadmap

### Phase 1: Foundation (Week 1)
- [x] Set up Plenary test structure
- [x] Create test runner script
- [ ] Implement test helpers and assertions
- [ ] Create minimal_init.lua
- [ ] Set up Makefile

### Phase 2: Core Tests (Week 2)
- [ ] Unit tests for config modules
- [ ] Integration tests for plugin loading
- [ ] Neurodiversity feature tests
- [ ] Performance benchmarks

### Phase 3: Workflow Tests (Week 3)
- [ ] Zettelkasten workflow tests
- [ ] AI-assisted writing tests
- [ ] Publishing workflow tests
- [ ] LSP integration tests

### Phase 4: CI/CD Integration (Week 4)
- [ ] GitHub Actions workflow
- [ ] Coverage reporting
- [ ] Performance regression detection
- [ ] Documentation updates

## Conclusion

This Plenary-based testing architecture provides:
- **Comprehensive Coverage**: Unit, integration, workflow, and performance tests
- **Neurodiversity Focus**: Dedicated tests for ADHD/autism features
- **Developer Experience**: Watch mode, custom assertions, mock utilities
- **CI/CD Ready**: Headless execution, coverage reporting, matrix testing
- **Maintainable Structure**: Clear organization, reusable helpers, consistent patterns

The design leverages Plenary.nvim's existing capabilities while maintaining PercyBrain's unique requirements and philosophy.