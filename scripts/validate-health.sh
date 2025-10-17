#!/bin/bash
#
# OVIWrite Layer 3 Validation: Health Check Automation
# Tests: :checkhealth reports no critical errors
#

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🏥 Layer 3: Health Check Validation${NC}"
echo "========================================"
echo ""

HEALTH_REPORT="/tmp/health-report.txt"

echo -e "${BLUE}📋 Running :checkhealth...${NC}"
echo ""

# Run checkhealth and capture output
nvim --headless \
  -c "checkhealth" \
  -c "write! $HEALTH_REPORT" \
  -c "quit" \
  2>&1 || true

if [ ! -f "$HEALTH_REPORT" ]; then
  echo -e "${RED}❌ Failed to generate health report${NC}"
  exit 1
fi

echo "Health report generated: $HEALTH_REPORT"
echo ""

# Parse health report
ERRORS=$(grep -c "ERROR" "$HEALTH_REPORT" 2>/dev/null || echo "0")
WARNINGS=$(grep -c "WARNING" "$HEALTH_REPORT" 2>/dev/null || echo "0")
OK_CHECKS=$(grep -c "OK" "$HEALTH_REPORT" 2>/dev/null || echo "0")

echo "Health Check Summary:"
echo "--------------------"
echo -e "  ✓ OK checks:   ${GREEN}$OK_CHECKS${NC}"
echo -e "  ⚠ Warnings:    ${YELLOW}$WARNINGS${NC}"
echo -e "  ✗ Errors:      ${RED}$ERRORS${NC}"
echo ""

# Show error details if present
if [ "$ERRORS" -gt 0 ]; then
  echo -e "${RED}Error Details:${NC}"
  echo "----------------------------------------"
  grep -B2 -A2 "ERROR" "$HEALTH_REPORT" | head -50
  echo "----------------------------------------"
  echo ""
fi

# Show warning details (first 10 only)
if [ "$WARNINGS" -gt 0 ]; then
  echo -e "${YELLOW}Warning Details (first 10):${NC}"
  echo "----------------------------------------"
  grep -B1 -A1 "WARNING" "$HEALTH_REPORT" | head -30
  echo "----------------------------------------"
  echo ""
fi

# Determine result
# Note: Warnings are informational, only errors block
if [ "$ERRORS" -eq 0 ]; then
  echo -e "${GREEN}✅ Health check passed${NC}"
  if [ "$WARNINGS" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  $WARNINGS warnings detected (non-blocking)${NC}"
    echo -e "${YELLOW}   Review full report: $HEALTH_REPORT${NC}"
  fi
  exit 0
else
  echo -e "${RED}❌ Health check failed${NC}"
  echo -e "${RED}   $ERRORS critical errors detected${NC}"
  echo ""
  echo -e "${YELLOW}💡 Review full report: $HEALTH_REPORT${NC}"
  echo -e "${YELLOW}   Fix critical errors before merging${NC}"
  exit 1
fi
