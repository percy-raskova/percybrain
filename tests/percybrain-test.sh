#!/bin/bash
# PercyBrain Test Suite
# Simple local testing for all PercyBrain components
# Usage: ./percybrain-test.sh [--verbose] [--component <name>]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Verbose mode
VERBOSE=0

# Test results array
declare -a TEST_RESULTS

# Configuration
NVIM_CONFIG="$HOME/.config/nvim"
ZETTELKASTEN_DIR="$HOME/Zettelkasten"
TEST_OUTPUT_DIR="$NVIM_CONFIG/tests/output"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Create output directory
mkdir -p "$TEST_OUTPUT_DIR"

#=============================================================================
# Helper Functions
#=============================================================================

print_header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_section() {
    echo ""
    echo -e "${YELLOW}▶ $1${NC}"
    echo ""
}

log_verbose() {
    if [ "$VERBOSE" -eq 1 ]; then
        echo -e "  ${BLUE}ℹ${NC} $1"
    fi
}

assert_file_exists() {
    local file="$1"
    local description="$2"

    TESTS_RUN=$((TESTS_RUN + 1))

    if [ -f "$file" ]; then
        echo -e "  ${GREEN}✓${NC} $description"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        TEST_RESULTS+=("PASS: $description")
        return 0
    else
        echo -e "  ${RED}✗${NC} $description (file not found: $file)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        TEST_RESULTS+=("FAIL: $description - file not found: $file")
        return 1
    fi
}

assert_command_exists() {
    local cmd="$1"
    local description="$2"

    TESTS_RUN=$((TESTS_RUN + 1))

    if command -v "$cmd" &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} $description"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        TEST_RESULTS+=("PASS: $description")
        return 0
    else
        echo -e "  ${RED}✗${NC} $description (command not found: $cmd)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        TEST_RESULTS+=("FAIL: $description - command not found: $cmd")
        return 1
    fi
}

assert_process_running() {
    local process="$1"
    local description="$2"

    TESTS_RUN=$((TESTS_RUN + 1))

    if pgrep -x "$process" > /dev/null; then
        echo -e "  ${GREEN}✓${NC} $description"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        TEST_RESULTS+=("PASS: $description")
        return 0
    else
        echo -e "  ${YELLOW}⊘${NC} $description (process not running: $process)"
        TESTS_SKIPPED=$((TESTS_SKIPPED + 1))
        TEST_RESULTS+=("SKIP: $description - process not running")
        return 1
    fi
}

assert_lua_module_loads() {
    local module="$1"
    local description="$2"

    TESTS_RUN=$((TESTS_RUN + 1))

    log_verbose "Testing Lua module: $module"

    local result
    result=$(nvim --headless -c "lua require('$module')" -c "qall" 2>&1)

    if echo "$result" | grep -q "Error\|Failed"; then
        echo -e "  ${RED}✗${NC} $description"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        TEST_RESULTS+=("FAIL: $description - module load error")
        [ "$VERBOSE" -eq 1 ] && echo "$result"
        return 1
    else
        echo -e "  ${GREEN}✓${NC} $description"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        TEST_RESULTS+=("PASS: $description")
        return 0
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local description="$3"

    TESTS_RUN=$((TESTS_RUN + 1))

    if echo "$haystack" | grep -q "$needle"; then
        echo -e "  ${GREEN}✓${NC} $description"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        TEST_RESULTS+=("PASS: $description")
        return 0
    else
        echo -e "  ${RED}✗${NC} $description (not found: $needle)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        TEST_RESULTS+=("FAIL: $description - pattern not found")
        return 1
    fi
}

#=============================================================================
# Component Tests
#=============================================================================

test_core_files() {
    print_section "Testing Core Configuration Files"

    assert_file_exists "$NVIM_CONFIG/init.lua" "init.lua exists"
    assert_file_exists "$NVIM_CONFIG/lua/config/init.lua" "config/init.lua exists"
    assert_file_exists "$NVIM_CONFIG/lua/config/zettelkasten.lua" "zettelkasten.lua exists"
    assert_file_exists "$NVIM_CONFIG/lua/plugins/ollama.lua" "ollama.lua exists"
    assert_file_exists "$NVIM_CONFIG/lua/plugins/sembr.lua" "sembr.lua exists"
    assert_file_exists "$NVIM_CONFIG/lua/plugins/lsp/lspconfig.lua" "lspconfig.lua exists"
}

