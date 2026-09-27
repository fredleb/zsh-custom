# Locate antidote (system package or Homebrew) and load plugins in stages.

zshrc_antidote_path() {
  emulate -L zsh
  local c
  local -a candidates=(
    /usr/share/zsh-antidote/antidote.zsh
    /usr/local/share/zsh-antidote/antidote.zsh
    /usr/share/zsh/plugins/antidote/antidote.zsh
  )
  for c in $candidates; do
    [[ -r $c ]] && { print -r -- $c; return 0 }
  done
  if (( $+commands[brew] )); then
    c="$(brew --prefix)/opt/antidote/share/antidote/antidote.zsh"
    [[ -r $c ]] && { print -r -- $c; return 0 }
  fi
  return 1
}

# Build (when stale) and source a cached antidote bundle for one plugins file.
# Keeps generated files out of the managed ~/.config/zsh directory.
zshrc_antidote_bundle_load() {
  emulate -L zsh
  local list=$1 cache tmp
  [[ -r $list ]] || return 0
  grep -qvE '^[[:space:]]*(#|$)' "$list" 2>/dev/null || return 0
  cache="$ZSH_CACHE/${${list:t}:r}.zsh"
  if [[ ! -s $cache || $list -nt $cache ]]; then
    tmp="$cache.tmp"
    if antidote bundle < "$list" >| "$tmp" 2>/dev/null; then
      mv -f -- "$tmp" "$cache"
    else
      rm -f -- "$tmp"
      print -u2 "zsh: warning: could not resolve plugins in $list"
      return 1
    fi
  fi
  source "$cache"
}

if (( $+functions[antidote] )); then
  :  # already loaded by a parent shell
elif [[ -n ${ZSHRC_ANTIDOTE_PATH:-} && -r ${ZSHRC_ANTIDOTE_PATH:-} ]]; then
  source "$ZSHRC_ANTIDOTE_PATH"
elif _zsc_antidote="$(zshrc_antidote_path)"; then
  source "$_zsc_antidote"
else
  print -u2 "zsh: warning: antidote not found; plugins disabled."
  print -u2 "     macOS: brew install antidote | Debian/Ubuntu: sudo apt-get install zsh-antidote"
  return 0
fi
unset _zsc_antidote

# Stage 1: completions + autosuggestions (before compinit).
zshrc_antidote_bundle_load "$ZSH_CONFIG/plugins.txt"

# compinit once.
if ! (( $+functions[compdef] )); then
  autoload -Uz compinit
  compinit
fi

# Stage 2: plugins that call compdef at source time.
zshrc_antidote_bundle_load "$ZSH_CONFIG/plugins.git.txt"

# Stage 3: syntax highlighting last.
zshrc_antidote_bundle_load "$ZSH_CONFIG/plugins.last.txt"
