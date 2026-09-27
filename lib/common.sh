#!/usr/bin/env bash
# shellcheck shell=bash
# Shared helpers for the zsh-custom installer and CLI. Source this file.

ZSHC_MARKER_BEGIN='# >>> zsh-custom (managed) >>>'
ZSHC_MARKER_END='# <<< zsh-custom (managed) <<<'

zshc_log()  { printf '%s\n' "$*"; }
zshc_warn() { printf 'zsh-custom: warning: %s\n' "$*" >&2; }
zshc_err()  { printf 'zsh-custom: error: %s\n' "$*" >&2; }
zshc_die()  { zshc_err "$*"; exit 1; }

zshc_user_layer() {
  printf '%s\n' "${ZSHRC_CUSTOM:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh-custom}"
}
zshc_cache_dir() {
  printf '%s\n' "${ZSHRC_CUSTOM_CACHE:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh-custom}"
}

# --- system dependency resolution -------------------------------------------

zshc_antidote_path() {
  if [[ -n ${ZSHRC_ANTIDOTE_PATH:-} && -r ${ZSHRC_ANTIDOTE_PATH:-} ]]; then
    printf '%s\n' "$ZSHRC_ANTIDOTE_PATH"; return 0
  fi
  local c
  for c in \
    /usr/share/zsh-antidote/antidote.zsh \
    /usr/local/share/zsh-antidote/antidote.zsh \
    /usr/share/zsh/plugins/antidote/antidote.zsh \
    /opt/homebrew/share/zsh-antidote/antidote.zsh \
    /usr/local/opt/zsh-antidote/share/zsh-antidote/antidote.zsh; do
    [[ -r "$c" ]] && { printf '%s\n' "$c"; return 0; }
  done
  if command -v brew >/dev/null 2>&1; then
    c="$(brew --prefix 2>/dev/null)/share/zsh-antidote/antidote.zsh"
    [[ -r "$c" ]] && { printf '%s\n' "$c"; return 0; }
  fi
  return 1
}

zshc_pkg_manager() {
  if command -v pacman >/dev/null 2>&1; then echo pacman
  elif command -v apt-get >/dev/null 2>&1; then echo apt
  elif command -v dnf >/dev/null 2>&1; then echo dnf
  elif command -v brew >/dev/null 2>&1; then echo brew
  else echo unknown; fi
}

# Print the command a USER should run to install a missing dependency.
# zsh-custom never runs this itself.
zshc_dep_hint() {
  local dep=$1 mgr; mgr="$(zshc_pkg_manager)"
  case "${mgr}:${dep}" in
    pacman:starship) echo "sudo pacman -S starship";;
    pacman:antidote) echo "yay -S zsh-antidote   # or another AUR helper";;
    pacman:zsh)      echo "sudo pacman -S zsh";;
    apt:starship)    echo "sudo apt-get install starship";;
    apt:antidote)    echo "sudo apt-get install zsh-antidote";;
    apt:zsh)         echo "sudo apt-get install zsh";;
    dnf:starship)    echo "sudo dnf install starship";;
    dnf:antidote)    echo "install antidote from source or your distribution";;
    dnf:zsh)         echo "sudo dnf install zsh";;
    brew:starship)   echo "brew install starship";;
    brew:antidote)   echo "brew install zsh-antidote   # or clone antidote";;
    brew:zsh)        echo "brew install zsh";;
    *)               echo "install '$dep' with your system package manager";;
  esac
}

