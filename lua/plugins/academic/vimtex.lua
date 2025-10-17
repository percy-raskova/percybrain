-- Plugin: VimTeX
-- Purpose: Comprehensive LaTeX support with compilation and viewing
-- Workflow: academic
-- Config: full

return {
  "lervag/vimtex",
  ft = { "tex", "bib" }, -- Load for LaTeX and BibTeX files
  config = function()
    -- Compiler settings
    vim.g.vimtex_compiler_method = "latexmk" -- Use latexmk for compilation
    vim.g.vimtex_compiler_latexmk = {
      build_dir = "build", -- Output directory for build files
      continuous = 1, -- Enable continuous compilation
      options = {
        "-pdf", -- Generate PDF output
        "-shell-escape", -- Allow shell escape for certain packages
        "-verbose",
        "-file-line-error",
        "-synctex=1",
        "-interaction=nonstopmode",
      },
    }

    -- PDF viewer configuration (Zathura for Linux)
    vim.g.vimtex_view_method = "zathura" -- PDF viewer
    vim.g.vimtex_view_zathura_options = "-x 'nvim --headless -c \"VimtexInverseSearch %{line} %{input}\"'"

    -- Quickfix settings
    vim.g.vimtex_quickfix_mode = 0 -- Don't open quickfix automatically
    vim.g.vimtex_quickfix_open_on_warning = 0

    -- Folding configuration
    vim.g.vimtex_fold_enabled = 1 -- Enable folding
    vim.g.vimtex_fold_types = {
      envs = { enabled = 1 },
      sections = { enabled = 1 },
    }

    -- Concealment for better readability
    vim.g.vimtex_syntax_conceal = {
      accents = 1,
      ligatures = 1,
      cites = 1,
      fancy = 1,
      spacing = 0,
      greek = 1,
      math_bounds = 0,
      math_delimiters = 1,
      math_fracs = 1,
      math_super_sub = 1,
      math_symbols = 1,
      sections = 0,
      styles = 1,
    }
    vim.opt.conceallevel = 2 -- Enable concealment

    -- Table of contents configuration
    vim.g.vimtex_toc_config = {
      name = "TOC",
      layers = { "content", "todo", "include" },
      split_width = 30,
      todo_sorted = 0,
      show_help = 1,
      show_numbers = 1,
    }

    -- Disable default mappings (use custom ones from keymaps.lua)
    vim.g.vimtex_mappings_enabled = 0

    -- Compiler callback for continuous compilation
    vim.g.vimtex_compiler_callback_hooks = { "VimtexUpdateToc" }

    -- Forward search (SyncTeX)
    vim.g.vimtex_view_forward_search_on_start = 0

    -- Grammar checking integration (ltex-ls)
    vim.g.vimtex_grammar_vlty = { lt_directory = "", lt_command = "languagetool" }

    -- Notifications
    vim.notify("📝 VimTeX loaded - LaTeX compilation ready", vim.log.levels.INFO)
  end,
}
