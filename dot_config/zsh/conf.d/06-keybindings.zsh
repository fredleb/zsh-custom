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
  unset _zsc_prefix_ok _zsc_dir _zsc_keymap
fi

# Skip a command that already appears elsewhere in history while walking.
setopt hist_find_no_dups
