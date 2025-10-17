return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  enabled = true,
  init = false,
  opts = function()
    local dashboard = require("alpha.themes.dashboard")
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




    -- stylua: ignore
    dashboard.section.buttons.val = {
      dashboard.button("f", " " .. " Find file",       "<cmd> Telescope find_files <cr>"),
      dashboard.button("n", "🧠" .. " New note",        "<cmd> lua require('config.zettelkasten').new_note() <cr>"),
      dashboard.button("d", "📅" .. " Daily note",      "<cmd> lua require('config.zettelkasten').daily_note() <cr>"),
      dashboard.button("z", "📝" .. " Quick capture",   "<cmd> lua require('config.zettelkasten').inbox_note() <cr>"),
      dashboard.button("s", "🔍" .. " Search notes",    "<cmd> lua require('config.zettelkasten').search_notes() <cr>"),
      dashboard.button("r", " " .. " Recent files",    "<cmd> Telescope oldfiles <cr>"),
      dashboard.button("l", "󰒲 " .. " Lazy",            "<cmd> Lazy <cr>"),
      dashboard.button("q", " " .. " Quit",            "<cmd> qa <cr>"),
    }
    for _, button in ipairs(dashboard.section.buttons.val) do
      button.opts.hl = "AlphaButtons"
      button.opts.hl_shortcut = "AlphaShortcut"
    end
    dashboard.section.header.opts.hl = "AlphaHeader"
    dashboard.section.buttons.opts.hl = "AlphaButtons"
    dashboard.section.footer.opts.hl = "AlphaFooter"
    dashboard.opts.layout[1].val = 8
    return dashboard
  end,
  config = function(_, dashboard)
    -- close Lazy and re-open when the dashboard is ready
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

    vim.api.nvim_create_autocmd("User", {
      once = true,
      pattern = "LazyVimStarted",
      callback = function()
        local stats = require("lazy").stats()
        local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
        dashboard.section.footer.val = "⚡ Neovim loaded "
          .. stats.loaded
          .. "/"
          .. stats.count
          .. " plugins in "
          .. ms
          .. "ms"
        pcall(vim.cmd.AlphaRedraw)
      end,
    })
  end,
}
