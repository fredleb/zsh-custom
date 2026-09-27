# Prefix History Search

## Why

Typing the start of a command (for example `opens`) and pressing Up recalls the
previous command regardless of what was typed, so it does not help recall a
specific recent invocation. Users expect Up and Down to walk history entries
that begin with the text already on the line.

## What Changes

- Up and Down recall history entries that begin with the text before the cursor
  when the line is non-empty, and fall back to ordinary history recall on an
  empty prompt. This is provided by zsh's built-in line-editor widgets
  (`up-line-or-beginning-search` / `down-line-or-beginning-search`), not a
  hand-written search.
- The bindings are installed in the `emacs` and `viins` keymaps, so they work
  regardless of each user's editing mode (zsh selects `viins` when `$EDITOR`
  contains `vi`).
- A command repeated in history is not shown twice while walking the prefix
  (`hist_find_no_dups`).
- The behavior ships from a new managed fragment
  `~/.config/zsh/conf.d/06-keybindings.zsh` and remains overridable through
  `~/.config/zsh/local.zsh`.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `shell-conveniences`: the interactive command history gains prefix filtering
  (Up/Down walk entries beginning with the typed text) and suppression of
  repeated entries during the walk.

## Impact

- New file `dot_config/zsh/conf.d/06-keybindings.zsh` (managed by chezmoi).
- `README.md` and `CHANGELOG.md` document the new convenience.
- `ci/check-conveniences.sh` asserts the Up/Down bindings in the sandbox.
- `openspec/specs/shell-conveniences/spec.md` gains a requirement (on archive).
- No new dependencies: the widgets ship with zsh.
- Behavior change: history recall filters by the typed prefix; repeated commands
  are hidden from recall (a global history option).
