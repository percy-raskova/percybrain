# PercyBrain Neovim Testing Framework Analysis

**By Kent Beck - Test-Driven Development Expert** **Date: 2025-10-19**

## Executive Summary

Your testing framework shows **solid fundamentals** with excellent coverage (82%) and good architectural patterns. However, you're experiencing the classic "testing configuration vs. behavior" challenge. Your failures aren't bugs - they're **expectation mismatches** between test assumptions and actual configuration choices.

**Key Finding**: You're testing that options match a specification that doesn't exist. The tests expect certain defaults, but `options.lua` deliberately sets different values for valid reasons.

## Architecture Assessment

### Strengths ✅

1. **BDD Style with AAA Pattern**: Excellent choice! The describe/it blocks with Arrange-Act-Assert make tests readable and maintainable.

2. **Six Enforced Standards**: Your standards are **nearly perfect**:

   - ✅ Helper/mock imports when used
   - ✅ before_each/after_each setup
   - ✅ AAA comments
   - ✅ No \_G pollution
   - ✅ Local helper functions
   - ✅ No raw assert.contains

   **Missing**: Consider adding "Test names must start with a verb" (e.g., "should enable spell checking")

3. **Test Organization**: The unit/workflows/performance separation is clean and logical.

4. **139% Test/Code Ratio**: This is healthy for a configuration project where behavior is critical.

### Weaknesses ❌

1. **Configuration Testing Philosophy**: You're testing Vim's state, not your code's behavior. This creates environment dependencies.

2. **Missing Contract Tests**: No specification exists for what options SHOULD be set.

3. **Mock Overuse**: Comprehensive Vim API mocking might hide real integration issues.

## Root Cause Analysis of Failures

### Pattern 1: Testing Unset Options

```lua
-- Test expects:
opt.linebreak = true  -- Word boundary breaks
-- Reality:
-- options.lua doesn't set this at all!
```

**Problem**: Tests assume options that were never configured.

### Pattern 2: Testing Different Values

```lua
-- Test expects:
opt.hlsearch = true   -- Search highlighting on
-- Reality in options.lua:
opt.hlsearch = false  -- Deliberately turned off for focus
```

**Problem**: Tests don't respect intentional configuration choices.

### Pattern 3: Testing Vim Defaults vs. Custom

```lua
-- Test expects:
opt.expandtab = true  -- Use spaces not tabs
-- Reality:
-- Not set in options.lua, so uses Vim default (false)
```

## Immediate Fixes

### Fix 1: Create a Configuration Contract

First, define what you ACTUALLY want:

```lua
-- lua/config/options_spec.lua (NEW FILE - the contract)
return {
  -- Writer-focused
  spell = true,
  spelllang = "en",
  wrap = true,
  linebreak = true,  -- ADD to options.lua if you want word boundaries

  -- Search
  incsearch = true,
  ignorecase = true,
  smartcase = true,
  hlsearch = false,  -- Intentionally false for focus

  -- Editor
  number = true,
  relativenumber = true,
  scrolloff = 10,    -- You set 10, not 8
  mouse = "a",       -- ADD to options.lua

  -- Files
  swapfile = false,  -- ADD to options.lua
  backup = false,    -- Already set correctly
  undofile = true,   -- ADD to options.lua

  -- Indentation
  expandtab = true,  -- ADD to options.lua
  tabstop = 2,       -- ADD to options.lua
  shiftwidth = 2,    -- ADD to options.lua

  -- Visual
  cursorline = true, -- ADD to options.lua
  termguicolors = true,

  -- Performance
  updatetime = 250,  -- ADD to options.lua
  timeoutlen = 300,  -- ADD to options.lua

  -- Completion
  completeopt = "menuone,noselect",
  pumheight = 15,    -- ADD to options.lua

  -- ADHD/Autism
  showmode = false,  -- ADD to options.lua
  fillchars = { vert = "│", horiz = "─" }, -- ADD to options.lua
}
```

### Fix 2: Update options.lua

