# OVIWrite Project Overview

## Purpose

OVIWrite is a Neovim-based Integrated Writing Environment (IWE) designed specifically for **writers**, not programmers. It transforms Neovim into a full-featured writing tool supporting:

- **Long-form prose**: LaTeX for novels, academic writing, reports
- **Screenwriting**: Fountain format support
- **Note-taking**: Markdown, Org-mode
- **Personal knowledge management**: vim-wiki, Zettelkasten, Obsidian integration

> **Deep Dive**: See `iwe_telekasten_integration_patterns` for IWE LSP + Zettelkasten architecture details

## Core Philosophy

- **Plain text over rich text**: Avoid vendor lock-in, ensure longevity
- **Modal editing efficiency**: Vim motions for speed-of-thought writing
- **Extensibility**: Writer-focused workflows and customization
- **Cross-platform**: Works on Linux, macOS, Android (Termux), limited Windows/iPad

> **Implementation Patterns**: See `percy_development_patterns` for codebase-specific development practices and `configuration_patterns` for system design principles

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

> **Critical Pattern**: See `percybrain_lazy_nvim_pattern` for explicit import system that prevents blank screen issues

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

**Tested Platforms**: ✅ Linux (Debian/Ubuntu), macOS (>10.0), Android (Termux) ❌ Limited: Windows, iPad

______________________________________________________________________

## Architecture References

For detailed implementation patterns and design decisions, consult these specialized memories:

### Core System Architecture

- **`codebase_structure`**: Complete directory structure, file organization, and module dependencies
- **`architecture`**: High-level system design principles and architectural patterns
- **`percybrain_lazy_nvim_pattern`**: Critical plugin loading mechanism (prevents blank screen on startup)
- **`configuration_patterns`**: System-wide configuration patterns and organization strategies

### Key Workflows & Features

- **`gtd_implementation_reference`**: GTD (Getting Things Done) task management architecture and AI integration
- **`gtd_system_architecture_2025-10-21`**: Latest GTD Phase 3 implementation with AI-powered task decomposition
- **`iwe_telekasten_integration_patterns`**: IWE LSP integration with Zettelkasten workflows (core writing system)
- **`workflow_integration_patterns`**: Cross-workflow patterns and integration strategies

### User Interface & Interaction

- **`keymap_architecture_patterns`**: Complete keymap organization, leader key structure, and binding conventions
- **`ui_design_patterns`**: UI/UX design principles, theming, and visual consistency patterns
- **`percybrain_quick_reference`**: Essential keyboard shortcuts and common operations

### Development & Quality

- **`percy_development_patterns`**: Development workflows, coding standards, and contribution guidelines
- **`testing_best_practices`**: Test architecture, Kent Beck's testing philosophy, and quality gates
- **`quality_automation_patterns`**: Automated quality enforcement (pre-commit hooks, linting, formatting)
- **`llm_testing_framework`**: AI/LLM testing strategies and validation approaches

### Documentation & User Resources

- **`percybrain_documentation`**: Documentation organization following Diataxis framework
- **`PERCYBRAIN_USER_GUIDE`**: Comprehensive user-facing documentation
- **`documentation_strategy`**: Documentation authoring and maintenance strategies
- **`style_and_conventions`**: Code style, naming conventions, and formatting standards

### Specialized Systems

- **`semver_automation_implementation`**: Semantic versioning automation and release workflows
- **`percy_as_cognitive_compiler`**: Philosophical foundation - distributed cognition design principles
- **`percybrain_workspace`**: Workspace configuration and environment setup
- **`suggested_commands`**: CLI commands and common development tasks

### Session Archives

- **`percybrain_system_analysis_2025-10-18`**: Major system analysis session outcomes
- **`critical_implementation_session_2025-10-17`**: Critical implementation decisions and rationale
- **`test_suite_simplification_2025-10-17`**: Test suite refactoring and simplification patterns

______________________________________________________________________

## Quick Navigation

- **First-time setup**: Read `PERCYBRAIN_USER_GUIDE` → `percybrain_quick_reference`
- **Development work**: Read `percy_development_patterns` → `testing_best_practices`
- **Architecture understanding**: Read `architecture` → `codebase_structure` → specific workflow memories
- **GTD implementation**: Read `gtd_implementation_reference` → `gtd_system_architecture_2025-10-21`
- **Keymap customization**: Read `keymap_architecture_patterns` → `ui_design_patterns`
- **Quality standards**: Read `quality_automation_patterns` → `style_and_conventions`
