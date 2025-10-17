#!/bin/bash
#
# OVIWrite Development Environment Setup
# Installs git hooks and prepares local development environment
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

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  OVIWrite Development Setup           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Check 1: Neovim
echo -e "${BLUE}🔍 Checking dependencies...${NC}"
echo ""

if ! command -v nvim >/dev/null 2>&1; then
  echo -e "${RED}❌ Neovim not found${NC}"
  echo "   Install from: https://neovim.io"
  exit 1
else
  NVIM_VERSION=$(nvim --version | head -1)
  echo -e "${GREEN}✓ Neovim: $NVIM_VERSION${NC}"

  # Check version (should be >= 0.8.0)
  NVIM_MAJOR=$(nvim --version | head -1 | grep -oE 'v[0-9]+\.[0-9]+' | cut -d'v' -f2 | cut -d'.' -f1)
  NVIM_MINOR=$(nvim --version | head -1 | grep -oE 'v[0-9]+\.[0-9]+' | cut -d'v' -f2 | cut -d'.' -f2)

  if [ "$NVIM_MAJOR" -eq 0 ] && [ "$NVIM_MINOR" -lt 8 ]; then
    echo -e "${YELLOW}⚠️  Neovim version is older than recommended (0.8.0+)${NC}"
    echo "   Some features may not work correctly"
  fi
fi

# Check 2: Git
if ! command -v git >/dev/null 2>&1; then
  echo -e "${RED}❌ Git not found${NC}"
  exit 1
else
  GIT_VERSION=$(git --version)
  echo -e "${GREEN}✓ Git: $GIT_VERSION${NC}"
fi

# Check 3: Optional tools
if command -v luacheck >/dev/null 2>&1; then
  echo -e "${GREEN}✓ luacheck (optional): $(luacheck --version 2>&1 | head -1)${NC}"
else
  echo -e "${YELLOW}○ luacheck (optional): Not installed${NC}"
fi

if command -v rg >/dev/null 2>&1; then
  echo -e "${GREEN}✓ ripgrep (optional): $(rg --version | head -1)${NC}"
else
  echo -e "${YELLOW}○ ripgrep (optional): Not installed${NC}"
fi

echo ""

# Install git hooks
echo -e "${BLUE}📦 Installing git hooks...${NC}"

if [ ! -d ".git" ]; then
  echo -e "${RED}❌ Not a git repository${NC}"
  echo "   Initialize with: git init"
  exit 1
fi

# Install pre-commit hook
if [ -f ".git/hooks/pre-commit" ]; then
  echo -e "${YELLOW}⚠️  Existing pre-commit hook found${NC}"
  echo "   Backing up to .git/hooks/pre-commit.backup"
  cp .git/hooks/pre-commit .git/hooks/pre-commit.backup
fi

cp scripts/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
echo -e "${GREEN}✓ Installed pre-commit hook${NC}"

# Install pre-push hook
if [ -f ".git/hooks/pre-push" ]; then
  echo -e "${YELLOW}⚠️  Existing pre-push hook found${NC}"
  echo "   Backing up to .git/hooks/pre-push.backup"
  cp .git/hooks/pre-push .git/hooks/pre-push.backup
fi

cp scripts/pre-push .git/hooks/pre-push
chmod +x .git/hooks/pre-push
echo -e "${GREEN}✓ Installed pre-push hook${NC}"

echo ""

# Make validation scripts executable
echo -e "${BLUE}🔧 Preparing validation scripts...${NC}"

chmod +x scripts/*.sh 2>/dev/null || true
chmod +x scripts/validate-*.lua 2>/dev/null || true
chmod +x scripts/extract-keymaps.lua 2>/dev/null || true

echo -e "${GREEN}✓ Made scripts executable${NC}"
echo ""

# Create test environment directory
echo -e "${BLUE}📁 Creating isolated test directory...${NC}"

mkdir -p .nvim-test
echo ".nvim-test/" >> .gitignore 2>/dev/null || true

echo -e "${GREEN}✓ Created .nvim-test/ directory${NC}"
echo ""

# Test validation scripts
echo -e "${BLUE}🧪 Testing validation scripts...${NC}"

if ./scripts/validate-layer1.sh >/dev/null 2>&1; then
  echo -e "${GREEN}✓ Layer 1 validation works${NC}"
else
  echo -e "${YELLOW}⚠️  Layer 1 validation test failed (may have errors in config)${NC}"
fi

if nvim --headless -l scripts/validate-layer2.lua >/dev/null 2>&1; then
  echo -e "${GREEN}✓ Layer 2 validation works${NC}"
else
  echo -e "${YELLOW}⚠️  Layer 2 validation test failed (may have plugin errors)${NC}"
fi

echo ""

# Success summary
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅ Setup Complete!                   ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Available commands:${NC}"
echo ""
echo -e "  ${GREEN}./scripts/validate.sh${NC}"
echo "    Quick validation (Layer 1-2, ~10 seconds)"
echo ""
echo -e "  ${GREEN}./scripts/validate.sh --full${NC}"
echo "    Full validation (Layer 1-4, includes startup test)"
echo ""
echo -e "  ${GREEN}./scripts/validate.sh --check <name>${NC}"
echo "    Run specific check (duplicates, startup, health, docs)"
echo ""
echo -e "  ${GREEN}SKIP_VALIDATION=1 git commit${NC}"
echo "    Skip validation temporarily (use sparingly)"
echo ""
echo -e "${BLUE}Git hooks installed:${NC}"
echo "  - pre-commit: Runs Layer 1-2 before each commit"
echo "  - pre-push: Runs Layer 1-3 before each push"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Run: ./scripts/validate.sh --full"
echo "  2. Fix any validation errors found"
echo "  3. Start developing with confidence!"
echo ""
