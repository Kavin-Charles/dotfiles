# Obsidian Purple

Transparent black with purple accents. Space is the leader; pause after Space for the key menu.

On the starter screen, `j`/`l` select the next item, `k`/`h` select the previous item, and Enter opens it.

| Key | Action |
| --- | --- |
| `Space Space` / `Space ff` | Find files |
| `Space fg` / `Space fw` | Search project / word |
| `Space fb` / `Space fr` | Buffers / recent files |
| `-` / `Space e` | Browse parent directory / floating browser |
| `gd`, `gr`, `K` | Definition, references, documentation |
| `Space cr`, `Space ca`, `Space cf` | Rename, code action, format |
| `Space cd` / `[d`, `]d` | Diagnostics / previous, next diagnostic |
| `gcc` / visual `gc` | Comment line / selection |
| `Space gs`, `Space gp`, `Space gb` | Git status, hunk preview, blame |
| `[h`, `]h` / `Space gS` | Previous, next hunk / stage hunk |
| `Space ha`, `Space hh`, `Space 1–5` | Pin file, show pins, jump to pin |
| `sa`, `sd`, `sr` | Add, delete, replace surrounding characters |
| Visual `Space s` + quote/bracket | Surround selected text |
| `Ctrl s` / `Space w` | Save |
| `Shift h`, `Shift l` | Previous, next buffer |
| `Ctrl h/j/k/l` | Focus split |
| `Space ut` | Toggle transparency |
| `Space ul`, `Space um` | Plugins / Mason language tools |

In completion: Ctrl Space opens suggestions, Ctrl n/p or Tab selects, Enter accepts a selected entry, Ctrl e dismisses. Enter does not accept an unselected suggestion.

Surround uses mini.surround. Select text with `v`, then press `Space s "` for double quotes, `Space s '` for single quotes, or `Space s (` / `[` / `{` / `<` for brackets. Backticks work too. Opening and closing bracket keys both wrap without added spaces. The shorter visual `sa` shortcut also works. Without selecting text, `siw"` quotes the current word and `siw)` adds parentheses (`siw` is an alias for `saiw`, which also works). Use `sd"` to remove surrounding quotes or `sr"'` to change double quotes to single quotes.

File search prioritizes an exact filename or filename without its extension, then fuzzy filename matches, then matches found only in parent directories. For example, `server` ranks `server.go` above `server/handler.go`. Include `/` (such as `server/handler`) to search by path using normal FZF ranking. Fuzzy matching, smart case and extended FZF query syntax remain available.

In the Oil file browser: Enter opens a file; `-` goes up; `g?` shows help; Esc closes the browser. In insert mode, the first Esc returns to normal mode and the next closes the browser. Edit names and `:w` to rename/create; changes are reviewed before they are applied.

Installed language servers cover Bash, C/C++, CSS, Go, HTML, JSON, Lua, Python, Rust, TypeScript/JavaScript, Vim and YAML. They start only for matching filetypes. Lua, Python and TypeScript attachment and completion were tested. `:Mason` manages servers and formatters. Formatting is manual (`Space cf`), using an available formatter or LSP fallback. StyLua, Prettier, Ruff and shfmt are installed; gofmt and rustfmt were already available.

Configuration: `lua/config/` for editing options, keys, LSP and completion; `lua/plugins/` for tools; `colors/obsidian-purple.lua` for colors. The pinned `lazy-lock.json` records plugin versions. Plugin installation/update is explicit via `:Lazy`; normal startup does not download anything.

Tree-sitter uses the current main-branch API. Parsers for Lua, Python, JavaScript, TypeScript, TSX, Bash, C, C++, Go, Rust, JSON, YAML, HTML, CSS, Markdown, Vim and Vim help are installed. Run `:TSUpdate` after a plugin update.

Dependencies: git, ripgrep, make, a C compiler, wl-clipboard and Tree-sitter CLI. Tree-sitter CLI is installed in `~/.local/bin`; Neovim adds that path for GUI/terminal consistency.

File icons use letters, and key hints use readable names, so no Nerd Font is required. Editor tools follow the current [Neovim LSP API](https://neovim.io/doc/user/lsp/), [Tree-sitter main API](https://github.com/nvim-treesitter/nvim-treesitter), [Oil](https://github.com/stevearc/oil.nvim) and [Conform](https://github.com/stevearc/conform.nvim) documentation.

Backup before this setup: see `~/.local/state/desktop-fast/latest`.
