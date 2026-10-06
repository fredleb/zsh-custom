## 1. Select the emacs key map

- [ ] 1.1 Add `bindkey -e` to `dot_config/zsh/conf.d/06-keybindings.zsh` (top of the interactive block) and verify `bindkey -lL main` reports the emacs key map and `bindkey '^R'` resolves to `history-incremental-search-backward`
- [ ] 1.2 Confirm the existing arrow, navigation, and Delete-modifier bindings still resolve in the emacs key map; verify via `bindkey -M emacs` lookups

## 2. Behavioural verification

- [x] 2.1 Drive a pty with `EDITOR=vim` and confirm Ctrl-R recalls an earlier command by substring, and that Ctrl-A/Ctrl-E/Ctrl-W perform their emacs actions
- [x] 2.2 Confirm the override works: with `bindkey -v` set in the user customization layer, the shell uses the vi key map (ESC enters command mode)

## 3. CI assertion

- [x] 3.1 Extend `ci/check-conveniences.sh` to assert the active key map is emacs and `^R` is `history-incremental-search-backward`; verify it passes and fails if `bindkey -e` is removed

## 4. Documentation and release

- [x] 4.1 Document the emacs key map (and the `bindkey -v` override) in the README, and add a `CHANGELOG.md` entry under a new MINOR version; verify `ci/check-version.sh` passes

## 5. Verification

- [x] 5.1 Run `ci/test-install.sh` and `ci/check-conveniences.sh` locally and confirm both pass
- [x] 5.2 Run `openspec validate "use-emacs-keybindings" --strict` and confirm the change validates
