-- Auto-save.nvim: ADHD hyperfocus protection
-- Never lose work during deep focus sessions
-- Repository: https://github.com/pocco81/auto-save.nvim

return {
  "pocco81/auto-save.nvim",
  event = { "InsertLeave", "TextChanged" }, -- Save on meaningful changes
  keys = {
    { "<leader>as", "<cmd>ASToggle<CR>", desc = "💾 Toggle auto-save" },
  },
  config = function()
    require("auto-save").setup({
      enabled = true, -- Start enabled

      -- Save triggers (ADHD-optimized)
      execution_message = {
        message = function()
          return "💾 Auto-saved at " .. vim.fn.strftime("%H:%M:%S")
        end,
        dim = 0.18, -- Subtle notification (not distracting)
        cleaning_interval = 1250, -- Clear message after 1.25s
      },

      -- Events that trigger save (removed TextChanged for less aggressive saving)
      trigger_events = { "InsertLeave" }, -- Only save when leaving insert mode

      -- Conditions
      condition = function(buf)
        local fn = vim.fn
        local utils = require("auto-save.utils.data")

        -- Don't save if:
        if
          fn.getbufvar(buf, "&modifiable") == 1 -- Buffer is modifiable
          and utils.not_in(fn.getbufvar(buf, "&filetype"), {
            -- Don't auto-save these filetypes
            "harpoon",
            "neo-tree",
            "oil",
            "TelescopePrompt",
            "DressingInput",
          })
        then
          return true -- Save this buffer
        end
        return false
      end,

      -- Writing behavior
      write_all_buffers = false, -- Only save current buffer (less disruptive)

      -- Debouncing (prevent too frequent saves)
      debounce_delay = 5000, -- Wait 5 seconds after leaving insert mode (was 135ms)

      -- IMPORTANT: Don't auto-save during these
      callbacks = {
        enabling = nil,
        disabling = nil,
        before_asserting_save = nil,
        before_saving = function()
          -- Don't save if in command mode or visual mode
          local mode = vim.api.nvim_get_mode().mode
          if mode == "c" or mode:match("^[vV]") then
            return false
          end
        end,
        after_saving = nil,
      },
    })

    -- Visual indicator in statusline
    vim.api.nvim_create_autocmd("User", {
      pattern = "AutoSaveWritePre",
      callback = function()
        -- Could add statusline indicator here if needed
        vim.g.autosave_status = "saving"
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "AutoSaveWritePost",
      callback = function()
        vim.g.autosave_status = "saved"
        -- Clear status after a moment
        vim.defer_fn(function()
          vim.g.autosave_status = ""
        end, 2000)
      end,
    })

    -- Periodic auto-save timer (every 5 minutes for modified buffers)
    local function periodic_save()
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_option(buf, "modified") then
          local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
          local filetype = vim.api.nvim_buf_get_option(buf, "filetype")

          -- Only save normal file buffers
          if buftype == "" and filetype ~= "TelescopePrompt" and filetype ~= "DressingInput" then
            vim.api.nvim_buf_call(buf, function()
              vim.cmd("silent! write")
            end)
          end
        end
      end
    end

    -- Start 5-minute timer
    local timer = vim.loop.new_timer()
    timer:start(
      300000, -- Start after 5 minutes (300,000ms)
      300000, -- Repeat every 5 minutes
      vim.schedule_wrap(periodic_save)
    )

    -- Notification
    vim.notify("💾 Auto-save enabled! Saves on InsertLeave + every 5 minutes.", vim.log.levels.INFO)
  end,
}
