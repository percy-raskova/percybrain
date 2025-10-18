-- PercyBrain Window Management System
-- Purpose: Intuitive window control with <leader>w prefix
-- Features: Navigation, splitting, moving, closing, layout presets

local M = {}

-- ============================================================================
-- NAVIGATION (<leader>w + hjkl)
-- ============================================================================

-- Navigate to window in direction
M.navigate = function(direction)
  local win_cmds = {
    h = "wincmd h",
    j = "wincmd j",
    k = "wincmd k",
    l = "wincmd l",
  }
  vim.cmd(win_cmds[direction])
end

-- ============================================================================
-- SPLITTING (<leader>ws/wv)
-- ============================================================================

M.split_horizontal = function()
  vim.cmd("split")
  vim.notify("🪟 Horizontal split created", vim.log.levels.INFO)
end

M.split_vertical = function()
  vim.cmd("vsplit")
  vim.notify("🪟 Vertical split created", vim.log.levels.INFO)
end

-- ============================================================================
-- MOVING WINDOWS (<leader>w + HJKL)
-- ============================================================================

-- Move current window in direction
M.move_window = function(direction)
  local move_cmds = {
    H = "wincmd H", -- Move to far left
    J = "wincmd J", -- Move to bottom
    K = "wincmd K", -- Move to top
    L = "wincmd L", -- Move to far right
  }
  vim.cmd(move_cmds[direction])
  vim.notify("🪟 Window moved " .. direction, vim.log.levels.INFO)
end

-- ============================================================================
-- CLOSING (<leader>wc/wo/wq)
-- ============================================================================

M.close_window = function()
  if vim.fn.winnr("$") == 1 then
    vim.notify("⚠️  Cannot close last window", vim.log.levels.WARN)
    return
  end
  vim.cmd("close")
  vim.notify("🪟 Window closed", vim.log.levels.INFO)
end

M.close_other_windows = function()
  vim.cmd("only")
  vim.notify("🪟 All other windows closed", vim.log.levels.INFO)
end

M.quit_window = function()
  vim.cmd("quit")
end

-- ============================================================================
-- RESIZING (<leader>w + =/</>)
-- ============================================================================

M.equalize_windows = function()
  vim.cmd("wincmd =")
  vim.notify("🪟 Windows equalized", vim.log.levels.INFO)
end

M.maximize_width = function()
  vim.cmd("vertical resize | wincmd |")
  vim.notify("🪟 Width maximized", vim.log.levels.INFO)
end

M.maximize_height = function()
  vim.cmd("resize | wincmd _")
  vim.notify("🪟 Height maximized", vim.log.levels.INFO)
end

-- ============================================================================
-- BUFFER MANAGEMENT (<leader>wb/bn/bp/bd)
-- ============================================================================

M.list_buffers = function()
  vim.cmd("Telescope buffers")
end

M.next_buffer = function()
  vim.cmd("bnext")
end

M.prev_buffer = function()
  vim.cmd("bprevious")
end

M.delete_buffer = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local bufname = vim.api.nvim_buf_get_name(bufnr)

  -- Check if buffer is modified
  if vim.api.nvim_buf_get_option(bufnr, "modified") then
    local choice = vim.fn.confirm("Buffer has unsaved changes. Delete anyway?", "&Yes\n&No\n&Save and Delete", 2)
    if choice == 1 then
      vim.cmd("bdelete!")
    elseif choice == 3 then
      vim.cmd("write")
      vim.cmd("bdelete")
    else
      return
    end
  else
    vim.cmd("bdelete")
  end

  vim.notify("🗑️  Buffer deleted: " .. vim.fn.fnamemodify(bufname, ":t"), vim.log.levels.INFO)
end

-- ============================================================================
-- LAYOUT PRESETS
-- ============================================================================

-- Wiki Workflow Layout: File Explorer (left) | Document (center) | Lynx (right)
M.layout_wiki = function()
  -- Close all windows except current
  vim.cmd("only")

  -- Open file tree on left (30% width)
  vim.cmd("NvimTreeOpen")
  vim.cmd("wincmd l") -- Move to main window

  -- Split vertically for Lynx browser on right (40% width)
  vim.cmd("vsplit")
  vim.cmd("wincmd L") -- Move to far right
  vim.cmd("vertical resize 60")

  -- Open terminal for Lynx in right pane
  vim.cmd("terminal")
  vim.defer_fn(function()
    vim.fn.chansend(vim.b.terminal_job_id, "clear\n")
  end, 100)

  -- Return focus to center document window
  vim.cmd("wincmd h")

  vim.notify("📚 Wiki workflow layout activated", vim.log.levels.INFO)
end

-- Focus Layout: Single window, clean workspace
M.layout_focus = function()
  vim.cmd("only")
  vim.cmd("NvimTreeClose")
  vim.notify("✍️  Focus layout activated", vim.log.levels.INFO)
end

