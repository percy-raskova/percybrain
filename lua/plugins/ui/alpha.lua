-- Plugin: Alpha Dashboard
-- Purpose: PercyBrain startup screen with Blood Moon aesthetic and quick-access menu
-- Workflow: ui
-- Why: Provides immediate context and orientation on startup - critical for ADHD users who need
--      clear entry points. ASCII logo establishes identity, menu offers predictable navigation
--      to common workflows (new note, wiki, AI, terminal). Startup stats provide performance
--      feedback without intrusion. Reduces decision paralysis by presenting curated options.
-- Config: full - custom ASCII logo, themed buttons, startup metrics
--
-- Usage:
--   Opens automatically on nvim startup (VimEnter event)
--   Single-key shortcuts: z/w/d/m/t/a/n/D/b/l/g/q
--   Displays plugin load count and startup time in footer
--
-- Dependencies: none (pure Neovim plugin)
--
-- Configuration Notes:
--   - Custom PercyBrain ASCII logo with tagline
--   - Blood Moon theme integration (AlphaHeader, AlphaButtons, AlphaShortcut, AlphaFooter highlight groups)
--   - 12 curated menu options covering all major workflows
--   - Auto-closes Lazy.nvim when dashboard ready (clean startup experience)
--   - Performance stats calculated from lazy.nvim plugin loader

return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  enabled = true,
  init = false,
  opts = function()
    local dashboard = require("alpha.themes.dashboard")

    -- PercyBrain ASCII logo
    local logo = [[

    ██████╗ ███████╗██████╗  ██████╗██╗   ██╗██████╗ ██████╗  █████╗ ██╗███╗   ██╗
    ██╔══██╗██╔════╝██╔══██╗██╔════╝╚██╗ ██╔╝██╔══██╗██╔══██╗██╔══██╗██║████╗  ██║
    ██████╔╝█████╗  ██████╔╝██║      ╚████╔╝ ██████╔╝██████╔╝███████║██║██╔██╗ ██║
    ██╔═══╝ ██╔══╝  ██╔══██╗██║       ╚██╔╝  ██╔══██╗██╔══██╗██╔══██║██║██║╚██╗██║
    ██║     ███████╗██║  ██║╚██████╗   ██║   ██████╔╝██║  ██║██║  ██║██║██║ ╚████║
    ╚═╝     ╚══════╝╚═╝  ╚═╝ ╚═════╝   ╚═╝   ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝

       ┌──────────────────────────────────────────────────────────┐
       │     Your Second Brain, As Fast As Your First 🧠          │
       └──────────────────────────────────────────────────────────┘
              thoughts --> connections --> insights --> publish

    ]]

    dashboard.section.header.val = vim.split(logo, "\n")

    -- Custom menu buttons with exact user requirements
    -- stylua: ignore
    -- luacheck: push ignore 631
    dashboard.section.buttons.val = {
      dashboard.button("z", "📝 " .. " New zettelkasten note",    "<cmd> lua require('config.zettelkasten').new_note() <cr>"),
      dashboard.button("w", "📚 " .. " Wiki explorer",            "<cmd> lua require('config.zettelkasten').wiki_browser() <cr>"),
      dashboard.button("d", "📊 " .. " Dashboards",               "<cmd> lua require('percybrain.dashboard').toggle() <cr>"),
      dashboard.button("m", "🛍️ " .. " MCP Hub",                  "<cmd> MCPHub <cr>"),
      dashboard.button("t", "💻 " .. " Terminal",                 "<cmd> ToggleTerm <cr>"),
      dashboard.button("a", "🤖 " .. " AI assistant",             "<cmd> lua require('config.zettelkasten').ai_menu() <cr>"),
      dashboard.button("n", "🆕 " .. " New note (choose type)",   "<cmd> lua require('percybrain.quick-capture').prompt_new_note() <cr>"),
      dashboard.button("D", "✍️ " .. " Distraction free writing", "<cmd> lua require('percybrain.quick-capture').distraction_free_start() <cr>"),
      dashboard.button("b", "🌐 " .. " Lynx browser",             "<cmd> LynxOpen <cr>"),
      dashboard.button("l", "📖 " .. " BibTeX citation library",  "<cmd> lua require('percybrain.bibtex').browse() <cr>"),
      dashboard.button("g", "🕸️ " .. " Network graph of notes",   "<cmd> lua require('percybrain.network-graph').show_borg() <cr>"),
      dashboard.button("q", "🚪 " .. " Quit",                     "<cmd> qa <cr>"),
    }
    -- luacheck: pop

    -- Apply Blood Moon styling
    for _, button in ipairs(dashboard.section.buttons.val) do
      button.opts.hl = "AlphaButtons"
      button.opts.hl_shortcut = "AlphaShortcut"
    end

    dashboard.section.header.opts.hl = "AlphaHeader"
    dashboard.section.buttons.opts.hl = "AlphaButtons"
    dashboard.section.footer.opts.hl = "AlphaFooter"

    -- Spacing
    dashboard.opts.layout[1].val = 8

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
