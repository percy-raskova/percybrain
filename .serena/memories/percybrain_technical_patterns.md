# PercyBrain Technical Patterns and Architecture

**Last Updated**: 2025-10-17 **Context**: UI/UX Implementation Session

## Module Organization Pattern

### Directory Structure

```
lua/
├── config/              # Core system configuration
│   ├── init.lua        # Bootstrap + module loading
│   ├── globals.lua     # Global variables
│   ├── keymaps.lua     # Keybindings
│   ├── options.lua     # Vim options
│   ├── zettelkasten.lua # Core Zettelkasten system
│   └── window-manager.lua # NEW: Window management
├── percybrain/          # NEW: PercyBrain-specific modules
│   ├── dashboard.lua   # AI metrics
│   ├── network-graph.lua # Borg visualization
│   ├── quick-capture.lua # Fast note creation
│   └── bibtex.lua      # Citation management
└── plugins/
    ├── ui/
    │   ├── percybrain-theme.lua # Blood Moon theme
    │   └── alpha.lua   # Dashboard
    └── utilities/
        └── mcp-marketplace.lua # MCP Hub
```

### Naming Conventions

- **Modules**: `module-name.lua` (kebab-case)
- **Functions**: `function_name()` (snake_case)
- **Variables**: `local_var` (snake_case)
- **Constants**: `CONSTANT_VAR` (UPPER_SNAKE_CASE)

## Lazy Loading Strategy

### Immediate Load (lazy = false)

```lua
return {
  "plugin/repo",
  lazy = false,
  priority = 1000, -- Higher priority = loads earlier
  config = function()
    -- Setup here
  end,
}
```

**Use for**: Themes, core UI elements, frequently used features

### Command-based Load

```lua
return {
  "plugin/repo",
  cmd = { "CommandName", "AnotherCommand" },
  config = function()
    -- Setup here
  end,
}
```

**Use for**: Occasional-use tools, marketplace, browsers

### Key-based Load

```lua
return {
  "plugin/repo",
  keys = {
    { "<leader>key", "<cmd>Command<cr>", desc = "Description" },
  },
  config = function()
    -- Setup here
  end,
}
```

**Use for**: Features bound to specific keybindings

### Event-based Load

```lua
return {
  "plugin/repo",
  event = "BufWritePost", -- or "VeryLazy", "BufReadPre", etc.
  config = function()
    -- Setup here
  end,
}
```

**Use for**: Auto-triggered features, background services

## Module Setup Pattern

### Standard Module Structure

```lua
local M = {}

-- Configuration
local config = {
  option1 = "value1",
  option2 = "value2",
}

-- Private functions
local function private_helper()
  -- Implementation
end

-- Public functions
M.public_function = function()
  -- Implementation
end

-- Setup function (optional)
M.setup = function(opts)
  config = vim.tbl_extend("force", config, opts or {})
  -- Initialize module
end

return M
```

### Usage in init.lua

```lua
require("module-name").setup() -- If has setup()
-- OR
local module = require("module-name") -- If no setup needed
```

## Notification Pattern

### Standard Format

```lua
vim.notify("emoji Message text", vim.log.levels.LEVEL)
```

### Log Levels

- `vim.log.levels.INFO` - General information (🎉 🚀 ✅ 📊)
- `vim.log.levels.WARN` - Warnings (⚠️ ⚡)
- `vim.log.levels.ERROR` - Errors (❌ 🚨)

### Emoji Conventions

- 🪟 Window operations
- 🌙 Theme/appearance
- 📊 Dashboards/metrics
- 🤖 AI/automation
- 📝 Notes/writing
- 🔍 Search/find
- 🛍️ Marketplace/plugins
- ✅ Success
- ❌ Error
- ⚠️ Warning

## Color Theme Integration

### Override Pattern (tokyonight base)

