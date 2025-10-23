-- AI and SemBr Keymaps
-- Namespace: <leader>a (AI)

local registry = require("config.keymaps")

local keymaps = {
  -- AI operations (normal mode)
  { "<leader>aa", "<cmd>AIMenu<cr>", desc = "🤖 AI menu" },
  { "<leader>ac", "<cmd>AIChat<cr>", desc = "💬 AI chat" },
  { "<leader>ae", "<cmd>AIExplain<cr>", desc = "📖 Explain selection" },
  { "<leader>as", "<cmd>AISummarize<cr>", desc = "📝 Summarize" },
  { "<leader>ad", "<cmd>AIDraft<cr>", desc = "✍️  Draft text" },
  { "<leader>ar", "<cmd>AIRewrite<cr>", desc = "✨ Rewrite" },
  { "<leader>am", "<cmd>AIModelSelect<cr>", desc = "🔧 Select model" },

  -- VISUAL MODE: AI operations on selected text
  { "<leader>ae", "<cmd>AIExplain<cr>", desc = "📖 Explain selection", mode = "v" },
  { "<leader>as", "<cmd>AISummarize<cr>", desc = "📝 Summarize selection", mode = "v" },
  {
    "<leader>ar",
    function()
      -- Trigger IWE rewrite code action for visual selection
      vim.lsp.buf.code_action({
        filter = function(action)
          return action.kind and action.kind:match("custom.rewrite")
        end,
        apply = true,
      })
    end,
    desc = "✨ Rewrite selection (IWE AI)",
    mode = "v",
  },
  {
    "<leader>ax",
    function()
      -- Trigger IWE expand code action
      vim.lsp.buf.code_action({
        filter = function(action)
          return action.kind and action.kind:match("custom.expand")
        end,
        apply = true,
      })
    end,
    desc = "📈 Expand selection (IWE AI)",
    mode = "v",
  },
  {
    "<leader>ak",
    function()
      -- Trigger IWE keywords code action
      vim.lsp.buf.code_action({
        filter = function(action)
          return action.kind and action.kind:match("custom.keywords")
        end,
        apply = true,
      })
    end,
    desc = "🔑 Bold keywords in selection (IWE AI)",
    mode = "v",
  },
  {
    "<leader>aj",
    function()
      -- Trigger IWE emoji code action
      vim.lsp.buf.code_action({
        filter = function(action)
          return action.kind and action.kind:match("custom.emoji")
        end,
        apply = true,
      })
    end,
    desc = "😊 Add emojis to selection (IWE AI)",
    mode = "v",
  },
}

return registry.register_module("ai", keymaps)
