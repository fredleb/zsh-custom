## Context

See `proposal.md` — Why. Relevant current state, all verified against the
installed shell rather than assumed:

- The loader (`conf.d/00-antidote.zsh`) sources each plugin bundle inside a
  function that runs `emulate -L zsh`. Option changes made by a bundle are
  discarded; aliases and environment exports are not. That is why the loader
  re-asserts `auto_cd` and the history options globally after all stages.
- `~/.cache/zsh/` already holds the generated bundles (`plugins.zsh`,
  `plugins.omz.zsh`, …), named from the plugin-list basename.
- oh-my-zsh's `lib/theme-and-appearance.zsh` reads `$ZSH_CACHE_DIR` for its
  probe cache. That variable is set by oh-my-zsh's own entrypoint
  (`oh-my-zsh.sh`, line 57), which this repository deliberately bypasses. The
  variable name here is `$ZSH_CACHE`.
- A throwaway `XDG_CONFIG_HOME` running the real `dot_zshrc` confirmed that
  sourcing `lib/theme-and-appearance.zsh` inside the loader's `emulate -L zsh`
  scope yields `alias ls='ls --color=tty'`, a 1906-character `LS_COLORS`,
  `LSCOLORS=Gxfxcxdxbxegedabagacad`, and a `diff` function. `prompt_subst` is
  scoped away, which is harmless because Starship's `init` sets it itself.
- Aliases chain: `ll='ls -lh'` expands `ls`, which then expands to
  `ls --color=tty`. One colour alias repairs all four listing aliases,
  regardless of definition order.
- Measured startup cost, 100 runs per variant, `zsh -f -c 'source dot_zshrc'`:
  baseline ≈ 54–59 ms; with the library but no `ZSH_CACHE_DIR` ≈ 60–65 ms;
  with both ≈ 58–59 ms.

## Goals / Non-Goals

**Goals:**

- Colourised `ls`/`l`/`ll`/`la`/`lsa` on Linux and macOS with no new
  dependency and no measurable startup regression.
- The colour layer stays upstream-maintained, matching how the listing aliases
  are already sourced.
- A CI assertion, so this cannot disappear silently a third time.

**Non-Goals:**

- Reaching an identical palette on Linux and macOS.
- Colouring `grep`/`egrep`/`fgrep` (`lib/grep.zsh`), `ip`, `man`, `less`,
  `systemctl`, or `journalctl`.
- Adopting `eza`/`lsd`, or owning a managed `dircolors` scheme.
- Making the `diff` wrapper a promised behaviour; it is an accepted side
  effect.

## Decisions

### Decision: Load upstream's `lib/theme-and-appearance.zsh`

