--- Time Tracking Keymaps (Pendulum)
--- Namespace: CONSOLIDATED into <leader>pt* (prose → timer)
--- @module config.keymaps.organization.time-tracking
---
--- DESIGN CHANGE (2025-10-21):
--- Time tracking moved from <leader>op* to <leader>pt* (prose timer namespace)
--- Rationale: Writers track time while writing - belongs in prose workflow
---
--- All keybindings now defined in lua/config/keymaps/workflows/prose.lua
--- This file kept for backward compatibility / module structure clarity
---
--- NEW LOCATIONS:
--- <leader>pts - Timer start (was <leader>ops)
--- <leader>pte - Timer stop (was <leader>ope)
--- <leader>ptt - Timer status (was <leader>opt)
--- <leader>ptr - Timer report (was <leader>opr)

local registry = require("config.keymaps")

-- No keymaps defined here - all moved to prose.lua
-- This empty registration maintains module structure
local keymaps = {}

return registry.register_module("organization.time-tracking", keymaps)
