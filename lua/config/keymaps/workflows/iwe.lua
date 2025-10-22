--- IWE (Integrated Writing Environment) Keymaps
--- Namespace: <leader>z* (zettelkasten navigation), <leader>zr* (refactoring), <leader>ip* (preview)
--- @module config.keymaps.workflows.iwe
---
--- IWE provides LSP features for interconnected markdown notes:
--- - Smart linking and reference navigation
--- - Zettelkasten-aware symbols and backlinks
--- - List/section refactoring
--- - Preview generation for exports
---
--- Keybinding Design (Writer-First Philosophy):
--- - <leader>z* prefix: CONSOLIDATED Zettelkasten navigation (all note operations in one namespace)
--- - <leader>zr* prefix: Zettelkasten refactoring operations
--- - <leader>ip* prefix: IWE Preview features (publishing-related, separate from core workflow)
---
--- DESIGN RATIONALE:
--- Writers need all note operations in ONE namespace for "speed of thought" access.
--- Previous g* and <leader>i* scattered navigation - now unified under <leader>z*.

local registry = require("config.keymaps")

local keymaps = {
  -- ========================================================================
  -- ZETTELKASTEN NAVIGATION (<leader>z* prefix)
  -- ========================================================================
  -- Consolidated from previous g* prefix for writer-first workflow
  -- Capital letters avoid conflicts with existing <leader>z* lowercase bindings

  { "<leader>zF", "<cmd>Telescope iwe_files<CR>", desc = "🔍 IWE: Find files" },
  { "<leader>zS", "<cmd>Telescope iwe_workspace_symbols<CR>", desc = "📂 IWE: Workspace symbols" },
  { "<leader>zA", "<cmd>Telescope iwe_namespace_symbols<CR>", desc = "🏷️  IWE: Namespace symbols" },
  { "<leader>z/", "<cmd>Telescope iwe_live_grep<CR>", desc = "🔎 IWE: Live grep" },
  { "<leader>zB", "<cmd>Telescope lsp_references<CR>", desc = "🔗 IWE: Backlinks (LSP)" },
  { "<leader>zO", "<cmd>Telescope lsp_document_symbols<CR>", desc = "📋 IWE: Document outline" },

  -- ========================================================================
  -- ZETTELKASTEN REFACTORING (<leader>zr* prefix)
  -- ========================================================================
  -- Consolidated from previous <leader>i* prefix
  -- All note refactoring operations in zettelkasten namespace

  -- Extract/Inline (Core IWE Workflow)
  { "<leader>zrx", "<cmd>IweExtract<CR>", desc = "✂️  Extract section to new note" },
  { "<leader>zri", "<cmd>IweInline<CR>", desc = "📥 Inline note content here" },
  { "<leader>zrf", "<cmd>IweFormat<CR>", desc = "📐 Format document structure" },

  -- List/Heading Rewriting
  {
    "<leader>zrh",
    function()
      vim.lsp.buf.code_action({
        filter = function(a)
          return a.title:match("Rewrite list section")
        end,
      })
    end,
    desc = "✏️  Rewrite list → heading",
  },

  {
    "<leader>zrl",
    function()
      vim.lsp.buf.code_action({
        filter = function(a)
          return a.title:match("Rewrite section list")
        end,
      })
    end,
    desc = "✏️  Rewrite heading → list",
  },

  -- ========================================================================
  -- PREVIEW GENERATION (<leader>ip* prefix)
  -- ========================================================================
  -- Generate various preview formats for export and visualization

  { "<leader>ips", "<cmd>IWEPreviewSquash<CR>", desc = "📊 IWE: Generate squash preview" },
  { "<leader>ipe", "<cmd>IWEPreviewExport<CR>", desc = "📤 IWE: Generate export graph preview" },
  { "<leader>iph", "<cmd>IWEPreviewHeaders<CR>", desc = "📑 IWE: Generate export with headers preview" },
  { "<leader>ipw", "<cmd>IWEPreviewWorkspace<CR>", desc = "🌍 IWE: Generate workspace preview" },
}

return registry.register_module("workflows.iwe", keymaps)
