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

# Auto-discover all keymap tests (alphabetically sorted)
# New test files are automatically included without manual updates
keymap_test_paths=$(find tests/unit/keymap -name "*_spec.lua" -type f | sort)

total_tests=0
passed=0
failed=0

# Count total tests
for path in $keymap_test_paths; do
  ((total_tests++))
done

# Run each test file
for test_path in $keymap_test_paths; do
  test_file=$(basename "$test_path")
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
