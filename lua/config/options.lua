local opt = vim.opt

-- Indentation
opt.expandtab = true -- Use spaces instead of tabs
opt.tabstop = 2 -- 2 spaces per tab
opt.shiftwidth = 2 -- 2 spaces for indentation level
opt.smartindent = true -- Smart autoindenting

-- Text Display
opt.wrap = true -- Wrap long lines
opt.linebreak = true -- Break at word boundaries, not mid-word
opt.textwidth = 0 -- No hard wrapping (0 = unlimited)

-- Grammar and spell check
opt.spelllang = "en"
opt.spell = true

-- Search
opt.incsearch = true -- Show matches while typing
opt.ignorecase = true -- Case insensitive search
opt.smartcase = true -- Unless uppercase used
opt.hlsearch = false -- Don't highlight search (intentional for focus)

-- Appearance
opt.number = true
opt.relativenumber = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cmdheight = 1
opt.scrolloff = 10 -- Keep 10 lines visible above/below cursor
opt.cursorline = true -- Highlight current line for focus

-- Behavior
opt.hidden = true
opt.errorbells = false
opt.splitright = true -- New vertical splits go right
opt.splitbelow = true -- New horizontal splits go below
opt.autochdir = false
opt.iskeyword:append("a")
opt.clipboard:append("unnamedplus")
opt.modifiable = true
opt.encoding = "UTF-8"
opt.mouse = "a" -- Enable mouse in all modes
opt.mousemoveevent = true -- Enable mouse move events (for bufferline hover)

-- File Handling
opt.swapfile = false -- No swap files (we have undo)
opt.backup = false -- No backup files
opt.writebackup = false -- No backup while editing
opt.undofile = true -- Persistent undo history
opt.undodir = { vim.fn.stdpath("state") .. "/undo" }
opt.fixendofline = false -- Don't automatically remove trailing blank lines on save

-- Performance
opt.updatetime = 250 -- Faster completion (default 4000ms)
opt.timeoutlen = 300 -- Faster key sequence completion
opt.ttimeoutlen = 10 -- Faster key code sequences
opt.lazyredraw = false -- Don't redraw during macros

-- Completion
opt.completeopt = "menuone,noselect"
opt.pumheight = 15 -- Maximum 15 items in popup menu

-- ADHD/Autism Optimizations
opt.showmode = false -- Don't show mode (it's in statusline)
opt.fillchars = {
  vert = "│", -- Vertical separator
  horiz = "─", -- Horizontal separator
  horizup = "┴",
  horizdown = "┬",
  vertleft = "┤",
  vertright = "├",
  verthoriz = "┼",
}
