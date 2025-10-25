-- Visual Mode Zettelkasten Operations
-- Purpose: Transform selected text into knowledge management primitives
-- Pattern: Selection → Link/Note/Quote/Format

local M = {}

-- Turn selected text into a link (create note if doesn't exist)
function M.selection_to_link()
  -- Get visual selection
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local lines = vim.fn.getline(start_pos[2], end_pos[2])

  if #lines == 0 then
    vim.notify("No text selected", vim.log.levels.WARN)
    return
  end

  -- Get selected text (handle multiline)
  local selected_text
  if #lines == 1 then
    selected_text = string.sub(lines[1], start_pos[3], end_pos[3])
  else
    -- Multiline selection - use first line as link text
    selected_text = lines[1]
  end

  -- Prompt for note title (default to selected text)
  local title = vim.fn.input("Note title: ", selected_text)
  if title == "" then
    return
  end

  -- Create slug from title
  local slug = title:lower():gsub("%s+", "-"):gsub("[^%w%-]", "")

  -- Replace selection with markdown link
  local link = string.format("[%s](%s)", selected_text, slug)

  -- Replace visual selection
  vim.cmd(string.format('normal! gv"_c%s', link))
  vim.cmd("normal! l") -- Move cursor after link

  -- Check if note exists, create if not
  local note_path = vim.fn.expand("~/Zettelkasten/zettel/" .. slug .. ".md")
  if vim.fn.filereadable(note_path) == 0 then
    -- Note doesn't exist - create it
    local create = vim.fn.confirm("Note doesn't exist. Create it?", "&Yes\n&No", 1)
    if create == 1 then
      require("config.zettelkasten").new_note(title)
    end
  end
end

-- Extract selection to new note (uses IWE LSP code action)
function M.extract_selection()
  -- Trigger IWE extract code action
  vim.lsp.buf.code_action({
    filter = function(action)
      return action.kind and action.kind:match("custom.extract")
    end,
    apply = true,
  })
end

-- Extract selection as quote to new note
function M.extract_as_quote()
  vim.lsp.buf.code_action({
    filter = function(action)
      return action.kind and action.kind:match("custom.extract") and action.title:match("[Qq]uote")
    end,
    apply = true,
  })
end

return M
