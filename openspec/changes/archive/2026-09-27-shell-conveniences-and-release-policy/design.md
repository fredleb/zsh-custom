## Context

See `proposal.md` — Why. Relevant current state:

- `conf.d/00-antidote.zsh` loads plugins in stages: stage 1 (`plugins.txt`) before
  `compinit`, stage 2 (`plugins.git.txt`) after `compinit` because those files call
  `compdef`, stage 3 (`plugins.last.txt`) for syntax highlighting.
- `lib/directories.zsh` calls `compdef _dirs d` at source time (stage 2) and sets
  `auto_cd`, which is what makes `..` work — it defines no `..` alias.
- `lib/history.zsh` has no external dependencies.
- Verified on the installed shell: `l`/`ll` undefined, `AUTO_CD` off, `HISTFILE`
  unset, `HISTSIZE=30`, `SAVEHIST=0`, `HIST_IGNORE_SPACE` off. zsh's default Up/Down
  bindings are `up-line-or-history`/`down-line-or-history`, so history navigation
  works once history is loaded and persisted.
- v3 dropped the `VERSION` file; the version is the git tag. `.github/workflows/ci.yml`
  has no release job, so tags are cut by hand.

## Goals / Non-Goals

**Goals:**

- Restore directory listing/navigation and interactive history from the
  upstream-maintained library, not a hand-written copy.
- Make every merge to the main branch a release, enforced mechanically.
- Keep the change reversible and free of new system dependencies.

**Non-Goals:**

- Restoring key bindings, colored `ls`/`grep`, `take`, or any other library part.
- Adding `eza`/`lsd`, or reintroducing a `VERSION` file.
- Inferring version bumps from commit messages.

## Decisions

### Decision: Source the conveniences from named upstream library files

Load `ohmyzsh/ohmyzsh path:lib/directories.zsh` and
`ohmyzsh/ohmyzsh path:lib/history.zsh` through antidote.

- Alternatives: a hand-written alias/history fragment (rejected — the requested
  maintained source); `plugins/common-aliases` (rejected — a far wider change:
  `rm`/`cp`/`mv -i`, `help=man`, file-suffix aliases); an `eza` plugin (rejected —
  a new system dependency); writing history options by hand (rejected — same
  reason as the aliases).

### Decision: Load both files in a new stage-2 list, not `plugins.git.txt`

Add `plugins.omz.txt` and load it from `conf.d/00-antidote.zsh` after `compinit`.

- Rationale: `directories.zsh` needs `compdef`, so stage 1 is too early; putting a
  directory/history library in the file named `plugins.git.txt` misleads readers.
- Alternatives: append to `plugins.git.txt` (rejected — misnamed); stage 3
  (works, but places general libraries after syntax highlighting).

### Decision: Keep `auto_cd` enabled

Keep the option the library sets, which is what makes `..` navigate.

- Rationale: `..` exists only as an `auto_cd` behaviour (verified: with `auto_cd`
  off, `..` fails with "permission denied"). Keeping upstream's option avoids a
  hand-written `..` alias and divergence from the maintained file.
- Alternatives: `unsetopt auto_cd` plus a hand-written `alias ..='cd ..'`
  (rejected — hand-maintained and divergent); dropping `..` (rejected — reported
  need).
- Trade-off accepted: typing a bare directory name changes into it; the user layer
  can `unsetopt auto_cd`.

### Decision: History navigation via zsh defaults, not `key-bindings.zsh`

Do not load `lib/key-bindings.zsh`. Its history effect (Up/Down beginning-search)
is a superset of the default `up-line-or-history`; loading it would also change
Home/End/Delete and word navigation, which are out of scope.

- Rationale: the reported need is "Up shows history, Up/Down navigate", which zsh
  provides once history is loaded. Scope discipline.
- Alternative: load `key-bindings.zsh` for a richer setup (deferred — see Open
  Questions).

### Decision: Ensure the plugin cache directory exists before writing bundles

The loader SHALL create `$ZSH_CACHE` before writing any bundle file.

- Rationale: found while implementing — `zshrc_antidote_bundle_load` writes
  `"$cache.tmp"` and then `mv`s it, but nothing creates `$ZSH_CACHE` in the
  sourcing path. On a fresh install (and in CI) the directory is absent, so every
  `antidote bundle` write fails and **all** plugins are reported
  "plugin unavailable" — not just the new ones. The bug only stays hidden on a
  machine whose `~/.cache/zsh` predates the chezmoi migration.
- Alternatives: rely on `dot_zshrc` to create it (rejected — fragile: it depends
  on a file outside the fragment's control being sourced first, which is not the
  case in the sandbox or in `zsh -f`-style invocations); create it in each
  `mkdir -p` call site (rejected — one obvious place is enough).
- Consequence: `ci/test-install.sh` SHALL also assert that plugins resolve, so a
  silent all-plugins-disabled regression cannot return.

### Decision: Version identity and enforcement

The version is the newest `## [x.y.z]` changelog heading plus the matching tag; no
`VERSION` file. The pull request that will be merged carries the bump (MAJOR
breaking, MINOR new/changed capability, PATCH otherwise). A check job compares the
pull request's top changelog version against the base branch; a job on push to
`main` creates the tag for the current top version if it does not exist.

- Rationale: keeps one source of truth, keeps release credentials off pull
  requests, and makes tagging idempotent across several merges between runs.
- Alternatives: reintroduce `VERSION` (rejected — the second source of truth v3
  removed); a bot inferring bumps from commit types (rejected — extra third-party
  action and unreliable inference); manual tagging (rejected — unenforced).

## Risks / Trade-offs

- **`auto_cd` surprises a user who types a directory name expecting a command** → documented;
  matches pre-v2 behaviour; user layer can disable it.
- **`lib/history.zsh` sets `alias history=omz_history`** → the `history` command output
  changes. Accepted; documented.
- **Merging settings with an existing partial `~/.zsh_history`** → the existing file is used
  as-is; history accumulates from now on. No format change is introduced.
- **Upstream edits the library files** → definitions change under us. Mitigation: both are
  longstanding files; CI asserts the promised behaviours.
- **Version churn** — every merge produces a tag, including docs/CI. Accepted.
- **Changelog heading parsing breaks** on reformatting → the check fails closed and names
  the expected format.
- **Admin/`--no-verify` merges bypass the check** → the tag job still runs on push;
  document a branch-protection rule.
- **A missing cache directory silently disables every plugin** → the loader creates
  `$ZSH_CACHE` before writing bundles, and `ci/test-install.sh` asserts plugins
  resolve so the regression cannot return unnoticed.

## Migration Plan

1. Land the plugin list and the workflows together; bump the version and changelog
   for this change.
2. `chezmoi update` applies it; the conveniences appear in the next shell, history
   begins persisting, and the `~/.zsh_history` already on disk is picked up.
3. Rollback: revert the plugin list and workflows; the previous shell behaviour
   returns. Existing tags remain valid.
4. Note in the changelog that commands beginning with a space are no longer
   recorded going forward (past entries remain in the history file).

## Open Questions

- Whether to also load `lib/key-bindings.zsh` (Home/End/Delete, word navigation) in
  a later change. Deferred; it does not affect the specs or tasks here.
