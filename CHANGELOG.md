# Changelog

All notable changes to this project are documented here.
Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning: [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.3.0] - 2026-09-27

### Fixed
- The terminal navigation keys (Delete, Home, End, Insert, PageUp, PageDown)
  now perform their editing action instead of inserting escape sequences or
  changing the editing mode. Previously, with the vi keymap selected (when
  `$EDITOR` contains `vi`), a key's escape sequence was read as "leave insert
  mode" and the rest ran as vi commands — Delete, for example, changed the case
  of the following text. The keys are bound in the emacs, vi, and vi-command
  keymaps, using the terminal's advertised sequences with well-known fallbacks
  (`dot_config/zsh/conf.d/06-keybindings.zsh`).

## [3.2.2] - 2026-09-27

### Changed
- Recorded the contribution rule that continuous integration verifies pull
  requests but a human maintainer reviews and performs the merge; automation
  and AI agents must not merge (or close, or force-push over review) without
  explicit consent. Added `AGENTS.md` so agents follow the rule operationally.

## [3.2.1] - 2026-09-27

### Changed
- Project specifications updated to record the 3.2.0 prefix history search and
  the XDG base-directory behavior, and the corresponding completed changes
  archived. No shell behavior change.

### Fixed
- The end-to-end CI check no longer fails intermittently on macOS when git's
  detached background maintenance races the throwaway sandbox cleanup.

## [3.2.0] - 2026-09-27

### Added
- Up/Down now walk the history entries that begin with the text typed at the
  prompt, so typing `opens` then pressing Up recalls the most recent `opens…`
  command and further presses walk older matches. A repeated command is shown
  only once. On an empty prompt Up/Down keep the previous recall behaviour, and
  in a multi-line edit they move the cursor. Bound for both the emacs and vi
  editing modes (`dot_config/zsh/conf.d/06-keybindings.zsh`).

### Changed
- The shell no longer sets `XDG_CONFIG_HOME`, `XDG_CACHE_HOME`, or
  `XDG_DATA_HOME` to their default values. Setting them is not neutral: a tool
  that derives its home from an XDG variable when it is set (such as Debian's
  nvm init, which pointed `NVM_DIR` at `~/.config/nvm`) could be redirected away
  from its existing data and disappear from `PATH`. Set them yourself if you
  want them; the framework still uses them when present. If a tool stops finding
  its data, pin its home in `local.zsh` (see the README).

## [3.1.2] - 2026-09-27

### Fixed
- The release workflow now publishes a **GitHub Release**, not only a git tag.
  A tag alone does not appear on the repository's releases page, which is why
  `v3.1.1` was tagged but showed no new release. Release notes are taken from the
  changelog section for that version.

## [3.1.1] - 2026-09-27

### Fixed
- The release workflow now creates the version tag. Tagging failed on the CI
  runner with "empty ident name" because an annotated tag needs a committer
  identity; the workflow now sets the GitHub Actions bot identity. As a result
  `v3.1.0` was recorded in the changelog but never tagged.

## [3.1.0] - 2026-09-27

### Added
- Directory listing and navigation aliases restored (`l`, `ll`, `la`, `lsa`,
  `md`, `rd`, `-`, `1`–`9`, `d`, and `..`), loaded from the upstream-maintained
  `ohmyzsh/ohmyzsh lib/directories.zsh` through antidote.
- Interactive command history restored: it persists across sessions, Up/Down
  recall it, and it is shared between shells
  (`ohmyzsh/ohmyzsh lib/history.zsh`).
- A command line beginning with a space is no longer recorded in history
  (`hist_ignore_space`).
- Every merge to the main branch is a release: the version and changelog entry
  are required, CI blocks a merge without them, and a workflow tags the merged
  version.

### Fixed
- Plugins are now loaded on a machine whose `~/.cache/zsh` does not already
  exist. Previously every bundle write failed, so **all** plugins were silently
  disabled on a fresh install (and in CI); only pre-existing installs were
  unaffected.
- Options set by loaded plugins now persist. The loader's `emulate -L zsh` scope
  discarded them, which is why `auto_cd` and the history options had no effect.

### Notes
- `..` works because the library enables `auto_cd`; typing a bare directory name
  also changes into it, matching the pre-v2 behavior. Disable it with
  `unsetopt auto_cd` in `~/.config/zsh/local.zsh`.
