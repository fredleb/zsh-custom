#!/usr/bin/env bash
# Fail if a privilege-escalation command is INVOKED in repo scripts.
# Occurrences inside strings/comments (e.g. printed install instructions) are
# allowed; only command-position usage is flagged.
set -euo pipefail

root="${1:-$(cd -- "$(dirname -- "$0")/.." && pwd)}"

pattern='(^|[;&|()`]|&&|\|\|)[[:space:]]*(sudo|doas)([[:space:]]|$)'
su_pattern='(^|[;&|()`]|&&|\|\|)[[:space:]]*su[[:space:]]'

status=0
while IFS= read -r f; do
  [[ -z $f ]] && continue
  if grep -nE "$pattern" "$f" >/dev/null 2>&1 || grep -nE "$su_pattern" "$f" >/dev/null 2>&1; then
    echo "check-no-privilege: privilege escalation found in $f" >&2
    grep -nE "$pattern" "$f" >&2 || true
    grep -nE "$su_pattern" "$f" >&2 || true
    status=1
  fi
done < <(find "$root" -type f \
  \( -name '*.sh' -o -name '*.zsh' -o -name 'zsh-custom' -o -name 'zshrc' \) \
  -not -path '*/.git/*' -not -path '*/.github/*' \
  -not -path '*/ci/check-no-privilege.sh' -print | sort)

if (( status == 0 )); then
  echo "check-no-privilege: ok"
fi
exit "$status"
