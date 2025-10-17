#!/bin/bash
# PercyBrain Simple Test Suite
# Ensures code is syntactically valid, formatted, and follows best practices
# This is NOT an enterprise test suite - it's pragmatic validation for a hobbyist project

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
TESTS_PASSED=0
TESTS_FAILED=0

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  PercyBrain Simple Test Suite${NC}"
echo -e "${BLUE}  Purpose: Ensure code works, not corporate compliance${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Detect if running in CI or local environment
if [ -n "${GITHUB_ACTIONS:-}" ]; then
    # In GitHub Actions, we're in the tests/ directory
    NVIM_CONFIG="$(cd .. && pwd)"
else
    # Local environment
    NVIM_CONFIG="${NVIM_CONFIG:-$HOME/.config/nvim}"
fi

#=============================================================================
# Test Functions
#=============================================================================

test_lua_syntax() {
    echo -e "${YELLOW}▶ Testing Lua Syntax${NC}"
    echo ""

    local lua_files
    lua_files=$(find "$NVIM_CONFIG/lua" -name "*.lua" 2>/dev/null)

    local syntax_errors=0

    for file in $lua_files; do
        # Use luac if available, otherwise nvim headless
        if command -v luac &> /dev/null; then
            if luac -p "$file" &> /dev/null; then
                : # Success, no output needed
            else
                echo -e "  ${RED}✗${NC} Syntax error in: $file"
                syntax_errors=$((syntax_errors + 1))
            fi
        else
            # Fall back to Neovim headless mode
            if nvim --headless -c "luafile $file" -c "qall" &> /dev/null; then
                : # Success
            else
                echo -e "  ${RED}✗${NC} Syntax error in: $file"
                syntax_errors=$((syntax_errors + 1))
            fi
        fi
    done

    if [ "$syntax_errors" -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} All Lua files have valid syntax"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "  ${RED}✗${NC} Found $syntax_errors file(s) with syntax errors"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

test_core_config_loads() {
    echo ""
    echo -e "${YELLOW}▶ Testing Core Configuration Loading${NC}"
    echo ""

    # Check if init.lua exists
    if [ ! -f "$NVIM_CONFIG/init.lua" ]; then
        echo -e "  ${RED}✗${NC} init.lua not found"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi

    # In CI, we can't fully load config (requires plugin installation)
    # Just verify the Lua files can be parsed
    if [ -n "${GITHUB_ACTIONS:-}" ]; then
        # CI: Only check if files parse without syntax errors (already done in syntax test)
        echo -e "  ${GREEN}✓${NC} Core config syntax valid (full load skipped in CI)"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    fi

    # Local: Try to load the main config with Neovim headless
    if nvim --headless -c "lua require('config')" -c "qall" 2>&1 | grep -qi "error"; then
        echo -e "  ${RED}✗${NC} Core config failed to load"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    else
        echo -e "  ${GREEN}✓${NC} Core configuration loads without errors"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    fi
}

test_formatting_compliance() {
    echo ""
    echo -e "${YELLOW}▶ Testing Code Formatting (StyLua)${NC}"
    echo ""

    if ! command -v stylua &> /dev/null; then
        echo -e "  ${YELLOW}⊘${NC} StyLua not installed - skipping format check"
        return 0
    fi

    echo -e "  ${BLUE}ℹ${NC} Running StyLua format check (timeout: 30s)..."

    # Use temporary file for output
    local temp_output
    temp_output=$(mktemp)
    trap "rm -f $temp_output" RETURN

    # Run with timeout to prevent hangs
    local exit_code=0
    if timeout 30 stylua --check "$NVIM_CONFIG/lua" > "$temp_output" 2>&1; then
        exit_code=0
    else
        exit_code=$?
    fi

    # Check if timeout occurred
    if [ "$exit_code" -eq 124 ]; then
        echo -e "  ${RED}✗${NC} StyLua timed out after 30 seconds"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi

    # Check result
    if [ "$exit_code" -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} All code is properly formatted"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "  ${RED}✗${NC} Code formatting issues detected"
        cat "$temp_output" | head -10
        echo -e "  ${YELLOW}ℹ${NC} Run: stylua lua/ to fix"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

test_linting_compliance() {
    echo ""
    echo -e "${YELLOW}▶ Testing Code Quality (Selene)${NC}"
    echo ""

    if ! command -v selene &> /dev/null; then
        echo -e "  ${YELLOW}⊘${NC} Selene not installed - skipping lint check"
        return 0
    fi

    # Run Selene with timeout to prevent hangs in CI
    # Use temporary file for output to avoid command substitution hangs
    local temp_output
    temp_output=$(mktemp)
    trap "rm -f $temp_output" RETURN

    echo -e "  ${BLUE}ℹ${NC} Running Selene linter (timeout: 60s)..."

    # IMPORTANT: Run Selene from project root, not tests/ directory
    # This ensures it finds selene.toml configuration file
    local original_dir
    original_dir=$(pwd)
    cd "$NVIM_CONFIG" || return 1

    # Run with timeout and capture output
    local exit_code=0
    if timeout 60 selene lua/ > "$temp_output" 2>&1; then
        exit_code=0
    else
        exit_code=$?
    fi

    # Return to original directory
    cd "$original_dir" || true

    # Check if timeout occurred (exit code 124)
    if [ "$exit_code" -eq 124 ]; then
        echo -e "  ${RED}✗${NC} Selene timed out after 60 seconds"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi

    # Read output from file
    local lint_output
    lint_output=$(cat "$temp_output")

    # Parse Selene output for errors
    # Selene shows a summary line like "Results: X errors, Y warnings, Z parse errors"
    local error_count=0
    if echo "$lint_output" | grep -q "Results:"; then
        error_count=$(echo "$lint_output" | grep "Results:" | grep -oP '\d+(?= errors)' || echo 0)
    fi

    # Check for actual errors (not warnings)
    if [ "$error_count" -gt 0 ]; then
        echo -e "  ${RED}✗${NC} $error_count linting errors detected:"
        echo "$lint_output" | head -30
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi

    # Check for warnings (acceptable, won't fail build)
    local warning_count=0
    if echo "$lint_output" | grep -q "warning\["; then
        warning_count=$(echo "$lint_output" | grep -c "warning\[" || echo 0)
    fi

    if [ "$warning_count" -gt 0 ]; then
        echo -e "  ${YELLOW}⊘${NC} $warning_count linting warnings (not blocking)"
        echo -e "  ${GREEN}✓${NC} No errors - warnings are acceptable"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    fi

    # No errors or warnings
    echo -e "  ${GREEN}✓${NC} No linting issues"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
}

test_critical_files_exist() {
    echo ""
    echo -e "${YELLOW}▶ Testing Critical Files Exist${NC}"
    echo ""

    local critical_files=(
        "$NVIM_CONFIG/init.lua"
        "$NVIM_CONFIG/lua/config/init.lua"
        "$NVIM_CONFIG/lua/config/options.lua"
        "$NVIM_CONFIG/lua/config/keymaps.lua"
    )

    local missing=0

    for file in "${critical_files[@]}"; do
        if [ -f "$file" ]; then
            : # File exists, no output needed
        else
            echo -e "  ${RED}✗${NC} Missing: $file"
            missing=$((missing + 1))
        fi
    done

    if [ "$missing" -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} All critical configuration files exist"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "  ${RED}✗${NC} Missing $missing critical file(s)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

#=============================================================================
# Main
#=============================================================================

# Run tests
test_lua_syntax
test_critical_files_exist
test_core_config_loads
test_formatting_compliance
test_linting_compliance

# Summary
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Test Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Tests Passed: $TESTS_PASSED"
echo "Tests Failed: $TESTS_FAILED"
echo ""

if [ "$TESTS_FAILED" -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed! Your code is good to commit.${NC}"
    echo ""
    exit 0
else
    echo -e "${RED}❌ Some tests failed. Please fix the issues above.${NC}"
    echo ""
    echo "💡 Tips:"
    echo "  - For formatting: run 'stylua lua/'"
    echo "  - For syntax: check the files marked with ✗"
    echo "  - Don't worry about warnings - they won't block commits"
    echo ""
    exit 1
fi
