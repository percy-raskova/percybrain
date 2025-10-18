# Neovim MCP Server Connection Guide

## ✅ Solution: How to Connect Claude to Neovim

The Neovim MCP server requires Neovim to be running with a socket listener. Here's how to make it work:

### Quick Start (What Works)

**Option 1: Start Neovim with --listen flag (RECOMMENDED)**
```bash
nvim --listen /tmp/nvim
```

**Option 2: Start in tmux/screen session**
```bash
tmux new -s nvim-mcp "nvim --listen /tmp/nvim"
# Or detached:
tmux new -d -s nvim-mcp "nvim --listen /tmp/nvim"
```

**Option 3: Use existing Neovim and create socket**
Inside Neovim, run:
```vim
:call serverstart("/tmp/nvim")
```

### MCP Configuration (.mcp.json)

Your configuration is correct:
```json
"MCP Neovim Server": {
  "command": "/home/percy/.nvm/versions/node/v22.17.1/bin/npx",
  "args": ["-y", "mcp-neovim-server"],
  "env": {
    "ALLOW_SHELL_COMMANDS": "true",
    "NVIM_SOCKET_PATH": "/tmp/nvim",
    "NPM_CONFIG_AUDIT": "false",
    "NPM_CONFIG_FUND": "false"
  }
}
```

### Troubleshooting Checklist

#### 1. Check if Neovim is listening
```bash
# Check for socket file
ls -la /tmp/nvim

# Check running Neovim processes
ps aux | grep nvim

# Test socket connection
nvim --server /tmp/nvim --remote-expr "v:version"
```

#### 2. Common Issues & Fixes

**Issue: "Not connected" error**
- **Cause**: Neovim not running with --listen
- **Fix**: Start Neovim with `nvim --listen /tmp/nvim`

**Issue: "Connection closed" error**
- **Cause**: Socket doesn't exist or wrong path
- **Fix**: Ensure socket path matches in both Neovim and .mcp.json

**Issue: Works then stops**
- **Cause**: Neovim was closed
- **Fix**: Keep Neovim running in background (use tmux/screen)

### Persistent Setup

Add to your shell config (~/.bashrc or ~/.zshrc):
```bash
# Always start Neovim with socket
alias nvim='nvim --listen /tmp/nvim'

# Or create a dedicated MCP Neovim session
nvim-mcp() {
    if ! tmux has-session -t nvim-mcp 2>/dev/null; then
        tmux new-session -d -s nvim-mcp "nvim --listen /tmp/nvim"
        echo "Started Neovim MCP session"
    else
        echo "Neovim MCP session already running"
    fi
    tmux attach -t nvim-mcp
}
```

### Available MCP Commands

Once connected, Claude can:
- `vim_buffer` - Read current buffer
- `vim_command` - Execute Vim commands
- `vim_status` - Get cursor position, mode, etc.
- `vim_edit` - Edit buffer content
- `vim_window` - Manage windows
- `vim_search` - Search in buffer
- `vim_file_open` - Open files
- And many more!

### Testing the Connection

In Claude, test with:
```
mcp__MCP_Neovim_Server__vim_status
```

You should see cursor position, mode, and other status info.

## Summary

**The key requirement**: Neovim must be running with `--listen /tmp/nvim` for the MCP server to connect.

Your configuration is correct - you just needed to start Neovim with the socket listener enabled!