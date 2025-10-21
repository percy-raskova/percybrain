-- Window Management Keymaps
-- Namespace: <leader>w (window)

local registry = require("config.keymaps")

local keymaps = {
  -- Quick window toggle
  { "<leader>ww", function() vim.cmd("wincmd w"); vim.notify("🪟 Switched window", vim.log.levels.INFO) end, desc = "🪟 Quick window toggle" },

  -- Navigation (lowercase hjkl)
  { "<leader>wh", function() vim.cmd("wincmd h") end, desc = "← Window left" },
  { "<leader>wj", function() vim.cmd("wincmd j") end, desc = "↓ Window down" },
  { "<leader>wk", function() vim.cmd("wincmd k") end, desc = "↑ Window up" },
  { "<leader>wl", function() vim.cmd("wincmd l") end, desc = "→ Window right" },

  -- Moving windows (uppercase HJKL)
  { "<leader>wH", function() vim.cmd("wincmd H"); vim.notify("🪟 Window moved H", vim.log.levels.INFO) end, desc = "⇐ Move window left" },
  { "<leader>wJ", function() vim.cmd("wincmd J"); vim.notify("🪟 Window moved J", vim.log.levels.INFO) end, desc = "⇓ Move window down" },
  { "<leader>wK", function() vim.cmd("wincmd K"); vim.notify("🪟 Window moved K", vim.log.levels.INFO) end, desc = "⇑ Move window up" },
  { "<leader>wL", function() vim.cmd("wincmd L"); vim.notify("🪟 Window moved L", vim.log.levels.INFO) end, desc = "⇒ Move window right" },

  -- Splitting
  { "<leader>ws", function() vim.cmd("split"); vim.notify("🪟 Horizontal split created", vim.log.levels.INFO) end, desc = "➖ Split horizontal" },
  { "<leader>wv", function() vim.cmd("vsplit"); vim.notify("🪟 Vertical split created", vim.log.levels.INFO) end, desc = "➗ Split vertical" },

  -- Closing
  { "<leader>wc", function() require("config.window-manager").close_window() end, desc = "❌ Close window" },
  { "<leader>wo", function() vim.cmd("only"); vim.notify("🪟 All other windows closed", vim.log.levels.INFO) end, desc = "⭕ Close other windows" },
  { "<leader>wq", function() vim.cmd("quit") end, desc = "🚪 Quit window" },

  -- Resizing
  { "<leader>w=", function() vim.cmd("wincmd ="); vim.notify("🪟 Windows equalized", vim.log.levels.INFO) end, desc = "⚖️  Equalize windows" },
  { "<leader>w<", function() vim.cmd("vertical resize | wincmd |"); vim.notify("🪟 Width maximized", vim.log.levels.INFO) end, desc = "◀ Maximize width" },
  { "<leader>w>", function() vim.cmd("resize | wincmd _"); vim.notify("🪟 Height maximized", vim.log.levels.INFO) end, desc = "▲ Maximize height" },

  -- Buffer management
  { "<leader>wb", function() require("telescope.builtin").buffers() end, desc = "📝 List buffers" },
  { "<leader>wn", function() vim.cmd("bnext") end, desc = "➡️ Next buffer" },
  { "<leader>wp", function() vim.cmd("bprevious") end, desc = "⬅️ Previous buffer" },
  { "<leader>wd", function() require("config.window-manager").delete_buffer() end, desc = "🗑️ Delete buffer" },

  -- Layout presets
  { "<leader>wW", function() require("config.window-manager").layout_wiki() end, desc = "📚 Wiki workflow layout" },
  { "<leader>wF", function() require("config.window-manager").layout_focus() end, desc = "✍️ Focus layout" },
  { "<leader>wR", function() require("config.window-manager").layout_reset() end, desc = "🔄 Reset layout" },
  { "<leader>wG", function() require("config.window-manager").layout_research() end, desc = "🔬 Research layout" },

  -- Info
  { "<leader>wi", function() require("config.window-manager").window_info() end, desc = "ℹ️  Window info" },
}

return registry.register_module("window", keymaps)
