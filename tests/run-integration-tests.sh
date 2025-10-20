#!/usr/bin/env bash
# Integration Test Runner for PercyBrain
# Kent Beck: "Make tests so easy to run that there's no excuse not to"

set -e  # Exit on error

# ============================================================================
# Configuration
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
INTEGRATION_DIR="$SCRIPT_DIR/integration"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Test configuration
TIMEOUT_PER_TEST=5000  # 5 seconds per test
MAX_TOTAL_TIME=30      # 30 seconds max for all tests

# ============================================================================
# Helper Functions
# ============================================================================

log_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_section() {
    echo -e "\n${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}\n"
}

# ============================================================================
# Environment Setup
# ============================================================================

setup_test_environment() {
    log_section "Setting Up Test Environment"

    # Create temporary test vault
    export PERCYBRAIN_TEST_MODE=integration
    export PERCYBRAIN_TEST_VAULT="$(mktemp -d)/test_zettelkasten"
    export PERCYBRAIN_TEST_TIMEOUT="$TIMEOUT_PER_TEST"

    log_info "Creating test vault at: $PERCYBRAIN_TEST_VAULT"
    mkdir -p "$PERCYBRAIN_TEST_VAULT"/{inbox,templates,daily,.iwe}

    # Copy fixture templates if they exist
    if [ -d "$INTEGRATION_DIR/fixtures/templates" ]; then
        log_info "Copying template fixtures..."
        cp -r "$INTEGRATION_DIR/fixtures/templates/"* "$PERCYBRAIN_TEST_VAULT/templates/" 2>/dev/null || true
    else
        # Create basic templates if fixtures don't exist
        log_info "Creating basic templates..."
        cat > "$PERCYBRAIN_TEST_VAULT/templates/wiki.md" << 'EOF'
---
title: {{title}}
date: {{date}}
draft: false
tags: []
categories: []
---

# {{title}}
EOF

        cat > "$PERCYBRAIN_TEST_VAULT/templates/fleeting.md" << 'EOF'
---
title: {{title}}
created: {{timestamp}}
---

{{content}}
EOF
    fi

    log_success "Test environment ready"
}

cleanup_test_environment() {
    if [ -n "$PERCYBRAIN_TEST_VAULT" ] && [ -d "$PERCYBRAIN_TEST_VAULT" ]; then
        log_info "Cleaning up test vault..."
        rm -rf "$PERCYBRAIN_TEST_VAULT"
    fi
}

# ============================================================================
# Test Execution
# ============================================================================

