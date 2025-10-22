-- IWE + Telekasten Integration Contract Specification
-- Defines what the integration MUST provide to users

return {
  -- Directory Structure Requirements
  directories = {
    daily = "~/Zettelkasten/daily",
    weekly = "~/Zettelkasten/weekly",
    zettel = "~/Zettelkasten/zettel",
    sources = "~/Zettelkasten/sources",
    mocs = "~/Zettelkasten/mocs",
    drafts = "~/Zettelkasten/drafts",
    templates = "~/Zettelkasten/templates",
    assets = "~/Zettelkasten/assets",
  },

  -- Link Format Compatibility
  link_format = {
    notation = "wiki", -- [[note]] format
    compatible_with_iwe = true,
    supports_subdirs = true,
  },

  -- Core Capabilities (what users CAN DO)
  capabilities = {
    -- Telekasten capabilities
    "create_note_with_template",
    "navigate_with_calendar",
    "insert_wikilink",
    "show_backlinks",
    "rename_note_updates_links",

    -- IWE capabilities
    "extract_section_to_note",
    "inline_note_content",
    "navigate_to_definition",
    "workspace_symbols_search",
    "safe_rename_with_links",

    -- Integration capabilities
    "extract_creates_wikilink",
    "inline_preserves_formatting",
    "symbols_show_all_notes",
  },

  -- Template System
  templates = {
    note = "~/Zettelkasten/templates/note.md",
    daily = "~/Zettelkasten/templates/daily.md",
    weekly = "~/Zettelkasten/templates/weekly.md",
    source = "~/Zettelkasten/templates/source.md",
    moc = "~/Zettelkasten/templates/moc.md",
  },

  -- Critical Settings (must never change without explicit intent)
  protected_settings = {
    telekasten_link_notation = "wiki",
    iwe_link_type = "WikiLink",
    template_variables_enabled = true,
  },
}
