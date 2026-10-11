# Ghostty — Obsidian Purple

Matches the desktop's near-black background and lavender accents, with 94%
opacity, JetBrains Mono Nerd Font Mono, padded output, compact tabs and a
steady bar cursor.

New terminals load Starship from `~/.bashrc`. The prompt has connected purple
segments for the folder, branch and changes. The command follows on the same
line. Username, hostname and the clean/up-to-date marker are hidden.

Starship is installed in `~/.local/bin/starship`; the font lives in
`~/.local/share/fonts/JetBrainsMonoNerd`. Configuration is tracked in
`~/.config/starship.toml`. Git's bundled script provides tab completion.
The arrow turns red and an exit code appears after a failed command. Commands
taking at least three seconds show their duration.

## Git prompt

The Git segment shows the branch and counts for changes:

| Marker | Meaning |
| --- | --- |
| `~2` | Two modified files |
| `+1` | One staged change |
| `?1` | One untracked file |
| `≡1` | One stash |
| `↑2` / `↓1` | Commits ahead of / behind the upstream branch |
| `−1` / `»1` | One deleted / renamed file |
| `!1` | One conflict |
| `MERGING`, `REBASING` | An operation needs attention |

Upstream information uses local refs; run `gf` to refresh them from the remote.

## Suggestions and search

ble.sh adds command highlighting, tab-completion menus and muted lavender
inline suggestions. Press Right at the end of the line to accept a suggestion.
Configuration is in `~/.blerc`; ble.sh is installed in `~/.local/share/blesh`.
The blerc includes Ghostty's upstream compatibility fix for duplicate prompts
on Ghostty 1.3.1. It skips versions whose integration already contains the fix.

fzf is installed in `~/.local/bin/fzf`, with its theme in
`~/.config/fzf/config.sh`. It uses ble.sh's integration to keep the prompt and
completion working together:

| Keys | Action |
| --- | --- |
| Ctrl+R | Search command history |
| Ctrl+T | Select files to insert their paths |
| Alt+C | Search folders and change directory |
| Esc | Close search without selecting |

Open a new terminal to load all the line-editor hooks.

## Git commands

| Shortcut | Command |
| --- | --- |
| `g` | `git` |
| `gs` | `git status --short --branch` |
| `gd` / `gds` | Working / staged diff |
| `gl` | Graph of all branches |
| `ga` / `gc` | Add / commit |
| `gsw` | Switch branch |
| `gf` | Fetch |
| `gpl` | Pull with fast-forward only |

Tab completion works with these shortcuts, including branch names for `gsw`.

## Terminal shortcuts

| Keys | Action |
| --- | --- |
| Ctrl+Shift+T | New tab in the current directory |
| Ctrl+Shift+D or Ctrl+Shift+O | Split right |
| Ctrl+Shift+E | Split down |
| Ctrl+Alt+Arrow | Move between splits |
| Ctrl+Shift+Enter | Zoom the current split |
| Ctrl+Shift+F | Search output |
| Ctrl+Shift+Page Up / Page Down | Previous / next prompt |
| Ctrl+Shift+P | Command palette |
| Ctrl+Shift+, | Reload configuration |

Open a new tab for padding and shell changes. In an existing Bash session,
`source ~/.bashrc` loads the updated prompt and Git shortcuts.