Add one line to `dot_config/zsh/plugins.omz.txt`, after `directories.zsh` and
`history.zsh` (upstream's own alphabetical position).

- Rationale: it is the file that produced the behaviour being restored, and it
  keeps the capability's existing "upstream-maintained, not hand-maintained"
  constraint. The upstream file already handles the Linux/macOS split, the
  `~/.dircolors` preference, and the "only set `LS_COLORS` if unset" guard.
- Alternatives: a hand-written `conf.d/07-colours.zsh` (rejected — abandons the
  upstream-maintained principle for ~10 lines and must reimplement the
  platform split); `lib/grep.zsh` too (out of scope); forcing a managed palette
  (rejected — new maintenance burden for no behavioural gain).
- The file lives in the stage-2 list even though it does not need `compdef`;
  that list is the "upstream oh-my-zsh library files" stage, so it is the
  coherent home. Update the list's header comment, which currently explains
  the stage only in terms of `directories.zsh`.

### Decision: Point `ZSH_CACHE_DIR` at `$ZSH_CACHE` before the bundles load

Add `ZSH_CACHE_DIR="$ZSH_CACHE"` in `conf.d/00-antidote.zsh` before the first
`zshrc_antidote_bundle_load` call.

- Rationale: without it the probe cache path becomes `/appearance-probes`; the
  `[[ -w "" ]]` guard suppresses the write, so the file silently never caches
  and forks `diff --color` and `ls --color` on every shell start. Measured
  cost of that: +3–6 ms per shell. With the variable the probes are cached in
  `$ZSH_CACHE/appearance-probes` and the cost returns to parity.
- Alternatives: leave it unset (rejected — slower, and upstream's cache
  mechanism is silently dead); point it at `~/.cache/oh-my-zsh` (rejected — a
  second cache directory for one file); set it in `local.zsh` (rejected — this
  is framework plumbing, not user preference).
- Plain assignment, not `export`: oh-my-zsh sets it unexported, and only the
  shell's libraries read it.

### Decision: Keep upstream's per-platform colour mechanism

Do not override the `$OSTYPE` branch. Linux gets `ls --color=tty` and the GNU
`LS_COLORS` palette; macOS gets `ls -G` and `LSCOLORS`.

- Rationale: `--color=tty` gives exactly the semantics the spec asks for —
  colour at a terminal, plain in pipes. The platform branch is the only
  portable way to honour that without assuming GNU coreutils.
- Alternatives: `--color=always` (rejected — colours escape sequences leak
  into pipes and files); force `gls --color=tty` everywhere (rejected — makes
  brew coreutils mandatory on macOS, i.e. a new dependency).

### Decision: Accept different palettes per platform

The spec promises colour, not identical colour. On macOS the BSD palette
applies even when Homebrew coreutils are installed, because upstream's default
is "native `ls` first".

- Rationale: cheapest, and matches upstream. A user who wants GNU colours on
  macOS can opt in by aliasing `ls` to `gls --color=tty` in
  `~/.config/zsh/local.zsh`. Upstream's `gnu-ls` zstyle would be the natural
  switch, but `theme-and-appearance.zsh` reads it while loading, before the
  user layer is sourced, so setting it there has no effect.
- Alternative: set that zstyle by default (rejected — it would need `gls` to be
  installed to have any effect, so it would be a no-op on stock macOS and a
  hidden dependency where it is not).

### Decision: Assert colour portably in CI

Add the same portable assertion to both CI scripts, because the coverage
differs: `check-conveniences.sh` runs in the Linux-only `hygiene` job, while
`test-install.sh` runs in the `install` matrix on Ubuntu **and** macOS. The
assertion is that the `ls` alias is defined and matches `--color` or `-G`, and
that the corresponding palette variable (`LS_COLORS` on Linux, `LSCOLORS` on
macOS) is non-empty. Also add the static check that
`lib/theme-and-appearance.zsh` is declared in a plugin list.

- Rationale: putting it only in the hygiene job would leave the macOS branch
  unverified; putting it only in the install test would leave the fast
  convenience check blind. Both scripts already duplicate the listing-alias
  assertion, so this follows the established pattern.
- The assertions must not require a tty, so they check the alias and the
  variables rather than inspecting rendered bytes. A rendered-bytes check
  belongs to the implementation tasks, run under `script` for a pty.

## Risks / Trade-offs

- **`diff` becomes a shell function on Linux only** (upstream wraps it with
  `--color`). It is a user-visible difference between platforms and a
  behaviour change beyond "listing colour". → Only `diff` is affected, GNU
  `diff` without `--color` support is probed and skipped, and v1 behaved the
  same way. Document it in the CHANGELOG; do not promise it.
- **`$fg`, `$bg`, `$reset_color`, and `ZSH_THEME_GIT_PROMPT_*` become defined**
  as side effects of `autoload colors`. → Harmless globals; the prompt is
  Starship's, so the omz theme variables are inert.
- **`emulate -L zsh` scoping** could silently discard something the file sets.
  → Verified: alias and exports survive; only `prompt_subst` does not, and
  Starship owns it. No loader change needed.
- **Upstream could rename or remove the file.** → antidote reports the pattern
  individually (`plugin unavailable`), the loader already treats that as a
  warning, and the new CI assertion turns it into a red check.
- **The bundle cache must be regenerated.** The loader rebuilds when
  `plugins.omz.txt` is newer than the cache; `chezmoi update` changes the
  mtime, so no manual step is needed. A stale cache would simply keep the
  current colourless behaviour until the next shell start after the update.
- **`ZSH_CACHE_DIR` is a global name from another framework.** → Matching its
  conventional meaning is intentional; if a user's other omz usage already
  defines it, the existing value wins only if the assignment is made
  conditional, which it is not. The assignment is confined to the framework
  fragment and is overridable in `local.zsh` if it ever conflicts.

## Migration Plan

No user action. `chezmoi update` applies the two config lines, and the next
interactive shell is coloured. Rollback is deleting the
`lib/theme-and-appearance.zsh` line: listings return to plain, the listing
aliases and history are unaffected.

Release: MINOR (3.6.0) — a new user-visible capability, with a CHANGELOG entry.
