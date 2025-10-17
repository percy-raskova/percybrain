# OVIWrite Project Overview

## Purpose
OVIWrite is a Neovim-based Integrated Writing Environment (IWE) designed specifically for **writers**, not programmers. It transforms Neovim into a full-featured writing tool supporting:
- **Long-form prose**: LaTeX for novels, academic writing, reports
- **Screenwriting**: Fountain format support
- **Note-taking**: Markdown, Org-mode
- **Personal knowledge management**: vim-wiki, Zettelkasten, Obsidian integration

## Core Philosophy
- **Plain text over rich text**: Avoid vendor lock-in, ensure longevity
- **Modal editing efficiency**: Vim motions for speed-of-thought writing
- **Extensibility**: Writer-focused workflows and customization
- **Cross-platform**: Works on Linux, macOS, Android (Termux), limited Windows/iPad

## Target Audience
Writers willing to learn Vim motions (2-week learning curve) for:
- Fast, distraction-free writing
- Powerful editing capabilities
- Version control integration (Git)
- Extensible, adaptable writing environment

## Tech Stack
- **Neovim >= 0.8.0** (with LuaJIT)
- **Lua**: Primary configuration language
- **lazy.nvim**: Plugin manager (folke/lazy.nvim)
- **Git**: Version control, integrated via LazyGit
- **LaTeX**: TexLive/MikTeX for document compilation
- **Pandoc**: Document conversion
- **Node.js**: For some LSP servers
- **ripgrep**: Fast file/text searching

## Project Status
⚠️ **Seeking new maintainers** - Original author moved to Emacs (Nov 2024)
- Active but not heavily maintained
- Community-driven development
- Stable for production use

## System Requirements
**Required**:
- Neovim >= 0.8.0 (LuaJIT)
- Git >= 2.19.0
- Nerd Font (for icons)

**Recommended**:
- LaTeX distribution (TexLive, MikTeX)
- Pandoc
- LanguageTool (grammar checking)
- Node.js
- ripgrep

**Tested Platforms**:
✅ Linux (Debian/Ubuntu), macOS (>10.0), Android (Termux)
❌ Limited: Windows, iPad
