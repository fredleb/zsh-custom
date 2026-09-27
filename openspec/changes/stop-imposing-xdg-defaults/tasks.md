## 1. Change the managed environment

- [x] 1.1 Remove the three `XDG_*` default-setting exports from `dot_zshenv` (keep the header comment and the `~/.local/bin` PATH block) and verify the file still parses with `zsh -n dot_zshenv`
- [x] 1.2 Confirm the framework resolves its own paths without the variables set: a fresh shell with no `XDG_*` variables loads `conf.d` and creates `$HOME/.cache/zsh`, verified by a sandbox shell that sources the config and prints `$ZSH_CONFIG`/`$ZSH_CACHE`

## 2. Regression guards in CI

- [x] 2.1 Add an assertion (in `ci/test-install.sh` or `ci/check-conveniences.sh`) that an interactive shell started with no `XDG_*` variables leaves them unset; verify it passes after 1.1 and fails if the exports are restored
- [x] 2.2 Add an assertion that a user-set `XDG_CONFIG_HOME` is honored (the managed configuration is resolved from it) and not overridden; verify it passes

## 3. Documentation

- [x] 3.1 Document the XDG interaction and the `NVM_DIR` pin recipe for users whose environment already sets `XDG_CONFIG_HOME`, in `README.md` and/or `docs/migrating-from-v2.md`; verify the recipe is present and matches the working form
- [x] 3.2 Record the change in `CHANGELOG.md` under a new version with a MINOR bump (changed user-visible behavior), and verify `ci/check-version.sh` passes

## 4. Verification

- [x] 4.1 Reproduce the failure and the fix with a simulated non-XDG tool (a fake nvm install): without the change the tool's binary is absent from `PATH`, with the change it is present; verify via the sandbox recipe
- [x] 4.2 On a machine with nvm installed, start a fresh login shell and confirm `NVM_DIR` resolves to `~/.nvm` and `command -v node` points at the nvm-managed Node (`node --version` matches the nvm default)
- [x] 4.3 Run `ci/test-install.sh`, `ci/check-conveniences.sh`, and `ci/check-version.sh` locally and confirm all pass
- [x] 4.4 Run `openspec validate "stop-imposing-xdg-defaults" --strict` and confirm the change validates
