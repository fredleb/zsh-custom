# Bind Modified Delete Keys

## Why

The terminal-navigation fix bound the plain Delete key, but terminals and
multiplexers that emit xterm-style modified keys (byobu enables this with
`xterm-keys on`) send Shift+Delete and Ctrl+Delete as `^[[3;2~` and `^[[3;5~`.
Those sequences are still unbound, so in the vi keymap they leave insert mode
and the rest runs as vi commands, corrupting the line. Measured on the
maintainer's terminal: Delete `^[[3~`, Shift+Delete `^[[3;2~`, Ctrl+Delete
`^[[3;5~`.

## What Changes

- The keybindings fragment (`dot_config/zsh/conf.d/06-keybindings.zsh`) binds
  the Delete family's modifier sequences: Shift+Delete deletes the character
  under the cursor, Ctrl+Delete deletes the following word, and Alt+Delete
  deletes the preceding word, in the emacs, vi, and vi-command keymaps.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `shell-conveniences`: the terminal navigation keys gain the Delete key's
  modifier combinations.

## Impact

- `dot_config/zsh/conf.d/06-keybindings.zsh`; `README.md`; `CHANGELOG.md`;
  `ci/check-conveniences.sh`.
- No new dependency.
- Out of scope: other modified keys (Shift/Ctrl+arrows), function keys, and the
  CSI-u encoding some terminals use when `extended-keys` is enabled.
