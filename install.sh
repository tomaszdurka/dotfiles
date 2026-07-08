#!/usr/bin/env bash
#
# Symlinks the dotfiles in this repo into their expected locations, installs
# tpm, and prints post-install instructions. Idempotent — safe to re-run.
#
# Usage:  ./install.sh

set -euo pipefail

DOTFILES=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

link() {
    local src=$1
    local dest=$2

    mkdir -p "$(dirname "$dest")"

    if [[ -L $dest ]]; then
        ln -sfn "$src" "$dest"
        echo "  refreshed  $dest -> $src"
        return
    fi

    if [[ -e $dest ]]; then
        local backup="${dest}.backup.$(date +%Y%m%d%H%M%S)"
        mv "$dest" "$backup"
        echo "  backed up  $dest -> $backup"
    fi

    ln -sfn "$src" "$dest"
    echo "  linked     $dest -> $src"
}

echo "Installing dotfiles from $DOTFILES"

# tmux -----------------------------------------------------------------------
link "$DOTFILES/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"

# ghostty --------------------------------------------------------------------
link "$DOTFILES/ghostty/config" "$HOME/.config/ghostty/config"

# bin/ on PATH ---------------------------------------------------------------
link "$DOTFILES/bin/tmux-sessionizer" "$HOME/.local/bin/tmux-sessionizer"
chmod +x "$DOTFILES/bin/tmux-sessionizer"

# tpm (tmux plugin manager) --------------------------------------------------
if [[ ! -d $HOME/.tmux/plugins/tpm ]]; then
    echo "Cloning tpm..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
else
    echo "  tpm already installed"
fi

# Ensure ~/.local/bin is on PATH (zsh) ---------------------------------------
if ! echo "$PATH" | tr ':' '\n' | grep -qx "$HOME/.local/bin"; then
    cat <<'EOF'

  NOTE: ~/.local/bin isn't on your PATH. Add this to ~/.zshrc:

      export PATH="$HOME/.local/bin:$PATH"

EOF
fi

# Dependency check ------------------------------------------------------------
missing=()
for cmd in tmux fzf; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        missing+=("$cmd")
    fi
done
if (( ${#missing[@]} > 0 )); then
    cat <<EOF

  NOTE: missing dependencies: ${missing[*]}
        install with: brew install ${missing[*]}

EOF
fi

cat <<'EOF'

Done.

Next steps:
  1. Start tmux (or reload): tmux
  2. Install plugins:        Ctrl-a + I     (capital I, inside tmux)
  3. Try the session picker: Ctrl-a + f
EOF
