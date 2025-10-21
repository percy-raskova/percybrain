#!/bin/bash
# PercyBrain Unit Test Runner
# Runs the new unit tests with Plenary

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo -e "${BLUE}     PercyBrain Unit Test Suite${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"

# Test categories
UNIT_TESTS=(
    "tests/unit/config_spec.lua"
    "tests/unit/options_spec.lua"
    "tests/unit/keymaps_spec.lua"
    "tests/unit/globals_spec.lua"
    "tests/unit/window_manager_spec.lua"
)

PERFORMANCE_TESTS=(
    "tests/performance/startup_spec.lua"
)

# Function to run a test file
run_test() {
    local test_file=$1
    local test_name=$(basename "$test_file" _spec.lua)

    echo -e "\n${YELLOW}Testing:${NC} $test_name"
    echo "────────────────────────────────"

    if nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedFile $test_file" 2>&1; then
        echo -e "${GREEN}✅ PASSED${NC}: $test_name"
        return 0
    else
        echo -e "${RED}❌ FAILED${NC}: $test_name"
        return 1
    fi
}

# Run unit tests
echo -e "\n${BLUE}Running Unit Tests...${NC}"
echo "═══════════════════════════════════════"

total_tests=0
passed_tests=0

for test in "${UNIT_TESTS[@]}"; do
    ((total_tests++))
    if run_test "$test"; then
        ((passed_tests++))
    fi
done

# Run performance benchmarks
echo -e "\n${BLUE}Running Performance Benchmarks...${NC}"
echo "═══════════════════════════════════════"

for test in "${PERFORMANCE_TESTS[@]}"; do
    ((total_tests++))
    if run_test "$test"; then
        ((passed_tests++))
    fi
done

# Summary
echo -e "\n${BLUE}═══════════════════════════════════════════════${NC}"
echo -e "${BLUE}                 TEST SUMMARY${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"

if [ $passed_tests -eq $total_tests ]; then
    echo -e "${GREEN}✅ ALL TESTS PASSED!${NC}"
    echo -e "   ${passed_tests}/${total_tests} tests passed"
    exit 0
else
    failed_tests=$((total_tests - passed_tests))
    echo -e "${RED}❌ SOME TESTS FAILED${NC}"
    echo -e "   ${passed_tests}/${total_tests} tests passed"
    echo -e "   ${failed_tests} test(s) failed"
    exit 1
fi
