## Why

The v2 rewrite dropped the full oh-my-zsh library and replaced it with a minimal
plugin set. Several behaviours users took for granted were supplied by that
library **at runtime**, were never written into any user file, and had no spec or
test covering them — so they vanished silently and users rediscover them one at a
time:

- the `l`, `ll`, `la`, and `lsa` directory-listing aliases and `..` navigation
  (`lib/directories.zsh`),
- interactive command history: persisted across sessions, navigable with Up/Down,
  with commands starting with a space excluded (`lib/history.zsh`).

Separately, the main branch can accumulate changes that were never versioned, so
the version on `main` does not identify the latest merged state, and nothing
forces a changelog entry or a tag at merge time.

## What Changes

- Load the upstream-maintained `ohmyzsh/ohmyzsh path:lib/directories.zsh` and
  `ohmyzsh/ohmyzsh path:lib/history.zsh` through antidote, in a load stage after
  `compinit`.
- Restore the directory listing aliases (`l`, `ll`, `la`, `lsa`) and `..`
  navigation (which the library provides by enabling `auto_cd`).
- Restore interactive history: persist it across sessions, navigate it with
  Up/Down, and never record a command that begins with a space.
- Promise these behaviours in a new `shell-conveniences` capability, sourced from
  the upstream-maintained project rather than a hand-maintained copy, and
  overridable by the user customization layer.
- Fix a pre-existing bootstrap bug found while implementing: on a machine whose
  `$ZSH_CACHE` directory does not already exist (any fresh install, and CI),
  every plugin bundle fails to write, so **all** plugins are silently disabled —
  including the ones this change adds. The configuration SHALL create the cache
  directory before writing bundles.
- Require that every merge to the main branch is a release: it increments the
  version, records the changelog entry, and produces a matching tag, enforced by
  CI.

## Capabilities

### New Capabilities

- `shell-conveniences`: the default shell conveniences — directory listing and
  navigation aliases, and interactive command-history behaviour — sourced from an
  upstream-maintained project and overridable by the user layer.

### Modified Capabilities

- `distribution`: the versioned-releases requirement changes from "publish
  releases using tags" to "every merge to the main branch is a release"
  (version + changelog + tag), and the CI requirement gains a version gate.

## Impact

- **Config**: a stage-2 plugin list gains `path:lib/directories.zsh` and
  `path:lib/history.zsh`; the plugin loader creates the cache directory before
  writing bundles.
- **Behaviour (new)**: `l`, `ll`, `la`, `lsa`, `..` (via `auto_cd`), and the
  directory-navigation set; persisted history with Up/Down navigation and
  `hist_ignore_space`; `history` runs oh-my-zsh's `omz_history`.
- **Workflows**: a CI version/changelog gate and a tag job on merge to `main`.
- **Specs**: new `shell-conveniences`; modified `distribution`.
- **Non-goals**: restoring the whole oh-my-zsh library, key bindings, or colored
  `ls`/`grep`; adding a package dependency (`eza`/`lsd`); reintroducing a
  `VERSION` file.
