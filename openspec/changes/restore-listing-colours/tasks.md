## 1. Configuration

- [x] 1.1 Add `ohmyzsh/ohmyzsh path:lib/theme-and-appearance.zsh` to `dot_config/zsh/plugins.omz.txt` after `lib/directories.zsh` and `lib/history.zsh`, and update the file's header comment so it explains both reasons for stage 2. Verify with `grep -n theme-and-appearance dot_config/zsh/plugins.omz.txt` and confirm `zsh -n` is clean.
- [x] 1.2 Set `ZSH_CACHE_DIR="$ZSH_CACHE"` in `dot_config/zsh/conf.d/00-antidote.zsh` before the first `zshrc_antidote_bundle_load` call, with a comment explaining that oh-my-zsh's library files read it. Verify `zsh -i -c 'print -r -- $ZSH_CACHE_DIR'` prints `$ZSH_CACHE` and that `$ZSH_CACHE/appearance-probes` exists after one interactive start.

## 2. Behaviour

- [x] 2.1 In a throwaway `XDG_CONFIG_HOME` running the real `dot_zshrc`, verify `alias ls` matches `--color=tty` on Linux and that `LS_COLORS` is non-empty (the spike used for this design is the template: copy `conf.d/` and the plugin lists, apply with the overridden XDG roots).
- [x] 2.2 Verify all four aliases are colourised through alias chaining: under a pty (`script -qc 'll' /dev/null`) confirm `l`, `ll`, `la`, and `lsa` emit escape sequences.
- [x] 2.3 Verify piped output stays plain: `ll | cat -v` and `ls > /tmp/out; cat -v /tmp/out` contain no `^[[` sequences.
- [x] 2.4 Verify startup parity using the design's method: 100 runs of `zsh -f -c 'source dot_zshrc'` with and without the change, and confirm the delta is within ~2 ms of the ~55 ms baseline.
- [x] 2.5 Verify the accepted side effects: `whence -a diff` reports a function wrapping `diff --color` on Linux, `$fg`/`$bg`/`$reset_color` are defined, and `bindkey -lL main` still reports the emacs key map (no option regression).

## 3. CI

- [x] 3.1 Add the static assertion to `ci/check-conveniences.sh` that `lib/theme-and-appearance.zsh` is declared in a plugin list, and add the portable runtime assertion (alias matches `--color` or `-G`; `LS_COLORS` on Linux / `LSCOLORS` on macOS is non-empty). Verify `bash ci/check-conveniences.sh` prints `check-conveniences: ok`.
- [x] 3.2 Add the same portable assertion to the convenience block in `ci/test-install.sh` so the `macos-latest` matrix leg covers it. Verify `bash ci/test-install.sh` passes locally.
- [x] 3.3 Negative test: temporarily remove the `theme-and-appearance` line and confirm `bash ci/check-conveniences.sh` fails with a message naming the missing colour layer, then restore it.

## 4. Documentation and release

- [x] 4.1 Add a row for colourised listings to the "Shell conveniences" table in `README.md`, note the Linux/macOS palette difference, and show the `DISABLE_LS_COLORS`/`zstyle` override in the examples. Verify the rendered Markdown table has no broken row.
- [x] 4.2 Add a `## [3.6.0] - YYYY-MM-DD` entry to `CHANGELOG.md` under `### Added`, mentioning the colourised listings, the zero-cost probe cache, the Linux-only `diff` wrapper, and that `grep`/`ip`/`man` colouring is not included.
- [x] 4.3 Run `bash ci/check-version.sh origin/main .` and confirm it reports `ok`, then run `openspec validate restore-listing-colours --strict` and confirm the change validates.
