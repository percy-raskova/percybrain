# PercyBrain Plenary Testing Makefile
# Automated test execution and management

.PHONY: all test test-unit test-integration test-workflows test-neurodiversity \
        test-performance test-e2e test-watch test-file coverage clean help

# Configuration
NVIM := nvim
TEST_DIR := plenary
HELPERS_DIR := helpers
FIXTURES_DIR := fixtures
MINIMAL_INIT := minimal_init.lua
RUNNER := run-plenary.sh

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

#=============================================================================
# Default Target
#=============================================================================

all: test

#=============================================================================
# Main Test Targets
#=============================================================================

# Run all tests
test:
	@echo "$(BLUE)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@echo "$(BLUE)  Running All PercyBrain Tests$(NC)"
	@echo "$(BLUE)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@./$(RUNNER) all

# Run unit tests only
test-unit:
	@echo "$(YELLOW)▶ Running Unit Tests$(NC)"
	@$(NVIM) --headless -c "PlenaryBustedDirectory $(TEST_DIR)/unit" -c "qall" 2>&1 | grep -v "^🪟\|^🌙\|^📂\|^🧠"

# Run integration tests
test-integration:
	@echo "$(YELLOW)▶ Running Integration Tests$(NC)"
	@$(NVIM) --headless -c "PlenaryBustedDirectory $(TEST_DIR)/integration" -c "qall" 2>&1 | grep -v "^🪟\|^🌙\|^📂\|^🧠"

# Run workflow tests
test-workflows:
	@echo "$(YELLOW)▶ Running Workflow Tests$(NC)"
	@$(NVIM) --headless -c "PlenaryBustedDirectory $(TEST_DIR)/workflows" -c "qall" 2>&1 | grep -v "^🪟\|^🌙\|^📂\|^🧠"

# Run neurodiversity feature tests
test-neurodiversity:
	@echo "$(YELLOW)▶ Running Neurodiversity Tests$(NC)"
	@$(NVIM) --headless -c "PlenaryBustedDirectory $(TEST_DIR)/neurodiversity" -c "qall" 2>&1 | grep -v "^🪟\|^🌙\|^📂\|^🧠"

# Run performance benchmarks
test-performance:
	@echo "$(YELLOW)▶ Running Performance Benchmarks$(NC)"
	@$(NVIM) --headless -c "PlenaryBustedDirectory $(TEST_DIR)/performance" -c "qall" 2>&1 | grep -v "^🪟\|^🌙\|^📂\|^🧠"

# Run end-to-end tests
test-e2e:
	@echo "$(YELLOW)▶ Running End-to-End Tests$(NC)"
	@$(NVIM) --headless -c "PlenaryBustedDirectory $(TEST_DIR)/e2e" -c "qall" 2>&1 | grep -v "^🪟\|^🌙\|^📂\|^🧠"

#=============================================================================
# Development Targets
#=============================================================================

# Run tests in watch mode (requires inotify-tools)
test-watch:
	@echo "$(BLUE)Starting test watcher...$(NC)"
	@echo "$(YELLOW)Watching for changes in $(TEST_DIR)/ and ../lua/$(NC)"
	@while true; do \
		clear; \
		$(MAKE) test; \
		echo ""; \
		echo "$(YELLOW)Waiting for changes...$(NC)"; \
		inotifywait -q -e modify -r $(TEST_DIR)/ ../lua/ $(HELPERS_DIR)/; \
	done

# Run a specific test file
test-file:
	@if [ -z "$(FILE)" ]; then \
		echo "$(RED)Error: Please specify FILE=path/to/test_spec.lua$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)▶ Running Test File: $(FILE)$(NC)"
	@$(NVIM) --headless -c "PlenaryBustedFile $(FILE)" -c "qall"

# Debug a test file (opens in Neovim)
test-debug:
	@if [ -z "$(FILE)" ]; then \
		echo "$(RED)Error: Please specify FILE=path/to/test_spec.lua$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)▶ Debug Mode: $(FILE)$(NC)"
	@$(NVIM) -c "PlenaryBustedFile $(FILE)"

#=============================================================================
# Coverage and Reports
#=============================================================================

# Generate coverage report
coverage:
	@echo "$(BLUE)Generating Coverage Report...$(NC)"
	@$(NVIM) --headless \
		-c "lua require('plenary.test_harness').test_directory('$(TEST_DIR)', { minimal_init = '$(MINIMAL_INIT)', coverage = true })" \
		-c "qall"
	@echo "$(GREEN)Coverage report generated$(NC)"

# Generate test summary
summary:
	@echo "$(BLUE)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@echo "$(BLUE)  Test Summary Report$(NC)"
	@echo "$(BLUE)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@echo ""
	@echo "Test Files:"
	@find $(TEST_DIR) -name "*_spec.lua" -type f | wc -l
	@echo ""
	@echo "By Category:"
	@echo "  Unit Tests:         $$(find $(TEST_DIR)/unit -name "*_spec.lua" 2>/dev/null | wc -l)"
	@echo "  Integration Tests:  $$(find $(TEST_DIR)/integration -name "*_spec.lua" 2>/dev/null | wc -l)"
	@echo "  Workflow Tests:     $$(find $(TEST_DIR)/workflows -name "*_spec.lua" 2>/dev/null | wc -l)"
	@echo "  Neurodiversity:     $$(find $(TEST_DIR)/neurodiversity -name "*_spec.lua" 2>/dev/null | wc -l)"
	@echo "  Performance:        $$(find $(TEST_DIR)/performance -name "*_spec.lua" 2>/dev/null | wc -l)"
	@echo "  E2E Tests:          $$(find $(TEST_DIR)/e2e -name "*_spec.lua" 2>/dev/null | wc -l)"