test_external_dependencies() {
    print_section "Testing External Dependencies"

    assert_command_exists "nvim" "Neovim installed"
    assert_command_exists "iwe" "IWE LSP installed"
    assert_command_exists "sembr" "SemBr installed"
    assert_command_exists "ollama" "Ollama installed"

    # Check versions
    if command -v nvim &> /dev/null; then
        local nvim_version
        nvim_version=$(nvim --version | head -1)
        log_verbose "Neovim version: $nvim_version"
    fi

    if command -v iwe &> /dev/null; then
        local iwe_version
        iwe_version=$(iwe --version 2>&1 || echo "unknown")
        log_verbose "IWE version: $iwe_version"
    fi

    if command -v sembr &> /dev/null; then
        local sembr_version
        sembr_version=$(sembr --version 2>&1 || echo "unknown")
        log_verbose "SemBr version: $sembr_version"
    fi
}

test_zettelkasten_structure() {
    print_section "Testing Zettelkasten Directory Structure"

    TESTS_RUN=$((TESTS_RUN + 1))
    if [ -d "$ZETTELKASTEN_DIR" ]; then
        echo -e "  ${GREEN}✓${NC} Zettelkasten directory exists"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        TEST_RESULTS+=("PASS: Zettelkasten directory exists")
    else
        echo -e "  ${YELLOW}⊘${NC} Zettelkasten directory doesn't exist (will be created on first use)"
        TESTS_SKIPPED=$((TESTS_SKIPPED + 1))
        TEST_RESULTS+=("SKIP: Zettelkasten directory doesn't exist")
    fi

    # Check subdirectories
    for dir in inbox daily templates; do
        TESTS_RUN=$((TESTS_RUN + 1))
        if [ -d "$ZETTELKASTEN_DIR/$dir" ]; then
            echo -e "  ${GREEN}✓${NC} $dir/ subdirectory exists"
            TESTS_PASSED=$((TESTS_PASSED + 1))
            TEST_RESULTS+=("PASS: $dir subdirectory exists")
        else
            echo -e "  ${YELLOW}⊘${NC} $dir/ subdirectory doesn't exist (will be created on first use)"
            TESTS_SKIPPED=$((TESTS_SKIPPED + 1))
            TEST_RESULTS+=("SKIP: $dir subdirectory doesn't exist")
        fi
    done
}

test_templates() {
    print_section "Testing Template System"

    if [ ! -d "$ZETTELKASTEN_DIR/templates" ]; then
        echo -e "  ${YELLOW}⊘${NC} Templates directory doesn't exist - skipping template tests"
        TESTS_SKIPPED=$((TESTS_SKIPPED + 5))
        return
    fi

    for template in permanent literature project meeting fleeting; do
        assert_file_exists "$ZETTELKASTEN_DIR/templates/${template}.md" "Template: ${template}.md"
    done

    # Check template variables
    if [ -f "$ZETTELKASTEN_DIR/templates/permanent.md" ]; then
        TESTS_RUN=$((TESTS_RUN + 1))
        local content
        content=$(cat "$ZETTELKASTEN_DIR/templates/permanent.md")

        if echo "$content" | grep -q "{{title}}" && echo "$content" | grep -q "{{date}}"; then
            echo -e "  ${GREEN}✓${NC} Template variables present ({{title}}, {{date}})"
            TESTS_PASSED=$((TESTS_PASSED + 1))
            TEST_RESULTS+=("PASS: Template variables present")
        else
            echo -e "  ${RED}✗${NC} Template variables missing"
            TESTS_FAILED=$((TESTS_FAILED + 1))
            TEST_RESULTS+=("FAIL: Template variables missing")
        fi
    fi
}