```lua
-- lua/config/options.lua (UPDATED)
local opt = vim.opt

-- Indentation
opt.expandtab = true      -- Use spaces not tabs
opt.tabstop = 2          -- 2 spaces per tab
opt.shiftwidth = 2       -- 2 spaces for indentation
opt.smartindent = true

-- Text Display
opt.wrap = true
opt.linebreak = true     -- Break at word boundaries

-- Grammar and spell check
opt.spelllang = "en"
opt.spell = true

-- Search
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false     -- Intentionally off for focus

-- Appearance
opt.number = true
opt.relativenumber = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cmdheight = 1
opt.scrolloff = 10
opt.cursorline = true    -- Highlight current line

-- Behavior
opt.hidden = true
opt.errorbells = false
opt.splitright = true
opt.splitbelow = true
opt.autochdir = false
opt.clipboard:append("unnamedplus")
opt.modifiable = true
opt.encoding = "UTF-8"
opt.mouse = "a"          -- Enable mouse in all modes

-- File Handling
opt.swapfile = false     -- No swap files
opt.backup = false       -- No backup files
opt.undofile = true      -- Persistent undo
opt.undodir = { vim.fn.stdpath("state") .. "/undo" }

-- Performance
opt.updatetime = 250     -- Faster completion
opt.timeoutlen = 300     -- Faster key sequences
opt.lazyredraw = true    -- Don't redraw during macros

-- Completion
opt.completeopt = "menuone,noselect"
opt.pumheight = 15       -- Completion menu height

-- ADHD/Autism optimizations
opt.showmode = false     -- Mode shown in statusline
opt.fillchars = {
  vert = "│",
  horiz = "─",
  horizup = "┴",
  horizdown = "┬",
  vertleft = "┤",
  vertright = "├",
  verthoriz = "┼"
}
```

### Fix 3: Update Test to Match Reality

```lua
-- tests/plenary/unit/options_spec.lua (key changes)

describe("Options Configuration", function()
  -- Load the contract
  local expected_options = require("config.options_spec")

  before_each(function()
    package.loaded["config.options"] = nil
    require("config.options")
  end)

  it("sets all expected options", function()
    for option, expected_value in pairs(expected_options) do
      local actual = vim.opt[option]:get()
      assert.equals(
        expected_value,
        actual,
        string.format("Option %s: expected %s, got %s",
          option, vim.inspect(expected_value), vim.inspect(actual))
      )
    end
  end)
end)
```

## Watch Mode Implementation

Here's a simple, effective watch mode:

```bash
#!/usr/bin/env bash
# tests/watch.sh - Test watch mode for PercyBrain

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
WATCH_INTERVAL=${WATCH_INTERVAL:-2}  # Seconds between checks
TEST_PATTERN=${1:-"tests/plenary"}   # What to test

# Track test state
LAST_HASH=""
LAST_STATUS=0

get_file_hash() {
    find lua tests -name "*.lua" -type f -exec md5sum {} \; | sort | md5sum | cut -d' ' -f1
}

run_tests() {
    clear
    echo -e "${YELLOW}Running tests...${NC}"
    echo "═══════════════════════════════════════════"

    if ./tests/run-all-unit-tests.sh; then
        echo -e "\n${GREEN}✓ All tests passing!${NC}"
        return 0
    else
        echo -e "\n${RED}✗ Tests failed!${NC}"
        return 1
    fi
}

# Initial run
run_tests
LAST_STATUS=$?
LAST_HASH=$(get_file_hash)

echo -e "\n${YELLOW}Watching for changes... (Ctrl+C to stop)${NC}"

# Watch loop
while true; do
    sleep $WATCH_INTERVAL

    CURRENT_HASH=$(get_file_hash)

    if [ "$CURRENT_HASH" != "$LAST_HASH" ]; then
        echo -e "\n${YELLOW}Changes detected!${NC}"

        if run_tests; then
            if [ $LAST_STATUS -ne 0 ]; then
                echo -e "${GREEN}🎉 Tests fixed!${NC}"
                # Optional: notify-send "Tests Fixed" "All tests are passing!"
            fi
            LAST_STATUS=0
        else
            if [ $LAST_STATUS -eq 0 ]; then
                echo -e "${RED}💔 Tests broken!${NC}"
                # Optional: notify-send "Tests Broken" "Some tests are failing!"
            fi
            LAST_STATUS=1
        fi

        LAST_HASH=$CURRENT_HASH
        echo -e "\n${YELLOW}Watching for changes... (Ctrl+C to stop)${NC}"
    fi
done
```

