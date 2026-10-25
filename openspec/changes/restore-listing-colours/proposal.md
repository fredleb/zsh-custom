## Why

Directory listings have been colourless since v2, while users still expect the
coloured `l`, `ll`, `la`, and `lsa` that the pre-v2 configuration provided. The
cause is a known gap, not a bug: v1 loaded the whole oh-my-zsh library, and
v3.1.0 restored only `lib/directories.zsh` and `lib/history.zsh`. The colour
layer lives in a third upstream file, `lib/theme-and-appearance.zsh`, which the
v3.1.0 design listed under **Non-Goals**. Because no requirement or CI check
covers listing colour, its absence has been silent — the same failure mode that
the alias restoration was meant to end.

## What Changes

- Load `ohmyzsh/ohmyzsh path:lib/theme-and-appearance.zsh` through antidote in
  the upstream-library stage, next to `lib/directories.zsh` and
  `lib/history.zsh`, so the listing aliases are colourised by an
  upstream-maintained definition rather than a hand-written alias.
- Define `ZSH_CACHE_DIR` before the plugin bundles load, so upstream's probe
  cache (`appearance-probes`) works instead of forking two probes on every
  shell start. Without it startup regresses by roughly 3–6 ms; with it the cost
  is at parity.
- Promise listing colour in the `shell-conveniences` capability: colour at an
  interactive terminal, plain text when piped or redirected (`--color=tty`
  semantics), native mechanism per platform, upstream-maintained definitions,
  and overridable by the user layer.
- Extend `ci/check-conveniences.sh` to assert the colour layer is present, so a
  future refactor fails CI instead of silently dropping it again.
- Document the behaviour and its platform difference in the README and the
  CHANGELOG.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `shell-conveniences`: a new requirement for colourised directory listings
  (terminal-only colour, per-platform mechanism, upstream-maintained source,
  user override).

## Impact

- **Config**: `dot_config/zsh/plugins.omz.txt` gains one library file;
  `dot_config/zsh/conf.d/00-antidote.zsh` sets `ZSH_CACHE_DIR` before loading.
- **Behaviour**: `l`, `ll`, `la`, and `lsa` become colourised when stdout is a
  terminal. GNU systems use `ls --color=tty` and a `LS_COLORS` palette; macOS
  uses `ls -G` and `LSCOLORS`. Piped output stays plain. On GNU systems
  `diff` also becomes a function wrapping `diff --color`. `$fg`, `$bg`,
  `$reset_color`, and the `ZSH_THEME_GIT_PROMPT_*` variables become defined as
  side effects.
- **Startup cost**: measured at parity once the probe cache works (roughly
  55 ms baseline; +3–6 ms without the cache variable, +0–1 ms with it).
- **Dependencies**: none added. `eza`/`lsd` are explicitly not adopted.
- **Out of scope**: `grep`/`egrep`/`fgrep` colour (provided by a different
  upstream file, `lib/grep.zsh`), and `ip`, `man`, `less`, and `systemctl`
  colouring.
- **CI**: the install test already runs on Ubuntu and macOS; the new assertion
  must pass on both.
