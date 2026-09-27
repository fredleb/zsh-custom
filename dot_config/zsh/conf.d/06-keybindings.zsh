# Line-editor key bindings: prefix history search and the terminal navigation
# cluster (Delete, Home, End, Insert, PageUp, PageDown).
#
# Prefix history search: Up/Down walk the history entries that begin with the
# text already on the line, so typing `opens` then Up recalls `openspec …`.
#
# The search is provided by zsh's own line-editor widgets
# (up-line-or-beginning-search / down-line-or-beginning-search), not by a
# hand-written implementation. The hybrid widgets keep ordinary history recall
# on an empty prompt and move the cursor in a multi-line buffer.
#
# Bound in both the emacs and viins keymaps because zsh links `main` to `viins`
# when $EDITOR/$VISUAL contains "vi" and to `emacs` otherwise (see zshzle(1)).
# All four arrow sequences are covered: normal-cursor mode (^[[A/^[[B) and
# application-cursor mode (^[OA/^[OB), matching zsh's defaults.
#
# Override any of this in ~/.config/zsh/local.zsh (sourced last).

if [[ -o interactive ]]; then
  # The widgets live in zsh's Zle function directory. `zle -N` does not verify
  # that the function exists (it succeeds for any name), so autoloading a
  # missing widget would fail only when the key is pressed. Verify the files are
  # resolvable in fpath first and warn instead of failing silently.
  _zsc_prefix_ok=0
  for _zsc_dir in $fpath; do
    if [[ -r $_zsc_dir/up-line-or-beginning-search && -r $_zsc_dir/down-line-or-beginning-search ]]; then
      _zsc_prefix_ok=1
      break
    fi
  done

  if (( _zsc_prefix_ok )); then
    autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
    zle -N up-line-or-beginning-search
    zle -N down-line-or-beginning-search
    for _zsc_keymap in emacs viins; do
      bindkey -M $_zsc_keymap '^[[A' up-line-or-beginning-search
      bindkey -M $_zsc_keymap '^[OA' up-line-or-beginning-search
      bindkey -M $_zsc_keymap '^[[B' down-line-or-beginning-search
      bindkey -M $_zsc_keymap '^[OB' down-line-or-beginning-search
    done
  else
    print -u2 "zsh: warning: prefix history search unavailable (zsh Zle widgets not found in fpath)."
  fi

  # Terminal navigation keys. zsh binds none of these, and because `main`
  # follows $EDITOR (the vi case links to `viins`) an unbound ESC-prefixed
  # sequence leaves insert mode and the rest runs as vi commands: Delete's
  # `ESC [ 3 ~`, for example, becomes a `3` count and `~` (swap case), silently
  # dropping the user into vi command mode. Bind them in every editing mode.
  #
  # Sequences come from terminfo where the terminal advertises them, plus
  # literal fallbacks for terminals that do not (or when TERM is unset, which is
  # why CI sets TERM=xterm). A missing capability is skipped without error.
  zmodload -i zsh/terminfo 2>/dev/null
  _zsc_bind_nav() {
    emulate -L zsh
    local widget=$1 maps=$2 seq km
    shift 2
    for seq in "$@"; do
      [[ -n $seq ]] || continue
      for km in ${(s:,:)maps}; do
        bindkey -M "$km" "$seq" "$widget"
      done
    done
  }
  _zsc_bind_nav delete-char       emacs,viins       "${terminfo[kdch1]}" '^[[3~' '^[O3~'
  _zsc_bind_nav vi-delete-char    vicmd             "${terminfo[kdch1]}" '^[[3~' '^[O3~'
  _zsc_bind_nav overwrite-mode    emacs,viins       "${terminfo[kich1]}" '^[[2~' '^[O2~'
  _zsc_bind_nav beginning-of-line emacs,viins,vicmd "${terminfo[khome]}" '^[[H' '^[OH' '^[[1~'
  _zsc_bind_nav end-of-line       emacs,viins,vicmd "${terminfo[kend]}" '^[[F' '^[OF' '^[[4~'
  _zsc_bind_nav up-line           emacs,viins,vicmd "${terminfo[kpp]}" '^[[5~'
  _zsc_bind_nav down-line         emacs,viins,vicmd "${terminfo[knp]}" '^[[6~'

  # Delete key modifiers. xterm-style encodings (emitted by terminals and by
  # multiplexers with xterm keys, e.g. tmux `xterm-keys on` as byobu sets) so
  # they must be bound too, or Shift/Ctrl+Delete leave vi insert mode.
  _zsc_bind_nav delete-char        emacs,viins       '^[[3;2~'
  _zsc_bind_nav vi-delete-char     vicmd             '^[[3;2~'
  _zsc_bind_nav kill-word          emacs,viins,vicmd '^[[3;5~'
  _zsc_bind_nav backward-kill-word emacs,viins,vicmd '^[[3;3~'
  unset -f _zsc_bind_nav

  unset _zsc_prefix_ok _zsc_dir _zsc_keymap
fi

# Skip a command that already appears elsewhere in history while walking.
setopt hist_find_no_dups
