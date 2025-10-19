#!/bin/bash
# PercyBrain Plenary Test Runner
# Runs Lua tests using Plenary.nvim (already installed via Telescope)

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

NVIM_CONFIG="${NVIM_CONFIG:-$HOME/.config/nvim}"

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  PercyBrain Plenary Test Suite${NC}"
echo -e "${BLUE}  Using Existing Tooling (Plenary.nvim)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if Plenary is installed
if [ ! -d "$HOME/.local/share/nvim/lazy/plenary.nvim" ]; then
    echo -e "${RED}✗${NC} Plenary.nvim not found. Install Telescope to get it as dependency."
    exit 1
fi

echo -e "${GREEN}✓${NC} Plenary.nvim found (via Telescope dependency)"
echo ""

# Function to run a single test file
run_test_file() {
    local test_file="$1"
    local test_name=$(basename "$test_file" .lua)

    echo -e "${YELLOW}▶ Running: ${test_name}${NC}"

    if nvim --headless -c "PlenaryBustedFile $test_file" -c "qall" 2>&1; then
        echo -e "  ${GREEN}✓${NC} $test_name passed"
        return 0
    else
        echo -e "  ${RED}✗${NC} $test_name failed"
        return 1
    fi
}

# Function to run all tests in a directory
run_all_tests() {
    local test_dir="$NVIM_CONFIG/tests/plenary"
    local total_tests=0
    local passed_tests=0
    local failed_tests=0

    if [ ! -d "$test_dir" ]; then
        echo -e "${YELLOW}⚠${NC} No Plenary tests found in $test_dir"
        echo "  Creating test directory..."
        mkdir -p "$test_dir"
    fi

    # Find all *_spec.lua files
    for test_file in "$test_dir"/*_spec.lua; do
        if [ -f "$test_file" ]; then
            total_tests=$((total_tests + 1))
            if run_test_file "$test_file"; then
                passed_tests=$((passed_tests + 1))
            else
                failed_tests=$((failed_tests + 1))
            fi
            echo ""
        fi
    done

    # Summary
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  Test Summary${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "Total Test Files: $total_tests"
    echo "Passed: $passed_tests"
    echo "Failed: $failed_tests"

    if [ "$failed_tests" -eq 0 ] && [ "$total_tests" -gt 0 ]; then
        echo ""
        echo -e "${GREEN}✅ ALL TESTS PASSED${NC}"
        echo -e "${GREEN}   Following the Percyism: 'If tooling exists, and it works, use it'${NC}"
        return 0
    elif [ "$total_tests" -eq 0 ]; then
        echo ""
        echo -e "${YELLOW}⚠ NO TESTS FOUND${NC}"
        return 1
    else
        echo ""
        echo -e "${RED}❌ TESTS FAILED${NC}"
        return 1
    fi
}

# Main execution
case "${1:-all}" in
    all)
        run_all_tests
        ;;
    *)
        # Run specific test file
        if [ -f "$1" ]; then
            run_test_file "$1"
        else
            echo -e "${RED}✗${NC} Test file not found: $1"
            exit 1
        fi
        ;;
esac