#=============================================================================
# Maintenance Targets
#=============================================================================

# Clean test artifacts
clean:
	@echo "$(YELLOW)Cleaning test artifacts...$(NC)"
	@rm -rf $(FIXTURES_DIR)/mock_vault/* 2>/dev/null || true
	@rm -rf /tmp/test_vault* 2>/dev/null || true
	@rm -rf /tmp/test_site* 2>/dev/null || true
	@rm -f *.log 2>/dev/null || true
	@rm -rf coverage/ 2>/dev/null || true
	@echo "$(GREEN)✓ Cleaned$(NC)"

# Setup test environment
setup:
	@echo "$(BLUE)Setting up test environment...$(NC)"
	@mkdir -p $(TEST_DIR)/unit
	@mkdir -p $(TEST_DIR)/integration
	@mkdir -p $(TEST_DIR)/workflows
	@mkdir -p $(TEST_DIR)/neurodiversity
	@mkdir -p $(TEST_DIR)/performance
	@mkdir -p $(TEST_DIR)/e2e
	@mkdir -p $(HELPERS_DIR)
	@mkdir -p $(FIXTURES_DIR)
	@echo "$(GREEN)✓ Test directories created$(NC)"
	@if [ ! -f "$(MINIMAL_INIT)" ]; then \
		echo "$(YELLOW)Creating minimal_init.lua...$(NC)"; \
		$(MAKE) create-minimal-init; \
	fi
	@echo "$(GREEN)✓ Test environment ready$(NC)"

# Create minimal init file
create-minimal-init:
	@echo "-- Minimal Neovim configuration for testing" > $(MINIMAL_INIT)
	@echo "vim.opt.rtp:append('.')" >> $(MINIMAL_INIT)
	@echo "vim.opt.packpath:append('.')" >> $(MINIMAL_INIT)
	@echo "" >> $(MINIMAL_INIT)
	@echo "-- Load Plenary" >> $(MINIMAL_INIT)
	@echo "vim.opt.rtp:append(vim.fn.expand('~/.local/share/nvim/lazy/plenary.nvim'))" >> $(MINIMAL_INIT)
	@echo "" >> $(MINIMAL_INIT)
	@echo "-- Add test helpers to path" >> $(MINIMAL_INIT)
	@echo "vim.opt.rtp:append('tests')" >> $(MINIMAL_INIT)
	@echo "$(GREEN)✓ Created minimal_init.lua$(NC)"

#=============================================================================
# CI/CD Targets
#=============================================================================

# CI test runner (no colors, exit codes)
ci-test:
	@echo "Running CI tests..."
	@$(NVIM) --headless -c "PlenaryBustedDirectory $(TEST_DIR)" -c "qall" || exit 1

# CI performance check
ci-performance:
	@echo "Running performance checks..."
	@$(NVIM) --headless -c "PlenaryBustedDirectory $(TEST_DIR)/performance" -c "qall" || exit 1

#=============================================================================
# Help Target
#=============================================================================

help:
	@echo "$(BLUE)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@echo "$(BLUE)  PercyBrain Test Suite Commands$(NC)"
	@echo "$(BLUE)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@echo ""
	@echo "$(GREEN)Main Targets:$(NC)"
	@echo "  make test                 - Run all tests"
	@echo "  make test-unit           - Run unit tests only"
	@echo "  make test-integration    - Run integration tests"
	@echo "  make test-workflows      - Run workflow tests"
	@echo "  make test-neurodiversity - Run neurodiversity feature tests"
	@echo "  make test-performance    - Run performance benchmarks"
	@echo "  make test-e2e            - Run end-to-end tests"
	@echo ""
	@echo "$(GREEN)Development:$(NC)"
	@echo "  make test-watch          - Watch mode (auto-run on changes)"
	@echo "  make test-file FILE=...  - Run specific test file"
	@echo "  make test-debug FILE=... - Debug test file in Neovim"
	@echo ""
	@echo "$(GREEN)Reports:$(NC)"
	@echo "  make coverage            - Generate coverage report"
	@echo "  make summary             - Show test summary"
	@echo ""
	@echo "$(GREEN)Maintenance:$(NC)"
	@echo "  make clean               - Clean test artifacts"
	@echo "  make setup               - Setup test environment"
	@echo "  make help                - Show this help"
	@echo ""
	@echo "$(GREEN)CI/CD:$(NC)"
	@echo "  make ci-test             - Run tests for CI"
	@echo "  make ci-performance      - Run performance checks for CI"
	@echo ""
	@echo "$(YELLOW)Examples:$(NC)"
	@echo "  make test-file FILE=plenary/unit/config_spec.lua"
	@echo "  make test-watch          # Requires inotify-tools"
	@echo ""