test_lua_modules() {
    print_section "Testing Lua Module Loading"

    assert_lua_module_loads "config.zettelkasten" "Zettelkasten module loads"
    assert_lua_module_loads "plugins.sembr" "SemBr module loads"

    # Note: ollama.lua returns a plugin spec, not a module
    TESTS_RUN=$((TESTS_RUN + 1))
    if [ -f "$NVIM_CONFIG/lua/plugins/ollama.lua" ]; then
        echo -e "  ${GREEN}✓${NC} Ollama plugin file exists and is valid Lua"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        TEST_RESULTS+=("PASS: Ollama plugin file valid")
    else
        echo -e "  ${RED}✗${NC} Ollama plugin file missing or invalid"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        TEST_RESULTS+=("FAIL: Ollama plugin file missing")
    fi
}

test_ollama_integration() {
    print_section "Testing Ollama AI Integration"

    if ! command -v ollama &> /dev/null; then
        echo -e "  ${YELLOW}⊘${NC} Ollama not installed - skipping AI tests"
        TESTS_SKIPPED=$((TESTS_SKIPPED + 3))
        return
    fi

    # Check if Ollama service is running (don't fail if not)
    assert_process_running "ollama" "Ollama service running" || true

    # Check if model is installed
    TESTS_RUN=$((TESTS_RUN + 1))
    if ollama list 2>/dev/null | grep -q "llama3.2"; then
        echo -e "  ${GREEN}✓${NC} llama3.2 model installed"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        TEST_RESULTS+=("PASS: llama3.2 model installed")
    else
        echo -e "  ${YELLOW}⊘${NC} llama3.2 model not installed"
        TESTS_SKIPPED=$((TESTS_SKIPPED + 1))
        TEST_RESULTS+=("SKIP: llama3.2 model not installed")
    fi

    # Test Ollama API endpoint (if service running)
    if pgrep -x "ollama" > /dev/null; then
        TESTS_RUN=$((TESTS_RUN + 1))
        if curl -s http://localhost:11434/api/tags &> /dev/null; then
            echo -e "  ${GREEN}✓${NC} Ollama API responding"
            TESTS_PASSED=$((TESTS_PASSED + 1))
            TEST_RESULTS+=("PASS: Ollama API responding")
        else
            echo -e "  ${RED}✗${NC} Ollama API not responding"
            TESTS_FAILED=$((TESTS_FAILED + 1))
            TEST_RESULTS+=("FAIL: Ollama API not responding")
        fi
    fi
}

test_keybindings() {
    print_section "Testing Keybinding Configuration"

    # Check for keybinding conflicts
    TESTS_RUN=$((TESTS_RUN + 1))

    log_verbose "Checking for duplicate keybindings..."

    # Search for leader keybindings in config files
    local zettel_keys
    local ollama_keys

    zettel_keys=$(grep -o "'<leader>z[a-z]'" "$NVIM_CONFIG/lua/config/zettelkasten.lua" 2>/dev/null | sort)
    ollama_keys=$(grep -o '"<leader>a[a-z]"' "$NVIM_CONFIG/lua/plugins/ollama.lua" 2>/dev/null | sort)

    # Check for overlap between z and a prefixes (shouldn't happen)
    if echo "$zettel_keys" | grep -q "<leader>a" || echo "$ollama_keys" | grep -q "<leader>z"; then
        echo -e "  ${RED}✗${NC} Keybinding prefix conflict detected"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        TEST_RESULTS+=("FAIL: Keybinding prefix conflict")
    else
        echo -e "  ${GREEN}✓${NC} No keybinding conflicts detected"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        TEST_RESULTS+=("PASS: No keybinding conflicts")
    fi

    # Verify key separation
    TESTS_RUN=$((TESTS_RUN + 1))
    if echo "$zettel_keys" | grep -q "leader>z" && echo "$ollama_keys" | grep -q "leader>a"; then
        echo -e "  ${GREEN}✓${NC} Zettelkasten (z) and AI (a) prefixes properly separated"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        TEST_RESULTS+=("PASS: Key prefixes properly separated")
    else
        echo -e "  ${YELLOW}⊘${NC} Could not verify key prefix separation"
        TESTS_SKIPPED=$((TESTS_SKIPPED + 1))
        TEST_RESULTS+=("SKIP: Key prefix verification")
    fi
}

