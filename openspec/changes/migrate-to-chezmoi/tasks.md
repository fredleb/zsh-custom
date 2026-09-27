## 1. chezmoi source tree

- [x] 1.1 Add `.chezmoiversion` (minimum `2.40.0`) and `.chezmoiignore` listing repo-only paths (`README.md`, `CHANGELOG.md`, `LICENSE`, `install.sh`, `.gitignore`, `ci/`, `.github/`, `openspec/`, `.opencode/`, `docs/`) and user-private patterns covering both root and the nested config paths (`local.zsh`, `secrets.zsh`, `*.local.zsh`, `.zshrc.local`, `.config/zsh/local.zsh`, `.config/zsh/secrets.zsh`); verify `chezmoi managed` and `chezmoi ignored` agree with the intended set.
- [x] 1.2 Add `dot_zshenv` (XDG variables and `~/.local/bin` on `PATH`); verify a sandbox apply creates `~/.zshenv` and `zsh -n` passes on it.
- [x] 1.3 Add `dot_zshrc` that sets `ZSH_CONFIG`/`ZSH_CACHE`, sources `$ZSH_CONFIG/conf.d/*.zsh` in lexical order, then `$ZSH_CONFIG/local.zsh`, then `$HOME/.zshrc.local`; verify a sandbox apply creates `~/.zshrc`, that `zsh -n` passes, and that a shell starts cleanly when no `conf.d` exists.

## 2. Plugin management

- [x] 2.1 Add `dot_config/zsh/plugins.txt`, `dot_config/zsh/plugins.git.txt`, and `dot_config/zsh/plugins.last.txt` carrying over the v2 default sets (completions, autosuggestions; git library + plugin; syntax highlighting last); verify the three files match the intent of `plugin-management`.
- [x] 2.2 Add `dot_config/zsh/conf.d/00-antidote.zsh` with `zshrc_antidote_path` (system paths plus the Homebrew `opt/antidote` path) and `zshrc_antidote_bundle_load` (cache into `$ZSH_CACHE`, fail-soft), then run `compinit` once and load the three stages; verify in a fresh shell that `compdef` is defined and completion, autosuggestions, git, and syntax highlighting are active, and that a shell still starts when antidote is absent.

## 3. Prompt, completion, and secrets fragments

- [x] 3.1 Add `dot_config/starship.toml` (carry over the v2 `starship.toml`) and `dot_config/zsh/conf.d/10-prompt.zsh` that runs `eval "$(starship init zsh)"` when `starship` exists and warns otherwise; verify the prompt renders from `~/.config/starship.toml` without any `STARSHIP_CONFIG` export.
- [x] 3.2 Add `dot_config/zsh/conf.d/05-completion.zsh` (carry over the v2 fragment, pointing the completion cache at `$ZSH_CACHE`) and `dot_config/zsh/conf.d/20-secrets.zsh` (source `$ZSH_CONFIG/secrets.zsh` when present, warn on group/other permissions); verify the interactive completion menu works and that a missing secrets file is silent while a `0644` one warns.
- [x] 3.3 Verify prompt parity against `prompt-theme` (host/time/runtime/git in the default foreground, colour-coded git states, blue host only over SSH, exactly one space after the prompt character) in a test repository.

## 4. Bootstrap and migration

- [x] 4.1 Rewrite `install.sh` to verify `chezmoi`, `antidote`, and `starship` are present, print per-platform install commands for any that are missing and exit non-zero, and otherwise `exec chezmoi init --apply "$@" <repo>`; verify it never installs a dependency and passes `ci/check-no-privilege.sh`.
- [x] 4.2 Add `run_once_before_00-backup.sh` copying existing `~/.zshrc`, `~/.zshenv`, `~/.zprofile`, and `~/.zlogin` to `*.pre-chezmoi` once; verify a sandbox first apply creates the backup and a second apply does not overwrite it.
- [x] 4.3 Add `docs/migrating-from-v2.md` covering the backup, moving `~/.config/zsh-custom/` content into `~/.config/zsh/local.zsh` and `secrets.zsh`, loading an extra plugin list with `antidote load`, and rollback to v2.

## 5. Remove the v2 framework

- [ ] 5.1 Confirm new paths carry all v2 content (`dot_config/starship.toml`, the three plugin lists, and the completion fragment exist) before deleting anything; verify the guard check passes and does not proceed otherwise.
- [ ] 5.2 Delete `init.zsh`, `bin/`, `lib/`, root `conf.d/`, `templates/`, `VERSION`, `zsh_plugins.txt`, `zsh_plugins.git.txt`, `zsh_plugins.last.txt`, and `starship.toml`; update `.gitignore`; verify `git ls-files` lists only the new layout and the end-to-end test still passes.

## 6. Continuous integration

- [ ] 6.1 Add `ci/test-install.sh` that applies the checked-out source to a throwaway `$HOME`, asserts the managed files exist, asserts a pre-existing `~/.zshrc` was backed up, asserts a second apply leaves no drift, and asserts a headless interactive shell starts without framework errors; verify it passes locally with `bash ci/test-install.sh`.
- [ ] 6.2 Update `.github/workflows/ci.yml`: keep lint (shellcheck + `zsh -n`) and hygiene (no-privilege + secret scan); run `ci/test-install.sh` on a matrix of `ubuntu-latest` and `macos-latest`, installing chezmoi/antidote/starship per platform; verify the workflow passes on both operating systems.

## 7. Documentation and release

- [ ] 7.1 Rewrite `README.md` for the chezmoi workflow (install, requirements including `brew install antidote` / `brew install chezmoi`, daily commands `chezmoi update|diff|doctor|status`, customization files, secrets, uninstall); verify a new user can follow it end to end.
- [ ] 7.2 Add the `v3.0.0` entry to `CHANGELOG.md` stating the breaking changes and required user actions, and tag `v3.0.0`; verify the tag exists and the changelog names the migration guide.
- [ ] 7.3 Verify `.opencode/` and `openspec/` remain in the repo and are excluded from the managed set.
