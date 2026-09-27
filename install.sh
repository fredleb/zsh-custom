#!/usr/bin/env bash
# zsh-custom installer.
#
# Non-destructive: injects a version-invariant managed block into ~/.zshrc,
# seeds a user customization layer, and never overwrites user files.
# It does NOT install system packages and never invokes privilege escalation.
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
. "$REPO_DIR/lib/common.sh"
# shellcheck source=lib/migrate.sh
. "$REPO_DIR/lib/migrate.sh"

RC="${ZSHRC_CUSTOM_RC:-$HOME/.zshrc}"

usage() {
  cat <<EOF
Usage: install.sh [options]

Injects the zsh-custom managed block into ${RC} and seeds the user layer.

Options:
  -y, --yes     non-interactive (accepted for automation; installer never prompts)
  -h, --help    show this help
EOF
}

main() {
  while (($#)); do
    case "$1" in
      -y|--yes) ;;
      -h|--help) usage; return 0 ;;
      *) zshc_die "unknown option: $1 (try --help)" ;;
    esac
    shift
  done

  zshc_log "zsh-custom installer (framework $("$REPO_DIR/bin/zsh-custom" version 2>/dev/null || cat "$REPO_DIR/VERSION"))"
  zshc_log "  repo: ${REPO_DIR}"

  # 1. System prerequisites. Never installs anything, never escalates.
  if ! zshc_check_prereqs; then
    zshc_err "missing system prerequisites; nothing was changed."
    return 1
  fi

  # 2. Back up the existing rc BEFORE touching anything.
  local backup=""
  if [[ -f $RC ]]; then
    backup="$(mktemp -t zshrc-backup.XXXXXX)"
    cp -p "$RC" "$backup"
    zshc_log "  backed up ${RC} -> ${backup}"
    zshc_warn "old backups may contain secrets; review and remove any credentials from them"
  fi

  # 3. Migrate a legacy configuration (non-destructive).
  local mrc=0
  zshc_migrate_rc "$RC" || mrc=$?
  if (( mrc == 2 )); then
    zshc_err "migration refused; ${RC} was left unchanged."
    return 1
  fi
  if (( mrc != 0 )); then
    zshc_err "migration failed; ${RC} was left unchanged."
    return 1
  fi

  # 4. Seed the user customization layer (never overwrites existing files).
  zshc_log "  user layer: $(zshc_user_layer)"
  zshc_seed_user_layer "$REPO_DIR"

  # 5. Inject the stable managed block.
  if zshc_write_managed_block "$RC" "$REPO_DIR"; then
    zshc_log "  installed managed block in ${RC}"
  else
    zshc_log "  managed block already up to date in ${RC}"
  fi

  # 6. Validate before activation; roll back the rc if the framework is broken.
  if ! zshc_validate "$REPO_DIR"; then
    zshc_err "framework failed validation; restoring ${RC}"
    if [[ -n $backup ]]; then
      cp -p "$backup" "$RC"
    else
      rm -f "$RC"
    fi
    return 1
  fi

  # 7. Refresh the plugin cache (best effort).
  zshc_refresh_cache "$REPO_DIR" || zshc_warn "could not pre-build the plugin cache; it will build on first shell start"

  zshc_log ""
  zshc_log "Done. Restart your shell:  exec zsh"
  zshc_log "Diagnostics:               zsh-custom doctor"
  if [[ -n $backup ]]; then
    zshc_log "Backup of previous rc:     ${backup}"
  fi
}

main "$@"