-- Reset Layout: Return to default single window
M.layout_reset = function()
  vim.cmd("only")
  vim.cmd("NvimTreeClose")
  vim.cmd("enew") -- New empty buffer
  vim.notify("🔄 Layout reset to default", vim.log.levels.INFO)
end

-- Research Layout: Browser (left) | Document (right)
M.layout_research = function()
  vim.cmd("only")

  -- Split vertically
  vim.cmd("vsplit")
  vim.cmd("wincmd H") -- Move to left

  -- Open terminal for Lynx in left pane
  vim.cmd("terminal")
  vim.defer_fn(function()
    vim.fn.chansend(vim.b.terminal_job_id, "clear\n")
  end, 100)

  -- Return focus to right document window
  vim.cmd("wincmd l")

  vim.notify("🔬 Research layout activated", vim.log.levels.INFO)
end

-- ============================================================================
-- WINDOW INFO
-- ============================================================================

M.window_info = function()
  local wins = vim.api.nvim_list_wins()
  local current = vim.api.nvim_get_current_win()
  local info = string.format("🪟 Windows: %d total, current: %d", #wins, vim.fn.winnr())
  vim.notify(info, vim.log.levels.INFO)
end

-- ============================================================================
-- SETUP KEYBINDINGS
-- ============================================================================

M.setup = function()
  local keymap = vim.keymap.set
  local opts = { noremap = true, silent = true }

  -- Navigation (lowercase hjkl)
  keymap("n", "<leader>wh", function()
    M.navigate("h")
  end, vim.tbl_extend("force", opts, { desc = "Window left" }))
  keymap("n", "<leader>wj", function()
    M.navigate("j")
  end, vim.tbl_extend("force", opts, { desc = "Window down" }))
  keymap("n", "<leader>wk", function()
    M.navigate("k")
  end, vim.tbl_extend("force", opts, { desc = "Window up" }))
  keymap("n", "<leader>wl", function()
    M.navigate("l")
  end, vim.tbl_extend("force", opts, { desc = "Window right" }))

  -- Moving windows (uppercase HJKL)
  keymap("n", "<leader>wH", function()
    M.move_window("H")
  end, vim.tbl_extend("force", opts, { desc = "Move window left" }))
  keymap("n", "<leader>wJ", function()
    M.move_window("J")
  end, vim.tbl_extend("force", opts, { desc = "Move window down" }))
  keymap("n", "<leader>wK", function()
    M.move_window("K")
  end, vim.tbl_extend("force", opts, { desc = "Move window up" }))
  keymap("n", "<leader>wL", function()
    M.move_window("L")
  end, vim.tbl_extend("force", opts, { desc = "Move window right" }))

  -- Splitting
  keymap("n", "<leader>ws", M.split_horizontal, vim.tbl_extend("force", opts, { desc = "Split horizontal" }))
  keymap("n", "<leader>wv", M.split_vertical, vim.tbl_extend("force", opts, { desc = "Split vertical" }))

  -- Closing
  keymap("n", "<leader>wc", M.close_window, vim.tbl_extend("force", opts, { desc = "Close window" }))
  keymap("n", "<leader>wo", M.close_other_windows, vim.tbl_extend("force", opts, { desc = "Close other windows" }))
  keymap("n", "<leader>wq", M.quit_window, vim.tbl_extend("force", opts, { desc = "Quit window" }))

  -- Resizing
  keymap("n", "<leader>w=", M.equalize_windows, vim.tbl_extend("force", opts, { desc = "Equalize windows" }))
  keymap("n", "<leader>w<", M.maximize_width, vim.tbl_extend("force", opts, { desc = "Maximize width" }))
  keymap("n", "<leader>w>", M.maximize_height, vim.tbl_extend("force", opts, { desc = "Maximize height" }))

  -- Buffer management
  keymap("n", "<leader>wb", M.list_buffers, vim.tbl_extend("force", opts, { desc = "List buffers" }))
  keymap("n", "<leader>wn", M.next_buffer, vim.tbl_extend("force", opts, { desc = "Next buffer" }))
  keymap("n", "<leader>wp", M.prev_buffer, vim.tbl_extend("force", opts, { desc = "Previous buffer" }))
  keymap("n", "<leader>wd", M.delete_buffer, vim.tbl_extend("force", opts, { desc = "Delete buffer" }))

  -- Layout presets (uppercase for layouts)
  keymap("n", "<leader>wW", M.layout_wiki, vim.tbl_extend("force", opts, { desc = "Wiki workflow layout" }))
  keymap("n", "<leader>wF", M.layout_focus, vim.tbl_extend("force", opts, { desc = "Focus layout" }))
  keymap("n", "<leader>wR", M.layout_reset, vim.tbl_extend("force", opts, { desc = "Reset layout" }))
  keymap("n", "<leader>wG", M.layout_research, vim.tbl_extend("force", opts, { desc = "Research layout" }))

  -- Info
  keymap("n", "<leader>wi", M.window_info, vim.tbl_extend("force", opts, { desc = "Window info" }))

  vim.notify("🪟 PercyBrain window manager loaded", vim.log.levels.INFO)
end

return M