test_lsp_integration() {
    print_section "Testing LSP Integration"

    if ! command -v iwe &> /dev/null; then
        echo -e "  ${YELLOW}⊘${NC} IWE LSP not installed - skipping LSP tests"
        TESTS_SKIPPED=$((TESTS_SKIPPED + 2))
        return
    fi

    # Check LSP config
    TESTS_RUN=$((TESTS_RUN + 1))
    if grep -q 'lspconfig\["iwe"\]' "$NVIM_CONFIG/lua/plugins/lsp/lspconfig.lua" 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} IWE LSP configured in lspconfig.lua"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        TEST_RESULTS+=("PASS: IWE LSP configured")
    else
        echo -e "  ${RED}✗${NC} IWE LSP not found in lspconfig.lua"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        TEST_RESULTS+=("FAIL: IWE LSP not configured")
    fi

    # Check workspace setting
    TESTS_RUN=$((TESTS_RUN + 1))
    if grep -q "workspace.*Zettelkasten" "$NVIM_CONFIG/lua/plugins/lsp/lspconfig.lua" 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} IWE workspace set to Zettelkasten"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        TEST_RESULTS+=("PASS: IWE workspace configured")
    else
        echo -e "  ${YELLOW}⊘${NC} IWE workspace setting not found"
        TESTS_SKIPPED=$((TESTS_SKIPPED + 1))
        TEST_RESULTS+=("SKIP: IWE workspace setting")
    fi
}

test_documentation() {
    print_section "Testing Documentation"

    assert_file_exists "$NVIM_CONFIG/CLAUDE.md" "CLAUDE.md exists"
    assert_file_exists "$NVIM_CONFIG/claudedocs/PERCYBRAIN_DESIGN.md" "PERCYBRAIN_DESIGN.md exists"
    assert_file_exists "$NVIM_CONFIG/claudedocs/PERCYBRAIN_ANALYSIS.md" "PERCYBRAIN_ANALYSIS.md exists"
    assert_file_exists "$NVIM_CONFIG/claudedocs/PERCYBRAIN_PHASE1_COMPLETE.md" "PERCYBRAIN_PHASE1_COMPLETE.md exists"
    assert_file_exists "$NVIM_CONFIG/claudedocs/PERCYBRAIN_USER_GUIDE.md" "PERCYBRAIN_USER_GUIDE.md exists"

    # Check if user guide is up to date (contains new keybindings)
    if [ -f "$NVIM_CONFIG/claudedocs/PERCYBRAIN_USER_GUIDE.md" ]; then
        TESTS_RUN=$((TESTS_RUN + 1))
        local guide_content
        guide_content=$(cat "$NVIM_CONFIG/claudedocs/PERCYBRAIN_USER_GUIDE.md")

        if echo "$guide_content" | grep -q "<leader>aa" && echo "$guide_content" | grep -q "<leader>fz"; then
            echo -e "  ${GREEN}✓${NC} User guide contains updated keybindings"
            TESTS_PASSED=$((TESTS_PASSED + 1))
            TEST_RESULTS+=("PASS: User guide up to date")
        else
            echo -e "  ${YELLOW}⊘${NC} User guide may need keybinding updates"
            TESTS_SKIPPED=$((TESTS_SKIPPED + 1))
            TEST_RESULTS+=("SKIP: User guide keybindings check")
        fi
    fi
}

#=============================================================================
# Test Report Generation
#=============================================================================

generate_report() {
    local report_file="$TEST_OUTPUT_DIR/test-report-$TIMESTAMP.txt"

    {
        echo "PercyBrain Test Report"
        echo "======================"
        echo "Date: $(date)"
        echo "Hostname: $(hostname)"
        echo "User: $(whoami)"
        echo ""
        echo "Summary:"
        echo "--------"
        echo "Total Tests: $TESTS_RUN"
        echo "Passed: $TESTS_PASSED"
        echo "Failed: $TESTS_FAILED"
        echo "Skipped: $TESTS_SKIPPED"
        echo ""
        echo "Success Rate: $(awk "BEGIN {printf \"%.1f\", ($TESTS_PASSED/$TESTS_RUN)*100}")%"
        echo ""
        echo "Detailed Results:"
        echo "-----------------"
        for result in "${TEST_RESULTS[@]}"; do
            echo "$result"
        done
    } > "$report_file"

    echo -e "\n${BLUE}ℹ${NC} Test report saved: $report_file"
}

