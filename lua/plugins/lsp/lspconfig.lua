-- Plugin: nvim-lspconfig
-- Purpose: Language Server Protocol configuration for writing environment
-- Workflow: lsp
-- Why: Provides IDE-like features for Neovim configuration (lua_ls) and optional writing tools
--      (ltex_plus for grammar, texlab for LaTeX). IWE LSP provides markdown intelligence.
--      Minimal setup focused on writing workflow, not web development.
-- Config: minimal (writing-focused)
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
--   External: lua_ls (Mason), optional: ltex_plus, texlab (Mason)
--   Internal: nvim-cmp for autocompletion integration
--
-- Configuration Notes:
--   WRITING ENVIRONMENT: Minimal LSP configuration
--   - on_attach: Sets up keybindings for every LSP server
--   - capabilities: Enables nvim-cmp integration for autocompletion
--   - Custom diagnostic signs in gutter (errors, warnings, hints, info)
--   - lua_ls: REQUIRED for Neovim configuration editing
--   - ltex_plus: OPTIONAL grammar/spelling checker (conditionally configured)
--   - texlab: OPTIONAL LaTeX support (conditionally configured)
--   - IWE LSP (iwes): Configured separately in lua/plugins/lsp/iwe.lua
--
--   ALL WEB DEV LSPs REMOVED: tsserver, html, css, tailwind, svelte, graphql,
--   emmet, prisma, pyright, grammarly - not needed for writing environment

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

      -- Custom gd behavior for markdown (Zettelkasten navigation)
      -- For non-markdown, use standard LSP definition lookup
      if vim.bo[bufnr].filetype == "markdown" then
        opts.desc = "Follow link or create new note"
        keymap.set("n", "gd", function()
          require("lib.zettelkasten-nav").follow_or_create()
        end, opts)
      else
        opts.desc = "Show LSP definitions"
        keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions
      end

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
    -- Modern API (replaces deprecated sign_define)
    vim.diagnostic.config({
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = signs.Error,
          [vim.diagnostic.severity.WARN] = signs.Warn,
          [vim.diagnostic.severity.HINT] = signs.Hint,
          [vim.diagnostic.severity.INFO] = signs.Info,
        },
      },
    })

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

    -- ========================================================================
    -- WRITING ENVIRONMENT LSP CONFIGURATION
    -- ========================================================================
    -- This configuration is minimal and focused on writing workflow:
    -- - lua_ls: REQUIRED for Neovim config editing
    -- - ltex_plus: OPTIONAL grammar/spelling checker
    -- - texlab: OPTIONAL LaTeX support
    -- - IWE (iwes): Managed by iwe.nvim plugin (see lua/plugins/lsp/iwe.lua)
    --
    -- All web development LSPs have been removed (html, css, typescript, etc.)
    -- ========================================================================

    -- Configure Lua LSP (REQUIRED for Neovim configuration)
    safe_setup("lua_ls", {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        Lua = {
          -- Make language server recognize "vim" global
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            -- Make language server aware of runtime files
            library = {
              [vim.fn.expand("$VIMRUNTIME/lua")] = true,
              [vim.fn.stdpath("config") .. "/lua"] = true,
            },
          },
        },
      },
    })

    -- ========================================================================
    -- PROSE WRITING: ltex grammar checker
    -- ========================================================================
    -- NOTE: ltex-ls is installed via Mason (mason-lspconfig handles it)
    -- This manual setup configures filetypes and settings for prose writing
    -- Server name in lspconfig is "ltex" (not "ltex_plus")
    -- ========================================================================

    local ltex_capabilities = vim.deepcopy(capabilities)
    ltex_capabilities.window = ltex_capabilities.window or {}
    ltex_capabilities.window.workDoneProgress = false -- Disable progress popups

    safe_setup("ltex", {
      capabilities = ltex_capabilities,
      on_attach = on_attach,
      filetypes = { "markdown", "text", "tex", "org" }, -- All prose filetypes
      settings = {
        ltex = {
          language = "en-US",
          additionalRules = {
            enablePickyRules = true, -- More thorough grammar checking for prose
          },
          statusBarItem = false, -- Disable "Checking document" status text
          -- Technical terms dictionary (Rust crates, libraries, etc.)
          dictionary = {
            ["en-US"] = { "reqwest", "tokio", "serde", "async" },
          },
        },
      },
    })

    -- ========================================================================
    -- DISABLE CONFLICTING MARKDOWN LSPs
    -- ========================================================================
    -- Explicitly disable marksman to prevent conflicts with IWE
    -- (marksman installed system-wide via Homebrew)
    lspconfig.marksman.setup({
      autostart = false, -- Don't start automatically
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
