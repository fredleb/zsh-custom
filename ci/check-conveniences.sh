#!/usr/bin/env bash
# Fail if the shell conveniences the configuration promises are missing.
#
# The conveniences come from upstream oh-my-zsh library files loaded through
# antidote. A regression here is silent (the shell still starts), so it is
# asserted explicitly against a real install: listing aliases, and the options
# that the loader's `emulate -L zsh` scope used to discard.
#
# Requires chezmoi and a populated antidote cache (or network). When either is
# unavailable the runtime part is skipped and only the static checks run.
#
# Usage: check-conveniences.sh [repo-root]
set -euo pipefail

root="${1:-$(cd -- "$(dirname -- "$0")/.." && pwd)}"

status=0
fail() { echo "check-conveniences: $*" >&2; status=1; }

# 1. Static: the conveniences must be declared in a plugin list.
if ! grep -rqs 'lib/directories\.zsh' "$root"/dot_config/zsh/plugins*.txt; then
  fail "lib/directories.zsh is not declared in any plugin list"
fi
if ! grep -rqs 'lib/history\.zsh' "$root"/dot_config/zsh/plugins*.txt; then
  fail "lib/history.zsh is not declared in any plugin list"
fi

# 2. Runtime: apply the real configuration into a throwaway HOME and assert the
#    promised behaviours in the resulting interactive shell.
if ! command -v chezmoi >/dev/null 2>&1; then
  echo "check-conveniences: chezmoi not found; static checks only"
elif [[ ! -r "${XDG_CACHE_HOME:-$HOME/.cache}/antidote/github.com/ohmyzsh/ohmyzsh/lib/directories.zsh" ]]; then
  echo "check-conveniences: antidote cache not found; static checks only"
else
  sb="$(mktemp -d "${RUNNER_TEMP:-${TMPDIR:-/tmp}}/zsh-conv.XXXXXX")"
  trap 'rm -rf -- "$sb"' EXIT
  export HOME="$sb"
  export XDG_CONFIG_HOME="$sb/.config" XDG_DATA_HOME="$sb/.local/share" XDG_CACHE_HOME="$sb/.cache"
  mkdir -p "$XDG_CONFIG_HOME/chezmoi"
  printf 'sourceDir = "%s"\n' "$root" > "$XDG_CONFIG_HOME/chezmoi/chezmoi.toml"

  if ! chezmoi apply >/dev/null 2>&1; then
    fail "chezmoi apply failed in the sandbox"
  else
    out="$(
      zsh -i -c '
        for a in l ll la lsa; do
          [[ -n ${aliases[$a]} ]] || print -r -- "missing alias: $a"
        done
        [[ $options[AUTO_CD] == on ]]           || print -r -- "AUTO_CD is not on"
        [[ $options[HIST_IGNORE_SPACE] == on ]] || print -r -- "HIST_IGNORE_SPACE is not on"
        [[ -n $HISTFILE ]]                      || print -r -- "HISTFILE is empty"
      ' 2>/dev/null
    )"
    if [[ -n "$out" ]]; then
      while IFS= read -r line; do fail "$line"; done <<<"$out"
    fi

    # A plugin that fails to resolve is reported on stderr at shell start.
    warn="$(zsh -i -c exit 2>&1 | grep -E 'plugin unavailable|antidote not found' || true)"
    if [[ -n "$warn" ]]; then
      while IFS= read -r line; do fail "$line"; done <<<"$warn"
    fi
  fi
fi

if (( status == 0 )); then
  echo "check-conveniences: ok"
fi
exit "$status"
