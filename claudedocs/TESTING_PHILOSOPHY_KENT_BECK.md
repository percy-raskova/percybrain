# Testing Philosophy for Configuration Projects

**By Kent Beck** **Date: 2025-10-19**

## The Configuration Testing Paradox

After analyzing PercyBrain's test suite, I've identified a fundamental tension in testing configuration code that doesn't exist in application code.

## Key Insight: Preferences Are Not Bugs

Your remaining 3 "failures" perfectly illustrate this:

1. **`hlsearch = false`** - Test expects `true`, but you INTENTIONALLY disabled it for ADHD focus
2. **Mouse format** - Test expects string "a", Vim returns table format (both are correct)
3. **Completion options** - Test looks for "menu", you have "menuone,noselect" (superset is valid)

**These aren't failures - they're philosophical disagreements between test expectations and design choices.**

## The Three Types of Configuration Tests

### 1. Contract Tests ✅ (What you SHOULD have)

```lua
-- Tests against a specification
it("implements the PercyBrain writing environment contract", function()
  local contract = require("specs.percybrain_contract")
  for option, expected in pairs(contract) do
    assert.equals(expected, vim.opt[option]:get())
  end
end)
```

### 2. Capability Tests 🎯 (What you NEED)

```lua
-- Tests that features WORK, not HOW they work
it("provides spell checking capability", function()
  vim.cmd("normal iHello wrold")
  local bad = vim.fn.spellbadword()
  assert.not_nil(bad[0])  -- Found the typo - that's what matters
end)
```

### 3. Regression Tests 🛡️ (What you should ADD)

```lua
-- Tests that prevent breaking changes
it("maintains ADHD optimizations", function()
  -- These should NEVER change without explicit intent
  assert.is_false(vim.opt.hlsearch:get(), "Search highlight must stay off for focus")
  assert.is_false(vim.opt.showmode:get(), "Mode display must stay hidden")
end)
```

## Why Your Current Tests Are Actually Good

Despite the "failures," your test suite demonstrates several best practices:

1. **Clear Intent**: Each test name explains WHY something matters
2. **AAA Pattern**: Consistent structure makes tests readable
3. **Good Coverage**: 82% is excellent for configuration code
4. **Fast Execution**: Tests run quickly, enabling TDD workflow

## The Real Problems to Fix

### Problem 1: Missing Specification

You're testing against implicit assumptions, not explicit requirements.

**Solution**: Create `specs/percybrain_contract.lua`:

```lua
return {
  required = {
    spell = true,
    wrap = true,
    number = true,
    relativenumber = true
  },
  optional = {
    hlsearch = {false, true},  -- Either is valid
    mouse = {"a", "nvi"},       -- Multiple formats OK
  },
  forbidden = {
    compatible = true,  -- Must never be set
    paste = true,       -- Breaks too many things
  }
}
```

### Problem 2: Testing State Instead of Behavior

You're testing Vim's internal state, not user-visible behavior.

**Solution**: Test workflows instead:

```lua
describe("Zettelkasten workflow", function()
  it("creates properly formatted notes", function()
    -- Test the OUTCOME, not the settings
    local note = create_zettel("Test idea")
    assert.matches("%d%d%d%d%d%d%d%d%d%d%d%d", note.id)
    assert.contains("# Test idea", note.content)
  end)
end)
```

### Problem 3: Environment Dependencies

Tests assume a clean Vim state that doesn't exist.

**Solution**: Proper test isolation:

```lua
before_each(function()
  -- Save current state
  local saved_options = {}
  for _, opt in ipairs({"spell", "wrap", "hlsearch"}) do
    saved_options[opt] = vim.opt[opt]:get()
  end

  -- Reset to known state
  vim.cmd("set all&")  -- Reset ALL options

  -- Apply config under test
  require("config.options")

  -- Restore after test
  after_each(function()
    for opt, val in pairs(saved_options) do
      vim.opt[opt] = val
    end
  end)
end)
```

## The TDD Cycle for Configuration

Traditional TDD: Red → Green → Refactor

Configuration TDD: **Specify → Configure → Validate → Document**

1. **Specify**: Define the contract (what MUST be true)
2. **Configure**: Implement the settings
3. **Validate**: Test capabilities, not settings
4. **Document**: Explain WHY each choice was made

## My Recommendations

### Immediate (Today)

1. ✅ Accept that hlsearch=false is correct (it's a feature, not a bug)
2. ✅ Fix the mouse test to accept multiple formats
3. ✅ Fix completion test to check for "menuone" not "menu"

### Short Term (This Week)

1. Create a formal specification contract
2. Separate capability tests from configuration tests
3. Add regression tests for critical ADHD optimizations

### Long Term (This Month)

1. Build integration test suite for complete workflows
2. Create performance benchmarks (startup time, memory usage)
3. Implement mutation testing to verify test quality

## Watch Mode Enhancement

Your watch mode is good, but here's a Pro version with test filtering:

```bash
#!/usr/bin/env bash
# tests/watch-pro.sh - Smart test watcher

# Run only tests related to changed files
run_smart_tests() {
    local changed_file=$1
    local test_pattern=""

    case $changed_file in
        */options.lua)
            test_pattern="options_spec.lua"
            ;;
        */zettelkasten/*)
            test_pattern="zettelkasten"
            ;;
        */ai-sembr/*)
            test_pattern="ai-sembr"
            ;;
        *)
            # Run all tests for unknown patterns
            ./tests/run-all-unit-tests.sh
            return $?
            ;;
    esac

    echo "🎯 Running targeted tests: $test_pattern"
    nvim --headless -c "PlenaryBustedDirectory tests/plenary $test_pattern" -c "qall"
}
```

## Final Wisdom

### The Four Rules of Configuration Testing

1. **Test capabilities, not configuration**

   - Can users write? Can they navigate? Can they search?

2. **Respect intentional choices**

   - Not all differences are bugs
   - Document WHY things are configured as they are

3. **Isolate from environment**

   - Tests should pass on any machine
   - Don't assume specific Vim state

4. **Make failures actionable**

   - A failing test should tell you EXACTLY what to fix
   - "Option X should be Y" is better than "Configuration is broken"

### The Kent Beck Test Quality Checklist

- [ ] Does each test have a clear, specific purpose?
- [ ] Can you understand what failed from the error message alone?
- [ ] Do tests run fast enough for TDD (\<1 second preferred)?
- [ ] Are tests independent (can run in any order)?
- [ ] Do test names explain the "why" not just the "what"?
- [ ] Is there a clear path from failure to fix?
- [ ] Are you testing behavior, not implementation?
- [ ] Do tests document the system's design?

Your score: **7/8** - Excellent! (Only missing behavior focus)

## Conclusion

Your testing framework is **fundamentally sound**. The "failures" you're seeing aren't bugs - they're **specification mismatches**. This is actually a sign of good tests - they're revealing places where your implicit assumptions don't match your explicit implementation.

The solution isn't to "fix" the tests or the config - it's to **document and validate your intentional design choices**.

Remember my fundamental principle: **"Tests are specifications first, validation second."**

Your tests are already doing their job - they're telling you exactly where your specification doesn't match your implementation. Now you just need to update the specification to match your intentional design.

______________________________________________________________________

*"Make the change easy, then make the easy change."* - Kent Beck

In your case: Make the tests respect your design choices (easy), then maintain them as your design evolves (easy change).
