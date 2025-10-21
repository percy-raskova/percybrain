#!/usr/bin/env bash
# Test runner for keymap centralization test suite
# Runs all tests in tests/unit/keymap/ directory

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "Running Keymap Centralization Test Suite..."
echo "==========================================="

# Array of test files
test_files=(
  "cleanup_spec.lua"
  "loading_spec.lua"
  "registry_spec.lua"
  "syntax_spec.lua"
  "namespace_spec.lua"
)

total_tests=${#test_files[@]}
passed=0
failed=0

# Run each test file
for test_file in "${test_files[@]}"; do
  echo ""
  echo "Running: $test_file"

  if nvim --headless -u tests/minimal_init.lua \
    -c "PlenaryBustedFile tests/unit/keymap/$test_file" 2>&1 | grep -q "Success"; then
    echo -e "${GREEN}✓ PASSED${NC}"
    ((passed++))
  else
    echo -e "${RED}✗ FAILED${NC}"
    ((failed++))
  fi
done

echo ""
echo "==========================================="
echo "Results: $passed/$total_tests passed"

if [ $failed -eq 0 ]; then
  echo -e "${GREEN}All tests passed!${NC}"
  exit 0
else
  echo -e "${RED}$failed test(s) failed${NC}"
  exit 1
fi
