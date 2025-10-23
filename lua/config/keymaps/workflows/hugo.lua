-- Hugo/MkDocs Publishing Keymaps
-- Namespace: <leader>h (hugo/publish)
--
-- DESIGN RATIONALE:
-- Publishing is separate from core Zettelkasten workflow.
-- Writers need static site generation tools accessible but not cluttering
-- the primary <leader>z namespace used 50+ times per session.

local registry = require("config.keymaps")

local keymaps = {
  -- Static site publishing (mkdocs)
  {
    "<leader>hp",
    function()
      require("config.zettelkasten").publish()
    end,
    desc = "🚀 Publish to static site (mkdocs)",
  },

  -- Preview server (mkdocs)
  {
    "<leader>hv",
    function()
      require("config.zettelkasten").preview_site()
    end,
    desc = "👁️  Preview site (mkdocs serve)",
  },

  -- Build only (no serve)
  {
    "<leader>hb",
    function()
      require("config.zettelkasten").build_site()
    end,
    desc = "🔨 Build site (mkdocs build)",
  },

  -- Open site in browser
  {
    "<leader>ho",
    function()
      vim.fn.system("xdg-open http://localhost:8000 &")
      vim.notify("🌐 Opening site in browser", vim.log.levels.INFO)
    end,
    desc = "🌐 Open preview in browser",
  },
}

return registry.register_module("workflows.hugo", keymaps)
