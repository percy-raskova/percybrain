-- Plugin: none-ls (null-ls successor)
-- Purpose: Bridge non-LSP tools (formatters) into LSP ecosystem
-- Workflow: utilities
-- Why: Provides format-on-save for Lua configuration files via stylua.
--      Minimal setup for writing environment - only Lua formatting needed.
-- Config: minimal (writing-focused)
--
-- Usage:
--   Automatic format-on-save (configured in on_attach)
--   :lua vim.lsp.buf.format() - Manual format current buffer
--
-- Dependencies:
--   mason-null-ls (bridges Mason-installed tools to null-ls)
--   External: stylua (Mason-installed, for Lua formatting)
--
-- Configuration Notes:
--   WRITING ENVIRONMENT: Minimal formatter setup
--   - stylua: REQUIRED for Neovim Lua config formatting
--   - All web dev formatters/linters removed (prettier, eslint, black, pylint, etc.)
--   format_on_save: Triggered by BufWritePre autocmd (automatic)
--   Filter setup: Only uses null-ls for formatting (prevents conflicts with LSP servers)

return {
  "nvimtools/none-ls.nvim", -- configure formatters & linters
  lazy = true,
  -- event = { "BufReadPre", "BufNewFile" }, -- to enable uncomment this
  dependencies = {
    "jay-babu/mason-null-ls.nvim",
  },
  config = function()
    local mason_null_ls = require("mason-null-ls")

    local null_ls = require("null-ls")

    local null_ls_utils = require("null-ls.utils")

    mason_null_ls.setup({
      -- WRITING ENVIRONMENT: Only install stylua for Lua formatting
      ensure_installed = {
        "stylua", -- REQUIRED: Lua formatter for Neovim config
        -- All web dev tools removed: prettier, eslint, black, pylint, isort
      },
    })

    -- Setup formatters (no linters needed for writing environment)
    local formatting = null_ls.builtins.formatting

    -- Setup format-on-save autocmd group
    local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

    -- Configure null_ls with minimal sources
    null_ls.setup({
      -- Root directory detection
      root_dir = null_ls_utils.root_pattern(".null-ls-root", "Makefile", ".git"),
      -- WRITING ENVIRONMENT: Only stylua for Lua formatting
      sources = {
        formatting.stylua, -- Lua formatter for Neovim config files
        -- All other formatters/linters removed (prettier, eslint, black, pylint, etc.)
      },
      -- configure format on save
      on_attach = function(current_client, bufnr)
        if current_client.supports_method("textDocument/formatting") then
          vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({
                filter = function(client)
                  --  only use null-ls for formatting
                  return client.name == "null-ls"
                end,
                bufnr = bufnr,
              })
            end,
          })
        end
      end,
    })
  end,
}
