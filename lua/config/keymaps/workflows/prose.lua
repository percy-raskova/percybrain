-- Prose Writing Keymaps
-- Namespace: <leader>p (prose - writer-first workflow)
--
-- WRITER-FIRST PHILOSOPHY:
-- This namespace consolidates all prose-focused writing tools.
-- Writers need quick access to focus modes, word counts, spell checking, etc.
--
-- DESIGN CHANGES (2025-10-21):
-- - Expanded from 4 to 10+ prose-specific operations
-- - Added reading mode, word count, spell/grammar tools
-- - Integrated time tracking under <leader>pt* (prose timer)
-- - Renamed <leader>pd → <leader>pf (focus mode - more mnemonic)

local registry = require("config.keymaps")

local keymaps = {
  -- Prose mode toggle
  { "<leader>pp", "<cmd>Prose<cr>", desc = "✍️  Prose mode toggle" },

  -- Focus and reading modes
  { "<leader>pf", "<cmd>Goyo<CR>", desc = "🎯 Focus mode (Goyo)" },
  { "<leader>pr", "<cmd>set number! relativenumber! signcolumn=no<CR>", desc = "📖 Reading mode" },

  -- Document preview and styling
  { "<leader>pm", "<cmd>StyledocToggle<cr>", desc = "📝 Toggle StyledDoc preview" },
  { "<leader>pP", "<cmd>PasteImage<cr>", desc = "📷 Paste image (capital P)" },

  -- Word count and stats
  {
    "<leader>pw",
    function()
      local wc = vim.fn.wordcount()
      vim.notify(
        string.format("Words: %d | Chars: %d | Lines: %d", wc.words or 0, wc.chars or 0, vim.fn.line("$")),
        vim.log.levels.INFO
      )
    end,
    desc = "📊 Word count stats",
  },

  -- Spell and grammar checking
  { "<leader>ps", "<cmd>set spell!<CR>", desc = "✅ Toggle spell check" },
  { "<leader>pg", "<cmd>LspStart ltex<CR>", desc = "📝 Start grammar check (ltex)" },

  -- Time tracking (consolidated from <leader>op*)
  { "<leader>pts", "<cmd>PendulumStart<CR>", desc = "⏱️  Timer start" },
  { "<leader>pte", "<cmd>PendulumStop<CR>", desc = "⏹️  Timer stop" },
  { "<leader>ptt", "<cmd>PendulumStatus<CR>", desc = "📊 Timer status" },
  { "<leader>ptr", "<cmd>PendulumReport<CR>", desc = "📈 Timer report" },
}

return registry.register_module("prose", keymaps)
