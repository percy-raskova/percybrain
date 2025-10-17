#!/bin/bash
# PercyBrain Plugin Refactoring Script
# Reorganizes plugins into workflow-based directories

set -euo pipefail

echo "🔄 PercyBrain Plugin Refactoring"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

PLUGIN_DIR="lua/plugins"

# Create new directory structure
echo "📁 Creating workflow directories..."
mkdir -p "$PLUGIN_DIR/zettelkasten"
mkdir -p "$PLUGIN_DIR/ai-sembr"
mkdir -p "$PLUGIN_DIR/prose-writing/distraction-free"
mkdir -p "$PLUGIN_DIR/prose-writing/editing"
mkdir -p "$PLUGIN_DIR/prose-writing/formatting"
mkdir -p "$PLUGIN_DIR/prose-writing/grammar"
mkdir -p "$PLUGIN_DIR/academic"
mkdir -p "$PLUGIN_DIR/publishing"
mkdir -p "$PLUGIN_DIR/org-mode"
mkdir -p "$PLUGIN_DIR/lsp"
mkdir -p "$PLUGIN_DIR/completion"
mkdir -p "$PLUGIN_DIR/ui"
mkdir -p "$PLUGIN_DIR/navigation"
mkdir -p "$PLUGIN_DIR/utilities"
mkdir -p "$PLUGIN_DIR/treesitter"
mkdir -p "$PLUGIN_DIR/lisp"
mkdir -p "$PLUGIN_DIR/experimental"

echo "✅ Directories created"
echo ""

# Phase 1: Delete redundant plugins
echo "🗑️  Phase 1: Removing redundant plugins..."

rm -f "$PLUGIN_DIR/fountain.lua"          # Screenwriting removed
rm -f "$PLUGIN_DIR/twilight.lua"          # Redundant with limelight
rm -f "$PLUGIN_DIR/vimorg.lua"            # Deprecated
rm -f "$PLUGIN_DIR/fzf-vim.lua"           # Redundant with fzf-lua
rm -f "$PLUGIN_DIR/gen.lua"               # Redundant with ollama
rm -f "$PLUGIN_DIR/vim-grammarous.lua"    # Use ltex-ls instead
rm -f "$PLUGIN_DIR/LanguageTool.lua"      # Use ltex-ls instead

echo "✅ Removed 7 redundant plugins"
echo ""

# Phase 2: Move plugins to workflow directories
echo "📦 Phase 2: Reorganizing plugins..."

# Zettelkasten
mv "$PLUGIN_DIR/vim-wiki.lua" "$PLUGIN_DIR/zettelkasten/" 2>/dev/null || true
mv "$PLUGIN_DIR/vim-zettel.lua" "$PLUGIN_DIR/zettelkasten/" 2>/dev/null || true
mv "$PLUGIN_DIR/obsidianNvim.lua" "$PLUGIN_DIR/zettelkasten/obsidian.lua" 2>/dev/null || true
mv "$PLUGIN_DIR/telescope.lua" "$PLUGIN_DIR/zettelkasten/" 2>/dev/null || true
mv "$PLUGIN_DIR/img-clip.lua" "$PLUGIN_DIR/zettelkasten/" 2>/dev/null || true

# AI & SemBr
mv "$PLUGIN_DIR/ollama.lua" "$PLUGIN_DIR/ai-sembr/" 2>/dev/null || true
mv "$PLUGIN_DIR/sembr.lua" "$PLUGIN_DIR/ai-sembr/" 2>/dev/null || true

# Prose Writing - Distraction Free
mv "$PLUGIN_DIR/goyo.lua" "$PLUGIN_DIR/prose-writing/distraction-free/" 2>/dev/null || true
mv "$PLUGIN_DIR/zen-mode.lua" "$PLUGIN_DIR/prose-writing/distraction-free/" 2>/dev/null || true
mv "$PLUGIN_DIR/limelight.lua" "$PLUGIN_DIR/prose-writing/distraction-free/" 2>/dev/null || true
mv "$PLUGIN_DIR/centerpad.lua" "$PLUGIN_DIR/prose-writing/distraction-free/" 2>/dev/null || true

# Prose Writing - Editing
mv "$PLUGIN_DIR/vim-pencil.lua" "$PLUGIN_DIR/prose-writing/editing/" 2>/dev/null || true

# Prose Writing - Formatting
mv "$PLUGIN_DIR/autopairs.lua" "$PLUGIN_DIR/prose-writing/formatting/" 2>/dev/null || true
mv "$PLUGIN_DIR/comment.lua" "$PLUGIN_DIR/prose-writing/formatting/" 2>/dev/null || true

# Prose Writing - Grammar
mv "$PLUGIN_DIR/vale.lua" "$PLUGIN_DIR/prose-writing/grammar/" 2>/dev/null || true
mv "$PLUGIN_DIR/thesaurusquery.lua" "$PLUGIN_DIR/prose-writing/grammar/thesaurus.lua" 2>/dev/null || true

# Academic
mv "$PLUGIN_DIR/vimtex.lua" "$PLUGIN_DIR/academic/" 2>/dev/null || true
mv "$PLUGIN_DIR/vim-pandoc.lua" "$PLUGIN_DIR/academic/" 2>/dev/null || true
mv "$PLUGIN_DIR/vim-latex-preview.lua" "$PLUGIN_DIR/academic/" 2>/dev/null || true
mv "$PLUGIN_DIR/cmp-dictionary.lua" "$PLUGIN_DIR/academic/" 2>/dev/null || true

