#!/bin/sh
# First chezmoi apply only: preserve any hand-edited shell config.
set -eu
for f in .zshrc .zshenv .zprofile .zlogin; do
  src="$HOME/$f"
  [ -f "$src" ] || continue
  dst="$HOME/$f.pre-chezmoi"
  [ -e "$dst" ] && continue
  cp -p "$src" "$dst"
  printf 'chezmoi: backed up %s -> %s\n' "$src" "$dst"
done
