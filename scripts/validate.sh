#!/bin/bash
#
# OVIWrite Master Validation Script
# Entry point for all validation checks
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

FULL_MODE=false
CHECK_SPECIFIC=""
HELP=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --full)
      FULL_MODE=true
      shift
      ;;
    --check)
      CHECK_SPECIFIC="$2"
      shift 2
      ;;
    --help|-h)
      HELP=true
      shift
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      HELP=true
      shift
      ;;
  esac
done

# Show help
if [ "$HELP" = true ]; then
  cat <<EOF
${BLUE}OVIWrite Validation Script${NC}

Usage: ./scripts/validate.sh [OPTIONS]

Options:
  --full              Run full validation (Layer 1-4, includes startup test)
  --check <name>      Run specific check only
  --help, -h          Show this help message

Specific Checks:
  duplicates          Check for duplicate plugin files
  deprecated-apis     Check for deprecated API usage
  markdown            Check markdown formatting
  startup             Test Neovim startup (Layer 3)
  health              Run health check (Layer 3)
  plugins             Test plugin loading (Layer 3)
  docs                Validate documentation sync (Layer 4)

Examples:
  ${GREEN}./scripts/validate.sh${NC}
    Run standard validation (Layer 1-2)

  ${GREEN}./scripts/validate.sh --full${NC}
    Run full validation including startup test

  ${GREEN}./scripts/validate.sh --check duplicates${NC}
    Check only for duplicate plugins

  ${GREEN}./scripts/validate.sh --check startup${NC}
    Test Neovim startup

Exit Codes:
  0  - Validation passed
  1  - Validation failed (errors found)

For development:
  ${YELLOW}SKIP_VALIDATION=1 git commit${NC}  - Skip pre-commit validation

EOF
  exit 0
fi

# Run specific check
if [ -n "$CHECK_SPECIFIC" ]; then
  echo -e "${BLUE}🔍 Running specific check: $CHECK_SPECIFIC${NC}"
  echo ""

  case $CHECK_SPECIFIC in
    duplicates)
      exec "$SCRIPT_DIR/validate-layer1.sh" --only-duplicates
      ;;
    deprecated-apis)
      exec "$SCRIPT_DIR/validate-layer1.sh" --only-deprecated
      ;;
    markdown)
      exec "$SCRIPT_DIR/validate-markdown.sh"
      ;;
    startup)
      exec "$SCRIPT_DIR/validate-startup.sh"
      ;;
    health)
      exec "$SCRIPT_DIR/validate-health.sh"
      ;;
    plugins)
      exec nvim --headless -l "$SCRIPT_DIR/validate-plugin-loading.lua"
      ;;
    docs)
      exec nvim --headless -l "$SCRIPT_DIR/validate-documentation.lua"
      ;;
    *)
      echo -e "${RED}❌ Unknown check: $CHECK_SPECIFIC${NC}"
      echo ""
      echo "Available checks: duplicates, deprecated-apis, markdown, startup, health, plugins, docs"
      exit 1
      ;;
  esac
fi

# Normal validation flow
echo -e "${BLUE}╔════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   OVIWrite Validation Suite       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════╝${NC}"
echo ""

if [ "$FULL_MODE" = true ]; then
  echo -e "${YELLOW}Mode: Full validation (Layer 1-4)${NC}"
else
  echo -e "${YELLOW}Mode: Standard validation (Layer 1-2)${NC}"
  echo -e "${YELLOW}      Use --full for complete validation${NC}"
fi

echo ""

OVERALL_STATUS=0

# Layer 1: Static validation
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}Layer 1: Static Validation${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
if ! "$SCRIPT_DIR/validate-layer1.sh"; then
  OVERALL_STATUS=1
  echo -e "${RED}❌ Layer 1 failed${NC}"
else
  echo -e "${GREEN}✅ Layer 1 passed${NC}"
fi
echo ""

# Layer 2: Structural validation
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}Layer 2: Structural Validation${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
if ! nvim --headless -l "$SCRIPT_DIR/validate-layer2.lua"; then
  OVERALL_STATUS=1
  echo -e "${RED}❌ Layer 2 failed${NC}"
else
  echo -e "${GREEN}✅ Layer 2 passed${NC}"
fi
echo ""

# Markdown validation (warnings only, doesn't block)
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}Markdown Formatting${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
"$SCRIPT_DIR/validate-markdown.sh" || true  # Never blocks, just warns
echo ""

# Full mode: Layer 3 and 4
if [ "$FULL_MODE" = true ]; then
  # Layer 3a: Startup test
  echo -e "${BLUE}═══════════════════════════════════════${NC}"
  echo -e "${BLUE}Layer 3a: Startup Test${NC}"
  echo -e "${BLUE}═══════════════════════════════════════${NC}"
  if ! "$SCRIPT_DIR/validate-startup.sh"; then
    OVERALL_STATUS=1
    echo -e "${RED}❌ Layer 3a failed${NC}"
  else
    echo -e "${GREEN}✅ Layer 3a passed${NC}"
  fi
  echo ""

  # Layer 3b: Health check
  echo -e "${BLUE}═══════════════════════════════════════${NC}"
  echo -e "${BLUE}Layer 3b: Health Check${NC}"
  echo -e "${BLUE}═══════════════════════════════════════${NC}"
  if ! "$SCRIPT_DIR/validate-health.sh"; then
    OVERALL_STATUS=1
    echo -e "${RED}❌ Layer 3b failed${NC}"
  else
    echo -e "${GREEN}✅ Layer 3b passed${NC}"
  fi
  echo ""

  # Layer 3c: Plugin loading (optional, can be slow)
  # Commented out by default, uncomment for full plugin testing
  # echo -e "${BLUE}═══════════════════════════════════════${NC}"
  # echo -e "${BLUE}Layer 3c: Plugin Loading${NC}"
  # echo -e "${BLUE}═══════════════════════════════════════${NC}"
  # if ! nvim --headless -l "$SCRIPT_DIR/validate-plugin-loading.lua"; then
  #   OVERALL_STATUS=1
  #   echo -e "${RED}❌ Layer 3c failed${NC}"
  # else
  #   echo -e "${GREEN}✅ Layer 3c passed${NC}"
  # fi
  # echo ""

  # Layer 4: Documentation sync
  echo -e "${BLUE}═══════════════════════════════════════${NC}"
  echo -e "${BLUE}Layer 4: Documentation Sync${NC}"
  echo -e "${BLUE}═══════════════════════════════════════${NC}"
  # Note: Layer 4 always exits 0 (warnings only)
  nvim --headless -l "$SCRIPT_DIR/validate-documentation.lua"
  echo ""
fi

# Final summary
echo -e "${BLUE}═══════════════════════════════════════${NC}"
if [ $OVERALL_STATUS -eq 0 ]; then
  echo -e "${GREEN}╔════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║  ✅ ALL VALIDATIONS PASSED         ║${NC}"
  echo -e "${GREEN}╚════════════════════════════════════╝${NC}"

  if [ "$FULL_MODE" = false ]; then
    echo ""
    echo -e "${YELLOW}💡 Tip: Run with --full before pushing for complete validation${NC}"
  fi
else
  echo -e "${RED}╔════════════════════════════════════╗${NC}"
  echo -e "${RED}║  ❌ VALIDATION FAILED              ║${NC}"
  echo -e "${RED}╚════════════════════════════════════╝${NC}"
  echo ""
  echo -e "${YELLOW}Fix errors above before committing/pushing${NC}"
  echo -e "${YELLOW}Or skip temporarily: ${NC}SKIP_VALIDATION=1 git commit"
fi

exit $OVERALL_STATUS
