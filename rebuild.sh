#!/usr/bin/env bash
# Apply the current state of this repo to the machine.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ln -sfn "$DIR" ~/.dotfiles
exec sudo darwin-rebuild switch --flake ~/.dotfiles#mac
