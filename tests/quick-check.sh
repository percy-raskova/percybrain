#!/bin/bash
# PercyBrain Quick Health Check
# Fast verification that everything is working
# Usage: ./quick-check.sh

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  PercyBrain Quick Health Check"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Track overall status
ALL_GOOD=1

check() {
    local description="$1"
    local command="$2"

    if eval "$command" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $description"
    else
        echo -e "${RED}✗${NC} $description"
        ALL_GOOD=0
    fi
}

# Core checks
check "Neovim installed" "command -v nvim"
check "IWE LSP installed" "command -v iwe"
check "SemBr installed" "command -v sembr"
check "Ollama installed" "command -v ollama"

# Config files
check "Core config exists" "[ -f ~/.config/nvim/lua/config/zettelkasten.lua ]"
check "Ollama plugin exists" "[ -f ~/.config/nvim/lua/plugins/ollama.lua ]"

# Zettelkasten structure
check "Zettelkasten directory" "[ -d ~/Zettelkasten ]"
check "Templates directory" "[ -d ~/Zettelkasten/templates ]"

# Template files
TEMPLATE_COUNT=0
for template in permanent literature project meeting fleeting; do
    if [ -f ~/Zettelkasten/templates/${template}.md ]; then
        ((TEMPLATE_COUNT++))
    fi
done

if [ "$TEMPLATE_COUNT" -eq 5 ]; then
    echo -e "${GREEN}✓${NC} All 5 templates present"
else
    echo -e "${YELLOW}⊘${NC} Only $TEMPLATE_COUNT/5 templates found"
    [ "$TEMPLATE_COUNT" -lt 5 ] && ALL_GOOD=0
fi

# Ollama model check
if command -v ollama &> /dev/null; then
    if ollama list 2>/dev/null | grep -q "llama3.2"; then
        echo -e "${GREEN}✓${NC} llama3.2 model installed"
    else
        echo -e "${YELLOW}⊘${NC} llama3.2 model not installed"
    fi
fi

# Ollama service check
if pgrep -x ollama > /dev/null; then
    echo -e "${GREEN}✓${NC} Ollama service running"
else
    echo -e "${YELLOW}⊘${NC} Ollama service not running (will auto-start when needed)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$ALL_GOOD" -eq 1 ]; then
    echo -e "${GREEN}🎉 PercyBrain is healthy!${NC}"
    echo ""
    echo "Try these commands in Neovim:"
    echo "  <leader>zn  - Create new note"
    echo "  <leader>aa  - AI assistant menu"
    echo "  <leader>zf  - Find notes"
    exit 0
else
    echo -e "${RED}⚠️  Some issues detected${NC}"
    echo ""
    echo "Run full test suite for details:"
    echo "  ./percybrain-test.sh --verbose"
    exit 1
fi
