#!/bin/bash
#
# OVIWrite Layer 1 Validation: Static Analysis
# Checks: Lua syntax, duplicate plugins, deprecated APIs, file organization
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
NC='\033[0m' # No Color

ERROR_COUNT=0
WARNING_COUNT=0

# Parse options
ONLY_DUPLICATES=false
ONLY_DEPRECATED=false

for arg in "$@"; do
  case $arg in
    --only-duplicates) ONLY_DUPLICATES=true ;;
    --only-deprecated) ONLY_DEPRECATED=true ;;
  esac
done

echo -e "${BLUE}🔍 Layer 1: Static Validation${NC}"
echo "========================================"

# Check 1: Lua Syntax Validation
if [ "$ONLY_DUPLICATES" = false ] && [ "$ONLY_DEPRECATED" = false ]; then
  echo ""
  echo -e "${BLUE}📝 Checking Lua syntax...${NC}"

  SYNTAX_ERRORS=0
  while IFS= read -r file; do
    if ! nvim --headless -c "luafile $file" -c "quit" 2>&1 | grep -qi error; then
      echo -e "  ${GREEN}✓${NC} $file"
    else
      echo -e "  ${RED}✗${NC} $file"
      nvim --headless -c "luafile $file" -c "quit" 2>&1 | grep -i error || true
      ((SYNTAX_ERRORS++)) || true
      ((ERROR_COUNT++)) || true
    fi
  done < <(find lua/ -name "*.lua" 2>/dev/null || true)

  if [ $SYNTAX_ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ All Lua files have valid syntax${NC}"
  else
    echo -e "${RED}❌ Found $SYNTAX_ERRORS Lua syntax errors${NC}"
  fi
fi

# Check 2: Duplicate Plugin Detection
if [ "$ONLY_DEPRECATED" = false ]; then
  echo ""
  echo -e "${BLUE}🔎 Checking for duplicate plugin files...${NC}"

  # Find all plugin files (excluding init.lua)
  PLUGIN_FILES=$(find lua/plugins -maxdepth 1 -name "*.lua" -not -name "init.lua" 2>/dev/null || true)

  if [ -z "$PLUGIN_FILES" ]; then
    echo -e "${YELLOW}⚠️  No plugin files found in lua/plugins/${NC}"
  else
    # Normalize plugin names (lowercase, remove hyphens/underscores)
    NORMALIZED_NAMES=$(echo "$PLUGIN_FILES" | \
      sed 's|lua/plugins/||; s|\.lua$||' | \
      tr '[:upper:]' '[:lower:]' | \
      tr -d '_-' | \
      sort)

    # Find duplicates
    DUPLICATES=$(echo "$NORMALIZED_NAMES" | uniq -d)

    if [ -z "$DUPLICATES" ]; then
      echo -e "${GREEN}✅ No duplicate plugin files detected${NC}"
    else
      echo -e "${RED}❌ Duplicate plugin files detected:${NC}"
      echo ""

      for normalized in $DUPLICATES; do
        echo -e "  ${RED}Collision:${NC} $normalized"
        # Find original filenames that created this collision
        echo "$PLUGIN_FILES" | while read -r file; do
          basename=$(basename "$file" .lua | tr '[:upper:]' '[:lower:]' | tr -d '_-')
          if [ "$basename" = "$normalized" ]; then
            echo -e "    - $(basename "$file")"
          fi
        done
        echo ""
      done

      echo -e "${YELLOW}💡 Fix: Keep only one version of each plugin configuration${NC}"
      ((ERROR_COUNT++)) || true
    fi
  fi
fi

# Check 3: Deprecated API Scanning
if [ "$ONLY_DUPLICATES" = false ]; then
  echo ""
  echo -e "${BLUE}🔧 Scanning for deprecated APIs...${NC}"

  PATTERNS_FILE="$SCRIPT_DIR/deprecated-patterns.txt"

  if [ ! -f "$PATTERNS_FILE" ]; then
    # Create default patterns file if it doesn't exist
    cat > "$PATTERNS_FILE" <<'EOF'
# Format: PATTERN|REPLACEMENT|SEVERITY
# SEVERITY: ERROR (blocks commit), WARNING (notifies only)
vim\.highlight\.on_yank|vim.hl.on_yank|ERROR
config\s*=\s*\{\}|opts = {}|WARNING
setup_ts_grammar|[REMOVED - Delete this line]|ERROR
require\s*\(\s*["']nvim-treesitter\.configs["']\s*\)\.setup|Use opts = {} in plugin spec|WARNING
EOF
    echo -e "${YELLOW}📝 Created default deprecated-patterns.txt${NC}"
  fi

  DEPRECATED_FOUND=0

  while IFS='|' read -r pattern replacement severity; do
    # Skip comments and empty lines
    [[ "$pattern" =~ ^#.*$ ]] && continue
    [ -z "$pattern" ] && continue

    # Search for pattern in Lua files
    if grep -rn -E "$pattern" lua/ 2>/dev/null | grep -v "deprecated-patterns.txt"; then
      ((DEPRECATED_FOUND++)) || true

      if [ "$severity" = "ERROR" ]; then
        echo -e "${RED}❌ [ERROR] Deprecated API found:${NC}"
        ((ERROR_COUNT++)) || true
      else
        echo -e "${YELLOW}⚠️  [WARNING] Deprecated API found:${NC}"
        ((WARNING_COUNT++)) || true
      fi

      echo -e "   ${BLUE}Pattern:${NC} $pattern"
      echo -e "   ${GREEN}Use instead:${NC} $replacement"
      echo ""
    fi
  done < "$PATTERNS_FILE"

  if [ $DEPRECATED_FOUND -eq 0 ]; then
    echo -e "${GREEN}✅ No deprecated APIs detected${NC}"
  fi
fi

# Check 4: File Organization Rules
if [ "$ONLY_DUPLICATES" = false ] && [ "$ONLY_DEPRECATED" = false ]; then
  echo ""
  echo -e "${BLUE}📁 Checking file organization...${NC}"

  ORG_ERRORS=0

  # Rule 1: Only lua/plugins/init.lua and lua/config/init.lua allowed as init.lua
  INVALID_INITS=$(find lua/ -name "init.lua" \
    -not -path "lua/plugins/init.lua" \
    -not -path "lua/config/init.lua" 2>/dev/null || true)

  if [ -n "$INVALID_INITS" ]; then
    echo -e "${RED}❌ Invalid init.lua files found:${NC}"
    echo "$INVALID_INITS" | while read -r file; do
      echo -e "  - $file"
    done
    echo -e "${YELLOW}💡 Fix: Rename to descriptive filename or move to lua/utils/${NC}"
    echo ""
    ((ORG_ERRORS++)) || true
    ((ERROR_COUNT++)) || true
  fi

  # Rule 2: Check for non-plugin specs in lua/plugins/*.lua
  # (Files that return module-like structures instead of lazy.nvim plugin specs)
  while IFS= read -r file; do
    [ -z "$file" ] && continue
    [ "$(basename "$file")" = "init.lua" ] && continue

    # Quick check: does file contain typical module pattern without plugin spec?
    if grep -q "^local M = {}" "$file" 2>/dev/null && \
       ! grep -q "return {" "$file" 2>/dev/null; then
      echo -e "${RED}❌ Potential utility module in plugins/:${NC} $file"
      echo -e "${YELLOW}💡 Fix: Move to lua/utils/ or lua/lib/${NC}"
      echo ""
      ((ORG_ERRORS++)) || true
      ((ERROR_COUNT++)) || true
    fi
  done < <(find lua/plugins -maxdepth 1 -name "*.lua" 2>/dev/null || true)

  if [ $ORG_ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ File organization is correct${NC}"
  fi
fi

# Summary
echo ""
echo "========================================"
if [ $ERROR_COUNT -eq 0 ]; then
  echo -e "${GREEN}✅ Layer 1 validation passed${NC}"
  if [ $WARNING_COUNT -gt 0 ]; then
    echo -e "${YELLOW}⚠️  $WARNING_COUNT warnings (non-blocking)${NC}"
  fi
  exit 0
else
  echo -e "${RED}❌ Layer 1 validation failed${NC}"
  echo -e "${RED}   Errors: $ERROR_COUNT${NC}"
  if [ $WARNING_COUNT -gt 0 ]; then
    echo -e "${YELLOW}   Warnings: $WARNING_COUNT${NC}"
  fi
  echo ""
  echo "Run './scripts/validate.sh --check duplicates' or '--check deprecated-apis' for specific checks"
  exit 1
fi
