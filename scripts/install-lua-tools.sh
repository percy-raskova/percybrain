#!/bin/bash
#
# Install Modern Lua Development Tools
# - StyLua: Code formatter (Rust)
# - Selene: Linter (Rust)
# - lua-language-server: LSP with diagnostics
#

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

INSTALL_DIR="${HOME}/.local/bin"
CI_MODE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --ci)
      CI_MODE=true
      shift
      ;;
    --help|-h)
      cat <<EOF
${BLUE}Install Modern Lua Development Tools${NC}

Usage: ./scripts/install-lua-tools.sh [OPTIONS]

Tools installed:
  StyLua              - Fast Lua code formatter (Rust)
  Selene              - Modern Lua linter (Rust)
  lua-language-server - LSP with diagnostics and type checking

Options:
  --ci        CI mode (non-interactive, optimized for GitHub Actions)
  --help, -h  Show this help message

Installation directory: ${INSTALL_DIR}

Examples:
  ${GREEN}./scripts/install-lua-tools.sh${NC}
    Install all tools locally

  ${GREEN}./scripts/install-lua-tools.sh --ci${NC}
    Install for CI environment (GitHub Actions)

EOF
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      exit 1
      ;;
  esac
done

echo -e "${BLUE}╔════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Lua Development Tools Installer  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════╝${NC}"
echo ""

# Create install directory
mkdir -p "$INSTALL_DIR"

# Detect OS and Architecture
OS="unknown"
ARCH="unknown"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
else
    echo -e "${RED}✗ Unsupported OS: $OSTYPE${NC}"
    exit 1
fi

ARCH=$(uname -m)
case "$ARCH" in
    x86_64|amd64)
        ARCH="x86_64"
        ;;
    arm64|aarch64)
        ARCH="aarch64"
        ;;
    *)
        echo -e "${RED}✗ Unsupported architecture: $ARCH${NC}"
        exit 1
        ;;
esac

echo -e "${GREEN}✓${NC} OS: $OS"
echo -e "${GREEN}✓${NC} Architecture: $ARCH"
echo -e "${GREEN}✓${NC} Install directory: $INSTALL_DIR"
echo ""

#
# Install StyLua (Lua formatter)
#
echo -e "${BLUE}═══ Installing StyLua ═══${NC}"

if command -v stylua &> /dev/null; then
    STYLUA_VERSION=$(stylua --version | awk '{print $2}')
    echo -e "${GREEN}✓${NC} StyLua already installed: v${STYLUA_VERSION}"
else
    echo "Downloading StyLua..."

    STYLUA_VERSION="0.20.0"

    if [ "$OS" = "linux" ]; then
        STYLUA_URL="https://github.com/JohnnyMorganz/StyLua/releases/download/v${STYLUA_VERSION}/stylua-linux-${ARCH}.zip"
    else
        STYLUA_URL="https://github.com/JohnnyMorganz/StyLua/releases/download/v${STYLUA_VERSION}/stylua-macos-${ARCH}.zip"
    fi

    TEMP_DIR=$(mktemp -d)
    trap "rm -rf $TEMP_DIR" EXIT

    if curl -L "$STYLUA_URL" -o "$TEMP_DIR/stylua.zip"; then
        unzip -q "$TEMP_DIR/stylua.zip" -d "$TEMP_DIR"
        chmod +x "$TEMP_DIR/stylua"
        mv "$TEMP_DIR/stylua" "$INSTALL_DIR/stylua"
        echo -e "${GREEN}✓${NC} StyLua v${STYLUA_VERSION} installed successfully"
    else
        echo -e "${RED}✗${NC} Failed to download StyLua"
        exit 1
    fi
fi
echo ""

#
# Install Selene (Lua linter)
#
echo -e "${BLUE}═══ Installing Selene ═══${NC}"

if command -v selene &> /dev/null; then
    SELENE_VERSION=$(selene --version | awk '{print $2}')
    echo -e "${GREEN}✓${NC} Selene already installed: v${SELENE_VERSION}"
