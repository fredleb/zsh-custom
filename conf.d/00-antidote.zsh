# Resolve the system-installed antidote and load the default plugin set.

# Print the path to the packaged antidote entrypoint, or fail.
zshrc_custom_antidote_path() {
  emulate -L zsh
  local c
  local -a candidates=(
    /usr/share/zsh-antidote/antidote.zsh
    /usr/local/share/zsh-antidote/antidote.zsh
    /usr/share/zsh/plugins/antidote/antidote.zsh
    /opt/homebrew/share/zsh-antidote/antidote.zsh
    /usr/local/opt/zsh-antidote/share/zsh-antidote/antidote.zsh
  )
  for c in $candidates; do
    [[ -r $c ]] && { print -r -- $c; return 0 }
  done
  if (( $+commands[brew] )); then
    c="$(brew --prefix 2>/dev/null)/share/zsh-antidote/antidote.zsh"
    [[ -r $c ]] && { print -r -- $c; return 0 }
  fi
  return 1
}

# Load a plugin list file through a cached antidote static bundle. Fail-soft.
zshrc_custom_load_plugins() {
  emulate -L zsh
  setopt local_options no_aliases
  local list=$1
  [[ -r $list ]] || return 0
  # Skip files with no active (non-comment) lines.
  grep -qvE '^[[:space:]]*(#|$)' "$list" 2>/dev/null || return 0
  if ! (( $+functions[antidote] )); then
    print -u2 "zsh-custom: warning: antidote unavailable; skipping $list"
    return 1
  fi
  local name=${${list:t}:r}
  local cache="$ZSHRC_CUSTOM_CACHE/${name}.zsh"
  [[ -d $ZSHRC_CUSTOM_CACHE ]] || mkdir -p -- "$ZSHRC_CUSTOM_CACHE" 2>/dev/null
  if [[ ! -s $cache || $list -nt $cache ]]; then
    local tmp="$cache.tmp"
    if ! antidote bundle < "$list" >| "$tmp" 2>/dev/null; then
      # Fail-soft: resolve each plugin individually, warning about the bad ones.
      print -u2 "zsh-custom: warning: could not resolve all plugins in $list; checking individually"
      : > "$tmp"
      local line
      while IFS= read -r line; do
        [[ -z ${line//[[:space:]]/} || $line == \#* ]] && continue
        if ! antidote bundle <<< "$line" >> "$tmp" 2>/dev/null; then
          print -u2 "zsh-custom: warning: plugin unavailable: $line"
        fi
      done < "$list"
    fi
    mv -f -- "$tmp" "$cache"
  fi
  source "$cache"
}

typeset -g ZSHRC_CUSTOM_ANTIDOTE
ZSHRC_CUSTOM_ANTIDOTE="$(zshrc_custom_antidote_path 2>/dev/null)" || ZSHRC_CUSTOM_ANTIDOTE=""
if [[ -n $ZSHRC_CUSTOM_ANTIDOTE ]]; then
  source "$ZSHRC_CUSTOM_ANTIDOTE"

  # Stage 1: completions + autosuggestions (must run before compinit so that
  # zsh-completions' fpath entry is picked up).
  zshrc_custom_load_plugins "$ZSHRC_CUSTOM_ROOT/zsh_plugins.txt"

  # compinit: run once, unless something already initialized completion.
  if ! (( $+functions[compdef] )); then
    autoload -Uz compinit
    compinit
  fi

  # Stage 2: plugins that call compdef at source time (e.g. the git plugin).
  zshrc_custom_load_plugins "$ZSHRC_CUSTOM_ROOT/zsh_plugins.git.txt"
else
  print -u2 "zsh-custom: warning: antidote not found; plugins disabled."
  print -u2 "            Install 'zsh-antidote' system-wide (see README) and restart your shell."
fi
