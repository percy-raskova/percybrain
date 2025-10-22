# Issue #7: Lua LSP IDE Configuration for Self-Sufficient Development

**Labels:** `enhancement`, `developer-experience`, `self-sufficiency`, `high-priority`

## Description

Implement comprehensive Lua development environment within Neovim to enable self-sufficient configuration maintenance without AI dependency.

## Context

Current state requires AI assistance for most Neovim configuration tasks. To achieve long-term maintainability and self-sufficiency, need full IDE-level features for Lua development.

**User Rationale**: "If I want to not be completely reliant on AI and get shit done myself"

## Requirements

### 1. Lua Language Server (lua-ls)

- Install and configure lua-ls with Neovim API completion
- Neovim runtime path integration
- Plugin API definitions and signatures
- Workspace library configuration for all Neovim modules

### 2. Code Navigation

- Go-to-definition for functions, modules, plugins
- Find references across entire config
- Symbol search (functions, variables, modules)
- Workspace symbol browser (Telescope integration)
- Jump to plugin spec definitions

### 3. Inline Documentation

- Hover information for Neovim API functions
- Signature help during function calls
- Quick reference for common patterns
- Plugin configuration examples accessible in-editor

### 4. Diagnostics & Linting

- Real-time Lua error detection
- Linting via lua-ls diagnostics
- Integration with existing luacheck setup
- Inline error messages with quick fixes

### 5. Code Formatting

- StyLua integration (already exists, verify configuration)
- Format-on-save capability
- Format selection/buffer commands

### 6. Debugging Support

- DAP (Debug Adapter Protocol) for Lua
- Breakpoint support
- Variable inspection
- Step-through debugging for Neovim config
- Integration with existing test suite

### 7. Enhanced Code Navigation

- Telescope integration for config-specific searches
- Plugin spec navigation (jump to plugin definitions)
- Keymap browser with conflict detection
- Module dependency visualization

## Acceptance Criteria

- [ ] lua-ls installed with Neovim API completion working
- [ ] Go-to-definition works for functions, modules, plugins
- [ ] Find references works across entire config
- [ ] Hover documentation shows Neovim API info
- [ ] Signature help appears during function calls
- [ ] Real-time diagnostics show Lua errors
- [ ] StyLua formatting works on save
- [ ] DAP debugging configured with breakpoint support
- [ ] Telescope integration for config searches
- [ ] Keymap browser shows all keybindings with conflicts
- [ ] Documentation accessible: Can navigate config without AI assistance

## Implementation Tasks

### Phase 1: LSP Setup (4-6 hours)

- [ ] Install lua-ls via Mason or system package
- [ ] Configure lua-ls with Neovim runtime paths
- [ ] Add workspace library for Neovim API
- [ ] Configure diagnostics and formatting
- [ ] Test go-to-definition, hover, references

### Phase 2: Enhanced Navigation (4-6 hours)

- [ ] Create Telescope pickers for config searches
- [ ] Implement plugin spec navigation
- [ ] Build keymap browser with conflict detection
- [ ] Add module dependency visualization

### Phase 3: Debugging (2-3 hours)

- [ ] Install DAP and nvim-dap-ui
- [ ] Configure Lua DAP adapter
- [ ] Create debug configurations for Neovim
- [ ] Test breakpoints and variable inspection

### Phase 4: Documentation (2-3 hours)

- [ ] Create quick reference for common patterns
- [ ] Add plugin configuration examples
- [ ] Document debugging workflow
- [ ] Verify self-sufficiency: Complete config task without AI

## Testing Strategy

- Manual validation: Complete config modification without AI assistance
- Go-to-definition test: Jump to 10 different module definitions
- Find references test: Find all usages of common functions
- Debugging test: Set breakpoints and inspect variables
- Documentation test: Access Neovim API docs via hover

## Success Metrics

- **Self-Sufficiency**: Can complete routine config tasks without AI
- **Navigation Speed**: Find any function/module in \<10 seconds
- **Error Detection**: Catch 90%+ of Lua errors before running Neovim
- **Debugging Capability**: Can debug config issues with DAP

## Estimated Effort

12-16 hours

## Dependencies

- Mason (for LSP installation)
- nvim-lspconfig
- lua-ls (language server)
- nvim-dap (debugging)
- nvim-dap-ui (debugging UI)
- Telescope (enhanced navigation)

## Related Files

- `lua/plugins/lsp/` (LSP configuration)
- `lua/plugins/completion/nvim-cmp.lua` (completion integration)
- `lua/plugins/navigation/telescope.lua` (Telescope config)
- `lua/plugins/utilities/dap.lua` (NEW - debugging config)
