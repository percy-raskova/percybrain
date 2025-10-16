
==============================================================================
lazy:                                                                       ✅

lazy.nvim ~
- {lazy.nvim} version `11.17.1`
- ✅ OK {git} `version 2.51.0`
- ✅ OK no existing packages found by other package managers
- ✅ OK packer_compiled.lua not found

luarocks ~
- checking `luarocks` installation
- you have some plugins that require `luarocks`:
    * `image.nvim`
- ✅ OK {luarocks} `/usr/bin/luarocks 3.8.0`
- ✅ OK {lua5.1} `Lua 5.1.5  Copyright (C) 1994-2012 Lua.org, PUC-Rio`

==============================================================================
noice:                                                                      ✅

noice.nvim ~
- ✅ OK *Neovim* >= 0.9.0
- ✅ OK You're using a GUI that should work ok
- ✅ OK *vim.go.lazyredraw* is not enabled
- ✅ OK `nvim-notify` is installed
- ✅ OK {TreeSitter} `vim` parser is installed
- ✅ OK {TreeSitter} `regex` parser is installed
- ✅ OK {TreeSitter} `lua` parser is installed
- ✅ OK {TreeSitter} `bash` parser is installed
- ✅ OK {TreeSitter} `markdown` parser is installed
- ✅ OK {TreeSitter} `markdown_inline` parser is installed
- ✅ OK `vim.notify` is set to **Noice**
- ✅ OK `vim.lsp.buf.hover` is set to **Noice**
- ✅ OK `vim.lsp.buf.signature_help` is set to **Noice**
- ✅ OK `vim.lsp.util.convert_input_to_markdown_lines` is set to **Noice**
- ✅ OK `vim.lsp.util.stylize_markdown` is set to **Noice**

==============================================================================
nvim-treesitter:                                                    1 ⚠️  1 ❌

Installation ~
- ⚠️ WARNING `tree-sitter` executable not found (parser generator, only needed for :TSInstallFromGrammar, not required for :TSInstall)
- ✅ OK `node` found v22.17.1 (only needed for :TSInstallFromGrammar)
- ✅ OK `git` executable found.
- ✅ OK `cc` executable found. Selected from { vim.NIL, "cc", "gcc", "clang", "cl", "zig" }
  Version: cc (Debian 12.2.0-14+deb12u1) 12.2.0
- ✅ OK Neovim was compiled with tree-sitter runtime ABI version 15 (required >=13). Parsers must be compatible with runtime ABI.

OS Info:
{
  machine = "x86_64",
  release = "6.1.0-40-amd64",
  sysname = "Linux",
  version = "#1 SMP PREEMPT_DYNAMIC Debian 6.1.153-1 (2025-09-20)"
} ~

Parser/Features         H L F I J
  - bash                ✓ ✓ ✓ . ✓
  - c                   ✓ ✓ ✓ ✓ ✓
  - cmake               ✓ . ✓ ✓ ✓
  - diff                ✓ . ✓ . ✓
  - dockerfile          ✓ . . . ✓
  - dtd                 ✓ ✓ ✓ . ✓
  - fish                ✓ ✓ ✓ ✓ ✓
  - git_config          ✓ . ✓ . ✓
  - git_rebase          ✓ . . . ✓
  - gitattributes       ✓ ✓ . . ✓
  - gitcommit           ✓ . . . ✓
  - gitignore           ✓ . . . ✓
  - hcl                 ✓ . ✓ ✓ ✓
  - html                ✓ ✓ ✓ ✓ ✓
  - javascript          ✓ ✓ ✓ ✓ ✓
  - jsdoc               ✓ . . . .
  - json                ✓ ✓ ✓ ✓ .
  - json5               ✓ . . . ✓
  - jsonc               ✓ ✓ ✓ ✓ ✓
  - kotlin              ✓ ✓ ✓ . ✓
  - lua                 ✓ ✓ ✓ ✓ ✓
  - luadoc              ✓ . . . .
  - luap                ✓ . . . .
  - markdown            ✓ . ✓ ✓ ✓
  - markdown_inline     ✓ . . . ✓
  - ninja               ✓ . ✓ ✓ ✓
  - printf              ✓ . . . .
  - python              x ✓ ✓ ✓ ✓
  - query               ✓ ✓ ✓ ✓ ✓
  - regex               ✓ . . . .
  - rst                 ✓ ✓ . . ✓
  - sql                 ✓ . ✓ ✓ ✓
  - terraform           ✓ . ✓ ✓ ✓
  - toml                ✓ ✓ ✓ ✓ ✓
  - tsx                 ✓ ✓ ✓ ✓ ✓
  - typescript          ✓ ✓ ✓ ✓ ✓
  - vim                 ✓ ✓ ✓ . ✓
  - vimdoc              ✓ . . . ✓
  - xml                 ✓ ✓ ✓ ✓ ✓
  - yaml                ✓ ✓ ✓ ✓ ✓

  Legend: H[ighlight], L[ocals], F[olds], I[ndents], In[j]ections
         +) multiple parsers found, only one will be used
         x) errors found in the query, try to run :TSUpdate {lang} ~