- `lib/history.zsh` aliases `history` to oh-my-zsh's `omz_history`.
- Space-prefixed commands already present in `~/.zsh_history` remain; exclusion
  applies from this release onward.

## [3.0.0] - 2026-09-27

### Changed
- **BREAKING** Distribution is now handled by **chezmoi**. The custom installer,
  the version-invariant managed block in `~/.zshrc`, the `zsh-custom` CLI, and
  the seeded user layer are removed. Use `chezmoi update`, `chezmoi diff`,
  `chezmoi status`, and `chezmoi doctor`.
- The repository is now a **chezmoi source directory**. Managed files are
  `~/.zshenv`, `~/.zshrc`, `~/.config/zsh/**`, and `~/.config/starship.toml`.
- Personal configuration lives in untracked files that updates never touch:
  `~/.config/zsh/local.zsh`, `~/.config/zsh/secrets.zsh`, and `~/.zshrc.local`.
- chezmoi, antidote, and Starship are system prerequisites; the configuration
  never installs packages and never escalates privileges.
- Versioning is by git tags on the source; there is no `VERSION` file.

### Added
- macOS is now a supported, CI-verified platform (the end-to-end install test
  runs on both Linux and macOS).
- `docs/migrating-from-v2.md` documents the one-time migration and rollback.
- A first-run backing up of existing shell files to `*.pre-chezmoi`.

### Removed
- `init.zsh`, `bin/zsh-custom`, `lib/`, the root `conf.d/`, `templates/`,
  `VERSION`, and the legacy plugin-list files.

### Migration
- Run the new `install.sh`; it backs up your existing `~/.zshrc` and applies the
  chezmoi source. Move personal settings from `~/.config/zsh-custom/` into
  `~/.config/zsh/local.zsh` and `~/.config/zsh/secrets.zsh`. See
  [docs/migrating-from-v2.md](docs/migrating-from-v2.md).

## [2.0.1] - 2026-09-27

### Fixed
- **README**: corrected the install/upgrade instructions — the CLI location and
  `PATH` context, a real example version (the old one did not exist), an
  existing-clone path, a pre-v2 upgrade path, and a troubleshooting section.
- **Completion**: restored the interactive completion menu (selectable list,
  arrow-key navigation, highlighting) that the previous configuration provided.
- **Prompt**: the host, time, runtime, and git branch name now use the
  terminal's default foreground so they stay readable on light backgrounds;
  git status indicators are color-coded by state; the host is blue only for
  remote sessions; the extra space after the prompt character is gone.

## [2.0.0] - 2026-09-27

### Added
- Stable, version-invariant managed block in `~/.zshrc` that sources a single
  entrypoint. Upgrades no longer rewrite your shell configuration.
- User customization layer at `$ZSHRC_CUSTOM` (default `~/.config/zsh-custom`)
  with `plugins.txt`, `conf.d/`, `theme.toml`, `secrets.zsh`, and `local.zsh`.
  It is created once and never overwritten by updates.
- `zsh-custom` CLI: `install`, `update`, `doctor`, `refresh`, `version`, `uninstall`.
- System dependency detection with per-platform install instructions. The
  framework never installs packages and never invokes `sudo`/`su`/`doas`.
- Secret handling: per-user `secrets.zsh` (mode 600) with a permissions warning,
  and CI secret scanning.
- CI: shellcheck, `zsh -n`, secret scan, no-privilege check, headless install,
  and idempotency checks.

### Changed
- Plugins are managed by **antidote** (system-installed) instead of antigen.
- The prompt is provided by **Starship** instead of the bundled custom theme.
- The full oh-my-zsh library is no longer loaded; only the needed plugins are.
- The installer is non-destructive and idempotent.

### Removed
- `themes/fidji.zsh-theme` (replaced by Starship).
- The antigen bootstrap and its `git.io/antigen` download.
- The template-copying installer that overwrote `~/.zshrc`.

### Migration
- **One-time migration:** on first install, a legacy antigen-based `~/.zshrc`
  is backed up before anything changes. Your custom lines are relocated into
  `$ZSHRC_CUSTOM/conf.d/00-migrated.zsh`, and any secret-looking lines into
  `$ZSHRC_CUSTOM/secrets.zsh` (mode 600). Review both files, and **rotate any
  token that was previously exported** from your shell configuration.
- Old `~/.zshrc.*` backups may contain secrets; review and delete them.
