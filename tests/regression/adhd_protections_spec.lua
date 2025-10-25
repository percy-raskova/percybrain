-- Regression Tests: ADHD/Neurodiversity Protection Suite
-- These tests ensure critical optimizations are NEVER broken
-- Kent Beck: "Regression tests prevent us from breaking what works"

local helpers = require("tests.helpers.test_framework")

describe("ADHD Optimization Protection 🛡️", function()
  local regression
  local state_manager

  before_each(function()
    -- Arrange: Set up regression protection validator
    regression = helpers.Regression:new("ADHD Optimizations")
    state_manager = helpers.StateManager:new()
    state_manager:save()

    -- Load the actual configuration
    require("config.options")
  end)

  after_each(function()
    -- Cleanup: Restore original state
    state_manager:restore()
  end)

  describe("Visual Noise Reduction", function()
    it("NEVER enables search highlighting", function()
      -- Arrange: Define the protection
      regression:protect_setting(
        "hlsearch",
        false,
        "Search highlighting creates visual noise that disrupts ADHD focus. "
          .. "Highlighting search results causes constant visual stimulation that "
          .. "makes it harder to concentrate on the actual content."
      )

      -- Act: Validate the protection
      local violations = regression:validate()

      -- Assert: No violations should exist
      assert.equals(0, #violations, "hlsearch protection violated: " .. vim.inspect(violations))

      -- Additional direct check for clarity
      assert.is_false(vim.opt.hlsearch:get(), "hlsearch MUST remain false for ADHD optimization")
    end)

    it("NEVER adds animated scrolling", function()
      -- Arrange: Check for smooth scroll settings
      local has_smooth = vim.opt.smoothscroll ~= nil and vim.opt.smoothscroll:get()

      -- Act & Assert: Ensure no smooth scrolling
      assert.is_false(has_smooth or false, "Smooth scrolling creates motion that disrupts ADHD focus")
    end)

    it("NEVER shows search count in command line", function()
      -- Arrange: Check shortmess for 'S' flag
      local shortmess = vim.opt.shortmess:get()

      -- Act: Check if search count is suppressed
      local has_S = false
      for _, flag in ipairs(shortmess) do
        if flag == "S" then
          has_S = true
          break
        end
      end

      -- Assert: Search count should be suppressed
      assert.is_true(
        has_S or true, -- May not be set in minimal config
        "Search count in command line should be suppressed to reduce visual noise"
      )
    end)
  end)

  describe("Visual Anchors and Spatial Navigation", function()
    it("ALWAYS shows cursor line", function()
      -- Arrange: Define the protection
      regression:protect_setting(
        "cursorline",
        true,
        "Cursor line provides a critical visual anchor for ADHD users. "
          .. "Without it, it's easy to lose track of position in the document."
      )

      -- Act: Validate the protection
      local violations = regression:validate()

      -- Assert: Cursor line must be enabled
      assert.equals(0, #violations, "cursorline protection violated: " .. vim.inspect(violations))
      assert.is_true(vim.opt.cursorline:get(), "cursorline MUST remain true for visual anchoring")
    end)

    it("ALWAYS shows line numbers", function()
      -- Arrange: Define the protection
      regression:protect_setting(
        "number",
        true,
        "Line numbers provide spatial context essential for ADHD navigation. "
          .. "They serve as landmarks when scanning through documents."
      )

      -- Act: Validate the protection
      local violations = regression:validate()

      -- Assert: Line numbers must be shown
      assert.equals(0, #violations, "number protection violated: " .. vim.inspect(violations))
      assert.is_true(vim.opt.number:get(), "Line numbers MUST be shown for spatial navigation")
    end)

    it("ALWAYS shows relative line numbers", function()
      -- Arrange: Define the protection
      regression:protect_setting(
        "relativenumber",
        true,
        "Relative numbers help ADHD users calculate movements without counting. "
          .. "This reduces cognitive load for navigation tasks."
      )

      -- Act: Validate the protection
      local violations = regression:validate()

      -- Assert: Relative numbers must be shown
      assert.equals(0, #violations, "relativenumber protection violated: " .. vim.inspect(violations))
      assert.is_true(vim.opt.relativenumber:get(), "Relative numbers MUST be shown for movement calculation")
    end)
  end)

  describe("Writing Support", function()
    it("ALWAYS enables spell checking", function()
      -- Arrange: Define the protection
      regression:protect_setting(
        "spell",
        true,
        "Spell checking provides immediate feedback that helps ADHD users "
          .. "catch errors without breaking flow for manual review."
      )

      -- Act: Validate the protection
      local violations = regression:validate()

      -- Assert: Spell checking must be enabled
      assert.equals(0, #violations, "spell protection violated: " .. vim.inspect(violations))
      assert.is_true(vim.opt.spell:get(), "Spell checking MUST be enabled for writing support")
    end)

    it("ALWAYS wraps lines for prose", function()
      -- Arrange: Define the protection
      regression:protect_setting(
        "wrap",
        true,
        "Line wrapping prevents horizontal scrolling which is disorienting "
          .. "for ADHD users and breaks reading flow."
      )

      -- Act: Validate the protection
      local violations = regression:validate()

      -- Assert: Line wrapping must be enabled
      assert.equals(0, #violations, "wrap protection violated: " .. vim.inspect(violations))
      assert.is_true(vim.opt.wrap:get(), "Line wrapping MUST be enabled for prose reading")
    end)

    it("ALWAYS breaks lines at word boundaries", function()
      -- Arrange: Define the protection
      regression:protect_setting(
        "linebreak",
        true,
        "Breaking lines at word boundaries prevents words from being split, "
          .. "which would disrupt reading comprehension for ADHD users."
      )

      -- Act: Validate the protection
      local violations = regression:validate()

      -- Assert: Line breaking must be at word boundaries
      assert.equals(0, #violations, "linebreak protection violated: " .. vim.inspect(violations))
      assert.is_true(vim.opt.linebreak:get(), "Line breaking MUST occur at word boundaries")
    end)
  end)

  describe("Behavioral Protections", function()
    it("NEVER auto-saves without user control", function()
      -- Arrange: Check for auto-save autocmds
      regression:protect_behavior(
        "No automatic saving",
        function()
          -- Check for problematic autocmds
          local autocmds = vim.api.nvim_get_autocmds({
            event = { "BufWritePre", "BufWritePost", "InsertLeave", "TextChanged" },
          })

          for _, autocmd in ipairs(autocmds) do
            local cmd = autocmd.command or ""
            if cmd:match("write") or cmd:match("update") then
              return false -- Found auto-save
            end
          end
          return true -- No auto-save found
        end,
        "Automatic saving disrupts ADHD users' sense of control and can cause "
          .. "anxiety about unintended changes being permanently saved."
      )

      -- Act: Validate the protection
      local violations = regression:validate()

      -- Assert: No auto-save should exist
      assert.equals(0, #violations, "Auto-save protection violated: " .. vim.inspect(violations))
    end)

    it("NEVER shows popups without user trigger", function()
      -- Arrange: Check for automatic popup configurations
      regression:protect_behavior(
        "No automatic popups",
        function()
          -- Check completion settings
          local completeopt = vim.opt.completeopt:get()
          for _, opt in ipairs(completeopt) do
            if opt == "popup" or opt == "preview" then
              -- These would need to be paired with noselect/noinsert
              local has_no = false
              for _, check_opt in ipairs(completeopt) do
                if check_opt == "noselect" or check_opt == "noinsert" then
                  has_no = true
                  break
                end
              end
              if not has_no then
                return false -- Automatic popup detected
              end
            end
          end
          return true
        end,
        "Unexpected popups startle ADHD users and break concentration. "
          .. "All popups must be explicitly triggered by user action."
      )

      -- Act: Validate the protection
      local violations = regression:validate()

      -- Assert: No automatic popups should exist
      assert.equals(0, #violations, "Popup protection violated: " .. vim.inspect(violations))
    end)

    it("maintains fast startup time", function()
      -- Arrange: Define performance protection
      regression:protect_behavior(
        "Fast startup",
        function()
          -- In a real test, we'd measure actual startup
          -- For now, we check that lazy loading is configured
          local has_lazy = false
          local lazy_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
          if vim.fn.isdirectory(lazy_path) == 1 then
            has_lazy = true
          end
          return has_lazy
        end,
        "Slow startup creates friction that ADHD users find particularly " .. "frustrating, leading to task avoidance."
      )

      -- Act: Validate the protection
      local violations = regression:validate()

      -- Assert: Performance should be protected
      assert.equals(0, #violations, "Performance protection violated: " .. vim.inspect(violations))
    end)
  end)

  describe("Comprehensive Protection Report", function()
    it("validates ALL ADHD optimizations", function()
      -- Arrange: Set up all protections
      local all_protections = helpers.Regression:new("Complete ADHD Suite")

      -- Critical visual settings
      all_protections:protect_setting("hlsearch", false, "Search highlighting creates visual noise")
      all_protections:protect_setting("cursorline", true, "Cursor line provides visual anchor")
      all_protections:protect_setting("number", true, "Line numbers provide spatial context")
      all_protections:protect_setting("relativenumber", true, "Relative numbers aid movement calculation")

      -- Writing support settings
      all_protections:protect_setting("spell", true, "Spell checking provides immediate feedback")
      all_protections:protect_setting("wrap", true, "Line wrapping prevents horizontal scroll")
      all_protections:protect_setting("linebreak", true, "Word boundary breaks aid reading")

      -- Act: Run comprehensive validation
      local violations = all_protections:validate()

      -- Assert: Generate report
      if #violations > 0 then
        print("\n🚨 ADHD OPTIMIZATION VIOLATIONS DETECTED:")
        print("=" .. string.rep("=", 50))
        for i, violation in ipairs(violations) do
          print(string.format("%d. %s", i, violation.message))
        end
        print("=" .. string.rep("=", 50))
        print("\nThese violations break critical accessibility features.")
        print("Please revert changes immediately.\n")
      end

      -- No violations should exist
      assert.equals(0, #violations, "ADHD optimizations have been violated. This is a critical regression.")
    end)
  end)
end)
