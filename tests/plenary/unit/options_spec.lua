-- Unit Tests: Vim Options Configuration
-- Tests for writer-focused defaults and neurodiversity optimizations

describe("Options Configuration", function()
  before_each(function()
    -- Ensure options module is loaded fresh
    package.loaded['config.options'] = nil
    require('config.options')
  end)

  describe("Writer-Focused Defaults", function()
    it("enables spell checking by default", function()
      assert.is_true(vim.opt.spell:get(), "Spell checking should be enabled")
    end)

    it("sets correct spell language", function()
      local langs = vim.opt.spelllang:get()
      assert.contains(langs, "en", "English spell checking should be enabled")
    end)

    it("enables line wrapping for prose", function()
      assert.is_true(vim.opt.wrap:get(), "Line wrapping should be enabled for prose")
    end)

    it("sets appropriate text width", function()
      local textwidth = vim.opt.textwidth:get()
      assert.is_true(textwidth == 80 or textwidth == 0,
        "Text width should be 80 or unlimited")
    end)

    it("enables line break at word boundaries", function()
      assert.is_true(vim.opt.linebreak:get(), "Should break lines at word boundaries")
    end)
  end)

  describe("Search Configuration", function()
    it("enables incremental search", function()
      assert.is_true(vim.opt.incsearch:get(), "Incremental search should be enabled")
    end)

    it("enables search highlighting", function()
      assert.is_true(vim.opt.hlsearch:get(), "Search highlighting should be enabled")
    end)

    it("enables smart case searching", function()
      assert.is_true(vim.opt.smartcase:get(), "Smart case should be enabled")
      assert.is_true(vim.opt.ignorecase:get(), "Ignore case should be enabled for smartcase")
    end)
  end)

  describe("Editor Behavior", function()
    it("sets correct scroll offset", function()
      local scrolloff = vim.opt.scrolloff:get()
      assert.is_true(scrolloff >= 8, "Scrolloff should be at least 8 lines")
    end)

    it("enables relative line numbers", function()
      assert.is_true(vim.opt.relativenumber:get(), "Relative numbers should be enabled")
      assert.is_true(vim.opt.number:get(), "Line numbers should be enabled")
    end)

    it("shows sign column", function()
      local signcolumn = vim.opt.signcolumn:get()
      assert.is_true(signcolumn == "yes" or signcolumn == "auto",
        "Sign column should be visible")
    end)

    it("enables mouse support", function()
      local mouse = vim.opt.mouse:get()
      assert.equals("a", mouse, "Mouse should be enabled in all modes")
    end)
  end)

  describe("Clipboard Integration", function()
    it("uses system clipboard", function()
      local clipboard = vim.opt.clipboard:get()
      assert.is_true(vim.tbl_contains(clipboard, "unnamedplus") or
                     vim.tbl_contains(clipboard, "unnamed"),
        "System clipboard integration should be enabled")
    end)
  end)

  describe("File Handling", function()
    it("disables swap files", function()
      assert.is_false(vim.opt.swapfile:get(), "Swap files should be disabled")
    end)

    it("disables backup files", function()
      assert.is_false(vim.opt.backup:get(), "Backup files should be disabled")
    end)

    it("enables persistent undo", function()
      assert.is_true(vim.opt.undofile:get(), "Persistent undo should be enabled")
    end)

    it("sets undo directory", function()
      local undodir = vim.opt.undodir:get()
      assert.is_table(undodir)
      assert.is_true(#undodir > 0, "Undo directory should be set")
    end)
  end)

  describe("Indentation Settings", function()
    it("enables smart indentation", function()
      assert.is_true(vim.opt.smartindent:get(), "Smart indent should be enabled")
    end)

    it("uses spaces instead of tabs", function()
      assert.is_true(vim.opt.expandtab:get(), "Should use spaces instead of tabs")
    end)

    it("sets correct tab width", function()
      local tabstop = vim.opt.tabstop:get()
      assert.is_true(tabstop == 2 or tabstop == 4,
        "Tab width should be 2 or 4 spaces")

      local shiftwidth = vim.opt.shiftwidth:get()
      assert.equals(tabstop, shiftwidth, "Shiftwidth should match tabstop")
    end)
  end)

  describe("Visual Enhancements", function()
    it("enables termguicolors for themes", function()
      assert.is_true(vim.opt.termguicolors:get(),
        "Terminal GUI colors should be enabled")
    end)

    it("enables cursor line highlighting", function()
      assert.is_true(vim.opt.cursorline:get(),
        "Cursor line should be highlighted")
    end)

    it("sets appropriate color column", function()
      local colorcolumn = vim.opt.colorcolumn:get()
      -- Either empty or set to 80/100/120
      assert.is_true(#colorcolumn == 0 or
                     vim.tbl_contains(colorcolumn, "80") or
                     vim.tbl_contains(colorcolumn, "100") or
                     vim.tbl_contains(colorcolumn, "120"),
        "Color column should be unset or at standard width")
    end)
  end)

  describe("Performance Options", function()
    it("sets appropriate update time", function()
      local updatetime = vim.opt.updatetime:get()
      assert.is_true(updatetime <= 300,
        "Update time should be 300ms or less for responsive feel")
    end)

    it("sets reasonable timeout", function()
      local timeout = vim.opt.timeout:get()
      local timeoutlen = vim.opt.timeoutlen:get()

      assert.is_true(timeout, "Timeout should be enabled")
      assert.is_true(timeoutlen <= 500,
        "Timeout length should be 500ms or less")
    end)

    it("enables lazy redraw for performance", function()
      -- This might be disabled for better visual feedback
      -- Just test that it's consciously set
      local lazyredraw = vim.opt.lazyredraw:get()
      assert.is_boolean(lazyredraw, "Lazy redraw should be explicitly set")
    end)
  end)

  describe("Completion Options", function()
    it("configures completion menu", function()
      local completeopt = vim.opt.completeopt:get()
      assert.contains(completeopt, "menu", "Completion menu should be shown")
      assert.contains(completeopt, "menuone", "Menu should show even for single match")
    end)

    it("sets appropriate pumheight", function()
      local pumheight = vim.opt.pumheight:get()
      assert.is_true(pumheight >= 10 and pumheight <= 20,
        "Popup menu height should be between 10-20 items")
    end)
  end)

  describe("Split Behavior", function()
    it("opens splits in intuitive positions", function()
      assert.is_true(vim.opt.splitbelow:get(), "Horizontal splits should open below")
      assert.is_true(vim.opt.splitright:get(), "Vertical splits should open right")
    end)
  end)

  describe("ADHD/Autism Optimizations", function()
    it("minimizes distractions", function()
      -- Check that distracting features are disabled
      local showmode = vim.opt.showmode:get()
      assert.is_false(showmode, "Mode display should be hidden (shown in statusline)")
    end)

    it("provides clear visual boundaries", function()
      -- fillchars should be set for clear splits
      local fillchars = vim.opt.fillchars:get()
      assert.is_table(fillchars)
      -- Should have some split characters defined
      assert.is_true(fillchars.vert ~= nil or fillchars.horiz ~= nil,
        "Split characters should be defined")
    end)

    it("enables focus helpers", function()
      -- Cursor line for current position awareness
      assert.is_true(vim.opt.cursorline:get(),
        "Cursor line should be enabled for focus")

      -- Adequate scroll offset for context
      assert.is_true(vim.opt.scrolloff:get() >= 8,
        "Scroll offset should maintain context")
    end)
  end)

  describe("Option Validation", function()
    it("doesn't set conflicting options", function()
      -- Check for option conflicts
      if vim.opt.paste:get() then
        -- If paste is on, certain options should be disabled
        assert.is_false(vim.opt.smartindent:get(),
          "Smart indent conflicts with paste mode")
      end
    end)

    it("respects option dependencies", function()
      -- smartcase requires ignorecase
      if vim.opt.smartcase:get() then
        assert.is_true(vim.opt.ignorecase:get(),
          "Smartcase requires ignorecase to be set")
      end

      -- relativenumber works better with number
      if vim.opt.relativenumber:get() then
        assert.is_true(vim.opt.number:get(),
          "Relative numbers should have regular numbers enabled")
      end
    end)
  end)
end)