The following errors have been detected: ~
- ❌ ERROR python(highlights): ...m/0.11.4/share/nvim/runtime/lua/vim/treesitter/query.lua:373: Query error at 226:4. Invalid node type "except*":
    "except*"
     ^

  python(highlights) is concatenated from the following files:
  | [ERROR]:"/home/percy/.local/share/nvim/lazy/nvim-treesitter/queries/python/highlights.scm", failed to load: ...m/0.11.4/share/nvim/runtime/lua/vim/treesitter/query.lua:373: Query error at 226:4. Invalid node type "except*":
    "except*"
     ^


==============================================================================
orgmode:                                                            3 ⚠️  1 ❌

Orgmode ~
- ❌ ERROR Treesitter grammar is not installed. Run `:Org install_treesitter_grammar` to install it.
- ⚠️ WARNING Setup not called
- ⚠️ WARNING No agenda files configured. Set `org_agenda_files` in your config.
- ⚠️ WARNING No default notes file configured. Set `org_default_notes_file` in your config.

==============================================================================
telescope:                                                                  ✅

Checking for required plugins ~
- ✅ OK plenary installed.
- ✅ OK nvim-treesitter installed.

Checking external dependencies ~
- ✅ OK rg: found ripgrep 14.1.1 (rev 4649aa9700)
- ✅ OK fd: found fdfind 8.6.0

===== Installed extensions ===== ~

Telescope Extension: `notify` ~
- No healthcheck provided

==============================================================================
vim.deprecated:                                                           2 ⚠️

 ~
- ⚠️ WARNING vim.str_utfindex is deprecated. Feature will be removed in Nvim 1.0
  - ADVICE:
    - use vim.str_utfindex(s, encoding, index, strict_indexing) instead.
    - stack traceback:
        /home/percy/.local/share/nvim/lazy/noice.nvim/lua/noice/view/backend/notify.lua:112
        [C]:-1
        /home/percy/.local/share/nvim/lazy/noice.nvim/lua/noice/util/call.lua:149
        /home/percy/.local/share/nvim/lazy/nvim-notify/lua/notify/service/buffer/init.lua:107
        [C]:-1
        /home/percy/.local/share/nvim/lazy/nvim-notify/lua/notify/service/init.lua:71
        /home/percy/.local/share/nvim/lazy/nvim-notify/lua/notify/instance.lua:130
        /home/percy/.local/share/nvim/lazy/noice.nvim/lua/noice/view/backend/notify.lua:168
        /home/percy/.local/share/nvim/lazy/noice.nvim/lua/noice/view/backend/notify.lua:198
        /home/percy/.local/share/nvim/lazy/noice.nvim/lua/noice/view/init.lua:163
        [C]:-1
        /home/percy/.local/share/nvim/lazy/noice.nvim/lua/noice/util/call.lua:149
        /home/percy/.local/share/nvim/lazy/noice.nvim/lua/noice/view/init.lua:170
        /home/percy/.local/share/nvim/lazy/noice.nvim/lua/noice/message/router.lua:214
        [C]:-1
        /home/percy/.local/share/nvim/lazy/noice.nvim/lua/noice/util/call.lua:149
        [C]:-1
        /home/percy/.local/share/nvim/lazy/noice.nvim/lua/noice/util/init.lua:146
        vim/_editor.lua:0
        vim/_editor.lua:0

 ~
- ⚠️ WARNING vim.validate is deprecated. Feature will be removed in Nvim 1.0
  - ADVICE:
    - use vim.validate(name, value, validator, optional_or_msg) instead.
    - stack traceback:
        /home/percy/.local/share/nvim/lazy/nvim-treesitter/lua/nvim-treesitter/install.lua:93
        [C]:-1
        /home/percy/.local/share/nvim/lazy/nvim-treesitter/lua/nvim-treesitter/install.lua:483
        /home/percy/.local/share/nvim/lazy/nvim-treesitter/lua/nvim-treesitter/install.lua:552
        /home/percy/.local/share/nvim/lazy/nvim-treesitter/lua/nvim-treesitter/install.lua:589
        lua:1

==============================================================================
vim.health:                                                                 ✅

Configuration ~
- ✅ OK no issues found

Runtime ~
- ✅ OK $VIMRUNTIME: /home/linuxbrew/.linuxbrew/Cellar/neovim/0.11.4/share/nvim/runtime

