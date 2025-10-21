-- GTD (Getting Things Done) Workflow Keymaps
-- Namespace: <leader>o (organization) - shares with Goyo focus mode
--
-- GTD Phases:
-- 1. Capture: Collect everything that requires attention
-- 2. Clarify: Process inbox items into actionable outcomes
-- 3. Organize: Put items in appropriate lists/contexts
-- 4. Reflect: Review system weekly to stay current
-- 5. Engage: Execute with confidence based on context
--
-- Note: <leader>o is also used by Goyo (focus mode) which is fine
--       since GTD and focus mode are complementary (organization workflow)

local registry = require("config.keymaps")

local keymaps = {
  -- Phase 1: Capture
  {
    "<leader>oc",
    function()
      local text = vim.fn.input("Quick capture: ")
      if text ~= "" then
        require("percybrain.gtd.capture").quick_capture(text)
        vim.notify("✅ Captured to inbox", vim.log.levels.INFO)
      end
    end,
    desc = "📥 GTD quick capture",
  },

  -- Phase 2: Clarify
  {
    "<leader>op",
    function()
      require("percybrain.gtd.clarify_ui").process_next()
    end,
    desc = "🔄 GTD process inbox (clarify)",
  },

  -- Inbox management
  {
    "<leader>oi",
    function()
      local clarify = require("percybrain.gtd.clarify")
      local count = clarify.inbox_count()
      vim.notify(string.format("📬 %d items in inbox", count), vim.log.levels.INFO)
    end,
    desc = "📬 GTD inbox count",
  },

  -- Phase 3: AI Enhancement
  {
    "<leader>od",
    function()
      require("percybrain.gtd.ai").decompose_task()
    end,
    desc = "🤖 GTD decompose task (AI)",
    mode = { "n" },
  },

  {
    "<leader>ox",
    function()
      require("percybrain.gtd.ai").suggest_context()
    end,
    desc = "🏷️  GTD suggest context (AI)",
    mode = { "n" },
  },

  {
    "<leader>or",
    function()
      require("percybrain.gtd.ai").infer_priority()
    end,
    desc = "⚡ GTD infer priority (AI)",
    mode = { "n" },
  },
}

return registry.register_module("gtd", keymaps)
