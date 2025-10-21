return {
  "iwe-org/iwe.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim", -- Required
  },
  config = function()
    require("iwe").setup({
      lsp = {
        cmd = { "iwes" },
        name = "iwes",
        debounce_text_changes = 500,
        auto_format_on_save = true,
      },
      mappings = {
        -- Markdown editing keybindings (-, <C-n>, <C-p>, /d, /w)
        enable_markdown_mappings = true,

        -- Telescope/LSP/Preview keybindings managed by iwe.lua keymaps
        -- Disabled here to prevent duplicates and ensure registry compliance
        enable_telescope_keybindings = false, -- Registry: gf, gs, ga, g/, gb, go
        enable_lsp_keybindings = false, -- Registry: <leader>ih, <leader>il
        enable_preview_keybindings = false, -- Registry: <leader>ip[sehw]

        leader = "<leader>",
        localleader = "<localleader>",
      },
      telescope = {
        enabled = true,
        setup_config = true,
        load_extensions = { "ui-select", "emoji" },
      },
    })
  end,
}
