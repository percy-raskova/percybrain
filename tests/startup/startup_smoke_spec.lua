-- Startup Smoke Tests for PercyBrain
-- Tests the contract: "Neovim starts cleanly without warnings or errors"
-- Kent Beck: "Test what users experience first - can they even start?"

describe("Startup Smoke Tests 🚀", function()
  before_each(function()
    -- Arrange: Startup tests don't need state management
  end)

  after_each(function()
    -- Cleanup: No state to restore for startup tests
  end)

  describe("LSP Configuration Contract", function()
    it("should NOT produce deprecation warnings at startup", function()
      -- Arrange: Run neovim and capture messages
      local handle = io.popen("timeout 10 nvim --headless -c 'qa!' 2>&1")
      if not handle then
        assert.fail("Could not run nvim to check for deprecation warnings")
        return
      end

      -- Act: Read startup output
      local output = handle:read("*all")
      handle:close()

      -- Assert: Should NOT have deprecation warnings
      local has_deprecation = output:match("[Dd]eprecated") and output:match("lspconfig")

      -- NOTE: nvim-lspconfig plugin is still valid and maintained
      -- The deprecation is about using the old "framework" API
      -- This test checks that we don't get runtime warnings, not code patterns
      if has_deprecation then
        assert.fail("LSP deprecation warning detected at startup: " .. (output:match("deprecated.-\n") or "unknown"))
      end
    end)

    it("should use ts_ls instead of deprecated tsserver", function()
      -- Arrange: Load LSP config
      local config_path = vim.fn.stdpath("config") .. "/lua/plugins/lsp/lspconfig.lua"
      local file = io.open(config_path, "r")
      assert.is_not_nil(file)

      -- Act: Check for deprecated tsserver usage
      local content = file:read("*all")
      file:close()

      -- Assert: Should NOT use tsserver
      local uses_tsserver = content:match("lspconfig%[?[\"']tsserver[\"']%]?")
      assert.is_nil(uses_tsserver, "DEPRECATED: 'tsserver' is deprecated. Use 'ts_ls' instead (lspconfig migration)")
    end)

    it("should NOT configure non-existent language servers", function()
      -- Arrange: List of LSP servers configured
      local config_path = vim.fn.stdpath("config") .. "/lua/plugins/lsp/lspconfig.lua"
      local file = io.open(config_path, "r")
      local content = file:read("*all")
      file:close()

      -- Act: Find grammarly-languageserver configuration
      local configures_grammarly = content:match("lspconfig%[?[\"']grammarly%-languageserver[\"']%]?")

      -- Assert: Should have availability check OR not configure at all
      -- grammarly-languageserver doesn't exist in lspconfig
      if configures_grammarly then
        -- Should have conditional setup
        local has_check = content:match("if.*executable.*grammarly") or content:match("pcall.*lspconfig.*grammarly")

        local error_msg = "grammarly-languageserver configured without availability check. "
          .. "This LSP doesn't exist in lspconfig - should be 'grammarly' only"

        assert.is_truthy(has_check, error_msg)
      end
    end)

    it("should gracefully handle missing ltex-ls", function()
      -- Arrange: Check if ltex-ls is installed
      local ltex_installed = vim.fn.executable("ltex-ls") == 1

      -- Act: Load LSP config
      local config_path = vim.fn.stdpath("config") .. "/lua/plugins/lsp/lspconfig.lua"
      local file = io.open(config_path, "r")
      local content = file:read("*all")
      file:close()

      -- Assert: If not installed, should have conditional setup
      if not ltex_installed then
        local configures_ltex = content:match("lspconfig%[?[\"']ltex[\"']%]?%.setup")
        local has_availability_check = content:match("if.*executable.*ltex") or content:match("pcall")

        if configures_ltex and not has_availability_check then
          local error_msg = "ltex configured but not installed and no availability check. "
            .. "Should check with vim.fn.executable('ltex-ls')"
          assert.fail(error_msg)
        end
      end
    end)
  end)

  describe("Plugin Configuration Contract", function()
    it("gitsigns should NOT use invalid configuration fields", function()
      -- Arrange: Load gitsigns config
      local config_path = vim.fn.stdpath("config") .. "/lua/plugins/utilities/gitsigns.lua"
      local file = io.open(config_path, "r")
      assert.is_not_nil(file, "Gitsigns config must exist")

      -- Act: Read configuration
      local content = file:read("*all")
      file:close()

      -- Assert: Check for invalid fields
      local invalid_fields = {
        { pattern = "yadm%s*=%s*{", name = "yadm", reason = "Removed in gitsigns 0.7+" },
        {
          pattern = "_extmark_signs%s*=%s*true",
          name = "_extmark_signs",
          reason = "Internal field (underscore prefix)",
        },
        { pattern = "_threaded_diff%s*=%s*true", name = "_threaded_diff", reason = "Internal field" },
        {
          pattern = "_refresh_staged_on_update%s*=%s*true",
          name = "_refresh_staged_on_update",
          reason = "Internal field",
        },
      }

      local violations = {}
      for _, field in ipairs(invalid_fields) do
        if content:match(field.pattern) then
          table.insert(violations, string.format("  - %s: %s", field.name, field.reason))
        end
      end

      if #violations > 0 then
        assert.fail("Gitsigns has invalid configuration fields:\n" .. table.concat(violations, "\n"))
      end
    end)
  end)

  describe("User Experience Contract", function()
    it("should NOT show annoying ltex_plus status popups", function()
      -- Arrange: Check if ltex_plus is configured
      local ltex_plus_path = vim.fn.stdpath("config") .. "/lua/plugins/prose-writing/ltex_plus.lua"
      local file = io.open(ltex_plus_path, "r")

      if not file then
        -- ltex_plus not configured, test passes
        assert.is_true(true, "ltex_plus not configured")
        return
      end

      -- Act: Read configuration
      local content = file:read("*all")
      file:close()

      -- Assert: Status messages should be disabled
      local has_status_disabled = content:match("window.*enabled%s*=%s*false")
        or content:match("statusText.*enabled%s*=%s*false")

      assert.is_truthy(
        has_status_disabled,
        "ltex_plus shows annoying 'Checking document' popup. "
          .. "Disable with: window = { enabled = false } or statusText = { enabled = false }"
      )
    end)

    it("should NOT show LICENSE file on startup", function()
      -- Arrange: Potential LICENSE file locations
      local config_root = vim.fn.stdpath("config")
      local license_locations = {
        config_root .. "/LICENSE",
        config_root .. "/LICENSE.md",
        config_root .. "/LICENSE.txt",
      }

      -- Act: Check for auto-read configuration
      for _, license_path in ipairs(license_locations) do
        if vim.fn.filereadable(license_path) == 1 then
          -- Assert: Should not be in startup files
          local init_lua = config_root .. "/init.lua"
          local file = io.open(init_lua, "r")
          if file then
            local content = file:read("*all")
            file:close()

            local opens_license = content:match("edit.*LICENSE") or content:match("view.*LICENSE")

            assert.is_nil(opens_license, "init.lua opens LICENSE file on startup - remove this")
          end
        end
      end
    end)
  end)

  describe("Startup Performance Contract", function()
    it("should start without blocking operations", function()
      -- Arrange: Measure startup time
      local start_time = vim.loop.hrtime()

      -- Act: Source configuration
      vim.cmd("silent! runtime plugin/**/*.lua")

      local elapsed_ns = vim.loop.hrtime() - start_time
      local elapsed_ms = elapsed_ns / 1000000

      -- Assert: Should be reasonably fast (< 2000ms for plugin loading)
      assert.is_true(elapsed_ms < 2000, string.format("Plugin loading took %.2fms (should be < 2000ms)", elapsed_ms))
    end)
  end)
end)
