#!/usr/bin/env bash
# Fail unless CHANGELOG.md's newest version is strictly greater than the base
# ref's newest version. This enforces the "every merge to main is a release"
# rule: the pull request that will be merged must carry the version bump and its
# changelog entry.
#
# Usage: check-version.sh [base-ref] [repo-root]
#   base-ref defaults to origin/main, then main, then HEAD~1.
set -euo pipefail

base="${1:-}"
root="${2:-$(cd -- "$(dirname -- "$0")/.." && pwd)}"

if [[ -z "$base" ]]; then
  for candidate in origin/main origin/master main master; do
    if git -C "$root" rev-parse --verify --quiet "$candidate" >/dev/null; then
      base="$candidate"
      break
    fi
  done
fi
[[ -n "$base" ]] || { echo "check-version: no base ref found" >&2; exit 1; }

# Newest `## [x.y.z]` heading, in file order (Keep a Changelog keeps the newest
# at the top).
version_of() {
  grep -m1 -E '^## \[[0-9]+\.[0-9]+\.[0-9]+\]' -- "$1" 2>/dev/null \
    | sed -E 's/^## \[([0-9]+\.[0-9]+\.[0-9]+)\].*/\1/'
}

head_file="$root/CHANGELOG.md"
[[ -r "$head_file" ]] || { echo "check-version: no CHANGELOG.md" >&2; exit 1; }
new="$(version_of "$head_file")"
if [[ -z "$new" ]]; then
  echo "check-version: no version heading in CHANGELOG.md (expected '## [x.y.z] - date')" >&2
  exit 1
fi

old="$(git -C "$root" show "$base:CHANGELOG.md" 2>/dev/null | grep -m1 -E '^## \[[0-9]+\.[0-9]+\.[0-9]+\]' \
  | sed -E 's/^## \[([0-9]+\.[0-9]+\.[0-9]+)\].*/\1/')"

if [[ -z "$old" ]]; then
  echo "check-version: base '$base' has no version heading; cannot compare" >&2
  exit 1
fi

if [[ "$new" == "$old" ]]; then
  echo "check-version: version $new is unchanged from $base; bump it for this merge" >&2
  exit 1
fi

# `sort -V` orders semver correctly for x.y.z.
if [[ "$(printf '%s\n%s\n' "$old" "$new" | sort -V | tail -1)" != "$new" ]]; then
  echo "check-version: version $new is lower than base $old" >&2
  exit 1
fi

echo "check-version: ok ($old -> $new)"
