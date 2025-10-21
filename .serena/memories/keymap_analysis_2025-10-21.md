# Keymap Architecture Analysis - 2025-10-21

## Summary

Deep analysis of PercyBrain's keymap system revealed sophisticated registry architecture (8.5/10 quality) with two fixable issues.

## Key Findings

**Registry System** (`lua/config/keymaps/init.lua`):

- Central conflict detection with `register_module()` pattern
- 17/18 modules compliant (94%)
- utilities.lua bypasses registry (needs fix)

**Namespace Organization** (EXCELLENT):

- Zero conflicts detected across 19 modules
- Clear semantic prefixes: `<leader>z*` (zettelkasten), `<leader>f*` (find), `<leader>t*` (terminal), etc.

**IWE Integration Gap**:

- Markdown mappings: ✅ Enabled
- Telescope keybindings: ❌ Disabled (needs integration)
- LSP keybindings: ❌ Disabled (needs integration)
- Preview keybindings: ❌ Not configured (needs integration)

## Critical Issues

1. **utilities.lua Registry Bypass** (`lua/config/keymaps/utilities.lua:16`):

   - Returns `keymaps` directly instead of `registry.register_module("utilities", keymaps)`
   - Impact: Pattern inconsistency, bypasses conflict detection
   - Fix: 2-minute change (add registry require + change return)

2. **IWE Keybinding Conflicts**:

   - `<leader>l` conflicts with Lynx browser (`<leader>l[oecs]`)
   - `<leader>p*` conflicts with Prose workflow (`<leader>p[pmd]`)
   - Solution: Use `<leader>i*` namespace for IWE features

## Implementation Plan

**Phase 1: utilities.lua Fix** (2 min):

```lua
local registry = require("config.keymaps")
return registry.register_module("utilities", keymaps)
```

**Phase 2: IWE Integration** (15 min):

- Create `lua/config/keymaps/workflows/iwe.lua`
- Telescope navigation: `gf`, `gs`, `ga`, `g/`, `gb`, `go`
- LSP refactoring: `<leader>ih`, `<leader>il` (i prefix avoids conflict)
- Preview: `<leader>ip[sehw]` (ip = iwe preview)
- Update plugin config: keep `enable_*_keybindings = false`

**Phase 3: Documentation** (5 min):

- Update KEYBINDINGS_REFERENCE.md with IWE section

## Namespace Strategy

**IWE Keybinding Namespace**:

- `g*` → Navigation (go to file/symbol/grep)
- `<leader>i*` → IWE features (Integrated Writing Environment)
- `<leader>ip*` → IWE Preview (iwe preview commands)

**Rationale**: `<leader>i*` currently unused, clear mnemonic, avoids Lynx/Prose conflicts

## Quality Metrics

**Current**: 8.5/10

- Registry design: 10/10
- Pattern compliance: 9.4/10 (17/18)
- Namespace organization: 10/10
- Integration: 7/10

**After Fixes**: 9.5/10

- Pattern compliance: 10/10 (18/18)
- Integration: 9/10

## Key Architecture Patterns

**Excellent Patterns**:

- Central registry with conflict detection
- Semantic namespace organization
- Hierarchical file structure (workflows/, tools/, environment/, system/, organization/)
- Consistent module registration
- No scattered keybindings

**File Structure**:

```
lua/config/keymaps/
├── init.lua (registry)
├── utilities.lua (❌ needs fix)
├── workflows/ (4 files) ✅
├── tools/ (6 files) ✅
├── environment/ (3 files) ✅
├── system/ (2 files) ✅
└── organization/ (1 file) ✅
```

## Validation Commands

```bash
# Check conflicts
grep -r "^\s*{\s*\"<leader>" lua/config/keymaps/ | sed 's/.*{\s*"\([^"]*\)".*/\1/' | sort | uniq -c

# Test IWE after integration
:WhichKey g           # Show IWE navigation
:WhichKey <leader>i   # Show IWE features
gf                    # Test IWE find files
<leader>ips           # Test IWE squash preview
```

## Detailed Report

See: `claudedocs/KEYMAP_ANALYSIS_2025-10-21.md` (comprehensive 400+ line analysis)
