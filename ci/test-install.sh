#!/usr/bin/env bash
# End-to-end: apply the checked-out config to a throwaway HOME and verify.
set -euo pipefail

here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
# Create the sandbox outside a world-writable parent: compaudit treats
# completion directories under such a parent as insecure, and compinit then
# prompts for input (which aborts in a headless shell).
tmpbase="${RUNNER_TEMP:-$(cd "$here/.." && pwd)}"
sb="$(mktemp -d "$tmpbase/zsh-custom-test.XXXXXX")"
trap 'rm -rf -- "$sb"' EXIT
umask 022

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

# Plugins must actually resolve in a fresh sandbox. Without the cache-directory
# bootstrap every bundle write fails and all plugins are silently disabled,
# which the startup check above would not catch.
if grep -qE 'plugin unavailable|could not resolve all plugins' <<<"$out"; then
  echo "plugins failed to resolve in a fresh install" >&2
  exit 1
fi

# The promised shell conveniences are present.
zsh -i -c '
  for a in l ll la lsa; do [[ -n ${aliases[$a]} ]] || { print -r -- "missing alias: $a" >&2; exit 1; }; done
  [[ $options[AUTO_CD] == on ]]           || { print -r -- "AUTO_CD is not on" >&2; exit 1; }
  [[ $options[HIST_IGNORE_SPACE] == on ]] || { print -r -- "HIST_IGNORE_SPACE is not on" >&2; exit 1; }
  [[ -n $HISTFILE ]]                      || { print -r -- "HISTFILE is empty" >&2; exit 1; }
'

# Informational: doctor may report unrelated warnings (e.g. no age/gpg configured).
chezmoi doctor || true
