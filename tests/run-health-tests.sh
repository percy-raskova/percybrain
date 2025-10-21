#!/bin/bash
# tests/run-health-tests.sh
# Run health validation tests for PercyBrain
# Part of TDD implementation for checkhealth issues

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NVIM_CONFIG_DIR="$(dirname "$SCRIPT_DIR")"

echo "═══════════════════════════════════════════"
echo " PercyBrain Health Test Suite"
echo "═══════════════════════════════════════════"
echo ""

# Function to run a test file
# NOTE: Health tests intentionally DO NOT use -u tests/minimal_init.lua
# Health validation requires the FULL PercyBrain configuration to be loaded
# so we can verify the actual production setup, not a minimal test environment.
# This is different from unit/integration tests which use isolated environments.
run_test() {
    local test_file="$1"
    local test_name="$(basename "$test_file" .test.lua)"

    echo "🧪 Testing: $test_name"

    if nvim --headless \
           -c "PlenaryBustedFile $test_file" \
           -c "qa!" 2>&1; then
        echo "   ✅ PASSED"
        return 0
    else
        echo "   ❌ FAILED"
        return 1
    fi
}

# Track test results
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
FAILED_LIST=()

# Run health validation tests
echo "📋 Running Health Validation Tests..."
echo ""

# Test Python Treesitter parser
if [ -f "$SCRIPT_DIR/treesitter/python-parser-contract.test.lua" ]; then
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    if run_test "$SCRIPT_DIR/treesitter/python-parser-contract.test.lua"; then
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        FAILED_TESTS=$((FAILED_TESTS + 1))
        FAILED_LIST+=("python-parser-contract")
    fi
fi

# Test health validation
if [ -f "$SCRIPT_DIR/health/health-validation.test.lua" ]; then
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    if run_test "$SCRIPT_DIR/health/health-validation.test.lua"; then
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        FAILED_TESTS=$((FAILED_TESTS + 1))
        FAILED_LIST+=("health-validation")
    fi
fi

echo ""
echo "═══════════════════════════════════════════"
echo " Health Test Results"
echo "═══════════════════════════════════════════"
echo ""
echo "📊 Summary:"
echo "   Total:  $TOTAL_TESTS"
echo "   Passed: $PASSED_TESTS"
echo "   Failed: $FAILED_TESTS"
echo ""

if [ ${#FAILED_LIST[@]} -gt 0 ]; then
    echo "❌ Failed Tests:"
    for test in "${FAILED_LIST[@]}"; do
        echo "   • $test"
    done
    echo ""
fi

# Run actual checkhealth and parse results
echo "🔍 Running Neovim checkhealth..."
echo ""

# Capture checkhealth output
CHECKHEALTH_OUTPUT=$(nvim --headless -c "checkhealth" -c "qa!" 2>&1 || true)

# Count issues
CRITICAL_COUNT=$(echo "$CHECKHEALTH_OUTPUT" | grep -c "ERROR" || true)
HIGH_COUNT=$(echo "$CHECKHEALTH_OUTPUT" | grep -E -c "WARNING.*(deprecated|localoptions)" || true)
TOTAL_WARNINGS=$(echo "$CHECKHEALTH_OUTPUT" | grep -c "WARNING" || true)
MEDIUM_COUNT=$((TOTAL_WARNINGS - HIGH_COUNT))

echo "📈 Checkhealth Status:"
echo "   🔴 CRITICAL (Errors):     $CRITICAL_COUNT"
echo "   🟡 HIGH (Deprecations):   $HIGH_COUNT"
echo "   🟠 MEDIUM (Warnings):     $MEDIUM_COUNT"
echo ""

# Determine exit status
EXIT_CODE=0

if [ $FAILED_TESTS -gt 0 ]; then
    echo "⚠️  Some health tests failed. Review and fix issues."
    EXIT_CODE=1
fi

if [ $CRITICAL_COUNT -gt 0 ]; then
    echo "❌ CRITICAL errors detected in checkhealth!"
    echo "   Run :checkhealth in Neovim for details."
    EXIT_CODE=2
fi

if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ All health tests passed and system is healthy!"
else
    echo ""
    echo "📝 To fix issues, run:"
    echo "   nvim -c ':PercyBrainHealthFix' -c ':checkhealth'"
fi

echo ""
echo "═══════════════════════════════════════════"

exit $EXIT_CODE
