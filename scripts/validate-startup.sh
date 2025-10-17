#!/bin/bash
#
# OVIWrite Layer 3 Validation: Startup Test
# Tests: Neovim starts without errors, config loads successfully
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Layer 3: Startup Validation${NC}"
echo "========================================"
echo ""

# Create isolated test environment
TEST_HOME="/tmp/nvim-test-$$"
mkdir -p "$TEST_HOME/.config/nvim"
mkdir -p "$TEST_HOME/.local/share/nvim"
mkdir -p "$TEST_HOME/.cache/nvim"

echo -e "${BLUE}📁 Creating isolated test environment:${NC} $TEST_HOME"

# Copy config to test environment
cp -r "$PROJECT_ROOT"/* "$TEST_HOME/.config/nvim/" 2>/dev/null || true

# Create startup test script
cat > "$TEST_HOME/startup-test.lua" <<'EOF'
-- Startup validation script
local success = true
local errors = {}

-- Try loading main config
local ok, err = pcall(function()
  require('config')
end)

if not ok then
  table.insert(errors, "Failed to load config: " .. tostring(err))
  success = false
end

-- Check if lazy.nvim is available
local lazy_ok = pcall(require, 'lazy')
if not lazy_ok then
  table.insert(errors, "lazy.nvim not found")
  success = false
end

-- Print results
if success then
  print("STARTUP_SUCCESS")
else
  print("STARTUP_FAILED")
  for _, error_msg in ipairs(errors) do
    print("ERROR: " .. error_msg)
  end
end

-- Exit
vim.cmd('quit')
EOF

# Run Neovim startup test
echo -e "${BLUE}🔄 Running Neovim startup...${NC}"
echo ""

LOG_FILE="$TEST_HOME/startup-log.txt"

HOME="$TEST_HOME" \
XDG_CONFIG_HOME="$TEST_HOME/.config" \
XDG_DATA_HOME="$TEST_HOME/.local/share" \
XDG_CACHE_HOME="$TEST_HOME/.cache" \
  nvim --headless \
    -u "$TEST_HOME/.config/nvim/init.lua" \
    -l "$TEST_HOME/startup-test.lua" \
    > "$LOG_FILE" 2>&1

EXIT_CODE=$?

# Check results
echo "Startup log:"
echo "----------------------------------------"
cat "$LOG_FILE"
echo "----------------------------------------"
echo ""

SUCCESS_FOUND=false
ERROR_FOUND=false

if grep -q "STARTUP_SUCCESS" "$LOG_FILE"; then
  SUCCESS_FOUND=true
fi

if grep -qi "error\|fail" "$LOG_FILE"; then
  ERROR_FOUND=true
fi

# Determine result
if [ "$SUCCESS_FOUND" = true ] && [ "$ERROR_FOUND" = false ]; then
  echo -e "${GREEN}✅ Startup validation passed${NC}"
  echo -e "${GREEN}   Neovim started successfully with zero errors${NC}"

  # Cleanup
  rm -rf "$TEST_HOME"
  exit 0
else
  echo -e "${RED}❌ Startup validation failed${NC}"

  if [ "$SUCCESS_FOUND" = false ]; then
    echo -e "${RED}   Did not find STARTUP_SUCCESS marker${NC}"
  fi

  if [ "$ERROR_FOUND" = true ]; then
    echo -e "${RED}   Errors detected in startup log${NC}"
    echo ""
    echo "Error details:"
    grep -i "error\|fail" "$LOG_FILE" || true
  fi

  echo ""
  echo -e "${YELLOW}💡 Debug: Full log saved to: $LOG_FILE${NC}"
  echo -e "${YELLOW}   (Not cleaning up test environment for debugging)${NC}"

  exit 1
fi
