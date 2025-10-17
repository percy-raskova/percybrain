return {
  "nvim-orgmode/orgmode",
  dependencies = {
    { "nvim-treesitter/nvim-treesitter", lazy = true },
  },
  event = "VeryLazy",
  config = function()
    -- Setup orgmode (handles its own treesitter grammar)
    require("orgmode").setup({
      org_agenda_files = "~/orgfiles/**/*",
      org_default_notes_file = "~/orgfiles/refile.org",
    })
  end,
}
