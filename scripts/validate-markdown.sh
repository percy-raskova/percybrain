#!/bin/bash
#
# OVIWrite Markdown Validation
# Ensures markdown files are properly formatted and organized
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}📝 Markdown Formatting Validation${NC}"
echo ""

ERRORS=0
WARNINGS=0

# Find all markdown files
MARKDOWN_FILES=$(find . -name "*.md" -not -path "./node_modules/*" -not -path "./.git/*" 2>/dev/null || true)

if [ -z "$MARKDOWN_FILES" ]; then
  echo -e "${GREEN}✅ No markdown files to validate${NC}"
  exit 0
fi

echo "Found $(echo "$MARKDOWN_FILES" | wc -l) markdown files"
echo ""

# Check 1: Basic formatting issues
echo -e "${BLUE}Checking basic formatting...${NC}"
while IFS= read -r file; do
  # Skip empty files
  if [ ! -s "$file" ]; then
    continue
  fi

  # Check for trailing whitespace (warning only)
  if grep -n " $" "$file" > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  $file: Has trailing whitespace${NC}"
    echo "   💡 Fix: sed -i 's/[[:space:]]*$//' $file"
    WARNINGS=$((WARNINGS + 1))
  fi

  # Check for inconsistent line endings (critical)
  if file "$file" | grep -q CRLF; then
    echo -e "${RED}❌ $file: Has Windows line endings (CRLF)${NC}"
    echo "   💡 Fix: dos2unix $file  OR  sed -i 's/\r$//' $file"
    ERRORS=$((ERRORS + 1))
  fi

  # Check for missing final newline (warning only)
  if [ -n "$(tail -c 1 "$file")" ]; then
    echo -e "${YELLOW}⚠️  $file: Missing final newline${NC}"
    echo "   💡 Fix: echo >> $file"
    WARNINGS=$((WARNINGS + 1))
  fi

done <<< "$MARKDOWN_FILES"

# Check 2: Heading structure
echo ""
echo -e "${BLUE}Checking heading structure...${NC}"
while IFS= read -r file; do
  # Skip empty files
  if [ ! -s "$file" ]; then
    continue
  fi

  # Check for missing top-level heading (warning for non-README)
  if ! grep -q "^# " "$file" && [[ ! "$file" =~ README ]]; then
    echo -e "${YELLOW}⚠️  $file: Missing top-level heading (# Title)${NC}"
    echo "   💡 Consider adding a main title"
    WARNINGS=$((WARNINGS + 1))
  fi

  # Check for skipped heading levels (warning only)
  # This is complex to check perfectly, so we'll just flag if we see ### before ##
  if grep -q "^### " "$file" && ! grep -q "^## " "$file"; then
    echo -e "${YELLOW}⚠️  $file: Appears to skip heading levels${NC}"
    echo "   💡 Use progressive heading hierarchy: # → ## → ###"
    WARNINGS=$((WARNINGS + 1))
  fi

done <<< "$MARKDOWN_FILES"

# Check 3: Common markdown issues
echo ""
echo -e "${BLUE}Checking markdown syntax...${NC}"
while IFS= read -r file; do
  # Skip empty files
  if [ ! -s "$file" ]; then
    continue
  fi

  # Check for unclosed code blocks (critical)
  BACKTICK_COUNT=$(grep -c '^```' "$file" || true)
  if [ $((BACKTICK_COUNT % 2)) -ne 0 ]; then
    echo -e "${RED}❌ $file: Unclosed code block (odd number of \`\`\`)${NC}"
    echo "   💡 Every \`\`\` must have a closing \`\`\`"
    ERRORS=$((ERRORS + 1))
  fi

  # Check for naked URLs (warning only, could be intentional)
  if grep -E "http[s]?://[^\)]+" "$file" | grep -v "\[.*\](http" > /dev/null 2>&1; then
    # Don't flag if it's already in a link
    if grep -oE "http[s]?://[^\) ]+" "$file" | grep -v "^\[" > /dev/null 2>&1; then
      echo -e "${YELLOW}⚠️  $file: Contains bare URLs${NC}"
      echo "   💡 Consider using: [Link Text](URL)"
      WARNINGS=$((WARNINGS + 1))
    fi
  fi

done <<< "$MARKDOWN_FILES"

# Check 4: Documentation-specific checks
echo ""
echo -e "${BLUE}Checking documentation best practices...${NC}"

# Check CLAUDE.md exists
if [ ! -f "CLAUDE.md" ]; then
  echo -e "${YELLOW}⚠️  CLAUDE.md not found${NC}"
  echo "   💡 Create CLAUDE.md to help AI assistants understand your codebase"
  WARNINGS=$((WARNINGS + 1))
fi

# Check README.md exists
if [ ! -f "README.md" ]; then
  echo -e "${RED}❌ README.md not found${NC}"
  echo "   💡 Every project should have a README.md"
  ERRORS=$((ERRORS + 1))
fi

# Summary
echo ""
echo -e "${BLUE}═══════════════════════════════════════${NC}"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
  echo -e "${GREEN}✅ All markdown files look good!${NC}"
  exit 0
elif [ $ERRORS -eq 0 ]; then
  echo -e "${YELLOW}⚠️  Found $WARNINGS warnings (non-blocking)${NC}"
  echo ""
  echo "Warnings don't block commits, but fixing them improves quality."
  echo "Most have auto-fix suggestions above (💡)."
  exit 0
else
  echo -e "${RED}❌ Found $ERRORS critical errors, $WARNINGS warnings${NC}"
  echo ""
  echo "Critical errors must be fixed before committing."
  echo "See auto-fix suggestions above (💡)."
  echo ""
  echo "To skip temporarily:"
  echo "  SKIP_VALIDATION=1 git commit"
  exit 1
fi
