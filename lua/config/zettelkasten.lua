-- Zettelkasten Configuration for ZettelWrite
-- Personal knowledge management system

local M = {}

-- Configuration
M.config = {
  -- Path to your Zettelkasten
  home = vim.fn.expand("~/Zettelkasten"),
  inbox = vim.fn.expand("~/Zettelkasten/inbox"),
  daily = vim.fn.expand("~/Zettelkasten/daily"),
  templates = vim.fn.expand("~/Zettelkasten/templates"),

  -- Static site export
  export_path = vim.fn.expand("~/blog/content/zettelkasten"),
}

-- Create directories if they don't exist
function M.setup()
  local dirs = {
    M.config.home,
    M.config.inbox,
    M.config.daily,
    M.config.templates,
  }

  for _, dir in ipairs(dirs) do
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
  end

  -- Set up keymaps
  M.setup_keymaps()

  -- Set up commands
  M.setup_commands()
end

-- Keymaps for Zettelkasten workflow
function M.setup_keymaps()
  local opts = { noremap = true, silent = true }

  -- Quick capture
  vim.keymap.set('n', '<leader>zn', M.new_note, opts)
  vim.keymap.set('n', '<leader>zd', M.daily_note, opts)
  vim.keymap.set('n', '<leader>zi', M.inbox_note, opts)

  -- Search & navigation
  vim.keymap.set('n', '<leader>zf', M.find_notes, opts)
  vim.keymap.set('n', '<leader>zg', M.search_notes, opts)
  vim.keymap.set('n', '<leader>zb', M.backlinks, opts)

  -- Writing modes
  vim.keymap.set('n', '<leader>zw', '<cmd>ZenMode<cr>', opts)
  vim.keymap.set('n', '<leader>zp', M.publish, opts)
end

-- Create new note with template
function M.new_note()
  local title = vim.fn.input("Note title: ")
  if title == "" then return end

  local timestamp = os.date("%Y%m%d%H%M")
  local filename = string.format("%s-%s.md", timestamp, title:gsub(" ", "-"):lower())
  local filepath = M.config.home .. "/" .. filename

  -- Create note with frontmatter
  local lines = {
    "---",
    "title: " .. title,
    "date: " .. os.date("%Y-%m-%d %H:%M"),
    "tags: []",
    "---",
    "",
    "# " .. title,
    "",
    "",
  }

  vim.fn.writefile(lines, filepath)
  vim.cmd("edit " .. filepath)
end

-- Create/open daily note
function M.daily_note()
  local date = os.date("%Y-%m-%d")
  local filepath = M.config.daily .. "/" .. date .. ".md"

  if vim.fn.filereadable(filepath) == 0 then
    local lines = {
      "---",
      "title: Daily Note " .. date,
      "date: " .. date,
      "tags: [daily]",
      "---",
      "",
      "# " .. date,
      "",
      "## Notes",
      "",
    }
    vim.fn.writefile(lines, filepath)
  end

  vim.cmd("edit " .. filepath)
end

-- Quick inbox capture
function M.inbox_note()
  local timestamp = os.date("%Y%m%d%H%M%S")
  local filepath = M.config.inbox .. "/" .. timestamp .. ".md"

  local lines = {
    "---",
    "title: Quick Note",
    "date: " .. os.date("%Y-%m-%d %H:%M:%S"),
    "tags: [inbox]",
    "---",
    "",
    "",
  }

  vim.fn.writefile(lines, filepath)
  vim.cmd("edit " .. filepath)
  vim.cmd("startinsert")
end

-- Find notes with telescope
function M.find_notes()
  require('telescope.builtin').find_files({
    cwd = M.config.home,
    prompt_title = '🗂️  Find Note',
  })
end

-- Search notes content
function M.search_notes()
  require('telescope.builtin').live_grep({
    cwd = M.config.home,
    prompt_title = '🔍 Search Notes',
  })
end

-- Find backlinks to current file
function M.backlinks()
  local current_file = vim.fn.expand('%:t:r')  -- Filename without extension

  require('telescope.builtin').live_grep({
    cwd = M.config.home,
    prompt_title = '🔗 Backlinks to ' .. current_file,
    default_text = '[[' .. current_file,
  })
end

-- Publish to static site
function M.publish()
  print("📤 Publishing to static site...")

  -- Copy notes to export path
  local cmd = string.format('rsync -av --exclude="inbox" %s/ %s/',
    M.config.home, M.config.export_path)
  vim.fn.system(cmd)

  -- Build static site (adjust for your generator)
  local blog_dir = vim.fn.fnamemodify(M.config.export_path, ':h:h')
  vim.fn.system('cd ' .. blog_dir .. ' && hugo')

  print("✅ Published successfully!")
end

-- Set up user commands
function M.setup_commands()
  vim.api.nvim_create_user_command('ZettelNew', M.new_note, {})
  vim.api.nvim_create_user_command('ZettelDaily', M.daily_note, {})
  vim.api.nvim_create_user_command('ZettelInbox', M.inbox_note, {})
  vim.api.nvim_create_user_command('ZettelPublish', M.publish, {})
  vim.api.nvim_create_user_command('ZettelPreview', function()
    local blog_dir = vim.fn.fnamemodify(M.config.export_path, ':h:h')
    vim.fn.system('cd ' .. blog_dir .. ' && hugo server -D &')
    print("🌐 Preview server started at http://localhost:1313")
  end, {})
end

return M
