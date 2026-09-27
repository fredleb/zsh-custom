#!/usr/bin/env bash
# Fail if files contain likely secret VALUES (not just names like GITEA_TOKEN).
set -euo pipefail

root="${1:-$(cd -- "$(dirname -- "$0")/.." && pwd)}"

# High-signal value patterns. Deliberately avoids generic 40-char hex (too many
# false positives from git hashes in docs).
patterns=(
  'ghp_[A-Za-z0-9]{36}'
  'github_pat_[A-Za-z0-9_]{20,}'
  'AKIA[0-9A-Z]{16}'
  'xox[baprs]-[A-Za-z0-9-]{10,}'
  '-----BEGIN [A-Z ]*PRIVATE KEY-----'
  'sk-[A-Za-z0-9]{20,}'
  '(TOKEN|SECRET|PASSWORD|PASSWD|API_?KEY)[[:space:]]*=[[:space:]]*['"'"'"]?[A-Za-z0-9_/+-]{16,}'
)

status=0
while IFS= read -r f; do
  [[ -z $f ]] && continue
  # Skip binary files.
  grep -Iq . "$f" 2>/dev/null || continue
  for p in "${patterns[@]}"; do
    if grep -nEI "$p" "$f" 2>/dev/null; then
      echo "check-secrets: possible secret in $f" >&2
      status=1
    fi
  done
done < <(find "$root" -type f \
  -not -path '*/.git/*' -not -path '*/ci/check-secrets.sh' -print | sort)

if (( status == 0 )); then
  echo "check-secrets: ok"
fi
exit "$status"