else
    echo "Downloading Selene..."

    SELENE_VERSION="0.29.0"

    if [ "$OS" = "linux" ]; then
        SELENE_URL="https://github.com/Kampfkarren/selene/releases/download/${SELENE_VERSION}/selene-${SELENE_VERSION}-linux-${ARCH}.zip"
    else
        SELENE_URL="https://github.com/Kampfkarren/selene/releases/download/${SELENE_VERSION}/selene-${SELENE_VERSION}-macos-${ARCH}.zip"
    fi

    TEMP_DIR=$(mktemp -d)
    trap "rm -rf $TEMP_DIR" EXIT

    if curl -L "$SELENE_URL" -o "$TEMP_DIR/selene.zip"; then
        unzip -q "$TEMP_DIR/selene.zip" -d "$TEMP_DIR"
        chmod +x "$TEMP_DIR/selene"
        mv "$TEMP_DIR/selene" "$INSTALL_DIR/selene"
        echo -e "${GREEN}✓${NC} Selene v${SELENE_VERSION} installed successfully"
    else
        echo -e "${RED}✗${NC} Failed to download Selene"
        exit 1
    fi
fi
echo ""

#
# Install lua-language-server (LSP)
#
echo -e "${BLUE}═══ Installing lua-language-server ═══${NC}"

if command -v lua-language-server &> /dev/null; then
    LUA_LS_VERSION=$(lua-language-server --version 2>&1 | head -n1 || echo "unknown")
    echo -e "${GREEN}✓${NC} lua-language-server already installed: $LUA_LS_VERSION"
else
    echo "Downloading lua-language-server..."

    LUA_LS_VERSION="3.7.4"

    if [ "$OS" = "linux" ]; then
        LUA_LS_URL="https://github.com/LuaLS/lua-language-server/releases/download/${LUA_LS_VERSION}/lua-language-server-${LUA_LS_VERSION}-linux-${ARCH}.tar.gz"
    else
        LUA_LS_URL="https://github.com/LuaLS/lua-language-server/releases/download/${LUA_LS_VERSION}/lua-language-server-${LUA_LS_VERSION}-darwin-${ARCH}.tar.gz"
    fi

    LUA_LS_DIR="${HOME}/.local/share/lua-language-server"
    mkdir -p "$LUA_LS_DIR"

    TEMP_DIR=$(mktemp -d)
    trap "rm -rf $TEMP_DIR" EXIT

    if curl -L "$LUA_LS_URL" -o "$TEMP_DIR/lua-ls.tar.gz"; then
        tar -xzf "$TEMP_DIR/lua-ls.tar.gz" -C "$LUA_LS_DIR"

        # Create wrapper script
        cat > "$INSTALL_DIR/lua-language-server" <<'EOFS'
#!/bin/bash
exec "${HOME}/.local/share/lua-language-server/bin/lua-language-server" "$@"
EOFS
        chmod +x "$INSTALL_DIR/lua-language-server"

        echo -e "${GREEN}✓${NC} lua-language-server v${LUA_LS_VERSION} installed successfully"
    else
        echo -e "${RED}✗${NC} Failed to download lua-language-server"
        exit 1
    fi
fi
echo ""

# Verify installations
echo -e "${BLUE}═══ Verifying Installations ═══${NC}"

ALL_GOOD=true

if command -v stylua &> /dev/null; then
    echo -e "${GREEN}✓${NC} stylua: $(stylua --version)"
else
    echo -e "${RED}✗${NC} stylua not found in PATH"
    ALL_GOOD=false
fi

if command -v selene &> /dev/null; then
    echo -e "${GREEN}✓${NC} selene: $(selene --version)"
else
    echo -e "${RED}✗${NC} selene not found in PATH"
    ALL_GOOD=false
fi

if command -v lua-language-server &> /dev/null; then
    echo -e "${GREEN}✓${NC} lua-language-server: $(lua-language-server --version 2>&1 | head -n1)"
else
    echo -e "${RED}✗${NC} lua-language-server not found in PATH"
    ALL_GOOD=false
fi

echo ""

if [ "$ALL_GOOD" = false ]; then
    echo -e "${YELLOW}⚠${NC}  Some tools not found in PATH"
    echo "Add to your shell config (~/.bashrc, ~/.zshrc):"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
    echo "Then reload your shell: source ~/.bashrc"
    exit 1
fi

# Success
echo -e "${GREEN}╔════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅ ALL TOOLS INSTALLED            ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════╝${NC}"
echo ""
echo "Tools ready:"
echo -e "  ${GREEN}✓${NC} stylua (formatter)"
echo -e "  ${GREEN}✓${NC} selene (linter)"
echo -e "  ${GREEN}✓${NC} lua-language-server (diagnostics)"
echo ""
echo "Next steps:"
echo "  1. Run: ${BLUE}./scripts/setup-hooks.sh${NC}"
echo "  2. Configure: ${BLUE}.stylua.toml${NC} and ${BLUE}selene.toml${NC}"
echo "  3. Test: ${BLUE}stylua --check lua/${NC}"
