--- Terminal Keymaps
--- Namespace: <leader>t (terminal), <leader>ft (floating terminal)
--- @module config.keymaps.environment.terminal

local registry = require("config.keymaps")

local keymaps = {
	{ "<leader>t", "<cmd>terminal<CR>", desc = "💻 Open terminal" },
	{ "<leader>te", "<cmd>ToggleTerm<CR>", desc = "🖥️  Toggle terminal" },
	{ "<leader>ft", "<cmd>FloatermToggle<CR>", desc = "🎈 Floating terminal" },
}

return registry.register_module("environment.terminal", keymaps)
