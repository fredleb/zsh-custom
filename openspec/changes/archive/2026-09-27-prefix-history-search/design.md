# Design: Prefix History Search

## Context

See `proposal.md` for motivation. The relevant current state:

- History *options* come from `ohmyzsh/ohmyzsh lib/history.zsh` loaded through
  antidote (see `dot_config/zsh/plugins.omz.txt`). That file does not bind any
  keys; Up/Down keep zsh's stock `up-line-or-history` / `down-line-or-history`,
  which search nothing.
- `conf.d` fragments load in lexical order after antidote and `compinit`, and
  `~/.config/zsh/local.zsh` is sourced last, so a fragment is the natural place
  to install bindings and let users override them.
- zsh links the `main` keymap to `viins` when `$EDITOR` or `$VISUAL` contains
  the substring `vi` (`zshzle(1)`), otherwise to `emacs`. On this fleet
  `EDITOR=vim`, so the default editing keymap is `viins`.
- The prefix-search primitives ship with zsh in its `Zle` function directory;
  nothing new is installed.

## Goals / Non-Goals

**Goals:**

- Typed text filters history recall; empty prompt falls back to ordinary recall.
- Works in both the emacs and vi editing modes.
- Repeated commands are not shown twice while walking.
- Overridable through the untracked user layer.

**Non-Goals:**

- Substring or fuzzy matching anywhere in the line (that is a different feature,
  e.g. the `zsh-history-substring-search` plugin).
- Binding `^P` / `^N`, or the vi command-mode (`vicmd`) keymap.
- Any change to completion behavior.

## Decisions

**D1 — Use zsh's hybrid widgets, not the raw search widgets.** Bind
`up-line-or-beginning-search` / `down-line-or-beginning-search`. They perform a
whole-line-prefix search when the line is non-empty, fall back to ordinary
history on an empty prompt, and move the cursor instead of searching in a
multi-line buffer. Alternatives considered: `history-beginning-search-backward`/
`forward` (Prefix, but always searches, so an empty prompt and mid-line editing
behave worse) and `history-search-backward`/`forward` (matches only the first
word, so `openspec s` would not narrow to `openspec show …`). The hybrid was
validated against a live pty.

**D2 — Install in `emacs` and `viins`, not bare `main`.** Because zsh picks the
default keymap from `$EDITOR`/`$VISUAL` (D-context above), binding only `main`
works for the startup default but breaks for anyone with the other setting or
who later runs `bindkey -e` / `bindkey -v`. Binding both keymaps is two extra
lines and is deterministic. Alternative: bind `main` only.

**D3 — Enable `hist_find_no_dups` to suppress repeats.** Chosen deliberately as
a global history option, accepting that it affects all recall, not just the
prefix walk.

**D4 — Ship from a new `dot_config/zsh/conf.d/06-keybindings.zsh`.** Keeps the
bindings separate from completion (`05-completion.zsh`) and gives users a clear
override target. Alternative: fold into `05-completion.zsh`, which already uses
`zle -N`/`bindkey`.

**D5 — Arrows only.** `^P`/`^N` are left untouched; they are a separate UX call.

## Risks / Trade-offs

- **`Zle` functions missing from `fpath`** (a split `zsh` functions package)
  would make `autoload` create a stub that fails only when pressed → guard at
  load time: warn once if the widget function cannot be found, and assert the
  binding in `ci/check-conveniences.sh`.
- **`hist_find_no_dups` is global** → intended per D3, but worth stating in the
  changelog so the change is not mistaken for prefix-only.
- **Cursor at column 0 of a single-line buffer** searches with an empty prefix
  and jumps to the newest entry → documented corner; the common case (cursor at
  end) is unaffected.
- **`vicmd` is not bound** → Up/Down in vi command mode keep their normal
  behavior; acceptable and explicit in the non-goals.
