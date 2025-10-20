-- Plugin: none-ls (null-ls successor)
-- Purpose: Bridge non-LSP tools (formatters/linters) into LSP ecosystem
-- Workflow: utilities
-- Why: Unified tooling interface - makes formatters like prettier and linters like
--      eslint work through LSP protocol, providing consistent UX with language servers.
--      ADHD-optimized through automatic format-on-save (eliminates manual formatting),
--      unified diagnostic display (all issues in one place), and predictable behavior.
--      Critical for maintaining code quality without cognitive overhead of manual tool invocation.
-- Config: full
--
-- Usage:
--   Automatic format-on-save (configured in on_attach)
--   :lua vim.lsp.buf.format() - Manual format current buffer
--   Diagnostics appear inline with LSP diagnostics
--
-- Dependencies:
--   mason-null-ls (bridges Mason-installed tools to null-ls)
--   External: prettier, stylua, black, isort, pylint, eslint_d (Mason-installed)
--
-- Configuration Notes:
--   ensure_installed: Auto-installs formatters/linters via Mason
--   format_on_save: Triggered by BufWritePre autocmd (automatic)
--   root_dir detection: Uses .null-ls-root, Makefile, .git, package.json
--   Conditional linting: eslint_d only runs if .eslintrc.js/cjs exists
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
      ensure_installed = {
        "prettier", -- prettier formatter
        "stylua", -- lua formatter
        "black", -- python formatter
        "pylint", -- python linter
        "eslint_d", -- js linter
      },
    })

    -- for conciseness
    local formatting = null_ls.builtins.formatting -- to setup formatters
    local diagnostics = null_ls.builtins.diagnostics -- to setup linters

    -- to setup format on save
    local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

    -- configure null_ls
    null_ls.setup({
      -- add package.json as identifier for root (for typescript monorepos)
      root_dir = null_ls_utils.root_pattern(".null-ls-root", "Makefile", ".git", "package.json"),
      -- setup formatters & linters
      sources = {
        --  to disable file types use
        --  "formatting.prettier.with({disabled_filetypes: {}})" (see null-ls docs)
        formatting.prettier.with({
          extra_filetypes = { "svelte" },
        }), -- js/ts formatter
        formatting.stylua, -- lua formatter
        formatting.isort,
        formatting.black,
        diagnostics.pylint,
        diagnostics.eslint_d.with({ -- js/ts linter
          condition = function(utils)
            -- only enable if root has .eslintrc.js or .eslintrc.cjs
            return utils.root_has_file({ ".eslintrc.js", ".eslintrc.cjs" })
          end,
        }),
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
