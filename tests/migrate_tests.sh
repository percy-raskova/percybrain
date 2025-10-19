#!/bin/bash
# Test Migration Script - Transition to Kent Beck Testing Framework
# This script helps migrate existing tests to the new architecture

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}    PercyBrain Test Migration to Kent Beck Framework${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Create new directory structure
echo -e "${YELLOW}Creating new test directory structure...${NC}"

mkdir -p tests/contract
mkdir -p tests/capability/{zettelkasten,ai,ui,prose,navigation}
mkdir -p tests/regression
mkdir -p tests/integration
mkdir -p specs

echo -e "${GREEN}✅ Directory structure created${NC}"

# Analyze existing tests
echo ""
echo -e "${YELLOW}Analyzing existing tests...${NC}"

# Count existing tests
EXISTING_TESTS=$(find tests/plenary -name "*_spec.lua" 2>/dev/null | wc -l)
echo "Found $EXISTING_TESTS existing test files"

# Migration mapping
declare -A MIGRATION_MAP=(
  # Contract tests (validate against spec)
  ["tests/plenary/unit/config_spec.lua"]="tests/contract/config_contract_spec.lua"
  ["tests/plenary/unit/globals_spec.lua"]="tests/contract/globals_contract_spec.lua"

  # Capability tests (what users can do)
  ["tests/plenary/unit/zettelkasten/config_spec.lua"]="tests/capability/zettelkasten/config_capabilities_spec.lua"
  ["tests/plenary/unit/zettelkasten/link_analysis_spec.lua"]="tests/capability/zettelkasten/linking_capabilities_spec.lua"
  ["tests/plenary/workflows/zettelkasten_spec.lua"]="tests/capability/zettelkasten/workflow_capabilities_spec.lua"
  ["tests/plenary/unit/ai-sembr/ollama_spec.lua"]="tests/capability/ai/ollama_capabilities_spec.lua"
  ["tests/plenary/unit/sembr/formatter_spec.lua"]="tests/capability/ai/sembr_capabilities_spec.lua"
  ["tests/plenary/unit/sembr/integration_spec.lua"]="tests/integration/sembr_integration_spec.lua"
  ["tests/plenary/unit/window-manager_spec.lua"]="tests/capability/ui/window_management_spec.lua"
  ["tests/plenary/unit/keymaps_spec.lua"]="tests/capability/navigation/keymaps_spec.lua"

  # Regression tests (protect critical settings)
  ["tests/plenary/unit/options_spec.lua"]="tests/regression/options_protection_spec.lua"
  ["tests/plenary/unit/options_spec_fixed.lua"]="tests/regression/options_protection_fixed_spec.lua"

  # Performance tests
  ["tests/plenary/performance/startup_spec.lua"]="tests/capability/performance/startup_spec.lua"

  # Core tests
  ["tests/plenary/core_spec.lua"]="tests/contract/core_contract_spec.lua"
)

# Create migration report
echo ""
echo -e "${YELLOW}Migration Plan:${NC}"
echo "────────────────────────────────────────────────"

for old_path in "${!MIGRATION_MAP[@]}"; do
  new_path="${MIGRATION_MAP[$old_path]}"
  if [ -f "$old_path" ]; then
    echo -e "${BLUE}Migrate:${NC} $(basename $old_path)"
    echo -e "  From: $old_path"
    echo -e "  To:   $new_path"
    echo ""
  fi
done

# Ask for confirmation
echo ""
read -p "Do you want to proceed with migration? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Migration cancelled"
  exit 0
fi

# Perform migration
echo ""
echo -e "${YELLOW}Migrating tests...${NC}"

MIGRATED=0
FAILED=0

for old_path in "${!MIGRATION_MAP[@]}"; do
  new_path="${MIGRATION_MAP[$old_path]}"
  if [ -f "$old_path" ]; then
    # Create directory if needed
    new_dir=$(dirname "$new_path")
    mkdir -p "$new_dir"

    # Copy file with transformation hints
    cp "$old_path" "$new_path"

    # Add migration header to help with updates
    cat > "$new_path.tmp" << 'EOF'
-- MIGRATION NOTE: This test has been migrated from the old structure
-- Please update according to Kent Beck testing principles:
-- 1. Test capabilities, not configuration
-- 2. Use helpers from tests/helpers/test_framework.lua
-- 3. Provide actionable failure messages
-- Original file: OLD_PATH

EOF
    echo "-- Original file: $old_path" | sed 's/OLD_PATH/'$old_path'/' >> "$new_path.tmp"
    cat "$new_path" >> "$new_path.tmp"
    mv "$new_path.tmp" "$new_path"

    echo -e "${GREEN}✅ Migrated:${NC} $(basename $old_path) → $(basename $new_path)"
    ((MIGRATED++))
  else
    echo -e "${RED}⚠️  Not found:${NC} $old_path"
    ((FAILED++))
  fi
done

# Create example conversion script
echo ""
echo -e "${YELLOW}Creating test conversion examples...${NC}"

cat > tests/CONVERSION_EXAMPLES.md << 'EOF'
# Test Conversion Examples

## Configuration Test → Contract Test

### Before (Configuration Test):
```lua
it("enables spell checking by default", function()
  require("config.options")
  local spell_enabled = vim.opt.spell:get()
  assert.is_true(spell_enabled)
end)
```

### After (Contract Test):
```lua
it("provides spell checking capability as per contract", function()
  local contract = require('specs.percybrain_contract')

  -- Verify against contract specification
  assert.is_true(
    contract.REQUIRED.writing_environment.settings.spell,
    "Contract requires spell checking to be enabled"
  )

  -- Verify implementation matches contract
  require("config.options")
  assert.equals(
    vim.opt.spell:get(),
    contract.REQUIRED.writing_environment.settings.spell,
    "Implementation must match contract specification"
  )
end)
```

## Configuration Test → Capability Test

### Before (Configuration Test):
```lua
it("sets hlsearch to false", function()
  require("config.options")
  assert.is_false(vim.opt.hlsearch:get())
end)
```

### After (Capability Test):
```lua
it("CAN search without visual noise", function()
  local helpers = require('tests.helpers.test_framework')

  helpers.assert_can("search without highlighting", function()
    -- Search for a pattern
    vim.cmd('normal /test<CR>')

    -- Verify no highlighting disturbs the view
    return vim.opt.hlsearch:get() == false
  end, "Users should be able to search without visual distractions")
end)
```

## Setting Test → Regression Test

### Before (Setting Test):
```lua
it("has hlsearch disabled", function()
  assert.is_false(vim.opt.hlsearch:get())
end)
```

### After (Regression Test):
```lua
it("NEVER enables search highlighting (ADHD protection)", function()
  local helpers = require('tests.helpers.test_framework')
  local regression = helpers.Regression:new("ADHD Optimizations")

  regression:protect_setting(
    'hlsearch',
    false,
    "Search highlighting creates visual noise that disrupts ADHD focus"
  )

  local violations = regression:validate()
  assert.equals(0, #violations,
    "Critical ADHD optimization violated: " .. vim.inspect(violations))
end)
```

## Multi-file Test → Integration Test

### Before:
```lua
it("integrates sembr with completion", function()
  -- Complex test across multiple components
end)
```

### After:
```lua
describe("SemBr Integration", function()
  it("WORKS across AI and completion systems", function()
    local helpers = require('tests.helpers.test_framework')

    helpers.assert_works("AI-completion integration", function()
      -- Test actual integration behavior
      local ai_response = ai.complete("test")
      local completion_items = completion.process(ai_response)
      return #completion_items > 0
    end, "AI and completion should work together seamlessly")
  end)
end)
```
EOF

echo -e "${GREEN}✅ Created CONVERSION_EXAMPLES.md${NC}"

# Update test runner
echo ""
echo -e "${YELLOW}Updating test configuration...${NC}"

# Check if backup of mise.toml exists
if [ ! -f ".mise.toml.backup" ]; then
  cp .mise.toml .mise.toml.backup
  echo -e "${GREEN}✅ Backed up .mise.toml to .mise.toml.backup${NC}"
fi

# Summary
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}                    Migration Summary${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "Tests migrated:  ${GREEN}$MIGRATED${NC}"
echo -e "Tests not found: ${YELLOW}$FAILED${NC}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Review migrated tests in new directories"
echo "2. Update tests to follow Kent Beck patterns (see CONVERSION_EXAMPLES.md)"
echo "3. Copy .mise.toml.new to .mise.toml for new test commands"
echo "4. Run 'mise test:quick' to verify basic functionality"
echo "5. Gradually convert tests to capability/contract/regression patterns"
echo ""
echo -e "${YELLOW}New Commands:${NC}"
echo "  mise test         - Run all tests"
echo "  mise test:quick   - Fast feedback (contract + regression)"
echo "  mise test:watch   - Watch mode"
echo "  mise tc           - Contract tests"
echo "  mise tcap         - Capability tests"
echo "  mise tr           - Regression tests"
echo ""
echo -e "${GREEN}Migration preparation complete!${NC}"
echo "The old tests remain in place - remove them once new tests are verified."
