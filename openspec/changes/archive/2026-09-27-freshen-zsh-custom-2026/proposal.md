## Why

`zsh-custom` is a small **public** zsh distribution used by the maintainer and colleagues across many machines. It has been dormant since 2017, its plugin manager (antigen) has been removed from the host system so the installed config currently fails on every shell start, and its installer **overwrites `~/.zshrc`**, so any user customization is destroyed on the next install. The repo also has no versioning, tests, or docs, and its supported secret pattern is to export tokens from a file that the installer backs up. The project needs to become a safe, upgradeable, well-maintained v2 before more people depend on it.

## What Changes

- **BREAKING** Replace the destructive `install.sh` model with a **stable managed block** in `~/.zshrc` that merely sources the framework entrypoint. The block is version-invariant, so upgrades become `git pull` and can never overwrite user lines.
- **BREAKING** Relocate all user-specific configuration out of the tracked repo into a user-owned `$ZSHRC_CUSTOM` layer (default `~/.config/zsh-custom`) that the installer creates if absent and **never modifies** afterwards.
- **BREAKING** Replace antigen with **antidote** and drop the full oh-my-zsh library load; load only the plugins actually needed.
- Replace the 128-line custom `themes/fidji.zsh-theme` with a **Starship** configuration (TOML) that reproduces the current look.
- Replace the exported `GITEA_TOKEN` pattern with a **secrets layer**: a per-user `secrets.zsh` (0600, gitignored) and guidance to prefer credential helpers; ensure secrets are never written into installer backups.
- Add an idempotent `update` path, a `doctor`/status command, and a **migration** path that preserves existing hand-edited configurations.
- Add release hygiene appropriate to a public tool: semver tags, `CHANGELOG.md`, CI (syntax check, secret scan, headless load test, idempotency test), docs, and a deprecation policy.
- Remove dead artifacts: antigen cache expectations, `*.zwc` compilation, and the removed `git.io/antigen` bootstrap.

## Capabilities

### New Capabilities
- `shell-bootstrap`: installation, update, and uninstallation lifecycle; the version-invariant managed block; idempotency; migration of existing installs; platform detection.
- `plugin-management`: antidote-based plugin loading, the curated default plugin set, and user extension via an extra plugin file.
- `prompt-theme`: the Starship prompt configuration replacing the custom theme.
- `user-customization`: the `$ZSHRC_CUSTOM` override layer, load ordering, and escape hatches that survive framework updates.
- `secrets-handling`: where secrets live, permissions, exclusion from version control and backups, and guidance for token-based tooling.
- `distribution`: versioning, changelog, releases, CI checks, documentation, and deprecation policy for a public shared tool.

### Modified Capabilities
<!-- None: the repo currently has no specs under openspec/specs/. -->

## Impact

- **Repo files**: `install.sh` (rewritten), `zshrc`/bootstrap (replaced by `init.zsh` + `conf.d/`), `themes/fidji.zsh-theme` (removed), new `zsh_plugins.txt`, `starship.toml`, `.gitignore`, `CHANGELOG.md`, docs, `.github/workflows/`.
- **Users**: existing installs are migrated non-destructively; the public GitHub repo gains a tagged `v2.0.0` release; upgrading stops requiring reinstall.
- **Dependencies**: introduces antidote and Starship, both **installed system-wide via the OS package manager** (not vendored per user); the repo never invokes privileged commands and only instructs the user when a dependency is missing; removes antigen and full oh-my-zsh; keeps `zsh-users` plugins.
- **Security**: the exposed Gitea token must be rotated by the maintainer; the public repo gains automated secret scanning.
- **Out of scope**: supporting shells other than zsh; per-project environment management (direnv) beyond leaving a documented hook.
