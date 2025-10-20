-- Plugin: nvim-cmp
-- Purpose: Intelligent autocompletion engine with LSP, snippets, and buffer content
-- Workflow: completion
-- Why: Reduces typing effort and cognitive load by offering contextual suggestions. Critical for
--      ADHD users who benefit from reduced friction in writing. LSP integration provides accurate
--      code/text completions. Snippets accelerate common patterns. Buffer completion suggests
--      words from current file (helpful for consistent terminology). Path completion reduces
--      errors in file references. Visual icons (lspkind) aid pattern recognition.
-- Config: full - custom keybindings, multiple completion sources, VS Code-style icons
--
-- Usage:
--   <Tab> - Accept selected completion (prose-friendly: Tab = accept, Enter = line break)
--   <S-Tab> - Navigate to previous suggestion
--   <C-j> / <C-k> - Navigate completion suggestions
--   <C-Space> - Manually trigger completion
--   <C-e> - Abort completion
--   <C-b> / <C-f> - Scroll documentation preview
--
-- Dependencies:
--   Internal: LuaSnip (snippet engine), lspkind (icons), friendly-snippets (snippet library)
--   Works with: nvim-lspconfig (LSP completions), cmp-dictionary (academic writing)
--
-- Configuration Notes:
--   - Tab accepts completion (prose-optimized, differs from typical Vim behavior)
--   - Enter inserts line break unless completion is explicitly selected
--   - Completion sources prioritized: LSP > snippets > buffer > paths
--   - Visual icons from lspkind for function, variable, keyword recognition
--   - Integrates with all configured LSP servers (IWE LSP for note titles, etc.)

return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-buffer", -- source for text in buffer
    "hrsh7th/cmp-path", -- source for file system paths
    "L3MON4D3/LuaSnip", -- snippet engine
    "saadparwaiz1/cmp_luasnip", -- for autocompletion
    "rafamadriz/friendly-snippets", -- useful snippets
    "onsails/lspkind.nvim", -- vs-code like pictograms
  },
  config = function()
    local cmp = require("cmp")

    local luasnip = require("luasnip")

    local lspkind = require("lspkind")

    -- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
    require("luasnip.loaders.from_vscode").lazy_load()

    cmp.setup({
      completion = {
        completeopt = "menu,menuone,preview,noselect",
      },
      snippet = { -- configure how nvim-cmp interacts with snippet engine
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-k>"] = cmp.mapping.select_prev_item(), -- previous suggestion
        ["<C-j>"] = cmp.mapping.select_next_item(), -- next suggestion
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(), -- show completion suggestions
        ["<C-e>"] = cmp.mapping.abort(), -- close completion window
        -- Tab to accept completion, Enter for line break
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.confirm({ select = true }) -- accept selected item
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump() -- expand snippet or jump to next placeholder
          else
            fallback() -- insert tab
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item() -- navigate to previous suggestion
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1) -- jump to previous snippet placeholder
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<CR>"] = cmp.mapping({
          i = function(fallback)
            if cmp.visible() and cmp.get_active_entry() then
              cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
            else
              fallback() -- just insert line break
            end
          end,
          s = cmp.mapping.confirm({ select = true }),
          c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false }),
        }),
      }),
      -- sources for autocompletion
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" }, -- snippets
        { name = "buffer" }, -- text within current buffer
        { name = "path" }, -- file system paths
      }),
      -- configure lspkind for vs-code like pictograms in completion menu
      formatting = {
        format = lspkind.cmp_format({
          maxwidth = 50,
          ellipsis_char = "...",
        }),
      },
    })
  end,
}