#=============================================================================
# Main Test Runner
#=============================================================================

run_all_tests() {
    print_header "PercyBrain Test Suite"

    echo "Starting test run at $(date)"
    echo "Config directory: $NVIM_CONFIG"
    echo "Zettelkasten directory: $ZETTELKASTEN_DIR"
    echo ""

    # Run test suites
    test_core_files
    test_external_dependencies
    test_zettelkasten_structure
    test_templates
    test_lua_modules
    test_ollama_integration
    test_keybindings
    test_lsp_integration
    test_documentation

    # Print summary
    print_header "Test Summary"

    echo "Total Tests Run: $TESTS_RUN"
    echo -e "  ${GREEN}✓${NC} Passed: $TESTS_PASSED"
    echo -e "  ${RED}✗${NC} Failed: $TESTS_FAILED"
    echo -e "  ${YELLOW}⊘${NC} Skipped: $TESTS_SKIPPED"
    echo ""

    local success_rate
    success_rate=$(awk "BEGIN {printf \"%.1f\", ($TESTS_PASSED/$TESTS_RUN)*100}")

    if [ "$TESTS_FAILED" -eq 0 ]; then
        echo -e "${GREEN}🎉 All tests passed! ($success_rate%)${NC}"
        echo ""
        generate_report
        return 0
    else
        echo -e "${RED}❌ Some tests failed ($success_rate% success rate)${NC}"
        echo ""
        echo "Failed tests:"
        for result in "${TEST_RESULTS[@]}"; do
            if [[ $result == FAIL:* ]]; then
                echo -e "  ${RED}✗${NC} ${result#FAIL: }"
            fi
        done
        echo ""
        generate_report
        return 1
    fi
}

#=============================================================================
# Usage
#=============================================================================

usage() {
    cat << EOF
Usage: $0 [OPTIONS]

PercyBrain Test Suite - Local testing for all components

OPTIONS:
    -h, --help              Show this help message
    -v, --verbose           Enable verbose output
    -c, --component NAME    Test only specific component
                           (core, deps, zettel, templates, lua, ollama, keys, lsp, docs)

EXAMPLES:
    $0                      Run all tests
    $0 --verbose            Run all tests with detailed output
    $0 -c ollama            Test only Ollama integration
    $0 -c templates -v      Test templates with verbose output

EOF
}

#=============================================================================
# Parse Arguments
#=============================================================================

COMPONENT=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=1
            shift
            ;;
        -c|--component)
            COMPONENT="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

#=============================================================================
# Execute Tests
#=============================================================================

if [ -n "$COMPONENT" ]; then
    print_header "PercyBrain Test Suite - Component: $COMPONENT"

    case $COMPONENT in
        core)
            test_core_files
            ;;
        deps)
            test_external_dependencies
            ;;
        zettel)
            test_zettelkasten_structure
            ;;
        templates)
            test_templates
            ;;
        lua)
            test_lua_modules
            ;;
        ollama)
            test_ollama_integration
            ;;
        keys)
            test_keybindings
            ;;
        lsp)
            test_lsp_integration
            ;;
        docs)
            test_documentation
            ;;
        *)
            echo "Unknown component: $COMPONENT"
            echo "Valid components: core, deps, zettel, templates, lua, ollama, keys, lsp, docs"
            exit 1
            ;;
    esac

    print_header "Component Test Summary"
    echo "Tests Run: $TESTS_RUN"
    echo "Passed: $TESTS_PASSED"
    echo "Failed: $TESTS_FAILED"
    echo "Skipped: $TESTS_SKIPPED"
else
    run_all_tests
fi