```lua
return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    local colors = {
      bg = "#1a0000",
      fg = "#e8e8e8",
      -- ... more colors
    }

    require("tokyonight").setup({
      on_colors = function(c)
        -- Override base colors
        c.bg = colors.bg
        c.fg = colors.fg
      end,

      on_highlights = function(hl, c)
        -- Override specific highlights
        hl.Normal = { fg = colors.fg, bg = colors.bg }
        hl.StatusLine = { fg = colors.gold, bg = colors.bg_dark }
      end,
    })

    vim.cmd([[colorscheme tokyonight]])
  end,
}
```

### Plugin-Specific Highlights

Always include these for consistency:

- Telescope (search UI)
- NvimTree (file explorer)
- WhichKey (keybinding help)
- Alpha (dashboard)
- Lualine (statusline)
- GitSigns (git integration)

## Floating Window Pattern

### Standard Configuration

```lua
local buf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_buf_set_lines(buf, 0, -1, false, content_lines)
vim.api.nvim_buf_set_option(buf, "filetype", "text")
vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
vim.api.nvim_buf_set_option(buf, "modifiable", false)

local width = 75
local height = math.min(vim.o.lines - 10, #content_lines + 2)

local win_opts = {
  relative = "editor",
  width = width,
  height = height,
  col = math.floor((vim.o.columns - width) / 2),
  row = math.floor((vim.o.lines - height) / 2),
  style = "minimal",
  border = "double",
  title = " 🤖 TITLE 🤖 ",
  title_pos = "center",
}

local win = vim.api.nvim_open_win(buf, true, win_opts)

-- Standard close keymaps
vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>close<cr>", { noremap = true, silent = true })
vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "<cmd>close<cr>", { noremap = true, silent = true })
```

### Best Practices

- Always use `bufhidden = "wipe"` for cleanup
- Set `modifiable = false` for read-only displays
- Use `math.min()` to prevent oversized windows
- Center windows with `math.floor()` calculations
- Provide both `q` and `<Esc>` to close

## AI Integration Pattern

### Ollama API Call

```lua
local function call_ollama(prompt)
  local ollama_cmd = string.format(
    [[curl -s -X POST %s/api/generate -d '{"model": "%s", "prompt": %s, "stream": false}' | jq -r '.response']],
    config.ollama_url,
    config.ollama_model,
    vim.fn.json_encode(prompt)
  )

  local response = vim.fn.system(ollama_cmd)

  if vim.v.shell_error == 0 and response ~= "" then
    return response
  else
    return nil
  end
end
```

### Background Execution

```lua
-- Non-blocking AI call
vim.defer_fn(function()
  local result = call_ollama(prompt)
  if result then
    cache.ai_result = result
  end
end, 100) -- 100ms delay
```

### Performance Optimization

- Keep prompts under 1000 characters for speed
- Cache results for 5 minutes (300 seconds)
- Use non-blocking execution with `vim.defer_fn()`
- Graceful degradation if Ollama unavailable

## File System Operations

### Safe File Writing

```lua
local function write_file(filepath, content)
  -- Ensure directory exists
  local dir = vim.fn.fnamemodify(filepath, ":h")
  vim.fn.mkdir(dir, "p")

  -- Write file
  local file = io.open(filepath, "w")
  if file then
    file:write(content)
    file:close()
    return true
  else
    vim.notify("❌ Failed to write: " .. filepath, vim.log.levels.ERROR)
    return false
  end
end
```

### File Reading Pattern

```lua
local function read_file(filepath)
  local file = io.open(filepath, "r")
  if not file then
    return nil
  end

  local content = file:read("*all")
  file:close()
  return content
end
```

### Directory Scanning

```lua
local function scan_directory(path, pattern)
  local find_cmd = string.format('find "%s" -name "%s" -type f', path, pattern)
  local files = vim.fn.systemlist(find_cmd)
  return files
end
```

## Keybinding Patterns

### Leader Key Namespaces

- `<leader>w` - Window management
- `<leader>z` - Zettelkasten operations
- `<leader>l` - Lynx/browser operations
- `<leader>m` - MCP/marketplace operations
- `<leader>f` - Focus/distraction-free modes
- `<leader>a` - AI assistant operations