Performance ~
- ✅ OK Build type: Release

Remote Plugins ~
- ✅ OK Up to date

terminal ~
- key_backspace (kbs) terminfo entry: `key_backspace=\177`
- key_dc (kdch1) terminfo entry: `key_dc=\E[3~`
- $COLORTERM="truecolor"

External Tools ~
- ✅ OK ripgrep 14.1.1 (rev 4649aa9700) (/usr/bin/rg)

==============================================================================
vim.lsp:                                                                    ✅

- LSP log level : WARN
- Log path: /home/percy/.local/state/nvim/lsp.log
- Log size: 45 KB

vim.lsp: Active Clients ~
- No active clients

vim.lsp: Enabled Configurations ~

vim.lsp: File Watcher ~
- file watching "(workspace/didChangeWatchedFiles)" disabled on all clients

vim.lsp: Position Encodings ~
- No active clients

==============================================================================
vim.provider:                                                             4 ⚠️

Clipboard (optional) ~
- ✅ OK Clipboard tool found: xclip

Node.js provider (optional) ~
- Node.js: v22.17.1

- ⚠️ WARNING Missing "neovim" npm (or yarn, pnpm) package.
  - ADVICE:
    - Run in shell: npm install -g neovim
    - Run in shell (if you use yarn): yarn global add neovim
    - Run in shell (if you use pnpm): pnpm install -g neovim
    - You may disable this provider (and warning) by adding `let g:loaded_node_provider = 0` to your init.vim

Perl provider (optional) ~
- ⚠️ WARNING "Neovim::Ext" cpan module is not installed
  - ADVICE:
    - See :help |provider-perl| for more information.
    - You can disable this provider (and warning) by adding `let g:loaded_perl_provider = 0` to your init.vim
- ⚠️ WARNING No usable perl executable found

Python 3 provider (optional) ~
- `g:python3_host_prog` is not set. Searching for pynvim-python in the environment.
- Executable: /home/percy/.local/bin/pynvim-python
- Python version: 3.11.2
- pynvim version: 0.6.0
- ✅ OK Latest pynvim is installed.

Python virtualenv ~
- ✅ OK no $VIRTUAL_ENV

Ruby provider (optional) ~
- Ruby: ruby 3.1.2p20 (2022-04-12 revision 4491bb740a) [x86_64-linux-gnu]
- ⚠️ WARNING `neovim-ruby-host` not found.
  - ADVICE:
    - Run `gem install neovim` to ensure the neovim RubyGem is installed.
    - Run `gem environment` to ensure the gem bin directory is in $PATH.
    - If you are using rvm/rbenv/chruby, try "rehashing".
    - See :help |g:ruby_host_prog| for non-standard gem installations.
    - You can disable this provider (and warning) by adding `let g:loaded_ruby_provider = 0` to your init.vim

==============================================================================
vim.treesitter:                                                             ✅

Treesitter features ~
- Treesitter ABI support: min 13, max 15
- WASM parser support: false

