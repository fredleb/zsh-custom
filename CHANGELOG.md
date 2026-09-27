# Changelog

All notable changes to this project are documented here.
Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning: [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
