# dotfiles

My personal terminal setup: tmux + Ghostty on macOS.

## What's here

```
tmux/tmux.conf            tmux config (Ctrl-a prefix, vim keys, sensible defaults)
ghostty/config            Ghostty terminal config
bin/tmux-sessionizer      fzf-based project/session picker
install.sh                Symlinks everything into place + installs tpm
```

## Install

```bash
git clone git@github.com:tomaszdurka/dotfiles.git ~/projects/dotfiles
cd ~/projects/dotfiles
./install.sh
```

Existing files are backed up with a timestamp; symlinks are refreshed in place.

Dependencies: `tmux`, `fzf`, `git`. Install with `brew install tmux fzf git`.

## First run

1. Start (or reload) tmux: `tmux`
2. Install plugins: press `Ctrl-a + I` (capital I) inside tmux — tpm will pull
   `tmux-sensible`, `tmux-resurrect`, `tmux-continuum`, `tmux-yank`.
3. Session picker: `Ctrl-a + f` opens fzf inside a tmux popup listing
   directories under `~/projects/` (edit `SEARCH_PATHS` in
   `bin/tmux-sessionizer` to add more). Selecting one creates (or switches
   to) a session named after that directory.

## Key bindings

| Key                | Action                                        |
|--------------------|-----------------------------------------------|
| `Ctrl-a`           | Prefix (replaces default `Ctrl-b`)            |
| `prefix + r`       | Reload `tmux.conf`                            |
| `prefix + \|`      | Split pane horizontally (in cwd)              |
| `prefix + -`       | Split pane vertically (in cwd)                |
| `prefix + h/j/k/l` | Move between panes (vim-style)                |
| `prefix + H/J/K/L` | Resize pane (repeatable)                      |
| `prefix + f`       | Session picker (fzf popup)                    |
| `prefix + s`       | List sessions (tmux default)                  |
| `prefix + w`       | List windows across sessions (tmux default)   |
| `v` / `y` (copy)   | Vim selection / yank to macOS clipboard       |

## Ghostty ↔ tmux

Ghostty passes truecolor and OSC 52 through natively. `tmux.conf` sets
`terminal-overrides` for both `xterm-256color` and `xterm-ghostty` so colors
render correctly, and `allow-passthrough on` lets nested apps use OSC
sequences (image protocols, clipboard).

## Uninstall

Symlinks live at:

- `~/.config/tmux/tmux.conf`
- `~/.config/ghostty/config`
- `~/.local/bin/tmux-sessionizer`

Remove them by hand; the `.backup.<timestamp>` files created on first install
hold whatever was there before.
