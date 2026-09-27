## Why

The v2 design deliberately hand-rolled a distribution layer — a version-invariant managed block, a custom `install.sh`/`zsh-custom` CLI, user-layer seeding, and antigen migration — that duplicates what mature dotfiles managers already do. That bespoke lifecycle is the bulk of the maintenance cost, and it must independently track antidote, Starship, platform, and secret-handling changes. chezmoi already provides install, update, diff, drift detection, diagnostics, and uninstall across Linux and macOS, so the project can keep the parts it chose well (antidote for plugins, Starship for the prompt) and drop the reinvented wheel.

## What Changes

- **BREAKING** The repository becomes a chezmoi source directory. Distribution, install, update, uninstall, drift preview, and diagnostics are provided by chezmoi (`init --apply`, `update`, `diff`, `status`, `doctor`, `purge`) instead of the managed block and the custom `zsh-custom` CLI.
- **BREAKING** Remove `init.zsh`, `bin/zsh-custom`, `lib/`, the root `conf.d/`, the template-seeding user layer, and the antigen migration code.
- Managed files become `~/.zshenv`, `~/.zshrc`, `~/.config/zsh/**`, and `~/.config/starship.toml`.
- **BREAKING** User customization moves to untracked files the framework never manages: `~/.config/zsh/local.zsh`, `~/.config/zsh/secrets.zsh`, and `~/.zshrc.local`.
- Keep antidote for staged plugin loading and Starship for the prompt (config at Starship's default path).
- Treat chezmoi as a **system prerequisite** (OS/Homebrew package), consistent with antidote and Starship; do not install it from a mutable URL.
- Version the framework with git tags on the chezmoi source instead of a `VERSION` file.
- CI adds a macOS end-to-end install job alongside the existing lint and hygiene checks.
- First apply backs up any existing hand-edited shell files to `*.pre-chezmoi`.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `shell-bootstrap`: the install/update/uninstall/diagnostics lifecycle moves from a managed block plus a custom CLI to chezmoi; the prerequisite model adds chezmoi and macOS.
- `user-customization`: customization moves to untracked files sourced by the managed entrypoint; the framework no longer creates or owns a user layer.
- `secrets-handling`: the secrets file path changes and is explicitly never managed by the distribution tool.
- `distribution`: versioning moves to git tags on the chezmoi source; CI must cover macOS.

## Impact

- **Repo files removed**: `init.zsh`, `bin/zsh-custom`, `lib/`, root `conf.d/`, `templates/`, `VERSION`, `zsh_plugins.txt`, `zsh_plugins.git.txt`, `zsh_plugins.last.txt`, `starship.toml`.
- **Repo files added**: `.chezmoiversion`, `.chezmoiignore`, `dot_zshenv`, `dot_zshrc`, `dot_config/zsh/**`, `dot_config/starship.toml`, `run_once_before_00-backup.sh`, rewritten `install.sh`, `ci/test-install.sh`, `docs/migrating-from-v2.md`, updated CI.
- **Users**: existing v2 installs migrate through the new `install.sh` (which backs up `~/.zshrc`) and move personal settings into the untracked layer; documented in `docs/migrating-from-v2.md`.
- **Dependencies**: adds chezmoi (system/Homebrew package); keeps antidote and Starship; CI gains macOS.
- **Security**: the distribution tool never manages or commits the secrets file; secret scanning continues to gate the public repo.
