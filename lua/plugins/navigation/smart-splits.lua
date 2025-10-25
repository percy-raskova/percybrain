-- Plugin: Smart Splits
-- Purpose: Intelligent window navigation and resizing with Kitty integration
-- Workflow: navigation
-- Why: ADHD optimization - consistent directional navigation reduces cognitive load.
--      Seamless Kitty integration means muscle memory works everywhere.
--      Smart resizing with visual feedback prevents frustration.
-- Config: full - Kitty integration enabled
--
-- Usage:
--   Navigation (works in both Neovim and Kitty):
--     <C-h/j/k/l> - Move to window left/down/up/right
--
--   Resizing:
--     <A-h/j/k/l> - Resize window left/down/up/right
--     <A-=> - Equalize all windows
--
--   Swapping (optional):
--     <leader>wh/j/k/l - Swap buffer with window left/down/up/right
--
-- Dependencies: Kitty terminal with remote control enabled
-- Multiplexer: Kitty (also supports tmux, wezterm)
--
-- Kitty Configuration Required (~/.config/kitty/kitty.conf):
--   allow_remote_control yes
--   listen_on unix:/tmp/mykitty
--
--   # Optional: Match Neovim navigation keybindings
--   map ctrl+h neighboring_window left
--   map ctrl+l neighboring_window right
--   map ctrl+k neighboring_window up
--   map ctrl+j neighboring_window down

return {
  "mrjones2014/smart-splits.nvim",
  lazy = false, -- Don't lazy load for Kitty integration (needs IS_NVIM user var on startup)
  priority = 50,
  build = "./kitty/install-kittens.bash", -- Install Kitty integration scripts

  config = function()
    require("smart-splits").setup({
      -- Ignored buffer types (won't resize these)
      ignored_buftypes = {
        "nofile",
        "quickfix",
        "prompt",
      },

      -- Ignored filetypes (won't resize these)
      ignored_filetypes = {
        "NvimTree",
        "neo-tree",
        "Trouble",
      },

      -- Default resize amount
      default_amount = 3,

      -- Tmux integration (seamless navigation)
      at_edge = "wrap", -- wrap | stop

      -- Kitty multiplexer integration (seamless Neovim + Kitty navigation)
      multiplexer_integration = "kitty", -- kitty | tmux | wezterm

      -- Disable multiplexer nav when zoomed
      disable_multiplexer_nav_when_zoomed = true,

      -- Cursor follows when moving between splits
      cursor_follows_swapped_bufs = true,

      -- Resize mode settings
      resize_mode = {
        -- Quit resize mode with 'q' or <ESC>
        quit_key = "<ESC>",
        -- Resize mode indication
        silent = false,
        -- Show which direction you're resizing
        hooks = {
          on_enter = function()
            vim.notify("🔧 Resize mode (hjkl to resize, = to equalize, ESC to exit)", vim.log.levels.INFO)
          end,
        },
      },

      -- Log level for debugging (set to 'info' or 'debug' if you have issues)
      log_level = "warn",
    })

    vim.notify("🪟 Smart Splits loaded (Kitty integration active)", vim.log.levels.INFO)
  end,

  keys = {
    -- Navigation (Ctrl + hjkl) - works in tmux too!
    {
      "<C-h>",
      function()
        require("smart-splits").move_cursor_left()
      end,
      desc = "Move to left split",
    },
    {
      "<C-j>",
      function()
        require("smart-splits").move_cursor_down()
      end,
      desc = "Move to below split",
    },
    {
      "<C-k>",
      function()
        require("smart-splits").move_cursor_up()
      end,
      desc = "Move to above split",
    },
    {
      "<C-l>",
      function()
        require("smart-splits").move_cursor_right()
      end,
      desc = "Move to right split",
    },

    -- Resizing (Alt + hjkl)
    {
      "<A-h>",
      function()
        require("smart-splits").resize_left()
      end,
      desc = "Resize split left",
    },
    {
      "<A-j>",
      function()
        require("smart-splits").resize_down()
      end,
      desc = "Resize split down",
    },
    {
      "<A-k>",
      function()
        require("smart-splits").resize_up()
      end,
      desc = "Resize split up",
    },
    {
      "<A-l>",
      function()
        require("smart-splits").resize_right()
      end,
      desc = "Resize split right",
    },

    -- Equalize splits
    {
      "<A-=>",
      function()
        require("smart-splits").equalize()
      end,
      desc = "Equalize all splits",
    },

    -- Swapping buffers (leader + w + direction)
    {
      "<leader>wh",
      function()
        require("smart-splits").swap_buf_left()
      end,
      desc = "Swap buffer left",
    },
    {
      "<leader>wj",
      function()
        require("smart-splits").swap_buf_down()
      end,
      desc = "Swap buffer down",
    },
    {
      "<leader>wk",
      function()
        require("smart-splits").swap_buf_up()
      end,
      desc = "Swap buffer up",
    },
    {
      "<leader>wl",
      function()
        require("smart-splits").swap_buf_right()
      end,
      desc = "Swap buffer right",
    },

    -- Start resize mode (interactive resizing)
    {
      "<leader>wr",
      function()
        require("smart-splits").start_resize_mode()
      end,
      desc = "Enter resize mode",
    },
  },
}
