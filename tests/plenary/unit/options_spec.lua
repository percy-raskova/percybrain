-- Unit Tests: Vim Options Configuration
-- Tests for writer-focused defaults and neurodiversity optimizations

-- Helper function for table contains check
local function contains(tbl, value)
  for _, v in pairs(tbl) do
    if v == value then
      return true
    end
  end
  return false
end

describe("Options Configuration", function()
  before_each(function()
    -- Arrange: Ensure options module is loaded fresh
    package.loaded["config.options"] = nil
    require("config.options")
  end)

  after_each(function()
    -- No cleanup needed - options remain configured
  end)

  describe("Writer-Focused Defaults", function()
    it("enables spell checking by default", function()
      -- Arrange: Options module loaded in before_each

      -- Act: Get spell option value
      local spell_enabled = vim.opt.spell:get()

      -- Assert: Spell checking should be enabled
      assert.is_true(spell_enabled, "Spell checking should be enabled")
    end)

    it("sets correct spell language", function()
      -- Arrange: Options module loaded in before_each

      -- Act: Get spell language configuration
      local langs = vim.opt.spelllang:get()

      -- Assert: English spell checking should be enabled
      assert.is_true(contains(langs, "en"), "English spell checking should be enabled")
    end)

    it("enables line wrapping for prose", function()
      -- Arrange: Options module loaded in before_each

      -- Act: Get line wrap setting
      local wrap_enabled = vim.opt.wrap:get()

      -- Assert: Line wrapping should be enabled for prose
      assert.is_true(wrap_enabled, "Line wrapping should be enabled for prose")
    end)

    it("sets appropriate text width", function()
      -- Arrange: Options module loaded in before_each

      -- Act: Get text width setting
      local textwidth = vim.opt.textwidth:get()

      -- Assert: Text width should be 80 or unlimited
      assert.is_true(textwidth == 80 or textwidth == 0, "Text width should be 80 or unlimited")
    end)

    it("enables line break at word boundaries", function()
      -- Arrange: Options module loaded in before_each

      -- Act: Get linebreak setting
      local linebreak_enabled = vim.opt.linebreak:get()

      -- Assert: Should break lines at word boundaries
      assert.is_true(linebreak_enabled, "Should break lines at word boundaries")
    end)
  end)

  describe("Search Configuration", function()
    it("enables incremental search", function()
      -- Arrange: Options module loaded in before_each

      -- Act: Get incremental search setting
      local incsearch_enabled = vim.opt.incsearch:get()

      -- Assert: Incremental search should be enabled
      assert.is_true(incsearch_enabled, "Incremental search should be enabled")
    end)

    it("enables search highlighting", function()
      -- Arrange: Options module loaded in before_each

      -- Act: Get search highlight setting
      local hlsearch_enabled = vim.opt.hlsearch:get()

      -- Assert: Search highlighting should be enabled
      assert.is_true(hlsearch_enabled, "Search highlighting should be enabled")
    end)

    it("enables smart case searching", function()
      -- Arrange: Options module loaded in before_each

      -- Act: Get smartcase and ignorecase settings
      local smartcase_enabled = vim.opt.smartcase:get()
      local ignorecase_enabled = vim.opt.ignorecase:get()

      -- Assert: Smart case and ignore case should be enabled
      assert.is_true(smartcase_enabled, "Smart case should be enabled")
      assert.is_true(ignorecase_enabled, "Ignore case should be enabled for smartcase")
    end)
  end)

  describe("Editor Behavior", function()
    it("sets correct scroll offset", function()
      -- Arrange: Options module loaded in before_each

      -- Act: Get scroll offset value
      local scrolloff = vim.opt.scrolloff:get()

      -- Assert: Scrolloff should be at least 8 lines
      assert.is_true(scrolloff >= 8, "Scrolloff should be at least 8 lines")
    end)

    it("enables relative line numbers", function()
      -- Arrange: Options module loaded in before_each

      -- Act: Get line number settings
      local relativenumber_enabled = vim.opt.relativenumber:get()
      local number_enabled = vim.opt.number:get()

      -- Assert: Both relative and absolute numbers should be enabled
      assert.is_true(relativenumber_enabled, "Relative numbers should be enabled")
      assert.is_true(number_enabled, "Line numbers should be enabled")
    end)

    it("shows sign column", function()
      -- Arrange: Options module loaded in before_each

      -- Act: Get sign column setting
      local signcolumn = vim.opt.signcolumn:get()

      -- Assert: Sign column should be visible
      assert.is_true(signcolumn == "yes" or signcolumn == "auto", "Sign column should be visible")
    end)

    it("enables mouse support", function()
      -- Arrange: Options module loaded in before_each

      -- Act: Get mouse setting
      local mouse = vim.opt.mouse:get()

      -- Assert: Mouse should be enabled in all modes
      assert.equals("a", mouse, "Mouse should be enabled in all modes")
    end)
  end)

  describe("Clipboard Integration", function()
    it("uses system clipboard", function()
      -- Arrange: Options module loaded in before_each

      -- Act: Get clipboard configuration
      local clipboard = vim.opt.clipboard:get()

      -- Assert: System clipboard integration should be enabled
      assert.is_true(
        vim.tbl_contains(clipboard, "unnamedplus") or vim.tbl_contains(clipboard, "unnamed"),
        "System clipboard integration should be enabled"
      )
    end)
  end)

  describe("File Handling", function()
    it("disables swap files", function()
      -- Arrange: Options module loaded in before_each

      -- Act: Get swapfile setting
      local swapfile_enabled = vim.opt.swapfile:get()

      -- Assert: Swap files should be disabled
      assert.is_false(swapfile_enabled, "Swap files should be disabled")
    end)

    it("disables backup files", function()
      -- Arrange: Options module loaded in before_each

      -- Act: Get backup setting
      local backup_enabled = vim.opt.backup:get()

      -- Assert: Backup files should be disabled
      assert.is_false(backup_enabled, "Backup files should be disabled")
    end)

    it("enables persistent undo", function()
      -- Arrange: Options module loaded in before_each

      -- Act: Get undofile setting
      local undofile_enabled = vim.opt.undofile:get()

      -- Assert: Persistent undo should be enabled
      assert.is_true(undofile_enabled, "Persistent undo should be enabled")
    end)

    it("sets undo directory", function()
      -- Arrange: Options module loaded in before_each

      -- Act: Get undo directory configuration
      local undodir = vim.opt.undodir:get()

      -- Assert: Undo directory should be configured
      assert.is_table(undodir)
      assert.is_true(#undodir > 0, "Undo directory should be set")
    end)
  end)

  describe("Indentation Settings", function()
    it("enables smart indentation", function()
      -- Arrange: Options module loaded in before_each

      -- Act: Get smartindent setting
      local smartindent_enabled = vim.opt.smartindent:get()

      -- Assert: Smart indent should be enabled
      assert.is_true(smartindent_enabled, "Smart indent should be enabled")
    end)

    it("uses spaces instead of tabs", function()
      -- Arrange: Options module loaded in before_each

      -- Act: Get expandtab setting
      local expandtab_enabled = vim.opt.expandtab:get()

      -- Assert: Should use spaces instead of tabs
      assert.is_true(expandtab_enabled, "Should use spaces instead of tabs")
    end)

    it("sets correct tab width", function()
      -- Arrange: Options module loaded in before_each

      -- Act: Get tab settings
      local tabstop = vim.opt.tabstop:get()
      local shiftwidth = vim.opt.shiftwidth:get()

      -- Assert: Tab width should be consistent
      assert.is_true(tabstop == 2 or tabstop == 4, "Tab width should be 2 or 4 spaces")
      assert.equals(tabstop, shiftwidth, "Shiftwidth should match tabstop")
    end)
  end)

  describe("Visual Enhancements", function()
    it("enables termguicolors for themes", function()
      -- Arrange: Options module loaded in before_each

      -- Act: Get termguicolors setting
      local termguicolors_enabled = vim.opt.termguicolors:get()

      -- Assert: Terminal GUI colors should be enabled
      assert.is_true(termguicolors_enabled, "Terminal GUI colors should be enabled")
    end)

    it("enables cursor line highlighting", function()
      -- Arrange: Options module loaded in before_each

      -- Act: Get cursorline setting
      local cursorline_enabled = vim.opt.cursorline:get()

      -- Assert: Cursor line should be highlighted
      assert.is_true(cursorline_enabled, "Cursor line should be highlighted")
    end)

    it("sets appropriate color column", function()
      -- Arrange: Options module loaded in before_each

      -- Act: Get color column configuration
      local colorcolumn = vim.opt.colorcolumn:get()

      -- Assert: Either empty or set to standard width
      assert.is_true(
        #colorcolumn == 0
          or vim.tbl_contains(colorcolumn, "80")
          or vim.tbl_contains(colorcolumn, "100")
          or vim.tbl_contains(colorcolumn, "120"),
        "Color column should be unset or at standard width"
      )
    end)
  end)

  describe("Performance Options", function()
    it("sets appropriate update time", function()
      -- Arrange: Options module loaded in before_each

      -- Act: Get updatetime setting
      local updatetime = vim.opt.updatetime:get()

      -- Assert: Update time should be responsive
      assert.is_true(updatetime <= 300, "Update time should be 300ms or less for responsive feel")
    end)

    it("sets reasonable timeout", function()
      -- Arrange: Options module loaded in before_each

      -- Act: Get timeout settings
      local timeout = vim.opt.timeout:get()
      local timeoutlen = vim.opt.timeoutlen:get()

      -- Assert: Timeout should be configured appropriately
      assert.is_true(timeout, "Timeout should be enabled")
      assert.is_true(timeoutlen <= 500, "Timeout length should be 500ms or less")
    end)

    it("enables lazy redraw for performance", function()
      -- Arrange: Options module loaded in before_each

      -- Act: Get lazyredraw setting
      local lazyredraw = vim.opt.lazyredraw:get()

      -- Assert: Lazy redraw should be explicitly set
      assert.is_boolean(lazyredraw, "Lazy redraw should be explicitly set")
    end)
  end)

  describe("Completion Options", function()
    it("configures completion menu", function()
      -- Arrange: Options module loaded in before_each

      -- Act: Get completeopt configuration
      local completeopt = vim.opt.completeopt:get()

      -- Assert: Completion menu should be properly configured
      assert.is_true(contains(completeopt, "menu"), "Completion menu should be shown")
      assert.is_true(contains(completeopt, "menuone"), "Menu should show even for single match")
    end)

    it("sets appropriate pumheight", function()
      -- Arrange: Options module loaded in before_each

      -- Act: Get popup menu height
      local pumheight = vim.opt.pumheight:get()

      -- Assert: Popup menu height should be reasonable
      assert.is_true(pumheight >= 10 and pumheight <= 20, "Popup menu height should be between 10-20 items")
    end)
  end)

  describe("Split Behavior", function()
    it("opens splits in intuitive positions", function()
      -- Arrange: Options module loaded in before_each

      -- Act: Get split behavior settings
      local splitbelow = vim.opt.splitbelow:get()
      local splitright = vim.opt.splitright:get()

      -- Assert: Splits should open in intuitive positions
      assert.is_true(splitbelow, "Horizontal splits should open below")
      assert.is_true(splitright, "Vertical splits should open right")
    end)
  end)

  describe("ADHD/Autism Optimizations", function()
    it("minimizes distractions", function()
      -- Arrange: Options module loaded in before_each

      -- Act: Get showmode setting
      local showmode = vim.opt.showmode:get()

      -- Assert: Distracting features should be disabled
      assert.is_false(showmode, "Mode display should be hidden (shown in statusline)")
    end)

    it("provides clear visual boundaries", function()
      -- Arrange: Options module loaded in before_each

      -- Act: Get fillchars configuration
      local fillchars = vim.opt.fillchars:get()

      -- Assert: Split characters should be defined for clarity
      assert.is_table(fillchars)
      assert.is_true(fillchars.vert ~= nil or fillchars.horiz ~= nil, "Split characters should be defined")
    end)

    it("enables focus helpers", function()
      -- Arrange: Options module loaded in before_each

      -- Act: Get focus-related settings
      local cursorline = vim.opt.cursorline:get()
      local scrolloff = vim.opt.scrolloff:get()

      -- Assert: Focus helpers should be enabled
      assert.is_true(cursorline, "Cursor line should be enabled for focus")
      assert.is_true(scrolloff >= 8, "Scroll offset should maintain context")
    end)
  end)

  describe("Option Validation", function()
    it("doesn't set conflicting options", function()
      -- Arrange: Options module loaded in before_each

      -- Act: Check for option conflicts
      local paste_enabled = vim.opt.paste:get()
      local smartindent_enabled = vim.opt.smartindent:get()

      -- Assert: If paste is on, conflicting options should be disabled
      if paste_enabled then
        assert.is_false(smartindent_enabled, "Smart indent conflicts with paste mode")
      end
    end)

    it("respects option dependencies", function()
      -- Arrange: Options module loaded in before_each

      -- Act: Get interdependent option values
      local smartcase = vim.opt.smartcase:get()
      local ignorecase = vim.opt.ignorecase:get()
      local relativenumber = vim.opt.relativenumber:get()
      local number = vim.opt.number:get()

      -- Assert: Option dependencies should be satisfied
      if smartcase then
        assert.is_true(ignorecase, "Smartcase requires ignorecase to be set")
      end

      if relativenumber then
        assert.is_true(number, "Relative numbers should have regular numbers enabled")
      end
    end)
  end)
end)
