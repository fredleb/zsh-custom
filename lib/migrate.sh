#!/usr/bin/env bash
# shellcheck shell=bash
# Non-destructive migration of a legacy antigen-based ~/.zshrc.
#
# zshc_migrate_rc <rc-file> <repo-dir>
#   return 0 : nothing to migrate, or migration succeeded
#   return 2 : ambiguous — caller must abort without modifying the rc
#   return 1 : error

zshc_detect_legacy() {
  grep -qE 'antigen' "${1:-}" 2>/dev/null
}

zshc_migrate_rc() {
  local rc=$1
  [[ -f $rc ]] || return 0
  zshc_detect_legacy "$rc" || return 0

  # Refuse to guess when the antigen heredoc is malformed.
  if grep -qE '<<[[:space:]]*EOBUNDLES' "$rc" && ! grep -qE '^EOBUNDLES[[:space:]]*$' "$rc"; then
    zshc_err "legacy antigen block in $rc is not terminated (missing EOBUNDLES)"
    zshc_log "  Refusing to migrate. Close the heredoc, or start from a clean ~/.zshrc, then re-run."
    return 2
  fi

  local layer kept content
  layer="$(zshc_user_layer)"
  kept="$(mktemp)"
  content="$(mktemp)"

  # Split: keep only comments/blank lines; everything else goes to `content`.
  awk -v kept="$kept" -v content="$content" '
    /<<[[:space:]]*EOBUNDLES/ {skip=1; next}
    skip && /^EOBUNDLES[[:space:]]*$/ {skip=0; next}
    skip {next}
    /source .*antigen\.zsh/ {next}
    /^[[:space:]]*antigen[[:space:]]/ {next}
    /^[[:space:]]*$/ {print > kept; next}
    /^[[:space:]]*#/ {print > kept; next}
    {print > content}
  ' "$rc"

  # Any leftover antigen reference means we could not classify it.
  if grep -qE '(^|[^[:alnum:]_])antigen([^[:alnum:]_]|$)' "$content"; then
    rm -f "$kept" "$content"
    zshc_err "could not classify a legacy antigen reference in $rc"
    zshc_log "  Refusing to migrate. Review $rc manually, then re-run."
    return 2
  fi

  mkdir -p "$layer/conf.d"
  local migrated="$layer/conf.d/00-migrated.zsh"
  local secrets="$layer/secrets.zsh"

  local user_count=0 secret_count=0 line
  {
    printf '# Migrated from ~/.zshrc by zsh-custom (%s)\n' "$(date '+%Y-%m-%d %H:%M:%S')"
  } >> "$migrated"
  {
    printf '# Migrated from ~/.zshrc by zsh-custom (%s)\n' "$(date '+%Y-%m-%d %H:%M:%S')"
  } >> "$secrets"

  while IFS= read -r line; do
    [[ -z ${line//[[:space:]]/} ]] && continue
    if [[ $line =~ (TOKEN|SECRET|PASSWORD|PASSWD|API_?KEY|PRIVATE_?KEY)= ]]; then
      printf '%s\n' "$line" >> "$secrets"
      (( secret_count++ ))
    else
      printf '%s\n' "$line" >> "$migrated"
      (( user_count++ ))
    fi
  done < "$content"

  chmod 600 "$secrets" 2>/dev/null
  mv "$kept" "$rc"
  rm -f "$content"

  zshc_log "Migration summary for $rc:"
  zshc_log "  ${user_count} line(s) -> $migrated"
  zshc_log "  ${secret_count} secret line(s) -> $secrets (mode 600)"
  if (( secret_count > 0 )); then
    zshc_warn "secrets were found in $rc; rotate any exposed tokens and review old backups"
  fi
  return 0
}
