#!/usr/bin/env bash
# test-clean-install.sh - Validate PercyBrain installation from scratch
# Part of CI/CD Installation Validation Pipeline

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test results tracking
TESTS_PASSED=0
TESTS_FAILED=0

# Logging functions
log_info() {
  echo -e "${GREEN}✓${NC} $1"
}

log_error() {
  echo -e "${RED}✗${NC} $1"
}

log_warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

# Test helper
run_test() {
  local test_name=$1
  local test_command=$2

  echo -n "Testing: $test_name ... "

  if eval "$test_command" > /dev/null 2>&1; then
    echo -e "${GREEN}PASS${NC}"
    ((TESTS_PASSED++))
    return 0
  else
    echo -e "${RED}FAIL${NC}"
    ((TESTS_FAILED++))
    return 1
  fi
}

# Main test suite
main() {
  echo "=================================================="
  echo "  PercyBrain Clean Installation Validation"
  echo "=================================================="
  echo ""

  # Phase 1: Directory Structure Validation
  echo "Phase 1: Directory Structure"
  echo "----------------------------"

  run_test "Root directory exists" "test -d ."
  run_test "init.lua exists" "test -f init.lua"
  run_test "lua/config exists" "test -d lua/config"
  run_test "lua/plugins exists" "test -d lua/plugins"
  run_test "tests directory exists" "test -d tests"
  run_test "docs directory exists" "test -d docs"

  echo ""

  # Phase 2: Critical Files Validation
  echo "Phase 2: Critical Files"
  echo "-----------------------"

  run_test "lua/config/init.lua exists" "test -f lua/config/init.lua"
  run_test "lua/config/options.lua exists" "test -f lua/config/options.lua"
  run_test "lua/config/keymaps.lua exists" "test -f lua/config/keymaps.lua"
  run_test "lua/config/zettelkasten.lua exists" "test -f lua/config/zettelkasten.lua"
  run_test "lua/plugins/init.lua exists" "test -f lua/plugins/init.lua"

  echo ""

  # Phase 3: Configuration Files
  echo "Phase 3: Configuration Files"
  echo "----------------------------"

  run_test ".mise.toml exists" "test -f .mise.toml"
  run_test ".luacheckrc exists" "test -f .luacheckrc"
  run_test ".stylua.toml exists" "test -f .stylua.toml"
  run_test ".pre-commit-config.yaml exists" "test -f .pre-commit-config.yaml"

  echo ""

  # Phase 4: Plugin Directory Structure
  echo "Phase 4: Plugin Directory Structure"
  echo "------------------------------------"

  local plugin_dirs=(
    "zettelkasten"
    "ai-sembr"
    "prose-writing"
    "academic"
    "lsp"
    "completion"
    "ui"
    "navigation"
    "utilities"
  )

  for dir in "${plugin_dirs[@]}"; do
    run_test "Plugin directory: $dir" "test -d lua/plugins/$dir"
  done

  echo ""

  # Phase 5: Documentation Completeness
  echo "Phase 5: Documentation"
  echo "----------------------"

  run_test "README.md exists" "test -f README.md"
  run_test "CLAUDE.md exists" "test -f CLAUDE.md"
  run_test "PERCYBRAIN_DESIGN.md exists" "test -f PERCYBRAIN_DESIGN.md"
  run_test "PERCYBRAIN_SETUP.md exists" "test -f PERCYBRAIN_SETUP.md"
  run_test "QUICK_REFERENCE.md exists" "test -f QUICK_REFERENCE.md"

  echo ""

  # Phase 6: Test Framework Structure
  echo "Phase 6: Test Framework"
  echo "-----------------------"

  run_test "tests/minimal_init.lua exists" "test -f tests/minimal_init.lua"
  run_test "tests/helpers exists" "test -d tests/helpers"
  run_test "tests/contract exists" "test -d tests/contract"
  run_test "tests/capability exists" "test -d tests/capability"
  run_test "tests/regression exists" "test -d tests/regression"
  run_test "specs/percybrain_contract.lua exists" "test -f specs/percybrain_contract.lua"

  echo ""

  # Phase 7: Lua Syntax Validation
  echo "Phase 7: Lua Syntax Validation"
  echo "-------------------------------"

  if command -v lua > /dev/null 2>&1; then
    local lua_files
    lua_files=$(find lua -name "*.lua" -type f)
    local syntax_errors=0

    for file in $lua_files; do
      if ! lua -c "$file" > /dev/null 2>&1; then
        log_error "Syntax error in: $file"
        ((syntax_errors++))
        ((TESTS_FAILED++))
      fi
    done

    if [ $syntax_errors -eq 0 ]; then
      log_info "All Lua files have valid syntax"
      ((TESTS_PASSED++))
    else
      log_error "Found $syntax_errors Lua syntax errors"
    fi
  else
    log_warning "Lua not found, skipping syntax validation"
  fi

  echo ""

  # Phase 8: Plugin Count Validation
  echo "Phase 8: Plugin Count"
  echo "---------------------"

  local plugin_count
  plugin_count=$(find lua/plugins -name "*.lua" -type f ! -name "init.lua" | wc -l)

  if [ "$plugin_count" -ge 60 ]; then
    log_info "Plugin count: $plugin_count (expected ~68)"
    ((TESTS_PASSED++))
  else
    log_error "Plugin count: $plugin_count (expected ~68)"
    ((TESTS_FAILED++))
  fi

  echo ""

  # Summary
  echo "=================================================="
  echo "  Installation Validation Summary"
  echo "=================================================="
  echo ""
  echo "Tests Passed: $TESTS_PASSED"
  echo "Tests Failed: $TESTS_FAILED"
  echo ""

  if [ $TESTS_FAILED -eq 0 ]; then
    log_info "Clean installation structure validated successfully"
    echo ""
    echo "✅ Ready for dependency installation phase"
    exit 0
  else
    log_error "Installation validation failed"
    echo ""
    echo "❌ Fix installation issues before proceeding"
    exit 1
  fi
}

# Run main test suite
main
