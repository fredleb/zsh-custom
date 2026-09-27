# Interactive completion: selectable menu, highlighting, and matching.
#
# These are standard zsh completion settings. oh-my-zsh (used by the previous
# config) applies the same ones in its lib/completion.zsh. Without them the
# completion list has no selectable menu and no highlighting.
#
# Override any of this in ~/.config/zsh/local.zsh (sourced last).

# The complist module provides the selectable menu.
zmodload -i zsh/complist

# Make - and _ completion word separators (enables partial-word matching).
WORDCHARS=''

unsetopt MENU_COMPLETE     # do not cycle directly; show a menu instead
setopt AUTO_MENU           # open the menu on the second Tab
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END

# Arrow-key selection in the menu, with the current entry highlighted.
zstyle ':completion:*:*:*:*:*' menu select

# Highlight and colorize the candidate list.
zstyle ':completion:*' list-colors ''

# Case-insensitive, partial-word, and substring matching.
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*'

# Complete . and ..
zstyle ':completion:*' special-dirs true

# Cache expensive completions.
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$ZSH_CACHE/zcompcache"
[[ -d $ZSH_CACHE/zcompcache ]] || mkdir -p -- "$ZSH_CACHE/zcompcache" 2>/dev/null

# Don't offer uninteresting system users.
zstyle ':completion:*:*:*:users' ignored-patterns \
  adm apache at avahi bin daemon ftp games gdm halt ldap lp mail mailnull \
  man messagebus mysql named news nobody nscd ntp operator postfix postgres \
  rpc rpcuser rpm sshd sync tftp uucp wwwrun xfs '_*'

zstyle '*' single-ignored show

# Optional: show dots while a slow completion runs (set COMPLETION_WAITING_DOTS).
if [[ ${COMPLETION_WAITING_DOTS:-false} != false ]]; then
  expand-or-complete-with-dots() {
    [[ $COMPLETION_WAITING_DOTS = true ]] && COMPLETION_WAITING_DOTS="%F{red}…%f"
    printf '\e[?7l%s\e[?7h' "${(%)COMPLETION_WAITING_DOTS}"
    zle expand-or-complete
    zle redisplay
  }
  zle -N expand-or-complete-with-dots
  bindkey -M emacs '^I' expand-or-complete-with-dots
  bindkey -M viins '^I' expand-or-complete-with-dots
  bindkey -M vicmd '^I' expand-or-complete-with-dots
fi
