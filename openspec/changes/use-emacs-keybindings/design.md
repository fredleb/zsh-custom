# Design: Use Emacs Key Bindings in the Shell

## Context

See `proposal.md` for motivation.

- zsh links `main` to `viins` when `$EDITOR`/`$VISUAL` contains `vi`, otherwise
  to `emacs` (`zshzle(1)`). The user customization layer sets `EDITOR=vim`, so
  the shell ran the vi-insert key map.
- Measured: `viins ^R -> redisplay`, `viins ^A/^E/^P/^N` are not the emacs
  bindings, while `emacs ^R -> history-incremental-search-backward`.
- Earlier changes bound arrows, the navigation keys, and the Delete modifiers in
  `emacs`, `viins`, and `vicmd`; the `emacs` bindings are ready to use.

## Goals / Non-Goals

**Goals:**

- The shell uses the emacs key map regardless of `$EDITOR`, restoring Ctrl-R
  history search and the other emacs editing keys.
- Overridable, so a user can still choose the vi key map.

**Non-Goals:**

- Changing `$EDITOR`/`$VISUAL` (those are for external tools).
- Removing vi support from zsh altogether.
- Re-binding the navigation/Delete keys (already covered in the emacs key map).

## Decisions

**D1 — Select emacs explicitly with `bindkey -e` rather than patching more keys
into `viins`.** One line restores the entire emacs key set (Ctrl-R, Ctrl-A/E,
Ctrl-P/N, Ctrl-W/K/U, …) and decouples the shell's editing mode from `$EDITOR`.
Alternatives considered: keep patching individual keys in `viins` (incomplete —
exactly what we had been doing, one surprise at a time); change `$EDITOR`
(wrong: it targets external editors, and the shell would still follow it).

**D2 — Keep the existing `viins`/`vicmd` bindings.** They are dormant while the
emacs key map is active and remain correct if a user selects vi mode with
`bindkey -v`.

**D3 — Place `bindkey -e` at the top of the interactive block in
`06-keybindings.zsh`.** It applies before the rest of the bindings and is easy to
find and override.

## Risks / Trade-offs

- **Users who relied on vi modal editing in the shell lose it** → documented;
  `bindkey -v` in `~/.config/zsh/local.zsh` (sourced last) restores vi mode.
  Classified as a MINOR behavior change.
- **Overriding a user's deliberate key choices** → the user customization layer
  is still sourced last, so its overrides win.
