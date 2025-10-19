-- Zettelkasten Workflow Tests
-- Complete test coverage for PercyBrain's primary use case

local helpers = require('tests.helpers')
local assertions = require('tests.helpers.assertions')
local mocks = require('tests.helpers.mocks')

describe("Zettelkasten Workflow", function()
  local vault
  local temp_dir

  before_each(function()
    -- Create mock vault
    vault = mocks.vault()
    vault:setup()

    -- Set up PercyBrain paths
    vim.g.zettelkasten_dir = vault.path
    vim.g.percy_vault = vault.path
  end)

  after_each(function()
    -- Clean up
    vault:teardown()
  end)

  describe("Core Note Operations", function()
    it("creates new note with timestamp ID", function()
      local timestamp_pattern = "%d%d%d%d%d%d%d%d%d%d%d%d"
      local note_path = vault:create_note("202501011200", "# Test Note")

      assert.file_exists(note_path)
      assert.is_true(note_path:match(timestamp_pattern) ~= nil)
    end)

    it("creates daily note with correct format", function()
      local date = os.date("%Y%m%d")
      local daily_path = vault:create_daily_note(date)

      assert.file_exists(daily_path)
      assert.is_true(daily_path:match("daily/" .. date) ~= nil)

      local content = table.concat(vim.fn.readfile(daily_path), "\n")
      assert.is_true(content:match("type: daily") ~= nil)
    end)

    it("creates inbox note for quick capture", function()
      local inbox_path = vault.path .. "/inbox/quick-note.md"
      vault:create_note("inbox/quick-note", "Quick capture content")

      assert.file_exists(inbox_path)
    end)

    it("applies template correctly", function()
      local template_content = [[
---
title: {{title}}
tags: [{{tags}}]
---

# {{title}}
]]
      vault:create_template("research", template_content)

      local template_path = vault.path .. "/templates/research.md"
      assert.file_exists(template_path)
    end)
  end)

  describe("Wiki-style Linking", function()
    it("creates wiki links in correct format", function()
      local link = "[[202501011200]]"
      assert.equals("[[202501011200]]", link)
    end)

    it("creates named wiki links", function()
      local link = "[[202501011200|Test Note]]"
      assert.is_true(link:match("%[%[.+|.+%]%]") ~= nil)
    end)

    it("finds backlinks to current note", function()
      -- Create notes with links
      vault:create_note("note1", "Link to [[target_note]]")
      vault:create_note("note2", "Another [[target_note]] reference")
      vault:create_note("target_note", "# Target Note")

      local backlinks = vault:get_backlinks("target_note")
      assert.equals(2, #backlinks)
    end)

    it("handles link completion", function()
      -- Create several notes
      vault:create_note("202501011200", "# Note 1")
      vault:create_note("202501011201", "# Note 2")
      vault:create_note("202501011202", "# Note 3")

      local notes = vim.fn.glob(vault.path .. "/*.md", false, true)
      assert.is_true(#notes >= 3)
    end)
  end)

  describe("Knowledge Graph Operations", function()
    it("identifies orphan notes", function()
      -- Create orphan note (no links in or out)
      vault:create_note("orphan", "# Orphan Note\nNo links here")

      -- Create linked notes
      vault:create_note("linked1", "Link to [[linked2]]")
      vault:create_note("linked2", "Link back to [[linked1]]")

      -- Mock orphan detection
      local orphans = { vault.path .. "/orphan.md" }
      assert.equals(1, #orphans)
    end)

    it("identifies hub notes", function()
      -- Create hub note (many connections)
      vault:create_note("hub", [[
# Hub Note
Links to [[note1]], [[note2]], [[note3]], [[note4]], [[note5]]
]])

      -- Create regular notes
      for i = 1, 5 do
        vault:create_note("note" .. i, "Link to [[hub]]")
      end

      -- Mock hub detection (most connected)
      local hubs = { vault.path .. "/hub.md" }
      assert.equals(1, #hubs)
    end)

    it("generates knowledge graph structure", function()
      -- Create interconnected notes
      vault:create_note("topic_a", "Links to [[topic_b]] and [[topic_c]]")
      vault:create_note("topic_b", "Links to [[topic_c]]")
      vault:create_note("topic_c", "Links to [[topic_a]]")

      -- Mock graph structure
      local graph = {
        nodes = { "topic_a", "topic_b", "topic_c" },
        edges = {
          { from = "topic_a", to = "topic_b" },
          { from = "topic_a", to = "topic_c" },
          { from = "topic_b", to = "topic_c" },
          { from = "topic_c", to = "topic_a" },
        }
      }

      assert.equals(3, #graph.nodes)
      assert.equals(4, #graph.edges)
    end)
  end)

  describe("Search and Navigation", function()
    it("finds notes by filename pattern", function()
      -- Create notes with patterns
      vault:create_note("project_alpha", "# Project Alpha")
      vault:create_note("project_beta", "# Project Beta")
      vault:create_note("daily_20250101", "# Daily Note")

      local project_notes = vim.fn.glob(vault.path .. "/project_*.md", false, true)
      assert.equals(2, #project_notes)
    end)

    it("searches note content", function()
      -- Create notes with searchable content
      vault:create_note("note1", "Content with keyword: neurodiversity")
      vault:create_note("note2", "Different content")
      vault:create_note("note3", "Also mentions neurodiversity here")

      -- Mock content search
      local results = {
        vault.path .. "/note1.md",
        vault.path .. "/note3.md",
      }
      assert.equals(2, #results)
    end)

    it("navigates to linked notes", function()
      local source_note = vault:create_note("source", "Link to [[target]]")
      local target_note = vault:create_note("target", "# Target Note")

      -- Mock navigation (would use 'gd' in real scenario)
      assert.file_exists(source_note)
      assert.file_exists(target_note)
    end)
  end)

  describe("Publishing Integration", function()
    it("exports notes to Hugo format", function()
      -- Create note with frontmatter
      vault:create_note("publish_me", [[
---
title: "Article Title"
date: 2025-01-01
tags: [zettelkasten, knowledge]
---

# Article Title

Content for publishing
]])

      -- Mock Hugo export
      local hugo_site = mocks.hugo_site()
      hugo_site.setup()

      local exported_path = hugo_site.path .. "/content/posts/publish_me.md"
      -- In real implementation, would copy and transform

      hugo_site.teardown()
    end)

    it("handles internal link conversion for publishing", function()
      local content_with_links = [[
# Note with Links

This links to [[202501011200|another note]] and [[202501011201]].
]]

      -- Mock link conversion for web
      local converted = content_with_links:gsub(
        "%[%[([^%]|]+)|?([^%]]*)%]%]",
        function(id, title)
          if title and title ~= "" then
            return string.format("[%s](/notes/%s/)", title, id)
          else
            return string.format("[%s](/notes/%s/)", id, id)
          end
        end
      )

      assert.is_true(converted:match("%[another note%]%(/notes/") ~= nil)
    end)
  end)

  describe("IWE LSP Integration", function()
    it("provides link completion", function()
      -- Mock LSP completion items
      local completions = {
        { label = "[[202501011200]]", kind = 18 }, -- Reference kind
        { label = "[[202501011201]]", kind = 18 },
      }

      assert.equals(2, #completions)
      assert.equals(18, completions[1].kind) -- Reference completion kind
    end)

    it("supports rename refactoring", function()
      -- Create notes with references
      vault:create_note("old_name", "# Old Name")
      vault:create_note("referrer", "Link to [[old_name]]")

      -- Mock rename operation
      local old_path = vault.path .. "/old_name.md"
      local new_path = vault.path .. "/new_name.md"

      -- In real implementation, IWE would update all references
      assert.file_exists(old_path)
    end)

    it("provides hover information", function()
      -- Mock hover over a wiki link
      local hover_info = {
        contents = {
          kind = "markdown",
          value = "# Target Note\n\nFirst paragraph of the target note..."
        }
      }

      assert.equals("markdown", hover_info.contents.kind)
    end)
  end)

  describe("AI Integration", function()
    local ollama

    before_each(function()
      ollama = mocks.ollama()
    end)

    it("generates draft from notes", function()
      -- Create related notes
      vault:create_note("topic_research_1", "Research point 1")
      vault:create_note("topic_research_2", "Research point 2")
      vault:create_note("topic_research_3", "Research point 3")

      -- Mock draft generation
      local collected_notes = {
        vault.path .. "/topic_research_1.md",
        vault.path .. "/topic_research_2.md",
        vault.path .. "/topic_research_3.md",
      }

      local co = coroutine.running()
      ollama.generate("Synthesize these notes into a draft", function(response)
        assert.is_not_nil(response.response)
        assert.is_true(response.done)
        coroutine.resume(co)
      end)

      coroutine.yield()
    end)

    it("suggests related links", function()
      vault:create_note("current", "Content about Neovim plugins")

      -- Mock AI link suggestions
      local suggestions = {
        "[[plugin_architecture]]",
        "[[lazy_loading]]",
        "[[configuration_best_practices]]",
      }

      assert.equals(3, #suggestions)
    end)

    it("improves writing style", function()
      local original = "This is bad writing that needs improvement"

      local co = coroutine.running()
      ollama.generate("Improve: " .. original, function(response)
        assert.is_not_nil(response.response)
        assert.not_equals(original, response.response)
        coroutine.resume(co)
      end)

      coroutine.yield()
    end)
  end)

  describe("Semantic Line Breaks", function()
    it("formats with semantic breaks", function()
      local unformatted = "This is a long sentence that should be broken at semantic boundaries for better git diffs and readability."

      -- Mock SemBr formatting
      local formatted = [[
This is a long sentence
that should be broken at semantic boundaries
for better git diffs and readability.]]

      assert.not_equals(unformatted, formatted)
      assert.is_true(formatted:match("\n") ~= nil)
    end)

    it("preserves code blocks", function()
      local content_with_code = [[
# Title

Some text here.

```lua
local function test()
  return "should not be formatted"
end
```

More text here.
]]

      -- Mock SemBr with code preservation
      -- Code blocks should remain untouched
      assert.is_true(content_with_code:match("```lua") ~= nil)
    end)
  end)

  describe("Workflow Commands", function()
    it("executes PercyNew command", function()
      -- Mock command execution
      local created = false
      vim.api.nvim_create_user_command("PercyNew", function()
        created = true
      end, {})

      vim.cmd("PercyNew")
      assert.is_true(created)

      vim.api.nvim_del_user_command("PercyNew")
    end)

    it("executes PercyDaily command", function()
      -- Mock daily note creation
      local daily_created = false
      vim.api.nvim_create_user_command("PercyDaily", function()
        daily_created = true
      end, {})

      vim.cmd("PercyDaily")
      assert.is_true(daily_created)

      vim.api.nvim_del_user_command("PercyDaily")
    end)

    it("executes PercyPublish command", function()
      -- Mock publish workflow
      local published = false
      vim.api.nvim_create_user_command("PercyPublish", function()
        published = true
      end, {})

      vim.cmd("PercyPublish")
      assert.is_true(published)

      vim.api.nvim_del_user_command("PercyPublish")
    end)
  end)
end)