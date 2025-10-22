-- Plugin: nvim-lspconfig
-- Purpose: Language Server Protocol configuration for intelligent code features across languages
-- Workflow: lsp
-- Why: Provides IDE-like features (go-to-definition, hover docs, diagnostics, code actions) that
--      reduce cognitive load when writing. Consistent interface across all languages (Lua, Python,
--      JavaScript, Markdown via IWE LSP, LaTeX via ltex-ls). Real-time error detection catches
--      issues early. Autocomplete integration improves writing flow. Critical foundation for
--      PercyBrain's intelligent editing experience.
-- Config: full - comprehensive keybindings and LSP server setup
--
-- Usage:
--   gd - Go to definition
--   gD - Go to declaration
--   gR - Show references (Telescope)
--   gi - Show implementations
--   gt - Show type definitions
--   K - Hover documentation
--   <leader>ca - Code actions
--   <leader>rn - Smart rename
--   <leader>D - Buffer diagnostics
--   <leader>d - Line diagnostics
--   [d / ]d - Navigate diagnostics
--   <leader>rs - Restart LSP
--
-- Dependencies:
--   External: Various LSP servers installed via Mason (html, typescript, css, tailwind, etc.)
--   Internal: nvim-cmp for autocompletion integration
--
-- Configuration Notes:
--   - on_attach: Sets up keybindings for every LSP server
--   - capabilities: Enables nvim-cmp integration for autocompletion
--   - Custom diagnostic signs in gutter (errors, warnings, hints, info)
--   - Configures multiple language servers (HTML, TypeScript, CSS, Tailwind, Lua, etc.)
--   - IWE LSP for markdown is configured separately in zettelkasten/iwe-lsp.lua
--   - ltex-ls for grammar/spelling is configured via Mason

return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
  },
  config = function()
    -- import lspconfig plugin
    local lspconfig = require("lspconfig")

    -- import cmp-nvim-lsp plugin
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    local keymap = vim.keymap -- for conciseness

    local opts = { noremap = true, silent = true }
    local on_attach = function(_client, bufnr)
      opts.buffer = bufnr

      -- set keybinds
      opts.desc = "Show LSP references"
      keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

      opts.desc = "Go to declaration"
      keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

      opts.desc = "Show LSP definitions"
      keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

      opts.desc = "Show LSP implementations"
      keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

      opts.desc = "Show LSP type definitions"
      keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

      opts.desc = "See available code actions"
      -- see available code actions, in visual mode will apply to selection
      keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

      opts.desc = "Smart rename"
      keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

      opts.desc = "Show buffer diagnostics"
      keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

      opts.desc = "Show line diagnostics"
      keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

      opts.desc = "Go to previous diagnostic"
      keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

      opts.desc = "Go to next diagnostic"
      keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

      opts.desc = "Show documentation for what is under cursor"
      keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

      opts.desc = "Restart LSP"
      keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
    end

    -- used to enable autocompletion (assign to every lsp server config)
    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- Change the Diagnostic symbols in the sign column (gutter)
    -- (not in youtube nvim video)
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    -- Helper function to safely configure LSP servers
    -- Only configures if the server is available in lspconfig
    local function safe_setup(server_name, config)
      local ok, server = pcall(function()
        return lspconfig[server_name]
      end)
      if ok and server then
        server.setup(config)
      else
        vim.notify(
          string.format("LSP server '%s' not available - install via Mason or manually", server_name),
          vim.log.levels.WARN
        )
      end
    end

    -- configure html server
    safe_setup("html", {
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- configure typescript server with plugin
    -- FIXED: Use ts_ls instead of deprecated tsserver
    safe_setup("ts_ls", {
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- configure css server
    safe_setup("cssls", {
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- configure tailwindcss server
    safe_setup("tailwindcss", {
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- configure svelte server
    safe_setup("svelte", {
      capabilities = capabilities,
      on_attach = function(client, bufnr)
        on_attach(client, bufnr)

        vim.api.nvim_create_autocmd("BufWritePost", {
          pattern = { "*.js", "*.ts" },
          callback = function(ctx)
            if client.name == "svelte" then
              client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.file })
            end
          end,
        })
      end,
    })
    --
    -- configure LanguageTool grammar checker (ltex-ls)
    -- Only configure if ltex-ls is installed
    if vim.fn.executable("ltex-ls") == 1 then
      -- FIXED: Disable annoying "Checking document" popup notifications
      local ltex_capabilities = vim.deepcopy(capabilities)
      ltex_capabilities.window = ltex_capabilities.window or {}
      ltex_capabilities.window.workDoneProgress = false -- Disable progress popups

      safe_setup("ltex", {
        capabilities = ltex_capabilities,
        on_attach = on_attach,
        filetypes = { "markdown", "text", "tex", "org" },
        settings = {
          ltex = {
            language = "en-US",
            additionalRules = {
              enablePickyRules = true,
            },
            -- Disable status text that shows "Checking document"
            statusBarItem = false,
          },
        },
      })
    else
      -- Notify user that ltex-ls is not installed (info level, not error)
      local ltex_msg = "ltex-ls not found - grammar checking disabled. " .. "Install: https://valentjn.github.io/ltex/"
      vim.notify(ltex_msg, vim.log.levels.INFO)
    end
    --
    -- configure texlab server
    safe_setup("texlab", {
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- configure Grammarly server
    -- FIXED: Use 'grammarly' not 'grammarly-languageserver'
    -- Only configure if grammarly is available
    if vim.fn.executable("grammarly-languageserver") == 1 then
      safe_setup("grammarly", {
        capabilities = capabilities,
        on_attach = on_attach,
      })
    end

    -- configure prisma orm server
    safe_setup("prismals", {
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- configure graphql language server
    safe_setup("graphql", {
      capabilities = capabilities,
      on_attach = on_attach,
      filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
    })

    -- configure emmet language server
    safe_setup("emmet_ls", {
      capabilities = capabilities,
      on_attach = on_attach,
      filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
    })

    -- configure python server
    safe_setup("pyright", {
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- configure lua server (with special settings)
    safe_setup("lua_ls", {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = { -- custom settings for lua
        Lua = {
          -- make the language server recognize "vim" global
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            -- make language server aware of runtime files
            library = {
              [vim.fn.expand("$VIMRUNTIME/lua")] = true,
              [vim.fn.stdpath("config") .. "/lua"] = true,
            },
          },
        },
      },
    })

    -- IWE LSP Configuration
    -- NOTE: IWE LSP server (iwes) is configured via lua/plugins/lsp/iwe.lua
    -- The iwe.nvim plugin automatically starts and manages the iwes server.
    -- No separate lspconfig setup needed - iwe.nvim handles it internally.
    --
    -- See: lua/plugins/lsp/iwe.lua for full IWE configuration
    -- Commands: :IWE lsp start/stop/restart/status
    -- Health check: :checkhealth iwe
  end,
}
