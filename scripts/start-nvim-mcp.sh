#!/bin/bash
# Script to start Neovim with MCP socket support
# This ensures Claude can connect to your Neovim instance

SOCKET_PATH="/tmp/nvim"
SESSION_NAME="nvim-mcp"

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Starting Neovim MCP Server Connection${NC}"

# Check if socket already exists
if [ -S "$SOCKET_PATH" ]; then
    echo -e "${YELLOW}⚠️  Socket already exists at $SOCKET_PATH${NC}"
    echo "Testing if it's responsive..."

    if nvim --server "$SOCKET_PATH" --remote-expr "v:version" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Existing socket is working!${NC}"
        echo "Neovim is already listening for MCP connections."
        exit 0
    else
        echo -e "${RED}❌ Socket exists but not responding. Removing...${NC}"
        rm -f "$SOCKET_PATH"
    fi
fi

# Check if tmux session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo -e "${YELLOW}⚠️  Tmux session '$SESSION_NAME' already exists${NC}"
    echo "Attaching to existing session..."
    tmux attach-session -t "$SESSION_NAME"
else
    echo -e "${GREEN}📝 Creating new tmux session '$SESSION_NAME'${NC}"
    echo "Starting Neovim with socket listening at: $SOCKET_PATH"

    # Create tmux session with Neovim listening on socket
    tmux new-session -s "$SESSION_NAME" "nvim --listen $SOCKET_PATH" \; \
         set-option -t "$SESSION_NAME" status-left "[MCP Connected] " \; \
         set-option -t "$SESSION_NAME" status-style bg=red,fg=white

    echo -e "${GREEN}✅ Neovim MCP server is ready!${NC}"
fi

echo ""
echo "To detach from tmux: Press Ctrl+B then D"
echo "To reattach later: tmux attach -t $SESSION_NAME"
echo "To check status: $0 status"