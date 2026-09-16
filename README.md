# dotfiles

My Mac setup as code: nix-darwin + home-manager + Homebrew.
One command sets up a fresh machine; the same command applies every later change.

## Fresh machine

```sh
git clone git@github.com:tomaszdurka/dotfiles.git
cd dotfiles
./bootstrap.sh
```

## Daily use

Edit config, then apply:

```sh
./rebuild.sh
```

Files under `home/` are symlinked into place (via `~/.dotfiles`), so editing
them is editing the live config - no rebuild needed. A rebuild is only needed
when package lists or system settings change.

## Homebrew is additive here

Unlike the setup this repo was inspired by, `./rebuild.sh` never uninstalls
brew packages. Install things with `brew install` freely, then run:

```sh
./sync.sh
```

It finds everything installed but not declared and asks, per package, whether
to add it to the config (`brew/brews.txt` / `brew/casks.txt`) or ignore it
forever (`brew/ignore.txt`). Commit the result.

## What's in the box

- `configuration.nix` - macOS defaults (dark mode, fast key repeat, dock,
  Finder, trackpad; menu bar stays visible) and the Homebrew package lists
- `home.nix` - zsh (syntax highlighting, aliases, fzf Ctrl+R history),
  starship prompt, Hack Nerd Font, and all the symlinks
- `home/.config/tmux/tmux.conf` - the terminal workflow: named sessions that
  survive reboots (tmux-resurrect + tmux-continuum), `prefix+f` fuzzy session
  switcher, mouse selection copies to clipboard
- `home/.config/ghostty/config` - Ghostty opens straight into the shared
  `main` tmux session; the `t` shell function jumps to a per-project session
- `home/.config/nvim` - Neovim (lazy.nvim, rose-pine moon)
- `home/AGENTS.md` - one agent policy shared by Claude, Codex, and opencode

## tmux crash course

- `Ctrl+g` (no prefix, anywhere in tmux): THE switcher - one flat list of
  sessions showing busy/idle, tab count, and folder; `Ctrl+n` inside it
  starts a new session in a project folder you pick; `t` opens the same
  switcher from a plain shell
- `prefix` is `Ctrl+b`
- `prefix N` rename the current session; `prefix s` session tree with previews
- `prefix c` new window, `prefix n`/`p` switch windows
- `prefix "` / `prefix %` split panes, `prefix h/j/k/l` move between panes
- `prefix d` detach; close the terminal window whenever, nothing is lost
- After a reboot, open the terminal: continuum restores all sessions

## Validate without applying

```sh
nix flake check --no-build
darwin-rebuild build --flake .#mac
```
