-- Plugin: StyledDoc
-- Purpose: Markdown styling with image rendering support
-- Workflow: experimental
-- Config: full

return {
  "denstiny/styledoc.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "vhyrro/luarocks.nvim",
    "3rd/image.nvim",
  },
  ft = "markdown",
  keys = {
    { "<leader>md", "<cmd>StyledocToggle<cr>", desc = "Toggle StyledDoc" },
  },
  config = function()
    require("styledoc").setup({
      -- Enable image rendering
      enable_image = true,

      -- Enable syntax highlighting for code blocks
      enable_code_highlight = true,

      -- Enable table rendering
      enable_table = true,

      -- Enable list rendering
      enable_list = true,

      -- Enable heading styling
      enable_heading = true,

      -- Image settings
      image = {
        max_width = 80, -- Maximum image width in characters
        max_height = 40, -- Maximum image height in characters
      },

      -- Heading styles
      heading = {
        h1 = "■",
        h2 = "▶",
        h3 = "▸",
        h4 = "▹",
        h5 = "▫",
        h6 = "▪",
      },
    })

    vim.notify("🎨 StyledDoc loaded - Enhanced markdown rendering", vim.log.levels.INFO)
  end,
}
