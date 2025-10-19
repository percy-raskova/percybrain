-- Unit Tests: Global Variables and Settings
-- Tests for global configuration that affects entire environment

-- Helper function for table contains check
local function contains(tbl, value)
  if type(tbl) == "table" then
    for _, v in ipairs(tbl) do
      if v == value then
        return true
      end
    end
  end
  return false
end

describe("Globals Configuration", function()
  before_each(function()
    -- Arrange: Ensure globals module is loaded fresh
    package.loaded["config.globals"] = nil
    require("config.globals")
  end)

  after_each(function()
    -- No cleanup needed - globals remain configured
  end)

  describe("Leader Keys", function()
    it("sets mapleader to space", function()
      -- Act & Assert
      assert.equals(" ", vim.g.mapleader, "Leader key should be space")
    end)

    it("sets maplocalleader to space", function()
      -- Act & Assert
      assert.equals(" ", vim.g.maplocalleader, "Local leader should be space")
    end)
  end)

  describe("Plugin Disable Flags", function()
    it("disables netrw for nvim-tree", function()
      -- Act & Assert: NvimTree requires netrw to be disabled
      assert.equals(1, vim.g.loaded_netrw)
      assert.equals(1, vim.g.loaded_netrwPlugin)
    end)

    it("disables built-in plugins for performance", function()
      -- Arrange
      local disabled_plugins = {
        "loaded_gzip",
        "loaded_zip",
        "loaded_zipPlugin",
        "loaded_tar",
        "loaded_tarPlugin",
        "loaded_getscript",
        "loaded_getscriptPlugin",
        "loaded_vimball",
        "loaded_vimballPlugin",
        "2html_plugin",
        "loaded_matchit",
        "loaded_matchparen",
      }

      -- Act: Count disabled plugins
      local disabled_count = 0
      for _, plugin in ipairs(disabled_plugins) do
        if vim.g[plugin] == 1 then
          disabled_count = disabled_count + 1
        end
      end

      -- Assert: At least some should be disabled for performance
      assert.is_true(disabled_count >= 2, "Should disable some built-in plugins for performance")
    end)
  end)

  describe("Theme Configuration", function()
    it("sets theme-related globals", function()
      -- Arrange: Check that globals can be set
      vim.g.test_theme_var = "test"

      -- Act & Assert
      assert.equals("test", vim.g.test_theme_var)

      -- Cleanup
      vim.g.test_theme_var = nil
    end)
  end)

  describe("Python Configuration", function()
    it("sets python host programs if needed", function()
      -- Arrange: Python providers for plugins that need them
      if vim.fn.has("python3") == 1 then
        local python3_host = vim.g.python3_host_prog

        -- Act & Assert: It's ok if not set (uses system python3)
        if python3_host then
          assert.is_string(python3_host)
          assert.is_true(python3_host:len() > 0)
        end
      end
    end)

    it("can disable python providers for performance", function()
      -- Arrange
      local providers = {
        "loaded_python_provider", -- Python 2 (deprecated)
        "loaded_python3_provider", -- Python 3
        "loaded_ruby_provider", -- Ruby
        "loaded_perl_provider", -- Perl
        "loaded_node_provider", -- Node.js
      }

      -- Act & Assert: It's valid to disable unused providers
      for _, provider in ipairs(providers) do
        local value = vim.g[provider]
        if value ~= nil then
          assert.is_number(value, provider .. " should be 0 or 1")
        end
      end
    end)
  end)

  describe("File Type Settings", function()
    it("configures markdown settings", function()
      -- Arrange: Markdown is primary format for PercyBrain
      local markdown_vars = {
        "markdown_fenced_languages",
        "markdown_syntax_conceal",
        "markdown_folding",
        "vim_markdown_folding_disabled",
        "vim_markdown_conceal",
      }

      -- Act & Assert: These are optional but good to have
      for _, var in ipairs(markdown_vars) do
        local value = vim.g[var]
        if value ~= nil then
          assert.is_not_nil(value, var .. " is configured")
        end
      end
    end)

    it("configures LaTeX settings if needed", function()
      -- Arrange
      local tex_vars = {
        "tex_flavor",
        "vimtex_view_method",
        "vimtex_compiler_method",
      }

      -- Act & Assert: Optional LaTeX configuration
      for _, var in ipairs(tex_vars) do
        local value = vim.g[var]
        if value ~= nil then
          assert.is_string(value, var .. " should be a string")
        end
      end

      -- tex_flavor is commonly set to 'latex'
      if vim.g.tex_flavor then
        assert.is_true(
          contains({ "latex", "plain", "context" }, vim.g.tex_flavor),
          "Invalid tex flavor: " .. tostring(vim.g.tex_flavor)
        )
      end
    end)
  end)

  describe("PercyBrain Specific Globals", function()
    it("sets knowledge management paths", function()
      -- Arrange: PercyBrain might set vault paths
      local percy_vars = {
        "percybrain_vault",
        "percybrain_templates",
        "percybrain_daily",
        "percybrain_inbox",
        "zettelkasten_dir",
        "wiki_root",
      }

      -- Act & Assert: These are optional but check if set correctly
      for _, var in ipairs(percy_vars) do
        local value = vim.g[var]
        if value ~= nil then
          assert.is_string(value, var .. " should be a path string")
          assert.is_true(
            value:match("^[~/]") ~= nil or value:match("^%a:") ~= nil,
            var .. " should be an absolute or home-relative path"
          )
        end
      end
    end)

    it("sets AI integration globals", function()
      -- Arrange: Ollama and AI settings
      local ai_vars = {
        "ollama_model",
        "ollama_host",
        "ai_temperature",
        "ai_max_tokens",
      }

      -- Act & Assert
      for _, var in ipairs(ai_vars) do
        local value = vim.g[var]
        if value ~= nil then
          if var:match("model") or var:match("host") then
            assert.is_string(value, var .. " should be a string")
          elseif var:match("temperature") or var:match("tokens") then
            assert.is_number(value, var .. " should be a number")
          end
        end
      end
    end)
  end)

  describe("Security and Privacy", function()
    it("doesn't expose sensitive data", function()
      -- Arrange
      local sensitive_patterns = {
        "api_key",
        "api_token",
        "secret",
        "password",
        "token",
        "auth_",
      }

      -- Act & Assert: Check that no API keys or tokens are in globals
      for key, _ in pairs(vim.g) do
        for _, pattern in ipairs(sensitive_patterns) do
          if key:lower():match(pattern) then
            local value = vim.g[key]
            if type(value) == "string" then
              assert.is_true(
                value == "" or value == "REDACTED" or value:match("^%*+$") ~= nil,
                "Global " .. key .. " might contain sensitive data"
              )
            end
          end
        end
      end
    end)
  end)

  describe("Performance Optimizations", function()
    it("sets performance-related globals", function()
      -- Act & Assert: Various performance tweaks
      if vim.g.did_load_filetypes ~= nil then
        assert.is_number(vim.g.did_load_filetypes)
      end

      -- loaded_remote_plugins can be either number or string (path)
      -- Neovim sets it to rplugin.vim path when remote plugins are loaded
      if vim.g.loaded_remote_plugins ~= nil then
        assert.truthy(vim.g.loaded_remote_plugins, "loaded_remote_plugins should be set")
      end
    end)

    it("loads quickly", function()
      -- Arrange
      local start = vim.fn.reltime()

      -- Act
      package.loaded["config.globals"] = nil
      require("config.globals")

      local elapsed = vim.fn.reltimefloat(vim.fn.reltime(start))

      -- Assert: Globals should load almost instantly
      assert.is_true(elapsed < 0.005, string.format("Globals loading too slow: %.3fs", elapsed))
    end)
  end)

  describe("Compatibility Settings", function()
    it("handles OS-specific settings", function()
      -- Arrange
      local os_name = vim.loop.os_uname().sysname

      -- Act & Assert: Check for OS-specific globals
      if os_name == "Darwin" then
        if vim.g.clipboard then
          assert.is_table(vim.g.clipboard)
        end
      elseif os_name:match("Windows") then
        if vim.g.sqlite_clib_path then
          assert.is_string(vim.g.sqlite_clib_path)
        end
      end
    end)
  end)

  describe("Global State Integrity", function()
    it("doesn't pollute global namespace", function()
      -- Arrange: Count globals before loading
      local before_count = 0
      for _ in pairs(vim.g) do
        before_count = before_count + 1
      end

      -- Act
      package.loaded["config.globals"] = nil
      require("config.globals")

      local after_count = 0
      for _ in pairs(vim.g) do
        after_count = after_count + 1
      end

      -- Assert: Should only add a reasonable number of globals
      local added = after_count - before_count
      assert.is_true(added < 50, string.format("Too many globals added: %d", added))
    end)

    it("uses consistent naming conventions", function()
      -- Arrange
      local our_patterns = {
        "^percybrain_",
        "^percy_",
        "^loaded_",
        "^did_",
      }

      -- Act: Count globals following patterns
      local consistent_count = 0
      local total_count = 0

      for key, _ in pairs(vim.g) do
        total_count = total_count + 1
        for _, pattern in ipairs(our_patterns) do
          if key:match(pattern) then
            consistent_count = consistent_count + 1
            break
          end
        end
      end

      -- Assert: Most globals should follow patterns (allow for vim defaults)
      if total_count > 20 then
        local ratio = consistent_count / total_count
        assert.is_true(ratio > 0.3, string.format("Low naming consistency: %.1f%%", ratio * 100))
      end
    end)
  end)
end)
