#!/bin/bash
#
# Setup Git Hooks for PercyBrain
# Installs pre-commit and pre-push hooks
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
GIT_HOOKS_DIR="$PROJECT_ROOT/.git/hooks"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Git Hooks Setup for PercyBrain   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════╝${NC}"
echo ""

# Check if we're in a git repository
if [ ! -d "$PROJECT_ROOT/.git" ]; then
  echo -e "${RED}✗ Not a git repository${NC}"
  echo "Run this from the root of your git repository"
  exit 1
fi

# Create hooks directory if it doesn't exist
mkdir -p "$GIT_HOOKS_DIR"

#
# Install pre-commit hook
#
echo -e "${YELLOW}Installing pre-commit hook...${NC}"
if [ -f "$SCRIPT_DIR/hooks/pre-commit" ]; then
  cp "$SCRIPT_DIR/hooks/pre-commit" "$GIT_HOOKS_DIR/pre-commit"
  chmod +x "$GIT_HOOKS_DIR/pre-commit"
  echo -e "${GREEN}✓${NC} pre-commit hook installed"
else
  echo -e "${RED}✗${NC} pre-commit hook not found at $SCRIPT_DIR/hooks/pre-commit"
  exit 1
fi

#
# Install pre-push hook
#
echo -e "${YELLOW}Installing pre-push hook...${NC}"
if [ -f "$SCRIPT_DIR/hooks/pre-push" ]; then
  cp "$SCRIPT_DIR/hooks/pre-push" "$GIT_HOOKS_DIR/pre-push"
  chmod +x "$GIT_HOOKS_DIR/pre-push"
  echo -e "${GREEN}✓${NC} pre-push hook installed"
else
  echo -e "${RED}✗${NC} pre-push hook not found at $SCRIPT_DIR/hooks/pre-push"
  exit 1
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅ HOOKS INSTALLED SUCCESSFULLY   ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════╝${NC}"
echo ""

echo "Installed hooks:"
echo -e "  ${GREEN}✓${NC} pre-commit  - StyLua formatting + Selene linting"
echo -e "  ${GREEN}✓${NC} pre-push    - Full validation + PercyBrain tests"
echo ""

echo "Usage:"
echo "  ${BLUE}git commit${NC}  - Runs pre-commit checks (format + lint)"
echo "  ${BLUE}git push${NC}    - Runs pre-push checks (full validation)"
echo ""

echo "Skip hooks when needed:"
echo "  ${YELLOW}SKIP_HOOKS=1 git commit${NC}"
echo "  ${YELLOW}SKIP_HOOKS=1 git push${NC}"
echo ""

echo "Test hooks:"
echo "  ${BLUE}.git/hooks/pre-commit${NC}"
echo "  ${BLUE}.git/hooks/pre-push${NC}"