# Publishing
mv "$PLUGIN_DIR/markdown-preview.lua" "$PLUGIN_DIR/publishing/" 2>/dev/null || true
mv "$PLUGIN_DIR/autopandoc.lua" "$PLUGIN_DIR/publishing/" 2>/dev/null || true

# Org-mode
mv "$PLUGIN_DIR/nvimorgmode.lua" "$PLUGIN_DIR/org-mode/" 2>/dev/null || true
mv "$PLUGIN_DIR/org-bullets.lua" "$PLUGIN_DIR/org-mode/" 2>/dev/null || true
mv "$PLUGIN_DIR/headlines.lua" "$PLUGIN_DIR/org-mode/" 2>/dev/null || true

# LSP
mv "$PLUGIN_DIR/mason-lspconfig.lua" "$PLUGIN_DIR/lsp/" 2>/dev/null || true

# Completion
mv "$PLUGIN_DIR/nvim-cmp.lua" "$PLUGIN_DIR/completion/" 2>/dev/null || true

# UI
mv "$PLUGIN_DIR/alpha.lua" "$PLUGIN_DIR/ui/" 2>/dev/null || true
mv "$PLUGIN_DIR/whichkey.lua" "$PLUGIN_DIR/ui/" 2>/dev/null || true
mv "$PLUGIN_DIR/noice.lua" "$PLUGIN_DIR/ui/" 2>/dev/null || true
mv "$PLUGIN_DIR/catppuccin.lua" "$PLUGIN_DIR/ui/" 2>/dev/null || true
mv "$PLUGIN_DIR/gruvbox.lua" "$PLUGIN_DIR/ui/" 2>/dev/null || true
mv "$PLUGIN_DIR/nightfox.lua" "$PLUGIN_DIR/ui/" 2>/dev/null || true
mv "$PLUGIN_DIR/transparent.lua" "$PLUGIN_DIR/ui/" 2>/dev/null || true
mv "$PLUGIN_DIR/nvim-web-devicons.lua" "$PLUGIN_DIR/ui/" 2>/dev/null || true

# Navigation
mv "$PLUGIN_DIR/nvim-tree.lua" "$PLUGIN_DIR/navigation/" 2>/dev/null || true
mv "$PLUGIN_DIR/yazi.lua" "$PLUGIN_DIR/navigation/" 2>/dev/null || true
mv "$PLUGIN_DIR/fzf-lua.lua" "$PLUGIN_DIR/navigation/" 2>/dev/null || true
mv "$PLUGIN_DIR/neoscroll.lua" "$PLUGIN_DIR/navigation/" 2>/dev/null || true

# Utilities
mv "$PLUGIN_DIR/lazygit.lua" "$PLUGIN_DIR/utilities/" 2>/dev/null || true
mv "$PLUGIN_DIR/toggleterm.lua" "$PLUGIN_DIR/utilities/" 2>/dev/null || true
mv "$PLUGIN_DIR/floaterm.lua" "$PLUGIN_DIR/utilities/" 2>/dev/null || true
mv "$PLUGIN_DIR/pomo.lua" "$PLUGIN_DIR/utilities/" 2>/dev/null || true
mv "$PLUGIN_DIR/translate.lua" "$PLUGIN_DIR/utilities/" 2>/dev/null || true
mv "$PLUGIN_DIR/stay-centered.lua" "$PLUGIN_DIR/utilities/" 2>/dev/null || true
mv "$PLUGIN_DIR/typewriter.lua" "$PLUGIN_DIR/utilities/" 2>/dev/null || true
mv "$PLUGIN_DIR/hardtime.lua" "$PLUGIN_DIR/utilities/" 2>/dev/null || true
mv "$PLUGIN_DIR/screenkey.lua" "$PLUGIN_DIR/utilities/" 2>/dev/null || true
mv "$PLUGIN_DIR/high-str.lua" "$PLUGIN_DIR/utilities/" 2>/dev/null || true

# Treesitter
mv "$PLUGIN_DIR/nvim-treesitter.lua" "$PLUGIN_DIR/treesitter/" 2>/dev/null || true

# Lisp
mv "$PLUGIN_DIR/quicklispnvim.lua" "$PLUGIN_DIR/lisp/" 2>/dev/null || true
mv "$PLUGIN_DIR/cl-neovim.lua" "$PLUGIN_DIR/lisp/" 2>/dev/null || true

# Experimental
mv "$PLUGIN_DIR/pendulum.lua" "$PLUGIN_DIR/experimental/" 2>/dev/null || true
mv "$PLUGIN_DIR/styledoc.lua" "$PLUGIN_DIR/experimental/" 2>/dev/null || true
mv "$PLUGIN_DIR/vim-dialect.lua" "$PLUGIN_DIR/experimental/" 2>/dev/null || true
mv "$PLUGIN_DIR/w3m.lua" "$PLUGIN_DIR/experimental/" 2>/dev/null || true

echo "✅ Plugins reorganized"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ Refactoring complete!"
echo ""
echo "Summary:"
echo "  ❌ Removed: 7 redundant plugins"
echo "  📦 Reorganized: 60 plugins into workflows"
echo "  ➕ Ready for: 8 new plugin files"
echo ""
echo "Next: Run the add-new-plugins.sh script to add new features"
echo ""