Make it executable:

```bash
chmod +x tests/watch.sh
```

## Best Practices for Neovim Configuration Testing

### 1. Test Behavior, Not State

```lua
-- ❌ Bad: Testing Vim's internal state
it("enables spell checking", function()
  assert.is_true(vim.opt.spell:get())
end)

-- ✅ Good: Testing that YOUR code sets it
it("configures spell checking for prose writing", function()
  local config = require("config.options")
  assert.spy(config.setup_spell_checking).was_called()
  -- Or test the effect:
  local misspelled = vim.fn.spellbadword("teh")
  assert.is_not.equals("", misspelled[0])
end)
```

### 2. Contract-Driven Testing

Always have a specification that defines expected behavior:

- What options MUST be set
- What options are OPTIONAL
- What values are ACCEPTABLE ranges

### 3. Integration Tests Over Unit Tests for Config

```lua
-- For configuration, integration tests are MORE valuable
describe("Zettelkasten workflow", function()
  it("creates linked notes with proper formatting", function()
    -- Test the actual workflow, not individual options
  end)
end)
```

### 4. Environment Independence

```lua
-- Use test-specific initialization
before_each(function()
  -- Reset to known state
  vim.cmd("set all&")  -- Reset all options to defaults
  -- Then apply your config
  require("config.options")
end)
```

## Philosophical Insights

### Configuration vs. Application Testing

**Configuration testing is fundamentally different** from application testing:

1. **Configurations are declarations**, not behaviors
2. **User preferences matter** - not all "failures" are bugs
3. **Environment matters** - what works on Linux might not on Windows
4. **Evolution is expected** - configs change more than APIs

### The Right Testing Strategy for PercyBrain

1. **Test workflows, not options**: Can users create Zettelkasten notes?
2. **Test integrations**: Does LSP work with your config?
3. **Test performance**: Does startup stay under 100ms?
4. **Test regressions**: Did this change break existing workflows?

### My Recommendation

**Shift from "option testing" to "capability testing"**:

```lua
describe("Writing Environment", function()
  it("provides spell checking capability", function()
    -- Test that spell checking WORKS, not that option is set
    vim.cmd("normal iHello wrold")
    local bad = vim.fn.spellbadword()
    assert.not_nil(bad[0])  -- Found the typo
  end)

  it("provides distraction-free writing", function()
    -- Test the experience, not the settings
    local distractions = {
      vim.opt.showmode:get(),
      vim.opt.ruler:get(),
      vim.opt.showcmd:get()
    }
    -- At least one should be hidden
    assert.is_true(vim.tbl_contains(distractions, false))
  end)
end)
```

## Action Items

1. **Immediate**: Fix options.lua with missing settings (15 minutes)
2. **Today**: Implement watch mode (5 minutes)
3. **This Week**: Refactor tests to test capabilities, not options
4. **This Month**: Create integration test suite for workflows
5. **Ongoing**: Maintain the contract specification

## Summary

Your testing infrastructure is **fundamentally sound**. The failures aren't bugs - they're **specification mismatches**. By:

1. Adding missing options to `options.lua`
2. Creating a configuration contract
3. Testing capabilities over state
4. Implementing watch mode

You'll have a robust, maintainable test suite that actually helps development rather than hindering it.

Remember: **Tests should make the next step obvious**. When a test fails, you should know exactly what to fix. Your current tests are already doing this - they're telling you exactly which options need to be set!

______________________________________________________________________

*"Make it work, make it right, make it fast - in that order."* - Kent Beck
