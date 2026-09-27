## 1. Convenience libraries

- [x] 1.0 Create `$ZSH_CACHE` in the plugin loader before writing bundles, and verify a bundle builds in a sandbox whose `$ZSH_CACHE` does not pre-exist
- [x] 1.1 Add `dot_config/zsh/plugins.omz.txt` containing `ohmyzsh/ohmyzsh path:lib/directories.zsh` and `ohmyzsh/ohmyzsh path:lib/history.zsh`, and verify `antidote bundle < dot_config/zsh/plugins.omz.txt` resolves both files
- [x] 1.2 Load the new list from `conf.d/00-antidote.zsh` in the stage after `compinit`, and verify `zsh -i -c 'alias l ll la lsa'` prints all four aliases
- [x] 1.3 Verify `..` navigation and its dependency: in an interactive shell `cd /tmp; ..; pwd` prints `/`, and `$options[AUTO_CD]` is `on`
- [x] 1.4 Verify history settings: `HISTFILE` is non-empty, `HISTSIZE` and `SAVEHIST` are raised, and `HIST_IGNORE_SPACE` is `on`; in an interactive shell run a command with a leading space and verify it is absent from `fc -l` afterwards, and that Up recalls a previously run command
- [x] 1.5 Fix the plugin loader so options set by loaded plugins persist: source each bundle outside the loader's `emulate -L zsh` scope and re-assert the convenience-library options after all stages, and verify `AUTO_CD`, `HIST_IGNORE_SPACE`, and `SHARE_HISTORY` are `on` in a fresh sandbox

## 2. Guard against regression

- [x] 2.1 Extend the checks in `ci/` to assert `l`, `ll`, `la`, `lsa` are defined, `AUTO_CD` is on, `HIST_IGNORE_SPACE` is on, and `HISTFILE` is non-empty, and verify the check fails when the plugin line is removed- [x] 2.2 Run `bash ci/test-install.sh` on a clean checkout and verify the end-to-end install still passes on Linux (and macOS in CI)
- [x] 2.3 Assert in `ci/test-install.sh` that plugins resolve in a fresh sandbox (no `plugin unavailable` warning), and verify the check fails when the cache-directory creation is removed

## 3. Release on every merge

- [x] 3.1 Add `ci/check-version.sh` that reads the top `## [x.y.z]` heading of `CHANGELOG.md` and compares it with a base ref, and verify it fails on an unchanged or unparseable version and passes on an increased one
- [x] 3.2 Add a CI job that runs the check for pull requests against `main` and fails the change when the version is not increased or the heading cannot be parsed
- [x] 3.3 Add a workflow that runs on push to `main` and creates the tag `v<top-changelog-version>` when it does not exist, verify a re-run creates no duplicate tag, grant it `contents: write`, and document the branch-protection requirement
- [x] 3.4 Bump the version and add a `CHANGELOG.md` entry for this change, and verify `ci/check-version.sh` passes against `main`

## 4. Documentation

- [x] 4.1 Document the listing/navigation conveniences, the history behaviour (Up/Down, space-prefixed commands excluded), their upstream source, and how to override them in `~/.config/zsh/local.zsh`, and verify the README and `CHANGELOG.md` mention the change