### Keymap Registration

```lua
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

keymap("n", "<leader>key", function()
  -- Action here
end, vim.tbl_extend("force", opts, { desc = "Description for WhichKey" }))
```

### Buffer-local Keymaps

```lua
vim.api.nvim_buf_set_keymap(
  buf,
  "n",
  "key",
  "<cmd>command<cr>",
  { noremap = true, silent = true }
)
```

## Auto-command Patterns

### Simple Auto-command

```lua
vim.api.nvim_create_autocmd("Event", {
  pattern = "*.md",
  callback = function()
    -- Action here
  end,
})
```

### Complex Auto-command

```lua
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "*.md" },
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local filepath = vim.api.nvim_buf_get_name(bufnr)

    -- Conditional logic
    if filepath:match("Zettelkasten") then
      -- Action for Zettelkasten notes
    end
  end,
})
```

## MCP Server Configuration

### Standard Pattern (.mcp.json)

```json
{
  "mcpServers": {
    "server-name": {
      "command": "uvx",
      "args": ["--from", "git+https://github.com/user/repo", "server-command"],
      "env": {
        "ENV_VAR": "value"
      }
    }
  }
}
```

### Node.js Servers

```json
{
  "command": "/home/percy/.nvm/versions/node/v22.17.1/bin/npx",
  "args": ["-y", "@scope/package@latest"],
  "env": {
    "NPM_CONFIG_AUDIT": "false",
    "NPM_CONFIG_FUND": "false"
  }
}
```

### Python Servers (uvx)

```json
{
  "command": "uvx",
  "args": ["--from", "git+https://github.com/user/repo", "command"],
  "env": {}
}
```

## Performance Considerations

### Startup Optimization

1. Lazy-load everything possible
2. Use `lazy = false` sparingly (themes only)
3. Defer non-critical initialization with `vim.defer_fn()`
4. Avoid heavy computations in config functions

### Runtime Optimization

1. Cache expensive operations (file scans, AI calls)
2. Use background execution for slow operations
3. Limit result sets (max_nodes, head_limit)
4. Use efficient Lua patterns over shell commands when possible

### Memory Management

1. Set `bufhidden = "wipe"` for temporary buffers
2. Clear caches after timeout periods
3. Use local functions to avoid global namespace pollution
4. Close file handles explicitly

## Error Handling Patterns

### Graceful Degradation

```lua
local success, result = pcall(function()
  return require("optional-module")
end)

if not success then
  vim.notify("⚠️  Optional feature unavailable", vim.log.levels.WARN)
  return
end
```

### Shell Command Error Handling

```lua
local output = vim.fn.system(command)

if vim.v.shell_error ~= 0 then
  vim.notify("❌ Command failed: " .. command, vim.log.levels.ERROR)
  return nil
end

return output
```

## Testing Patterns

### Headless Module Test

```bash
nvim --headless \
  -c "lua print('Test: ' .. type(require('module')))" \
  -c "qa"
```

### Load Test

```bash
nvim --headless \
  -c "lua require('config.init')" \
  -c "lua print('All modules loaded')" \
  -c "qa" 2>&1 | grep -E "(Error|error|OK)"
```

## Documentation Standards

### File Headers

```lua
-- Plugin: Name
-- Purpose: Brief description
-- Workflow: category
-- Config: minimal|full
-- Repository: https://github.com/user/repo (if applicable)
```

### Function Documentation

```lua
-- Brief description of what function does
-- @param param_name type Description of parameter
-- @return type Description of return value
local function example_function(param_name)
  -- Implementation
end
```

### Module Documentation

Include at top of module:

- Purpose and scope
- Configuration options
- Public API functions
- Usage examples
- Dependencies

## Conclusion

These patterns represent the established architecture and conventions for the PercyBrain system. Follow these patterns for consistency, maintainability, and optimal performance.
