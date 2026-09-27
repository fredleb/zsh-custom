# Design: Fix Terminal Navigation Keys

## Context

See `proposal.md` for motivation.

- `dot_config/zsh/conf.d/06-keybindings.zsh` already binds the arrow keys (Up
  and Down) in the `emacs` and `viins` keymaps, using literal sequences that
  match both cursor modes (`^[[A`/`^[OA`). This change extends the same fragment.
- zsh's default keymaps bind no Delete/Home/End/Insert/PageUp/PageDown sequence
  (`delete-char` and `up-line`/`down-line` have no default binding), and
  `main` links to `viins` or `emacs` based on `$EDITOR`/`$VISUAL`.
- The sequences are terminal-specific. Measured for the same keys:
  `TERM=xterm` gives Home/End as `^[OH`/`^[OF`, while `screen`/`tmux-256color`
  and `linux` give `^[[1~`/`^[[4~`; `vt100` and `dumb` advertise none. Delete is
  `^[[3~` almost everywhere.

## Goals / Non-Goals

**Goals:**

- The navigation cluster performs its conventional action in emacs and vi
  insert modes, without leaving insert mode or inserting escape text.
- Works across terminals, including inside a multiplexer, and degrades quietly
  when a capability is missing.

**Non-Goals:**

- Function keys, and Ctrl/Alt-modified Delete.
- Changing which keymap the shell starts in (the user's `$EDITOR` choice stands).
- Reworking the arrow bindings already shipped.

## Decisions

**D1 — Sequences from terminfo, plus literal fallbacks.** Bind
`$terminfo[kdch1|khome|kend|kich1|kpp|knp]` (after `zmodload zsh/terminfo`) and
*also* the well-known literal alternates. terminfo alone breaks when `TERM` is
unset or `dumb` (empty capabilities, so nothing gets bound) and does not cover a
terminal that sends a variant; literals alone break inside tmux (different
Home/End) and other non-xterm terminals. Together they cover both. Alternative:
literals only (simpler, but wrong under tmux — the reporter's environment);
terminfo only (fails headless).

**D2 — Bind `emacs`, `viins`, and `vicmd`.** The insert modes are the two zsh
can start in; `vicmd` is included so that in vi command mode the same keys do
not fall through to unrelated vi commands (`~`, `P`, …). Alternative: insert
modes only (leaves the command-mode foot-guns).

**D3 — Delete maps to `vi-delete-char` in `vicmd`.** The vi-appropriate widget
that does not delete past the end of the line; the insert modes use
`delete-char`. Alternative: `delete-char` everywhere (works, but `vi-delete-char`
is the intended vi command-mode behaviour).

**D4 — PageUp/PageDown map to `up-line`/`down-line`.** Buffer movement, chosen
by the maintainer over history navigation or prefix search. `up-line`/`down-line`
are unbound zsh widgets with exactly this meaning.

**D5 — Omit function keys and modifier combos.** They are not used and are not
part of "the navigation cluster"; leaving them out keeps the change focused.
Residual: an unbound Ctrl+Del still drops vi insert mode, which can be added in
one line later.

**D6 — Guarded, non-fatal binding.** A helper binds a sequence only when it is
non-empty, so `dumb`/unset `TERM` and terminals without a capability produce no
error.

## Risks / Trade-offs

- **CI runs headless with no `TERM`** → terminfo capabilities are empty and only
  the literal fallbacks bind; the CI check must set `TERM=xterm` explicitly for
  the terminfo-derived assertions.
- **Binding the same sequence twice** (terminfo and a literal that coincide) →
  harmless; `bindkey` is idempotent.
- **Over-strict guarding could hide a broken terminal** → the fallbacks ensure
  the common sequences are always bound regardless of terminfo.
- **Overriding a user's deliberate rebind** → `local.zsh` is sourced last, so
  user overrides still win.
