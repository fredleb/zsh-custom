# Fix Terminal Navigation Keys

## Why

In the default configuration the terminal navigation keys — Delete, Home, End,
Insert, PageUp, PageDown — do not perform their editing action. zsh binds none
of them by default, and because zsh selects the `main` keymap from `$EDITOR`
(the `vi` case links to `viins`), the leading `ESC` of each key sequence is read
as "leave insert mode"; the rest of the sequence then runs as vi commands.
Pressing Delete mid-line, for example, changes the case of following text and
silently drops the user into vi command mode; in the emacs keymap the same keys
insert stray `~` characters. Both failure modes are silent and confusing.

## What Changes

- The managed keybindings fragment (`dot_config/zsh/conf.d/06-keybindings.zsh`)
  gains bindings for the navigation cluster in the emacs, vi-insert, and
  vi-command keymaps: Delete deletes forward, Home/End move to the line bounds,
  Insert toggles overwrite mode, and PageUp/PageDown move within the buffer.
- Key sequences are read from the terminal's capabilities (`terminfo`) with
  well-known literal fallbacks, so the bindings work outside xterm and inside a
  terminal multiplexer such as tmux, where Home and End use different sequences.
- Bindings are guarded: a sequence the current terminal does not provide is
  skipped without error.
- Out of scope: function keys, and Ctrl/Alt-modified Delete.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `shell-conveniences`: the shell gains working terminal navigation keys in
  every editing mode it can start in.

## Impact

- `dot_config/zsh/conf.d/06-keybindings.zsh`; `README.md`; `CHANGELOG.md`;
  `ci/check-conveniences.sh`.
- No new dependency: `zsh/terminfo` ships with zsh.
- Behavior change: the navigation keys no longer insert escape sequences or
  change the editing mode.