zshc_zsh_version_ok() {
  command -v zsh >/dev/null 2>&1 || return 1
  local v major minor rest
  v="$(zsh -c 'echo $ZSH_VERSION' 2>/dev/null)" || return 1
  [[ -n $v ]] || return 1
  major=${v%%.*}; rest=${v#*.}; minor=${rest%%.*}
  (( major > 5 || (major == 5 && minor >= 4) ))
}

# Verify all system prerequisites. Never installs anything.
zshc_check_prereqs() {
  local failed=0
  if ! zshc_zsh_version_ok; then
    zshc_err "zsh >= 5.4 is required (found: $(zsh -c 'echo $ZSH_VERSION' 2>/dev/null || echo none))"
    zshc_log "  install/upgrade with: $(zshc_dep_hint zsh)"
    failed=1
  fi
  if ! zshc_antidote_path >/dev/null 2>&1; then
    zshc_err "antidote is not installed system-wide"
    zshc_log "  install with: $(zshc_dep_hint antidote)"
    failed=1
  fi
  if ! command -v starship >/dev/null 2>&1; then
    zshc_err "starship is not installed system-wide"
    zshc_log "  install with: $(zshc_dep_hint starship)"
    failed=1
  fi
  (( failed == 0 ))
}

# --- managed block ------------------------------------------------------------

# The block body is intentionally version-invariant: it only sources the
# entrypoint. Never change its contents between releases.
zshc_managed_block_body() {
  local repo=$1
  printf '%s\n' "$ZSHC_MARKER_BEGIN"
  printf '%s\n' "[ -f \"$repo/init.zsh\" ] && source \"$repo/init.zsh\""
  printf '%s\n' "$ZSHC_MARKER_END"
}

zshc_has_managed_block() {
  [[ -f ${1:-} ]] && grep -qF "$ZSHC_MARKER_BEGIN" "$1" 2>/dev/null
}

# Replace or append the managed block in file $1 (framework repo $2).
# Idempotent; preserves every line outside the markers.
zshc_write_managed_block() {
  local rc=$1 repo=$2 block tmp
  block="$(zshc_managed_block_body "$repo")"
  [[ -f $rc ]] || : > "$rc"
  tmp="$(mktemp)"
  if zshc_has_managed_block "$rc"; then
    awk -v b="$ZSHC_MARKER_BEGIN" -v e="$ZSHC_MARKER_END" -v block="$block" '
      $0==b {print block; skip=1; next}
      skip && $0==e {skip=0; next}
      skip {next}
      {print}
    ' "$rc" > "$tmp"
  else
    cp "$rc" "$tmp"
    if [[ -s $tmp ]] && [[ $(tail -c1 "$tmp" | wc -l) -eq 0 ]]; then
      printf '\n' >> "$tmp"
    fi
    printf '%s\n' "$block" >> "$tmp"
  fi
  if cmp -s "$tmp" "$rc"; then
    rm -f "$tmp"; return 1   # already up to date
  fi
  mv "$tmp" "$rc"
  return 0
}

zshc_remove_managed_block() {
  local rc=$1 tmp
  [[ -f $rc ]] || return 0
  zshc_has_managed_block "$rc" || return 0
  tmp="$(mktemp)"
  awk -v b="$ZSHC_MARKER_BEGIN" -v e="$ZSHC_MARKER_END" '
    $0==b {skip=1; next}
    skip && $0==e {skip=0; next}
    skip {next}
    {print}
  ' "$rc" > "$tmp"
  mv "$tmp" "$rc"
}

# --- user layer ---------------------------------------------------------------

zshc_seed_user_layer() {
  local repo=$1 layer tmpl rel dest
  layer="$(zshc_user_layer)"
  tmpl="$repo/templates/user"
  [[ -d $tmpl ]] || return 0
  mkdir -p "$layer/conf.d" 2>/dev/null
  while IFS= read -r rel; do
    [[ -z $rel ]] && continue
    dest="$layer/${rel#./}"
    [[ -e $dest ]] && continue
    mkdir -p "$(dirname "$dest")"
    cp -p "$tmpl/${rel#./}" "$dest"
    zshc_log "  seeded $dest"
  done < <(cd "$tmpl" && find . -type f -print)
  [[ -f "$layer/secrets.zsh" ]] && chmod 600 "$layer/secrets.zsh" 2>/dev/null
}

# --- validation / cache -------------------------------------------------------

zshc_validate() {
  local repo=$1 f
  local -a files=()
  [[ -f "$repo/init.zsh" ]] && files+=("$repo/init.zsh")
  for f in "$repo"/conf.d/*.zsh; do [[ -f $f ]] && files+=("$f"); done
  for f in "${files[@]}"; do
    if ! zsh -n "$f" 2>/dev/null; then
      zshc_err "syntax error in $f"
      return 1
    fi
  done
  return 0
}

zshc_refresh_cache() {
  local repo=$1
  rm -rf -- "$(zshc_cache_dir)" 2>/dev/null
  zsh -f -c "source '$repo/init.zsh'" >/dev/null 2>&1 || return 1
  return 0
}
