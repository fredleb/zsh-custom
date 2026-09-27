#!/usr/bin/env bash
# End-to-end: apply the checked-out config to a throwaway HOME and verify.
set -euo pipefail

here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
sb="$(mktemp -d)"
trap 'rm -rf -- "$sb"' EXIT

# Simulate an existing hand-edited rc so we can prove it is backed up.
printf '# my own line\nexport USER_LINE=1\n' > "${sb}/.zshrc"

export HOME="$sb"
# Isolate the whole XDG environment: some runners set XDG_CONFIG_HOME, which
# chezmoi prefers over $HOME for config-file discovery.
export XDG_CONFIG_HOME="${sb}/.config"
export XDG_DATA_HOME="${sb}/.local/share"
export XDG_CACHE_HOME="${sb}/.cache"
mkdir -p "${XDG_CONFIG_HOME}/chezmoi"
printf 'sourceDir = "%s"\n' "$here" > "${XDG_CONFIG_HOME}/chezmoi/chezmoi.toml"

chezmoi apply

test -f "${sb}/.zshrc"
test -f "${sb}/.zshenv"
test -f "${sb}/.config/zsh/conf.d/00-antidote.zsh"
test -f "${sb}/.config/starship.toml"

test -f "${sb}/.zshrc.pre-chezmoi"
grep -q 'USER_LINE=1' "${sb}/.zshrc.pre-chezmoi"

# Idempotent: a second apply reports no drift.
chezmoi apply
test -z "$(chezmoi status)"

# A headless interactive shell starts without framework errors.
out="$(zsh -i -c exit 2>&1 || true)"
printf '%s\n' "$out"
if grep -qE 'antidote not found|starship not found|command not found' <<<"$out"; then
  echo "shell startup reported errors" >&2
  exit 1
fi

# Informational: doctor may report unrelated warnings (e.g. no age/gpg configured).
chezmoi doctor || true
