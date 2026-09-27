#!/usr/bin/env bash
# End-to-end: apply the checked-out config to a throwaway HOME and verify.
set -euo pipefail

here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
# Create the sandbox outside a world-writable parent: compaudit treats
# completion directories under such a parent as insecure, and compinit then
# prompts for input (which aborts in a headless shell).
tmpbase="${RUNNER_TEMP:-$(cd "$here/.." && pwd)}"
sb="$(mktemp -d "$tmpbase/zsh-custom-test.XXXXXX")"

# Cleanup must never fail the job. Git's automatic maintenance can still be
# writing into antidote's clones when the script ends; on macOS `rm -rf` then
# races with it and reports "Directory not empty". Retry a few times.
trap 'for i in 1 2 3 4 5; do rm -rf -- "$sb" 2>/dev/null && break; sleep 1; done' EXIT

# Stop git from starting detached automatic maintenance in the sandbox (the
# writer that races the cleanup above).
export GIT_CONFIG_COUNT=3
export GIT_CONFIG_KEY_0=maintenance.auto       GIT_CONFIG_VALUE_0=false
export GIT_CONFIG_KEY_1=maintenance.autoDetach GIT_CONFIG_VALUE_1=false
export GIT_CONFIG_KEY_2=gc.auto                GIT_CONFIG_VALUE_2=0

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
  [[ $XDG_CONFIG_HOME == "$HOME/.config" ]]   || { print -r -- "XDG_CONFIG_HOME was overridden: $XDG_CONFIG_HOME" >&2; exit 1; }
  [[ $ZSH_CONFIG == "$XDG_CONFIG_HOME/zsh" ]] || { print -r -- "ZSH_CONFIG is not derived from XDG_CONFIG_HOME: $ZSH_CONFIG" >&2; exit 1; }
'

# With none of the XDG base-directory variables set, the shell must not impose
# them, and must still resolve the managed configuration from the standard
# locations. (Setting them to defaults redirects tools whose data lives outside
# the XDG directories, e.g. Debian's nvm init and NVM_DIR.)
xdg_out="$(
  unset XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME
  zsh -i -c '
    for v in XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME; do
      [[ -z ${(P)v:-} ]] || print -r -- "imposed $v=${(P)v}"
    done
    [[ $ZSH_CONFIG == "$HOME/.config/zsh" ]] || print -r -- "ZSH_CONFIG=$ZSH_CONFIG"
    [[ $ZSH_CACHE == "$HOME/.cache/zsh" ]]   || print -r -- "ZSH_CACHE=$ZSH_CACHE"
    [[ -r $ZSH_CONFIG/conf.d/00-antidote.zsh ]] || print -r -- "managed conf.d not found under $ZSH_CONFIG"
  ' 2>/dev/null
)"
if [[ -n "$xdg_out" ]]; then
  printf '%s\n' "$xdg_out" >&2
  exit 1
fi

# Informational: doctor may report unrelated warnings (e.g. no age/gpg configured).
chezmoi doctor || true
