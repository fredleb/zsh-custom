# Use Emacs Key Bindings in the Shell

## Why

zsh chooses its line-editor key map from `$EDITOR`/`$VISUAL`: when either
contains `vi` it uses the vi-insert key map, otherwise emacs. Because the
configuration sets `EDITOR=vim`, the shell silently runs the vi key map, where
the emacs control keys are missing — Ctrl-R (history search) is bound to
`redisplay`, and Ctrl-A/Ctrl-E/Ctrl-P/Ctrl-N do nothing useful. Users lose
incremental history search and familiar line editing. The shell's editing mode
should be a deliberate choice, not a side effect of `$EDITOR`, which is about
external editors.

## What Changes

- The keybindings fragment selects the emacs key map for the line editor
  (`bindkey -e`), decoupling it from `$EDITOR`/`$VISUAL`. This restores Ctrl-R
  history search and the other emacs editing keys at once.
- Users who want vi modal editing opt back in from the untracked customization
  layer (`bindkey -v`), which is sourced last.
- The existing arrow, navigation, and Delete-modifier bindings already cover the
  emacs key map and keep applying.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `shell-conveniences`: the line editor's key map is selected deliberately
  (emacs) rather than following `$EDITOR`, restoring the emacs control keys
  including history search.

## Impact

- `dot_config/zsh/conf.d/06-keybindings.zsh`; `README.md`; `CHANGELOG.md`;
  `ci/check-conveniences.sh`.
- Behavior change: the shell uses emacs key bindings even when `$EDITOR`
  contains `vi`; ESC no longer enters vi command mode in the shell. Overridable
  through `~/.config/zsh/local.zsh`.
