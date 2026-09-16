#!/usr/bin/env bash
# Takes a fresh Mac from nothing to this fully configured setup.
# Run once per machine; use ./rebuild.sh for every later change.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

echo "==> Step 1: Determinate Nix"
if command -v nix >/dev/null 2>&1; then
  echo "    nix already installed, skipping"
else
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    | sh -s -- install --no-confirm
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

echo "==> Step 2: symlink this repo to ~/.dotfiles"
# home.nix resolves its symlinks through ~/.dotfiles, so this must exist
# before the first switch.
ln -sfn "$DIR" ~/.dotfiles

echo "==> Step 3: first darwin-rebuild switch"
# darwin-rebuild doesn't exist yet on a fresh machine, so run it straight
# from the nix-darwin flake this one time.
NIX_BIN="$(command -v nix)"
sudo "$NIX_BIN" run github:nix-darwin/nix-darwin/nix-darwin-26.05#darwin-rebuild -- \
  switch --flake ~/.dotfiles#mac

echo "==> Done. Use ./rebuild.sh for future changes."
