#!/usr/bin/env bash
# test-neovim-launch.sh - Validate Neovim launches with PercyBrain config
# Part of CI/CD Installation Validation Pipeline

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test tracking
TESTS_PASSED=0
TESTS_FAILED=0

log_info() {
  echo -e "${GREEN}✓${NC} $1"
}

log_error() {
  echo -e "${RED}✗${NC} $1"
}

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

main() {
  echo "=================================================="
  echo "  PercyBrain Neovim Launch Validation"
  echo "=================================================="
  echo ""

  # Phase 1: Basic Neovim Launch
  echo "Phase 1: Basic Launch"
  echo "---------------------"

  run_test "Neovim launches headless" "nvim --headless -c 'qa!'"
  run_test "Neovim version check" "nvim --version | grep -q 'NVIM v0'"

  echo ""

  # Phase 2: Configuration Loading
  echo "Phase 2: Configuration Loading"
  echo "-------------------------------"

  # Test init.lua loads
  if nvim --headless -c "lua print('init.lua loaded')" -c "qa!" 2>&1 | grep -q "init.lua loaded"; then
    log_info "init.lua loads successfully"
    ((TESTS_PASSED++))
  else
    log_error "init.lua failed to load"
    ((TESTS_FAILED++))
  fi

  # Test config modules load
  if nvim --headless -c "lua require('config')" -c "qa!" 2>&1; then
    log_info "config module loads successfully"
    ((TESTS_PASSED++))
  else
    log_error "config module failed to load"
    ((TESTS_FAILED++))
  fi

  echo ""

  # Phase 3: Critical Options Validation
  echo "Phase 3: Critical Options"
  echo "-------------------------"

  # Test ADHD optimizations
  if nvim --headless -c "lua if vim.opt.hlsearch:get() == false then print('PASS') end" -c "qa!" 2>&1 | grep -q "PASS"; then
    log_info "ADHD optimization: hlsearch=false"
    ((TESTS_PASSED++))
  else
    log_error "ADHD optimization: hlsearch should be false"
    ((TESTS_FAILED++))
  fi

  if nvim --headless -c "lua if vim.opt.spell:get() == true then print('PASS') end" -c "qa!" 2>&1 | grep -q "PASS"; then
    log_info "Writing environment: spell=true"
    ((TESTS_PASSED++))
  else
    log_error "Writing environment: spell should be true"
    ((TESTS_FAILED++))
  fi

  if nvim --headless -c "lua if vim.opt.wrap:get() == true then print('PASS') end" -c "qa!" 2>&1 | grep -q "PASS"; then
    log_info "Writing environment: wrap=true"
    ((TESTS_PASSED++))
  else
    log_error "Writing environment: wrap should be true"
    ((TESTS_FAILED++))
  fi

  if nvim --headless -c "lua if vim.opt.number:get() == true then print('PASS') end" -c "qa!" 2>&1 | grep -q "PASS"; then
    log_info "Visual anchors: number=true"
    ((TESTS_PASSED++))
  else
    log_error "Visual anchors: number should be true"
    ((TESTS_FAILED++))
  fi

  echo ""

  # Phase 4: Leader Keys
  echo "Phase 4: Leader Keys"
  echo "--------------------"

  if nvim --headless -c "lua if vim.g.mapleader == ' ' then print('PASS') end" -c "qa!" 2>&1 | grep -q "PASS"; then
    log_info "Leader key: <space>"
    ((TESTS_PASSED++))
  else
    log_error "Leader key should be <space>"
    ((TESTS_FAILED++))
  fi

  echo ""

  # Phase 5: Startup Time Validation
  echo "Phase 5: Startup Performance"
  echo "----------------------------"

  local startuptime_file
  startuptime_file=$(mktemp)

  nvim --headless --startuptime "$startuptime_file" -c "qa!" 2>&1

  if [ -f "$startuptime_file" ]; then
    local startup_time
    startup_time=$(tail -n 1 "$startuptime_file" | awk '{print $1}')

    # Convert to milliseconds (remove decimal point)
    startup_ms=${startup_time//./}

    if [ "$startup_ms" -lt 1000 ]; then
      log_info "Startup time: ${startup_time}ms (target: <1000ms)"
      ((TESTS_PASSED++))
    else
      log_error "Startup time: ${startup_time}ms (exceeds 1000ms target)"
      ((TESTS_FAILED++))
    fi

    rm -f "$startuptime_file"
  else
    log_error "Could not measure startup time"
    ((TESTS_FAILED++))
  fi

  echo ""

  # Phase 6: Plugin Manager Check
  echo "Phase 6: Plugin Manager"
  echo "-----------------------"

  if nvim --headless -c "lua if pcall(require, 'lazy') then print('PASS') end" -c "qa!" 2>&1 | grep -q "PASS"; then
    log_info "lazy.nvim plugin manager available"
    ((TESTS_PASSED++))
  else
    log_error "lazy.nvim plugin manager not found"
    ((TESTS_FAILED++))
  fi

  echo ""

  # Summary
  echo "=================================================="
  echo "  Neovim Launch Validation Summary"
  echo "=================================================="
  echo ""
  echo "Tests Passed: $TESTS_PASSED"
  echo "Tests Failed: $TESTS_FAILED"
  echo ""

  if [ $TESTS_FAILED -eq 0 ]; then
    log_info "Neovim launches successfully with PercyBrain config"
    echo ""
    echo "✅ Ready for plugin installation validation"
    exit 0
  else
    log_error "Neovim launch validation failed"
    echo ""
    echo "❌ Fix configuration issues before proceeding"
    exit 1
  fi
}

main