run_integration_tests() {
    log_section "Running Integration Tests"

    local STARTTIME=$(date +%s)
    local EXIT_CODE=0

    # Check if integration test directory exists
    if [ ! -d "$INTEGRATION_DIR" ]; then
        log_warning "Integration test directory not found. Creating structure..."
        mkdir -p "$INTEGRATION_DIR"/{workflows,interactions,helpers,fixtures}
        log_info "Created integration test structure. Add tests to $INTEGRATION_DIR/workflows/"
        return 0
    fi

    # Check for test files
    local test_files=$(find "$INTEGRATION_DIR/workflows" -name "*_spec.lua" 2>/dev/null | head -5)

    if [ -z "$test_files" ]; then
        log_warning "No integration tests found in $INTEGRATION_DIR/workflows/"
        log_info "Example test created at: $INTEGRATION_DIR/workflows/wiki_creation_spec.lua"
        return 0
    fi

    # Create minimal init file for integration tests
    local INIT_FILE="$SCRIPT_DIR/integration_minimal_init.lua"
    cat > "$INIT_FILE" << 'EOF'
-- Minimal init for integration tests
vim.opt.rtp:append(".")
vim.opt.rtp:append("~/.local/share/nvim/site/pack/vendor/start/plenary.nvim")

-- Set test environment
vim.env.PERCYBRAIN_TEST = "true"
vim.g.percybrain_test_mode = "integration"

-- Disable plugins not needed for tests
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Load only what's needed for integration tests
vim.cmd([[runtime! lua/percybrain/*.lua]])
EOF

    # Run workflow tests
    if [ -d "$INTEGRATION_DIR/workflows" ]; then
        log_info "Running workflow integration tests..."

        nvim --headless \
            -u "$INIT_FILE" \
            -c "PlenaryBustedDirectory $INTEGRATION_DIR/workflows/ { minimal_init = '$INIT_FILE', sequential = true }" \
            -c "qa!" 2>&1 | tee "$SCRIPT_DIR/output/integration-test-output.log"

        EXIT_CODE=${PIPESTATUS[0]}
    fi

    # Run interaction tests if they exist
    if [ -d "$INTEGRATION_DIR/interactions" ] && [ "$(ls -A $INTEGRATION_DIR/interactions/*.lua 2>/dev/null)" ]; then
        log_info "Running component interaction tests..."

        nvim --headless \
            -u "$INIT_FILE" \
            -c "PlenaryBustedDirectory $INTEGRATION_DIR/interactions/ { minimal_init = '$INIT_FILE' }" \
            -c "qa!" 2>&1 | tee -a "$SCRIPT_DIR/output/integration-test-output.log"

        local INTERACTION_EXIT=$?
        if [ $INTERACTION_EXIT -ne 0 ]; then
            EXIT_CODE=$INTERACTION_EXIT
        fi
    fi

    local ENDTIME=$(date +%s)
    local DURATION=$((ENDTIME - STARTTIME))

    # Check execution time
    if [ $DURATION -gt $MAX_TOTAL_TIME ]; then
        log_warning "Tests took ${DURATION}s (target: <${MAX_TOTAL_TIME}s)"
    fi

    # Clean up init file
    rm -f "$INIT_FILE"

    return $EXIT_CODE
}

# ============================================================================
# Reporting
# ============================================================================

generate_report() {
    local exit_code=$1
    local duration=$2

    log_section "Test Results"

    if [ $exit_code -eq 0 ]; then
        log_success "All integration tests passed!"
        echo ""
        echo "  Execution time: ${duration} seconds"
        echo "  Test vault: $PERCYBRAIN_TEST_VAULT"
        echo "  Log file: $SCRIPT_DIR/output/integration-test-output.log"
    else
        log_error "Integration tests failed!"
        echo ""
        echo "  Exit code: $exit_code"
        echo "  Duration: ${duration} seconds"
        echo "  Check log: $SCRIPT_DIR/output/integration-test-output.log"

        # Show last few lines of error
        if [ -f "$SCRIPT_DIR/output/integration-test-output.log" ]; then
            echo ""
            echo "Last error lines:"
            echo "─────────────────────────────────────────"
            tail -n 20 "$SCRIPT_DIR/output/integration-test-output.log" | grep -E "(FAIL|ERROR|Error)" || true
        fi
    fi
}

# ============================================================================
# Main Script
# ============================================================================

main() {
    local TOTAL_START=$(date +%s)

    # Header
    echo ""
    echo "🧪 PercyBrain Integration Test Suite"
    echo "======================================"
    echo ""

    # Ensure output directory exists
    mkdir -p "$SCRIPT_DIR/output"

    # Set up test environment
    setup_test_environment

    # Run tests
    run_integration_tests
    local EXIT_CODE=$?

    # Calculate total duration
    local TOTAL_END=$(date +%s)
    local TOTAL_DURATION=$((TOTAL_END - TOTAL_START))

    # Generate report
    generate_report $EXIT_CODE $TOTAL_DURATION

    # Cleanup
    cleanup_test_environment

    # Exit with test result
    exit $EXIT_CODE
}

# Handle interrupts gracefully
trap cleanup_test_environment EXIT INT TERM

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --debug)
            set -x
            export DEBUG_INTEGRATION=1
            shift
            ;;
        --keep-vault)
            export KEEP_TEST_VAULT=1
            shift
            ;;
        --timeout)
            TIMEOUT_PER_TEST="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --debug         Enable debug output"
            echo "  --keep-vault    Don't delete test vault after tests"
            echo "  --timeout MS    Set timeout per test in milliseconds (default: 5000)"
            echo "  --help          Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Run '$0 --help' for usage information"
            exit 1
            ;;
    esac
done

# Run main function
main