Treesitter parsers ~
- ✅ OK Parser: bash                      ABI: 15, path: /home/percy/.local/share/nvim/site/parser/bash.so
- ✅ OK Parser: c                         ABI: 15, path: /home/percy/.local/share/nvim/site/parser/c.so
- ✅ OK Parser: c                    (not loaded), path: /home/linuxbrew/.linuxbrew/Cellar/neovim/0.11.4/lib/nvim/parser/c.so
- ✅ OK Parser: cmake                     ABI: 14, path: /home/percy/.local/share/nvim/site/parser/cmake.so
- ✅ OK Parser: diff                      ABI: 14, path: /home/percy/.local/share/nvim/site/parser/diff.so
- ✅ OK Parser: dockerfile                ABI: 14, path: /home/percy/.local/share/nvim/site/parser/dockerfile.so
- ✅ OK Parser: dtd                       ABI: 14, path: /home/percy/.local/share/nvim/site/parser/dtd.so
- ✅ OK Parser: fish                      ABI: 14, path: /home/percy/.local/share/nvim/site/parser/fish.so
- ✅ OK Parser: git_config                ABI: 14, path: /home/percy/.local/share/nvim/site/parser/git_config.so
- ✅ OK Parser: git_rebase                ABI: 14, path: /home/percy/.local/share/nvim/site/parser/git_rebase.so
- ✅ OK Parser: gitattributes             ABI: 14, path: /home/percy/.local/share/nvim/site/parser/gitattributes.so
- ✅ OK Parser: gitcommit                 ABI: 14, path: /home/percy/.local/share/nvim/site/parser/gitcommit.so
- ✅ OK Parser: gitignore                 ABI: 13, path: /home/percy/.local/share/nvim/site/parser/gitignore.so
- ✅ OK Parser: hcl                       ABI: 15, path: /home/percy/.local/share/nvim/site/parser/hcl.so
- ✅ OK Parser: html                      ABI: 14, path: /home/percy/.local/share/nvim/site/parser/html.so
- ✅ OK Parser: javascript                ABI: 15, path: /home/percy/.local/share/nvim/site/parser/javascript.so
- ✅ OK Parser: jsdoc                     ABI: 15, path: /home/percy/.local/share/nvim/site/parser/jsdoc.so
- ✅ OK Parser: json                      ABI: 14, path: /home/percy/.local/share/nvim/site/parser/json.so
- ✅ OK Parser: json5                     ABI: 15, path: /home/percy/.local/share/nvim/site/parser/json5.so
- ✅ OK Parser: jsonc                     ABI: 13, path: /home/percy/.local/share/nvim/site/parser/jsonc.so
- ✅ OK Parser: kotlin                    ABI: 14, path: /home/percy/.local/share/nvim/site/parser/kotlin.so
- ✅ OK Parser: lua                       ABI: 15, path: /home/percy/.local/share/nvim/site/parser/lua.so
- ✅ OK Parser: lua                  (not loaded), path: /home/linuxbrew/.linuxbrew/Cellar/neovim/0.11.4/lib/nvim/parser/lua.so
- ✅ OK Parser: luadoc                    ABI: 14, path: /home/percy/.local/share/nvim/site/parser/luadoc.so
- ✅ OK Parser: luap                      ABI: 14, path: /home/percy/.local/share/nvim/site/parser/luap.so
- ✅ OK Parser: markdown                  ABI: 15, path: /home/percy/.local/share/nvim/site/parser/markdown.so
- ✅ OK Parser: markdown             (not loaded), path: /home/linuxbrew/.linuxbrew/Cellar/neovim/0.11.4/lib/nvim/parser/markdown.so
- ✅ OK Parser: markdown_inline           ABI: 15, path: /home/percy/.local/share/nvim/site/parser/markdown_inline.so
- ✅ OK Parser: markdown_inline      (not loaded), path: /home/linuxbrew/.linuxbrew/Cellar/neovim/0.11.4/lib/nvim/parser/markdown_inline.so
- ✅ OK Parser: ninja                     ABI: 13, path: /home/percy/.local/share/nvim/site/parser/ninja.so
- ✅ OK Parser: printf                    ABI: 14, path: /home/percy/.local/share/nvim/site/parser/printf.so
- ✅ OK Parser: python                    ABI: 15, path: /home/percy/.local/share/nvim/site/parser/python.so
- ✅ OK Parser: python               (not loaded), path: /home/percy/.local/share/nvim/lazy/nvim-treesitter/parser/python.so
- ✅ OK Parser: query                     ABI: 15, path: /home/percy/.local/share/nvim/site/parser/query.so
- ✅ OK Parser: query                (not loaded), path: /home/linuxbrew/.linuxbrew/Cellar/neovim/0.11.4/lib/nvim/parser/query.so
- ✅ OK Parser: regex                     ABI: 15, path: /home/percy/.local/share/nvim/site/parser/regex.so
- ✅ OK Parser: rst                       ABI: 14, path: /home/percy/.local/share/nvim/site/parser/rst.so
- ✅ OK Parser: sql                       ABI: 14, path: /home/percy/.local/share/nvim/site/parser/sql.so
- ✅ OK Parser: terraform                 ABI: 15, path: /home/percy/.local/share/nvim/site/parser/terraform.so
- ✅ OK Parser: toml                      ABI: 14, path: /home/percy/.local/share/nvim/site/parser/toml.so
- ✅ OK Parser: tsx                       ABI: 14, path: /home/percy/.local/share/nvim/site/parser/tsx.so
- ✅ OK Parser: typescript                ABI: 14, path: /home/percy/.local/share/nvim/site/parser/typescript.so
- ✅ OK Parser: vim                       ABI: 15, path: /home/percy/.local/share/nvim/site/parser/vim.so
- ✅ OK Parser: vim                  (not loaded), path: /home/linuxbrew/.linuxbrew/Cellar/neovim/0.11.4/lib/nvim/parser/vim.so
- ✅ OK Parser: vimdoc                    ABI: 15, path: /home/percy/.local/share/nvim/site/parser/vimdoc.so
- ✅ OK Parser: vimdoc               (not loaded), path: /home/linuxbrew/.linuxbrew/Cellar/neovim/0.11.4/lib/nvim/parser/vimdoc.so
- ✅ OK Parser: xml                       ABI: 14, path: /home/percy/.local/share/nvim/site/parser/xml.so
- ✅ OK Parser: yaml                      ABI: 14, path: /home/percy/.local/share/nvim/site/parser/yaml.so

