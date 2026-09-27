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
if [[ ! -r "$root/dot_config/zsh/conf.d/06-keybindings.zsh" ]]; then
  fail "conf.d/06-keybindings.zsh is missing"
elif ! grep -qs 'up-line-or-beginning-search' "$root/dot_config/zsh/conf.d/06-keybindings.zsh"; then
  fail "conf.d/06-keybindings.zsh does not configure prefix history search"
fi

# 2. Runtime: apply the real configuration into a throwaway HOME and assert the
#    promised behaviours in the resulting interactive shell.
if ! command -v chezmoi >/dev/null 2>&1; then
  echo "check-conveniences: chezmoi not found; static checks only"
elif [[ ! -r "${XDG_CACHE_HOME:-$HOME/.cache}/antidote/github.com/ohmyzsh/ohmyzsh/lib/directories.zsh" ]]; then
  echo "check-conveniences: antidote cache not found; static checks only"
else
  sb="$(mktemp -d "${RUNNER_TEMP:-${TMPDIR:-/tmp}}/zsh-conv.XXXXXX")"
  # Cleanup must never fail the job (git's automatic maintenance can still be
  # writing into antidote's clones; see test-install.sh). Retry a few times.
  trap 'for i in 1 2 3 4 5; do rm -rf -- "$sb" 2>/dev/null && break; sleep 1; done' EXIT
  # Stop git from starting detached automatic maintenance in the sandbox.
  export GIT_CONFIG_COUNT=3
  export GIT_CONFIG_KEY_0=maintenance.auto       GIT_CONFIG_VALUE_0=false
  export GIT_CONFIG_KEY_1=maintenance.autoDetach GIT_CONFIG_VALUE_1=false
  export GIT_CONFIG_KEY_2=gc.auto                GIT_CONFIG_VALUE_2=0
  export HOME="$sb"
  export XDG_CONFIG_HOME="$sb/.config" XDG_DATA_HOME="$sb/.local/share" XDG_CACHE_HOME="$sb/.cache"
  mkdir -p "$XDG_CONFIG_HOME/chezmoi"
  printf 'sourceDir = "%s"\n' "$root" > "$XDG_CONFIG_HOME/chezmoi/chezmoi.toml"

  if ! chezmoi apply >/dev/null 2>&1; then
    fail "chezmoi apply failed in the sandbox"
  else
    out="$(
      TERM=xterm zsh -i -c '
        for a in l ll la lsa; do
          [[ -n ${aliases[$a]} ]] || print -r -- "missing alias: $a"
        done
        [[ $options[AUTO_CD] == on ]]           || print -r -- "AUTO_CD is not on"
        [[ $options[HIST_IGNORE_SPACE] == on ]] || print -r -- "HIST_IGNORE_SPACE is not on"
        [[ -n $HISTFILE ]]                      || print -r -- "HISTFILE is empty"
        [[ $options[HIST_FIND_NO_DUPS] == on ]] || print -r -- "HIST_FIND_NO_DUPS is not on"
        [[ $(bindkey -M emacs "^[[A") == *up-line-or-beginning-search* ]]   || print -r -- "emacs Up is not prefix history search"
        [[ $(bindkey -M emacs "^[OA") == *up-line-or-beginning-search* ]]   || print -r -- "emacs Up (application mode) is not prefix history search"
        [[ $(bindkey -M emacs "^[[B") == *down-line-or-beginning-search* ]] || print -r -- "emacs Down is not prefix history search"
        [[ $(bindkey -M emacs "^[OB") == *down-line-or-beginning-search* ]] || print -r -- "emacs Down (application mode) is not prefix history search"
        [[ $(bindkey -M viins "^[[A") == *up-line-or-beginning-search* ]]   || print -r -- "viins Up is not prefix history search"
        [[ $(bindkey -M viins "^[OA") == *up-line-or-beginning-search* ]]   || print -r -- "viins Up (application mode) is not prefix history search"
        [[ $(bindkey -M viins "^[[B") == *down-line-or-beginning-search* ]] || print -r -- "viins Down is not prefix history search"
        [[ $(bindkey -M viins "^[OB") == *down-line-or-beginning-search* ]] || print -r -- "viins Down (application mode) is not prefix history search"

        # Terminal navigation keys resolve to their widgets in every keymap.
        nav_check() {
          local km=$1 key=$2 want=$3 got
          got=$(bindkey -M $km "$key"); got=${got##* }
          [[ $got == $want ]] || print -r -- "navigation: $km $key -> $got (want $want)"
        }
        nav_check emacs "^[[3~" delete-char
        nav_check viins "^[[3~" delete-char
        nav_check vicmd "^[[3~" vi-delete-char
        for km in emacs viins vicmd; do
          nav_check $km "^[[H"  beginning-of-line
          nav_check $km "^[[F"  end-of-line
          nav_check $km "^[[5~" up-line
          nav_check $km "^[[6~" down-line
        done
        for km in emacs viins; do
          nav_check $km "^[[2~" overwrite-mode
        done
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
