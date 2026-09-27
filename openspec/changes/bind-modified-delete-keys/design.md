# Design: Bind Modified Delete Keys

## Context

See `proposal.md` for motivation.

- `dot_config/zsh/conf.d/06-keybindings.zsh` already binds the plain navigation
  keys, including Delete (`^[[3~`, `^[O3~`) to `delete-char` in the emacs and
  vi-insert keymaps and to `vi-delete-char` in vi-command mode, via a helper
  `_zsc_bind_nav <widget> <keymaps> <sequences…>`.
- xterm-style key encoding (`xterm-keys on`, which byobu sets) sends the Delete
  key's modifier combinations as `^[[3;2~` (Shift), `^[[3;5~` (Ctrl) and
  `^[[3;3~` (Alt). terminfo has no capability for these, so they are literal.

## Goals / Non-Goals

**Goals:**

- The Delete key's modifier combinations delete text in every editing mode,
  instead of leaving vi insert mode and running vi commands.

**Non-Goals:**

- Other modified keys (Shift/Ctrl+arrow, Shift+PageUp/Down), function keys, and
  the CSI-u encoding used when `extended-keys` is enabled rather than
  `xterm-keys`.

## Decisions

**D1 — Widget mapping.** Shift+Delete → `delete-char` (`vi-delete-char` in
vicmd), Ctrl+Delete → `kill-word` (delete the following word), Alt+Delete →
`backward-kill-word` (delete the preceding word). These are the conventional
readline/editor meanings. Alternative: map all three to `delete-char` (simpler
but loses the word operations users expect).

**D2 — Reuse the existing `_zsc_bind_nav` helper.** The sequences plug into the
same guarded helper, so keymap coverage (emacs, viins, vicmd) and the
empty-sequence guard stay consistent with the plain keys.

**D3 — Literal sequences only.** terminfo advertises no capability for modified
keys, so these are hard-coded; they are the xterm-standard encodings.

## Risks / Trade-offs

- **Other modified keys remain unbound** → still leave vi insert mode when
  pressed; deliberately out of scope, one line each to add later.
- **`extended-keys on` sends CSI-u (`^[[51;5u`)** instead of xterm `^[[3;5~` →
  these bindings would not match; also out of scope (the maintainer's byobu uses
  `xterm-keys`/xterm format).
- **Terminals that encode modified Delete differently** → the guarded helper
  ignores empty sequences but cannot guess unknown encodings; documented.
