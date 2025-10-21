--- Time Tracking Keymaps (Pendulum)
--- Namespace: <leader>tp (time tracking/pendulum)
--- @module config.keymaps.organization.time-tracking

local registry = require("config.keymaps")

local keymaps = {
	{ "<leader>tps", "<cmd>PendulumStart<CR>", desc = "⏱️  Start time tracking" },
	{ "<leader>tpe", "<cmd>PendulumStop<CR>", desc = "⏹️  Stop time tracking" },
	{ "<leader>tpt", "<cmd>PendulumStatus<CR>", desc = "📊 Time tracking status" },
	{ "<leader>tpr", "<cmd>PendulumReport<CR>", desc = "📈 Time tracking report" },
}

return registry.register_module("organization.time-tracking", keymaps)
