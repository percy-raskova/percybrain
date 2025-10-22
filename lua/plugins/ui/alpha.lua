-- Plugin: Alpha Dashboard
-- Purpose: PercyBrain startup screen - minimal, calm, writer-focused
-- Workflow: ui
-- Why: Provides immediate entry points on startup - critical for ADHD users who need
--      clear, calm navigation. Reduces visual noise and decision paralysis by presenting
--      curated workflows in frequency order. Emphasizes "get to writing fast" philosophy.
-- Config: full - custom ASCII logo, condensed menu, minimal styling
--
-- Usage:
--   Opens automatically on nvim startup (VimEnter event)
--   Single-key shortcuts organized by workflow frequency
--
-- Dependencies: none (pure Neovim plugin)
--
-- Configuration Notes:
--   - Condensed layout with NO blank lines between menu items
--   - Toned down: no emoji, minimal colors, subtle hierarchy
--   - Workflow-grouped: Start Writing > Workflows > Tools
--   - ADHD-optimized: calm, scannable, predictable

return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  enabled = true,
  init = false,
  opts = function()
    local dashboard = require("alpha.themes.dashboard")

    -- PercyBrain ASCII logo (simplified tagline)
    local logo = [[

    ██████╗ ███████╗██████╗  ██████╗██╗   ██╗██████╗ ██████╗  █████╗ ██╗███╗   ██╗
    ██╔══██╗██╔════╝██╔══██╗██╔════╝╚██╗ ██╔╝██╔══██╗██╔══██╗██╔══██╗██║████╗  ██║
    ██████╔╝█████╗  ██████╔╝██║      ╚████╔╝ ██████╔╝██████╔╝███████║██║██╔██╗ ██║
    ██╔═══╝ ██╔══╝  ██╔══██╗██║       ╚██╔╝  ██╔══██╗██╔══██╗██╔══██║██║██║╚██╗██║
    ██║     ███████╗██║  ██║╚██████╗   ██║   ██████╔╝██║  ██║██║  ██║██║██║ ╚████║
    ╚═╝     ╚══════╝╚═╝  ╚═╝ ╚═════╝   ╚═╝   ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝

              Zettelkasten Writing Environment

    ]]

    dashboard.section.header.val = vim.split(logo, "\n")

    -- Condensed menu: grouped by frequency, no emoji, minimal spacing
    -- stylua: ignore
    -- luacheck: push ignore 631
    dashboard.section.buttons.val = {
      -- Section: Start Writing (most frequent)
      { type = "text", val = "Start Writing:", opts = { hl = "Comment", position = "center" } },
      dashboard.button("n", "  n  New note",           "<cmd> lua require('config.zettelkasten').new_note() <cr>"),
      dashboard.button("d", "  d  Daily note",         "<cmd> lua require('config.zettelkasten').daily_note() <cr>"),
      dashboard.button("r", "  r  Recent files",       "<cmd> Telescope oldfiles <cr>"),
      dashboard.button("f", "  f  Find notes",         "<cmd> Telescope find_files cwd=~/Zettelkasten <cr>"),

      -- Section: Workflows (regular use)
      { type = "text", val = "Workflows:", opts = { hl = "Comment", position = "center" } },
      dashboard.button("a", "  a  AI assistant",       "<cmd> lua require('config.zettelkasten').ai_menu() <cr>"),
      dashboard.button("v", "  v  Dashboard",          "<cmd> lua require('percybrain.dashboard').toggle() <cr>"),
      dashboard.button("w", "  w  Wiki browser",       "<cmd> lua require('config.zettelkasten').wiki_browser() <cr>"),
      dashboard.button("p", "  p  Publish",            "<cmd> lua require('percybrain.publish').start() <cr>"),

      -- Section: Tools (occasional use)
      { type = "text", val = "Tools:", opts = { hl = "Comment", position = "center" } },
      dashboard.button("l", "  l  Lynx research",      "<cmd> LynxOpen <cr>"),
      dashboard.button("m", "  m  MCP hub",            "<cmd> MCPHub <cr>"),
      dashboard.button("s", "  s  Settings",           "<cmd> e ~/.config/nvim/init.lua <cr>"),
      dashboard.button("?", "  ?  Help",               "<cmd> help percybrain <cr>"),
      dashboard.button("q", "  q  Quit",               "<cmd> qa <cr>"),
    }
    -- luacheck: pop

    -- Minimal styling: subtle shortcut highlighting only
    for _, button in ipairs(dashboard.section.buttons.val) do
      if button.type ~= "text" then
        button.opts.hl = "Normal"
        button.opts.hl_shortcut = "Number" -- Subtle blue/green for keys
      end
    end

    dashboard.section.header.opts.hl = "AlphaHeader"
    dashboard.section.buttons.opts.hl = "Normal"
    dashboard.section.footer.opts.hl = "Comment"

    -- Tighter spacing
    dashboard.opts.layout[1].val = 4

    return dashboard
  end,

  config = function(_, dashboard)
    -- Close Lazy and re-open when the dashboard is ready
    if vim.o.filetype == "lazy" then
      vim.cmd.close()
      vim.api.nvim_create_autocmd("User", {
        once = true,
        pattern = "AlphaReady",
        callback = function()
          require("lazy").show()
        end,
      })
    end

    require("alpha").setup(dashboard.opts)

    -- Footer with startup stats
    vim.api.nvim_create_autocmd("User", {
      once = true,
      pattern = "LazyVimStarted",
      callback = function()
        local stats = require("lazy").stats()
        local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
        dashboard.section.footer.val = "⚡ PercyBrain loaded "
          .. stats.loaded
          .. "/"
          .. stats.count
          .. " plugins in "
          .. ms
          .. "ms"
        pcall(vim.cmd.AlphaRedraw)
      end,
    })

    vim.notify("🧠 PercyBrain dashboard loaded", vim.log.levels.INFO)
  end,
}
