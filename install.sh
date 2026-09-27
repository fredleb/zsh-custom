#!/usr/bin/env bash
# Bootstrap zsh-custom via chezmoi.
#
# Verifies system prerequisites (chezmoi, antidote, starship) and applies this
# repository with chezmoi. It NEVER installs packages and NEVER escalates
# privileges: when something is missing it prints the command for the user.
set -euo pipefail

repo="${ZSHRC_REPO:-fredleb/zsh-custom}"

pkg_manager() {
  if command -v brew >/dev/null 2>&1; then echo brew
  elif command -v pacman >/dev/null 2>&1; then echo pacman
  elif command -v apt-get >/dev/null 2>&1; then echo apt
  elif command -v dnf >/dev/null 2>&1; then echo dnf
  else echo unknown; fi
}

# Print the command a USER should run. This script never runs it.
dep_hint() {
  local dep=$1 mgr; mgr="$(pkg_manager)"
  case "${mgr}:${dep}" in
    brew:chezmoi)    echo "brew install chezmoi";;
    brew:antidote)   echo "brew install antidote";;
    brew:starship)   echo "brew install starship";;
    pacman:chezmoi)  echo "sudo pacman -S chezmoi";;
    pacman:antidote) echo "yay -S zsh-antidote   # or another AUR helper";;
    pacman:starship) echo "sudo pacman -S starship";;
    apt:chezmoi)     echo "sudo apt-get install chezmoi";;
    apt:antidote)    echo "sudo apt-get install zsh-antidote";;
    apt:starship)    echo "sudo apt-get install starship";;
    dnf:chezmoi)     echo "sudo dnf install chezmoi";;
    dnf:antidote)    echo "install antidote from source or your distribution";;
    dnf:starship)    echo "sudo dnf install starship";;
    *)               echo "install '$dep' with your system package manager";;
  esac
}

# antidote is a sourced zsh script, not a command on PATH.
antidote_found() {
  [[ -n ${ZSHRC_ANTIDOTE_PATH:-} && -r ${ZSHRC_ANTIDOTE_PATH:-} ]] && return 0
  local c
  for c in /usr/share/zsh-antidote/antidote.zsh \
           /usr/local/share/zsh-antidote/antidote.zsh \
           /usr/share/zsh/plugins/antidote/antidote.zsh; do
    [[ -r $c ]] && return 0
  done
  if command -v brew >/dev/null 2>&1; then
    [[ -r "$(brew --prefix 2>/dev/null)/opt/antidote/share/antidote/antidote.zsh" ]] && return 0
  fi
  return 1
}

missing=()
command -v chezmoi >/dev/null 2>&1 || missing+=(chezmoi)
antidote_found || missing+=(antidote)
command -v starship >/dev/null 2>&1 || missing+=(starship)

if (( ${#missing[@]} )); then
  echo "zsh-custom: missing system prerequisites:" >&2
  for d in "${missing[@]}"; do
    printf '  %-9s %s\n' "$d" "$(dep_hint "$d")" >&2
  done
  echo "Install them with your package manager, then re-run this script." >&2
  exit 1
fi

if [[ -f ${HOME}/.zshrc ]]; then
  echo "First apply: your existing shell files are backed up to *.pre-chezmoi."
fi

exec chezmoi init --apply "$@" "$repo"
