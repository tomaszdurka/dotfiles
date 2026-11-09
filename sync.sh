#!/usr/bin/env bash
# Pull manually installed Homebrew packages back into this config.
#
# For every formula/cask that is installed but not declared in
# brew/brews.txt or brew/casks.txt (and not in brew/ignore.txt), ask
# whether to add it to the config or ignore it permanently.
# Nothing is ever uninstalled by this script.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
BREWS_FILE="$DIR/brew/brews.txt"
CASKS_FILE="$DIR/brew/casks.txt"
IGNORE_FILE="$DIR/brew/ignore.txt"

declared() { # print entries of a file: comments and blanks dropped, tap prefixes stripped
  sed -e 's/#.*//' -e 's/[[:space:]]*$//' -e '/^$/d' -e 's|.*/||' "$1"
}

is_listed() { # is_listed <name> <file>; tap prefixes are ignored on both sides
  declared "$2" | grep -qx "${1##*/}"
}

process() { # process <kind> <file> <installed list>
  local kind="$1" file="$2" installed="$3" pkg added=0
  while IFS= read -r pkg; do
    [ -z "$pkg" ] && continue
    if is_listed "$pkg" "$file" || is_listed "$pkg" "$IGNORE_FILE"; then
      continue
    fi
    printf '\nNew %s: %s\n' "$kind" "$pkg"
    read -r -p "  [a]dd to config / [i]gnore forever / [s]kip for now? " reply </dev/tty
    case "$reply" in
      a|A) echo "$pkg" >> "$file"; added=1; echo "  added to ${file##*/}" ;;
      i|I) echo "$pkg" >> "$IGNORE_FILE"; echo "  added to ignore.txt" ;;
      *)   echo "  skipped" ;;
    esac
  done <<< "$installed"
  return 0
}

echo "==> Checking formulae (brew leaves)..."
process "formula" "$BREWS_FILE" "$(brew leaves)"

echo
echo "==> Checking casks..."
process "cask" "$CASKS_FILE" "$(brew list --cask)"

# The reverse direction: declared but not installed. A rebuild fixes this.
echo
echo "==> Declared but not installed (next ./rebuild.sh installs these):"
missing=0
while IFS= read -r pkg; do
  if ! brew list --formula | grep -qx "$pkg"; then echo "  formula: $pkg"; missing=1; fi
done < <(declared "$BREWS_FILE")
while IFS= read -r pkg; do
  if ! brew list --cask | grep -qx "$pkg"; then echo "  cask: $pkg"; missing=1; fi
done < <(declared "$CASKS_FILE")
[ "$missing" -eq 0 ] && echo "  none - everything declared is installed"

echo
if ! git -C "$DIR" diff --quiet -- brew/; then
  echo "==> Changes to commit:"
  git -C "$DIR" diff -- brew/
  echo "==> Review, then: git add brew && git commit -m 'sync brew packages'"
else
  echo "==> Config unchanged."
fi
