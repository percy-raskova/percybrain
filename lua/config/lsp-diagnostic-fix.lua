-- lua/config/lsp-diagnostic-fix.lua
-- Fix for deprecated diagnostic sign_define API
-- Migrates to modern vim.diagnostic.config() API

local M = {}

-- Remove any old sign definitions using deprecated API
local function remove_deprecated_signs()
  -- These are common sign names used by old configs
  local old_sign_names = {
    "DiagnosticSignError",
    "DiagnosticSignWarn",
    "DiagnosticSignInfo",
    "DiagnosticSignHint",
    "LspDiagnosticsSignError",
    "LspDiagnosticsSignWarning",
    "LspDiagnosticsSignInformation",
    "LspDiagnosticsSignHint",
  }

  for _, name in ipairs(old_sign_names) do
    pcall(vim.fn.sign_undefine, name)
  end
end

-- Configure diagnostics using modern API
function M.configure_diagnostics()
  -- Remove old signs first
  remove_deprecated_signs()

  -- Configure using modern vim.diagnostic.config API
  vim.diagnostic.config({
    -- Virtual text configuration
    virtual_text = {
      prefix = "●", -- Icon to show before virtual text
      spacing = 4, -- Spacing between code and virtual text
      source = "if_many", -- Show source only if multiple sources
      severity = {
        min = vim.diagnostic.severity.HINT,
      },
    },

    -- Sign column configuration (modern API)
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = "✗",
        [vim.diagnostic.severity.WARN] = "⚠",
        [vim.diagnostic.severity.INFO] = "ℹ",
        [vim.diagnostic.severity.HINT] = "➤",
      },
      -- Optional: Add highlight groups for line/number highlights
      linehl = {
        [vim.diagnostic.severity.ERROR] = "ErrorMsg",
        [vim.diagnostic.severity.WARN] = "WarningMsg",
      },
      numhl = {
        [vim.diagnostic.severity.ERROR] = "ErrorMsg",
        [vim.diagnostic.severity.WARN] = "WarningMsg",
      },
    },

    -- Floating window configuration
    float = {
      focusable = false,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },

    -- Underline configuration
    underline = {
      severity = {
        min = vim.diagnostic.severity.HINT,
      },
    },

    -- Update diagnostics in insert mode
    update_in_insert = false,

    -- Sort diagnostics by severity
    severity_sort = true,
  })

  vim.notify("LSP diagnostics configured with modern API", vim.log.levels.INFO, { title = "LSP Diagnostic Fix" })
end

-- Setup LSP handlers with modern API
function M.setup_lsp_handlers()
  -- Configure hover handler
  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "rounded",
    width = 60,
  })

  -- Configure signature help handler
  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = "rounded",
    width = 60,
  })

  -- Configure diagnostics handler
  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.handlers.on_publish_diagnostics, {
    -- Use modern diagnostic config instead of deprecated signs
    signs = false, -- Let vim.diagnostic.config handle signs
    virtual_text = false, -- Let vim.diagnostic.config handle virtual text
    underline = true,
    update_in_insert = false,
  })
end

-- Check if any plugin is using deprecated API
function M.check_for_deprecated_usage()
  -- Monkey-patch sign_define to detect usage
  local original_sign_define = vim.fn.sign_define
  local deprecated_callers = {}

  vim.fn.sign_define = function(name, dict)
    -- Detect if this is a diagnostic sign
    if name:match("Diagnostic") or name:match("LspDiagnostic") then
      local info = debug.getinfo(2, "Sl")
      table.insert(deprecated_callers, {
        name = name,
        source = info.short_src,
        line = info.currentline,
      })

      vim.notify(
        string.format("Deprecated sign_define usage detected: %s from %s:%d", name, info.short_src, info.currentline),
        vim.log.levels.WARN,
        { title = "LSP Diagnostic Fix" }
      )
    end

    -- Still call the original function for compatibility
    return original_sign_define(name, dict)
  end

  -- Restore original after a short delay
  vim.defer_fn(function()
    vim.fn.sign_define = original_sign_define
    if #deprecated_callers > 0 then
      vim.notify(
        string.format(
          "Found %d deprecated diagnostic sign definitions. Consider updating plugins.",
          #deprecated_callers
        ),
        vim.log.levels.WARN,
        { title = "LSP Diagnostic Fix" }
      )
    end
  end, 1000)
end

-- Main setup function
function M.setup()
  -- Configure diagnostics with modern API
  M.configure_diagnostics()

  -- Setup LSP handlers
  M.setup_lsp_handlers()

  -- Check for deprecated usage (for debugging)
  M.check_for_deprecated_usage()
end

return M
