-- IWE Zettelkasten Integration Contract Specification
-- Defines what the IWE-based Zettelkasten MUST provide to users

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
    notation = "markdown", -- [note](note.md) format
    compatible_with_iwe = true,
    supports_subdirs = true,
  },

  -- Core Capabilities (what users CAN DO)
  capabilities = {
    -- IWE LSP capabilities
    "extract_section_to_note",
    "inline_note_content",
    "navigate_to_definition",
    "workspace_symbols_search",
    "safe_rename_with_links",
    "markdown_link_navigation",

    -- IWE CLI capabilities
    "create_note_with_cli",
    "search_notes_with_cli",
    "validate_links_with_cli",

    -- Integration capabilities
    "extract_creates_markdown_link",
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
    iwe_link_type = "markdown", -- IWE uses markdown links [](note.md)
    lsp_server_name = "iwes",
    cli_command_name = "iwe",
    template_variables_enabled = true,
  },

  -- Required Tools
  required_tools = {
    lsp_server = "iwes", -- IWE LSP server binary
    cli = "iwe", -- IWE CLI binary
  },
}
